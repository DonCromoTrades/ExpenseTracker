# ExpenseTracker

ExpenseTracker is an app designed to help you scan receipts, organize expenses, and visualize spending over time.

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

## Contributing and Testing

Contributions are welcome! Fork the repository, create a feature branch, and open a pull request.

To run tests, use the Xcode menu `Product` > `Test` or run the following command from the project directory:

```bash
xcodebuild test -scheme ExpenseTracker -destination 'platform=iOS Simulator,name=iPhone 14'
```

