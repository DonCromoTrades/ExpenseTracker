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
    @NSManaged @objc(frequency) private var frequencyRaw: String?
}

extension Expense {
    public var frequency: RecurrenceFrequency? {
        get { frequencyRaw.flatMap { RecurrenceFrequency(rawValue: $0) } }
        set { frequencyRaw = newValue?.rawValue }
    }
}

public class RecurringExpense: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var amount: Double
    @NSManaged public var startDate: Date
    @NSManaged public var frequency: String
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

        let frequency = NSAttributeDescription()
        frequency.name = "frequency"
        frequency.attributeType = .stringAttributeType
        frequency.isOptional = true
        properties.append(frequency)

        entity.properties = properties

        // RecurringExpense entity
        let recurring = NSEntityDescription()
        recurring.name = "RecurringExpense"
        recurring.managedObjectClassName = NSStringFromClass(RecurringExpense.self)

        var recurringProps: [NSPropertyDescription] = []
        let rid = NSAttributeDescription()
        rid.name = "id"
        rid.attributeType = .UUIDAttributeType
        rid.isOptional = false
        recurringProps.append(rid)

        let rtitle = NSAttributeDescription()
        rtitle.name = "title"
        rtitle.attributeType = .stringAttributeType
        rtitle.isOptional = false
        recurringProps.append(rtitle)

        let ramount = NSAttributeDescription()
        ramount.name = "amount"
        ramount.attributeType = .doubleAttributeType
        ramount.isOptional = false
        recurringProps.append(ramount)

        let rstartDate = NSAttributeDescription()
        rstartDate.name = "startDate"
        rstartDate.attributeType = .dateAttributeType
        rstartDate.isOptional = false
        recurringProps.append(rstartDate)

        let rfrequency = NSAttributeDescription()
        rfrequency.name = "frequency"
        rfrequency.attributeType = .stringAttributeType
        rfrequency.isOptional = false
        recurringProps.append(rfrequency)

        recurring.properties = recurringProps

        // Budget entity
        let budgetEntity = NSEntityDescription()
        budgetEntity.name = "Budget"
        budgetEntity.managedObjectClassName = NSStringFromClass(Budget.self)

        var budgetProps: [NSPropertyDescription] = []
        let bid = NSAttributeDescription()
        bid.name = "id"
        bid.attributeType = .UUIDAttributeType
        bid.isOptional = false
        budgetProps.append(bid)

        let bcat = NSAttributeDescription()
        bcat.name = "category"
        bcat.attributeType = .stringAttributeType
        bcat.isOptional = false
        budgetProps.append(bcat)

        let blimit = NSAttributeDescription()
        blimit.name = "limit"
        blimit.attributeType = .doubleAttributeType
        blimit.isOptional = false
        budgetProps.append(blimit)

        budgetEntity.properties = budgetProps

        model.entities = [entity, recurring, budgetEntity]
        return model
    }

    /// Creates a new `Expense` with the provided values and saves the context.
    /// - Parameters:
    ///   - title: The title or vendor of the expense.
    ///   - amount: Monetary value of the expense.
    ///   - date: The date the expense occurred.
    ///   - category: Optional category name.
    /// - Returns: The newly created `Expense` instance.
    @discardableResult
    public func addExpense(title: String, amount: Double, date: Date, category: String? = nil) throws -> Expense {
        let expense = Expense(context: container.viewContext)
        expense.id = UUID()
        expense.title = title
        expense.amount = amount
        expense.date = date
        expense.category = category
        try container.viewContext.save()
        return expense
    }

    @discardableResult
    public func addRecurringExpense(title: String, amount: Double, startDate: Date, frequency: String) throws -> RecurringExpense {
        let obj = RecurringExpense(context: container.viewContext)
        obj.id = UUID()
        obj.title = title
        obj.amount = amount
        obj.startDate = startDate
        obj.frequency = frequency
        try container.viewContext.save()
        return obj
    }

    public func deleteRecurringExpense(_ expense: RecurringExpense) throws {
        let ctx = container.viewContext
        ctx.delete(expense)
        try ctx.save()
    }

    @discardableResult
    public func addBudget(category: String, limit: Double) throws -> Budget {
        let budget = Budget(context: container.viewContext)
        budget.id = UUID()
        budget.category = category
        budget.limit = limit
        try container.viewContext.save()
        return budget
    }

    public func deleteBudget(_ budget: Budget) throws {
        let ctx = container.viewContext
        ctx.delete(budget)
        try ctx.save()
    }
}
#else
import Foundation

public struct PersistenceController {
    public init() {}
}
#endif
