import 'dart:math';

import 'package:conway/world_printer.dart';
import 'package:conway/world_printer_plain.dart';

// RectangleWorld holds a rectangular array of cells
// that can be alive or dead.
class RectangleWorld {
  // The world has fixed dimensions.
  final int _numRows;
  final int _numCols;

  // The cell list must have length _numRows * _numCols.
  // A true entry is alive, a false entry is not alive.
  final List<bool> _cells;

  int get nRows => _numRows;

  int get nCols => _numCols;

  RectangleWorld(int numRows, int numCols, List<bool> cells)
      : _numRows = numRows,
        _numCols = numCols,
        _cells = cells;

  // Return an index into cells using {row,column} notation.
  int index(int i, int j) => (i * _numCols) + j;

  bool isAlive(int i, int j) => _cells[index(i, j)];

  bool customIsAlive(f, int i, int j) => _cells[f(i, j)];

  String asString(WorldPrinter p) {
    return p.asString(this);
  }

  static final WorldPrinter _defaultPrinter = WorldPrinterPlain();

  String toString() {
    return asString(_defaultPrinter);
  }

  static const charDead = ".";

  // fromString initializes a world from a multi-line string
  // argument like
  //
  //    ...#...
  //    ..#.#..
  //    .#.#.#.
  //    ...#...
  //    ...#...
  //    ...#...
  //
  // The shape must be rectangular (not necessarily square).
  // Cells are initialized per the rules
  //              '.': dead
  //    anything else: alive
  //
  factory RectangleWorld.fromString(String x) {
    final rawLines = x.split('\n');
    var lines = List<String>();
    rawLines.forEach((line) {
      if (line.length > 0) {
        lines.add(line);
      }
    });
    if (lines.length < 2) {
      throw 'must supply at least two lines';
    }
    final nR = lines.length;
    final nC = lines[0].length;
    for (var i = 1; i < lines.length; i++) {
      if (lines[i].length != nC) {
        throw 'all lines must be same length';
      }
    }
    final list = List<bool>();
    lines.forEach((line) {
      line.split('').forEach((ch) {
        list.add(ch != RectangleWorld.charDead);
      });
    });
    return RectangleWorld(nR, nC, list);
  }

  factory RectangleWorld.empty(int nR, int nC) {
    return RectangleWorld(nR, nC, List<bool>(nR * nC));
  }

  // Copy this as a transpose.
  RectangleWorld transpose() {
    final newCells = List<bool>(_numRows * _numCols);
    final newIndex = (int j, int i) => (j * _numRows) + i;
    for (var i = 0; i < _numRows; i++) {
      for (var j = 0; j < _numCols; j++) {
        newCells[newIndex(j, i)] = isAlive(i, j);
      }
    }
    return RectangleWorld(_numCols, _numRows, newCells);
  }

  // Paste the incoming world into this one, placing the incoming
  // world's {0,0} at this world's {cI,cJ}.  This world won't grow
  // to fit.  If incoming world is too big or too far 'down' or 'right'
  // it will overwrite cells due to boundary wrapping.
  void paste(final int cI, final int cJ, final RectangleWorld rw) {
    for (var i = 0; i < rw.nRows; i++) {
      final int tI = (cI + i) % _numRows;
      for (var j = 0; j < rw.nCols; j++) {
        _cells[index(tI, (cJ + j) % _numCols)] = rw.isAlive(i, j);
      }
    }
  }

  // Like paste, but a new world is returned big enough to cleanly
  // accept the paste.
  RectangleWorld expandToPaste(
      final int cI, final int cJ, final RectangleWorld incoming) {
    RectangleWorld rw = RectangleWorld.empty(
        max(_numRows, cI + incoming.nRows), max(_numCols, cJ + incoming.nCols));
    rw.paste(0, 0, this);
    rw.paste(cI, cJ, incoming);
    return rw;
  }

  // Copy this as a clockwise 90 degree rotation.
  RectangleWorld clockwise90() {
    final newCells = List<bool>(_numRows * _numCols);
    final newIndex = (int i, int j) => (j * _numRows) + (_numRows - 1 - i);
    for (var i = 0; i < _numRows; i++) {
      for (var j = 0; j < _numCols; j++) {
        newCells[newIndex(i, j)] = isAlive(i, j);
      }
    }
    return RectangleWorld(_numCols, _numRows, newCells);
  }

  // Copy this as a counter-clockwise 90 degree rotation.
  RectangleWorld counterClockwise90() {
    final newCells = List<bool>(_numRows * _numCols);
    final newIndex = (int i, int j) => ((_numCols - 1 - j) * _numRows) + i;
    for (var i = 0; i < _numRows; i++) {
      for (var j = 0; j < _numCols; j++) {
        newCells[newIndex(i, j)] = isAlive(i, j);
      }
    }
    return RectangleWorld(_numCols, _numRows, newCells);
  }

