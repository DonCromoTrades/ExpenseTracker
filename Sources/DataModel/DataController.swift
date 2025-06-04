import Foundation
import CoreData

public class DataController {
    public static let shared = DataController()
    public let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "ExpenseTrackerModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
    }

    public func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            try? context.save()
        }
    }
}
