//
//  ReceiptVerifier+Rx+Extension.swift
//  RxiStoreKit
//
//  Created by azbowMNk on 2021-03-25.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType where Element == Data {
//    Decode Receipt binary data into decodable object
    var decodeRecipt: Observable<RecieptObject> {
        map {
            do {
                let decoder = JSONDecoder()
                let decodedObject = try decoder.decode(RecieptObject.self, from: $0)
                return decodedObject
                
            } catch let err {
                throw err
            }
        }
    }
}

