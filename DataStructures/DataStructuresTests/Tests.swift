//
//  DataStructuresTests.swift
//  DataStructuresTests
//
//  Created by Alex Usbergo on 29/12/15.
//  Copyright © 2015 Alex Usbergo. All rights reserved.
//

import XCTest
@testable import DataStructures

class GraphTest: XCTestCase {
    
    func testBreadthFirst() {
     
        let g = Graph<Int>(arrayLiteral: 1,7,4,3,5,2,6)
        
        g.addEdge(g[1], to: g[2])
        g.addEdge(g[1], to: g[3])
        g.addEdge(g[1], to: g[5])
        g.addEdge(g[2], to: g[4])
        g.addEdge(g[4], to: g[5])
        g.addEdge(g[5], to: g[6])

        //bfs visit expected [1, 2, 3, 5, 4, 6]
        let bfs = g.traverseBreadthFirst().map() { return $0.value }
        XCTAssert(bfs.count == 6)
        XCTAssert(bfs == [1,2,3,5,4,6])
        
    }
    
    func testShortestPath() {
        
        var g = Graph<Int>(arrayLiteral: 1,7,4,3,5,2,6)
        g.directed = true
        g.weighted = true
        
        g.addEdge(g[1], to: g[2], weight: 2)
        g.addEdge(g[1], to: g[3], weight: 3)
        g.addEdge(g[1], to: g[5], weight: 6)
        g.addEdge(g[2], to: g[4], weight: 1)
        g.addEdge(g[4], to: g[5], weight: 1)
        g.addEdge(g[5], to: g[6], weight: 10)
        
        //shortest path from 1 to 5, expected [1, 2, 4, 5] with cost 4
        let p = g.shortestPath(g[1], to: g[5])
        XCTAssert(p?.cost == 4)
        XCTAssert((p?.vertices.map(){ return $0.value})! == [1,2,4,5])
    }
}

class LinkedListTest: XCTestCase {
    
    func testInsertions() {
        
        let linkedList = LinkedList<Int>()
        XCTAssert(linkedList.count == 0)
        
        linkedList.append(1)
        XCTAssert(linkedList[0] == 1)
        XCTAssert(linkedList.count == 1)
        
        linkedList.append(2)
        XCTAssert(linkedList[1] == 2)
        XCTAssert(linkedList.count == 2)
        
        linkedList.append(3)
        XCTAssert(linkedList[2] == 3)
        XCTAssert(linkedList.count == 3)
        
        linkedList.append(4)
        XCTAssert(linkedList[3] == 4)
        XCTAssert(linkedList.count == 4)
        
        linkedList.append(5)
        XCTAssert(linkedList[4] == 5)
        XCTAssert(linkedList.count == 5)
    }
    
    let numberOfTries = 100
    
    func testLinkedListPerformance() {
        
        measureBlock { () -> Void in
            let l = LinkedList<Int>()
            for i in 1...self.numberOfTries { l.append(i) }
            let _ = l.reduce(0, combine: { return $0 + $1 })
            
            for i in 1...self.numberOfTries {
                if i%10 == 0 { XCTAssert(l.contains(i)) }
            }
            
            for i in 1...self.numberOfTries {
                if i % 2 == 0 { l.removeFirst() }
                else { l.removeLast() }
            }
            
            XCTAssert(l.count == 0)
        }
    }
    
    func testArrayPerformance() {
        
        measureBlock { () -> Void in
            var l = Array<Int>()
            for i in 1...self.numberOfTries { l.append(i) }
            let _ = l.reduce(0, combine: { return $0 + $1 })
            
            for i in 1...self.numberOfTries {
                if i%10 == 0 { XCTAssert(l.contains(i)) }
            }
            
            for i in 1...self.numberOfTries {
                if i % 2 == 0 { l.removeFirst() }
                else { l.removeLast() }
            }
            
            XCTAssert(l.count == 0)
        }
    }
}

class PriorityQueueTests: XCTestCase {
    
    struct TestData {
        static let Value = 50
        static let List = [4,5,3,3,1,2]
        static let Max = 5
    }
    
    var queue = PriorityQueue<Int>(>)
    
