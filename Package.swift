// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CRest",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macOS(.v10_15),
        .macCatalyst(.v13)
    ],
    products: [
        .library(
            name: "CRest",
            targets: [
                "CRest"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: .init(5, 8, 0)),
        .package(url: "https://github.com/ayham-achami/CFoundation.git", branch: "mainline")
    ],
    targets: [
        .target(
            name: "CRest",
            dependencies: [
                "Alamofire",
                "CFoundation"
            ],
            path: "Sources",
            exclude: [
                "Info.plist"
            ]
        ),
        .testTarget(
            name: "CRestTests",
            dependencies: [
                "CRest"
            ],
            path: "CRestTests",
            exclude: [
                "Info.plist"
            ]
        ),
    ]
)

