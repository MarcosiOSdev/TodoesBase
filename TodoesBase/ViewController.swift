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
    
    var realm: Realm {
        return RealmStack.shared.realm
    }
    var categorySelected: Category?
    var items: Results<Item>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        self.title = categorySelected?.name
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
            guard let name = textField.text else { return }
            let newItem = Item()
            newItem.title = name
            self.save(newItem)
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        self.present(alert, animated: true)
    }
}

//MARK: - Functions Realm
extension ViewController {
    func loadDatas() {
//        guard let category = categorySelected else { return }
//
//        if let results = self.realm?
//            .objects(Category.self)
//            .filter("id == %@", category.id)
//            .first?
//            .items
//            .sorted(by: [SortDescriptor(keyPath: "done", ascending: false),
//                         SortDescriptor(keyPath: "title", ascending: true)]) {
//
//            self.items = results
//            self.tableView.reloadData()
//        }
    }
    func save(_ newItem: Item) {
//        guard let category = self.categorySelected else { return }
//        
//        do {
//            try realm?.write {
//                category.items.append(newItem)
//                realm?.add(category)
//            }
//        } catch {
//            print("Error save newItem")
//        }
    }
    func loadData(with itemName: String) {
        guard let category = self.categorySelected else { return }
        self.items = self.realm
            .objects(Item.self)
            .filter("title CONTAINS[cd] %@ AND ANY category.id == %@", itemName, category.id)            
            .sorted(by: [SortDescriptor(keyPath: "done", ascending: false),
                         SortDescriptor(keyPath: "title", ascending: true)])
        
        self.tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath)
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "Não tem itens"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = self.items?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error ao editar o done do Item")
            }
            self.tableView.reloadData()
        }
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchText == "" ? self.loadDatas() : self.loadData(with: searchText)
    }
}
