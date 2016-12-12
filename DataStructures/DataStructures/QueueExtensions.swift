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

public protocol Queue { associatedtype Q }

/// FIFO (first-in first-out) Queue
extension LinkedList: Queue {

  public typealias Q = T

  /// Add this element at the end of the queue
  public func enqueue(_ element: Q) {
    self.append(element)
  }

  /// Returns and remove the first element of the queue
  public func dequeue() -> Q? {
    return self.removeFirst()
  }

  /// Returns the first element of the queue
  public func peekQueue() -> Q? {
    return self.head.next?.element
  }
}

/// FIFO (first-in first-out) Queue
extension Array: Queue {

  public typealias Q = Element

  // /Add this element at the end of the queue
  public mutating func enqueue(_ element: Q) {
    self.append(element)
  }

  /// Returns and remove the first element of the quemutating ue
  public mutating func dequeue() -> Q? {
    return self.removeFirst()
  }

  /// Returns the first element of the queue
  public func peekQueue() -> Q? {
    return self.first
  }
}

extension PriorityQueue: Queue {

  public typealias Q = T

  /// Returns the first element of the queue
  public func peekQueue() -> Q? {
    return self.first
  }
}

