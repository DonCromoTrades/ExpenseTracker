# ExpenseTracker

Starter SwiftUI project for tracking expenses with OCR capabilities.

## Modules
- `ReceiptCapture`: Processes receipt images using the Vision framework.
- `DataModel`: CoreData stack for persisting expenses.
- `ChartsModule`: Basic charts for monthly summaries (requires iOS 16+).
- `ExpenseTrackerApp`: SwiftUI entry point that ties everything together.

## Xcode Project
An Xcode project can be generated using the included Ruby script:

```bash
ruby generate_project.rb
```

Open `ExpenseTracker.xcodeproj` in Xcode to run the app on iOS.
