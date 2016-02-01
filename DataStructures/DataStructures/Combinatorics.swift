//
//  ArrayExtensions.swift
//  DataStructures
//
//  Created by Alex Usbergo on 01/02/16.
//  Copyright © 2016 Alex Usbergo. All rights reserved.
//
// forked from hollance/swift-algorithm-club

import Foundation

public extension Array where Element: Comparable {
    
    ///Recursively splits the array in half until the value is found.
    ///If there is more than one occurrence of the search key in the array, then
    ///there is no guarantee which one it finds.
    ///- Note: The array must be sorted
    public func binarySearch<Element: Comparable>(a: [Element], key: Element) -> Int? {
        var range = 0..<a.count
        while range.startIndex < range.endIndex {
            let midIndex = range.startIndex + (range.endIndex - range.startIndex) / 2
            if a[midIndex] == key {
                return midIndex
            } else if a[midIndex] < key {
                range.startIndex = midIndex + 1
            } else {
                range.endIndex = midIndex
            }
        }
        return nil
    }
}

extension Array {
    
    /// Determines if there are any entries a[i] + a[j] == k in the array.
    /// This is an O(n) solution.
    /// The array must be sorted for this to work!
    public static func twoSumProblem(a: [Int], k: Int) -> ((Int, Int))? {
        var i = 0
        var j = a.count - 1
        
        while i < j {
            let sum = a[i] + a[j]
            if sum == k {
                return (i, j)
            } else if sum < k {
                ++i
            } else {
                --j
            }
        }
        return nil
    }
}


public extension String {
    
    ///Boyer-Moore string search
    ///This code is based on the article "Faster String Searches" by Costas Menico
    public func indexOf(pattern: String) -> String.Index? {
        // Cache the length of the search pattern because we're going to
        // use it a few times and it's expensive to calculate.
        let patternLength = pattern.characters.count
        assert(patternLength > 0)
        assert(patternLength <= self.characters.count)
        
        // Make the skip table. This table determines how far we skip ahead
        // when a character from the pattern is found.
        var skipTable = [Character: Int]()
        for (i, c) in pattern.characters.enumerate() {
            skipTable[c] = patternLength - i - 1
        }
        
        // This points at the last character in the pattern.
        let p = pattern.endIndex.predecessor()
        let lastChar = pattern[p]
        
        // The pattern is scanned right-to-left, so skip ahead in the string by
        // the length of the pattern. (Minus 1 because startIndex already points
        // at the first character in the source string.)
        var i = self.startIndex.advancedBy(patternLength - 1)
        
        // This is a helper function that steps backwards through both strings
        // until we find a character that doesn’t match, or until we’ve reached
        // the beginning of the pattern.
        func backwards() -> String.Index? {
            var q = p
            var j = i
            while q > pattern.startIndex {
                j = j.predecessor()
                q = q.predecessor()
                if self[j] != pattern[q] { return nil }
            }
            return j
        }
        
        // The main loop. Keep going until the end of the string is reached.
        while i < self.endIndex {
            let c = self[i]
            
            // Does the current character match the last character from the pattern?
            if c == lastChar {
                
                // There is a possible match. Do a brute-force search backwards.
                if let k = backwards() { return k }
                
                // If no match, we can only safely skip one character ahead.
                i = i.successor()
            } else {
                // The characters are not equal, so skip ahead. The amount to skip is
                // determined by the skip table. If the character is not present in the
                // pattern, we can skip ahead by the full pattern length. However, if
                // the character *is* present in the pattern, there may be a match up
                // ahead and we can't skip as far.
                i = i.advancedBy(skipTable[c] ?? patternLength)
            }
        }
        return nil
    }
}

public struct Combinatorics {
    
    /// Calculates n!
    public static func factorial(n: Int) -> Int {
        var n = n
        var result = 1
        while n > 1 {
            result *= n
            n -= 1
        }
        return result
    }
    
    /// Calculates P(n, k), the number of permutations of n distinct symbols
    /// in groups of size k.
    public static func permutations(n: Int, _ k: Int) -> Int {
        var n = n
        var answer = n
        for _ in 1..<k {
            n -= 1
            answer *= n
        }
        return answer
    }
    
    
    /// Prints out all the permutations of the given array.
    /// Original algorithm by Niklaus Wirth.
    /// See also Dr.Dobb's Magazine June 1993, Algorithm Alley
    public static func permuteWirth<T>(a: [T], _ n: Int) {
        if n == 0 {
            print(a)   // display the current permutation
        } else {
            var a = a
            permuteWirth(a, n - 1)
            for i in 0..<n {
                swap(&a[i], &a[n])
                permuteWirth(a, n - 1)
                swap(&a[i], &a[n])
            }
        }
    }
    
    /// Prints out all the permutations of an n-element collection.
    /// The initial array must be initialized with all zeros. The algorithm
    /// uses 0 as a flag that indicates more work to be done on each level
    /// of the recursion.
    /// Original algorithm by Robert Sedgewick.
    /// See also Dr.Dobb's Magazine June 1993, Algorithm Alley
    public static func permuteSedgewick(a: [Int], _ n: Int, inout _ pos: Int) {
        var a = a
        pos += 1
        a[n] = pos
        if pos == a.count - 1 {
            print(a)              // display the current permutation
        } else {
            for i in 0..<a.count {
                if a[i] == 0 {
                    permuteSedgewick(a, i, &pos)
                }
            }
        }
        pos -= 1
        a[n] = 0
    }
    
    
    /// Calculates C(n, k), or "n-choose-k", i.e. how many different selections
    /// of size k out of a total number of distinct elements (n) you can make.
    /// Doesn't work very well for large numbers.
    public static func combinations(n: Int, _ k: Int) -> Int {
        return permutations(n, k) / factorial(k)
    }
    
    /// Calculates C(n, k), or "n-choose-k", i.e. the number of ways to choose
    /// k things out of n possibilities.
    /// Thanks to the dynamic programming, this algorithm from Skiena allows for
    /// the calculation of much larger numbers, at the cost of temporary storage
    /// space for the cached values.
    public static func binomialCoefficient(n: Int, _ k: Int) -> Int {
        var bc = Array2D(columns: n + 1, rows: n + 1, initialValue: 0)
        
        for i in 0...n {
            bc[i, 0] = 1
            bc[i, i] = 1
        }
        
        if n > 0 {
            for i in 1...n {
                for j in 1..<i {
                    bc[i, j] = bc[i - 1, j - 1] + bc[i - 1, j]
                }
            }
        }
        
        return bc[n, k]
    }
}

/// Two-dimensional array with a fixed number of rows and columns.
/// This is mostly handy for games that are played on a grid, such as chess.
/// Performance is always O(1).
public struct Array2D<T> {
    
    public let columns: Int
    public let rows: Int
    private var array: [T]
    
    public init(columns: Int, rows: Int, initialValue: T) {
        self.columns = columns
        self.rows = rows
        array = .init(count: rows*columns, repeatedValue: initialValue)
    }
    
    public subscript(column: Int, row: Int) -> T {
        get {
            return array[row*columns + column]
        }
        set {
            array[row*columns + column] = newValue
        }
    }
}

