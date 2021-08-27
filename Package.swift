// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UseDesk",
    platforms: [.iOS(.v10)],
    products: [
        .library(name: "UseDesk", targets: ["UseDesk"])
    ],
    dependencies: [
        .package(url: "https://github.com/socketio/socket.io-client-swift", from: "16.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        .package(url: "https://github.com/sendyhalim/Swime", from: "3.0.0"),
        .package(url: "https://github.com/erikkerber/Down/tree/ek/portable-framework", .branch("ek/portable-framework"))
    ],
    targets: [
        .target(
            name: "UseDesk",
            dependencies: [
                "Alamofire",
                "SocketIO",
                "Swime",
                "Down"
            ],
            path: "Core"
        )
    ],
    swiftLanguageVersions: [.v5]
)
