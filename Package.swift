// swift-tools-version: 5.8

import PackageDescription

let package = Package(
  name: "assimp",
  products: [
    .library(name: "Assimp", type: .static, targets: ["Assimp"])
  ],
  targets: [
    .target(
      name: "Assimp",
      dependencies: ["CAssimp", "CAssimpShim"],
      swiftSettings: [
        .unsafeFlags(["-enable-library-evolution"])
      ]
    ),
    .target(
      name: "CAssimpShim",
      dependencies: ["CAssimp"],
      path: "Sources/CAssimpShim",
      publicHeadersPath: "include",
      cxxSettings: [
        .headerSearchPath("include")
      ],
      linkerSettings: [
        .linkedLibrary("assimp")
      ]
    ),
    .testTarget(
      name: "AssimpTests",
      dependencies: ["Assimp"]
    ),
    .systemLibrary(
      name: "CAssimp",
      path: "Sources/CAssimp",
      pkgConfig: "assimp",
      providers: [
        .brew(["assimp"]),
        .apt(["libassimp-dev"]),
      ]
    ),
  ],
  cxxLanguageStandard: .gnucxx17
)
