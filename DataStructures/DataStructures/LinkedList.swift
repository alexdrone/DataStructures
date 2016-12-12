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

final public class LinkedListNode<T>: HeadLinkedListNode<T> {

  /// The actual payload of the node
  public let element: T

  fileprivate init(element: T, linkedList: LinkedList<T>) {
    self.element = element;
    super.init(linkedList: linkedList)
  }

  /// Remove the node
  public func remove() {

    // this was the last node
    if self.next == nil {
      self.linkedList?.current = self.prev
    }

    self.linkedList?.count -= 1
    self.prev?.next = self.next

    self.linkedList?.__didRemove(self)
  }

  /// Insert the node before this
  public func inserBefore(_ node: LinkedListNode<T>) {
    node.next = self
    node.prev = self.prev
    self.prev = node
  }
}

open class HeadLinkedListNode<T> {

  // a reference to the linked list
  fileprivate var linkedList: LinkedList<T>?

  // the previous and the next node
  internal var next: LinkedListNode<T>?
  internal var prev: HeadLinkedListNode<T>?

  fileprivate init(linkedList: LinkedList<T>? = nil) {
    self.linkedList = linkedList
  }

  /// Insert the node passed as argument after this
  open func insertAfter(_ node: LinkedListNode<T>) {

    node.prev = self

    // node in-between
    if let next = self.next {
      node.next = next

      // this is the last node
    } else {
      self.linkedList?.current = node
    }

    self.next = node
    self.linkedList?.count += 1
  }
}

//MARK: - LinkedList

/// All of the operations perform as could be expected for a doubly-linked list.
/// Operations that index into the list will traverse the list from the beginning or the end,
/// whichever is closer to the specified index.
/// Note that this implementation is not synchronized. If multiple threads access a linked
/// list concurrently,
/// and at least one of the threads modifies the list structurally, it must be synchronized 
/// externally.
open class LinkedList<T>: ExpressibleByArrayLiteral {

  public typealias Element = T

  /// The element count
  open fileprivate(set) var count: UInt = 0

  /// The head of the linked list
  internal var head: HeadLinkedListNode<T>
  weak fileprivate var current: HeadLinkedListNode<T>?

  open var tail: LinkedListNode<T>? {
    return self.current as? LinkedListNode<T>
  }

  open subscript(index: UInt) -> T? {
    return self.node(forIndex: index)?.element
  }

  init() {
    self.head = HeadLinkedListNode<T>()
    self.current = self.head
    self.head.linkedList = self
  }

  /// Create an instance initialized with `elements`.
  public required convenience init(arrayLiteral elements: Element...) {
    self.init()

    for item in elements {
      self.append(item)
    }
  }

  /// Appends an element to the linkedlist
  open func append(_ element: T) {
    let node = LinkedListNode(element: element, linkedList: self)
    self.current?.insertAfter(node)

    self.__didAppend(node)
  }

  /// Remove the first element from the list
  open func removeFirst() -> T? {
    let node = self.head.next
    node?.remove()
    return node?.element
  }

  /// Remove the last element from the list
  open func removeLast() -> T? {
    guard let node = self.current as? LinkedListNode<T> else { return nil }
    node.remove()
    return node.element
  }

  /// Returns the node at the nth index
  open func node(forIndex index: UInt) -> LinkedListNode<T>? {

    //tail
    if index == self.count-1 {
      return self.current as? LinkedListNode<T>

      //iterate from head
    } else if index < self.count/2 {

      var idx: UInt = 0
      var node = self.head

      while let n = node.next {
        node = n
        if idx == index {
          idx += 1
          return n
        }
        idx += 1
      }

      //iterate from tail
    } else {

      var idx: UInt = self.count-1
      var node = self.current

      while let n = node?.prev {
        node = n
        if idx == index {
          idx -= 1
          return n as? LinkedListNode<T>
        }
        idx -= 1
      }
    }

    return nil
  }

  /// Remove the node at the given index
  open func remove(atIndex index: UInt) {
    self.node(forIndex: index)?.remove()
  }

  /// Remove all the nodes from the linkedlist
  open func removeAll() {
    self.head.next = nil
    self.current = self.head
    self.count = 0
  }

  open func toArray() -> [T] {
    var array = [T]()
    for e in self { array.append(e) }
    return array
  }

  fileprivate func __didAppend(_ node: LinkedListNode<T>) {}
  fileprivate func __didRemove(_ node: LinkedListNode<T>) {}

  public typealias Index = LinkedListIndex<T>

  /// Indexable protocol

  open var startIndex: Index {
    return LinkedListIndex(index: 0, node: self.head.next)
  }

  open var endIndex: Index {
    return LinkedListIndex(index: 0, node: self.current as? LinkedListNode<T>)
  }

