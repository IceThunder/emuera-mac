// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Emuera",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "emuera",
            targets: ["EmueraApp"]
        ),
        .library(
            name: "EmueraCore",
            targets: ["EmueraCore"]
        )
    ],
    dependencies: [],
    targets: [
        // Core Engine - 脚本解析和执行引擎
        .target(
            name: "EmueraCore",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
            ]
        ),

        // macOS Application - UI和系统服务
        .executableTarget(
            name: "EmueraApp",
            dependencies: ["EmueraCore"],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
            ]
            // Foundation and AppKit are automatically linked on macOS
        ),

        // Unit Tests
        .testTarget(
            name: "EmueraCoreTests",
            dependencies: ["EmueraCore"]
        ),

        .testTarget(
            name: "EmueraAppTests",
            dependencies: ["EmueraApp"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)