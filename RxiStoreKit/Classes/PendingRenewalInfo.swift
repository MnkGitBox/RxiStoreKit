//
//  PendingRenewalInfo.swift
//  RxiStoreKit
//
//  Created by azbowMNk on 2021-03-25.
//

import Foundation

public struct PendingRenewalInfo: Decodable {
    //    The value for this key corresponds to the productIdentifier property of the product that the customer’s subscription renews.
    var autoRenewProductId: String
    /*
     The current renewal status for the auto-renewable subscription.
     See [auto_renew_status](https://developer.apple.com/documentation/appstorereceipts/auto_renew_status) for more information.
     */
    var autoRenewStatus: AutoRenewStatus
    
    /*
     The reason a subscription expired.
     This field is only present for a receipt that contains an expired auto-renewable subscription.
     See More Details [expiration_intent](https://developer.apple.com/documentation/appstorereceipts/expiration_intent)
     */
    var expirationIntent: IAPExpireIntent!
    
    //    The time at which the grace period for subscription renewals expires, in a date-time format similar to the ISO 8601.
    var gracePeriodExpiresDate: String!
    
    /*
     The time at which the grace period for subscription renewals expires, in UNIX epoch time format, in milliseconds.
     This key is only present for apps that have Billing Grace Period enabled and when the user experiences a billing error at the time of renewal.
     Use this time format for processing dates.
     */
    var gracePeriodExpiresDateMS: String!
    
    //    The time at which the grace period for subscription renewals expires, in the Pacific Time zone.
    var gracePeriodExpiresDatePST: String!
    
    /*
     A flag that indicates Apple is attempting to renew an expired subscription automatically.
     This field is only present if an auto-renewable subscription is in the billing retry state.
     See [is_in_billing_retry_period](https://developer.apple.com/documentation/appstorereceipts/is_in_billing_retry_period) for more information.
     */
    var isInBillingRetryPeriod: BoolType!
    
    /*
     The reference name of a subscription offer that you configured in App Store Connect.
     This field is present when a customer redeemed a subscription offer code.
     For more information, see [offer_code_ref_name](https://developer.apple.com/documentation/appstorereceipts/offer_code_ref_name).
     */
    var offerCodeRefName: String!
    
    //    The transaction identifier of the original purchase.
    var originalTransactionId: String
    
    /*
     The price consent status for a subscription price increase.
     This field is only present if the customer was notified of the price increase.
     The default value is "normal" and changes to "increased" if the customer consents.
     Possible values: normal, increased
     */
    var priceConsentStatus: IAPPriceConsentStatus!
    
    /*
     The unique identifier of the product purchased.
     You provide this value when creating the product in App Store Connect, and it corresponds to the productIdentifier property of the SKPayment object stored in the transaction's payment property.
     */
    var productId: String
    
    /*
     The identifier of the promotional offer for an auto-renewable subscription that the user redeemed.
     You provide this value in the Promotional Offer Identifier field when you create the promotional offer in App Store Connect.
     See More [promotional_offer_id](https://developer.apple.com/documentation/appstorereceipts/promotional_offer_id)
     */
    var promotionalOfferId: String!
}
