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

public class RecurringExpense: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var amount: Double
    @NSManaged public var frequency: String?
}

extension RecurringExpense {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecurringExpense> {
        NSFetchRequest<RecurringExpense>(entityName: "RecurringExpense")
    }
}

public class Budget: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var category: String
    @NSManaged public var limit: Double
}

extension Budget {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Budget> {
        NSFetchRequest<Budget>(entityName: "Budget")
    }
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
        let expenseEntity = NSEntityDescription()
        expenseEntity.name = "Expense"
        expenseEntity.managedObjectClassName = NSStringFromClass(Expense.self)

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

        expenseEntity.properties = properties

        // RecurringExpense entity
        let recEntity = NSEntityDescription()
        recEntity.name = "RecurringExpense"
        recEntity.managedObjectClassName = NSStringFromClass(RecurringExpense.self)

        var recProps: [NSPropertyDescription] = []

        let recId = NSAttributeDescription()
        recId.name = "id"
        recId.attributeType = .UUIDAttributeType
        recId.isOptional = false
        recProps.append(recId)

        let recTitle = NSAttributeDescription()
        recTitle.name = "title"
        recTitle.attributeType = .stringAttributeType
        recTitle.isOptional = false
        recProps.append(recTitle)

        let recAmount = NSAttributeDescription()
        recAmount.name = "amount"
        recAmount.attributeType = .doubleAttributeType
        recAmount.isOptional = false
        recProps.append(recAmount)

        let recFreq = NSAttributeDescription()
        recFreq.name = "frequency"
        recFreq.attributeType = .stringAttributeType
        recFreq.isOptional = true
        recProps.append(recFreq)

        recEntity.properties = recProps

        // Budget entity
        let budEntity = NSEntityDescription()
        budEntity.name = "Budget"
        budEntity.managedObjectClassName = NSStringFromClass(Budget.self)

        var budProps: [NSPropertyDescription] = []

        let budId = NSAttributeDescription()
        budId.name = "id"
        budId.attributeType = .UUIDAttributeType
        budId.isOptional = false
        budProps.append(budId)

        let budCategory = NSAttributeDescription()
        budCategory.name = "category"
        budCategory.attributeType = .stringAttributeType
        budCategory.isOptional = false
        budProps.append(budCategory)

        let budLimit = NSAttributeDescription()
        budLimit.name = "limit"
        budLimit.attributeType = .doubleAttributeType
        budLimit.isOptional = false
        budProps.append(budLimit)

        budEntity.properties = budProps

        model.entities = [expenseEntity, recEntity, budEntity]
        return model
    }

    // MARK: - Helper CRUD

    @discardableResult
    public func addRecurringExpense(title: String, amount: Double, frequency: String? = nil) -> RecurringExpense {
        let context = container.viewContext
        let item = RecurringExpense(context: context)
        item.id = UUID()
        item.title = title
        item.amount = amount
        item.frequency = frequency
        try? context.save()
        return item
    }

    public func deleteRecurringExpense(_ expense: RecurringExpense) {
        let context = container.viewContext
        context.delete(expense)
        try? context.save()
    }

    @discardableResult
    public func addBudget(category: String, limit: Double) -> Budget {
        let context = container.viewContext
        let item = Budget(context: context)
        item.id = UUID()
        item.category = category
        item.limit = limit
        try? context.save()
        return item
    }

    public func deleteBudget(_ budget: Budget) {
        let context = container.viewContext
        context.delete(budget)
        try? context.save()
    }
}
#else
import Foundation

public struct RecurringExpense {
    public init() {}
}

public struct Budget {
    public init() {}
}

public struct PersistenceController {
    public init() {}

    @discardableResult
    public func addRecurringExpense(title: String, amount: Double, frequency: String? = nil) -> RecurringExpense {
        RecurringExpense()
    }

    public func deleteRecurringExpense(_ expense: RecurringExpense) {}

    @discardableResult
    public func addBudget(category: String, limit: Double) -> Budget {
        Budget()
    }

    public func deleteBudget(_ budget: Budget) {}
}
#endif
