@_implementationOnly import CAssimp

extension String {
  init?(_ aiString: aiString) {
    let length = Int(aiString.length)
    guard length > 0 else {
      return nil
    }

    // Read exactly `length` bytes from the fixed-size inline buffer to avoid
    // relying on a trailing NUL, which may be omitted or optimized differently
    // in some builds. Decode as UTF-8.
    let result: String? = withUnsafeBytes(of: aiString.data) { rawBuffer in
      guard let baseAddress = rawBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
        return nil
      }
      return String(
        bytes: UnsafeBufferPointer(start: baseAddress, count: length),
        encoding: .utf8)
    }

    guard let result else { return nil }
    self = result
  }

  init?(bytes: UnsafeMutablePointer<Int8>, length: Int) {
    let bufferPtr = UnsafeMutableBufferPointer(
      start: bytes,
      count: length)

    let codeUnits: [UTF8.CodeUnit] =
      bufferPtr
      // .map { $0 > 0 ? $0 : Int8(0x20) } // this replaces all invalid characters with blank space
      .map { UTF8.CodeUnit($0) }

    self.init(decoding: codeUnits, as: UTF8.self)
  }
}
