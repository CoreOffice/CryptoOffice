# CryptoOffice

## Office Open XML (OOXML) formats (.xlsx, .docx, .pptx) decryption for Swift

CryptoOffice is a library for decrypting Microsoft Office formats that utilise
[ECMA-376 agile encryption](https://docs.microsoft.com/en-us/openspecs/office_file_formats/ms-offcrypto/cab78f5c-9c17-495e-bea9-032c63f02ad8). It should be used in conjuction
with libraries that allow parsing decrypted data, such as
[CoreXLSX](https://github.com/CoreOffice/CoreXLSX).

## Example

Using CryptoOffice is easy:

1. Add `import CryptoOffice` at the top of a relevant Swift source file.
2. Use `CryptoOfficeFile(path: String)` to create a new instance with a path to your encrypted file.
3. Call `decrypt(password: String)` on it to get decrypted data.
4. Parse the decrypted data with a library appropriate for that format
   ([CoreXLSX](https://github.com/CoreOffice/CoreXLSX) in this example).

```swift
import CoreXLSX
import CryptoOffice

let encryptedFile = try CryptoOfficeFile(path: "./categories.xlsx")
let decryptedData = try encryptedFile.decrypt(password: "pass")
let xlsx = try XLSXFile(data: decryptedData)

for path in try xlsx.parseWorksheetPaths() {
  let worksheet = try xlsx.parseWorksheet(at: path)
  for row in worksheet.data?.rows ?? [] {
    for c in row.cells {
      print(c)
    }
  }
}
```

## Requirements

**Apple Platforms**

- Xcode 11.0 or later
- Swift 5.1 or later
- iOS 13.0 / watchOS 6.0 / tvOS 13.0 / macOS 10.15 or later deployment targets

**Linux**

- Swift 5.1 or later

## Installation

### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager/) is a tool for
managing the distribution of Swift code. It’s integrated with the Swift build
system to automate the process of downloading, compiling, and linking
dependencies on all platforms.

Once you have your Swift package set up, adding `CryptoOffice` as a dependency is as
easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
  .package(url: "https://github.com/CoreOffice/CryptoOffice.git",
           .upToNextMinor(from: "0.1.1"))
]
```

If you're using CryptoOffice in an app built with Xcode, you can also add it as a direct
dependency [using Xcode's
GUI](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

## Contributing

### Coding Style

This project uses [SwiftFormat](https://github.com/nicklockwood/SwiftFormat)
and [SwiftLint](https://github.com/realm/SwiftLint) to
enforce formatting and coding style. We encourage you to run SwiftFormat within
a local clone of the repository in whatever way works best for you either
manually or automatically via an [Xcode
extension](https://github.com/nicklockwood/SwiftFormat#xcode-source-editor-extension),
[build phase](https://github.com/nicklockwood/SwiftFormat#xcode-build-phase) or
[git pre-commit
hook](https://github.com/nicklockwood/SwiftFormat#git-pre-commit-hook) etc.

To guarantee that these tools run before you commit your changes on macOS, you're encouraged
to run this once to set up the [pre-commit](https://pre-commit.com/) hook:

```
brew bundle # installs SwiftLint, SwiftFormat and pre-commit
pre-commit install # installs pre-commit hook to run checks before you commit
```

Refer to [the pre-commit documentation page](https://pre-commit.com/) for more details
and installation instructions for other platforms.

SwiftFormat and SwiftLint also run on CI for every PR and thus a CI build can
fail with incosistent formatting or style. We require CI builds to pass for all
PRs before merging.

### Code of Conduct

This project adheres to the [Contributor Covenant Code of
Conduct](https://github.com/CoreOffice/CryptoOffice/blob/master/CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code. Please report
unacceptable behavior to coreoffice@desiatov.com.

## License

CryptoOffice is licensed under the Apache License, Version 2.0 (the "License");
you may not use this library except in compliance with the License.
See the
[LICENSE](https://github.com/CoreOffice/CryptoOffice/blob/master/LICENSE) file
for more info.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

CryptoOffice uses [swift-crypto](https://github.com/apple/swift-crypto/),
[CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift),
[XMLCoder](https://github.com/MaxDesiatov/XMLCoder),
[OLEKit](https://github.com/CoreOffice/OLEKit) and
[ZIPFoundation](https://github.com/weichsel/ZIPFoundation). The latter is only
a dependency of CryptoOffice's test suite. Please check the respective projects
for their actual licensing information.
