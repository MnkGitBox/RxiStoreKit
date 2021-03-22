//
//  SKProductsRequestDelegateProxy.swift
//  RxiStoreKit
//
//  Created by azbowMNk on 2021-03-18.
//

import Foundation
import RxSwift
import RxCocoa
import StoreKit

extension SKProductsRequest: HasDelegate {
    public typealias Delegate = SKProductsRequestDelegate
}

public class SKProductsRequestDelegateProxy: DelegateProxy<SKProductsRequest, SKProductsRequestDelegate>,
                                             DelegateProxyType,
                                             SKProductsRequestDelegate {
    
    public init(parentObject: SKProductsRequest) {
        super.init(parentObject: parentObject, delegateProxy: SKProductsRequestDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { SKProductsRequestDelegateProxy(parentObject: $0) }
    }
    
    public static func currentDelegate(for object: SKProductsRequest) -> SKProductsRequestDelegate? {
        return object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: SKProductsRequestDelegate?, to object: SKProductsRequest) {
        object.delegate = delegate
    }
    
//MARK: - Observable implimentation for delegate
    //    Implimentation of  product response observing
    let skProductResponseSubject = PublishSubject<SKProductsResponse>()
    
    //    Catch result products
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        skProductResponseSubject.onNext(response)
    }
    
    //    Catch Product request errors
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        skProductResponseSubject.onError(error)
    }
    
    deinit {
        skProductResponseSubject.onCompleted()
    }
}













