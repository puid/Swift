//
//  Puid.EntropySystem.CSPrng
//
//  MIT License: See project LICENSE.txt
//

import Foundation

#if canImport(Darwin)
import Darwin
typealias EntropyStatus = OSStatus
#elseif canImport(Glibc)
import Glibc
typealias EntropyStatus = Int32
#endif


extension Puid.Entropy.System {
  struct CSPrng: PuidEntropySource {
    /// Fill the supplied `Data` with `count`bytes at the specified `offset` using sytem cryptographically strong bytes
    ///
    /// - Parameter into: Data into which the bytes are copied
    /// - Parameter count: The number of bytes to generate
    /// - Parameter offset: Offset byte at which to begin copy
    ///
    /// - Throws: `PuidError.bytesFailure(status:)` if system entropy is not available
    func bytes(into data: inout Data, count: Int, offset: Int) throws {
#if os(macOS)
      let status = data.withUnsafeMutableBytes {
        SecRandomCopyBytes(kSecRandomDefault, count, $0.baseAddress! + offset)
      }
      guard status == errSecSuccess else {
        throw PuidError.bytesFailure(status: status)
      }
#elseif os(Linux)
      (offset..<(offset+count)).forEach { ndx in
        data[ndx] = UInt8.random(in: UInt8.min ... UInt8.max)
      }
#endif
    }
    
    func method() -> String {
#if os(macOS)
      "SecRandomCopyBytes"
#elseif os(Linux)
      "UInt8.random"
#endif
    }
  }
}