    func testEmptyQueue() {
        XCTAssertEqual(queue.count, 0)
        XCTAssertNil(queue.first)
    }
    
    func testInitWithArray() {
        queue = PriorityQueue(TestData.List, >)
        let list = TestData.List.sort(>)
        for i in 0..<list.count {
            let element = queue.dequeue()
            XCTAssertNotNil(element)
            XCTAssertEqual(element!, list[i])
        }
    }
    
    func testSingleEnqueue() {
        queue.enqueue(TestData.Value)
        XCTAssertEqual(queue.count, 1)
        XCTAssertTrue(queue.first != nil && queue.first! == TestData.Value)
    }
    
    func testConsecutiveEnqueues() {
        for i in TestData.List {
            queue.enqueue(i)
        }
        XCTAssertEqual(queue.count, TestData.List.count)
        let list = TestData.List.sort(>)
        for i in 0..<list.count {
            let element = queue.dequeue()
            XCTAssertNotNil(element)
            XCTAssertEqual(element!, list[i])
        }
        XCTAssertNil(queue.dequeue())
        XCTAssertNil(queue.first)
    }
    
    func testEmptyDequeue() {
        XCTAssertNil(queue.dequeue())
        XCTAssertNil(queue.first)
    }
    
    func testRemoveAll() {
        queue = PriorityQueue(TestData.List, >)
        queue.removeAll(keepCapacity: true)
        XCTAssertEqual(queue.count, 0)
        XCTAssertNil(queue.dequeue())
    }
    
    // MARK: SequenceType
    
    func testSequenceTypeConformance() {
        queue = PriorityQueue(TestData.List, >)
        var list = TestData.List
        for element in queue {
            if let index = list.indexOf(element) {
                list.removeAtIndex(index)
            }
        }
        XCTAssertEqual(list.count, 0)
    }
    
    // MARK: Operators
    
    func testEqual() {
        queue = PriorityQueue<Int>(>)
        var other = PriorityQueue<Int>(>)
        XCTAssertTrue(queue == other)
        queue.enqueue(TestData.Value)
        XCTAssertFalse(queue == other)
        other.enqueue(TestData.Value)
        XCTAssertTrue(queue == other)
    }
    
}

class BloomFilterTests: XCTestCase {
    
    struct TestData {
        static let FPP: Double = 0.09
        static let List = [Int](1...10)
    }
    
    var bloomFilter = BloomFilter<Int>(expectedCount: 1000, FPP: TestData.FPP)
    
    func testEmptyBloomFilter() {
        XCTAssertEqual(bloomFilter.FPP, TestData.FPP)
        XCTAssertEqual(bloomFilter.FPP, TestData.FPP)
        XCTAssertTrue(bloomFilter.isEmpty)
        XCTAssertFalse(bloomFilter.contains(1))
    }
    
    func testInsert() {
        for i in TestData.List {
            bloomFilter.insert(i)
        }
        for i in TestData.List {
            XCTAssertTrue(bloomFilter.contains(i))
        }
        XCTAssertFalse(bloomFilter.contains(-1))
    }
    
    func testRoughCount() {
        for i in TestData.List {
            bloomFilter.insert(i)
        }
        XCTAssertTrue(bloomFilter.roughCount >= 7)
        XCTAssertTrue(bloomFilter.roughCount <= 10)
    }
    
    func testRemoveAll() {
        for i in TestData.List {
            bloomFilter.insert(i)
        }
        bloomFilter.removeAll()
        XCTAssertTrue(bloomFilter.isEmpty)
        XCTAssertFalse(bloomFilter.contains(1))
    }
}

class RedBlackTreeTests: XCTestCase {
    
    func testEmptyInit() {
        let empty = RedBlackTree<Int>()
        XCTAssert(empty.isEmpty)
        XCTAssert(empty.isBalanced)
    }
    
    func testSeqInit() {
        let seq = (0...100).map { _ in arc4random_uniform(100) }
        let set = Set(seq)
        let tree = RedBlackTree(seq)
        let setFromRedBlackTree = Set(tree)
        XCTAssertEqual(set, setFromRedBlackTree)
        XCTAssert(tree.isBalanced)
    }
    
