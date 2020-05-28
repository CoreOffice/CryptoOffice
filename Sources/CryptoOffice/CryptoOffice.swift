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

import Crypto
import Foundation
import OLEKit

struct AgileInfo: Decodable {
  struct KeyData: Decodable {
    let saltValue: Data
    let hashAlgorihm: String
  }

  struct Password: Decodable {
    let spinCount: Int
    let encryptedKeyValue: Data
    let saltValue: Data
    let hashAlgorihm: String
    let keyBits: Int
  }

  let keyData: KeyData
  let password: Password
}

public enum EncryptionType {
  case agile
}

public final class CryptoOfficeFile {
  private let oleFile: OLEFile

  public let encryptionType: EncryptionType

  public init(path: String) throws {
    do {
      oleFile = try OLEFile(path)
      guard let entry = oleFile.root.children.first(where: { $0.name == "EncryptionInfo" })
      else { throw CryptoOfficeError.fileIsNotEncrypted(path: path) }

      let stream = try oleFile.stream(entry)

      let major: UInt16 = stream.read()
      let minor: UInt16 = stream.read()
      switch (major, minor) {
      case (4, 4):
        encryptionType = .agile
      case (2, 2), (3, 2), (4, 2):
        throw CryptoOfficeError.standardEncryptionNotSupported
      case (3, 3), (4, 3):
        throw CryptoOfficeError.extensibleEncryptionNotSupported
      default:
        throw CryptoOfficeError.unknownEncryptionVersion(major: major, minor: minor)
      }
    } catch let OLEError.fileIsNotOLE(path) {
      throw CryptoOfficeError.fileIsNotEncrypted(path: path)
    }
  }
}
