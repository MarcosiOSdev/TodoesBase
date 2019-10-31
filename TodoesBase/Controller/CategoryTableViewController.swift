//
//  CategoryTableViewController.swift
//  TodoesBase
//
//  Created by Marcos Felipe Souza on 31/10/19.
//  Copyright © 2019 Marcos Felipe Souza. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {

    var coreDataStack = CoreDataStack.shared
    var categories = [Category]()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDatas()
    }

    //MARK: - DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name
        let count = category.items?.count ?? 0
        cell.detailTextLabel?.text = "(\(count))"
        return cell
    }
    
    //MARK: - Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    
    //MARK: - Event Actions
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Categoria",
                                                message: "Adicione a Categoria",
                                                preferredStyle: .alert)
        
        var textField = UITextField()
        alertController.addTextField { tf in
            tf.placeholder = "Digite a Categoria"
            textField = tf
        }
        
        alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Salvar",
                                                style: .default,
                                                handler: { [weak self] alert in
                                                    
                                                    guard let selfStrong = self else { return }
                                                    let category = Category(context: selfStrong.coreDataStack.managedContext)
                                                    category.name = textField.text
                                                    selfStrong.coreDataStack.saveContext()
                                                    selfStrong.loadDatas()
        }))
        
        self.present(alertController, animated: true)
    }
}

//MARK: - CoreData Functions -
extension CategoryTableViewController {
    func loadDatas() {
        do {
            self.categories = try coreDataStack.managedContext.fetch(Category.fetchRequest())
        } catch {
            self.categories = []
            print("Erro on load in LoadDatas")
        }
        self.tableView.reloadData()
    }
}