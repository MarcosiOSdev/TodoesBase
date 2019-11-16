//
//  MainRealm.swift
//  TodoesBase
//
//  Created by Marcos Felipe Souza on 15/11/19.
//  Copyright © 2019 Marcos Felipe Souza. All rights reserved.
//

import RealmSwift

class RealmStack {
    private init() {
        Realm.Configuration.defaultConfiguration = configuration
        if let absolutePath = Realm.Configuration.defaultConfiguration.fileURL?.absoluteString {
            print(absolutePath)
        }
    }
    static let shared = RealmStack()
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
            if oldVersion < 1 {
                print("==== Migration 1 === ")
                self.zeroToOne(migration, oldVersion)
            }
        })
        return config
    }
}

//MARK: - Migrations
extension RealmStack {
    
    private func zeroToOne(_ migration: Migration, _ oldSchemaVersion: UInt64) -> Void {
        let category = migration.create(Category.className())
        category["name"] = "No Category"
        category["id"] = NSUUID().uuidString
        migration.enumerateObjects(ofType: Item.className()) { oldObject, newObject in
            if let items = category["items"] as? List<MigrationObject>, let item = newObject {
                items.append(item)
            }
        }
    }
}
