// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExpenseTracker",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "ReceiptScanner", targets: ["ReceiptScanner"]),
        .library(name: "ExpenseStore", targets: ["ExpenseStore"]),
        .library(name: "DataVisualizer", targets: ["DataVisualizer"])
    ],
    targets: [
        .target(name: "ReceiptScanner"),
        .target(name: "ExpenseStore"),
        .target(name: "DataVisualizer", dependencies: ["ExpenseStore"]),
        .executableTarget(
            name: "ExpenseTracker",
            dependencies: ["ReceiptScanner", "ExpenseStore", "DataVisualizer"]),
        .testTarget(
            name: "ExpenseTrackerTests",
            dependencies: ["ExpenseTracker", "DataVisualizer", "ExpenseStore"]),
    ]
)
