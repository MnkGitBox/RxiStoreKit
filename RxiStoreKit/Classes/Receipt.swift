//
//  Receipt.swift
//  RxiStoreKit
//
//  Created by azbowMNk on 2021-03-25.
//

import Foundation

public struct Receipt: Decodable {
    ///    The environment for which the receipt was generated.
    public private(set)var environment: IAPEnvironment
    
    /*
     An indicator that an error occurred during the request.
     A value of 1 indicates a temporary issue; retry validation for this receipt at a later time.
     A value of 0 indicates an unresolvable issue; do not retry validation for this receipt.
     nil value occur when no retry required.
     Only applicable to status codes 21100-21199.
     */
    ///    An indicator that an error occurred during the request.
    public private(set)var isRetryable: Bool!
    
    /*
     The latest Base64 encoded app receipt.
     Only returned for receipts that contain auto-renewable subscriptions.
     */
    ///    The latest Base64 encoded app receipt.
    public private(set)var latestReceipt: Data!
    
    /*
     An array that contains all in-app purchase transactions.
     This excludes transactions for consumable products that have been marked as finished by your app.
     Only returned for receipts that contain auto-renewable subscriptions.
     More Info [responseBody.Latest_receipt_info](https://developer.apple.com/documentation/appstorereceipts/responsebody/latest_receipt_info)
     */
    ///    An array that contains all in-app purchase transactions.
    public private(set)var latestReceiptInfo: [LatestReciptInfo]!
    
    /*
     In the JSON file, an array where each element contains the pending renewal information for each auto-renewable subscription identified by the product_id.
     Only returned for app receipts that contain auto-renewable subscriptions.
     More Info [responseBody.Pending_renewal_info](https://developer.apple.com/documentation/appstorereceipts/responsebody/pending_renewal_info)
     */
    ///    In the JSON file, an array where each element contains the pending renewal information for each auto-renewable subscription identified by the product_id.
    public private(set)var pendingRenewalInfo: [PendingRenewalInfo]!
    
    /*
     The decoded version of the encoded receipt data sent with the request to the App Store.
     More Info: [responseBody.Receipt](https://developer.apple.com/documentation/appstorereceipts/responsebody/receipt)
     */
    /// A JSON representation of the receipt that was sent for verification.
    public private(set)var receipt: ReceiptInfo!
    
    /*
     Either 0 if the receipt is valid, or a status code if there is an error.
     The status code reflects the status of the app receipt as a whole.
     See status for possible status codes and descriptions.[status](https://developer.apple.com/documentation/appstorereceipts/status)
     */
    public private(set)var status: IAPReceiptStatus
}
