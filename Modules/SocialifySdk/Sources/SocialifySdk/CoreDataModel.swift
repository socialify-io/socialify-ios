//
//  CoreDataModel.swift
//
//
//  Created by Tomasz on 04/08/2021.
//

import Foundation
import CoreData
import os

@available(iOS 14.0, *)
@available(iOSApplicationExtension 14.0, *)
public final class CoreDataModel: ObservableObject {
    public static let shared: CoreDataModel = CoreDataModel()
    private let logger: Logger = Logger(subsystem: "\(Bundle.main.bundleIdentifier!).CoreData", category: "CoreData")
    
    private init() {}
    
    lazy public var persistentContainer: NSPersistentContainer = {

        let modelURL = Bundle.module.url(forResource: "SocialifyStore", withExtension: "momd")
        let model = NSManagedObjectModel(contentsOf: modelURL!)

        let container = NSPersistentContainer(name: "SocialifyStore", managedObjectModel: model!)
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                self.logger.error("Could not load store: \(error.localizedDescription)")
                self.logger.debug("\(String(describing: storeDescription))")
                self.clearDatabase()
                return
            }

            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            self.logger.info("Store loaded!")
        }

        return container

    }()
    
    /// Saves the CoreData context.
    public func saveContext(force: Bool = false) {
        if self.persistentContainer.viewContext.hasChanges || force {
            do {
                try self.persistentContainer.viewContext.save()
            } catch {
                logger.error("Error saving: \(error.localizedDescription)")
            }
        }
    }
    
    /// Resets the database.
    public func clearDatabase() {
        let urls = persistentContainer.persistentStoreDescriptions.map(\.url)
        let persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        
        logger.debug("Clearing database...")
        
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
            for url in urls {
                guard let url = url else { return }
                try persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)
                try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
            }
            logger.debug("Done!")
        } catch {
            logger.error("Error: \(error.localizedDescription)")
        }
    }
}
