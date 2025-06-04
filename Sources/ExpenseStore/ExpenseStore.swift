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
    @NSManaged public var frequency: String
}

public class Budget: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var category: String
    @NSManaged public var limit: Double
}

extension Expense {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expense> {
        NSFetchRequest<Expense>(entityName: "Expense")
    }
}

extension RecurringExpense {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecurringExpense> {
        NSFetchRequest<RecurringExpense>(entityName: "RecurringExpense")
    }
}

extension Budget {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Budget> {
        NSFetchRequest<Budget>(entityName: "Budget")
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

        let recurring = NSEntityDescription()
        recurring.name = "RecurringExpense"
        recurring.managedObjectClassName = NSStringFromClass(RecurringExpense.self)

        var recProps: [NSPropertyDescription] = []
        let rid = NSAttributeDescription()
        rid.name = "id"
        rid.attributeType = .UUIDAttributeType
        rid.isOptional = false
        recProps.append(rid)

        let rtitle = NSAttributeDescription()
        rtitle.name = "title"
        rtitle.attributeType = .stringAttributeType
        rtitle.isOptional = false
        recProps.append(rtitle)

        let ramount = NSAttributeDescription()
        ramount.name = "amount"
        ramount.attributeType = .doubleAttributeType
        ramount.isOptional = false
        recProps.append(ramount)

        let freq = NSAttributeDescription()
        freq.name = "frequency"
        freq.attributeType = .stringAttributeType
        freq.isOptional = false
        recProps.append(freq)

        recurring.properties = recProps

        let budget = NSEntityDescription()
        budget.name = "Budget"
        budget.managedObjectClassName = NSStringFromClass(Budget.self)

        var budProps: [NSPropertyDescription] = []
        let bid = NSAttributeDescription()
        bid.name = "id"
        bid.attributeType = .UUIDAttributeType
        bid.isOptional = false
        budProps.append(bid)

        let bcat = NSAttributeDescription()
        bcat.name = "category"
        bcat.attributeType = .stringAttributeType
        bcat.isOptional = false
        budProps.append(bcat)

        let blim = NSAttributeDescription()
        blim.name = "limit"
        blim.attributeType = .doubleAttributeType
        blim.isOptional = false
        budProps.append(blim)

        budget.properties = budProps

        model.entities = [expenseEntity, recurring, budget]
        return model
    }

    public func addRecurringExpense(title: String, amount: Double, frequency: String) throws {
        let context = container.viewContext
        let expense = RecurringExpense(context: context)
        expense.id = UUID()
        expense.title = title
        expense.amount = amount
        expense.frequency = frequency
        try context.save()
    }

    public func deleteRecurringExpense(_ expense: RecurringExpense) throws {
        let context = container.viewContext
        context.delete(expense)
        try context.save()
    }

    public func addBudget(category: String, limit: Double) throws {
        let context = container.viewContext
        let budget = Budget(context: context)
        budget.id = UUID()
        budget.category = category
        budget.limit = limit
        try context.save()
    }

    public func deleteBudget(_ budget: Budget) throws {
        let context = container.viewContext
        context.delete(budget)
        try context.save()
    }
}
#else
import Foundation

public struct PersistenceController {
    public init() {}
}
#endif
