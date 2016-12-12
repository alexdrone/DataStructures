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

public protocol Stack { associatedtype E }

/// LIFO (last-in first-out) Stack
extension LinkedList: Stack {

  public typealias E = T

  /// Removes the object at the top of this stack and returns that object as the value 
  /// of this function.
  public func pop() -> E? {
    return self.removeLast()
  }

  /// Pushes an item onto the top of this stack.
  public func push(_ element: E) {
    self.append(element)
  }

  /// Looks at the object at the top of this stack without removing it from the stack.
  public func peekStack() -> E? {
    guard let node = self.tail else { return nil }
    return node.element
  }
}

///LIFO (last-in first-out) Stack
extension Array: Stack {

  public typealias E = Element

  /// Removes the object at the top of this stack and returns that object as the value
  // of this function.
  public mutating func pop() -> E? {
    return self.removeLast()
  }

  /// Pushes an item onto the top of this stack.
  public mutating func push(_ element: E) {
    self.append(element)
  }

  /// Looks at the object at the top of this stack without removing it from the stack.
  public func peekStack() -> E? {
    return self.last
  }
}
