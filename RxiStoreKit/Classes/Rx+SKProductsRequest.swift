//
//  Rx+SKProductsRequest.swift
//  RxiStoreKit
//
//  Created by azbowMNk on 2021-03-22.
//

import Foundation
import RxSwift
import StoreKit
import RxCocoa

//MARK: - Reactive Extension where all rx functions live
extension Reactive where Base: SKProductsRequest {
    ///    Delegate for innovek observable
    public var delegate: DelegateProxy<SKProductsRequest, SKProductsRequestDelegate> {
        SKProductsRequestDelegateProxy.proxy(for: base)
    }
    
    ///    SKProduct request  rx version
    public var request: Observable<SKProductsResponse> {
        return SKProductsRequestDelegateProxy.proxy(for: base).skProductResponseSubject
    }
}
