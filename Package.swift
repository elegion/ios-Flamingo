// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "Flamingo",
    platforms: [.iOS(.v9)],
    products: [
        .library(name: "Flamingo", targets: ["Flamingo"])
    ],
    targets: [
        .target(
            name: "Flamingo",
            path: "Source"
        ),
    ]
)