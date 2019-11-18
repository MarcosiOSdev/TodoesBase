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
        self.tableView.reloadData()
    }
    private func delete(at indexPath: IndexPath) {
        let category = self.categories[indexPath.row]
        do {
            let realm = RealmStack.shared.realm
            try realm.write {
                realm.delete(category, cascading: true)
                self.categories.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } catch {
            print(error.localizedDescription)
            print("Error in Delete Category")
        }
        
    }
}

//MARK: - Anothers Funcs
extension CategoryViewController {
    private func setupTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        self.tableView.rowHeight = CGFloat(50)
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
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let action = UIContextualAction(style: .normal, title: "Files", handler: { (action,view,completionHandler ) in
            self.delete(at: indexPath)
            completionHandler(true)
        })
        action.image = UIImage(named: "trash-circle")
        action.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [action])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    func tableView(_ tableView: UITableView,
                           editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
            return .none
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let accessButton = UITableViewRowAction(style: .normal, title: "") { action, index in
            self.delete(at: indexPath)
        }
        accessButton.backgroundColor = UIColor(patternImage: UIImage(named: "trash-circle")!)
        
        return [accessButton]
    }
}
