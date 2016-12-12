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
//  Forked from https://github.com/oisdk/SwiftDataStructures
//

import Foundation

public enum Color { case r, b }

/// A red-black binary search tree. Adapted from Airspeed Velocity's implementation,
/// Chris Okasaki's Purely Functional Data Structures, and Stefan Kahrs' Red-black RedBlackTrees
// with types, which is implemented in the Haskell standard library.
public enum RedBlackTree<Element: Comparable> : Equatable {
  case empty
  indirect case node(Color,RedBlackTree<Element>,Element,RedBlackTree<Element>)
}

public func ==<E : Comparable>(lhs: RedBlackTree<E>, rhs: RedBlackTree<E>) -> Bool {
  return lhs.elementsEqual(rhs)
}

// MARK: Initializers

extension RedBlackTree : ExpressibleByArrayLiteral {

  /// Create an empty `RedBlackTree`.
  public init() { self = .empty }

  fileprivate init(
    _ x: Element,
    color: Color = .b,
    left: RedBlackTree<Element> = .empty,
    right: RedBlackTree<Element> = .empty
    ) {
    self = .node(color, left, x, right)
  }

  /// Create a `RedBlackTree` from a sequence
  public init<S : Sequence>(_ seq: S) where S.Iterator.Element == Element {
    self.init()
    for x in seq { insert(x) }
  }

  /// Create a `RedBlackTree` of `elements`
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

extension RedBlackTree: CustomDebugStringConvertible {

  /// A description of `self`, suitable for debugging
  public var debugDescription: String {
    return Array(self).debugDescription
  }
}

// MARK: Properties

extension RedBlackTree {

  /// Returns the smallest element in `self` if it's present, or `nil` if `self` is empty
  ///- Complexity: O(*log n*)
  public var first: Element? {
    return minElement()
  }

  /// Returns the largest element in `self` if it's present, or `nil` if `self` is empty
  ///- Complexity: O(*log n*)
  public var last: Element? {
    return maxElement()
  }

  /// Returns `true` iff `self` is empty
  public var isEmpty: Bool {
    return self == .empty
  }

  /// Returns the number of elements in `self`
  ///- Complexity: O(`count`)
  public var count: Int {
    guard case let .node(_, l, _, r) = self else { return 0 }
    return 1 + l.count + r.count
  }
}

// MARK: Balance

internal enum RedBlackTreeBalance {
  case balanced(blackHeight: Int)
  case unBalanced
}

extension RedBlackTree {
  internal var isBalanced: Bool {
    switch balance {
    case .balanced: return true
    case .unBalanced: return false
    }
  }

  internal var color: Color {
    if case .node(.r, _, _, _) = self { return .r }
    return .b
  }

  internal var balance: RedBlackTreeBalance {
    guard case let .node(c, l, _, r) = self else { return .balanced(blackHeight: 1) }
    if
      case let .node(_, _, lx, _) = l,
      case let .node(_, _, rx, _) = r
      , lx >= rx { return .unBalanced }
    guard
      case let .balanced(x) = l.balance,
      case let .balanced(y) = r.balance
      , x == y else { return .unBalanced }
    if case .b = c { return .balanced(blackHeight: x + 1) }
    guard case .b = l.color, case .b = r.color else { return .unBalanced }
    return .balanced(blackHeight: x)
  }

  fileprivate func balL() -> RedBlackTree {
    switch self {
    case let .node(.b, .node(.r, .node(.r, a, x, b), y, c), z, d):
      return .node(.r, .node(.b,a,x,b),y,.node(.b,c,z,d))
    case let .node(.b, .node(.r, a, x, .node(.r, b, y, c)), z, d):
      return .node(.r, .node(.b,a,x,b),y,.node(.b,c,z,d))
    default:
      return self
    }
  }

  fileprivate func balR() -> RedBlackTree {
    switch self {
    case let .node(.b, a, x, .node(.r, .node(.r, b, y, c), z, d)):
      return .node(.r, .node(.b,a,x,b),y,.node(.b,c,z,d))
    case let .node(.b, a, x, .node(.r, b, y, .node(.r, c, z, d))):
      return .node(.r, .node(.b,a,x,b),y,.node(.b,c,z,d))
    default:
      return self
    }
  }

