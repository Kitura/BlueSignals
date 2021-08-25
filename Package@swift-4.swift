// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

/**
 * Copyright IBM Corporation and the Kitura project authors 2016-2020
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import PackageDescription

#if os(Linux) || os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

let package = Package(
        name: "Signals",
        products: [
            // Products define the executables and libraries produced by a package, and make them visible to other packages.
            .library(
                    name: "Signals",
                    type: .dynamic,
                    targets: ["Signals"]
            )
        ],
        targets: [
            .target(
                    name: "Signals",
                    exclude: ["Signals.xcodeproj", "README.md", "Sources/Info.plist", "Sources/Signals.h", "Tests"]
            ),
            .target(
                    name: "Example",
                    dependencies: ["Signals"]
            ),
        ]
)

#else

fatalError("Unsupported OS")

#endif
