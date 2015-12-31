//
//  RedBlackTree.swift
//  DataStructures
//
//  Created by Alex Usbergo on 29/12/15.
//  Copyright © 2015 Alex Usbergo. All rights reserved.
//  Forked from https://github.com/oisdk/SwiftDataStructures
//

public enum Color { case R, B }

///A red-black binary search tree. Adapted from Airspeed Velocity's implementation, 
///Chris Okasaki's Purely Functional Data Structures, and Stefan Kahrs' Red-black RedBlackTrees with 
//types, which is implemented in the Haskell standard library.
public enum RedBlackTree<Element: Comparable> : Equatable {
    case Empty
    indirect case Node(Color,RedBlackTree<Element>,Element,RedBlackTree<Element>)
}

public func ==<E : Comparable>(lhs: RedBlackTree<E>, rhs: RedBlackTree<E>) -> Bool {
    return lhs.elementsEqual(rhs)
}

// MARK: Initializers

extension RedBlackTree : ArrayLiteralConvertible {
    
    ///Create an empty `RedBlackTree`.
    public init() { self = .Empty }
    
    private init(
        _ x: Element,
        color: Color = .B,
        left: RedBlackTree<Element> = .Empty,
        right: RedBlackTree<Element> = .Empty
        ) {
            self = .Node(color, left, x, right)
    }
    
    ///Create a `RedBlackTree` from a sequence
    public init<S : SequenceType where S.Generator.Element == Element>(_ seq: S) {
        self.init()
        for x in seq { insert(x) }
    }
    
    ///Create a `RedBlackTree` of `elements`
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension RedBlackTree: CustomDebugStringConvertible {
    
    ///A description of `self`, suitable for debugging
    public var debugDescription: String {
        return Array(self).debugDescription
    }
}

// MARK: Properties

extension RedBlackTree {
    
     ///Returns the smallest element in `self` if it's present, or `nil` if `self` is empty
     ///- Complexity: O(*log n*)
    public var first: Element? {
        return minElement()
    }
    
     ///Returns the largest element in `self` if it's present, or `nil` if `self` is empty
     ///- Complexity: O(*log n*)
    public var last: Element? {
        return maxElement()
    }
    
    ///Returns `true` iff `self` is empty
    public var isEmpty: Bool {
        return self == .Empty
    }
    
     ///Returns the number of elements in `self`
     ///- Complexity: O(`count`)
    public var count: Int {
        guard case let .Node(_, l, _, r) = self else { return 0 }
        return 1 + l.count + r.count
    }
}

// MARK: Balance

internal enum RedBlackTreeBalance {
    case Balanced(blackHeight: Int)
    case UnBalanced
}

extension RedBlackTree {
    internal var isBalanced: Bool {
        switch balance {
        case .Balanced: return true
        case .UnBalanced: return false
        }
    }
    
    internal var color: Color {
        if case .Node(.R, _, _, _) = self { return .R }
        return .B
    }
    
    internal var balance: RedBlackTreeBalance {
        guard case let .Node(c, l, _, r) = self else { return .Balanced(blackHeight: 1) }
        if
            case let .Node(_, _, lx, _) = l,
            case let .Node(_, _, rx, _) = r
            where lx >= rx { return .UnBalanced }
        guard
            case let .Balanced(x) = l.balance,
            case let .Balanced(y) = r.balance
            where x == y else { return .UnBalanced }
        if case .B = c { return .Balanced(blackHeight: x + 1) }
        guard case .B = l.color, case .B = r.color else { return .UnBalanced }
        return .Balanced(blackHeight: x)
    }
    
    private func balL() -> RedBlackTree {
        switch self {
        case let .Node(.B, .Node(.R, .Node(.R, a, x, b), y, c), z, d):
            return .Node(.R, .Node(.B,a,x,b),y,.Node(.B,c,z,d))
        case let .Node(.B, .Node(.R, a, x, .Node(.R, b, y, c)), z, d):
            return .Node(.R, .Node(.B,a,x,b),y,.Node(.B,c,z,d))
        default:
            return self
        }
    }
    
    private func balR() -> RedBlackTree {
        switch self {
        case let .Node(.B, a, x, .Node(.R, .Node(.R, b, y, c), z, d)):
            return .Node(.R, .Node(.B,a,x,b),y,.Node(.B,c,z,d))
        case let .Node(.B, a, x, .Node(.R, b, y, .Node(.R, c, z, d))):
            return .Node(.R, .Node(.B,a,x,b),y,.Node(.B,c,z,d))
        default:
            return self
        }
    }
    
