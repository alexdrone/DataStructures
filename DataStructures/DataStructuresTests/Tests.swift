//
//  DataStructuresTests.swift
//  DataStructuresTests
//
//  Created by Alex Usbergo on 29/12/15.
//  Copyright © 2015 Alex Usbergo. All rights reserved.
//

import XCTest
import DataStructures

class DataStructuresTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLinkedList() {
        
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
