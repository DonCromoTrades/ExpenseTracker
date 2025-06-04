// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExpenseTracker",
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // The main executable target for the application.
        .executableTarget(
            name: "ExpenseTracker"),

        // Test suite target using XCTest
        .testTarget(
            name: "ExpenseTrackerTests",
            dependencies: ["ExpenseTracker"]),
    ]
)
