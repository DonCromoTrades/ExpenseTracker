import Foundation
import ExpenseStore
import CoreData

final class SyncController: ObservableObject {
    private let persistence = PersistenceController.shared
    private let manager: CloudSyncManager

    @Published var lastError: Error?

    init() {
        self.manager = CloudSyncManager()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextDidSave(_:)),
                                               name: .NSManagedObjectContextDidSave,
                                               object: persistence.container.viewContext)
    }

    @objc private func contextDidSave(_ note: Notification) {
        syncExpenses()
    }

    func fetch() {
        manager.fetchUpdates { [weak self] error in
            if let err = error {
                print("Fetch error: \(err)")
                DispatchQueue.main.async { self?.lastError = err }
            }
        }
    }

    func syncExpenses() {
        let context = persistence.container.viewContext
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        do {
            let expenses = try context.fetch(request)
            manager.sync(expenses: expenses) { [weak self] error in
                if let err = error {
                    print("Sync error: \(err)")
                    DispatchQueue.main.async { self?.lastError = err }
                }
            }
        } catch {
            print("Sync fetch error: \(error)")
            DispatchQueue.main.async { self.lastError = error }
        }
    }
}
