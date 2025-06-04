#if canImport(CoreData)
import CoreData

public class Expense: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var amount: Double
    @NSManaged public var date: Date
    @NSManaged public var category: String?
    @NSManaged public var tags: [String]?
    @NSManaged public var notes: String?
}

extension Expense {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expense> {
        NSFetchRequest<Expense>(entityName: "Expense")
    }
}

public struct PersistenceController {
    public static let shared = PersistenceController()
    public let container: NSPersistentContainer

    public init(inMemory: Bool = false) {
        let model = Self.managedObjectModel()
        container = NSPersistentContainer(name: "ExpenseModel", managedObjectModel: model)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, _ in }
    }

    private static func managedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "Expense"
        entity.managedObjectClassName = NSStringFromClass(Expense.self)

        var properties: [NSPropertyDescription] = []

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false
        properties.append(id)

        let title = NSAttributeDescription()
        title.name = "title"
        title.attributeType = .stringAttributeType
        title.isOptional = false
        properties.append(title)

        let amount = NSAttributeDescription()
        amount.name = "amount"
        amount.attributeType = .doubleAttributeType
        amount.isOptional = false
        properties.append(amount)

        let date = NSAttributeDescription()
        date.name = "date"
        date.attributeType = .dateAttributeType
        date.isOptional = false
        properties.append(date)

        let category = NSAttributeDescription()
        category.name = "category"
        category.attributeType = .stringAttributeType
        category.isOptional = true
        properties.append(category)

        let tags = NSAttributeDescription()
        tags.name = "tags"
        tags.attributeType = .transformableAttributeType
        tags.attributeValueClassName = NSStringFromClass(NSArray.self)
        tags.valueTransformerName = NSValueTransformerName.secureUnarchiveFromDataTransformerName.rawValue
        tags.isOptional = true
        properties.append(tags)

        let notes = NSAttributeDescription()
        notes.name = "notes"
        notes.attributeType = .stringAttributeType
        notes.isOptional = true
        properties.append(notes)

        entity.properties = properties
        model.entities = [entity]
        return model
    }
}
#else
import Foundation

public struct PersistenceController {
    public init() {}
}
#endif
