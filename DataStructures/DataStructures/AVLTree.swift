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
//  Original ObjC implementation: https://github.com/StephanPartzsch/AVLTree
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
open class AVLTree<T: Comparable> {
  public typealias Element = T

  open let left : AVLTree<Element>?
  open let right : AVLTree<Element>?

  open let count : UInt
  open let depth : UInt
  open let balance : Int

  open let value : Element!

  public convenience init(_ value : Element){
    self.init(value: value, left: nil, right: nil)
  }

  open func contains(_ value : Element) -> Bool{
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

    let ld = left?.depth || 0
    let rd = right?.depth || 0
    self.depth = 1 + (ld > rd ? ld : rd)

    let l: Int = Int((left?.depth) || 0)
    let r: Int = Int((right?.depth) || 0)
    self.balance = l - r
  }

  fileprivate func fixBalance() -> AVLTree<Element> {
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

  open func remove(_ value : Element) -> (result: AVLTree<Element>?, foundFlag :Bool) {

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

  open func removeMin()-> (min : AVLTree<Element>, result : AVLTree<Element>?) {

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

  open func removeMax()-> (max : AVLTree<Element>, result : AVLTree<Element>?) {

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

  open func removeRoot() -> AVLTree<Element>? {

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

  fileprivate func rotateToRight() -> AVLTree<Element> {
    let newRight = AVLTree(value: value, left: left!.right, right: right)
    return AVLTree(value: left!.value, left: left!.left, right: newRight)
  }

  fileprivate func rotateToLeft() -> AVLTree<Element> {
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

extension AVLTree : Sequence {

  ///Runs a `RedBlackTreeGenerator` over the elements of `self`. (The elements are presented in
  ///order, from smallest to largest)
  public func makeIterator() -> AVLTreeGenerator<Element> {
    return AVLTreeGenerator(stack: [], curr: self)
  }
}

///A `Generator` for a AVLTree
public struct AVLTreeGenerator<Element : Comparable> : IteratorProtocol {

  fileprivate var (stack, curr): ([AVLTree<Element>], AVLTree<Element>)

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
