//
//  Graph.swift
//  Primer
//
//  Created by Alex Usbergo on 28/12/15.
//  Copyright © 2015 Alex Usbergo. All rights reserved.
//

import Foundation

private struct Edge<T:Equatable>: Equatable {
    
    ///The vertices associated to this edge
    private var vertices: (from:Vertex<T>, to:Vertex<T>)
    
    ///The wight for this edge
    private let weight: Double
    
    ///Creates a new edge
    private init(from: Vertex<T>, to: Vertex<T>, weight: Double = 1) {
        self.vertices = (from, to)
        self.weight = weight
    }
}

private enum VertexColor: Int { case White, Gray, Black }

public class Vertex<T:Equatable>: Hashable {
    
    ///The value for the vertex
    public let value: T
    
    ///Wheter this vertex has been visited or not
    private var color = VertexColor.White
    
    ///The edges from this vertex
    private var edges = [Edge<T>]()
    
    private let id: Int = NSUUID().UUIDString.hash
    
    ///The hash value
    public var hashValue: Int {
        return id
    }
    
    private init(value: T) {
        self.value = value
    }
}

extension Vertex: CustomStringConvertible {
    
    ///A textual representation of `self`.
    public var description: String {
        return "<Vertex \(self.value)>"
    }
}

public func ==<T>(lhs: Vertex<T>, rhs: Vertex<T>) -> Bool {
    return lhs.id == rhs.id
}

private func ==<T>(lhs: Edge<T>, rhs: Edge<T>) -> Bool {
    return lhs.vertices.from.value == rhs.vertices.from.value && rhs.vertices.to.value == rhs.vertices.to.value && lhs.weight == rhs.weight
}

public struct Graph<T:Equatable>: ArrayLiteralConvertible {
    
    public typealias Element = T
    
    ///All the vertices in this graph
    public var vertices = [Vertex<T>]()
    
    ///Wether this is a directed graph or not
    public var directed: Bool = false
    
    ///Wether the graph is weighted or not
    public var weighted: Bool = false
    
    ///The default starting vertex for graph traversals
    public var head: Vertex<T>?
    
    public subscript(index: T) -> [Vertex<T>] {
        return vertices.filter() { $0.value == index }
    }
    
    public subscript(index: T) -> Vertex<T> {
        return vertices.filter() { $0.value == index }.first!
    }
    
    public subscript(from: T, to:T) -> Double {
        
        get {
            guard let fromVertex: Vertex<T> = self[from],
                  let toVertex: Vertex<T> = self[to] else { return Double.infinity }
            
            guard let edge = fromVertex.edges.filter({ return $0.vertices.to == toVertex}).first else { return Double.infinity }
            
            return edge.weight
        }
        
        set (weight) {
            guard let fromVertex: Vertex<T> = self[from],
                  let toVertex: Vertex<T> = self[to] else { return }
            
            //creates a edge
            self.addEdge(fromVertex, to: toVertex, weight: weight)
        }
    }
    
    
    /// Create a new instance of the graph
    public init(directed: Bool = false, weighted: Bool = false) {
        self.directed = directed
        self.weighted = weighted
    }
    
    /// Create an instance initialized with `elements`.
    public init(arrayLiteral elements: Element...) {
        for element in elements {
            self.addVertex(element)
        }
    }
    
    ///Add a node to the graph
    public mutating func addVertex(value: T) -> Vertex<T> {
        let vertex = Vertex(value: value)
        self.vertices.append(vertex)
        return vertex
    }
    
    ///Remove a vertex from the graph
    public mutating func removeVertext(vertex: Vertex<T>) {
        
        func removeVertexFromEdges(fromVertex: Vertex<T>) {
            let edges = fromVertex.edges.filter() { return $0.vertices.to != vertex }
            fromVertex.edges = edges
        }
        
        for v in self.vertices {
            removeVertexFromEdges(v)
        }
        
        self.vertices = self.vertices.filter() { return $0 != vertex }
    }
    
    ///Creates an edge from/to the vertices passed as argument
    public func addEdge(from: Vertex<T>, to: Vertex<T>, weight: Double = 1) {
        
        let edge = Edge(from: from, to: to, weight: weight)
        from.edges.append(edge)
        
        if !self.directed {
            let reversedEdge = Edge(from: to, to: from, weight: weight)
            if !to.edges.contains(reversedEdge) {
                to.edges.append(reversedEdge)
            }
        }
    }
    
    ///Remove an edge from the graph
    public func removeEdge(from: Vertex<T>, to: Vertex<T>) {
        
        let edges = from.edges.filter() { return $0.vertices.to != to }
        from.edges = edges
        
        if !self.directed {
            let toEdges = to.edges.filter() { return $0.vertices.from != from }
            to.edges = toEdges
        }
    }
    
}