  fileprivate func unbalancedR() -> (result: RedBlackTree, wasBlack: Bool) {
    guard case let .node(c, l, x, .node(rc, rl, rx, rr)) = self else {
      preconditionFailure(
        "Should not call unbalancedR on an empty RedBlackTree or a RedBlackTree with an empty right"
      )
    }
    switch rc {
    case .b:
      return (RedBlackTree.node(.b, l, x, .node(.r, rl, rx, rr)).balR(), c == .b)
    case .r:
      guard case let .node(_, rll, rlx, rlr) = rl else {
        preconditionFailure("rl empty")
      }
      return (
        RedBlackTree.node(.b,
            RedBlackTree.node(.b, l, x, .node(.r, rll, rlx, rlr)).balR(), rx, rr), false
      )
    }
  }

  fileprivate func unbalancedL() -> (result: RedBlackTree, wasBlack: Bool) {
    guard case let .node(c, .node(lc, ll, lx, lr), x, r) = self else {
      preconditionFailure(
        "Should not call unbalancedL on an empty RedBlackTree or a RedBlackTree with an empty left"
      )
    }
    switch lc {
    case .b:
      return (RedBlackTree.node(.b, .node(.r, ll, lx, lr), x, r).balL(), c == .b)
    case .r:
      guard case let .node(_, lrl, lrx, lrr) = lr else {
        preconditionFailure("lr empty")
      }
      return (
        RedBlackTree.node(.b, ll, lx,
            RedBlackTree.node(.b, .node(.r, lrl, lrx, lrr), x, r).balL()), false
      )
    }
  }
}

// MARK: Contains

extension RedBlackTree {

  fileprivate func cont(_ x: Element, _ p: Element) -> Bool {
    guard case let .node(_, l, y, r) = self else { return x == p }
    return x < y ? l.cont(x, p) : r.cont(x, y)
  }

  /// Returns `true` iff `self` contains `x`
  ///- Complexity: O(*log n*)
  public func contains(_ x: Element) -> Bool {
    guard case let .node(_, l, y, r) = self else { return false }
    return x < y ? l.contains(x) : r.cont(x, y)
  }
}


extension RedBlackTree {

  fileprivate func ins(_ x: Element) -> RedBlackTree {
    guard case let .node(c, l, y, r) = self else { return RedBlackTree(x, color: .r) }
    if x < y { return RedBlackTree(y, color: c, left: l.ins(x), right: r).balL() }
    if y < x { return RedBlackTree(y, color: c, left: l, right: r.ins(x)).balR() }
    return self
  }

  /// Inserts `x` into `self
  ///- Complexity: O(*log n*)
  public mutating func insert(_ x: Element) {
    guard case let .node(_, l, y, r) = ins(x) else {
      preconditionFailure("ins should not return an empty RedBlackTree")
    }
    self = .node(.b, l, y, r)
  }
}

extension RedBlackTree : Sequence {

  /// Runs a `RedBlackTreeGenerator` over the elements of `self`. (The elements are presented in
  /// order, from smallest to largest)
  public func makeIterator() -> RedBlackTreeGenerator<Element> {
    return RedBlackTreeGenerator(stack: [], curr: self)
  }
}

/// A `Generator` for a RedBlackTree
public struct RedBlackTreeGenerator<Element : Comparable> : IteratorProtocol {

  fileprivate var (stack, curr): ([RedBlackTree<Element>], RedBlackTree<Element>)

  /// Advance to the next element and return it, or return `nil` if no next element exists.
  public mutating func next() -> Element? {
    while case let .node(_, l, x, r) = curr {
      if case .empty = l {
        curr = r
        return x
      } else {
        stack.append(curr)
        curr = l
      }
    }
    guard case let .node(_, _, x, r)? = stack.popLast()
      else { return nil }
    curr = r
    return x
  }
}

// MARK: Max, min

extension RedBlackTree {

  /// Returns the smallest element in `self` if it's present, or `nil` if `self` is empty
  ///- Complexity: O(*log n*)
  public func minElement() ->  Element? {
    switch self {
    case .empty: return nil
    case .node(_, .empty, let e, _): return e
    case .node(_, let l, _, _): return l.minElement()
    }
  }

  /// Returns the largest element in `self` if it's present, or `nil` if `self` is empty
  ///- Complexity: O(*log n*)
  public func maxElement() -> Element? {
    switch self {
    case .empty: return nil
    case .node(_, _, let e, .empty) : return e
    case .node(_, _, _, let r): return r.maxElement()
    }
  }

