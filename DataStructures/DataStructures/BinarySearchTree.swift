//
//  BinarySearchTree.swift
//  DataStructures
//
//  Created by Alex Usbergo on 25/01/16.
//  Copyright © 2016 Alex Usbergo. All rights reserved.
//

import Foundation

indirect public enum BinarySearchTree<T: Comparable>: SequenceType, ArrayLiteralConvertible {
    
    public typealias Element = T

    ///A node with data
    case Node(value: T, left: BinarySearchTree<T>, right: BinarySearchTree<T>)
    
    ///Empty node
    case Empty
        
    ///Conforming types can be initialized with array literals.
    public init(arrayLiteral elements: Element...) {
        func create(array: [T], start: Int, end: Int) -> BinarySearchTree {
            if abs(end - start) == 1 {
                return BinarySearchTree.Node(value: array[start], left: .Empty, right: .Empty)
            }
            let mid = (start + end)/2
            let tree = BinarySearchTree.Node(value: array[mid], left: create(array, start: start, end: mid-1), right: create(array, start: mid+1, end: end))
            return tree
        }
        self = create(elements.sort(), start: 0, end: elements.count-1)
    }
    
    ///Wether this is an empty node or not
    public var empty: Bool {
        get {
            switch self {
            case .Empty: return true
            default: return false
            }
        }
    }
    
    ///The value associated to this node
    public var value: T? {
        get {
            switch self {
            case .Node(let value, _, _): return value
            default: return nil
            }
        }
    }
    
    private var left: BinarySearchTree<T>? {
        get {
            switch self {
            case .Node(_, let left, _): return left
            default: return nil
            }
        }
    }
    
    private var right: BinarySearchTree<T>? {
        get {
            switch self {
            case .Node(_, _, let right): return right
            default: return nil
            }
        }
    }

    ///Returns the height of this tree
    ///- Complexity: O(n)
    public func height() -> Int {
        func heightRecursive(tree: BinarySearchTree<T>) -> Int {
            switch tree {
            case .Empty: return 0
            case .Node(_, let left, let right):
                return max(heightRecursive(left), heightRecursive(right)) + 1
            }
        }
        return heightRecursive(self)
    }
    
    ///A balanced tree is defined to be a tree such that the heights of the two
    ///subtrees of any node never differ by more than one
    ///- Complexity: O(n)
    public func balanced() -> Bool {
        switch self {
        case .Empty:
            return true
        case .Node(_, let left, let right):
            return abs(left.height() - right.height()) <= 1
        }
    }
    
    ///Returns the index for the seearched document, NSNotFound otherwise
    ///- Complexity: O(logn)
    public func indexOf(element: T) -> (Int, BinarySearchTree<T>) {
        
        var queue = [BinarySearchTree<T>]()
        queue.enqueue(self)
        
        var idx = 0
        while !queue.isEmpty {
            
            let node = queue.dequeue()!
            switch node {
            case .Empty:
                return (NSNotFound, .Empty)
            case .Node(let value, let left, let right):
                if (value == element) {
                    return (idx, node)
                    
                } else if element < value && !left.empty {
                    queue.enqueue(left)
                    
                } else if element > value && !right.empty {
                    queue.enqueue(right)
                }
            }
            idx++
        }
        
        return (NSNotFound, .Empty)
    }
    
    private func leftmostNode() -> BinarySearchTree<T> {
        var current = self
        while let left = current.left {
            current = left
        }
        return current
    }
    
    ///Returns the successor of the node passed in as argument
    ///Call this method on the root
    public func inorderSuccessor(node: BinarySearchTree<T>) -> BinarySearchTree<T>? {
        
        if let right = node.right {
            return right.leftmostNode()
        }
        
        var succ: BinarySearchTree<T>? = nil
        var root: BinarySearchTree<T>?  = self
        while let r = root where !r.empty {
           
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
    
    
    //MARK: Trasversal
    
    ///Returns a list of tree levels
    ///- Complexity: O(n)
    public func elementsAtLevel() -> [[T]] {
        var result = [[T]]()
        var current = [T]()
        
        var queue = Array<(node: BinarySearchTree<T>, marker: Bool)>()
        queue.enqueue((self, false))
        
        //marker
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
                case .Node(let value, let left, let right):
                    current.append(value)
                    queue.enqueue((left, false))
                    queue.enqueue((right, false))
                }
            }
        }
        
        return result
    }
    
    ///Performs a visit inorder of the tree
    public func inorder() -> [T] {
        func visit(node: BinarySearchTree<T>, inout result: [T]) {
            switch node {
            case .Empty: return
            case .Node(let value, let left, let right):
                visit(left, result: &result)
                result.append(value)
                visit(right, result: &result)
            }
        }
        
        var result = [T]()
        visit(self, result: &result)
        return result
    }
    
    ///Performs a visit postorder of the tree
    public func postorder() -> [T] {
        func visit(node: BinarySearchTree<T>, inout result: [T]) {
            switch node {
            case .Empty: return
            case .Node(let value, let left, let right):
                visit(left, result: &result)
                visit(right, result: &result)
                result.append(value)
            }
        }
        
        var result = [T]()
        visit(self, result: &result)
        return result
    }
    
    ///Performs a visit preorder of the tree
    public func preorder() -> [T] {
        func visit(node: BinarySearchTree<T>, inout result: [T]) {
            switch node {
            case .Empty: return
            case .Node(let value, let left, let right):
                result.append(value)
                visit(left, result: &result)
                visit(right, result: &result)
            }
        }
        
        var result = [T]()
        visit(self, result: &result)
        return result
    }
    
    
    public typealias Generator = BinarySearchTreeGenerator<T>
    
    ///Return a *generator* over the elements of this *sequence*.
    public func generate() -> Generator {
        return BinarySearchTreeGenerator(node: self)
    }
}

public struct BinarySearchTreeGenerator<T:Comparable>: GeneratorType {
    
    public typealias Element = T
    private let list: [T]
    private var index = 0
    
    private init(node: BinarySearchTree<T>) {
        self.list = node.inorder()
    }
    
    ///Advance to the next element and return it, or `nil` if no next element exists.
    public mutating func next() -> Element? {
        if self.index < self.list.count {
            return self.list[index++]
        }
        return nil
    }
}
