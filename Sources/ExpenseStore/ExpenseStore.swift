#if canImport(CoreData)
import CoreData

public class Expense: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var amount: Double
    @NSManaged public var date: Date
}

extension Expense {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expense> {
        NSFetchRequest<Expense>(entityName: "Expense")
    }
}

public struct PersistenceController {
    public static let shared: PersistenceController = {
        do {
            return try PersistenceController()
        } catch {
            fatalError("Unresolved error \(error)")
        }
    }()
    public let container: NSPersistentContainer

    public init(inMemory: Bool = false, storeURL: URL? = nil) throws {
        container = NSPersistentContainer(name: "ExpenseModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else if let storeURL {
            container.persistentStoreDescriptions.first?.url = storeURL
        }
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
            if let error {
                print("Failed to load persistent stores: \(error)")
            }
        }
        if let loadError {
            throw loadError
        }
    }
}
#else
import Foundation

public struct PersistenceController {
    public init(inMemory: Bool = false, storeURL: URL? = nil) throws {}
}
#endif
