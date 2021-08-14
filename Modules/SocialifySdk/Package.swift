// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SocialifySdk",
    platforms: [
            .macOS(.v10_15),
            .iOS(.v13),
            .watchOS(.v6),
            .tvOS(.v13),
        ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SocialifySdk",
            targets: ["SocialifySdk"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/Pengwius/BCryptSwift", from: "1.1.0"),
        .package(url: "https://github.com/puretears/SwiftRSA", from: "0.1.2"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", from: "5.0.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2"),
        .package(url: "https://github.com/bednarj4/SwiftyRSA", branch: "master"),
        .package(url: "https://github.com/socketio/socket.io-client-swift", branch: "master"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SocialifySdk",
            dependencies: ["BCryptSwift", "SwiftRSA", "SwiftyJSON", "KeychainAccess", "SwiftyRSA", .product(name: "SocketIO", package: "socket.io-client-swift")]),
        .testTarget(
            name: "SocialifySdkTests",
            dependencies: ["SocialifySdk"]),
    ]
)
