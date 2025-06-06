#if canImport(CloudKit)
import CloudKit
import SwiftData

public protocol CKDatabaseProtocol {
    func save(
        _ record: CKRecord,
        completionHandler: @Sendable @escaping (CKRecord?, Error?) -> Void
    )
    func perform(
        _ query: CKQuery,
        inZoneWith zoneID: CKRecordZone.ID?,
        completionHandler: @Sendable @escaping ([CKRecord]?, Error?) -> Void
    )
}

extension CKDatabase: CKDatabaseProtocol {}

public class CloudSyncManager {
    private let database: CKDatabaseProtocol
    private let context: ModelContext

    public init(container: CKContainer = .default(),
                context: ModelContext = PersistenceController.shared.container.mainContext) {
        self.database = container.privateCloudDatabase
        self.context = context
    }

    public init(database: CKDatabaseProtocol,
                context: ModelContext) {
        self.database = database
        self.context = context
    }

    private func record(from expense: Expense) -> CKRecord {
        let recordID = CKRecord.ID(recordName: expense.id.uuidString)
        let record = CKRecord(recordType: "Expense", recordID: recordID)
        record["title"] = expense.title as CKRecordValue
        record["amount"] = expense.amount as CKRecordValue
        record["date"] = expense.date as CKRecordValue
        if let category = expense.category {
            record["category"] = category as CKRecordValue
        }
        if let tags = expense.tags {
            record["tags"] = tags as CKRecordValue
        }
        if let notes = expense.notes {
            record["notes"] = notes as CKRecordValue
        }
        if let frequency = expense.frequency?.rawValue {
            record["frequency"] = frequency as CKRecordValue
        }
        return record
    }

    private func update(_ expense: Expense, from record: CKRecord) {
        expense.title = record["title"] as? String ?? expense.title
        expense.amount = record["amount"] as? Double ?? expense.amount
        expense.date = record["date"] as? Date ?? expense.date
        expense.category = record["category"] as? String
        expense.tags = record["tags"] as? [String]
        expense.notes = record["notes"] as? String
        if let raw = record["frequency"] as? String {
            expense.frequency = RecurrenceFrequency(rawValue: raw)
        } else {
            expense.frequency = nil
        }
    }

    private func merge(records: [CKRecord]) throws {
        for record in records {
            let id = UUID(uuidString: record.recordID.recordName) ?? UUID()
            let descriptor = FetchDescriptor<Expense>(predicate: #Predicate { $0.id == id })
            if let existing = try context.fetch(descriptor).first {
                update(existing, from: record)
            } else {
                let newExpense = Expense(id: id, title: "", amount: 0, date: Date())
                update(newExpense, from: record)
                context.insert(newExpense)
            }
        }
    }

    public func sync(expenses: [Expense], completion: @escaping (Error?) -> Void) {
        let records = expenses.map { record(from: $0) }
        let group = DispatchGroup()
        var capturedError: Error?
        for record in records {
            group.enter()
            database.save(record) { _, error in
                if capturedError == nil {
                    capturedError = error
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            if let err = capturedError {
                completion(err)
                return
            }
            self.fetchUpdates(completion: completion)
        }
    }

    public func fetchUpdates(completion: @escaping (Error?) -> Void) {
        let query = CKQuery(recordType: "Expense", predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                completion(error)
                return
            }
            guard let records = records else {
                completion(nil)
                return
            }
            do {
                try self.merge(records: records)
                try self.context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
#else
import Foundation

public class CloudSyncManager {
    public init() {}
    public func sync(expenses: [Any], completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
    public func fetchUpdates(completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
}
#endif
