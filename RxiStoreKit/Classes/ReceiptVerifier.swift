//
//  ReceiptVerifier.swift
//  RxiStoreKit
//
//  Created by azbowMNk on 2021-03-23.
//

import Foundation
import RxCocoa
import RxSwift

public class ReceiptVerifier {
    
    public static var shared: ReceiptVerifier = ReceiptVerifier()
    
    private init() {}
    
    /*
     Setting Object Include various kind of variables required for verification receipt
     Can use those default values or change public values with requirement.
     */
    public func verify<T: VerificationResponseType>(with setting: VerifyRequestSetting,
                                                    to responseMappingObject: T.Type) -> Single<T> {
        Single<T>.create { observer in
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
                                                              RequestKey.password : setting.password,
                                                              RequestKey.isProduction : setting.isProduction ], options: [])
                
                var request = URLRequest(url: setting.verifyServerUrl, cachePolicy: .reloadIgnoringCacheData)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                request.httpBody = jsonBody
                
                let sheduler = ConcurrentDispatchQueueScheduler.init(qos: .background)
                
                urlDisposable = URLSession.shared.rx.data(request: request).timeout(.seconds(30), scheduler: sheduler)
                    .decodeRecipt()
                    //                    .flatMapLatest {
                    //                        ($0 as! ReceiptLog).varyfiedData(of: productId)
                    //                    }
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






















