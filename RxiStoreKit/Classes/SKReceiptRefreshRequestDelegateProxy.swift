//
//  SKReceiptRefreshRequestDelegateProxy.swift
//  RxiStoreKit
//
//  Created by azbowMNk on 2021-03-30.
//

import Foundation
import StoreKit
import RxCocoa
import RxSwift

extension SKReceiptRefreshRequest: HasDelegate {
    public typealias Delegate = SKRequestDelegate
}

public class SKReceiptRefreshRequestDelegateProxy
    : DelegateProxy<SKReceiptRefreshRequest, SKRequestDelegate>
    , DelegateProxyType
    , SKRequestDelegate {
    
    public init(parentObject: SKReceiptRefreshRequest) {
        super.init(parentObject: parentObject, delegateProxy: SKReceiptRefreshRequestDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { SKReceiptRefreshRequestDelegateProxy(parentObject: $0) }
    }
    
    public static func currentDelegate(for object: SKReceiptRefreshRequest) -> SKRequestDelegate? {
        return object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: SKRequestDelegate?, to object: SKReceiptRefreshRequest) {
        object.delegate = delegate
    }
}

