// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "ExpenseTracker",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "ReceiptCapture", targets: ["ReceiptCapture"]),
        .library(name: "DataModel", targets: ["DataModel"]),
        .library(name: "ChartsModule", targets: ["ChartsModule"]),
        .executable(name: "ExpenseTrackerApp", targets: ["ExpenseTrackerApp"])
    ],
    targets: [
        .target(
            name: "ReceiptCapture",
            dependencies: []),
        .target(
            name: "DataModel",
            dependencies: []),
        .target(
            name: "ChartsModule",
            dependencies: []),
        .executableTarget(
            name: "ExpenseTrackerApp",
            dependencies: ["ReceiptCapture", "DataModel", "ChartsModule"])
    ]
)
