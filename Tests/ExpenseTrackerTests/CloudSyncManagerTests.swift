#if canImport(CloudKit) && canImport(CoreData)
import XCTest
import CloudKit
@testable import ExpenseStore

final class CloudSyncManagerTests: XCTestCase {
    class MockDatabase: CKDatabaseProtocol {
        var savedRecords: [CKRecord] = []
        var queryResults: [CKRecord] = []
        func save(_ record: CKRecord, completionHandler: @escaping (CKRecord?, Error?) -> Void) {
            savedRecords.append(record)
            completionHandler(record, nil)
        }
        func perform(_ query: CKQuery, inZoneWith zoneID: CKRecordZone.ID?, completionHandler: @escaping ([CKRecord]?, Error?) -> Void) {
            completionHandler(queryResults, nil)
        }
    }

    func testSyncSavesRecords() throws {
        let mockDB = MockDatabase()
        let context = PersistenceController(inMemory: true).container.viewContext
        let manager = CloudSyncManager(database: mockDB, context: context)

        let expense = Expense(context: context)
        expense.id = UUID()
        expense.title = "Coffee"
        expense.amount = 3.5
        expense.date = Date()

        let exp = expectation(description: "sync")
        manager.sync(expenses: [expense]) { error in
            XCTAssertNil(error)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(mockDB.savedRecords.count, 1)
        XCTAssertEqual(mockDB.savedRecords.first?["title"] as? String, "Coffee")
    }

    func testFetchUpdatesMergesRecords() throws {
        let mockDB = MockDatabase()
        let context = PersistenceController(inMemory: true).container.viewContext
        let manager = CloudSyncManager(database: mockDB, context: context)

        let recordID = CKRecord.ID(recordName: UUID().uuidString)
        let record = CKRecord(recordType: "Expense", recordID: recordID)
        record["title"] = "Tea" as CKRecordValue
        record["amount"] = 2.0 as CKRecordValue
        record["date"] = Date() as CKRecordValue
        mockDB.queryResults = [record]

        let exp = expectation(description: "fetch")
        manager.fetchUpdates { error in
            XCTAssertNil(error)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)

        let req: NSFetchRequest<Expense> = Expense.fetchRequest()
        let results = try context.fetch(req)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Tea")
    }
}
#endif
