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
    func decodeRecipt<T: Decodable>() -> Observable<T> {
        map {
            do {
                let decoder = JSONDecoder()
                let decodedObject = try decoder.decode(T.self, from: $0)
                return decodedObject
                
            } catch let err {
                throw err
            }
        }
    }
}

