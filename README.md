# JMCarouselView
JMCarouselView

Installation with Swift Package Manager (Xcode 11+)

Swift Package Manager (SwiftPM) is a tool for managing the distribution of Swift code as well as C-family dependency. From Xcode 11, SwiftPM got natively integrated with Xcode.

JMCarouselView support SwiftPM from version 5.9.0. To use SwiftPM, you should use Xcode 11 to open your project. Click File -> Swift Packages -> Add Package Dependency, enter JMCarouselView repo's URL. Or you can login Xcode with your GitHub account and just type JMCarouselView to search.

After select the package, you can choose the dependency type (tagged version, branch or commit). Then Xcode will setup all the stuff for you.

If you're a framework author and use JMCarouselView as a dependency, update your Package.swift file:

let package = Package(
    dependencies: [
        .package(url: "https://github.com/jigsapple/JMCarouselView.git", from: "1.0.0")
    ],
    // ...
)
