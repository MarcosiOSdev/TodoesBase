//
//  Item.swift
//  TodoesBase
//
//  Created by Marcos Felipe Souza on 31/10/19.
//  Copyright © 2019 Marcos Felipe Souza. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    
}
