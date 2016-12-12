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

import Foundation

/// A Multiset (sometimes called a bag) is a special kind of set in which
/// members are allowed to appear more than once. It's possible to convert a multiset
/// to a set: `let set = Set(multiset)`
///
/// Conforms to `Sequence`, `ExpressibleByArrayLiteral` and
///  `Hashable`.
public struct Bag<T: Hashable> {

  // MARK: Creating a Multiset

  /// Constructs an empty multiset.
  public init() {}

  /// Constructs a multiset from a sequence, such as an array.
  public init<S: Sequence>(_ elements: S) where S.Iterator.Element == T{
    for e in elements {
      insert(e)
    }
  }

  // MARK: Querying a Multiset

  /// Number of elements stored in the multiset, including multiple copies.
  public fileprivate(set) var count = 0

  /// Returns `true` if and only if `count == 0`.
  public var isEmpty: Bool {
    return count == 0
  }

  /// Number of distinct elements stored in the multiset.
  public var distinctCount: Int {
    return members.count
  }

  /// A sequence containing the multiset's distinct elements.
  public var distinctElements: AnySequence<T> {
    return AnySequence(members.keys)
  }

  /// Returns `true` if the multiset contains the given element.
  public func contains(_ element: T) -> Bool {
    return members[element] != nil
  }

  /// Returns the number of occurrences  of an element in the multiset.
  public func count(_ element: T) -> Int {
    return members[element] ?? 0
  }

  // MARK: Adding and Removing Elements

  /// Inserts a single occurrence of an element into the multiset.
  public mutating func insert(_ element: T) {
    insert(element, occurrences: 1)
  }

  /// Inserts a number of occurrences of an element into the multiset.
  public mutating func insert(_ element: T, occurrences: Int) {
    precondition(occurrences >= 1, "Invalid number of occurrences")
    let previousNumber = members[element] ?? 0
    members[element] = previousNumber + occurrences
    count += occurrences
  }

  /// Removes a single occurrence of an element from the multiset, if present.
  public mutating func remove(_ element: T) {
    return remove(element, occurrences: 1)
  }

  /// Removes a number of occurrences of an element from the multiset.
  /// If the multiset contains fewer than this number of occurrences to begin with,
  /// all occurrences will be removed.
  public mutating func remove(_ element: T, occurrences: Int) {
    precondition(occurrences >= 1, "Invalid number of occurrences")
    if let currentOccurrences = members[element] {
      let nRemoved = [currentOccurrences, occurrences].min()!
      count -= nRemoved
      let newOcurrencies = currentOccurrences - nRemoved
      if newOcurrencies == 0 {
        members.removeValue(forKey: element)
      } else {
        members[element] = newOcurrencies
      }
    }
  }

  /// Removes all occurrences of an element from the multiset, if present.
  public mutating func removeAllOf(_ element: T) {
    let ocurrences = count(element)
    return remove(element, occurrences: ocurrences)
  }

  /// Removes all the elements from the multiset, and by default
  /// clears the underlying storage buffer.
  public mutating func removeAll(keepingCapacity keep: Bool = false) {
    members.removeAll(keepingCapacity: keep)
    count = 0
  }

  // MARK: Private Properties and Helper Methods

  /// Internal dictionary holding the elements.
  fileprivate var members = [T: Int]()
}

// MARK: -

extension Bag: Sequence {

  // MARK: Sequence Protocol Conformance

  /// Provides for-in loop functionality. Generates multiple occurrences per element.
  ///
  /// - returns: A generator over the elements.
  public func makeIterator() -> AnyIterator<T> {
    var keyValueGenerator = members.makeIterator()
    var elementCount = 0
    var element : T? = nil
    return AnyIterator {
      if elementCount > 0 {
        elementCount -= 1
        return element
      }
      let nextTuple = keyValueGenerator.next()
      element = nextTuple?.0
      elementCount = nextTuple?.1 ?? 1
      elementCount -= 1
      return element
    }
  }
}

extension Bag: CustomStringConvertible {

  // MARK: CustomStringConvertible Protocol Conformance

  /// A string containing a suitable textual
  /// representation of the multiset.
  public var description: String {
    return "[" + map{"\($0)"}.joined(separator: ", ") + "]"
  }
}

extension Bag: ExpressibleByArrayLiteral {

  // MARK: ExpressibleByArrayLiteral Protocol Conformance

  /// Constructs a multiset using an array literal.
  /// Unlike a set, multiple copies of an element are inserted.
  public init(arrayLiteral elements: T...) {
    self.init(elements)
  }
}

extension Bag: Hashable {

  // MARK: Hashable Protocol Conformance

  /// The hash value.
  /// `x == y` implies `x.hashValue == y.hashValue`
  public var hashValue: Int {
    var result = 3
    result = (31 ^ result) ^ distinctCount
    result = (31 ^ result) ^ count
    for element in self {
      result = (31 ^ result) ^ element.hashValue
    }
    return result
  }
}

// MARK: Multiset Equatable Conformance

/// Returns `true` if and only if the multisets contain the same number of occurrences per element.
public func ==<T>(lhs: Bag<T>, rhs: Bag<T>) -> Bool {
  if lhs.count != rhs.count || lhs.distinctCount != rhs.distinctCount {
    return false
  }
  for element in lhs {
    if lhs.count(element) != rhs.count(element) {
      return false
    }
  }
  return true
}
