// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	 name: "ScheduleGridKit",
	  platforms: [
				  .macOS(.v13),
				  .iOS(.v16),
				  .watchOS(.v8)
			],
	 products: [
		  // Products define the executables and libraries produced by a package, and make them visible to other packages.
		  .library(
				name: "ScheduleGridKit",
				targets: ["ScheduleGridKit"]),
	 ],
	 dependencies: [
		.package(url: "https://github.com/bengottlieb/suite", from: "1.0.79"),
	 ],
	 targets: [
		  // Targets are the basic building blocks of a package. A target can define a module or a test suite.
		  // Targets can depend on other targets in this package, and on products in packages which this package depends on.
		  .target(name: "ScheduleGridKit", dependencies: [.product(name: "Suite", package: "Suite")]),
	 ]
)
