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
        
//        guard pendingRenewalInfo.gracePeriodExpiresDateMS == nil else {
//
//            response.entitlementCode = SubscriptionStateCohort.expired_in_grace_peropd.add(.standard_subscription)
//            response.gracePeriodExpireDate = pendingRenewalInfo.gracePeriodExpiresDateMS
//            response.isBillingError = true
//            return response//Subcribe. Notice user to subscription will expire soon 1
//        }
        
        if let gracePeriod = TimeInterval(pendingRenewalInfo.gracePeriodExpiresDateMS)?.removeMilliSeconds,
           gracePeriod > Date().timeIntervalSince1970 {
            
            let expirationIntent = pendingRenewalInfo.expirationIntent ?? .unowned
            
            switch expirationIntent {
            case .canceled:
                response.entitlementCode = SubscriptionStateCohort.expired_in_grace_peropd.add(.free_trial)
                response.isBillingError = false
                return response
                
            case .disAgreedToPriceIncreace, .billingError, .unowned:
                response.entitlementCode = SubscriptionStateCohort.expired_in_grace_peropd.add(.standard_subscription)
                response.isBillingError = true
                response.message = "Some thing went wrong with payment. Click here to check your subscription details."
                response.manageDeepLink = "https://apps.apple.com/account/billing"
                
                return response
                
            case .productNotAvailable:
                response.entitlementCode = SubscriptionStateCohort.expired_in_grace_peropd.add(.introductory_offer)
                response.isBillingError = true
                response.message = "The product was not available this time "
                response.manageDeepLink = "https://apps.apple.com/account/billing"
                
                return response
            }
            
            
        }
        
        if let isInBillingRetry = pendingRenewalInfo.isInBillingRetryPeriod,
           let expirationIntent = pendingRenewalInfo.expirationIntent {
            
            guard isInBillingRetry == .true else {
                return SubscriptionStateCohort.expired_from_billing.add(.subscription_offer)// unsubcribe - User have not subcribe till end of the retry -2
            }
            
            switch expirationIntent {
            case .billingError:
                return SubscriptionStateCohort.purchase_issue.add(.standard_subscription)// un-subcribe - expire from billing - 0
            
            case .disAgreedToPriceIncreace:
                return SubscriptionStateCohort.faild_to_accept_price_increase.add(.introductory_offer)// un-subcribe -3
            
            case .canceled:
                return SubscriptionStateCohort.expired_volantarilly.add(.free_trial)// un-subcribe -5
            
            case .productNotAvailable:
                return SubscriptionStateCohort.product_not_available.add(.introductory_offer)// un-subcribe -4
            
            case .unowned:
                return SubscriptionStateCohort.expired.add(.standard_subscription)//un-subcribe
            }
            
        } else {
            return SubscriptionStateCohort.expired.add(.standard_subscription)
        }
        
    }
    
    fileprivate func checkPendingRenewalDataForOnHeadExpireDate(_ pendingRenewalInfo: PendingRenewalInfo) -> String {
        if pendingRenewalInfo.autoRenewStatus == .offed {
            return SubscriptionStateCohort.active_auto_renew_off.add(.subscription_offer)// subcribe 4
        } else {
            return SubscriptionStateCohort.active_auto_renew_on.add(.standard_subscription)// subcribe 5
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
            let _latestExpireDateMS: Double?
            if let latestReceipt = receipt.latestReceiptInfo {
                var expireDatesMS = latestReceipt
                    .filter{ $0.productId == productId }
                    .compactMap{ $0.expiresDateMS }
                    .compactMap{ Double($0)?.removeMilliSeconds }
                
                expireDatesMS.sort{ $0 > $1 }
                _latestExpireDateMS = expireDatesMS.first
                
            } else {
                var expireDatesMS = receipt.receipt.inApp
                    .filter{ $0.productId == productId }
                    .compactMap{ $0.expiresDateMS }
                    .compactMap{ Double($0)?.removeMilliSeconds }
                
                expireDatesMS.sort{ $0 > $1 }
                _latestExpireDateMS = expireDatesMS.first
                
            }
            
            guard let latestExpireDateMS = _latestExpireDateMS else {
                return ReceiptResponse.init(productId: productId,
                                            entitlementCode: SubscriptionStateCohort.non_renew_subscription.add(.standard_subscription))
            } //Subcribe without expire data(Not a renewing subscription). 3
            
            let now = Date().timeIntervalSince1970
            
            if now > latestExpireDateMS {
                guard let pendingRenewalInfo = receipt.pendingRenewalInfo?.filter({ $0.productId == productId }).first else {
                    fatalError("Subscription Product id not available for auto renew subscription product id: \(productId)")
                } //Unsubcribe. offer trial
                return ReceiptValidator.shared.checkPendingRenewalDataForExpireDatePassed(pendingRenewalInfo)
                
            } else {
                guard let pendingRenewalInfo = receipt.pendingRenewalInfo?.filter({ $0.productId == productId }).first else {
                    return ReceiptResponse.init(productId: productId,
                                                entitlementCode: SubscriptionStateCohort.active_auto_renew_on.add(.standard_subscription))
                } //Subcribe 5
                
                return ReceiptValidator.shared.checkPendingRenewalDataForOnHeadExpireDate(pendingRenewalInfo)
            }
        }
    }
}


public struct ReceiptResponse {
    let productId: String
    var entitlementCode: String
    var startDate: TimeInterval!
    var endDate: TimeInterval!
    var gracePeriodExpireDate: TimeInterval!
    
    var isBillingError: Bool = false
    var message: String?
    var manageDeepLink: String?
}
