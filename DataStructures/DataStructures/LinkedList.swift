//
//  LinkedList.swift
//  Primer
//
//  Created by Alex Usbergo on 22/12/15.
//  Copyright © 2015 Alex Usbergo. All rights reserved.
//

import Foundation

final public class LinkedListNode<T>: HeadLinkedListNode<T> {
    
    ///The actual payload of the node
    public let element: T
    
    private init(element: T, linkedList: LinkedList<T>) {
        self.element = element;
        super.init(linkedList: linkedList)
    }
    
    ///Remove the node
    public func remove() {
        
        //this was the last node
        if self.next == nil {
            self.linkedList?.current = self.prev
        }
        
        self.linkedList?.count--
        self.prev?.next = self.next
        
        self.linkedList?.__didRemove(self)
    }
    
    ///Insert the node before this
    public func inserBefore(node: LinkedListNode<T>) {
        node.next = self
        node.prev = self.prev
        self.prev = node
    }
}

public class HeadLinkedListNode<T> {
    
    //a reference to the linked list
    private var linkedList: LinkedList<T>?
    
    //the previous and the next node
    internal var next: LinkedListNode<T>?
    internal var prev: HeadLinkedListNode<T>?

    private init(linkedList: LinkedList<T>? = nil) {
        self.linkedList = linkedList
    }
    
    ///Insert the node passed as argument after this
    public func insertAfter(node: LinkedListNode<T>) {
        
        node.prev = self
        
        //node in-between
        if let next = self.next {
            node.next = next
            
        //this is the last node
        } else {
            self.linkedList?.current = node
        }
        
        self.next = node
        self.linkedList?.count++
    }
}

//MARK: - LinkedList

///All of the operations perform as could be expected for a doubly-linked list. 
///Operations that index into the list will traverse the list from the beginning or the end, 
///whichever is closer to the specified index.
///Note that this implementation is not synchronized. If multiple threads access a linked list concurrently, 
///and at least one of the threads modifies the list structurally, it must be synchronized externally.
public class LinkedList<T>: ArrayLiteralConvertible {
    
    public typealias Element = T

    ///The element count
    public private(set) var count: UInt = 0
    
    ///The head of the linked list
    internal var head: HeadLinkedListNode<T>
    weak private var current: HeadLinkedListNode<T>?
    
    public var tail: LinkedListNode<T>? {
        return self.current as? LinkedListNode<T>
    }

    public subscript(index: UInt) -> T? {
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
    
    ///Appends an element to the linkedlist
    public func append(element: T) {
        let node = LinkedListNode(element: element, linkedList: self)
        self.current?.insertAfter(node)
        
        self.__didAppend(node)
    }
    
    ///Remove the first element from the list
    public func removeFirst() -> T? {
        let node = self.head.next
        node?.remove()
        return node?.element
    }
    
    ///Remove the last element from the list
    public func removeLast() -> T? {
        guard let node = self.current as? LinkedListNode<T> else { return nil }
        node.remove()
        return node.element
    }
    
    ///Returns the node at the nth index
    public func node(forIndex index: UInt) -> LinkedListNode<T>? {
        
        //tail
        if index == self.count-1 {
            return self.current as? LinkedListNode<T>
            
        //iterate from head
        } else if index < self.count/2 {
            
            var idx: UInt = 0
            var node = self.head

            while let n = node.next {
                node = n
                if idx++ == index { return n }
            }
            
        //iterate from tail
        } else {
            
            var idx: UInt = self.count-1
            var node = self.current
            
            while let n = node?.prev {
                node = n
                if idx-- == index { return n as? LinkedListNode<T> }
            }
        }
    
        return nil
    }
    
    ///Remove the node at the given index
    public func remove(atIndex index: UInt) {
        self.node(forIndex: index)?.remove()
    }
    
    ///Remove all the nodes from the linkedlist
    public func removeAll() {
        self.head.next = nil
        self.current = self.head
        self.count = 0
    }
    
    public func toArray() -> [T] {
        var array = [T]()
        for e in self { array.append(e) }
        return array
    }
    
    private func __didAppend(node: LinkedListNode<T>) {}
    private func __didRemove(node: LinkedListNode<T>) {}
    
    public typealias Index = LinkedListIndex<T>
    
    ///Indexable protocol
    
    public var startIndex: Index {
        return LinkedListIndex(index: 0, node: self.head.next)
    }
    
    public var endIndex: Index {
        return LinkedListIndex(index: 0, node: self.current as? LinkedListNode<T>)
    }
    
    public subscript (position: Index) -> Element {
        return position.node!.element
    }
}

extension LinkedList where T: Equatable {
    
