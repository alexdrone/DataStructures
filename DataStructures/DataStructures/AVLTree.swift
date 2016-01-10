//
//  AVLTree.swift
//  DataStructures
//
//  Created by Alex Usbergo on 09/01/16.
//  Copyright © 2016 Alex Usbergo. All rights reserved.
//
//  Original ObjC implementation: https://github.com/StephanPartzsch/AVLTree
//

import Foundation

func ||<T>(optional : Optional<T>, defaultValue : T) -> T {
    if let value = optional {
        return value
    }
    return defaultValue
}

public func +<T>(node : AVLTree<T>, newValue : T) -> AVLTree<T> {
    var newLeft : AVLTree<T>? = node.left
    var newRight : AVLTree<T>? = node.right
    
    if (newValue < node.value) {
        if let left = node.left {
            newLeft = left + newValue
        } else {
            newLeft = AVLTree(newValue)
        }
        
    } else if(newValue > node.value) {
        if let right = node.right {
            newRight = right + newValue
        } else {
            newRight = AVLTree(newValue)
        }
        
    } else {
        return node
    }
    
    let newRoot = AVLTree(value: node.value, left: newLeft, right: newRight)
    return newRoot.fixBalance()
}

public func-<T>(node: AVLTree<T>?, value : T) -> AVLTree<T>? {
    return node?.remove(value).result
}

///AVL tree is a self balanced binary tree.
///It doesn’t consume much memory, all standard operations (add, remove, find) are log(n) and
///you can iterate through the elements in ascending or descending manner. In comparison to an Array,
///an AVL tree is slower for addition but much faster for remove and find. The values are also always ordered.
public class AVLTree<T: Comparable> {
    public typealias Element = T
    
    public let left : AVLTree<Element>?
    public let right : AVLTree<Element>?
    
    public let count : UInt
    public let depth : UInt
    public let balance : Int
    
    public let value : Element!
    
    public convenience init(_ value : Element){
        self.init(value: value, left: nil, right: nil)
    }
    
    public func contains(value : Element) -> Bool{
        if self.value == value { return true }
        if left?.contains(value) == true { return true }
        if right?.contains(value) == true { return true }
        return false
    }
    
    init(value : Element, left: AVLTree<Element>?, right: AVLTree<Element>?){
        self.value = value
        self.left = left
        self.right = right
        self.count = 1 + (left?.count || 0) + (right?.count || 0)
        self.depth = 1 + max((left?.depth || 0), (right?.depth || 0))
        
        let l: Int = Int((left?.depth) || 0)
        let r: Int = Int((right?.depth) || 0)
        self.balance = l - r
    }
    
    private func fixBalance() -> AVLTree<Element> {
        if abs(balance) < 2 {
            return self
        }
        
        if (balance == 2) {
            let leftBalance = self.left?.balance || 0
            
            if (leftBalance == 1 || leftBalance == 0) {
                //Easy case:
                return rotateToRight()
            }
            
            if (leftBalance == -1) {
                //Rotate Left to left
                let newLeft = left!.rotateToLeft()
                let newRoot = AVLTree(value: value, left: newLeft, right: right)
                
                return newRoot.rotateToRight()
            }
            
            fatalError("LeftNode too unbalanced")
        }
        
        if (balance == -2) {
            let rightBalance = right?.balance || 0
            
            if (rightBalance == -1 || rightBalance == 0) {
                //Easy case:
                return rotateToLeft()
            }
            
            if (rightBalance == 1) {
                //Rotate right to right
                let newRight = right!.rotateToRight()
                let newRoot = AVLTree(value: value, left: left, right: newRight)
                
                return newRoot.rotateToLeft()
            }
            
            fatalError("RightNode too unbalanced")
        }
        
        fatalError("Tree too unbalanced")
    }
    
    public func remove(value : Element) -> (result: AVLTree<Element>?, foundFlag :Bool) {
        
        if value < self.value {
            
            let removeResult = left?.remove(value)
            if removeResult == nil || removeResult!.foundFlag == false {
                // Not found, so nothing changed
                return (self, false)
            }
            
            let newRoot = AVLTree(value: self.value, left: removeResult!.result, right: right).fixBalance()
            return (newRoot, true)
        }
        
        if value > self.value {
            
            let removeResult = right?.remove(value)
            if removeResult == nil || removeResult!.foundFlag == false {
                // Not found, so nothing changed
                return (self, false)
            }
            
            let newRoot = AVLTree(value: self.value, left: left, right: removeResult!.result)
            return (newRoot, true)
        }
        
        //found it
        return (removeRoot(), true)
    }
    
    public func removeMin()-> (min : AVLTree<Element>, result : AVLTree<Element>?) {
        
        if left == nil {
            //We are the minimum:
            return (self, right)
            
        } else {
            //Go down:
            let (min, newLeft) = left!.removeMin()
            let newRoot = AVLTree(value: value, left: newLeft, right: right)
            
            return (min, newRoot.fixBalance())
        }
    }
    
    public func removeMax()-> (max : AVLTree<Element>, result : AVLTree<Element>?) {
        
        if right == nil {
            //We are the max:
            return (self, left)
        } else {
            //Go down:
            let (max, newRight) = right!.removeMax()
            let newRoot = AVLTree(value: value, left: left, right: newRight)
            
            return (max, newRoot.fixBalance())
        }
    }
    
    public func removeRoot() -> AVLTree<Element>? {
        
        if left == nil {
            return right
        }
        
        if right == nil {
            return left
        }
        
        //Neither are empty:
        if left!.count < right!.count {
            // LeftNode has fewer, so promote from RightNode to minimize depth
            let (min, newRight) = right!.removeMin()
            let newRoot = AVLTree(value: min.value, left: left, right: newRight)
            
            return newRoot.fixBalance()
        } else {
            let (max, newLeft) = left!.removeMax()
            let newRoot = AVLTree(value: max.value, left: newLeft, right: right)
            
            return newRoot.fixBalance()
        }
    }
    
    private func rotateToRight() -> AVLTree<Element> {
        let newRight = AVLTree(value: value, left: left!.right, right: right)
        return AVLTree(value: left!.value, left: left!.left, right: newRight)
    }
    
    private func rotateToLeft() -> AVLTree<Element> {
        let newLeft = AVLTree(value: value, left: left, right: right!.left)
        return AVLTree(value: right!.value, left: newLeft, right: right!.right)
    }
}

extension AVLTree : CustomStringConvertible {
    
    public var description : String {
        let empty = "_"
        return "(\(value) \(left?.description || empty) \(right?.description || empty))"
    }
}

extension AVLTree : SequenceType {
    
     ///Runs a `RedBlackTreeGenerator` over the elements of `self`. (The elements are presented in
     ///order, from smallest to largest)
    public func generate() -> AVLTreeGenerator<Element> {
        return AVLTreeGenerator(stack: [], curr: self)
    }
}

///A `Generator` for a AVLTree
public struct AVLTreeGenerator<Element : Comparable> : GeneratorType {
    
    private var (stack, curr): ([AVLTree<Element>], AVLTree<Element>)
    
     ///Advance to the next element and return it, or return `nil` if no next element exists.
    public mutating func next() -> Element? {
        
        if curr.left == nil {
            if let right = curr.right {
                let value = curr.value
                curr = right
                return value
            }
        } else {
            stack.append(curr)
            if let left = curr.left {
                curr = left
            }
        }
        
        guard let node = stack.popLast() else {
            return nil
        }
        
        if let right = node.right {
            let value = node.value
            curr = right
            return value
        }
        
        return nil
    }
}
