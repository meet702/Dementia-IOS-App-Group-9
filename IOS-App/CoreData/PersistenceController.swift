//
//  PersistenceController.swift
//  IOS-App
//
//  Created by SDC-USER on 15/12/25.
//

internal import CoreData

struct PersistenceController {

    // Shared Instance
    static let shared = PersistenceController()

    // Core Data Container
    let container: NSPersistentContainer

    // Main Context
    var context: NSManagedObjectContext {
        container.viewContext
    }

    // Initializer
    init(inMemory: Bool = false) {

        container = NSPersistentContainer(name: "PeopleDataModel")

        if inMemory {
            container.persistentStoreDescriptions.first?.url =
                URL(fileURLWithPath: "/dev/null")
        }

        // Load persistent store
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError(
                    "Unresolved Core Data error \(error), \(error.userInfo)"
                )
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true

        container.viewContext.mergePolicy =
            NSMergeByPropertyObjectTrumpMergePolicy
    }

    // Save Helper
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError(
                    "Unresolved Core Data save error \(nsError), \(nsError.userInfo)"
                )
            }
        }
    }
}
