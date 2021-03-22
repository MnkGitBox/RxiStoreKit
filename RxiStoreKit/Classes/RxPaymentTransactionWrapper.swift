//
//  RxPaymentTransactionWrapper.swift
//  RxiStoreKit
//
//  Created by azbowMNk on 2021-03-22.
//

import Foundation
import RxSwift
import StoreKit

class RxPaymentTransactionWrapper: RxPaymentTransactionWrapperType {
    
    static let shared: RxPaymentTransactionWrapperType = RxPaymentTransactionWrapper()
    
    var delegateWrapper = WrappedObserver()
    
    private init() {}
}


//MARK: - RETURN TO PULIC APIs
extension RxPaymentTransactionWrapper {
    //    Updated transaction obseravble
    var updatedTransactions: Observable<[SKPaymentTransaction]> {
        delegateWrapper.updatedTransactions_subject
    }
}
