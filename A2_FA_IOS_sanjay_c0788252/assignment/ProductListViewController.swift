//
//  ViewController.swift
//  assignment 2
//
//  Created by Sanjay prajapati (c0788252)
//  Copyright © 2021 Sanjay.H. All rights reserved.
//

import UIKit

class ProductListViewController: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    var products: [Product] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchProductsFromPlist()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ProductDetailViewController {
            controller.product = sender as? Product
        }
    }
    
    func fetchProductsFromPlist()  {
        let isInsertData = UserDefaults.standard.bool(forKey: "insertData")
        if isInsertData {
            if let product = DataBaseManager().readAllProducts() {
                self.products.append(contentsOf: product)
            }
        }
        else {
            if let path = Bundle.main.path(forResource: "product", ofType: "plist"), let data = NSData(contentsOfFile: path) {
                do {
                    let pListData = try PropertyListSerialization.propertyList(from: data as Data, options: .mutableContainers, format: nil)
                    if let pListData = pListData as? [[String : String]] {
                        for product in pListData {
                            DataBaseManager().insertProducts(product )
                        }
                        if let product = DataBaseManager().readAllProducts() {
                            self.products.append(contentsOf: product)
                        }
                        UserDefaults.standard.set(true, forKey: "insertData")
                    }
                }
                catch {
                    print(error)
                }
            }
        }
    }
}

extension ProductListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let labelItem = cell.viewWithTag(10) as? UILabel// tage of label is 10
        let product = products[indexPath.row]
        labelItem?.text = product.productName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = products[indexPath.row]
        self.performSegue(withIdentifier: "productListToDetail", sender: product)
    }

}

extension ProductListViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string).lowercased()
            
            if let product = DataBaseManager().readAllProducts() {
                if updatedText.isEmpty {
                    self.products.removeAll()
                    self.products.append(contentsOf: product)
                }
                else {
                    let items = product.filter({($0.productName!.lowercased().contains(updatedText))})
                    self.products.removeAll()
                    self.products.append(contentsOf: items)
                }
                self.tblView.reloadData()
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
