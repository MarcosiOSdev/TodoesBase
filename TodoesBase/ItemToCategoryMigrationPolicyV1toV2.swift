//
//  ItemToCategoryMigrationPolicyV1toV2.swift
//  TodoesBase
//
//  Created by Marcos Felipe Souza on 30/10/19.
//  Copyright © 2019 Marcos Felipe Souza. All rights reserved.
//

import Foundation
import CoreData

let errorDomain = "Migration"
public class ItemToCategoryMigrationPolicyV1toV2: NSEntityMigrationPolicy {
    
    override public func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager) throws {
        
        
        
        let description = NSEntityDescription.entity(
            forEntityName: "Item",
            in: manager.destinationContext)
        
        let newItem = Item(
            entity: description!,
            insertInto: manager.destinationContext)
        
        let descriptionCategory = NSEntityDescription.entity(
            forEntityName: "Category",
            in: manager.destinationContext)
        
        let newCategory = Category(
            entity: descriptionCategory!,
            insertInto: manager.destinationContext)
        
        newCategory.name = "No Category"
        newCategory.items = []
        
        newItem.category = newCategory
        newCategory.addToItems(newItem)
        
        manager.associate(sourceInstance: sInstance, withDestinationInstance: newItem, for: mapping)
        
        
    }
    public override func createRelationships(forDestination dInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        
        print("GOT HERE")
    }
    
}