  fileprivate func _deleteMin() -> (RedBlackTree, Bool, Element) {
    switch self {
    case .empty:
      preconditionFailure("Should not call _deleteMin on an empty RedBlackTree")
    case let .node(.b, .empty, x, .empty):
      return (.empty, true, x)
    case let .node(.b, .empty, x, .node(.r, rl, rx, rr)):
      return (.node(.b, rl, rx, rr), false, x)
    case let .node(.r, .empty, x, r):
      return (r, false, x)
    case let .node(c, l, x, r):
      let (l0, d, m) = l._deleteMin()
      guard d else { return (.node(c, l0, x, r), false, m) }
      let tD = RedBlackTree.node(c, l0, x, r).unbalancedR()
      return (tD.0, tD.1, m)
    }
  }

  /// Removes the smallest element from `self` and returns it if it exists, or returns `nil`
  /// if `self` is empty.
  ///- Complexity: O(*log n*)
  public mutating func popFirst() -> Element? {
    guard case .node = self else { return nil }
    let (t, _, x) = _deleteMin()
    self = t
    return x
  }

  /// Removes the smallest element from `self` and returns it.
  ///- Complexity: O(*log n*)
  ///- Precondition: `!self.isEmpty`
  public mutating func removeFirst() -> Element? {
    guard case .node = self else { return nil }
    let (t, _, x) = _deleteMin()
    self = t
    return x
  }

  fileprivate func _deleteMax() -> (RedBlackTree, Bool, Element) {
    switch self {
    case .empty:
      preconditionFailure("Should not call _deleteMax on an empty RedBlackTree")
    case let .node(.b, .empty, x, .empty):
      return (.empty, true, x)
    case let .node(.b, .node(.r, rl, rx, rr), x, .empty):
      return (.node(.b, rl, rx, rr), false, x)
    case let .node(.r, l, x, .empty):
      return (l, false, x)
    case let .node(c, l, x, r):
      let (r0, d, m) = r._deleteMax()
      guard d else { return (.node(c, l, x, r0), false, m) }
      let tD = RedBlackTree.node(c, l, x, r0).unbalancedL()
      return (tD.0, tD.1, m)
    }
  }

  /// Removes the largest element from `self` and returns it if it exists, or returns `nil`
  /// if `self` is empty.
  ///- Complexity: O(*log n*)
  public mutating func popLast() -> Element? {
    guard case .node = self else { return nil }
    let (t, _, x) = _deleteMax()
    self = t
    return x
  }

  /// Removes the largest element from `self` and returns it.
  ///- Complexity: O(*log n*)
  ///- Precondition: `!self.isEmpty
  public mutating func removeLast() -> Element {
    let (t, _, x) = _deleteMax()
    self = t
    return x
  }
}

// MARK: Delete

extension RedBlackTree {

  fileprivate func del(_ x: Element) -> (RedBlackTree, Bool)? {
    guard case let .node(c, l, y, r) = self else { return nil }

    if x < y {
      guard let (l0, d) = l.del(x) else { return nil }
      let t = RedBlackTree.node(c, l0, y, r)
      return d ? t.unbalancedR() : (t, false)

    } else if y < x {
      guard let (r0, d) = r.del(x) else { return nil }
      let t = RedBlackTree.node(c, l, y, r0)
      return d ? t.unbalancedL() : (t, false)
    }

    if case .empty = r {
      guard case .b = c else { return (l, false) }
      if case let .node(.r, ll, lx, lr) = l { return (.node(.b, ll, lx, lr), false) }
      return (l, true)
    }

    let (r0, d, m) = r._deleteMin()
    let t = RedBlackTree.node(c, l, m, r0)
    return d ? t.unbalancedL() : (t, false)
  }

  /// Removes `x` from `self` and returns it if it is present, or `nil` if it is not
  ///- Complexity: O(*log n*)
  public mutating func remove(_ x: Element) -> Element? {
    guard let (t, _) = del(x) else { return nil }
    if case let .node(_, l, y, r) = t {
      self = .node(.b, l, y, r)
    } else {
      self = .empty
    }
    return x
  }
}

// MARK: Reverse

extension RedBlackTree {

  /// Returns a sequence of the elements of `self` from largest to smallest
  public func reverse() -> ReverseRedBlackTreeGenerator<Element> {
    return ReverseRedBlackTreeGenerator(stack: [], curr: self)
  }
}

/// A `Generator` for a RedBlackTree, that iterates over it in reverse.
public struct ReverseRedBlackTreeGenerator<Element : Comparable> : IteratorProtocol, Sequence {

  fileprivate var (stack, curr): ([RedBlackTree<Element>], RedBlackTree<Element>)

  public mutating func next() -> Element? {
    while case let .node(_, l, x, r) = curr {
      if case .empty = r {
        curr = l
        return x
      } else {
        stack.append(curr)
        curr = r
      }
    }
    guard case let .node(_, l, x, _)? = stack.popLast()
      else { return nil }
    curr = l
    return x
  }
}

// MARK: Higher-Order

extension RedBlackTree {