    private func unbalancedR() -> (result: RedBlackTree, wasBlack: Bool) {
        guard case let .Node(c, l, x, .Node(rc, rl, rx, rr)) = self else {
            preconditionFailure(
                "Should not call unbalancedR on an empty RedBlackTree or a RedBlackTree with an empty right"
            )
        }
        switch rc {
        case .B:
            return (RedBlackTree.Node(.B, l, x, .Node(.R, rl, rx, rr)).balR(), c == .B)
        case .R:
            guard case let .Node(_, rll, rlx, rlr) = rl else {
                preconditionFailure("rl empty")
            }
            return (
                RedBlackTree.Node(.B, RedBlackTree.Node(.B, l, x, .Node(.R, rll, rlx, rlr)).balR(), rx, rr), false
            )
        }
    }
    
    private func unbalancedL() -> (result: RedBlackTree, wasBlack: Bool) {
        guard case let .Node(c, .Node(lc, ll, lx, lr), x, r) = self else {
            preconditionFailure(
                "Should not call unbalancedL on an empty RedBlackTree or a RedBlackTree with an empty left"
            )
        }
        switch lc {
        case .B:
            return (RedBlackTree.Node(.B, .Node(.R, ll, lx, lr), x, r).balL(), c == .B)
        case .R:
            guard case let .Node(_, lrl, lrx, lrr) = lr else {
                preconditionFailure("lr empty")
            }
            return (
                RedBlackTree.Node(.B, ll, lx, RedBlackTree.Node(.B, .Node(.R, lrl, lrx, lrr), x, r).balL()), false
            )
        }
    }
}

// MARK: Contains

extension RedBlackTree {
    
    private func cont(x: Element, _ p: Element) -> Bool {
        guard case let .Node(_, l, y, r) = self else { return x == p }
        return x < y ? l.cont(x, p) : r.cont(x, y)
    }
    
     ///Returns `true` iff `self` contains `x`
     ///- Complexity: O(*log n*)
    public func contains(x: Element) -> Bool {
        guard case let .Node(_, l, y, r) = self else { return false }
        return x < y ? l.contains(x) : r.cont(x, y)
    }
}


extension RedBlackTree {
    
    private func ins(x: Element) -> RedBlackTree {
        guard case let .Node(c, l, y, r) = self else { return RedBlackTree(x, color: .R) }
        if x < y { return RedBlackTree(y, color: c, left: l.ins(x), right: r).balL() }
        if y < x { return RedBlackTree(y, color: c, left: l, right: r.ins(x)).balR() }
        return self
    }
    
     ///Inserts `x` into `self
     ///- Complexity: O(*log n*)
    public mutating func insert(x: Element) {
        guard case let .Node(_, l, y, r) = ins(x) else {
            preconditionFailure("ins should not return an empty RedBlackTree")
        }
        self = .Node(.B, l, y, r)
    }
}

extension RedBlackTree : SequenceType {
    
     ///Runs a `RedBlackTreeGenerator` over the elements of `self`. (The elements are presented in
     ///order, from smallest to largest)
    public func generate() -> RedBlackTreeGenerator<Element> {
        return RedBlackTreeGenerator(stack: [], curr: self)
    }
}

///A `Generator` for a RedBlackTree
public struct RedBlackTreeGenerator<Element : Comparable> : GeneratorType {
    
    private var (stack, curr): ([RedBlackTree<Element>], RedBlackTree<Element>)
    
     ///Advance to the next element and return it, or return `nil` if no next element exists.
    public mutating func next() -> Element? {
        while case let .Node(_, l, x, r) = curr {
            if case .Empty = l {
                curr = r
                return x
            } else {
                stack.append(curr)
                curr = l
            }
        }
        guard case let .Node(_, _, x, r)? = stack.popLast()
            else { return nil }
        curr = r
        return x
    }
}

// MARK: Max, min

extension RedBlackTree {

    ///Returns the smallest element in `self` if it's present, or `nil` if `self` is empty
     ///- Complexity: O(*log n*)
    public func minElement() ->  Element? {
        switch self {
        case .Empty: return nil
        case .Node(_, .Empty, let e, _): return e
        case .Node(_, let l, _, _): return l.minElement()
        }
    }
    
     ///Returns the largest element in `self` if it's present, or `nil` if `self` is empty
     ///- Complexity: O(*log n*)
    public func maxElement() -> Element? {
        switch self {
        case .Empty: return nil
        case .Node(_, _, let e, .Empty) : return e
        case .Node(_, _, _, let r): return r.maxElement()
        }
    }
    
