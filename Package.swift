// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "CRest",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .macOS(.v12),
        .watchOS(.v6),
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
        .package(url: "https://github.com/realm/SwiftLint", from: "0.53.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: .init(5, 8, 0)),
        .package(url: "https://github.com/ayham-achami/CFoundation.git", revision: "1f2b721a29c9cba5202a3c4389a702033f7f7373")
    ],
    targets: [
        .macro(
            name: "CRestMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            plugins: [
                .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
            ]
        ),
        .target(
            name: "CRest",
            dependencies: [
                "Alamofire",
                "CFoundation",
                "CRestMacros"
            ],
            plugins: [
                .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
            ]
        ),
        .executableTarget(
            name: "CRestClient",
            dependencies: [
                "CRest"
            ],
            plugins: [
                .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
            ]
        ),
        .testTarget(
            name: "CRestTests",
            dependencies: [
                "CRest"
            ],
            path: "CRestTests",
            plugins: [
                .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)

for target in package.targets {
  var settings = target.swiftSettings ?? []
  settings.append(.enableExperimentalFeature("StrictConcurrency=minimal"))
  target.swiftSettings = settings
}
