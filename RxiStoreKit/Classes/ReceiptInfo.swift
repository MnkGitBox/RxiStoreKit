//
//  IAPLocalReceipt.swift
//  RxiStoreKit
//
//  Created by azbowMNk on 2021-03-25.
//

import Foundation
public struct ReceiptInfo: Decodable {
    //    See app_item_id
    private(set)var adamId: Int
    
    /*
     Generated by App Store Connect and used by the App Store to uniquely identify the app purchased.
     Apps are assigned this identifier only in production.
     Treat this value as a 64-bit long integer.
     */
    private(set)var appItemId: Int64
    
    /*
     The app’s version number.
     The app's version number corresponds to the value of CFBundleVersion (in iOS) or CFBundleShortVersionString (in macOS) in the Info.plist.
     In production, this value is the current version of the app on the device based on the receipt_creation_date_ms.
     In the sandbox, the value is always "1.0".
     */
    /// The app’s version number.
    private(set)var applicationVersion: String
    
    /*
     The bundle identifier for the app to which the receipt belongs.
     You provide this string on App Store Connect. This corresponds to the value of CFBundleIdentifier in the Info.plist file of the app.
     */
    /// The bundle identifier for the app to which the receipt belongs.
    private(set)var bundleId: String
    
    /// A unique identifier for the app download transaction.
    private(set)var downloadId: Int!
    
    /// The time the receipt expires for apps purchased through the Volume Purchase Program, in a date-time format similar to the ISO 8601.
    private(set)var expirationDate: String!
    
    /*
     The time the receipt expires for apps purchased through the Volume Purchase Program, in UNIX epoch time format, in milliseconds.
     If this key is not present for apps purchased through the Volume Purchase Program, the receipt does not expire.
     Use this time format for processing dates.
     */
    /// The time the receipt expires for apps purchased through the Volume Purchase Program, in UNIX epoch time format, in milliseconds.
    private(set)var expirationDateMS: String!
    
    /// The time the receipt expires for apps purchased through the Volume Purchase Program, in the Pacific Time zone.
    private(set)var expirationDatePST: String!
    
    /*
     More info: [responseBody.Receipt.In_app](https://developer.apple.com/documentation/appstorereceipts/responsebody/receipt/in_app)
     */
    /// An array that contains the in-app purchase receipt fields for all in-app purchase transactions.
    public private(set)var inApp: [ReceiptInApp]
    
    /*
     The version of the app that the user originally purchased.
     This value does not change, and corresponds to the value of CFBundleVersion (in iOS) or CFBundleShortVersionString (in macOS) in the Info.plist file of the original purchase.
     In the sandbox environment, the value is always "1.0".
     */
    /// The version of the app that the user originally purchased.
    private(set)var originalApplicationVersion: String
    
    /// The time of the original app purchase, in a date-time format similar to ISO 8601.
    private(set)var originalPurchaseDate: String!
    
    /// The time of the original app purchase, in UNIX epoch time format, in milliseconds. Use this time format for processing dates.
    private(set)var originalPurchaseDateMS: String!
    
    /// The time of the original app purchase, in the Pacific Time zone.
    private(set)var originalPurchaseDatePST: String!
    
    /// The time the user ordered the app available for pre-order, in a date-time format similar to ISO 8601.
    private(set)var preorderDate: String!
    
    /*
     The time the user ordered the app available for pre-order, in UNIX epoch time format, in milliseconds.
     This field is only present if the user pre-orders the app.
     Use this time format for processing dates.
     */
    /// The time the user ordered the app available for pre-order, in UNIX epoch time format, in milliseconds.
    private(set)var preorderDateMS: String!
    
    /// The time the user ordered the app available for pre-order, in the Pacific Time zone.
    private(set)var preorderDatePST: String!
    
    /// The time the App Store generated the receipt, in a date-time format similar to ISO 8601.
    private(set)var receiptCreationDate: String
    
    /*
     The time the App Store generated the receipt, in UNIX epoch time format, in milliseconds.
     Use this time format for processing dates.
     This value does not change.
     */
    /// The time the App Store generated the receipt, in UNIX epoch time format, in milliseconds.
    private(set)var receiptCreationDateMS: String
    
    /// The time the App Store generated the receipt, in the Pacific Time zone.
    private(set)var receiptCreationDatePST: String
    
    /// The type of receipt generated. The value corresponds to the environment in which the app or VPP purchase was made.
    public private(set)var receiptType: IAPReceiptType
    
    /// The time the request to the verifyReceipt endpoint was processed and the response was generated, in a date-time format similar to ISO 8601.
    private(set)var requestDate: String!
    
    /*
     The time the request to the verifyReceipt endpoint was processed and the response was generated, in UNIX epoch time format, in milliseconds.
     Use this time format for processing dates.
     */
    /// The time the request to the verifyReceipt endpoint was processed and the response was generated, in UNIX epoch time format, in milliseconds.
    private(set)var requestDateMS: String!
    
    /// The time the request to the verifyReceipt endpoint was processed and the response was generated, in the Pacific Time zone
    private(set)var requestDatePST: String!
    
    /// An arbitrary number that identifies a revision of your app. In the sandbox, this key's value is “0”
    private(set)var versionExternalIdentifier: Int
}
