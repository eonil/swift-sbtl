// swift-tools-version:4.0

import Foundation
import PackageDescription

let package = Package(
    name: "SBTL",
    products: [
        .library(name: "SBTL", targets: ["SBTL"]),
        .executable(name: "SBTMBenchmark", targets: ["SBTLBenchmark"]),
    ],
    targets: [
        .target(
            name: "SBTL",
            dependencies: [],
            path: "SBTL"),
        .target(
            name: "SBTLBenchmark",
            dependencies: ["SBTL"],
            path: "SBTLBenchmark"),
        .testTarget(
            name: "SBTLTest",
            dependencies: ["SBTL"],
            path: "SBTLTest"),
    ]
)