    private func _deleteMin() -> (RedBlackTree, Bool, Element) {
        switch self {
        case .Empty:
            preconditionFailure("Should not call _deleteMin on an empty RedBlackTree")
        case let .Node(.B, .Empty, x, .Empty):
            return (.Empty, true, x)
        case let .Node(.B, .Empty, x, .Node(.R, rl, rx, rr)):
            return (.Node(.B, rl, rx, rr), false, x)
        case let .Node(.R, .Empty, x, r):
            return (r, false, x)
        case let .Node(c, l, x, r):
            let (l0, d, m) = l._deleteMin()
            guard d else { return (.Node(c, l0, x, r), false, m) }
            let tD = RedBlackTree.Node(c, l0, x, r).unbalancedR()
            return (tD.0, tD.1, m)
        }
    }
    
     ///Removes the smallest element from `self` and returns it if it exists, or returns `nil`
     ///if `self` is empty.
     ///- Complexity: O(*log n*)
    public mutating func popFirst() -> Element? {
        guard case .Node = self else { return nil }
        let (t, _, x) = _deleteMin()
        self = t
        return x
    }
    
     ///Removes the smallest element from `self` and returns it.
     ///- Complexity: O(*log n*)
     ///- Precondition: `!self.isEmpty`
    public mutating func removeFirst() -> Element? {
        guard case .Node = self else { return nil }
        let (t, _, x) = _deleteMin()
        self = t
        return x
    }
    
    private func _deleteMax() -> (RedBlackTree, Bool, Element) {
        switch self {
        case .Empty:
            preconditionFailure("Should not call _deleteMax on an empty RedBlackTree")
        case let .Node(.B, .Empty, x, .Empty):
            return (.Empty, true, x)
        case let .Node(.B, .Node(.R, rl, rx, rr), x, .Empty):
            return (.Node(.B, rl, rx, rr), false, x)
        case let .Node(.R, l, x, .Empty):
            return (l, false, x)
        case let .Node(c, l, x, r):
            let (r0, d, m) = r._deleteMax()
            guard d else { return (.Node(c, l, x, r0), false, m) }
            let tD = RedBlackTree.Node(c, l, x, r0).unbalancedL()
            return (tD.0, tD.1, m)
        }
    }
    
     ///Removes the largest element from `self` and returns it if it exists, or returns `nil`
     ///if `self` is empty.
     ///- Complexity: O(*log n*)
    public mutating func popLast() -> Element? {
        guard case .Node = self else { return nil }
        let (t, _, x) = _deleteMax()
        self = t
        return x
    }
    
    ///Removes the largest element from `self` and returns it.
     ///- Complexity: O(*log n*)
     ///- Precondition: `!self.isEmpty
    public mutating func removeLast() -> Element {
        let (t, _, x) = _deleteMax()
        self = t
        return x
    }
}

// MARK: Delete

extension RedBlackTree {
    
    private func del(x: Element) -> (RedBlackTree, Bool)? {
        guard case let .Node(c, l, y, r) = self else { return nil }
        
        if x < y {
            guard let (l0, d) = l.del(x) else { return nil }
            let t = RedBlackTree.Node(c, l0, y, r)
            return d ? t.unbalancedR() : (t, false)
            
        } else if y < x {
            guard let (r0, d) = r.del(x) else { return nil }
            let t = RedBlackTree.Node(c, l, y, r0)
            return d ? t.unbalancedL() : (t, false)
        }
        
        if case .Empty = r {
            guard case .B = c else { return (l, false) }
            if case let .Node(.R, ll, lx, lr) = l { return (.Node(.B, ll, lx, lr), false) }
            return (l, true)
        }
        
        let (r0, d, m) = r._deleteMin()
        let t = RedBlackTree.Node(c, l, m, r0)
        return d ? t.unbalancedL() : (t, false)
    }
    
     ///Removes `x` from `self` and returns it if it is present, or `nil` if it is not
     ///- Complexity: O(*log n*)
    public mutating func remove(x: Element) -> Element? {
        guard let (t, _) = del(x) else { return nil }
        if case let .Node(_, l, y, r) = t {
            self = .Node(.B, l, y, r)
        } else {
            self = .Empty
        }
        return x
    }
}

// MARK: Reverse

extension RedBlackTree {

    ///Returns a sequence of the elements of `self` from largest to smallest
    public func reverse() -> ReverseRedBlackTreeGenerator<Element> {
        return ReverseRedBlackTreeGenerator(stack: [], curr: self)
    }
}

///A `Generator` for a RedBlackTree, that iterates over it in reverse.
public struct ReverseRedBlackTreeGenerator<Element : Comparable> : GeneratorType, SequenceType {
    
    private var (stack, curr): ([RedBlackTree<Element>], RedBlackTree<Element>)

