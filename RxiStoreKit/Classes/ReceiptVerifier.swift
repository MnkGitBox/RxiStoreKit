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
    
 /**
     excludeOldTransaction: Bool => default false
     -
     - Set this value to true for the response to include only the latest renewal transaction for any subscriptions.
     -  Use this field only for app receipts that contain auto-renewable subscriptions.
     
     productId: String
     -
     - Subscription Product id
     
     password: String
     -
     - Your app’s shared secret, which is a hexadecimal string.
     
     */
    public func verify(_ productId: String, excludeOldTransaction isExclude: Bool = false) -> Single<RecieptObject> {
        Single<RecieptObject>.create { [unowned self] observer in
            var urlDisposable: Disposable?
            
            do {
                guard let receiptURL = Bundle.main.appStoreReceiptURL else {
                    throw VerifyError.noReceipet
                }
                
                guard Reacherbility.isInternetAccessible else{
                    throw VerifyError.noInternet
                }
                
                let receiptData = try Data(contentsOf: receiptURL, options: .alwaysMapped)
                let base64 = receiptData.base64EncodedString(options: [])
                let jsonBody = try JSONSerialization.data(withJSONObject:
                    [ RequestKey.recipt : base64,
                      "password" : "3ec7a2592c344beca2ac97ce002e15a4",
                     RequestKey.excludeOldTransaction : isExclude ], options: [])
                
                var request = URLRequest(url: self.IapUrlString, cachePolicy: .reloadIgnoringCacheData)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                request.httpBody = jsonBody

                let sheduler = ConcurrentDispatchQueueScheduler.init(qos: .background)
                
                urlDisposable = URLSession.shared.rx.data(request: request).timeout(.seconds(30), scheduler: sheduler)
                    .decodeRecipt
//                    .flatMapLatest {
//                        ($0 as! ReceiptLog).varyfiedData(of: productId)
//                    }
                    .subscribe(onNext: {
                        observer(.success($0))
                        
                    }, onError: {
                        observer(.failure($0))
                        
                    })

            } catch let error {
                observer(.failure(error))
            }
            
            return Disposables.create {
                urlDisposable?.dispose()
            }
        }
    }
}

//extension ReceiptLog {
//    func varyfiedData(of productId: String) -> Observable<Reciept> {
//        guard let data =  (self[ResponseKey.renewalInfo] as? [[String:Any]])?.filter({$0.stringVal(for: ResponseKey.autoRenewPid) == productId}).first else {
//            return Observable.error(VerifyError.jsonSerialization)
//        }
//
//        let statusCode = data.intVal(for: ResponseKey.statusCode)
//
//        if statusCode == 0 {
//            let subcriptionPlayLoads = (self[ResponseKey.latestReceipt] as? [[String:Any]])?.filter({$0.stringVal(for: ResponseKey.productId) == productId}) ?? []
//            let finalPlayLoadExMs = subcriptionPlayLoads.map{$0.stringVal(for: ResponseKey.expireDateMs)}.max()
//            let latestPayload = subcriptionPlayLoads.filter({$0.stringVal(for: ResponseKey.expireDateMs) == finalPlayLoadExMs}).first
//            let playLoadEx = latestPayload?.stringVal(for: ResponseKey.expireDate)
//            let playLoadSubDate = latestPayload?.stringVal(for: ResponseKey.originalPurchaseDate)
//
//            return Observable.of(Reciept.init(renewalInfo: data, expireDate: playLoadEx, subcribedDate: playLoadSubDate))
//
//        } else {
//            return Observable.error(VerifyError.invalid(code: statusCode))
//
//        }
//    }
//}



struct RequestKey {
    static var recipt: String {"receipt-data"}
    static var excludeOldTransaction: String {"exclude-old-transactions"}
}


















