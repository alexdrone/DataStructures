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

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


indirect public enum BinarySearchTree<T: Comparable>: Sequence, ExpressibleByArrayLiteral {

  public typealias Element = T

  /// A node with data
  case node(value: T, left: BinarySearchTree<T>, right: BinarySearchTree<T>)

  /// Empty node
  case Empty

  /// Conforming types can be initialized with array literals.
  public init(arrayLiteral elements: Element...) {
    func create(_ array: [T], start: Int, end: Int) -> BinarySearchTree {
      if abs(end - start) == 1 {
        return BinarySearchTree.node(value: array[start], left: .Empty, right: .Empty)
      }
      let mid = (start + end)/2
      let tree = BinarySearchTree.node(value: array[mid],
                                       left: create(array, start: start, end: mid-1),
                                       right: create(array, start: mid+1, end: end))
      return tree
    }
    self = create(elements.sorted(), start: 0, end: elements.count-1)
  }

  /// Wether this is an empty node or not
  public var empty: Bool {
    get {
      switch self {
      case .Empty: return true
      default: return false
      }
    }
  }

  /// The value associated to this node
  public var value: T? {
    get {
      switch self {
      case .node(let value, _, _): return value
      default: return nil
      }
    }
  }

  fileprivate var left: BinarySearchTree<T>? {
    get {
      switch self {
      case .node(_, let left, _): return left
      default: return nil
      }
    }
  }

  fileprivate var right: BinarySearchTree<T>? {
    get {
      switch self {
      case .node(_, _, let right): return right
      default: return nil
      }
    }
  }

  /// Returns the height of this tree
  ///- Complexity: O(n)
  public func height() -> Int {
    func heightRecursive(tree: BinarySearchTree<T>) -> Int {
      switch tree {
      case .Empty: return 0
      case .node(_, let left, let right):
        let left = heightRecursive(tree: left)
        let right = heightRecursive(tree: right)
        return (left > right ? left : right) + 1
      }
    }
    return heightRecursive(tree: self)
  }

  /// A balanced tree is defined to be a tree such that the heights of the two
  /// subtrees of any node never differ by more than one
  ///- Complexity: O(n)
  public func balanced() -> Bool {
    switch self {
    case .Empty:
      return true
    case .node(_, let left, let right):
      return abs(left.height() - right.height()) <= 1
    }
  }

  /// Returns the index for the seearched document, NSNotFound otherwise
  ///- Complexity: O(logn)
  public func indexOf(_ element: T) -> (Int, BinarySearchTree<T>) {

    var queue = [BinarySearchTree<T>]()
    queue.enqueue(self)

    var idx = 0
    while !queue.isEmpty {

      let node = queue.dequeue()!
      switch node {
      case .Empty:
        return (NSNotFound, .Empty)
      case .node(let value, let left, let right):
        if (value == element) {
          return (idx, node)

        } else if element < value && !left.empty {
          queue.enqueue(left)

        } else if element > value && !right.empty {
          queue.enqueue(right)
        }
      }
      idx += 1
    }

    return (NSNotFound, .Empty)
  }

  fileprivate func leftmostNode() -> BinarySearchTree<T> {
    var current = self
    while let left = current.left {
      current = left
    }
    return current
  }

  /// Returns the successor of the node passed in as argument
  /// Call this method on the root
  public func inorderSuccessor(_ node: BinarySearchTree<T>) -> BinarySearchTree<T>? {

    if let right = node.right {
      return right.leftmostNode()
    }

    var succ: BinarySearchTree<T>? = nil
    var root: BinarySearchTree<T>?  = self
    while let r = root , !r.empty {

      if node.value < r.value {
        succ = r
        root = r.left

      } else if node.value > r.value {
        root = r.right

      } else {
        break
      }
    }

    return succ
  }


  // MARK: Trasversal

  /// Returns a list of tree levels
  ///- Complexity: O(n)
  public func elementsAtLevel() -> [[T]] {
    var result = [[T]]()
    var current = [T]()

    var queue = Array<(node: BinarySearchTree<T>, marker: Bool)>()
    queue.enqueue((self, false))

    // marker
    queue.enqueue((BinarySearchTree.Empty, true))

    while !queue.isEmpty {

      let item = queue.dequeue()!

      if item.marker && !queue.isEmpty {
        result.append(current)
        current = [T]()
        queue.enqueue((BinarySearchTree.Empty, true))

      } else {
        switch item.node {
        case .Empty: break
        case .node(let value, let left, let right):
          current.append(value)
          queue.enqueue((left, false))
          queue.enqueue((right, false))
        }
      }
    }

    return result
  }

  /// Performs a visit inorder of the tree
  public func inorder() -> [T] {
    func visit(_ node: BinarySearchTree<T>, result: inout [T]) {
      switch node {
      case .Empty: return
      case .node(let value, let left, let right):
        visit(left, result: &result)
        result.append(value)
        visit(right, result: &result)
      }
    }

    var result = [T]()
    visit(self, result: &result)
    return result
  }

  /// Performs a visit postorder of the tree
  public func postorder() -> [T] {
    func visit(_ node: BinarySearchTree<T>, result: inout [T]) {
      switch node {
      case .Empty: return
      case .node(let value, let left, let right):
        visit(left, result: &result)
        visit(right, result: &result)
        result.append(value)
      }
    }

    var result = [T]()
    visit(self, result: &result)
    return result
  }

  /// Performs a visit preorder of the tree
  public func preorder() -> [T] {
    func visit(_ node: BinarySearchTree<T>, result: inout [T]) {
      switch node {
      case .Empty: return
      case .node(let value, let left, let right):
        result.append(value)
        visit(left, result: &result)
        visit(right, result: &result)
      }
    }

    var result = [T]()
    visit(self, result: &result)
    return result
  }


  public typealias Iterator = BinarySearchTreeGenerator<T>

  /// Return a *generator* over the elements of this *sequence*.
  public func makeIterator() -> Iterator {
    return BinarySearchTreeGenerator(node: self)
  }
}

public struct BinarySearchTreeGenerator<T:Comparable>: IteratorProtocol {

  public typealias Element = T
  fileprivate let list: [T]
  fileprivate var index = 0

  fileprivate init(node: BinarySearchTree<T>) {
    self.list = node.inorder()
  }

  ///Advance to the next element and return it, or `nil` if no next element exists.
  public mutating func next() -> Element? {
    if self.index < self.list.count {
      let result = self.list[index]
      index += 1
      return result
    }
    return nil
  }
}
