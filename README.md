# ExpenseTracker

ExpenseTracker is an app designed to help you scan receipts, organize expenses, and visualize spending over time. The code base is structured into several Swift modules to keep functionality isolated:

- **ReceiptScanner** – a Vision-based utility for extracting text from receipt images.
- **ExpenseStore** – a Core Data stack with an `Expense` model for persisting transactions.
- **DataVisualizer** – minimal SwiftUI views to render charts from stored data.

## Goals

- **Receipt OCR**: Use optical character recognition (OCR) to extract details from receipts.
- **Expense organization**: Categorize each expense for easy tracking.
- **Monthly visualization**: Summarize spending with monthly charts.

## Building the Project

This repository contains both a Swift Package and an Xcode project. If you only
need the command-line build of the package, run:

```bash
swift build
```

For the iOS application, open `ExpenseTracker.xcodeproj` in Xcode 14 or later,
ensure you have the iOS 15 SDK installed, select a simulator (or a connected
device) and press **Run**.

## Running on a Device

- Connect an iPhone or iPad and select it as the target device in Xcode.
- Ensure the deployment target of the project matches or is lower than your device's iOS version.

## User Setup

The app supports signing in with Apple or entering a local name. When building for iOS, enable the **Sign in with Apple** capability in the Xcode project if you would like to use Apple's authentication. A simple local sign-in flow is also provided for simulator testing.

To synchronize expenses across devices, enable the **iCloud** capability with CloudKit. Add the container identifier `iCloud.com.example.ExpenseTracker` to `ExpenseTracker.entitlements` and set the same value for `CloudKitContainerIdentifier` in `Info.plist`. The app will request iCloud permission on first launch and use `CloudSyncManager` to push local changes and fetch updates automatically.

## Contributing and Testing

Contributions are welcome! Fork the repository, create a feature branch, and open a pull request.

To run tests, use the Xcode menu `Product` > `Test` or run the following command from the project directory:
```bash
swift test
```

## Recurring Expenses and Budgets

Two additional Core Data entities help automate common spend tracking tasks:

- **RecurringExpense** – stores expenses that repeat on a schedule. Each record
  tracks an `id`, `title`, `amount`, the `nextDate` the expense will occur and
  a `frequency` (for example monthly or weekly).
- **Budget** – defines spending limits. A budget has an `id`, a `category`, the
  allowed `monthlyLimit` and the amount already `spent` during the current
  period.

### Fetching recurring expenses

```swift
import CoreData

let context = PersistenceController.shared.container.viewContext
let request: NSFetchRequest<RecurringExpense> = RecurringExpense.fetchRequest()
let recurring = try context.fetch(request)
```

### Computing remaining budget

```swift
let budgetRequest: NSFetchRequest<Budget> = Budget.fetchRequest()
let budgets = try context.fetch(budgetRequest)

if let groceries = budgets.first(where: { $0.category == "Groceries" }) {
    let remaining = groceries.monthlyLimit - groceries.spent
    print("Remaining for groceries: \(remaining)")
}
```


## License

This project is licensed under the [MIT License](LICENSE).


## Disclaimers

- The OCR process may occasionally misread text on receipts.
- ExpenseTracker is a personal finance tool and does not constitute professional financial advice.
- User data is stored locally on the device or synced privately with iCloud if enabled.
