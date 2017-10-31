# FyydKit

[![CocoaPods](https://img.shields.io/cocoapods/p/FyydKit.svg)]()
[![Build Status](https://travis-ci.org/funkenstrahlen/FyydKit.svg?branch=master)](https://travis-ci.org/funkenstrahlen/FyydKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/v/FyydKit.svg)](https://cocoapods.org/pods/FyydKit)

FyydKit is an implementation of the [fyyd API](https://fyyd.de) in Swift. The complete [fyyd API documentation can be found here](https://github.com/eazyliving/fyyd-api). Not all API functionality is currently supported by this framework.

## Contents

* [Requirements](#requirements)
* [Installation](#installation)
* [Configuration](#configuration)
* [Examples](#examples)
* [FAQ](#faq)
* [Changelog](#changelog)
* [Contributing](#contributing)
* [License](#license)

## Requirements

- iOS 10.0+ / Mac OS X 10.12+ / tvOS 10.0+ / watchOS 3.0+
- Xcode 9.0+

## Installation

FyydKit can be installed using [CocoaPods](http://cocoapods.org/), [Carthage](https://github.com/Carthage/Carthage), [Swift Package Manager](https://swift.org/package-manager/).

### CocoaPods

To install CocoaPods, run:

```bash
$ gem install cocoapods
```

Then create a `Podfile` with the following contents:

```ruby
platform :ios, '10.0'
use_frameworks!

target 'YOUR_TARGET_NAME' do
  pod 'FyydKit', '~> 1.0.0'
end
```

Finally, run the following command to install it:

```bash
$ pod install
```

### Carthage

To install Carthage, run (using Homebrew):

```bash
$ brew update
$ brew install carthage
```

Then add the following line to your `Cartfile`:

```
github "funkenstrahlen/FyydKit" ~> 1.0
```

### Swift Package Manager

Swift Package Manager requires Swift version 4.0 or higher. First, create a `Package.swift` file. It should look like:

```swift
dependencies: [
    .Package(url: "https://github.com/funkenstrahlen/FyydKit.git", from: "1.0.0")
]
```

`swift build` should then pull in and compile FyydKit for you to begin using.

## Configuration

Enable subscribe url schemes in your Info.plist!

## Examples

### Initialization



## FAQ



## Changelog

See [Github Releases](https://github.com/funkenstrahlen/FyydKit/releases) for a list of all changes and their corresponding versions.

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for guidelines to contribute back to FyydKit.

## License

FyydKit is released under the MIT license. See [LICENSE](LICENSE) for details.
