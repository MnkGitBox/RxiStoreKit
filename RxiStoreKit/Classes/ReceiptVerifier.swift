//
//  ReceiptVerifier.swift
//  RxiStoreKit
//
//  Created by azbowMNk on 2021-03-23.
//

import Foundation
import RxCocoa
import RxSwift

public typealias ReceiptLog = [String : Any]

public enum VerifyError: Error {
    case noReceipet
    case noInternet
    case jsonSerialization
    case secKeyVerify
    case undefine
    case none
    
    case invalid(code: Int)
    
}

extension VerifyError {
    public var description: String {
        let message: String
        switch self {
        case .invalid(21000), .jsonSerialization:
            message = "The App Store could not read the JSON object you provided."
            
        case .invalid(21002), .noReceipet:
            message = "The data in the receipt-data property was malformed or missing."
            
        case .invalid(21003):
            message = "The receipt could not be authenticated."
            
        case .invalid(21004):
            message = "The shared secret you provided does not match the shared secret on file for your account."
            
        case .invalid(21005):
            message = "The receipt server is not currently available."
            
        case .invalid(21006):
            message = "This receipt is valid but the subscription has expired. When this status code is returned to your server, the receipt data is also decoded and returned as part of the response."
            
        case .invalid(21007):
            message = "This receipt is from the test environment, but it was sent to the production environment for verification. Send it to the test environment instead."
            
        case .invalid(21008):
            message = "This receipt is from the production environment, but it was sent to the test environment for verification. Send it to the production environment instead."
            
        case .noInternet:
            message = "No internet connection appear to be connected."
            
        default:
            message = "Unknown error occured."
        }
        
        return message
    }
}


public class ReceiptVerifier {
    
    private var IapUrlString: URL {
        #if DEBUG
        return URL.init(string: Constants.iapSandBox)!
        #else
        return URL.init(string: Constants.iapProduction)!
        #endif
    }
    
    public static var shared: ReceiptVerifier = ReceiptVerifier()
    
    private init() {}

    public func verify(_ productId: String, excludeOldTransaction isExclude: Bool = false) -> Single<Reciept> {
        Single<Reciept>.create { [unowned self] observer in
            var urlDisposable: Disposable?
            
            do {
                guard let receiptURL = Bundle.main.appStoreReceiptURL else {
                    throw VerifyError.noReceipet
                }
                
                guard Reacherbility.isInternetAccessible else{
                    throw VerifyError.noInternet
                }
                
                let receiptData = try Data(contentsOf: receiptURL, options: .alwaysMapped)
//                let base64 = receiptData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
                let base64 = receiptData.base64EncodedString(options: [])
                let jsonBody = try JSONSerialization.data(withJSONObject:
                    [ RequestKey.recipt : base64,
                     RequestKey.excludeOldTransaction : isExclude ], options: [])
                var request = URLRequest(url: self.IapUrlString, cachePolicy: .reloadIgnoringCacheData)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                request.httpBody = jsonBody

                let sheduler = ConcurrentDispatchQueueScheduler.init(qos: .background)
                
                urlDisposable = URLSession.shared.rx.json(request: request).timeout(.seconds(30), scheduler: sheduler)
                    .flatMapLatest {
                        ($0 as! ReceiptLog).varyfiedData(of: productId)
                    }
                    .subscribe(onNext: {
                        observer(.success($0))
                        
                    }, onError: {
                        observer(.error($0))
                        
                    })

            } catch let error {
                observer(.error(error))
            }
            
            return Disposables.create {
                urlDisposable?.dispose()
            }
        }
    }
}