    public mutating func next() -> Element? {
        while case let .Node(_, l, x, r) = curr {
            if case .Empty = r {
                curr = l
                return x
            } else {
                stack.append(curr)
                curr = r
            }
        }
        guard case let .Node(_, l, x, _)? = stack.popLast()
            else { return nil }
        curr = l
        return x
    }
}

// MARK: Higher-Order

extension RedBlackTree {
    
    public func reduce<T>(initial: T, @noescape combine: (T, Element) throws -> T) rethrows -> T {
        guard case let .Node(_, l, x, r) = self else { return initial }
        let lx = try l.reduce(initial, combine: combine)
        let xx = try combine(lx, x)
        let rx = try r.reduce(xx, combine: combine)
        return rx
    }
    
    public func forEach(@noescape body: Element throws -> ()) rethrows {
        guard case let .Node(_, l, x, r) = self else { return }
        try l.forEach(body)
        try body(x)
        try r.forEach(body)
    }
}

public protocol SetType : SequenceType {
    
    ///Create an empty instance of `self`
    init()
    
    ///Create an instance of `self` containing the elements of `sequence`
    init<S : SequenceType where S.Generator.Element == Generator.Element>(_ sequence: S)
    
    ///Remove `x` from `self` and return it if it was present. If not, return `nil`.
    mutating func remove(x: Generator.Element) -> Generator.Element?
    
    ///Insert `x` into `self`
    mutating func insert(x: Generator.Element)
    
    ///returns `true` iff `self` contains `x`
    func contains(x: Generator.Element) -> Bool
    
    ///Remove the member if it was present, insert it if it was not.
    mutating func XOR(x: Generator.Element)
}


extension SetType {
    
    ///Return a new SetType with elements that are either in `self` or a finite
    ///sequence but do not occur in both.
    public func exclusiveOr<S : SequenceType where S.Generator.Element == Generator.Element>(sequence: S) -> Self {
            var result = self
            result.exclusiveOrInPlace(sequence)
            return result
    }
    
    ///For each element of a finite sequence, remove it from `self` if it is a
    ///common element, otherwise add it to the SetType.
    public mutating func exclusiveOrInPlace<S : SequenceType where S.Generator.Element == Generator.Element>(sequence: S) {
            var seen = Self()
            for x in sequence where !seen.contains(x) {
                XOR(x)
                seen.insert(x)
            }
    }
    
    ///Return a new set with elements common to `self` and a finite sequence.
    public func intersect<S : SequenceType where S.Generator.Element == Generator.Element>(sequence: S) -> Self {
            var result = Self()
            for x in sequence where contains(x) { result.insert(x) }
            return result
    }
    
    ///Remove any elements of `self` that aren't also in a finite sequence.
    public mutating func intersectInPlace<S : SequenceType where S.Generator.Element == Generator.Element> (sequence: S) {
            self = intersect(sequence)
    }
    
    ///Returns true if no elements in `self` are in a finite sequence.
    public func isDisjointWith<S : SequenceType where S.Generator.Element == Generator.Element>(sequence: S) -> Bool {
            return !sequence.contains(contains)
    }
    
    ///Returns true if `self` is a superset of a finite sequence.
    public func isSupersetOf<S : SequenceType where S.Generator.Element == Generator.Element>(sequence: S) -> Bool {
            return !sequence.contains { !self.contains($0) }
    }
    
    ///Returns true if `self` is a subset of a finite sequence
    public func isSubsetOf<S : SequenceType where S.Generator.Element == Generator.Element>(sequence: S) -> Bool {
            return Self(sequence).isSupersetOf(self)
    }
    
    ///Return a new SetType with elements in `self` that do not occur
    ///in a finite sequence.
    public func subtract<S : SequenceType where S.Generator.Element == Generator.Element>(sequence: S) -> Self {
            var result = self
            for x in sequence { result.remove(x) }
            return result
    }
    
    ///Remove all elements in `self` that occur in a finite sequence.
    public mutating func subtractInPlace<S : SequenceType where S.Generator.Element == Generator.Element>(sequence: S) {
            for x in sequence { remove(x) }
    }
    
    ///Return a new SetType with items in both `self` and a finite sequence.
    public func union<S : SequenceType where S.Generator.Element == Generator.Element>(sequence: S) -> Self {
            var result = self
            for x in sequence { result.insert(x) }
            return result
    }
    
    ///Insert the elements of a finite sequence into `self`
    public mutating func unionInPlace<S : SequenceType where S.Generator.Element == Generator.Element>(sequence: S) {
            for x in sequence { insert(x) }
    }
}

extension RedBlackTree: SetType {
    
    ///Remove the member if it was present, insert it if it was not.
    public mutating func XOR(x: Element) {
        if case nil = remove(x) { insert(x) }
    }
}