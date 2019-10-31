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
public class ItemToItemMigrationPolicyV1toV2: NSEntityMigrationPolicy {
    
    var categoryId: NSManagedObjectID?
    
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
        
        newItem.name = sInstance.value(forKey: "name") as? String
        let numberBool = sInstance.value(forKey: "done") as? Int
        newItem.setValue((numberBool ?? 0) > 0, forKey: "done") 
 
        
        // IF ja existe o ID da Category então usa  o NSManagedObject
        if let id = self.categoryId,
            let category = try? manager.destinationContext.existingObject(with: id),
            let item =  try? manager.destinationContext.existingObject(with: newItem.objectID) {
            
            let items = category.value(forKey: "items") as? NSSet
            items?.adding(item)
            item.setValue(category, forKey: "category")
            
        } else { // não existe ID , então cria a primeira category
            let newCategory = Category(
                entity: descriptionCategory!,
                insertInto: manager.destinationContext)
            
            newCategory.name = "No Category"
            newCategory.items = []
            newCategory.addToItems(newItem)
            newItem.category = newCategory
            self.categoryId = newCategory.objectID
        }
        
        
        manager.associate(sourceInstance: sInstance,
                          withDestinationInstance: newItem,
                          for: mapping)
        
        
    }
    public override func createRelationships(forDestination dInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        
        print("GOT HERE")
    }
    
}
