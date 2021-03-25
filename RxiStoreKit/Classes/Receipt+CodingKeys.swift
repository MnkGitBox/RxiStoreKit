//
//  Receipt+CodingKeys.swift
//  RxiStoreKit
//
//  Created by azbowMNk on 2021-03-25.
//

import Foundation

extension PendingRenewalInfo {
    enum CodingKeys: String,
                     CodingKey {
        case autoRenewProductId = "auto_renew_product_id"
        case autoRenewStatus = "auto_renew_status"
        case expirationIntent = "expiration_intent"
        case gracePeriodExpiresDate = "grace_period_expires_date"
        case gracePeriodExpiresDateMS = "grace_period_expires_date_ms"
        case gracePeriodExpiresDatePST = "grace_period_expires_date_pst"
        case isInBillingRetryPeriod = "is_in_billing_retry_period"
        case offerCodeRefName = "offer_code_ref_name"
        case priceConsentStatus = "price_consent_status"
        
        case productId = "product_id"
        case promotionalOfferId = "promotional_offer_id"
        
        case originalTransactionId = "original_transaction_id"
    }
}


extension LatestReciptInfo {
    enum CodingKeys: String,
                     CodingKey {
        case cancellationDate = "cancellation_date"
        case cancellationDateMS = "cancellation_date_ms"
        case cancellationDatePST = "cancellation_date_pst"
        case cancellationReason = "cancellation_reason"
        
        case expiresDate = "expires_date"
        case expiresDateMS = "expires_date_ms"
        case expiresDatePST = "expires_date_pst"
        
        case isInIntroOfferPeriod = "is_in_intro_offer_period"
        case isTrialPeriod = "is_trial_period"
        
        case originalPurchaseDate = "original_purchase_date"
        case originalPurchaseDateMS = "original_purchase_date_ms"
        case originalPurchaseDatePST = "original_purchase_date_pst"
        case originalTransactionId = "original_transaction_id"
        
        case purchaseDate = "purchase_date"
        case purchaseDateMS = "purchase_date_ms"
        case purchaseDatePST = "purchase_date_pst"
        
        case productId = "product_id"
        case promotionalOfferId = "promotional_offer_id"
        
        case quantity
        
        case webOrderLineItemId = "web_order_line_item_id"
        
        case transactionId = "transaction_id"
    }
}


extension ReceiptInApp {
    enum CodingKeys: String,
                     CodingKey {
        case cancellationDate = "cancellation_date"
        case cancellationDateMS = "cancellation_date_ms"
        case cancellationDatePST = "cancellation_date_pst"
        case cancellationReason = "cancellation_reason"
        
        case expiresDate = "expires_date"
        case expiresDateMS = "expires_date_ms"
        case expiresDatePST = "expires_date_pst"
        
        case inAppOwnershipType = "in_app_ownership_type"
        case isInIntroOfferPeriod = "is_in_intro_offer_period"
        case isTrialPeriod = "is_trial_period"
        case isUpgraded = "is_upgraded"
        case offerCodeRefName = "offer_code_ref_name"
        
        case originalPurchaseDate = "original_purchase_date"
        case originalPurchaseDateMS = "original_purchase_date_ms"
        case originalPurchaseDatePST = "original_purchase_date_pst"
        case originalTransactionId = "original_transaction_id"
        
        case purchaseDate = "purchase_date"
        case purchaseDateMS = "purchase_date_ms"
        case purchaseDatePST = "purchase_date_pst"
        
        case productId = "product_id"
        case promotionalOfferId = "promotional_offer_id"
        
        case quantity
        
        case subscriptionGroupIdentifier = "subscription_group_identifier"
        case webOrderLineItemId = "web_order_line_item_id"
        
        case transactionId = "transaction_id"
    }
}


extension ReceiptInfo {
    enum CodingKeys: String,
                                 CodingKey {
        case adamId = "adam_id"
        case appItemId = "app_item_id"
        case applicationVersion = "application_version"
        case bundleId = "bundle_id"
        case downloadId = "download_id"
        case expirationDate = "expiration_date"
        case expirationDateMS = "expiration_date_ms"
        case expirationDatePST = "expiration_date_pst"
        case inApp = "in_app"
        
        case originalApplicationVersion = "original_application_version"
        
        case originalPurchaseDate = "original_purchase_date"
        case originalPurchaseDateMS = "original_purchase_date_ms"
        case originalPurchaseDatePST = "original_purchase_date_pst"
        
        case preorderDate = "preorder_date"
        case preorderDateMS = "preorder_date_ms"
        case preorderDatePST = "preorder_date_pst"
        
        case receiptCreationDate = "receipt_creation_date"
        case receiptCreationDateMS = "receipt_creation_date_ms"
        case receiptCreationDatePST = "receipt_creation_date_pst"
        
        case receiptType = "receipt_type"
        
        case requestDate = "request_date"
        case requestDateMS = "request_date_ms"
        case requestDatePST = "request_date_pst"
        
        case versionExternalIdentifier = "version_external_identifier"
    }
}


//Coding Key values
extension Receipt {
    enum CodingKeys: String,
                     CodingKey {
        case environment, receipt, status
        case isRetryable = "is-retryable"
        case latestReceipt = "latest_receipt"
        case latestReceiptInfo = "latest_receipt_info"
        case pendingRenewalInfo = "pending_renewal_info"
    }
}
