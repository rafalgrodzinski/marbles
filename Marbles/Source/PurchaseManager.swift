//
//  PurchaseManager.swift
//  Marbles
//
//  Created by Rafal Grodzinski on 25/09/2016.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import Foundation
import StoreKit


class PurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver
{
    static let sharedInstance = PurchaseManager()

    private var productsRequest: SKProductsRequest?
    private let productIdentifiers: Set<String> = ["com.unalignedbyte.marbles.smalltip",
                                                   "com.unalignedbyte.marbles.mediumtip",
                                                   "com.unalignedbyte.marbles.largetip"]

    private var products: [SKProduct]?
    private var fetchProductsCallback: (([SKProduct]) -> Void)?
    private var buyProductCallback: ((Bool) -> Void)?


    private override init()
    {
        super.init()

        SKPaymentQueue.default().add(self)
    }


    func fetchProducts(_ completed: @escaping ([SKProduct]) -> Void)
    {
        self.productsRequest?.cancel()

        if !SKPaymentQueue.canMakePayments() {
            completed([])
            return
        }

        if let products = self.products {
            completed(products)
            return
        }

        self.fetchProductsCallback = completed

        self.productsRequest = SKProductsRequest(productIdentifiers: self.productIdentifiers)
        self.productsRequest?.delegate = self
        self.productsRequest?.start()
    }


    func buyProduct(_ product: SKProduct, completed: @escaping (Bool) -> Void)
    {
        self.buyProductCallback = completed

        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }


    // MARK: Products Request Delegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse)
    {
        self.products = response.products
        self.fetchProductsCallback?(response.products)
    }


    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                self.buyProductCallback?(true)
            case .failed:
                self.buyProductCallback?(false)
            default:
                break
            }
        }
    }
}
