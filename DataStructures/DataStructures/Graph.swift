//
//  Graph.swift
//  Primer
//
//  Created by Alex Usbergo on 28/12/15.
//  Copyright © 2015 Alex Usbergo. All rights reserved.
//

import Foundation

public struct Edge<T:Equatable>: Equatable {
    
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
    private let value: T
    
    ///Wheter this vertex has been visited or not
    private var color = VertexColor.White
    
    ///The edges from this vertex
    private var edges = [Edge<T>]()
    
    private let id: Int = NSUUID().UUIDString.hash
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
        return "\(self.value)"
    }
}

public func ==<T>(lhs: Vertex<T>, rhs: Vertex<T>) -> Bool {
    return lhs.id == rhs.id
}

public func ==<T>(lhs: Edge<T>, rhs: Edge<T>) -> Bool {
   return lhs.vertices.from.value == rhs.vertices.from.value && rhs.vertices.to.value == rhs.vertices.to.value && lhs.weight == rhs.weight
}

public class Graph<T:Equatable>: ArrayLiteralConvertible {
    
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
    public required init(arrayLiteral elements: Element...) {
        for element in elements {
            self.addVertex(element)
        }
    }
    
    ///Add a node to the graph
    public func addVertex(value: T) -> Vertex<T> {
        let vertex = Vertex(value: value)
        self.vertices.append(vertex)
        return vertex
    }
    
    ///Remove a vertex from the graph
    public func removeVertext(vertex: Vertex<T>) {
        
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


