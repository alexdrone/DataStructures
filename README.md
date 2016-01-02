# DataStructures

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build](https://img.shields.io/badge/build-passing-green.svg?style=flat)](#)
[![Platform](https://img.shields.io/badge/platform-ios | osx | watchos | tvos -lightgrey.svg?style=flat)](#)
[![Build](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://opensource.org/licenses/MIT)

A collection of data structures implemented in Swift.
For the time being the available data structures are:

- LinkedList
- SortedLinkedList
- Stack
- Queue
- Graph 
- BinaryHeap
- PriorityQueue*
- BloomFilter*
- Trie*
- RedBlackTree

## Installation

### Carthage

To install Carthage, run (using Homebrew):

```bash
$ brew update
$ brew install carthage
```

Then add the following line to your `Cartfile`:

```
github "alexdrone/DataStructures" "master"    

```

## Usage

All collection types are implemented as structures with the exception of the LinkedList data structure. This means they are copied when they are assigned to a new constant or variable, or when they are passed to a function or method. 

About copying structs:  

> The behavior you see in your code will always be as if a copy took place. However, Swift only performs an actual copy behind the scenes when it is absolutely necessary to do so. Swift manages all value copying to ensure optimal performance, and you should not avoid assignment to try to preempt this optimization.

## Walkthrough


###LinkedList

All of the operations perform as could be expected for a doubly-linked list. Operations that index into the list will traverse the list from the beginning or the end, whichever is closer to the specified index.

Note that this implementation is not synchronized. If multiple threads access a linked list concurrently, and at least one of the threads modifies the list structurally, it must be synchronized externally.

```swift
import DataStructures

let linkedList = LinkedList<Int>()
linkedList.append(1)
linkedList.append(2)

print(linkedList) //[1,2]

let sortedLinkedList = SortedLinkedList<Int>()
linkedList.append(3)
linkedList.append(1)
linkedList.append(2)

print(sortedLinkedList) //[1,2,3]

```


###Graph

A graph can be constructed from a array literal, or a dependency list.
Operations like *BFS* and *DFS* visit, *shortestPath* and *topologicalSort* are available to the user.


```swift
import DataStructures

//Graph (graphs can be directed/undirected and weighted/not weighted)
let graph = Graph<Int>(arrayLiteral: 1,7,4,3,5,2,6)

graph.addEdge(g[1], to: g[2])
graph.addEdge(g[1], to: g[3])
graph.addEdge(g[1], to: g[5])
graph.addEdge(g[2], to: g[4])
graph.addEdge(g[4], to: g[5])
graph.addEdge(g[5], to: g[6])

//bfs visit expected [1, 2, 3, 5, 4, 6]
let bfs = g.traverseBreadthFirst().map() { return $0.value }

//shortest path

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
(p?.vertices.map(){ return $0.value} //[1,2,4,5]

///topological sort and cycle check
let noCycle: Dictionary<String, [String]> = [ "A": [],  "B": [],  "C": ["D"], "D": ["A"], "E": ["C", "B"],  "F": ["E"] ]

var g = Graph<String>(directed: true, weighted: false)
g.populateFromDependencyList(noCycle)

g.isDirectedAcyclic() //true
g.topologicalSort() // ["A", "B", "D", "C", "E", "F"]
 

```


```swift

 
//Stacks and Queues are implemented through Array and LinkedList extension

extension LinkedList : Stack {
    public func pop() -> T?
    public func push(element: T)
    public func peekStack() -> T?
}

extension Array : Stack {
    public func pop() -> T?
    public func push(element: T)
    public func peekStack() -> T?
}

extension LinkedList: Queue {
    public func enqueue(element: Q)    
    public func dequeue() -> Q?     
    public func peekQueue() -> Q?
}

extension Array: Queue {
    public func enqueue(element: Q)    
    public func dequeue() -> Q?     
    public func peekQueue() -> Q?
}

//PriorityQueue*
var pQueue = PriorityQueue<Int>(<)
pQueue.enqueue(3)
pQueue.enqueue(1)
pQueue.enqueue(2)
pQueue.dequeue() // 1

//BloomFilter*
var bFilter = BloomFilter<String>(expectedCount: 100)
bFilter.insert("a")
bFilter.contains("a") // true

//Trie*
var trie = Trie()
trie.insert("Apple")
trie.insert("App Store")
trie.findPrefix("App") // ["App Store", "Apple"]

///RedBlackTree*
 let tree = RedBlackTree<Int>(arrayLiteral:[1, 3, 5, 6, 7, 8, 9])
 tree.popFirst()

```

## Credits
\* Currently the PriorityQueue and the BloomFilter data structures are forked from the excellent [Buckets](https://github.com/mauriciosantos/Buckets-Swift/) github project. I higly suggest to check it out!
The RedBlackTree datastructure is adapted from [SwiftDataStructures](https://github.com/oisdk/SwiftDataStructures) 