  public func reduce<T>(initial: T, combine: (T, Element) throws -> T) rethrows -> T {
    guard case let .node(_, l, x, r) = self else { return initial }
    let lx = try l.reduce(initial, combine)
    let xx = try combine(lx, x)
    let rx = try r.reduce(xx, combine)
    return rx
  }

  public func forEach(body: (Element) throws -> ()) rethrows {
    guard case let .node(_, l, x, r) = self else { return }
    try l.forEach(body)
    try body(x)
    try r.forEach(body)
  }
}

public protocol SetType : Sequence {

  /// Create an empty instance of `self`
  init()

  /// Create an instance of `self` containing the elements of `sequence`
  init<S : Sequence>(_ sequence: S) where S.Iterator.Element == Iterator.Element

  /// Remove `x` from `self` and return it if it was present. If not, return `nil`.
  mutating func remove(_ x: Iterator.Element) -> Iterator.Element?

  /// Insert `x` into `self`
  mutating func insert(_ x: Iterator.Element)

  /// returns `true` iff `self` contains `x`
  func contains(_ x: Iterator.Element) -> Bool

  /// Remove the member if it was present, insert it if it was not.
  mutating func XOR(_ x: Iterator.Element)
}

extension SetType {

  /// Return a new SetType with elements that are either in `self` or a finite
  /// sequence but do not occur in both.
  public func exclusiveOr<S : Sequence>(_ sequence: S) -> Self
      where S.Iterator.Element == Iterator.Element {
    var result = self
    result.exclusiveOrInPlace(sequence)
    return result
  }

  /// For each element of a finite sequence, remove it from `self` if it is a
  /// common element, otherwise add it to the SetType.
  public mutating func exclusiveOrInPlace<S : Sequence>(_ sequence: S)
      where S.Iterator.Element == Iterator.Element {
    var seen = Self()
    for x in sequence where !seen.contains(x) {
      XOR(x)
      seen.insert(x)
    }
  }

  /// Return a new set with elements common to `self` and a finite sequence.
  public func intersect<S : Sequence>(_ sequence: S) -> Self
      where S.Iterator.Element == Iterator.Element {
    var result = Self()
    for x in sequence where contains(x) { result.insert(x) }
    return result
  }

  /// Remove any elements of `self` that aren't also in a finite sequence.
  public mutating func intersectInPlace<S : Sequence> (_ sequence: S)
      where S.Iterator.Element == Iterator.Element {
    self = intersect(sequence)
  }

  /// Returns true if no elements in `self` are in a finite sequence.
  public func isDisjointWith<S : Sequence>(_ sequence: S) -> Bool
      where S.Iterator.Element == Iterator.Element {
    return !sequence.contains(where: contains)
  }

  /// Returns true if `self` is a superset of a finite sequence.
  public func isSupersetOf<S : Sequence>(_ sequence: S) -> Bool
      where S.Iterator.Element == Iterator.Element {
    return !sequence.contains { !self.contains($0) }
  }

  /// Returns true if `self` is a subset of a finite sequence
  public func isSubsetOf<S : Sequence>(_ sequence: S) -> Bool
      where S.Iterator.Element == Iterator.Element {
    return Self(sequence).isSupersetOf(self)
  }

  /// Return a new SetType with elements in `self` that do not occur
  /// in a finite sequence.
  public func subtract<S : Sequence>(_ sequence: S) -> Self
      where S.Iterator.Element == Iterator.Element {
    var result = self
    for x in sequence { result.remove(x) }
    return result
  }

  /// Remove all elements in `self` that occur in a finite sequence.
  public mutating func subtractInPlace<S : Sequence>(_ sequence: S)
      where S.Iterator.Element == Iterator.Element {
    for x in sequence { remove(x) }
  }

  /// Return a new SetType with items in both `self` and a finite sequence.
  public func union<S : Sequence>(_ sequence: S) -> Self
      where S.Iterator.Element == Iterator.Element {
    var result = self
    for x in sequence { result.insert(x) }
    return result
  }

  /// Insert the elements of a finite sequence into `self`
  public mutating func unionInPlace<S : Sequence>(_ sequence: S)
      where S.Iterator.Element == Iterator.Element {
    for x in sequence { insert(x) }
  }
}

extension RedBlackTree: SetType {

  /// Remove the member if it was present, insert it if it was not.
  public mutating func XOR(_ x: Element) {
    if case nil = remove(x) { insert(x) }
  }
}