extension Graph {

    ///Performs a bfs search, complexity 
    ///- Complexity: O(|E|+|V|)
    public func traverseBreadthFirst(start: Vertex<T>? = nil) -> [Vertex<T>] {
        
        let head = self.head ?? self.vertices.first
        guard let start = start ?? head else { return [Vertex<T>]() }
        
        var result = [Vertex<T>]()
        
        var queue = [Vertex<T>]()
        queue.enqueue(start)
        
        while !queue.isEmpty {
            
            //get a vertex
            let vertex = queue.dequeue()!
            
            for e in vertex.edges {
                
                //adds the 'to' vertex if the node is node visited yet
                if e.vertices.to.color == VertexColor.White {
                    e.vertices.to.color = VertexColor.Gray
                    queue.enqueue(e.vertices.to)
                }
            }
            
            //mark this node as visited
            vertex.color = VertexColor.Black
            result.enqueue(vertex)
        }
        
        //reset the vertices
        for vertex in result {
            vertex.color = VertexColor.White
        }
        
        return result
    }
    
    ///Performs a dfs search
    ///- Complexity: O(|E|+|V|)
    public func traverseDepthFirst(start: Vertex<T>? = nil) -> [Vertex<T>] {
        
        let head = self.head ?? self.vertices.first
        guard let start = start ?? head else { return [Vertex<T>]() }
        
        var result = [Vertex<T>]()
        
        var stack = [Vertex<T>]()
        stack.push(start)
        
        while !stack.isEmpty {
            
            //get a vertex
            let vertex = stack.pop()!
            
            //mark this node as visited
            result.append(vertex)
            vertex.color = VertexColor.Black
            
            for e in vertex.edges {
                
                //adds the 'to' vertex if the node is node visited yet
                if e.vertices.to.color == VertexColor.White {
                    e.vertices.to.color = VertexColor.Gray
                    stack.push(e.vertices.to)
                }
            }
        }
        
        //reset the vertices
        for vertex in result {
            vertex.color = VertexColor.White
        }
        
        return result
    }
}

extension Graph: CustomStringConvertible {
    
    ///A textual representation of `self`.
    public var description: String {
        return self.map() { return $0 }.description
    }
}

extension Graph: SequenceType {
    
    public typealias Generator = GraphGenerator<T>
    
    ///Return a *generator* over the elements of this *sequence*.
    public func generate() -> Generator {
        let bfs = self.traverseBreadthFirst(self.head).map() { return $0.value }
        return GraphGenerator<T>(bfs: bfs)
    }
}

public struct GraphGenerator<T:Equatable>: GeneratorType {
    
    public typealias Element = T
    
    private let bfs: [Element]
    private var index: Int = 0
    
    private init(bfs: [Element]) {
        self.bfs = bfs
    }
    
    ///Advance to the next element and return it, or `nil` if no next element exists.
    public mutating func next() -> Element? {
        if index < bfs.count {
            return self.bfs[self.index++]
        }
        return nil
    }
}

//MARK: - Shortest Path

public struct Path<T:Equatable>: Equatable {
    
    ///The cost and the previous cost
    public let cost: Double
    
    ///All the vertices included in the path
    public let vertices: [Vertex<T>]
    
    ///The final destination for this path
    public var destination: Vertex<T>? {
        return self.vertices.last
    }
    
    private init(cost: Double, vertices: [Vertex<T>] = [Vertex<T>]()) {
        self.cost = cost
        self.vertices = vertices
    }
    
    ///Creates a new path to the vertex passed as argument and with the additional cost
    private func appendNew(increment: Double, to:Vertex<T>) -> Path<T> {
        var v = self.vertices
        v.append(to)
        return Path(cost: self.cost + increment, vertices: v)
    }
}

extension Path: CustomStringConvertible {
    
    ///A textual representation of `self`.
    public var description: String {
        return "<Path(\(cost)) \(vertices)>"
    }
}

public func ==<T>(lhs: Path<T>, rhs: Path<T>) -> Bool {
    return lhs.cost == rhs.cost && lhs.vertices == rhs.vertices
}

private func +<T>(lhs: Path<T>, rhs:(Double,Vertex<T>)) -> Path<T> {
    return lhs.appendNew(rhs.0, to: rhs.1)
}

extension Graph {
    
