//
//  RxPaymentTransactionWrapperType.swift
//  RxiStoreKit
//
//  Created by azbowMNk on 2021-03-22.
//

import Foundation
import RxSwift
import StoreKit

protocol RxPaymentTransactionWrapperType {
    
    ///    Payment Queue Observer
    var delegateWrapper: RxPaymentTransactionWrapper.WrappedObserver { get set }
    
    ///    Transaction updates observable result
    var updatedTransactions: Observable<[SKPaymentTransaction]> { get }
    
}
