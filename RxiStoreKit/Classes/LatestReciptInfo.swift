//
//  LatestReciptInfo.swift
//  RxiStoreKit
//
//  Created by azbowMNk on 2021-03-25.
//

import Foundation

public struct LatestReciptInfo: Decodable {
    //    The time Apple customer support canceled a transaction, in a date-time format similar to the ISO 8601.
    //    This field is only present for refunded transactions.
    var cancellationDate: String!
    
    /*
     The time Apple customer support canceled a transaction, or the time an auto-renewable subscription plan was upgraded, in UNIX epoch time format, in milliseconds.
     This field is only present for refunded transactions. Use this time format for processing dates.
     
     See cancellation_date_ms for more information:
     [cancellation_date_ms](https://developer.apple.com/documentation/appstorereceipts/cancellation_date_ms)
     */
    var cancellationDateMS: String!
    
    //    The time Apple customer support canceled a transaction, in the Pacific Time zone.
    //    This field is only present for refunded transactions.
    var cancellationDatePST: String!
    
    /*
     The reason for a refunded transaction.
     -
     When a customer cancels a transaction, the App Store gives them a refund and provides a value for this key.
     A value of “appIssue” indicates that the customer canceled their transaction due to an actual or perceived issue within your app.
     A value of “none” indicates that the transaction was canceled for another reason; for example, if the customer made the purchase accidentally.
     */
    var cancellationReason: IAPCancellationReason!
    
    //    The time a subscription expires or when it will renew, in a date-time format similar to the ISO 8601.
    var expiresDate: String!
    
    /*
     The time the receipt expires for apps purchased through the Volume Purchase Program, in UNIX epoch time format, in milliseconds.
     If this key is not present for apps purchased through the Volume Purchase Program, the receipt does not expire.
     Use this time format for processing dates.
     */
    /// The time the receipt expires for apps purchased through the Volume Purchase Program, in UNIX epoch time format, in milliseconds.
    var expiresDateMS: String!
    
    //    The time a subscription expires or when it will renew, in the Pacific Time zone.
    var expiresDatePST: String!
    
    /*
     An indicator of whether an auto-renewable subscription is in the introductory price period.
     See [is_in_intro_offer_period](https://developer.apple.com/documentation/appstorereceipts/is_in_intro_offer_period) for more information.
     */
    var isInIntroOfferPeriod: BoolType!
    
    /*
     An indicator of whether a subscription is in the free trial period.
     See [is_trial_period](https://developer.apple.com/documentation/appstorereceipts/is_trial_period) for more information.
     */
    var isTrialPeriod: BoolType!
    
    //    The time of the original app purchase, in a date-time format similar to ISO 8601.
    var originalPurchaseDate: String!
    
    /*
     The time of the original app purchase, in UNIX epoch time format, in milliseconds.
     Use this time format for processing dates.
     For an auto-renewable subscription, this value indicates the date of the subscription’s initial purchase.
     The original purchase date applies to all product types and remains the same in all transactions for the same product ID.
     This value corresponds to the original transaction’s transactionDate property in StoreKit.
     */
    var originalPurchaseDateMS: String!
    
    //    The time of the original app purchase, in the Pacific Time zone.
    var originalPurchaseDatePST: String!
    
    /*
     The transaction identifier of the original purchase.
     See [original_transaction_id](https://developer.apple.com/documentation/appstorereceipts/original_transaction_id) for more information.
     */
    var originalTransactionId: String
    
    /*
     The unique identifier of the product purchased.
     You provide this value when creating the product in App Store Connect, and it corresponds to the productIdentifier property of the SKPayment object stored in the transaction’s payment property.
     */
    var productId: String
    
    /*
     The identifier of the subscription offer redeemed by the user.
     See [promotional_offer_id](https://developer.apple.com/documentation/appstorereceipts/promotional_offer_id) for more information.
     */
    var promotionalOfferId: String!
    
    /*
     The time the App Store charged the user’s account for a purchased or restored product, or the time the App Store charged the user’s account for a subscription purchase or renewal after a lapse, in a date-time format similar to ISO 8601.
     */
    var purchaseDate: String!
    
    /*
     For consumable, non-consumable, and non-renewing subscription products, the time the App Store charged the user’s account for a purchased or restored product, in the UNIX epoch time format, in milliseconds.
     For auto-renewable subscriptions, the time the App Store charged the user’s account for a subscription purchase or renewal after a lapse, in the UNIX epoch time format, in milliseconds.
     Use this time format for processing dates.
     */
    var purchaseDateMS: String!
    
    /*
     The time the App Store charged the user’s account for a purchased or restored product, or the time the App Store charged the user’s account for a subscription purchase or renewal after a lapse, in the Pacific Time zone.
     */
    var purchaseDatePST: String!
    
    /*
     The number of consumable products purchased.
     This value corresponds to the quantity property of the SKPayment object stored in the transaction’s payment property.
     The value is usually “1” unless modified with a mutable payment. The maximum value is 10.
     */
    var quantity: String
    
    /*
     A unique identifier for a transaction such as a purchase, restore, or renewal.
     See [transaction_id](https://developer.apple.com/documentation/appstorereceipts/transaction_id) for more information.
     */
    var transactionId: String
    
    /*
     A unique identifier for purchase events across devices, including subscription-renewal events.
     This value is the primary key for identifying subscription purchases.
     */
    var webOrderLineItemId: String!
}
