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
public class ItemToCategoryMigrationPolicyV1toV22: NSEntityMigrationPolicy {
    
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
        
        // 2
        func traversePropertyMappings(block: (NSPropertyMapping, String) -> ()) throws {
            if let attributeMappings = mapping.attributeMappings {
                for propertyMapping in attributeMappings {
                    if let destinationName = propertyMapping.name {
                        block(propertyMapping, destinationName)
                    } else {
                        // 3
                        let message =
                        "Attribute destination not configured properly"
                        let userInfo =
                            [NSLocalizedFailureReasonErrorKey: message]
                        throw NSError(domain: errorDomain,
                                      code: 0, userInfo: userInfo)
                    }
                }
            } else {
                let message = "No Attribute Mappings found!"
                let userInfo = [NSLocalizedFailureReasonErrorKey: message]
                throw NSError(domain: errorDomain,
                              code: 0, userInfo: userInfo)
            }
        }
        
        // 4
        try traversePropertyMappings {
            propertyMapping, destinationName in
            if let valueExpression = propertyMapping.valueExpression {
                let context: NSMutableDictionary = ["source": sInstance]
                guard let destinationValue =
                    valueExpression.expressionValue(with: sInstance,
                                                    context: context) else {
                                                        return
                }
                
                newAttachment.setValue(destinationValue,
                                       forKey: destinationName)
            }
        }
        
        
        // 5
        if (sInstance as? Item) != nil {
            newAttachment.setValue("No Category", forKey: "name")
        }
        
        // 7
        manager.associate(sourceInstance: sInstance,
                          withDestinationInstance: newAttachment,
                          for: mapping)
    }
    
    
}
