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

public enum CryptoOfficeError: Error {
  case standardEncryptionNotSupported
  case fileIsNotEncrypted(path: String)
  case cantEncodePassword(encoding: String.Encoding)
  case extensibleEncryptionNotSupported
  case encryptedKeyNotSpecifiedForAgileEncryption
  case unknownEncryptionVersion(major: UInt16, minor: UInt16)
  case hashAlgorithmNotSupported(actual: String?, expected: [String])
}
