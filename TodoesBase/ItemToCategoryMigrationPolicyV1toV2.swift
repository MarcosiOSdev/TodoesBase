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
        
        // 1
        let description = NSEntityDescription.entity(
            forEntityName: "Category",
            in: manager.destinationContext)
        
        let newAttachment = Category(
            entity: description!,
            insertInto: manager.destinationContext)
        
        newAttachment.setValue("no Category", forKey: "name")
        newAttachment.setValue(NSSet(array: []), forKey: "items")
        
        if let attributeMappings = mapping.relationshipMappings {
            for propertyMapping in attributeMappings {
                newAttachment.items?.adding(sInstance)
                sInstance.setValue(newAttachment, forKey: propertyMapping.name ?? "")
            }
        } else {
            let message = "No Attribute Mappings found!"
            let userInfo = [NSLocalizedFailureReasonErrorKey: message]
            throw NSError(domain: errorDomain,
                          code: 0, userInfo: userInfo)
        }
        
        
        // 7
        manager.associate(sourceInstance: sInstance,
                          withDestinationInstance: newAttachment,
                          for: mapping)
    }
    public override func createRelationships(forDestination dInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        
        print("GOT HERE")
    }
    
}
