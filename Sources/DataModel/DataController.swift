import Foundation
#if canImport(CoreData)
import CoreData
#endif

#if canImport(CoreData)
@MainActor
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
#else
@MainActor
/// Stub controller used on platforms without CoreData (e.g., Linux). This allows
/// the package to build even when the CoreData framework is unavailable.
public class DataController {
    public static let shared = DataController()
    private init() {}
    public func saveContext() {}
}
#endif
