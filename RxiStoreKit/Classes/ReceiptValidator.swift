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
}

/*
 Extension to validate recipt by given VerifyRequestSetting s.
 */
public extension ObservableType where Element == VerifyRequestSetting {
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

//extension ObservableType where Element == Receipt {
//    func verifyInlude(_ productId: String) -> Observable<(receipt: Receipt, valid: Bool)> {
//        map { receipt in
//            guard receipt.status != .valid else { return (receipt, false) }
//            
//            
//        }
//    }
//}


















