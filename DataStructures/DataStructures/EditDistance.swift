//
//  SequenceEditDistance.swift
//  DataStructures
//
//  Created by Alex Usbergo on 10/01/16.
//  Copyright © 2016 Alex Usbergo. All rights reserved.
//

import Foundation

///Represent an edit operation
public enum EditDistanceOperation {
    
    case Insertion(source: Int, target: Int)
    case Removal(source: Int)
    case Substitution(source: Int, target: Int)
    case AllChanged
    
    public static func compute(from: [Any], to: [Any], comparator:(lhs:Any, rhs:Any) -> Bool) -> [EditDistanceOperation] {
        
        let m = from.count + 1
        let n = to.count + 1
        
        if m == 1 || n == 1 {
            return [EditDistanceOperation.AllChanged]
        }
        
        // for all i and j, d[i,j] will hold the Levenshtein distance between
        // the first i characters of s and the first j characters of t;
        // note that d has (m+1)*(n+1) values
        // set each element to zero
        var d = [[Int]](count:m, repeatedValue: [Int](count:n, repeatedValue: 0))
        
        // source prefixes can be transformed into empty string by
        // dropping all characters
        for i in 1...m-1 {
            d[i][0] = i
        }
        
        // target prefixes can be reached from empty source prefix
        // by inserting every character
        for j in 1...n-1 {
            d[0][j] = j
        }
        
        // create the matrix
        for j in 1...n-1 {
            for i in 1...m-1 {
                
                if comparator(lhs: from[i-1], rhs: to[j-1]) {
                    
                    //no operation required
                    d[i][j] = d[i-1][j-1]
                    
                } else {
                    
                    //min(deletion_score, min(insertion_score, substitution_score))
                    d[i][j] = min(d[i-1][j], min(d[i][j-1], d[i-1][j-1])) + 1
                }
            }
        }
        
        // compute minimal set of edit operations
        var operations = [EditDistanceOperation]()
        
        var i = m - 1
        var j = n - 1
        
        while i > 0 || j > 0 {
            
            //remove, if applicable
            let removalScore = i > 0 ?  d[i-1][j] : Int.max
            
            //insertion, if applicable
            let insertionScore = j > 0 ? d[i][j-1] : Int.max
            
            //substituion, if applicable
            let substitutionScore = i > 0 && j > 0 ? d[i-1][j-1] : Int.max
            
            //removal
            if (removalScore < insertionScore && removalScore < substitutionScore) {
                operations.append(EditDistanceOperation.Removal(source: i-1))
                i -= 1
                
            //insertion
            } else if (insertionScore < removalScore && insertionScore < substitutionScore) {
                operations.append(EditDistanceOperation.Insertion(source: i, target: j-1))
                j -= 1
                
            //no change
            } else if (substitutionScore == d[i][j]) {
                i -= 1
                j -= 1
                
            //substitution
            } else {
                operations.append(EditDistanceOperation.Substitution(source: i-1, target: j-1))
                i -= 1
                j -= 1
            }
        }
        
        return operations
    }
    
    public static func computeObjectArray(from: [AnyObject], to: [AnyObject]) -> [EditDistanceOperation] {
        
        var fromAny = Array<Any>()
        for obj in from { fromAny.append(obj) }
        
        var toAny = Array<Any>()
        for obj in to { toAny.append(obj) }
        
        return self.compute(fromAny, to: toAny, comparator: {
            let l = $0 as! AnyObject, r = $1 as! AnyObject
            return l.isEqual(r);
        })
    }
    
    public static func compute<T:Equatable>(from: [T], to: [T]) -> [EditDistanceOperation] {
        
        //wraps it in [Any] (due to Swift beta5 bug)
        var fromAny = [Any](), toAny = [Any]()
        for obj in from { fromAny.append(obj) }
        for obj in to { toAny.append(obj) }
        
        return self.compute(fromAny, to: toAny, comparator: {
            let l = $0 as! T, r = $1 as! T
            return l == r
        })
    }
    
}

