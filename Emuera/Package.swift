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
    dependencies: [
    ],
    targets: [
        // Core Engine - 脚本解析和执行引擎
        .target(
            name: "EmueraCore",
            dependencies: [],
            path: "Sources/EmueraCore",
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
            path: "Sources/EmueraApp",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
            ],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-framework", "-Xlinker", "AppKit"]),
                .unsafeFlags(["-Xlinker", "-framework", "-Xlinker", "Foundation"]),
                .unsafeFlags(["-Xlinker", "-framework", "-Xlinker", "Cocoa"]),
            ]
        ),

        // Unit Tests
        .testTarget(
            name: "EmueraCoreTests",
            dependencies: ["EmueraCore"],
            path: "Tests/EmueraCoreTests"
        ),

        .testTarget(
            name: "EmueraAppTests",
            dependencies: ["EmueraApp"],
            path: "Tests/EmueraAppTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)