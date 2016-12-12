//
// The MIT License (MIT)
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

///Represent an edit operation
public enum EditDistanceOperation {

  case insertion(source: Int, target: Int)
  case removal(source: Int)
  case substitution(source: Int, target: Int)
  case allChanged

  public static func compute(_ from: [Any],
                             to: [Any],
                             comparator:(_ lhs:Any, _ rhs:Any) -> Bool) -> [EditDistanceOperation] {

    let m = from.count + 1
    let n = to.count + 1

    if m == 1 || n == 1 {
      return [EditDistanceOperation.allChanged]
    }

    // for all i and j, d[i,j] will hold the Levenshtein distance between
    // the first i characters of s and the first j characters of t;
    // note that d has (m+1)*(n+1) values
    // set each element to zero
    var d = [[Int]](repeating: [Int](repeating: 0, count: n), count: m)

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

        if comparator(from[i-1], to[j-1]) {

          // no operation required
          d[i][j] = d[i-1][j-1]

        } else {

          // min(deletion_score, min(insertion_score, substitution_score))
          d[i][j] = min(d[i-1][j], min(d[i][j-1], d[i-1][j-1])) + 1
        }
      }
    }

    // compute minimal set of edit operations
    var operations = [EditDistanceOperation]()

    var i = m - 1
    var j = n - 1

    while i > 0 || j > 0 {

      // remove, if applicable
      let removalScore = i > 0 ?  d[i-1][j] : Int.max

      // insertion, if applicable
      let insertionScore = j > 0 ? d[i][j-1] : Int.max

      // substituion, if applicable
      let substitutionScore = i > 0 && j > 0 ? d[i-1][j-1] : Int.max

      // removal
      if (removalScore < insertionScore && removalScore < substitutionScore) {
        operations.append(EditDistanceOperation.removal(source: i-1))
        i -= 1

        // insertion
      } else if (insertionScore < removalScore && insertionScore < substitutionScore) {
        operations.append(EditDistanceOperation.insertion(source: i, target: j-1))
        j -= 1

        // no change
      } else if (substitutionScore == d[i][j]) {
        i -= 1
        j -= 1

        // substitution
      } else {
        operations.append(EditDistanceOperation.substitution(source: i-1, target: j-1))
        i -= 1
        j -= 1
      }
    }

    return operations
  }

  public static func computeObjectArray(_ from: [AnyObject], to: [AnyObject]) -> [EditDistanceOperation] {

    var fromAny = Array<Any>()
    for obj in from { fromAny.append(obj) }

    var toAny = Array<Any>()
    for obj in to { toAny.append(obj) }

    return self.compute(fromAny, to: toAny, comparator: {
      let l = $0 as AnyObject, r = $1 as AnyObject
      return l.isEqual(r);
    })
  }

  public static func compute<T:Equatable>(_ from: [T], to: [T]) -> [EditDistanceOperation] {

    // wraps it in [Any] (due to Swift beta5 bug)
    var fromAny = [Any](), toAny = [Any]()
    for obj in from { fromAny.append(obj) }
    for obj in to { toAny.append(obj) }

    return self.compute(fromAny, to: toAny, comparator: {
      let l = $0 as! T, r = $1 as! T
      return l == r
    })
  }
}
