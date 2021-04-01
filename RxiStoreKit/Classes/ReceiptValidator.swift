//
//  ReceiptValidator.swift
//  RxiStoreKit
//
//  Created by azbowMNk on 2021-03-23.
//

import Foundation
import RxCocoa
import RxSwift

public class ReceiptValidator {
    
    public static var shared: ReceiptValidator = ReceiptValidator()
    
    private init() {}
    
    /*
     Setting Object Include various kind of variables required for verification receipt
     Can use those default values or change public values with requirement.
     */
    /*
     password: String
     -
     - Your app’s shared secret, which is a hexadecimal string.
     */
    public func prepareValidate() -> Observable<(defaultSetting: VerifyRequestSetting, receiptData: String)> {
        do {
            guard let receiptURL = Bundle.main.appStoreReceiptURL else {
                throw VerifyError.noReceipet
            }
            
            let receiptData = try Data(contentsOf: receiptURL, options: .alwaysMapped)
            let base64 = receiptData.base64EncodedString(options: [])
            
            return Observable.of((VerifyRequestSetting(), base64))
            
        } catch let err {
            return Observable.error(err)
            
        }
    }
    
    /*
     -Non-Open APIs for public.
     -Check Pending renewal info array of expired subscription for win back.
     -Check Pending renewal info array of on-going subscription for know user have de-activate.
        - If user have deactive auto renewing. Programmer have to give some win back offers.
     */
    fileprivate func checkPendingRenewalDataForExpireDatePassed(_ pendingRenewalInfo: PendingRenewalInfo) -> ReceiptResponse {
        var response = ReceiptResponse.init(productId: pendingRenewalInfo.autoRenewProductId,
                                            entitlementCode: "")
        var isOnGracePeriod = false
        var isOnBillingRetry = false
        
        if let gracePeriod = TimeInterval(pendingRenewalInfo.gracePeriodExpiresDateMS)?.removeMilliSeconds,
           gracePeriod > Date().timeIntervalSince1970 {
            isOnGracePeriod = true
        }
        
        if let onBllingRetry = pendingRenewalInfo.isInBillingRetryPeriod {
            isOnBillingRetry = onBllingRetry == .true
        }
        
        let expirationIntent = pendingRenewalInfo.expirationIntent ?? .unowned
        
        switch expirationIntent {
        case .billingError, .unowned:
            let entitlementCode: String
            
            switch (isOnBillingRetry, isOnGracePeriod) {
            case (_, true):
                entitlementCode = SubscriptionStateCohort.expired_in_grace_peropd.add(.standard_subscription)
                
            default:
                entitlementCode = SubscriptionStateCohort.purchase_issue.add(.standard_subscription)
            }
    
            response.entitlementCode = entitlementCode
            response.isBillingError = true
            response.message = "Some thing went wrong with payment. Click here to check your subscription details."
            response.manageDeepLink = "https://apps.apple.com/account/billing"// un-subcribe - expire from billing - 0
            return response
            
        case .disAgreedToPriceIncreace:
            let entitlementCode: String
            
            switch (isOnBillingRetry, isOnGracePeriod) {
            case (_, true):
                entitlementCode = SubscriptionStateCohort.expired_in_grace_peropd.add(.introductory_offer)
                
            default:
                entitlementCode = SubscriptionStateCohort.faild_to_accept_price_increase.add(.introductory_offer)
            }
            
            response.entitlementCode = entitlementCode
            return response
        // un-subcribe -3

        case .canceled:
            let entitlementCode: String
            
            switch (isOnBillingRetry, isOnGracePeriod) {
            case (_, true):
                entitlementCode = SubscriptionStateCohort.expired_in_grace_peropd.add(.free_trial)
                
            default:
                entitlementCode = SubscriptionStateCohort.expired_volantarilly.add(.free_trial)
            }
            
            response.entitlementCode = entitlementCode
            response.userCancelled = true
            return response

        case .productNotAvailable:
            let entitlementCode: String
            
            switch (isOnBillingRetry, isOnGracePeriod) {
            case (_, true):
                entitlementCode = SubscriptionStateCohort.expired_in_grace_peropd.add(.introductory_offer)
                
            default:
                entitlementCode = SubscriptionStateCohort.product_not_available.add(.introductory_offer)
            }
            
            response.entitlementCode = entitlementCode
            response.productNotAvailable = true
            response.message = "The product was not available this time "
            response.manageDeepLink = "https://apps.apple.com/account/billing"
            return response// un-subcribe -4
        }
    }
    
    fileprivate func checkPendingRenewalDataForOnHeadExpireDate(_ pendingRenewalInfo: PendingRenewalInfo) -> ReceiptResponse {
        var response = ReceiptResponse.init(productId: pendingRenewalInfo.autoRenewProductId, entitlementCode: "")
        if pendingRenewalInfo.autoRenewStatus == .offed {
            response.entitlementCode = SubscriptionStateCohort.active_auto_renew_off.add(.subscription_offer)// subcribe 4
            response.userCancelled = true
            return response
            
        } else {
            response.entitlementCode = SubscriptionStateCohort.active_auto_renew_on.add(.standard_subscription)// subcribe 5
            return response
        }
    }
}

/*
 Extension to validate recipt by given VerifyRequestSetting s.
 */
