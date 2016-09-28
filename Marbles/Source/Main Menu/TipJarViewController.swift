//
//  TipJarViewController.swift
//  Marbles
//
//  Created by Rafal Grodzinski on 25/09/2016.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import UIKit
import StoreKit


class TipJarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet private var menuButton: UIButton!
    @IBOutlet private var tableView: UITableView!

    private var products: [SKProduct]?


    override func viewDidLoad()
    {
        PurchaseManager.sharedInstance.fetchProducts() { (products: [SKProduct]) in
            self.products = products
            self.tableView.reloadData()
        }
    }


    @IBAction private func menuButtonPressed(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }


    // MARK: UITableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let rowsCount = self.products != nil ? self.products!.count : 0

        return rowsCount
    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 72.0
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let product = self.products?[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "TipCell", for: indexPath)
        cell.backgroundColor = UIColor.marblesGreen().withAlphaComponent(0.4)
        cell.layer.cornerRadius = 5.0
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 1.0

        let titleLabel = cell.viewWithTag(1)
        if let title = titleLabel as? UILabel {
            title.font = UIFont(name: "BunakenUnderwater", size: 24.0)
            title.text = "My Title"//product?.localizedTitle
        }

        let priceLabel = cell.viewWithTag(2)
        if let price = priceLabel as? UILabel {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "gb")// product?.priceLocale
            price.font = UIFont(name: "BunakenUnderwater", size: 20.0)
            price.text = formatter.string(from: 1.0)//product!.price)
        }

        let tipButton = cell.viewWithTag(3)
        if let tip = tipButton as? UIButton {
            tip.titleLabel?.font = UIFont(name: "BunakenUnderwater", size: 28.0)
        }

        return cell
    }
}
