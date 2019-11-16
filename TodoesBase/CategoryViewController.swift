//
//  CategoryViewController.swift
//  TodoesBase
//
//  Created by Marcos Felipe Souza on 15/11/19.
//  Copyright © 2019 Marcos Felipe Souza. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {
    private let cellID = "cellID"
    @IBOutlet weak var tableView: UITableView!
    
    private var categories = [Category]()
}

//MARK: - Lifecycle of View
extension CategoryViewController {
    override func viewDidLoad() {
        self.setupTableView()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.loadDatas()
        super.viewDidAppear(animated)
    }
}


//MARK: - Actions
extension CategoryViewController {
    @IBAction func tapOnAddButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Adicione uma nova Categoria",
                                      message: "",
                                      preferredStyle: .alert)
        
        var textField = UITextField()
        alert.addTextField { tf in
            textField = tf
            textField.placeholder = "Digite"
        }
        
        alert.addAction(UIAlertAction(title: "Salvar", style: .default, handler: { (alert) in
            let name = textField.text ?? ""
            let category = Category()
            category.name = name
            self.save(category: category)
            self.loadDatas()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        self.present(alert, animated: true)
    }
}

//MARK: - Realm Funcs
extension CategoryViewController {
    private func loadDatas() {
        let realm = RealmStack.shared.realm
        let result = realm.objects(Category.self)
        self.categories = Array(result)
        self.tableView.reloadData()
    }
    
    private func save(category: Category) {
        do {
            let realm = RealmStack.shared.realm
            try realm.write {
                realm.add(category)
            }
        } catch {
            print(error.localizedDescription)
            print("Error in SaveCategory")
        }
        
    }
}

//MARK: - Anothers Funcs
extension CategoryViewController {
    private func setupTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let itemVC = segue.destination as? ViewController {
            if let index = self.tableView.indexPathForSelectedRow {
                itemVC.categorySelected = self.categories[index.row]
            }
        }
    }
}

//MARK: - Datasource and Delegate TableView
extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle , reuseIdentifier: self.cellID)
        let category = self.categories[indexPath.row]
        cell.textLabel?.text = category.name
        cell.detailTextLabel?.text = "(\(category.items.count))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "goToItem", sender: nil)
    }
}