public extension ObservableType where Element == VerifyRequestSetting {
    ///    Validate Receipt with app store.
    ///    Response return with decode to given decodable type.
    func validate<T: Decodable>(_ responseMappingObject: T.Type) -> Observable<T> {
        flatMapLatest { setting -> Single<T> in
            Single.create { single in
                var urlDisposable: Disposable?
                do {
                    guard Reacherbility.isInternetAccessible else{
                        throw VerifyError.noInternet
                    }

                    guard let requestBody = setting.requestBody else { throw VerifyError.emptyRequestBody }
                    
                    let jsonBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
                    
                    var request = URLRequest(url: setting.verifyServerUrl, cachePolicy: .reloadIgnoringCacheData)
                    request.httpMethod = "POST"
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    request.httpBody = jsonBody
                    
                    let sheduler = ConcurrentDispatchQueueScheduler.init(qos: .background)
                    
                    urlDisposable = URLSession.shared.rx.data(request: request).timeout(.seconds(30), scheduler: sheduler)
                        .decodeRecipt()
                        .subscribe(onNext: {
                            single(.success($0))
                            
                        }, onError: {
                            single(.error($0))
                            
                        })
                    
                } catch let error {
                    single(.error(error))
                }
                
                return Disposables.create {
                    urlDisposable?.dispose()
                }
            }
        }
    }
}


public extension ObservableType where Element == Receipt {
    ///    Verify receipt whether include subscription 'product id' and decode result to chrodocode
    func cohort(_ productId: String) -> Observable<ReceiptResponse> {
        map { receipt  in
            guard receipt.status == .valid,
                  receipt.receipt.bundleId == Bundle.main.bundleIdentifier,
                  !receipt.receipt.inApp.filter({ $0.productId == productId }).isEmpty else {
                
                return ReceiptResponse.init(productId: productId,
                                            entitlementCode: SubscriptionStateCohort.expired.add(.standard_subscription))
            } //unsubcribe without any offer
            
            
            /*
             - Check latest expire data.
             - Latest receipt info or in-app receipt array
             - If there is no expire data found, Concern this subscription has no expire date.
             */
            let _latestExpireDateMS: String?
            let _latestSubDateMS: String?
            
            if let latestReceipt = receipt.latestReceiptInfo {
                var subProductArray = latestReceipt
                    .filter{ $0.productId == productId }
                subProductArray.sort{ $0.expiresDateMS > $1.expiresDateMS }
                
                let latestReceipt = subProductArray.first
                
                _latestExpireDateMS = latestReceipt?.expiresDateMS
                _latestSubDateMS = latestReceipt?.purchaseDateMS
                
            } else {
                var reciptsForProduct = receipt.receipt.inApp
                    .filter{ $0.productId == productId }
                reciptsForProduct.sort{ $0.expiresDateMS > $1.expiresDateMS }
                
                let latestRecipt = reciptsForProduct.first
                
                _latestExpireDateMS = latestRecipt?.expiresDateMS
                _latestSubDateMS = latestRecipt?.purchaseDateMS
                
            }
            
            guard let latestExpireDateMSString = _latestExpireDateMS,
                  let latestExpireDateMS = Double(latestExpireDateMSString)?.removeMilliSeconds else {
                
                var response = ReceiptResponse.init(productId: productId,
                                            entitlementCode: SubscriptionStateCohort.non_renew_subscription.add(.standard_subscription))
                response.startDate = _latestSubDateMS
                return response
                
            } //Subcribe without expire data(Not a renewing subscription). 3
            
            let now = Date().timeIntervalSince1970
            
            if now > latestExpireDateMS {
                guard let pendingRenewalInfo = receipt.pendingRenewalInfo?.filter({ $0.productId == productId }).first else {
                    
                    return ReceiptResponse.init(productId: productId,
                                                entitlementCode: SubscriptionStateCohort.expired.add(.standard_subscription))
                    
                } //Unsubcribe. offer trial
                
                var response = ReceiptValidator.shared.checkPendingRenewalDataForExpireDatePassed(pendingRenewalInfo)
                response.startDate = _latestSubDateMS
                response.endDate = _latestExpireDateMS
                return response
                
            } else {
                guard let pendingRenewalInfo = receipt.pendingRenewalInfo?.filter({ $0.productId == productId }).first else {
                    
                    var response = ReceiptResponse.init(productId: productId,
                                                entitlementCode: SubscriptionStateCohort.active_auto_renew_on.add(.standard_subscription))
                    response.startDate = _latestSubDateMS
                    response.endDate = _latestExpireDateMS
                    return response
                    
                } //Subcribe 5
                
                var response = ReceiptValidator.shared.checkPendingRenewalDataForOnHeadExpireDate(pendingRenewalInfo)
                response.startDate = _latestSubDateMS
                response.endDate = _latestExpireDateMS
                return response
            }
        }
    }
}


public struct ReceiptResponse {
    let productId: String
    var entitlementCode: String
    var startDate: String!
    var endDate: String!
    var gracePeriodExpireDate: TimeInterval!
    
    var isBillingError: Bool = false
    var message: String?
    var manageDeepLink: String?
    var userCancelled: Bool = false
    var productNotAvailable = false
}
