//
// The MIT License (MIT)
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// Forked from mauriciosantos/Buckets-Swift/

import Foundation

/// A Bloom filter is a probabilistic set designed to check rapidly and memory-efficiently,
/// whether an element is definitely not in the set or may be in the set. The false
/// positive probability is provided at construction time.
///
/// Inserted elements must conform to the `BloomFilterType` protocol. Types already conforming
/// to the protocol include, but are not limited to: `Int`, `Double` and `String`.
public struct BloomFilter<T: BloomFilterType> {

  // MARK: Creating a BloomFilter

  /// Creates a Bloom filter with the expected number of elements and a default
  /// false positive probability of 3%.
  /// Inserting significantly more elements than specified will result a deterioration of the
  /// false positive probability.
  public init(expectedCount: Int) {
    self.init(expectedCount: expectedCount, FPP: Constants.DefaultFPP)
  }

  /// Creates a Bloom filter with the expected number of elements and
  /// expected false positive probability.
  /// Inserting significantly more elements than specified will result in a deterioration of the
  /// false positive probability.
  public init(expectedCount: Int, FPP: Double) {
    if expectedCount < 0 {
      fatalError("Can't construct a Bloom filter with expectedCount < 0")
    }
    if FPP <= 0.0 || FPP >= 1.0  {
      fatalError("Can't construct BloomFilter with false positive probability >= 1 or <= 0")
    }

    // See: http://en.wikipedia.org/wiki/Bloom_filter for calculations

    let n = Double(expectedCount)
    let m = n*log(1/FPP) / pow(log(2), 2)

    let bitArraySize = Int(m)
    bits = BitArray(repeating: false, count: bitArraySize)

    let k = (m/n) * log(2)
    numberOfHashFunctions = Int(ceil(k))

    self.FPP = FPP
  }

  // MARK: Querying a BloomFilter

  /// The expected false positive probability.
  /// In other words, the probability that `contains()` will erroneously return true.
  public let FPP: Double

  /// Returns the approximated number of elements in the bloom filter.
  public var roughCount: Int {
    let count = Double(bits.count)
    let bitsSetToOne = Double(bits.cardinality)
    let hashFunctions = Double(numberOfHashFunctions)

    let result = -count*log(1.0 - bitsSetToOne/count)/hashFunctions
    if !result.isFinite {
      return Int.max
    }
    return Int(min(result, Double(Int.max)))
  }

  /// Returns `true` if no element has been inserted into the Bloom filter.
  public var isEmpty: Bool {
    return bits.cardinality == 0
  }

  /// Returns `true` if the given element might be in the Bloom filter or false if 
  /// it's definitely not.
  public func contains(_ element: T) -> Bool {
    for i in 0..<numberOfHashFunctions {
      let hashFunction = hashFunctionWithIndex(i)
      let index = hashFunction(element)
      if !bits[index] {
        return false
      }
    }
    return true
  }

  // MARK: Adding and Removing Elements

  /// Inserts an element into the Bloom filter. All subsequent calls to
  /// `contains()` with the same element will return true.
  public mutating func insert(_ element: T) {
    for i in 0..<numberOfHashFunctions {
      let hashFunction = hashFunctionWithIndex(i)
      let index = hashFunction(element)
      bits[index] = true
    }
  }

  /// Removes all the elements from the Bloom filter.
  public mutating func removeAll() {
    bits = BitArray(repeating: false, count: bits.count)
  }

  // MARK: Private Properties and Helper Methods

  fileprivate var bits: BitArray

  /// Optimal number of hash functions.
  fileprivate let numberOfHashFunctions: Int

  /// Creates any number of hash functions on the fly using just 2 predefined ones.
  /// See http://en.wikipedia.org/wiki/Double_hashing
  fileprivate func hashFunctionWithIndex(_ index: Int) -> (T) -> Int {
    let i = UInt(index)

    // Hi(x) = H0(x) + i*H1(x) mod table.size

    return  {
      let bytes = $0.bytes
      return Int((fnv1(bytes) &+ i&*fnv1a(bytes)) % UInt(self.bits.count))
    }
  }
}

// MARK:- Constants

private struct Constants {
  static let DefaultFPP = 0.03
}

public protocol BloomFilterType {

  /// Returns a data representation of self.
  var bytes: Data {get}
}


extension Bool: BloomFilterType {
  public var bytes: Data {return bytesFromStruct(self)}
}
extension Double: BloomFilterType {
  public var bytes: Data {return bytesFromStruct(self)}
}
extension Float: BloomFilterType {
  public var bytes: Data {return bytesFromStruct(self)}
}
extension Int: BloomFilterType {
  public var bytes: Data {return bytesFromStruct(self)}
}
extension Int8: BloomFilterType {
  public var bytes: Data {return bytesFromStruct(self)}
}
extension Int16: BloomFilterType {
  public var bytes: Data {return bytesFromStruct(self)}
}
extension Int32: BloomFilterType {
  public var bytes: Data {return bytesFromStruct(self)}
}
extension Int64: BloomFilterType {
  public var bytes: Data {return bytesFromStruct(self)}
}
extension UInt: BloomFilterType {
  public var bytes: Data {return bytesFromStruct(self)}
}
extension UInt8: BloomFilterType {
  public var bytes: Data {return bytesFromStruct(self)}
}
extension UInt16: BloomFilterType {
  public var bytes: Data {return bytesFromStruct(self)}
}
extension UInt32: BloomFilterType {
  public var bytes: Data {return bytesFromStruct(self)}
}
extension UInt64: BloomFilterType {
  public var bytes: Data {return bytesFromStruct(self)}
}
extension String: BloomFilterType {
  public var bytes: Data {return self.data(using: .utf8)!}
}

private func bytesFromStruct<T>(_ value: T) -> Data {
  var data = Data()
  var input = value
  let buffer = UnsafeBufferPointer(start: &input, count: 1)
  data.append(buffer)
  return data
}


struct FNVConstants {

  // FNV parameters

  #if arch(arm64) || arch(x86_64) // 64-bit

  static let OffsetBasis: UInt = 14695981039346656037
  static let FNVPrime: UInt = 1099511628211

  #else // 32-bit

  static let OffsetBasis: UInt = 2166136261
  static let FNVPrime: UInt = 16777619

  #endif
}

// MARK:- Public API

/// Calculates FNV-1 hash from a raw byte sequence, such as an array.
func fnv1<S:Sequence>(_ bytes: S) -> UInt where S.Iterator.Element == UInt8 {
  var hash = FNVConstants.OffsetBasis
  for byte in bytes {
    hash = hash &* FNVConstants.FNVPrime // &* means multiply with overflow
    hash ^= UInt(byte)
  }
  return hash
}

/// Calculates FNV-1a hash from a raw byte sequence, such as an array.
func fnv1a<S:Sequence>(_ bytes: S) -> UInt where S.Iterator.Element == UInt8 {
  var hash = FNVConstants.OffsetBasis
  for byte in bytes {
    hash ^= UInt(byte)
    hash = hash &* FNVConstants.FNVPrime
  }
  return hash
}
