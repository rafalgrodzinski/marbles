//
//  TipJarViewController.swift
//  Marbles
//
//  Created by Rafal Grodzinski on 25/09/2016.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import UIKit
import StoreKit
import Crashlytics


class TipJarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var waitIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var cannotPayLabel: UILabel!

    private var products: [SKProduct]?


    // MARK: - Initialization
    override func viewDidLoad()
    {
        // Enable auto-sizing cells
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 72.0

        // Setup for wait
        self.tableView.isHidden = true
        self.waitIndicator.startAnimating()
        self.cannotPayLabel.isHidden = true

        PurchaseManager.sharedInstance.fetchProducts() { [weak self] (products: [SKProduct]) in
            self?.products = products
            self?.waitIndicator.stopAnimating()

            if products.count > 0 {
                self?.tableView.isHidden = false
                self?.tableView.reloadData()
            } else {
                self?.cannotPayLabel.isHidden = false
            }
        }
    }


    override func viewDidAppear(_ animated: Bool)
    {
        Answers.logCustomEvent(withName: "Entered View", customAttributes: ["Name" : "TipJar"])
    }


    // MARK: - Actions
    @IBAction private func menuButtonPressed(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }


    @IBAction private func tipButtonPressed(sender: UIButton)
    {
        if let product = self.products?[sender.tag] {
            self.waitIndicator.startAnimating()
            self.view.isUserInteractionEnabled = false
            self.tableView.isHidden = true
            PurchaseManager.sharedInstance.buyProduct(product) { (successful: Bool) in
                if successful {
                    #if !DEBUG
                        Answers.logPurchase(withPrice: product.price,
                                            currency: product.priceLocale.identifier,
                                            success: successful as NSNumber?,
                                            itemName: product.localizedTitle,
                                            itemType: "Tip",
                                            itemId: product.productIdentifier,
                                            customAttributes: nil)
                    #endif

                    self.cannotPayLabel.text = "Thanks for the tip!"
                    self.cannotPayLabel.isHidden = false
                } else {
                    let alert = UIAlertController(title: "Issue with transaction", message: "Could not complete", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.tableView.isHidden = false
                }

                self.waitIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
            }
        }
    }


    // MARK: - UITableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let rowsCount = self.products != nil ? self.products!.count : 0

        return rowsCount
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let product = self.products?[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "TipCell", for: indexPath)
        cell.backgroundColor = Color.marblesGreen.withAlphaComponent(0.4)
        cell.layer.cornerRadius = 5.0
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 1.0

        let titleLabel = cell.viewWithTag(1)
        if let title = titleLabel as? UILabel {
            title.font = UIFont(name: "BunakenUnderwater", size: 24.0)
            title.text = product?.localizedTitle
        }

        let priceLabel = cell.viewWithTag(2)
        if let price = priceLabel as? UILabel {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product?.priceLocale
            price.font = UIFont(name: "BunakenUnderwater", size: 20.0)
            price.text = formatter.string(from: product!.price)
        }

        let tipButton = cell.viewWithTag(3)
        if let tip = tipButton as? UIButton {
            tip.titleLabel?.font = UIFont(name: "BunakenUnderwater", size: 28.0)
            tip.tag = indexPath.row
        }

        return cell
    }
}
