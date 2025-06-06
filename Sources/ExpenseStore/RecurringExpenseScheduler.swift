#if canImport(SwiftData)
import Foundation
import SwiftData

@available(iOS 17.0, macOS 14.0, *)
public class RecurringExpenseScheduler {
    private let context: ModelContext
    private let calendar = Calendar.current

    public init(context: ModelContext = PersistenceController.shared.container.mainContext) {
        self.context = context
    }

    private func advanceDate(_ date: Date, frequency: RecurrenceFrequency) -> Date {
        switch frequency {
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: date) ?? date
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: date) ?? date
        }
    }

    /// Checks for due recurring expenses and creates `Expense` records.
    public func processDueExpenses(asOf date: Date = Date()) throws {
        let descriptor = FetchDescriptor<RecurringExpense>(predicate: #Predicate { $0.nextDate <= date })
        let items = try context.fetch(descriptor)
        for item in items {
            let expense = Expense(title: item.title, amount: item.amount, date: item.nextDate)
            context.insert(expense)
            if let freq = RecurrenceFrequency(rawValue: item.frequency) {
                item.nextDate = advanceDate(item.nextDate, frequency: freq)
            }
        }
        try context.save()
    }
}
#endif
