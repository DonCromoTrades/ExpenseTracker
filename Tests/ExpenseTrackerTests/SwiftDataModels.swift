#if canImport(SwiftData)
import SwiftData
import ExpenseStore

@Model public class ExpenseModel {
    public var id: UUID
    public var title: String
    public var amount: Double
    public var date: Date
    public var category: String?
    public var tags: [String]?
    public var notes: String?
    public var frequencyRaw: String?

    public var frequency: RecurrenceFrequency? {
        get { frequencyRaw.flatMap { RecurrenceFrequency(rawValue: $0) } }
        set { frequencyRaw = newValue?.rawValue }
    }

    public init(id: UUID = UUID(), title: String, amount: Double, date: Date, category: String? = nil, tags: [String]? = nil, notes: String? = nil, frequency: RecurrenceFrequency? = nil) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.tags = tags
        self.notes = notes
        self.frequencyRaw = frequency?.rawValue
    }
}

@Model public class RecurringExpenseModel {
    public var id: UUID
    public var title: String
    public var amount: Double
    public var startDate: Date
    public var nextDate: Date
    public var frequency: String

    public init(id: UUID = UUID(), title: String, amount: Double, startDate: Date, nextDate: Date? = nil, frequency: String) {
        self.id = id
        self.title = title
        self.amount = amount
        self.startDate = startDate
        self.nextDate = nextDate ?? startDate
        self.frequency = frequency
    }
}

@Model public class BudgetModel {
    public var id: UUID
    public var category: String
    public var limit: Double

    public init(id: UUID = UUID(), category: String, limit: Double) {
        self.id = id
        self.category = category
        self.limit = limit
    }
}
#endif