  open subscript (position: Index) -> Element {
    return position.node!.element
  }
}

extension LinkedList where T: Equatable {

  /// Remove the node for the associated element
  public func remove(forElement element: T) {
    self.node(forElement: element)?.remove()
  }

  /// Returns 'true' if the list contains the element, 'false' otherwise
  public func contains(_ element: T) -> Bool {
    return self.node(forElement: element) != nil
  }

  /// Returns the node for the element passed as argument (if it exists)
  public func node(forElement element: T) -> LinkedListNode<T>? {

    var node = self.head
    while let n = node.next {
      node = n
      if element == n.element { return n }
    }

    return nil
  }

  ///Return the index of the element passed as argument
  public func index(forElement element: T) -> UInt? {

    var node = self.head
    var idx: UInt = 0
    while let n = node.next {
      node = n
      if element == n.element {
        return idx
      }
      idx += 1
    }

    return nil
  }
}

extension LinkedList: Sequence {

  public typealias Iterator = LinkedListGenerator<T>

  ///Return a *generator* over the elements of this *sequence*.
  public func makeIterator() -> Iterator {
    return LinkedListGenerator(linkedList: self)
  }
}

extension LinkedList: CustomStringConvertible {

  ///A textual representation of `self`.
  public var description: String {
    get {
      return self.map() { return $0 }.description
    }
  }
}

public struct LinkedListGenerator<T>: IteratorProtocol {

  public typealias Element = T

  fileprivate let linkedList: LinkedList<T>
  fileprivate var current: HeadLinkedListNode<T>?

  fileprivate init(linkedList: LinkedList<T>) {
    self.linkedList = linkedList
    self.current = linkedList.head
  }

  ///Advance to the next element and return it, or `nil` if no next element exists.
  public mutating func next() -> Element? {

    let node = self.current?.next
    self.current = node
    return node?.element
  }
}

//MARK: - Index

public struct LinkedListIndex<T>: Comparable, Equatable, _Incrementable {
  /// Returns a Boolean value indicating whether the value of the first
  /// argument is less than that of the second argument.
  ///
  /// This function is the only requirement of the `Comparable` protocol. The
  /// remainder of the relational operator functions are implemented by the
  /// standard library for any type that conforms to `Comparable`.
  ///
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  public static func <(lhs: LinkedListIndex<T>, rhs: LinkedListIndex<T>) -> Bool {
    guard let ln = lhs.node, let rn = rhs.node else { return false }
    return ln === rn && lhs.index == rhs.index
  }

  public typealias Distance = Int

  fileprivate let index: Distance
  fileprivate let node: LinkedListNode<T>?

  fileprivate func advanceByOne() -> LinkedListIndex<T> {
    guard let node = self.node else { return self }
    guard let next = node.next else { return self }
    return LinkedListIndex(index: index+1, node: next)
  }

  public func advancedBy(_ n: Distance) -> LinkedListIndex<T> {
    var result = self
    for _ in 0..<n { result = result.advanceByOne() }
    return result
  }

  public func advancedBy(_ n: Distance, limit: LinkedListIndex<T>) -> LinkedListIndex<T> {
    return self.advancedBy(n)
  }

  public func distanceTo(_ end: LinkedListIndex<T>) -> Distance {

    guard let node = self.node else { return 0 }

    var i = 0
    var current = node
    while let n = current.next {
      current = n
      i += 1
    }
    return i
  }

  public func successor() -> LinkedListIndex<T> {
    return self.advanceByOne()
  }

}

public func ==<T>(lhs: LinkedListIndex<T>, rhs: LinkedListIndex<T>) -> Bool {
  guard let ln = lhs.node, let rn = rhs.node else { return false }
  return ln === rn && lhs.index == rhs.index
}

//MARK: - SortedLinkedList

/// A LinkedList where the elment are inserted in order.
/// Use the 'sortClosure' property to define the sort policy
/// Every insertion has complexity O(n)
open class SortedLinkedList<T:Comparable>: LinkedList<T> {

  /// Set this property to have a custom sort closure.
  /// The default one is $0 < $1
  open var sortClosure: (T, T) -> Bool = { return $0 < $1 }

  /// Appends the element in the list respecting the order
  open override func append(_ element: T) {

    var node = self.head
    while let n = node.next {
      node = n
      if sortClosure(element, n.element) {
        n.inserBefore(LinkedListNode<T>(element: element, linkedList: self))
        break
      }
    }
  }

  // /Resort the element passed as argument in the list
  open func resort(_ element: T) {
    guard let node = self.node(forElement: element) else { return }
    node.remove()
    self.append(node.element)
  }

  /// Resort the whole list
  open func resortAll() {
    let array = self.toArray()
    self.removeAll()
    for e in array { self.append(e) }
  }

}

