// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Bolts",
    defaultLocalization: "en",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Bolts",
            targets: ["Bolts"]),
    ],
    targets: [
        .target(
            name: "Bolts",
            dependencies: [.target(name: "Bolts-iOS")],
            path: "Bolts",
            exclude: ["Info.plist"]
        ),
        .target(
            name: "Bolts-iOS",
            path: "Bolts-iOS"
        ),
//        .testTarget(
//            name: "Bolts-Tests",
//            dependencies: [.target(name: "Bolts-iOS")],
//            path: "BoltsTests",
//            exclude: ["BoltsTests-Info.plist"]
//        )
    ]
)