extension ReceiptLog {
    func varyfiedData(of productId: String) -> Observable<Reciept> {
        guard let data =  (self[ResponseKey.renewalInfo] as? [[String:Any]])?.filter({$0.stringVal(for: ResponseKey.autoRenewPid) == productId}).first else {
            return Observable.error(VerifyError.jsonSerialization)
        }
        
        let statusCode = data.intVal(for: ResponseKey.statusCode)
        
        if statusCode == 0 {
            let subcriptionPlayLoads = (self[ResponseKey.latestReceipt] as? [[String:Any]])?.filter({$0.stringVal(for: ResponseKey.productId) == productId}) ?? []
            let finalPlayLoadExMs = subcriptionPlayLoads.map{$0.stringVal(for: ResponseKey.expireDateMs)}.max()
            let latestPayload = subcriptionPlayLoads.filter({$0.stringVal(for: ResponseKey.expireDateMs) == finalPlayLoadExMs}).first
            let playLoadEx = latestPayload?.stringVal(for: ResponseKey.expireDate)
            let playLoadSubDate = latestPayload?.stringVal(for: ResponseKey.originalPurchaseDate)
            
            return Observable.of(Reciept.init(renewalInfo: data, expireDate: playLoadEx, subcribedDate: playLoadSubDate))
            
        } else {
            return Observable.error(VerifyError.invalid(code: statusCode))
            
        }
    }
}


public struct Reciept {
    
    public let productId: String
    public let inRenewStatus: Bool
    public let isExpired: Bool
    public let isInBillingRetryPeriod: Bool
    public let transactionID: String
    public let autoRenewProductID: String
    public let expireDate: String?
    public let subcribedDate: String?
    
    init (renewalInfo: [String : Any], expireDate: String?, subcribedDate: String?) {
        self.productId = renewalInfo.stringVal(for: ResponseKey.productId)
        self.inRenewStatus = renewalInfo.stringVal(for: ResponseKey.autoRenewState).bool
        self.isExpired = renewalInfo.stringVal(for: ResponseKey.expireIntent).bool
        self.isInBillingRetryPeriod = renewalInfo.stringVal(for: ResponseKey.onBillingRetry).bool
        self.transactionID = renewalInfo.stringVal(for: ResponseKey.originalTransactionId)
        self.autoRenewProductID = renewalInfo.stringVal(for: ResponseKey.autoRenewPid)
        self.expireDate = expireDate
        self.subcribedDate = subcribedDate
    }
}


public extension Dictionary where Key == String{
    func stringVal(for key:String)->String{
        return self[key] as? String ?? ""
    }
    func intVal(for key:String)->Int{
        return self[key] as? Int ?? 0
    }
    func dictionaryValue(for key:String)->[String:Any]{
        return self[key] as? [String:Any] ?? [:]
    }
    func boolVal(for key:String)->Bool{
        return self[key] as? Bool ?? false
    }
    func doubleValue(for key:String)->Double{
        return self[key] as? Double ?? 0.0
    }
    func nsArray(for key:String)->NSArray{
        return self[key] as? NSArray ?? []
    }
    func arrayValue(for key:String)->Array<Dictionary>{
        return self[key] as? [Dictionary] ?? []
    }
}


extension String {
    var bool:Bool{
        let number = Int(self)
        return (number == 0 || number == nil || number != 1) ? false : true
    }
}


struct ResponseKey {
    static var renewalInfo: String {"pending_renewal_info"}
    static var autoRenewPid: String {"auto_renew_product_id"}
    static var statusCode: String {"status"}
    static var latestReceipt: String {"latest_receipt_info"}
    static var productId: String {"product_id"}
    static var expireDateMs: String {"expires_date_ms"}
    static var expireDate: String {"expires_date"}
    static var originalPurchaseDate: String {"original_purchase_date"}
    static var originalTransactionId: String {"original_transaction_id"}
    static var autoRenewState: String {"auto_renew_status"}
    static var expireIntent: String {"expiration_intent"}
    static var onBillingRetry: String {"is_in_billing_retry_period"}
}

struct RequestKey {
    static var recipt: String {"receipt-data"}
    static var excludeOldTransaction: String {"exclude-old-transactions"}
}
