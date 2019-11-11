//
//  Item.swift
//  TodoesBase
//
//  Created by Marcos Felipe Souza on 31/10/19.
//  Copyright © 2019 Marcos Felipe Souza. All rights reserved.
//

import Foundation

struct Item: Codable {
    var name: String
    var done: Bool = false
}
