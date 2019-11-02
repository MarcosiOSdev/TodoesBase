//
//  DataMigrationManager.swift
//  TodoesBase
//
//  Created by Marcos Felipe Souza on 01/11/19.
//  Copyright © 2019 Marcos Felipe Souza. All rights reserved.
//

import Foundation
import CoreData

/// Class feita para interar atravez de todas as models do projeto até achar a que precisa ser usada para Store
class DataMigrationManager {
    
    let enableMigrations: Bool
    let modelName: String
    let storeName: String = "TodoesBase"
    
    var stack: CoreDataStack {
        //verifica se tem migracao e se a model é a atual
        guard enableMigrations,
            !store(at: storeURL,
                   isCompatibleWithModel: currentModel)
            else { return CoreDataStack(modelName: modelName) }
        
        performMigration()
        return CoreDataStack(modelName: modelName)
    }
    
    private lazy var currentModel: NSManagedObjectModel =
        .model(named: self.modelName)
    
    init(modelNamed: String, enableMigrations: Bool = false) {
        self.modelName = modelNamed
        self.enableMigrations = enableMigrations
    }
    
    func performMigration() {
        if !currentModel.isVersion3 {
            fatalError("Can only handle migrations to version 3!")
        }
        if let storeModel = self.storeModel {
            if storeModel.isVersion1 {
                let destinationModel = NSManagedObjectModel.version2
                //Mapping model in class: ItemToItemMigrationPolicyV1toV2
                let mappingModel = NSMappingModel(from: nil,
                                                  forSourceModel: storeModel,
                                                  destinationModel: destinationModel)
                migrateStoreAt(URL: storeURL,
                               fromModel: storeModel,
                               toModel: destinationModel,
                               mappingModel: mappingModel)
                
                performMigration()
            } else if storeModel.isVersion2 {
                let destinationModel = NSManagedObjectModel.version3
                
                
                migrateStoreAt(URL: storeURL,
                               fromModel: storeModel,
                               toModel: destinationModel)
                
                performMigration()
            }
        }
    }
    
    private func migrateStoreAt(URL storeURL: URL,
                                   fromModel from: NSManagedObjectModel,
                                   toModel to: NSManagedObjectModel,
                                   mappingModel: NSMappingModel? = nil) {
        
        // cria uma instancia para migracao.
        let migrationManager =
            NSMigrationManager(sourceModel: from, destinationModel: to)
        
        // verifica se o migration mapping foi passado no metodo.
        var migrationMappingModel: NSMappingModel
        if let mappingModel = mappingModel {
            migrationMappingModel = mappingModel
        } else {
            migrationMappingModel = try! NSMappingModel
                .inferredMappingModel(
                    forSourceModel: from, destinationModel: to)
        }
        
        // vai migrar instancia por instancia e data por data
        let targetURL = storeURL.deletingLastPathComponent()
        let destinationName = storeURL.lastPathComponent + "~1"
        let destinationURL = targetURL.appendingPathComponent(destinationName)
        
        print("From Model: \(from.entityVersionHashesByName)")
        print("To Model: \(to.entityVersionHashesByName)")
        print("Migrating store \(storeURL) to \(destinationURL)")
        print("Mapping model: \(String(describing: mappingModel))")
        
        // migration manager para funcionar
        let success: Bool
        do {
            try migrationManager.migrateStore(from: storeURL,
                                              sourceType: NSSQLiteStoreType,
                                              options: nil,
                                              with: migrationMappingModel,
                                              toDestinationURL: destinationURL,
                                              destinationType: NSSQLiteStoreType,
                                              destinationOptions: nil)
            success = true
        } catch {
            success = false
            print("Migration failed: \(error)")
        }
        
        // resultado das migracoes
        if success {
            print("Migration Completed Successfully")
            
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(at: storeURL)
                try fileManager.moveItem(at: destinationURL,
                                         to: storeURL)
            } catch {
                print("Error migrating \(error)")
            }
        }
    }
    
    //MARK: - Wrappper para determinar onde o store é compativel com a model dada
    private func store(at storeURL: URL,
                       isCompatibleWithModel model: NSManagedObjectModel) -> Bool {
        
        let storeMetadata = metadataForStoreAtURL(storeURL: storeURL)
        
        return model.isConfiguration(
            withName: nil,
            compatibleWithStoreMetadata:storeMetadata)
    }
    
    //MARK: - Retorna o metadata para armazenar apartir da URL
    private func metadataForStoreAtURL(storeURL: URL) -> [String: Any] {
        
        let metadata: [String: Any]
        do {
            metadata = try NSPersistentStoreCoordinator
                .metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL, options: nil)
        } catch {
            metadata = [:]
            print("Error retrieving metadata for store at URL: \(storeURL): \(error)")
        }
        return metadata
    }
    
    
    private var applicationSupportURL: URL {
        let path = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory,
            .userDomainMask, true)
            .first
        return URL(fileURLWithPath: path!)
    }
    
    /// A atual URL do Store
    private lazy var storeURL: URL = {
        let storeFileName = "\(self.storeName).sqlite"
        return URL(fileURLWithPath: storeFileName,
                   relativeTo: self.applicationSupportURL)
    }()
    
    /// A atual model do Store
    private var storeModel: NSManagedObjectModel? {
        return
            NSManagedObjectModel.modelVersionsFor(modelNamed: modelName)
                .filter {
                    self.store(at: storeURL, isCompatibleWithModel: $0)
                }.first
    }
    
}

extension NSManagedObjectModel {
    
    //MARK: - Equatable method
    static func == (firstModel: NSManagedObjectModel,
                    otherModel: NSManagedObjectModel) -> Bool {
        return firstModel.entitiesByName == otherModel.entitiesByName
    }
    
    private class func modelURLs(in modelFolder: String) -> [URL] {
        return Bundle.main
            .urls(forResourcesWithExtension: "mom",
                  subdirectory: "\(modelFolder).momd") ?? []
    }
    
    class func modelVersionsFor(
        modelNamed modelName: String) -> [NSManagedObjectModel] {
        
        return modelURLs(in: modelName)
            .compactMap(NSManagedObjectModel.init)
    }
    
    class func todoesBaseModel(
        named modelName: String) -> NSManagedObjectModel {
        
        let model = modelURLs(in: "TodoesBase")
            .filter { $0.lastPathComponent == "\(modelName).mom" }
            .first
            .flatMap(NSManagedObjectModel.init)
        return model ?? NSManagedObjectModel()
    }
    
    /// lembra da atual versão da model
    class func model(named modelName: String,
                     in bundle: Bundle = .main) -> NSManagedObjectModel {
        
        return
            bundle
                .url(forResource: modelName, withExtension: "momd")
                .flatMap(NSManagedObjectModel.init)
                ?? NSManagedObjectModel()
    }
    
    
    //MARK: - Versions
    class var version1: NSManagedObjectModel {
        return todoesBaseModel(named: "TodoesBase")
    }
    var isVersion1: Bool {
        return self == type(of: self).version1
    }
    
    class var version2: NSManagedObjectModel {
        return todoesBaseModel(named: "TodoesBase v2")
    }
    
    var isVersion2: Bool {
        return self == type(of: self).version2
    }
    
    class var version3: NSManagedObjectModel {
        return todoesBaseModel(named: "TodoesBase v3")
    }
    
    var isVersion3: Bool {
        return self == type(of: self).version3
    }
}
