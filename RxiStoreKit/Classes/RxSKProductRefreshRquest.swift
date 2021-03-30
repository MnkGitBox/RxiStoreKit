//
//  RxSKProductRefreshRquest.swift
//  RxiStoreKit
//
//  Created by azbowMNk on 2021-03-30.
//

import Foundation
import RxSwift
import RxCocoa
import StoreKit

extension Reactive where Base: SKReceiptRefreshRequest {
    public var delegate: DelegateProxy<SKReceiptRefreshRequest, SKRequestDelegate> {
        SKReceiptRefreshRequestDelegateProxy.proxy(for: base)
    }
    
    ///    Receipt re-fresh request
    public var requestDidFinished: ControlEvent<Void> {
        let sourceFinshed = delegate.methodInvoked(#selector(SKRequestDelegate.requestDidFinish(_:))).map{_ in}

        let sourceWithError = delegate.methodInvoked(#selector(SKRequestDelegate.request(_:didFailWithError:)))
            .map { params in
                throw params[1] as! Error
            }
        
        let source = Observable.of(sourceFinshed, sourceWithError)
            .merge()
        
        return ControlEvent(events: source)
    }
}
