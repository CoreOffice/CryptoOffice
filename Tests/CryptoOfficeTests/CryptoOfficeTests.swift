// Copyright 2020 CoreOffice contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@testable import CryptoOffice
import XCTest
import ZIPFoundation

final class CryptoOfficeTests: XCTestCase {
  func testWorkbook() throws {
    let url = URL(fileURLWithPath: #file)
      .deletingLastPathComponent()
      .appendingPathComponent("TestWorkbook.xlsx")

    let file = try CryptoOfficeFile(path: url.path)
    XCTAssertEqual(
      file.encryptionInfo.keyEncryptors.keyEncryptor[0].encryptedKey.hashAlgorithm,
      "SHA512"
    )

    let data = try file.decrypt(password: "pass")
    let archive = try XCTUnwrap(Archive(data: data, accessMode: .read))
    XCTAssertEqual(Array(archive).count, 10)
  }
}
