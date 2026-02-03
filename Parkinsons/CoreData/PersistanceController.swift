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
        if inMemory {
            container.persistentStoreDescriptions.first?.url =
                URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data load error: \(error)")
            }
        }
        container.viewContext.mergePolicy =
            NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
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


