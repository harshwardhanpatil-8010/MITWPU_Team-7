//
//  PersistanceController.swift
//  Parkinsons
//
//  Created by SDC-USER on 03/02/26.
//

import CoreData
 class PersistenceController {
    
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Data Model")
        print("[COREDATA] Initializing PersistenceController...")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url =
                URL(fileURLWithPath: "/dev/null")
        }
        
        // Enable automatic lightweight migration so re-runs don't fail
        if let description = container.persistentStoreDescriptions.first {
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
            print("[COREDATA] Store URL: \(description.url?.absoluteString ?? "nil")")
        }
        
        container.loadPersistentStores { storeDesc, error in
            if let error = error {
                print("[COREDATA] FATAL: Core Data load error: \(error)")
                fatalError("Core Data load error: \(error)")
            }
            print("[COREDATA] Store loaded OK: \(storeDesc.url?.lastPathComponent ?? "unknown")")
        }
        container.viewContext.mergePolicy =
            NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        print("[COREDATA] PersistenceController ready")
    }
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy =
            NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    func save(_ context: NSManagedObjectContext? = nil) {
        let ctx = context ?? viewContext
        guard ctx.hasChanges else { return }
        do {
            try ctx.save()
        } catch {
            fatalError("Core Data save error: \(error)")
        }
    }
}


