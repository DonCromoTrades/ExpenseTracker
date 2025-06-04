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

1. Open `ExpenseTracker.xcodeproj` in Xcode 14 or later.
2. Ensure you have the iOS 15 SDK or later installed.
3. Select an iOS simulator (or a connected device) and press **Run**.

## Running on a Device

- Connect an iPhone or iPad and select it as the target device in Xcode.
- Ensure the deployment target of the project matches or is lower than your device's iOS version.

## Contributing and Testing

Contributions are welcome! Fork the repository, create a feature branch, and open a pull request.

To run tests, use the Xcode menu `Product` > `Test` or run the following command from the project directory:

```bash
xcodebuild test -scheme ExpenseTracker -destination 'platform=iOS Simulator,name=iPhone 14'
```

