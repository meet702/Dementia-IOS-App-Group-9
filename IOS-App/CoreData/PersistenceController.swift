//
//  PersistenceController.swift
//  IOS-App
//
//  Created by SDC-USER on 15/12/25.
//

internal import CoreData

struct PersistenceController {

    // MARK: - Shared Instance
    static let shared = PersistenceController()

    // MARK: - Core Data Container
    let container: NSPersistentContainer

    // MARK: - Main Context
    var context: NSManagedObjectContext {
        container.viewContext
    }

    // MARK: - Initializer
    init(inMemory: Bool = false) {

        // ⚠️ MUST match your .xcdatamodeld file name
        container = NSPersistentContainer(name: "PeopleDataModel")

        // In-memory store (useful for previews & unit tests)
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

        // Automatically merge changes (important for background saves)
        container.viewContext.automaticallyMergesChangesFromParent = true

        // Optional but recommended
        container.viewContext.mergePolicy =
            NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Save Helper
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
