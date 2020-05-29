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
import CryptoSwift
import Foundation
import OLEKit

extension Crypto.Digest {
  var data: Data { Data(makeIterator()) }
}

struct AgileInfo: Decodable {
  struct KeyData: Decodable {
    let saltValue: Data
    let hashAlgorithm: String
  }

  struct EncryptedKey: Decodable {
    let spinCount: UInt32
    let encryptedKeyValue: Data
    let saltValue: Data
    let hashAlgorithm: String
    let keyBits: Int
  }

  struct KeyEncryptors: Decodable {
    struct KeyEncryptor: Decodable {
      let encryptedKey: EncryptedKey
    }

    let keyEncryptor: [KeyEncryptor]
  }

  let keyData: KeyData
  let keyEncryptors: KeyEncryptors

  func secretKey(password: String) throws -> [UInt8] {
    let block3 = Data([0x14, 0x6E, 0x0B, 0xE7, 0xAB, 0xAC, 0xD0, 0xD6])

    guard let encryptedKey = keyEncryptors.keyEncryptor.first?.encryptedKey else {
      throw CryptoOfficeError.encryptedKeyNotSpecifiedForAgileEncryption
    }

    let algorithm = encryptedKey.hashAlgorithm.lowercased()

    guard algorithm == "sha512" else {
      throw CryptoOfficeError.hashAlgorithmNotSupported(actual: algorithm, expected: ["sha512"])
    }
    guard let passwordData = password.data(using: .utf16LittleEndian)
    else { throw CryptoOfficeError.cantEncodePassword(encoding: .utf16LittleEndian) }

    // Initial round sha512(salt + password)
    var hash = SHA512.hash(data: encryptedKey.saltValue + passwordData)

    // Iteration of 0 -> spincount-1; hash = sha512(iterator + hash)
    for i in 0..<encryptedKey.spinCount {
      let spin = DataWriter()
      spin.write(i)
      hash = SHA512.hash(data: spin.data + hash.data)
    }

    hash = SHA512.hash(data: hash.data + block3)

    // truncate to bitsize
    let decryptionKey = hash.data[0..<(encryptedKey.keyBits / 8)].bytes

    let aes = try CryptoSwift.AES(
      key: decryptionKey,
      blockMode: CBC(iv: encryptedKey.saltValue.bytes),
      padding: .noPadding
    )
    let result = try aes.decrypt(encryptedKey.encryptedKeyValue.bytes)
    return result
  }

  func decrypt(_ reader: DataReader, secretKey: [UInt8]) throws -> Data {
    let segmentLength: UInt32 = 4096

    let totalSize: UInt32 = reader.read()
    let lastSegmentSize = totalSize % segmentLength

    reader.seek(toOffset: 8)

    var result = Data()
    let totalSegments = totalSize / segmentLength + (lastSegmentSize > 0 ? 1 : 0)

    for i in 0..<totalSegments {
      let segmentIndex = DataWriter()
      segmentIndex.write(i)

      let iv = (keyData.saltValue + segmentIndex.data).sha512()[0..<16].bytes
      let aes = try AES(key: secretKey, blockMode: CBC(iv: iv))

      let chunk: Data
      if i == totalSegments - 1 {
        chunk = reader.readDataToEnd()
      } else {
        chunk = reader.readData(ofLength: Int(segmentLength))
      }
      try result.append(Data(aes.decrypt(chunk.bytes)))
    }

    return result
  }
}
