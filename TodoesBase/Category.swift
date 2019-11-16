//
//  Category.swift
//  TodoesBase
//
//  Created by Marcos Felipe Souza on 15/11/19.
//  Copyright © 2019 Marcos Felipe Souza. All rights reserved.
//

import RealmSwift

class Category: Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var name: String = ""
    //let items = List<Item>()
    
    override class func primaryKey() -> String {
        return "id"
    }
}
