//
//  Rx+SKPaymentTransaction+Helper.swift
//  RxiStoreKit
//
//  Created by Malith Kamburapola on 2021-03-23.
//

import Foundation
import RxSwift
import StoreKit

public extension ObservableType where Element: SKPaymentTransaction {
    var ignoreIntermediateStatus: Observable<Self.Element> {
        return filter {
            switch $0.transactionState {
            case .purchased, .failed, .restored:
                return true
                
            default:
                return false
            }
        }
    }
    
    var filterFailedError: Observable<Self.Element> {
        map {
            guard $0.transactionState == .failed else { return $0 }
            throw $0.error!
        }
    }
    
    func filter(by payment: SKPayment) -> Observable<Self.Element> {
        filter{ $0.payment.productIdentifier == payment.productIdentifier }
    }
}
