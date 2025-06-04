#if canImport(CoreData)
import Foundation
import CoreData

public class RecurringExpenseScheduler {
    private let context: NSManagedObjectContext
    private let calendar = Calendar.current

    public init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
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
        let request: NSFetchRequest<RecurringExpense> = RecurringExpense.fetchRequest()
        request.predicate = NSPredicate(format: "nextDate <= %@", date as NSDate)
        let items = try context.fetch(request)
        for item in items {
            let expense = Expense(context: context)
            expense.id = UUID()
            expense.title = item.title
            expense.amount = item.amount
            expense.date = item.nextDate
            if let freq = RecurrenceFrequency(rawValue: item.frequency) {
                item.nextDate = advanceDate(item.nextDate, frequency: freq)
            }
        }
        if context.hasChanges {
            try context.save()
        }
    }
}
#endif