    func testArrayLiteralInit() {
        let tree: RedBlackTree = [1, 3, 5, 6, 7, 8, 9]
        XCTAssert(tree.elementsEqual([1, 3, 5, 6, 7, 8, 9]))
        XCTAssert(tree.isBalanced)
    }
    
    func testDebugDescription() {
        let seq = (0...100).map { _ in arc4random_uniform(100) }
        let arr = Set(seq).sort()
        let tre = RedBlackTree(seq)
        XCTAssertEqual(arr.debugDescription, tre.debugDescription)
        XCTAssert(tre.isBalanced)
    }
    
    func testFirst() {
        let seq = (0...100).map { _ in arc4random_uniform(100) }
        let set = Set(seq)
        let tre = RedBlackTree(seq)
        XCTAssertEqual(set.minElement(), tre.first)
        XCTAssert(tre.isBalanced)
    }
    
    func testLast() {
        let seq = (0...100).map { _ in arc4random_uniform(100) }
        let set = Set(seq)
        let tre = RedBlackTree(seq)
        XCTAssertEqual(set.maxElement(), tre.last)
        XCTAssert(tre.isBalanced)
    }
    
    func testIsEmpty() {
        let seq = (0...10).map { _ in arc4random_uniform(100) }
        XCTAssertFalse(RedBlackTree(seq).isEmpty)
        XCTAssert(RedBlackTree(seq).isBalanced)
    }
    
    func testCount() {
        let seq = (0...1000).map { _ in arc4random_uniform(100) }
        let tre = RedBlackTree(seq)
        XCTAssertEqual(Set(seq).count, tre.count)
        XCTAssert(tre.isBalanced)
    }
    
    func testContains() {
        let seq = (0...100).map { _ in Int(arc4random_uniform(100)) }
        let set = Set(seq)
        let tre = RedBlackTree(seq)
        for i in 0...110 {
            XCTAssertEqual(set.contains(i), tre.contains(i))
            XCTAssert(tre.isBalanced)
        }
    }
    
    func testRemoveMin() {
        let seq = (0...100).map { _ in Int(arc4random_uniform(100)) }
        var set = Set(seq)
        var tre = RedBlackTree(seq)
        for _ in 0...110 {
            XCTAssertEqual(set.minElement().flatMap { set.remove($0) }, tre.popFirst())
            XCTAssert(tre.isBalanced)
        }
    }
    
    func testRemoveMax() {
        let seq = (0...100).map { _ in Int(arc4random_uniform(100)) }
        var set = Set(seq)
        var tre = RedBlackTree(seq)
        for _ in 0...110 {
            XCTAssertEqual(set.maxElement().flatMap { set.remove($0) }, tre.popLast())
            XCTAssert(tre.isBalanced)
        }
    }
    
    func testRemove() {
        let seq = (0...100).map { _ in arc4random_uniform(100) }
        var set = Set(seq)
        var tre = RedBlackTree(seq)
        for _ in 0...10000 {
            let i = arc4random_uniform(110)
            XCTAssertEqual(set.remove(i), tre.remove(i))
            XCTAssert(tre.isBalanced)
        }
    }
    
    func testReverse() {
        let seq = (0...100).map { _ in Int(arc4random_uniform(100)) }
        let sorted = Set(seq).sort(>)
        let tree = RedBlackTree(seq)
        XCTAssert(sorted.elementsEqual(tree.reverse()))
        
    }
    
    func testSeqType() {
        let seq = (0...10000).map { _ in arc4random_uniform(UInt32.max) }
        let expectation = Set(seq).sort()
        let reality = RedBlackTree(seq)
        XCTAssert(expectation.elementsEqual(reality))
    }
    
    func testExclusiveOr() {
        let fst = (0...100).map { _ in Int(arc4random_uniform(100)) }
        let sec = (0...100).map { _ in Int(arc4random_uniform(100)) }
        let set = Set(fst)
        let tre = RedBlackTree(fst)
        let treeOr = tre.exclusiveOr(sec)
        let setOr = set.exclusiveOr(sec).sort()
        XCTAssert(treeOr.isBalanced)
        XCTAssert(treeOr.elementsEqual(setOr))
    }
    
