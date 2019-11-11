//
//  ViewController.swift
//  TodoesBase
//
//  Created by Marcos Felipe Souza on 30/10/19.
//  Copyright © 2019 Marcos Felipe Souza. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    private let cellID = "cellReuse"
    
    
    var items = [Item]()
    
    //NSCODER :
    let dataFilePath:URL? = {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
        return url
    }()
    
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
            guard let name = textField.text else { return }
            let newItem = Item(name: name, done: false)
            self.save(item: newItem)
            self.loadDatas()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        self.present(alert, animated: true)
    }
    
    func save(item: Item) {
        self.items.append(item)
        do {
            let data = try PropertyListEncoder().encode(self.items)
            try data.write(to: self.dataFilePath!)
        } catch {
            print("Error ao salvar Item")
        }
    }
    
    func loadDatas(with name: String? = nil) {
        if let data = try? Data(contentsOf: self.dataFilePath!) {
            do {
                self.items = try PropertyListDecoder().decode([Item].self, from: data)
                if let namePredicate = name {
                    self.items = self.items.filter {$0.name.contains(namePredicate)}
                }
                self.items.sort { $0.name < $1.name || ($0.done && !$1.done) }
            } catch {
                print("Load Datas ok.")
            }
        }
        self.tableView.reloadData()
    }
    
    func updateItems() {
        do {
            let data = try PropertyListEncoder().encode(self.items)
            try data.write(to: self.dataFilePath!)
        } catch {
            print("Error ao salvar Item")
        }
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
        var item = self.items[indexPath.row]
        item.done = !item.done
        self.items[indexPath.row] = item
        self.updateItems()
        self.loadDatas()
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            searchBar.resignFirstResponder()
            loadDatas()
        } else if let name = searchBar.text {
            loadDatas(with: name)
        }
    }
}
