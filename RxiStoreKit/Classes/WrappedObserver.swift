//
//  WrappedObserver.swift
//  RxiStoreKit
//
//  Created by azbowMNk on 2021-03-22.
//

import Foundation
import StoreKit
import RxSwift

extension RxPaymentTransactionWrapper {
    class WrappedObserver: NSObject,
                           SKPaymentTransactionObserver {
        
        let updatedTransactions_subject = PublishSubject<[SKPaymentTransaction]>()
        fileprivate let removedTransactions_subject = PublishSubject<[SKPaymentTransaction]>()
    }
}

//MARK: - WRAPPER DELEGATE IMPLIMENATATION CONVERT TO OBSERVABLE
extension RxPaymentTransactionWrapper.WrappedObserver {
    //    Payment Queue updated transaction return delegate
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        updatedTransactions_subject.onNext(transactions)
    }
    
    //    Payment Queue Removed transaction return delegate
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        removedTransactions_subject.onNext(transactions)
    }
    
    // Pass when transactions are removed from the queue (via finishTransaction:).
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("RxiStoreKit ---------------------------------------> paymentQueueRestoreCompletedTransactionsFinished")
    }
    
    // Pass when an error is encountered while adding transactions from the user's purchase history back to the queue.
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("RxiStoreKit ---------------------------------------> restoreCompletedTransactionsFailedWithError")
    }
    
    // Sent when the download state has changed.
    func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        print("RxiStoreKit ---------------------------------------> updatedDownloads")
    }
    
    // Sent when a user initiates an IAP buy from the App Store
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        print("RxiStoreKit ---------------------------------------> shouldAddStorePayment")
        return true
    }
    
    func paymentQueueDidChangeStorefront(_ queue: SKPaymentQueue) {
        print("RxiStoreKit ---------------------------------------> paymentQueueDidChangeStorefront")
    }
    
    // Sent when entitlements for a user have changed and access to the specified IAPs has been revoked.
    func paymentQueue(_ queue: SKPaymentQueue, didRevokeEntitlementsForProductIdentifiers productIdentifiers: [String]) {
        print("RxiStoreKit ---------------------------------------> didRevokeEntitlementsForProductIdentifiers")
    }
}
