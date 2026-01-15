// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KKPinView",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "KKPinView",
            targets: ["KKPinView"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "KKPinView",
            path: "KKPinView/Sources/KKPinView"
        ),
        .testTarget(
            name: "KKPinViewTests",
            dependencies: ["KKPinView"],
            path: "KKPinView/Tests/KKPinViewTests"
        ),
    ]
)
