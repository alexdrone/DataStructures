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
    private let weight: Int
    
    ///Creates a new edge
    private init(from: Vertex<T>, to: Vertex<T>, weight: Int = 1) {
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
    public func addEdge(from: Vertex<T>, to: Vertex<T>, weight: Int = 1) {
        
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
    
    ///Performs a bfs search, complexity O(V+E)
    public func traverseBreadthFirst(start: Vertex<T>? = nil) -> [Vertex<T>] {
        
        let head = self.head ?? self.vertices.first
        guard let start = start ?? head else { return [Vertex<T>]() }
        
        var result = [Vertex<T>]()
        
        var queue = [Vertex<T>]()
        queue.append(start)
        
        while !queue.isEmpty {
            
            //get a vertex
            let vertex = queue.removeFirst()
            
            for e in vertex.edges {
                
                //adds the 'to' vertex if the node is node visited yet
                if e.vertices.to.color == VertexColor.White {
                    e.vertices.to.color = VertexColor.Gray
                    queue.append(e.vertices.to)
                }
            }
            
            //mark this node as visited
            vertex.color = VertexColor.Black
            result.append(vertex)
        }
        
        //reset the vertices
        for vertex in result {
            vertex.color = VertexColor.White
        }
        
        return result
    }
    
    ///Performs a dfs search, complexity O(V+E)
    public func traverseDepthFirst(start: Vertex<T>?) -> [Vertex<T>] {
        
        //recursive dfs visit
        func visit(vertex: Vertex<T>, input: [Vertex<T>]) -> [Vertex<T>] {
            
            var result = input
            vertex.color = VertexColor.Gray
            
            for edge in vertex.edges {
                if edge.vertices.to.color == VertexColor.White {
                    result.appendContentsOf(visit(edge.vertices.to, input: result))
                }
            }
            
            vertex.color = VertexColor.Black
            result.append(vertex)
            return result
        }
        
        guard let start = (start ?? self.head) else { return [Vertex<T>]() }
        let result = [Vertex<T>]()
        
        return visit(start, input: result)
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

public class GraphGenerator<T:Equatable>: GeneratorType {
    
    public typealias Element = T
    
    private let bfs: [Element]
    private var index: Int = 0
    
    private init(bfs: [Element]) {
        self.bfs = bfs
    }
    
    ///Advance to the next element and return it, or `nil` if no next element exists.
    public func next() -> Element? {
        if index < bfs.count {
            return self.bfs[self.index++]
        }
        return nil
    }
}

//MARK: - Shortest Path

public struct Path<T:Equatable>: Equatable {
    
    ///The cost and the previous cost
    public let cost: Int
    
    ///All the vertices included in the path
    public let vertices: [Vertex<T>]
    
    ///The final destination for this path
    public var destination: Vertex<T>? {
        return self.vertices.last
    }
    
    private init(cost: Int, vertices: [Vertex<T>] = [Vertex<T>]()) {
        self.cost = cost
        self.vertices = vertices
    }
    
    ///Creates a new path to the vertex passed as argument and with the additional cost
    private func appendNew(increment: Int, to:Vertex<T>) -> Path<T> {
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

private func +<T>(lhs: Path<T>, rhs:(Int,Vertex<T>)) -> Path<T> {
    return lhs.appendNew(rhs.0, to: rhs.1)
}

extension Graph {
    
    ///Compute the shortest path from a node to another using Dijkstra's algorithm.
    ///- Complexity: is O(E+VlogV)
    public func shortestPath(from: Vertex<T>, to: Vertex<T>) -> Path<T>? {
        
        var frontier = [Path<T>]()
        var final = [Path<T>]()
        
        //use the source edges to create the frontier
        for e in from.edges {
            frontier.append(Path(cost: e.weight, vertices: [from, e.vertices.to]))
        }
        
        //support path changes using the greedy approach
        while !frontier.isEmpty {
            
            var bestPath = Path<T>(cost: Int.max)
            
            var idx = 0
            for i in 0..<frontier.count {
                let p = frontier[i]
                
                if p.cost < bestPath.cost {
                    bestPath = p
                    idx = i
                }
            }
            
            //enumerate the bestPath edges
            guard let edges = bestPath.destination?.edges else { continue }
            
            for e in edges {
                let path = bestPath + (e.weight, e.vertices.to)
                
                if !frontier.contains(path) {
                    frontier.append(path)
                }
            }
            
            //preserve the best path
            if bestPath.destination == to {
                final.append(bestPath)
            }
            
            //remove the best path from the frontier
            frontier.removeAtIndex(idx)
        }
        
        var shortestPath = Path<T>(cost: Int.max)
        
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


