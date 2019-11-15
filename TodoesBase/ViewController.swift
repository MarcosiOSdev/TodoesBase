//
//  ViewController.swift
//  TodoesBase
//
//  Created by Marcos Felipe Souza on 30/10/19.
//  Copyright © 2019 Marcos Felipe Souza. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    private let cellID = "cellReuse"
    
    var realm: Realm? = {
        do {
            let realm = try Realm()
            return realm
        } catch {
            return nil
        }        
    }()
    
    var items: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        loadDatas()
    }
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Adicione um novo Item",
                                      message: "",
                                      preferredStyle: .alert)
        
        var textField = UITextField()
        alert.addTextField { tf in
            textField = tf
            textField.placeholder = "Digite"
        }
        
        alert.addAction(UIAlertAction(title: "Salvar", style: .default, handler: { (alert) in
            let name = textField.text ?? ""
            let newItem = Item()
            newItem.title = name
            self.save(newItem)
            self.loadDatas()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        self.present(alert, animated: true)
    }
}

//MARK: - Functions Realm
extension ViewController {
    func loadDatas() {
        guard let results = self.realm?.objects(Item.self) else { return }
        self.items = Array(results)
        self.tableView.reloadData()
    }
    func save(_ newItem: Item) {
        do {
            try realm?.write {
                realm?.add(newItem)
            }
        } catch {
            print("Error save newItem")
        }
    }
    func loadData(with itemName: String) {
        guard let results = realm?.objects(Item.self).filter("title CONTAINS %@", itemName) else { return }        
        self.items = Array(results)
        self.tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.performBatchUpdates({
            let item = self.items[indexPath.row]
            item.done = !item.done
            self.items[indexPath.row] = item
        })
        tableView.reloadRows(at: [indexPath], with: .left)
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.loadData(with: searchText)
    }
}
