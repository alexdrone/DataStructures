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
    
    func testDfs() {
        var g = Graph<Int>(arrayLiteral: 1,7,4,3,5,2,6)
        g.directed = false
        
        g.addEdge(g[1], to: g[2], weight: 2)
        g.addEdge(g[1], to: g[3], weight: 3)
        g.addEdge(g[1], to: g[5], weight: 6)
        g.addEdge(g[2], to: g[4], weight: 1)
        g.addEdge(g[4], to: g[5], weight: 1)
        g.addEdge(g[5], to: g[6], weight: 10)
    }
    
    let noCycle: Dictionary<String, [String]> = [
        "A": [],  "B": [],  "C": ["D"], "D": ["A"], "E": ["C", "B"],  "F": ["E"]
    ]
    
    let cycle: Dictionary<String, [String]> = [
        "A": [],  "B": ["F"],  "C": ["D"],   "D": ["A"],  "E": ["C", "B"],  "F": ["E"],
    ]
    
    let noCycleResult = ["A", "B", "D", "C", "E", "F"]

    func testTopoSort() {
        
        XCTAssert(try! topoSort(noCycle) == noCycleResult)
        
        do {
            try topoSort(cycle)
            XCTAssert(false)

        } catch {
            XCTAssert(true)
        }
    }
    
    func testTopologicalSort() {
        
        var g = Graph<String>(directed: true, weighted: false)
        g.populateFromDependencyList(noCycle)

        XCTAssert(try! topoSort(g.toDependencyList()) == noCycleResult)
        XCTAssert(g.isDirectedAcyclic() == true)
        
        g = Graph<String>(directed: true, weighted: false)
        g.populateFromDependencyList(cycle)
        XCTAssert(g.isDirectedAcyclic() == false)

        do {
            try topoSort(g.toDependencyList())
            XCTAssert(false)
            
        } catch {
            XCTAssert(true)
        }
        
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

class TrieTests: XCTestCase {
    
    struct TestData {
        static let Elements = ["Hello", "Hel", "Apple", "Y", "Yes", "NO", ""]
    }
    
    var trie = Trie()
    
    func testEmptyTrie() {
        XCTAssertEqual(trie.count, 0)
        XCTAssertEqual(trie.elements, [])
    }
    
    func testInitWithArray() {
        trie = Trie(TestData.Elements)
        XCTAssertEqual(trie.count, TestData.Elements.count)
        for element in TestData.Elements {
            XCTAssertTrue(trie.contains(element))
        }
        XCTAssertEqual(Set(trie.elements), Set(TestData.Elements))
    }
    
    func testEmptyContains() {
        XCTAssertFalse(trie.contains(""))
    }
    
    func testNonEmptyContains() {
        trie = Trie(TestData.Elements)
        for element in TestData.Elements {
            XCTAssertTrue(trie.contains(element))
        }
        XCTAssertFalse(trie.contains("H"))
    }
    
    func testContiansEmptyPrefix() {
        XCTAssertTrue(trie.isPrefix(""))
        trie = Trie(TestData.Elements)
        XCTAssertTrue(trie.isPrefix(""))
    }
    
    func testContiansValidPrefix() {
        trie = Trie(TestData.Elements)
        XCTAssertTrue(trie.isPrefix("Hell"))
        XCTAssertTrue(trie.isPrefix("H"))
        XCTAssertTrue(trie.isPrefix("Y"))
        XCTAssertTrue(trie.isPrefix("NO"))
    }
    
    func testContiansInvalidPrefix() {
        trie = Trie(TestData.Elements)
        XCTAssertFalse(trie.isPrefix("Yello"))
        XCTAssertFalse(trie.isPrefix("Hello World"))
        XCTAssertFalse(trie.isPrefix("Yeah"))
        XCTAssertFalse(trie.isPrefix("NOse"))
    }
    
    func testfindPrefix() {
        trie = Trie(TestData.Elements)
        XCTAssertEqual(trie.findPrefix("Hello World"), [])
        XCTAssertEqual(Set(trie.findPrefix("")), Set(TestData.Elements))
        XCTAssertEqual(Set(trie.findPrefix("Y")), Set(["Y", "Yes"]))
        XCTAssertEqual(Set(trie.findPrefix("Hel")), Set(["Hel", "Hello"]))
        XCTAssertEqual(Set(trie.findPrefix("NO")), Set(["NO"]))
    }
    
    func testlongestPrefixIn() {
        trie = Trie(TestData.Elements)
        XCTAssertEqual(trie.longestPrefixIn(""), "")
        XCTAssertEqual(trie.longestPrefixIn("abc"), "")
        XCTAssertEqual(trie.longestPrefixIn("Hello World"), "Hello")
        XCTAssertEqual(trie.longestPrefixIn("Hel"), "Hel")
        XCTAssertEqual(trie.longestPrefixIn("Y"), "Y")
        XCTAssertEqual(trie.longestPrefixIn("Apple"), "Apple")
    }
    
    func testInsert() {
        trie.insert("abc")
        XCTAssertEqual(trie.elements, ["abc"])
        XCTAssertTrue(trie.contains("abc"))
    }
    
    func testRemoveFromEmptyTrie() {
        XCTAssertNil(trie.remove(""))
        XCTAssertEqual(trie.count, 0)
    }
    
    func testRemove() {
        trie = Trie(TestData.Elements)
        XCTAssertNotNil(trie.remove(""))
        XCTAssertFalse(trie.contains(""))
        XCTAssertEqual(Set(trie.elements), Set(["Hello", "Hel", "Apple", "Y", "Yes", "NO"]))
        XCTAssertNil(trie.remove("H"))
        XCTAssertEqual(Set(trie.elements), Set(["Hello", "Hel", "Apple", "Y", "Yes", "NO"]))
        XCTAssertNotNil(trie.remove("Y"))
        XCTAssertEqual(Set(trie.elements), Set(["Hello", "Hel", "Apple", "Yes", "NO"]))
        XCTAssertNotNil(trie.remove("Hello"))
        XCTAssertEqual(Set(trie.elements), Set(["Hel", "Apple", "Yes", "NO"]))
        XCTAssertEqual(trie.count, TestData.Elements.count - 3)
    }
    
    func testRemoveAll() {
        trie = Trie(TestData.Elements)
        trie.removeAll()
        XCTAssertEqual(trie.count, 0)
        XCTAssertEqual(trie.elements, [])
    }
    
    func testHashableConformance() {
        trie = Trie(TestData.Elements)
        var other = Trie()
        XCTAssertNotEqual(trie.hashValue, other.hashValue)
        XCTAssertTrue(trie != other)
        other = Trie(Array(TestData.Elements.reverse()))
        XCTAssertEqual(trie.hashValue, trie.hashValue)
        XCTAssertTrue(trie == other)
    }
}

class MultimapTests: XCTestCase {
    
    struct TestData {
        static let Dictionary = [1: 2,2: 3, 3: 4]
    }
    
    var multimap = Multimap<Int, Int>()
    
    func testEmptyMultimap() {
        XCTAssertEqual(multimap.count, 0)
        XCTAssertEqual(multimap.keyCount, 0)
        XCTAssertEqual(multimap.valuesForKey(1), [])
    }
    
    func testInitWithDictionary() {
        multimap = Multimap(TestData.Dictionary)
        XCTAssertEqual(multimap.count, TestData.Dictionary.count)
        XCTAssertEqual(multimap.keyCount, TestData.Dictionary.count)
        for (k,v) in TestData.Dictionary {
            XCTAssertTrue(multimap.containsValue(v, forKey: k))
        }
    }
    
    func testValuesForKey() {
        multimap = Multimap(TestData.Dictionary)
        XCTAssertEqual(multimap.valuesForKey(1), [2])
    }
    
    func testContainsKey() {
        multimap = Multimap(TestData.Dictionary)
        XCTAssertTrue(multimap.containsKey(1))
        XCTAssertFalse(multimap.containsKey(100))
    }
    
    func testContainsValueForKey() {
        multimap = Multimap(TestData.Dictionary)
        XCTAssertTrue(multimap.containsValue(3, forKey: 2))
        XCTAssertFalse(multimap.containsValue(2, forKey: 2))
        XCTAssertFalse(multimap.containsValue(2, forKey: 100))
    }
    
    func testSubscript() {
        multimap = Multimap(TestData.Dictionary)
        XCTAssertEqual(multimap.valuesForKey(1), [2])
        XCTAssertEqual(multimap.valuesForKey(100), [])
    }
    
    func testInsertValueForKey() {
        multimap.insertValue(10, forKey: 5)
        XCTAssertEqual(multimap.count, 1)
        XCTAssertEqual(multimap.keyCount, 1)
        XCTAssertEqual(multimap[5], [10])
    }
    
    func testInsertValuesForKey() {
        multimap.insertValues([1, 2], forKey: 5)
        XCTAssertEqual(multimap.count, 2)
        XCTAssertEqual(multimap.keyCount, 1)
        XCTAssertTrue(multimap.containsValue(1, forKey: 5))
        XCTAssertTrue(multimap.containsValue(2, forKey: 5))
        XCTAssertFalse(multimap.containsValue(3, forKey: 5))
    }
    
    func testReplaceValuesForKey() {
        multimap.insertValues([1, 2, 3], forKey: 5)
        multimap.insertValues([1, 2, 3], forKey: 10)
        multimap.replaceValues([10], forKey: 5)
        XCTAssertEqual(multimap.count, 4)
        XCTAssertEqual(multimap.keyCount, 2)
        XCTAssertEqual(multimap[5], [10])
    }
    
    func testRemoveValueForKey() {
        multimap.insertValues([1, 2, 2], forKey: 5)
        multimap.removeValue(2, forKey: 5)
        XCTAssertEqual(multimap.count, 2)
        XCTAssertEqual(multimap.keyCount, 1)
        XCTAssertTrue(multimap.containsValue(1, forKey: 5))
        XCTAssertTrue(multimap.containsValue(2, forKey: 5))
        multimap.removeValue(2, forKey: 5)
        XCTAssertFalse(multimap.containsValue(2, forKey: 5))
        XCTAssertTrue(multimap.containsValue(1, forKey: 5))
    }
    
    func testRemoveValuesForKey() {
        multimap.insertValues([1, 2, 2], forKey: 5)
        multimap.insertValues([2], forKey: 10)
        multimap.removeValuesForKey(5)
        XCTAssertEqual(multimap.count, 1)
        XCTAssertEqual(multimap.keyCount, 1)
        XCTAssertFalse(multimap.containsValue(1, forKey: 5))
        XCTAssertTrue(multimap.containsValue(2, forKey: 10))
    }
    
    func testRemoveAll() {
        multimap = Multimap(TestData.Dictionary)
        multimap.removeAll(keepCapacity: true)
        XCTAssertEqual(multimap.count, 0)
        XCTAssertEqual(multimap.keyCount, 0)
        XCTAssertEqual(multimap.valuesForKey(1), [])
    }
    
    func testSequenceTypeConformance() {
        multimap.insertValues([1, 2, 2], forKey: 5)
        multimap.insertValues([5], forKey: 10)
        var values = [1, 2, 2, 5]
        var keys = [5,5,5, 10]
        for (key, value) in multimap {
            if let index = values.indexOf(value) {
                values.removeAtIndex(index)
            }
            if let index = keys.indexOf(key) {
                keys.removeAtIndex(index)
            }
        }
        XCTAssertEqual(values.count, 0)
        XCTAssertEqual(keys.count, 0)
    }
    
    func testDictionaryLiteralConvertibleConformance() {
        multimap = [1:2, 2:2, 2:2]
        XCTAssertEqual(multimap.count, 3)
        XCTAssertEqual(multimap.keyCount, 2)
        XCTAssertEqual(multimap.valuesForKey(1), [2])
        XCTAssertEqual(multimap.valuesForKey(2), [2,2])
    }
    
    func testEquatableConformance() {
        multimap = Multimap(TestData.Dictionary)
        var other = Multimap<Int, Int>()
        XCTAssertTrue(multimap != other)
        other = Multimap(multimap)
        XCTAssertTrue(multimap == other)
    }
}
