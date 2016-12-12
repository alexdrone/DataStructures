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
// Forked from mauriciosantos/Buckets-Swift/

/// A Matrix is a fixed size generic 2D collection.
/// You can set and get elements using subscript notation. Example:
/// `matrix[row, column] = value`
///
/// This collection also provides linear algebra functions and operators such as
/// `inverse()`, `+` and `*` using Apple's Accelerate framework where vailable. Please note that
/// these operations are designed to work exclusively with `Double` matrices.
/// Check the `Functions` section for more information.
///
/// Conforms to `MutableCollection`,
/// `ExpressibleByArrayLiteral` and `CustomStringConvertible`.
public struct Matrix<T> {

  // MARK: Creating a Matrix

  /// Constructs a new matrix with all positions set to the specified value.
  public init(rows: Int, columns: Int, repeating repeatedValue: T) {
    precondition(rows >= 0, "Can't create matrix. Invalid number of rows")
    precondition(columns >= 0, "Can't create matrix. Invalid number of columns")

    self.rows = rows
    self.columns = columns
    grid = Array(repeating: repeatedValue, count: rows * columns)
  }

  /// Constructs a new matrix using a 1D array in row-major order.
  /// `Matrix[i,j] == grid[i*columns + j]`
  public init(rows: Int, columns: Int, grid: [T]) {
    precondition(grid.count == rows*columns, "")

    self.rows = rows
    self.columns = columns
    self.grid = grid
  }

  /// Constructs a new matrix using a 2D array.
  /// All columns must be the same size, otherwise an error is triggered.
  public init(_ rowsArray: [[T]]) {
    let rows = rowsArray.count
    precondition(rows > 0, "Can't create an empty matrix")
    precondition(rowsArray[0].count > 0, "Can't create a matrix column with no elements")

    let columns = rowsArray[0].count
    for subArray in rowsArray {
      if subArray.count != columns {
        preconditionFailure("Can't create a matrix with different sized columns")
      }
    }
    var grid = Array<T>()
    grid.reserveCapacity(rows*columns)
    for i in 0..<rows {
      for j in 0..<columns {
        grid.append(rowsArray[i][j])
      }
    }
    self.init(rows: rows, columns: columns, grid: grid)
  }

  // MARK: Querying a Matrix

  /// The number of rows in the matrix.
  public let rows: Int

  /// The number of columns in the matrix.
  public let columns: Int

  /// The one-dimensional array backing the matrix in row-major order.
  /// `Matrix[i,j] == grid[i*columns + j]`
  public internal(set) var grid: [T]

  /// Returns the transpose of the matrix.
  public var transpose: Matrix<T> {
    var result = Matrix(rows: columns, columns: rows, repeating: self[0,0])
    for i in 0..<rows {
      for j in 0..<columns {
        result[j,i] = self[i,j]
      }
    }
    return result
  }

  // MARK: Getting and Setting elements

  // Provides random access for getting and setting elements using square bracket notation.
  // The first argument is the row number.
  // The first argument is the column number.
  public subscript(row: Int, column: Int) -> T {
    get {
      precondition(indexIsValidForRow(row, column: column), "Index out of range")
      return grid[(row * columns) + column]
    }
    set {
      precondition(indexIsValidForRow(row, column: column), "Index out of range")
      grid[(row * columns) + column] = newValue
    }
  }

  // MARK: Private Properties and Helper Methods

  fileprivate func indexIsValidForRow(_ row: Int, column: Int) -> Bool {
    return row >= 0 && row < rows && column >= 0 && column < columns
  }
}


extension Matrix: MutableCollection {


  // MARK: MutableCollectionType Protocol Conformance

  public typealias MatrixIndex = Int

  /// Always zero, which is the index of the first element when non-empty.
  public var startIndex : MatrixIndex {
    return 0
  }

  /// Always `rows*columns`, which is the successor of the last valid subscript argument.
  public var endIndex : MatrixIndex {
    return rows*columns
  }

  /// Returns the position immediately after the given index.
  /// - Parameter i: A valid index of the collection. `i` must be less than
  ///   `endIndex`.
  /// - Returns: The index value immediately after `i`.
  public func index(after i: Int) -> Int {
    return i + 1
  }

  /// Provides random access to elements using the matrix back-end array coordinate
  /// in row-major order.
  /// Matrix[row, column] is preferred.
  public subscript(position: MatrixIndex) -> T {
    get {
      return self[position/columns, position % columns]
    }
    set {
      self[position/columns, position % columns] = newValue
    }
  }
}

extension Matrix: ExpressibleByArrayLiteral {

  // MARK: ExpressibleByArrayLiteral Protocol Conformance

  /// Constructs a matrix using an array literal.
  public init(arrayLiteral elements: Array<T>...) {
    self.init(elements)
  }
}

extension Matrix: CustomStringConvertible {

  // MARK: CustomStringConvertible Protocol Conformance

  /// A string containing a suitable textual
  /// representation of the matrix.
  public var description: String {
    var result = "["
    for i in 0..<rows {
      if i != 0 {
        result += ", "
      }
      let start = i*columns
      let end = start + columns
      result += "[" + grid[start..<end].map {"\($0)"}.joined(separator: ", ") + "]"
    }
    result += "]"
    return result
  }
}

// MARK: Matrix Standard Operators

/// Returns `true` if and only if the matrices contain the same elements
/// at the same coordinates.
/// The underlying elements must conform to the `Equatable` protocol.
public func ==<T: Equatable>(lhs: Matrix<T>, rhs: Matrix<T>) -> Bool {
  return lhs.columns == rhs.columns && lhs.rows == rhs.rows &&
    lhs.grid == rhs.grid
}

