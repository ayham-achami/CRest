// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CRest",
    platforms: [.iOS(.v13), .macCatalyst(.v13), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CRest",
            targets: ["CRest"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "Alamofire", url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.2"),
        .package(name: "CFoundation", url: "https://github.com/ayham-achami/CFoundation.git", .branch("mainline"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CRest",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "CFoundation", package: "CFoundation")
            ],
            path: "Sources",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "CRestTests",
            dependencies: ["CRest"],
            path: "CRestTests",
            exclude: ["Info.plist"]),
    ]
)