    ///Remove the node for the associated element
    public func remove(forElement element: T) {
        self.node(forElement: element)?.remove()
    }
    
    ///Returns 'true' if the list contains the element, 'false' otherwise 
    public func contains(element: T) -> Bool {
        return self.node(forElement: element) != nil
    }
 
    ///Returns the node for the element passed as argument (if it exists)
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
            idx++
        }
        
        return nil
    }
}

extension LinkedList: SequenceType {
    
    public typealias Generator = LinkedListGenerator<T>
    
    ///Return a *generator* over the elements of this *sequence*.
    public func generate() -> Generator {
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

public struct LinkedListGenerator<T>: GeneratorType {
    
    public typealias Element = T
    
    private let linkedList: LinkedList<T>
    private var current: HeadLinkedListNode<T>?
    
    private init(linkedList: LinkedList<T>) {
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

public struct LinkedListIndex<T>: ForwardIndexType, Equatable, _Incrementable {
    
    public typealias Distance = Int
    
    private let index: Distance
    private let node: LinkedListNode<T>?

    private func advanceByOne() -> LinkedListIndex<T> {
        guard let node = self.node else { return self }
        guard let next = node.next else { return self }
        return LinkedListIndex(index: index+1, node: next)
    }
    
    public func advancedBy(n: Distance) -> LinkedListIndex<T> {
        var result = self
        for _ in 0..<n { result = result.advanceByOne() }
        return result
    }

    public func advancedBy(n: Distance, limit: LinkedListIndex<T>) -> LinkedListIndex<T> {
        return self.advancedBy(n)
    }
    
    public func distanceTo(end: LinkedListIndex<T>) -> Distance {
        
        guard let node = self.node else { return 0 }

        var i = 0
        var current = node
        while let n = current.next {
            current = n
            i++
        }
        return i
    }
    
    public func successor() -> LinkedListIndex<T> {
        return self.advanceByOne()
    }
    
}

public func ==<T>(lhs: LinkedListIndex<T>, rhs: LinkedListIndex<T>) -> Bool {
    guard let ln = lhs.node, rn = rhs.node else { return false }
    return ln === rn && lhs.index == rhs.index
}

//MARK: - SortedLinkedList

///A LinkedList where the elment are inserted in order.
///Use the 'sortClosure' property to define the sort policy
///Every insertion has complexity O(n)
public class SortedLinkedList<T:Comparable>: LinkedList<T> {
    
    ///Set this property to have a custom sort closure. 
    ///The default one is $0 < $1
    public var sortClosure: (T, T) -> Bool = { return $0 < $1 }
    
    ///Appends the element in the list respecting the order
    public override func append(element: T) {
        
        var node = self.head
        while let n = node.next {
            node = n
            if sortClosure(element, n.element) {
                n.inserBefore(LinkedListNode<T>(element: element, linkedList: self))
                break
            }
        }
    }
    
    ///Resort the element passed as argument in the list
    public func resort(element: T) {
        guard let node = self.node(forElement: element) else { return }
        node.remove()
        self.append(node.element)
    }
    
    ///Resort the whole list
    public func resortAll() {
        let array = self.toArray()
        self.removeAll()
        for e in array { self.append(e) }
    }
    
}

