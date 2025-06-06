#if canImport(SwiftData)
import SwiftData
#if canImport(CloudKit)
import CloudKit
#endif

@Model
public final class Expense {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var amount: Double
    public var date: Date
    public var category: String?
    public var tags: [String]?
    public var notes: String?
    public var frequency: RecurrenceFrequency?

    public init(id: UUID = UUID(), title: String, amount: Double, date: Date,
                category: String? = nil, tags: [String]? = nil,
                notes: String? = nil, frequency: RecurrenceFrequency? = nil) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.tags = tags
        self.notes = notes
        self.frequency = frequency
    }
}

@Model
public final class RecurringExpense {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var amount: Double
    public var startDate: Date
    public var nextDate: Date
    public var frequency: String

    public init(id: UUID = UUID(), title: String, amount: Double,
                startDate: Date, frequency: String) {
        self.id = id
        self.title = title
        self.amount = amount
        self.startDate = startDate
        self.nextDate = startDate
        self.frequency = frequency
    }
}

@Model
public final class Budget {
    @Attribute(.unique) public var id: UUID
    public var category: String
    public var limit: Double

    public init(id: UUID = UUID(), category: String, limit: Double) {
        self.id = id
        self.category = category
        self.limit = limit
    }
}

public struct PersistenceController {
    public static let shared = PersistenceController()
    public let container: ModelContainer
#if canImport(CloudKit)
    public let cloudSync: CloudSyncManager
#endif

    public init(inMemory: Bool = false) {
        let schema = Schema([Expense.self, RecurringExpense.self, Budget.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        container = try! ModelContainer(for: schema, configurations: config)
#if canImport(CloudKit)
        if let id = Bundle.main.object(forInfoDictionaryKey: "CloudKitContainerIdentifier") as? String {
            cloudSync = CloudSyncManager(container: CKContainer(identifier: id), context: container.mainContext)
        } else {
            cloudSync = CloudSyncManager(context: container.mainContext)
        }
        cloudSync.fetchUpdates { _ in }
#endif
    }

    private var context: ModelContext { container.mainContext }

    /// Creates a new `Expense` with the provided values and saves the context.
    /// - Parameters:
    ///   - title: The title or vendor of the expense.
    ///   - amount: Monetary value of the expense.
    ///   - date: The date the expense occurred.
    ///   - category: Optional category name.
    /// - Returns: The newly created `Expense` instance.
    @discardableResult
    public func addExpense(title: String, amount: Double, date: Date, category: String? = nil) throws -> Expense {
        let expense = Expense(title: title, amount: amount, date: date, category: category)
        context.insert(expense)
        try context.save()
#if canImport(CloudKit)
        cloudSync.sync(expenses: [expense]) { _ in }
#endif
        return expense
    }

    @discardableResult
    public func addRecurringExpense(title: String, amount: Double, startDate: Date, frequency: String) throws -> RecurringExpense {
        let obj = RecurringExpense(title: title, amount: amount, startDate: startDate, frequency: frequency)
        context.insert(obj)
        try context.save()
        return obj
    }

    public func deleteRecurringExpense(_ expense: RecurringExpense) throws {
        context.delete(expense)
        try context.save()
    }

    @discardableResult
    public func addBudget(category: String, limit: Double) throws -> Budget {
        let budget = Budget(category: category, limit: limit)
        context.insert(budget)
        try context.save()
        return budget
    }

    public func deleteBudget(_ budget: Budget) throws {
        context.delete(budget)
        try context.save()
    }

    @discardableResult
    public func addExpense(title: String, amount: Double, date: Date,
                           category: String? = nil, notes: String? = nil) throws -> Expense {
        let expense = Expense(title: title, amount: amount, date: date, category: category, notes: notes)
        context.insert(expense)
        try context.save()
#if canImport(CloudKit)
        cloudSync.sync(expenses: [expense]) { _ in }
#endif
        return expense
    }

    public func deleteExpense(_ expense: Expense) throws {
        context.delete(expense)
        try context.save()
#if canImport(CloudKit)
        cloudSync.fetchUpdates { _ in }
#endif
    }

#if canImport(CloudKit)
    public func syncExpense(_ expense: Expense) {
        cloudSync.sync(expenses: [expense]) { _ in }
    }

    public func fetchCloudUpdates() {
        cloudSync.fetchUpdates { _ in }
    }
#endif
}
#else
import Foundation

public struct PersistenceController {
    public init() {}
}
#endif