  // Copy this, adding padding on left.
  RectangleWorld padLeft(int n) {
    final newNumCols = _numCols + n;
    final newCells = List<bool>(_numRows * newNumCols);
    final newIndex = (int i, int j) => (i * newNumCols) + j;
    for (var i = 0; i < _numRows; i++) {
      for (var j = 0; j < n; j++) {
        newCells[newIndex(i, j)] = false;
      }
      for (var j = 0; j < _numCols; j++) {
        newCells[newIndex(i, j + n)] = isAlive(i, j);
      }
    }
    return RectangleWorld(_numRows, newNumCols, newCells);
  }

  // Copy this, adding padding on right.
  RectangleWorld padRight(int n) {
    final newNumCols = _numCols + n;
    final newCells = List<bool>(_numRows * newNumCols);
    final newIndex = (int i, int j) => (i * newNumCols) + j;
    for (var i = 0; i < _numRows; i++) {
      for (var j = 0; j < _numCols; j++) {
        newCells[newIndex(i, j)] = isAlive(i, j);
      }
      for (var j = _numCols; j < newNumCols; j++) {
        newCells[newIndex(i, j)] = false;
      }
    }
    return RectangleWorld(_numRows, newNumCols, newCells);
  }

  // Copy this, adding padding on top.
  RectangleWorld padTop(int n) {
    final newNumRows = _numRows + n;
    final newCells = List<bool>(newNumRows * _numCols);
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < _numCols; j++) {
        newCells[index(i, j)] = false;
      }
    }
    for (var i = 0; i < _numRows; i++) {
      for (var j = 0; j < _numCols; j++) {
        newCells[index(i + n, j)] = isAlive(i, j);
      }
    }
    return RectangleWorld(newNumRows, _numCols, newCells);
  }

  // Copy this, adding padding on bottom.
  RectangleWorld padBottom(int n) {
    final newNumRows = _numRows + n;
    final newCells = List<bool>(newNumRows * _numCols);
    for (var i = 0; i < _numRows; i++) {
      for (var j = 0; j < _numCols; j++) {
        newCells[index(i, j)] = isAlive(i, j);
      }
    }
    for (var i = _numRows; i < newNumRows; i++) {
      for (var j = 0; j < _numCols; j++) {
        newCells[index(i, j)] = false;
      }
    }
    return RectangleWorld(newNumRows, _numCols, newCells);
  }

  // Append the other world to the right of this one.
  // Fill empty lines as needed on the bottom of the
  // shorter of the two.
  // No attempt to center the shorter one.
  RectangleWorld appendRight(RectangleWorld other) {
    RectangleWorld left = this, right = other;
    if (other._numRows > _numRows) {
      left = this.padBottom(other._numRows - _numRows);
    } else if (_numRows > other._numRows) {
      right = other.padBottom(_numRows - other._numRows);
    }
    assert(left._numRows == right._numRows);
    final newNumCols = left._numCols + right._numCols;
    final newNumRows = left._numRows;
    final newCells = List<bool>(newNumRows * newNumCols);
    final newIndex = (int i, int j) => (i * newNumCols) + j;
    for (var i = 0; i < newNumRows; i++) {
      for (var j = 0; j < left._numCols; j++) {
        newCells[newIndex(i, j)] = left.isAlive(i, j);
      }
      for (var j = 0; j < right._numCols; j++) {
        newCells[newIndex(i, j + left._numCols)] = right.isAlive(i, j);
      }
    }
    return RectangleWorld(newNumRows, newNumCols, newCells);
  }

  // Append the other world to the bottom of this one.
  // Fill empty columns as needed on the right of the
  // thinner of the two.
  // No attempt to center the thinner one.
  RectangleWorld appendBottom(RectangleWorld other) {
    RectangleWorld top = this, bottom = other;
    if (other._numCols > _numCols) {
      top = this.padRight(other._numCols - _numCols);
    } else if (_numCols > other._numCols) {
      bottom = other.padRight(_numCols - other._numCols);
    }
    assert(top._numCols == bottom._numCols);
    final newNumCols = top._numCols;
    final newNumRows = top._numRows + bottom._numRows;
    final newCells = List<bool>(newNumRows * newNumCols);
    final newIndex = (int i, int j) => (i * newNumCols) + j;
    for (var i = 0; i < top._numRows; i++) {
      for (var j = 0; j < newNumCols; j++) {
        newCells[newIndex(i, j)] = top.isAlive(i, j);
      }
    }
    for (var i = 0; i < bottom._numRows; i++) {
      for (var j = 0; j < newNumCols; j++) {
        newCells[newIndex(i + top.nRows, j)] = bottom.isAlive(i, j);
      }
    }
    return RectangleWorld(newNumRows, newNumCols, newCells);
  }
}

main() {
  var r1 = RectangleWorld.fromString('''
..#..
..##.
..###
..#..
..#..
..#..
''').padLeft(2).padTop(2).padBottom(3).padRight(10);
  var r2 = r1.clockwise90().clockwise90();
  var w = r1.appendBottom(r2);
  print(w.toString());
}
