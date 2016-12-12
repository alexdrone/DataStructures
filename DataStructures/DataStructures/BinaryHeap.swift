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
// Forked from mauriciosantos/Buckets-Swift/

import Foundation

// Max Heap
struct BinaryHeap<T> : Sequence {

  var isEmpty: Bool {
    return items.isEmpty
  }
  var count: Int {
    return items.count
  }
  var max: T? {
    return items.first
  }

  // returns true if the first argument has the highest priority
  fileprivate let isOrderedBefore: (T,T) -> Bool
  fileprivate var items = [T]()

  init(compareFunction: @escaping (T,T) -> Bool) {
    isOrderedBefore = compareFunction
  }

  mutating func insert(_ element: T) {
    items.append(element)
    siftUp()
  }

  mutating func removeMax() -> T? {
    if !isEmpty {
      let value = items[0]
      items[0] = items[count - 1]
      items.removeLast()
      if !isEmpty {
        siftDown()
      }
      return value
    }
    return nil
  }

  mutating func removeAll(keepingCapacity keep: Bool = false)  {
    items.removeAll(keepingCapacity: keep)
  }

  func makeIterator() -> AnyIterator<T> {
    return AnyIterator(items.makeIterator())
  }

  fileprivate mutating func siftUp() {
    func parent(_ index: Int) -> Int {
      return (index - 1) / 2
    }

    var i = count - 1
    var parentIndex = parent(i)
    while i > 0 && !isOrderedBefore(items[parentIndex], items[i]) {
      swap(&items[i], &items[parentIndex])
      i = parentIndex
      parentIndex = parent(i)
    }
  }

  fileprivate mutating func siftDown() {
    // Returns the index of the maximum element if it exists, otherwise -1
    func maxIndex(_ i: Int, _ j: Int) -> Int {
      if j >= count && i >= count {
        return -1
      } else if j >= count && i < count {
        return i
      } else if isOrderedBefore(items[i], items[j]) {
        return i
      } else {
        return j
      }
    }

    func leftChild(_ index: Int) -> Int {
      return (2 * index) + 1
    }

    func rightChild(_ index: Int) -> Int {
      return (2 * index) + 2
    }

    var i = 0
    var max = maxIndex(leftChild(i), rightChild(i))
    while max >= 0 && !isOrderedBefore(items[i], items[max]) {
      swap(&items[max], &items[i])
      i = max
      max = maxIndex(leftChild(i), rightChild(i))
    }
  }
}

// MARK: Heap Operators

/// Returns `true` if and only if the heaps contain the same elements
/// in the same order.
/// The underlying elements must conform to the `Equatable` protocol.
func ==<U: Equatable>(lhs: BinaryHeap<U>, rhs: BinaryHeap<U>) -> Bool {
  return lhs.items.sorted(by: lhs.isOrderedBefore) == rhs.items.sorted(by: rhs.isOrderedBefore)
}

func !=<U: Equatable>(lhs: BinaryHeap<U>, rhs: BinaryHeap<U>) -> Bool {
  return !(lhs==rhs)
}

