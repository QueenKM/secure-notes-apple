// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SecureNotesApple",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "SecureNotesCore",
            targets: ["SecureNotesCore"]
        )
    ],
    targets: [
        .target(
            name: "SecureNotesCore"
        ),
        .testTarget(
            name: "SecureNotesCoreTests",
            dependencies: ["SecureNotesCore"]
        )
    ]
)
