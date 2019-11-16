//
//  MainRealm.swift
//  TodoesBase
//
//  Created by Marcos Felipe Souza on 15/11/19.
//  Copyright © 2019 Marcos Felipe Souza. All rights reserved.
//

import RealmSwift

class MainRealm {
    private init() {
        Realm.Configuration.defaultConfiguration = configuration
        initRealm()
        if let absolutePath = Realm.Configuration.defaultConfiguration.fileURL?.absoluteString {
            print(absolutePath)
        }
    }
    static let shared = MainRealm()
    var realm: Realm {
        do {
            let realm = try Realm()
            return realm
        } catch let error {
            print(error.localizedDescription)
            fatalError("Doenst work Realm")
        }
    }
    
    var configuration: Realm.Configuration {
        let config = Realm.Configuration(schemaVersion: 1, migrationBlock: { (migration, oldVersion) in
            if oldVersion == 1 {
                self.zeroToOne(migration, oldVersion)
            }
        })
        return config
    }
    private func initRealm() {
        
    }
}

//MARK: - Migrations
extension MainRealm {
    
    private func zeroToOne(_ migration: Migration, _ oldSchemaVersion: UInt64) -> Void {
        let category = Category()
        category.name = "No Category"        
        
        migration.enumerateObjects(ofType: Item.className()) { oldObject, newObject in
            let item = Item()
            item.title = newObject?["title"] as! String
            item.done = newObject?["done"] as! Bool
            category.items.append(item)
        }
        print("and migration")
    }
}
