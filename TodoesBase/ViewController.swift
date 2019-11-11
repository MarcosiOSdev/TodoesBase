//
//  ViewController.swift
//  TodoesBase
//
//  Created by Marcos Felipe Souza on 30/10/19.
//  Copyright © 2019 Marcos Felipe Souza. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    private let cellID = "cellReuse"
    
    let stack = CoreDataStack.shared
    
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
            
            let item = Item(context: self.stack.managedContext)
            item.name = textField.text
            self.stack.saveContext()
            self.loadDatas()
            
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        self.present(alert, animated: true)
    }
    
    func loadDatas(request: NSFetchRequest<Item>? = nil) {
        do {
            let itemRequest:NSFetchRequest = request ?? Item.fetchRequest()
            let nameSort = NSSortDescriptor(key: "name", ascending: true)
            let checkedSort = NSSortDescriptor(key: "done", ascending: false)
            itemRequest.sortDescriptors = [checkedSort, nameSort]
            self.items = try stack.managedContext.fetch(itemRequest)
        } catch {
            print("Error on ViewDidLoad on Load of Items")
        }
        self.tableView.reloadData()
    }
    
    func loadDatas(with name: String) {
        let request: NSFetchRequest = Item.fetchRequest()
        let predicateNamed = NSPredicate(format: "name CONTAINS[cd] %@", name)
        request.predicate = predicateNamed
        self.loadDatas(request: request)
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.name
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.performBatchUpdates({
            let item = self.items[indexPath.row]
            item.done = !item.done
            stack.saveContext()
        })
        tableView.reloadRows(at: [indexPath], with: .left)
        
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadDatas()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else if let name = searchBar.text {
            loadDatas(with: name)
        }
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let name = searchBar.text {
            loadDatas(with: name)
        }
    }
    
}
