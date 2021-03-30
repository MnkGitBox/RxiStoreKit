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
    ///    The subscription will renew at the end of the current subscription period.
    case active = "1"
    ///    The customer has turned off automatic renewal for the subscription.
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



/*
 Either 0 if the receipt is valid, or a status code if there is an error.
 The status code reflects the status of the app receipt as a whole.
 See [status](https://developer.apple.com/documentation/appstorereceipts/status) for possible status codes and descriptions.
 */
public enum IAPReceiptStatus: Int,
                              Decodable {
    ///   The request to the App Store was not made using the HTTP POST request method
    case invalidateHTTPRequest = 21000
    
    ///    This status code is no longer sent by the App Store
    case invalidIAPStatusCode = 21001
    
    ///    The data in the receipt-data property was malformed or the service experienced a temporary issue. Try again.
    case invalidReceiptData = 21002
    
    ///    The receipt could not be authenticated.
    case authenticationFaild = 21003
    
    ///    The shared secret you provided does not match the shared secret on file for your account.
    case invalidSharedSecret = 21004
    
    ///    The receipt server was temporarily unable to provide the receipt. Try again.
    case serverTemporarilyUnavailable = 21005
    
    /*
     This receipt is valid but the subscription has expired.
     When this status code is returned to your server, the receipt data is also decoded and returned as part of the response.
     Only returned for iOS 6-style transaction receipts for auto-renewable subscriptions.
     */
    ///    This receipt is valid but the subscription has expired.
    case subscriptionHasExpired = 21006
    
    ///    This receipt is from the test environment, but it was sent to the production environment for verification.
    case testToProduction = 21007
    
    ///    This receipt is from the production environment, but it was sent to the test environment for verification.
    case productionToTest = 21008
    
    ///    Internal data access error. Try again later.
    case failedToAccessInternalData = 21009
    
    ///    The user account cannot be found or has been deleted.
    case invalidUserAccount = 21010
    
    ///    No Errors. Valid Receipt
    case valid = 0
    
    /*
     Custom decoder to status.
     Status code 21100 - 21199 are varius kind of internal data access errors.
     So We have assign 'failedToAccessInternalData' as default status for any dis-provided codes.
     */
    public init(from decoder: Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(Int.self)
        self = IAPReceiptStatus.init(rawValue: rawValue) ?? .failedToAccessInternalData
    }
}


/*
 Settings for receipt verification request
 */
public struct VerifyRequestSetting {
    private var enviroment: IAPEnvironment {
        #if DEBUG
        return .sandbox
        #else
        return .production
        #endif
    }
    
    private var iapAppStoreUrl: URL {
        #if DEBUG
        return URL.init(string: Constants.iapSandBox)!
        #else
        return URL.init(string: Constants.iapProduction)!
        #endif
    }
    
    public var isProduction: Bool { enviroment == .production }
    
    //    Subscription product ids created in app in-app purchase section in AppStore Connect
    public var productIds: Set<String> = []
    
    /*
     verifyServerUrl
     -
     - URL of IAP Recipt verification end point created in your server
     - When URL doent provide, it calls to app store directly from the app. This behavior is not recomended by apple
     - [See this](https://developer.apple.com/documentation/storekit/in-app_purchase/validating_receipts_with_the_app_store)
     
     Warning
     -
     - Do not call the App Store server verifyReceipt endpoint from your app. You can't build a trusted connection between a user’s device and the App Store directly, because you don’t control either end of that connection, which makes it susceptible to a man-in-the-middle attack.
     */
    public var verifyServerUrl: URL!
    
    /*
     excludeOldTransaction: Bool => default false
     -
     Set this value to true for the response to include only the latest renewal transaction for any subscriptions.
     Use this field only for app receipts that contain auto-renewable subscriptions.
     */
    public var excludeOldTransaction = false
    
    /*
     Server Request body parameters.
     */
    public var requestBody: [String : Any]!
    
    //    Public Initialization with required data
    init() {
        self.verifyServerUrl = iapAppStoreUrl
    }
    
}

/*
 Default receipt validation responce object
 This object can send if there is no values required to catch from response
 */
public struct ReceiptDefaultResponse: Decodable {
    public var data: Receipt
}


/*
 Errors happen on verification process
 Manage by the Local Library
 */
public enum VerifyError: Error {
    case noReceipet
    case noInternet
    case emptyRequestBody
}

/*
 Basic Subcription status
 */
public enum SubcriptionStatus {
    case active, expired, notDetermine
}


/*
 Chordo - Subscription State
 
 Subcribe
 
 Active(Auto-Renew on)                  5
 Active(Auto-Renew off)                 4
 Non-Renewing Subscription              3
 Off-Paltform                           2
 Expired(in Grace Period)               1
 
 Un-Subcribed
 
 Purchase Issue                         0
 Expired(In Billing Retry)             -1
 Expired From Billing                  -2
 Faild To Accept Price Increase        -3
 Product Not Available                 -4
 Expired Volantarilly                  -5
 Upgraded                              -6
 Refund from Issue                     -7
 Other Refund                          -8
 
 Un-Identified                         -500.0
 
 
 
 Sub-Status
 
 Standard Subscription                 .0
 Free Trial                            .1
 Introductory Offer                    .2
 Subscription Offer                    .3
 */


enum SubscriptionStateCohort: String {
    case active_auto_renew_on = "5"
    case active_auto_renew_off = "4"
    case non_renew_subscription = "3"
    case off_platform = "2"
    case expired_in_grace_peropd = "1"
    
    case purchase_issue = "0"
    case expired_in_billing_re_try = "-1"
    case expired_from_billing = "-2"
    case faild_to_accept_price_increase = "-3"
    case product_not_available = "-4"
    case expired_volantarilly = "-5"
    case upgraded = "-6"
    case refund_from_issue = "-7"
    case other_refund = "-8"
    
    case expired = "-500"
    
    enum SubState: String {
        case standard_subscription = ".0"
        case free_trial = ".1"
        case introductory_offer = ".2"
        case subscription_offer = ".3"
    }
    
    func add(_ subState: SubState) -> String {
        self.rawValue + subState.rawValue
    }
}


extension TimeInterval {
    var removeMilliSeconds: TimeInterval {
        self / 1000
    }
}