public func !=<T: Equatable>(lhs: Matrix<T>, rhs: Matrix<T>) -> Bool {
  return !(lhs == rhs)
}

#if os(OSX) || os(iOS)
  import Foundation
  import Accelerate

  // MARK: Matrix Linear Algebra Operations

  // Inversion

  /// Returns the inverse of the given matrix or nil if it doesn't exist.
  /// If the argument is a non-square matrix an error is triggered.
  public func inverse(_ matrix: Matrix<Double>) -> Matrix<Double>? {
    if matrix.columns != matrix.rows {
      fatalError("Can't invert a non-square matrix.")
    }
    var invMatrix = matrix
    var N = __CLPK_integer(sqrt(Double(invMatrix.grid.count)))
    var pivots = [__CLPK_integer](repeating: 0, count: Int(N))
    var workspace = [Double](repeating: 0.0, count: Int(N))
    var error : __CLPK_integer = 0
    // LU factorization
    dgetrf_(&N, &N, &invMatrix.grid, &N, &pivots, &error)
    if error != 0 {
      return nil
    }
    // Matrix inversion
    dgetri_(&N, &invMatrix.grid, &N, &pivots, &workspace, &N, &error)
    if error != 0 {
      return nil
    }
    return invMatrix
  }

  // Addition

  /// Performs matrix and matrix addition.
  public func +(lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    if lhs.rows != rhs.rows || lhs.columns != rhs.columns {
      fatalError("Impossible to add different size matrices")
    }
    var result = rhs
    cblas_daxpy(Int32(lhs.grid.count), 1.0, lhs.grid, 1, &(result.grid), 1)
    return result
  }

  /// Performs matrix and matrix addition.
  public func +=(lhs: inout Matrix<Double>, rhs: Matrix<Double>) {
    lhs.grid = (lhs + rhs).grid
  }

  /// Performs matrix and scalar addition.
  public func +(lhs: Matrix<Double>, rhs: Double) -> Matrix<Double> {
    let scalar = rhs
    var result = Matrix<Double>(rows: lhs.rows, columns: lhs.columns, repeating: scalar)
    cblas_daxpy(Int32(lhs.grid.count), 1, lhs.grid, 1, &(result.grid), 1)
    return result
  }

  /// Performs scalar and matrix addition.
  public func +(lhs: Double, rhs: Matrix<Double>) -> Matrix<Double> {
    return rhs + lhs
  }

  /// Performs matrix and scalar addition.
  public func +=(lhs: inout Matrix<Double>, rhs: Double) {
    lhs.grid = (lhs + rhs).grid
  }

  // Subtraction

  /// Performs matrix and matrix subtraction.
  public func -(lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    if lhs.rows != rhs.rows || lhs.columns != rhs.columns {
      fatalError("Impossible to substract different size matrices.")
    }
    var result = lhs
    cblas_daxpy(Int32(lhs.grid.count), -1.0, rhs.grid, 1, &(result.grid), 1)
    return result
  }

  /// Performs matrix and matrix subtraction.
  public func -=(lhs: inout Matrix<Double>, rhs: Matrix<Double>) {
    lhs.grid = (lhs - rhs).grid
  }

  /// Performs matrix and scalar subtraction.
  public func -(lhs: Matrix<Double>, rhs: Double) -> Matrix<Double> {
    return lhs + (-rhs)
  }

  /// Performs matrix and scalar subtraction.
  public func -=(lhs: inout Matrix<Double>, rhs: Double) {
    lhs.grid = (lhs - rhs).grid
  }

  // Negation

  /// Negates all the values in a matrix.
  public prefix func -(m: Matrix<Double>) -> Matrix<Double> {
    var result = m
    cblas_dscal(Int32(m.grid.count), -1.0, &(result.grid), 1)
    return result
  }

  // Multiplication

  /// Performs matrix and matrix multiplication.
  /// The first argument's number of columns must match the second argument's number of rows,
  /// otherwise an error is triggered.
  public func *(lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    if lhs.columns != rhs.rows {
      fatalError("Matrix product is undefined: first.columns != second.rows")
    }
    var result = Matrix<Double>(rows: lhs.rows, columns: rhs.columns, repeating: 0.0)
    cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, Int32(lhs.rows), Int32(rhs.columns),
                Int32(lhs.columns), 1.0, lhs.grid, Int32(lhs.columns), rhs.grid, Int32(rhs.columns),
                0.0, &(result.grid), Int32(result.columns))

    return result
  }

  /// Performs matrix and scalar multiplication.
  public func *(lhs: Matrix<Double>, rhs: Double) -> Matrix<Double> {
    var result = lhs
    cblas_dscal(Int32(lhs.grid.count), rhs, &(result.grid), 1)
    return result
  }

  /// Performs scalar and matrix multiplication.
  public func *(lhs: Double, rhs: Matrix<Double>) -> Matrix<Double> {
    return rhs*lhs
  }

  /// Performs matrix and scalar multiplication.
  public func *=(lhs: inout Matrix<Double>, rhs: Double) {
    lhs.grid = (lhs*rhs).grid
  }

  // Division

  /// Performs matrix and scalar division.
  public func /(lhs: Matrix<Double>, rhs: Double) -> Matrix<Double> {
    return lhs * (1/rhs)
  }
  
  /// Performs matrix and scalar division.
  public func /=(lhs: inout Matrix<Double>, rhs: Double) {
    lhs.grid = (lhs/rhs).grid
  }
#endif