    ///Compute the shortest path from a node to another using Dijkstra's algorithm.
    ///- Note: Make sure your graph is a DAG before attempting to compute the shortest path.
    /// You can do so by calling the 'isDirectedAcyclic()' method.
    ///- Complexity: O(|E|+|V|log|V|)
    public func shortestPath(from: Vertex<T>, to: Vertex<T>) -> Path<T>? {
        
        var frontier = PriorityQueue<Path<T>>({ return $0.cost < $1.cost })
        var final = [Path<T>]()
        
        //use the source edges to create the frontier
        for e in from.edges {
            frontier.enqueue(Path(cost: e.weight, vertices: [from, e.vertices.to]))
        }
        
        //support path changes using the greedy approach
        while !frontier.isEmpty {
            
            let bestPath = frontier.dequeue()!

            //enumerate the bestPath edges
            guard let edges = bestPath.destination?.edges else { continue }
            
            for e in edges {
                let path = bestPath + (e.weight, e.vertices.to)
                
                if !frontier.contains(path) {
                    frontier.enqueue(path)
                }
            }
            
            //preserve the best path
            if bestPath.destination == to {
                final.append(bestPath)
            }
            
        }
        
        var shortestPath = Path<T>(cost: Double.infinity)
        
        for path in final {
            if path.destination == to && path.cost < shortestPath.cost {
                shortestPath = path
            }
        }
        
        //there's no path found
        if shortestPath.destination == nil {
            return nil
        }
        
        return shortestPath
    }

}

//MARK: - Topological Sort

extension Graph where T: Hashable {

    ///Creates a graph with a dependency list
    ///e.g: {"foo": ["bar", "baz"], "bar"; ["baz"], "baz": [], "etc": []}
    public mutating func populateFromDependencyList(dependencyList: [T:[T]]) {
        self.directed = true

        //creates all the vertices
        for (key,_) in dependencyList {
            self.addVertex(key)
        }
        
        //adds the edges from the dependency list
        for (key, list) in dependencyList {
            for value in list {
                self.addEdge(self[key], to: self[value])
            }
        }
    }
    
    ///Export the graph into a dependency list.
    ///- Note: If this graph is weighted, that information is going to be lost
    ///- Note: This method fails if this graph is a undirected one
    public func toDependencyList() -> [T: [T]] {
        
        //A directed graph has a
        assert(self.directed)

        var dependencyList = [T: [T]]()
        for v in self.vertices {
            dependencyList[v.value] = [T]()
        }
        
        for v in self.vertices {
            for e in v.edges {
                dependencyList[v.value]?.append(e.vertices.to.value)
            }
        }
        
        return dependencyList
    }
}

extension Graph  {
    
    ///Returns 'true' if this graph is a directed acyclic graph
    ///- Complexity: is O(|E|+|V|)
    public func isDirectedAcyclic() -> Bool {

        //not directed
        if !self.directed {
            return false
        }
        
        do {
            
            //Try to run a toposort, if there's a cycle an exception is going to be thrown
            try self.topologicalSort()
            return true
            
        } catch {
            //cycle error
            return false
        }
    }
    
    ///Topological ordering of a directed graph is a linear ordering of its vertices such that for
    ///every directed edge uv from vertex u to vertex v, u comes before v in the ordering.
    ///- Complexity: is O(|E|+|V|)
    public func topologicalSort() throws -> [Vertex<T>] {
        
        //Creates a dependency list based on the vertices ids
        var dependencyList = [Int: [Int]]()
        var map = [Int: Vertex<T>]()
        for v in self.vertices {
            map[v.id] = v
            dependencyList[v.id] = [Int]()
        }
        
        for v in self.vertices {
            for e in v.edges {
                dependencyList[v.id]?.append(e.vertices.to.id)
            }
        }
        
        return try topoSort(dependencyList).map() { return map[$0]! }
    }
}

enum TopologicalSortError : ErrorType {
    
    ///The dependency list contains a loop
    case CycleError(String)
}

///General topological sort function
public func topoSort<T:Comparable>(dependencyList:[T:[T]]) throws -> [T] {
    
    //Simple helper method to check if a dependecy list is empty
    func isEmpty(graph: [T:[T]]) -> Bool {
        for (_, value) in graph {
            if value.count > 0 { return false }
        }
        return true
    }
    
    var sorted: [T] = []
    var nextDepth: [T] = []
    var graph = dependencyList
    
    for key in graph.keys { if graph[key]! == [] { nextDepth.append(key) } }
    for key in nextDepth { graph.removeValueForKey(key) }
    
    while nextDepth.count != 0 {
        
        nextDepth.sortInPlace() { return $0 > $1}
        let node = nextDepth.removeLast()
        
        sorted.append(node)
        
        for key in graph.keys {
            
            if  graph[key]!.filter({ $0 == node}).count > 0 {
                graph[key] = graph[key]?.filter({$0 != node})
                if graph[key]?.count == 0 { nextDepth.append(key) }
            }
        }
    }
    
    if !isEmpty(graph) { throw TopologicalSortError.CycleError("This dependency list contains a cycle")
    } else { return sorted }
}