    func testExclusiveOrInPlace() {
        let fst = (0...100).map { _ in Int(arc4random_uniform(100)) }
        let sec = (0...100).map { _ in Int(arc4random_uniform(100)) }
        var set = Set(fst)
        var tre = RedBlackTree(fst)
        tre.exclusiveOrInPlace(sec)
        set.exclusiveOrInPlace(sec)
        let setOr = set.sort()
        XCTAssert(tre.isBalanced)
        XCTAssert(tre.elementsEqual(setOr))
    }
    
    func testIntersect() {
        let fst = (0...100).map { _ in Int(arc4random_uniform(100)) }
        let sec = (0...100).map { _ in Int(arc4random_uniform(100)) }
        let set = Set(fst)
        let tre = RedBlackTree(fst)
        let treeIn = tre.intersect(sec)
        let setIn = set.intersect(sec).sort()
        XCTAssert(treeIn.isBalanced)
        XCTAssert(treeIn.elementsEqual(setIn))
    }

    func testDisjoint() {
        let fst = (0...100).map { _ in Int(arc4random_uniform(100)) }
        let sec = (0...100).map { _ in Int(arc4random_uniform(100)) }
        let withoutSec = Set(fst).subtract(sec)
        let tree = RedBlackTree(withoutSec)
        XCTAssert(tree.isDisjointWith(sec))
        XCTAssert(tree.isBalanced)
    }
    
    func testSuperset() {
        let fst = (0...100).map { _ in Int(arc4random_uniform(100)) }
        let sec = (0...100).map { _ in Int(arc4random_uniform(100)) }
        let with = Set(fst).union(sec)
        let tree = RedBlackTree(with)
        XCTAssert(tree.isSupersetOf(sec))
        XCTAssert(tree.isBalanced)
    }
    
    func testSubset() {
        let fst = (0...100).map { _ in Int(arc4random_uniform(100)) }
        let sec = (0...100).map { _ in Int(arc4random_uniform(100)) }
        let with = Set(fst).union(sec)
        let tree = RedBlackTree(fst)
        XCTAssert(tree.isSubsetOf(with))
        XCTAssert(tree.isBalanced)
    }
    
    func testSubtract() {
        let fst = (0...100).map { _ in Int(arc4random_uniform(100)) }
        let sec = (0...100).map { _ in Int(arc4random_uniform(100)) }
        let withoutSec = Set(fst).subtract(sec)
        let withoutTre = RedBlackTree(fst).subtract(sec)
        XCTAssert(withoutSec.sort().elementsEqual(withoutTre))
        XCTAssert(withoutTre.isBalanced)
    }
    
    func testSubtractInPlace() {
        let fst = (0...100).map { _ in Int(arc4random_uniform(100)) }
        let sec = (0...100).map { _ in Int(arc4random_uniform(100)) }
        var withoutSec = Set(fst)
        withoutSec.subtractInPlace(sec)
        var withoutTre = RedBlackTree(fst)
        withoutTre.subtractInPlace(sec)
        XCTAssert(withoutSec.sort().elementsEqual(withoutTre))
        XCTAssert(withoutTre.isBalanced)
    }
    
    func testUnion() {
        let fst = (0...100).map { _ in Int(arc4random_uniform(100)) }
        let sec = (0...100).map { _ in Int(arc4random_uniform(100)) }
        let unionSet = Set(fst).union(sec)
        let unionTre = RedBlackTree(fst).union(sec)
        XCTAssert(unionSet.sort().elementsEqual(unionTre))
        XCTAssert(unionTre.isBalanced)
    }
    
    func testUnionInPlace() {
        let fst = (0...100).map { _ in Int(arc4random_uniform(100)) }
        let sec = (0...100).map { _ in Int(arc4random_uniform(100)) }
        var unionSet = Set(fst)
        unionSet.unionInPlace(sec)
        var unionTre = RedBlackTree(fst)
        unionTre.unionInPlace(sec)
        XCTAssert(unionSet.sort().elementsEqual(unionTre))
        XCTAssert(unionTre.isBalanced)
    }
    
}
