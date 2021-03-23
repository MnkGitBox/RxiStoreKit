//
//  Rx+SKPaymentQueue.swift
//  RxiStoreKit
//
//  Created by azbowMNk on 2021-03-22.
//

import Foundation
import RxSwift
import StoreKit

extension Reactive where Base: SKPaymentQueue {
    
    var paymentQueueObserver: RxPaymentTransactionWrapperType { RxPaymentTransactionWrapper.shared }
    
    ///    Add payment to SkPayment Queue and return observable result
    public func add( _ payment: SKPayment) -> Observable<SKPaymentTransaction> {
        //        Create observable to catch payment transactions
        let observable = Observable<SKPaymentTransaction>.create { observer in
            let disposable = paymentQueueObserver.updatedTransactions
                .flatMapLatest{Observable.from($0)}
                .filter(by: payment)
                .ignoreIntermediateStatus
                .do(afterNext: {
                    SKPaymentQueue.default().finishTransaction($0)
    
                })
                .filterFailedError
                .bind(to: observer)
            
            return Disposables.create {
                self.base.remove(paymentQueueObserver.delegateWrapper)
                disposable.dispose()
            }
        }
        
        //        Add Payment and payment observer to current Queue
        self.base.add(paymentQueueObserver.delegateWrapper)
        self.base.add(payment)
        
        return observable
    }
    
}



