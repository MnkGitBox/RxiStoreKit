//
//  Receipt+Helper+Models.swift
//  RxiStoreKit
//
//  Created by azbowMNk on 2021-03-25.
//

import Foundation

/*
 The environment for which the receipt was generated.
 Possible values: Sandbox, Production
 */
public enum IAPEnvironment: String,
                            Codable {
    case sandbox = "Sandbox"
    case production = "Production"
}


/*
 The reason for a refunded transaction.
 
 When a customer cancels a transaction, the App Store gives them a refund and provides a value for this key.
 A value of “appIssue” indicates that the customer canceled their transaction due to an actual or perceived issue within your app.
 A value of “none” indicates that the transaction was canceled for another reason; for example, if the customer made the purchase accidentally.
 */
public enum IAPCancellationReason: String,
                                   Decodable {
    case appIssue = "1"
    case none = "0"
}


/*
 A value that indicates whether the user is the purchaser of the product, or is a family member with access to the product through Family Sharing.
 See [in_app_ownership_type](https://developer.apple.com/documentation/appstorereceipts/in_app_ownership_type) for more information.
 */
public enum IAPOwnershipType: String,
                              Codable {
    case familyShared = "FAMILY_SHARED"
    case purchased = "PURCHASED"
}



public enum BoolType: Decodable {
    case `true`
    case `false`
    
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        
        switch value {
        case let val where (val == "true" || val == "1"):
            self = .true
            
        default:
            self = .false
        }
    }
}


/*
 The current renewal status for the auto-renewable subscription.
 See [auto_renew_status](https://developer.apple.com/documentation/appstorereceipts/auto_renew_status) for more information.
 */
public enum AutoRenewStatus: String,
                             Decodable {
    case active = "1"
    case offed = "0"
}


/*
 The price consent status for a subscription price increase.
 This field is only present if the customer was notified of the price increase.
 The default value is "normal" and changes to "increased" if the customer consents.
 Possible values: normal, increased
 */
public enum IAPPriceConsentStatus: String,
                                   Decodable {
    case increased = "1"
    case normal = "0"
}


/*
 The reason a subscription expired.
 This field is only present for a receipt that contains an expired auto-renewable subscription.
 See More Details [expiration_intent](https://developer.apple.com/documentation/appstorereceipts/expiration_intent)
 */
public enum IAPExpireIntent: String,
                             Decodable {
    //    The customer voluntarily canceled their subscription.
    case canceled = "1"
    
    //    Billing error; for example, the customer's payment information was no longer valid.
    case billingError = "2"
    
    //    The customer did not agree to a recent price increase.
    case disAgreedToPriceIncreace = "3"
    
    //    The product was not available for purchase at the time of renewal.
    case productNotAvailable = "4"
    
    //    Unknown error.
    case unowned = "5"
}



/*
 The type of receipt generated.
 The value corresponds to the environment in which the app or VPP purchase was made.
 */
public enum IAPReceiptType: String,
                            Decodable {
    case production = "Production"
    case productionVVP = "ProductionVPP"
    case productionSandBox = "ProductionSandbox"
    case productionVVPSandBox = "ProductionVPPSandbox"
}
