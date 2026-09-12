// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "CalculatorCore",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [.library(name: "CalculatorCore", targets: ["CalculatorCore"])],
    targets: [
        .target(name: "CalculatorCore", path: "Calculator", exclude: ["CalculatorApp.swift", "ContentView.swift"], sources: ["Calculator.swift"]),
        .testTarget(name: "CalculatorCoreTests", dependencies: ["CalculatorCore"], path: "Tests", exclude: ["generate-fixtures.cjs"], resources: [.copy("fixtures.json")])
    ]
)
