import 'dart:math';

import 'world_printer.dart';
import 'world_printer_plain.dart';

// RectangleWorld holds a rectangular array of cells
// that can be alive or dead.
class RectangleWorld {
  // The world has fixed dimensions.
  final int _numRows;
  final int _numCols;

  // A true entry is alive, a false entry is not alive.
  final List<bool> _cells;

  int get nRows => _numRows;

  int get nCols => _numCols;

  // Failed assertion means the world isn't rectangular.
  RectangleWorld(int numRows, List<bool> cells)
      : _numRows = numRows,
        _numCols = cells.length ~/ numRows,
        _cells = cells,
        assert(cells.length == (numRows * (cells.length ~/ numRows)));

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

  static final chDead = ".".codeUnitAt(0);
  static final chAlive = "#".codeUnitAt(0);

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
    var lines = List<List<int>>();
    rawLines.forEach((line) {
      if (line.length > 0) {
        lines.add(line.codeUnits);
      }
    });
    if (lines.length < 2) {
      throw 'must supply at least two lines';
    }
    final nR = lines.length;
    final nC = lines[0].length;
    for (int i = 1; i < lines.length; i++) {
      if (lines[i].length != nC) {
        throw 'length (${lines[i].length}) of line $i must match length ($nC) of first line';
      }
    }
    final list = List<bool>(nR * nC);
    int k = 0;
    lines.forEach((line) {
      line.forEach((ch) {
        list[k] = (ch != RectangleWorld.chDead);
        k++;
      });
    });
    return RectangleWorld(nR, list);
  }

  factory RectangleWorld.empty(int nR, int nC) {
    return RectangleWorld(nR, List<bool>.filled(nR * nC, false));
  }

  factory RectangleWorld.identity(int nR) {
    final w = RectangleWorld.empty(nR, nR);
    for (int i = 0; i < nR; i++) {
      w._cells[w.index(i, i)] = true;
    }
    return w;
  }

  // Copy this as a transpose.
  RectangleWorld transpose() {
    final newCells = List<bool>(_numRows * _numCols);
    final newIndex = (int j, int i) => (j * _numRows) + i;
    for (int i = 0; i < _numRows; i++) {
      for (int j = 0; j < _numCols; j++) {
        newCells[newIndex(j, i)] = isAlive(i, j);
      }
    }
    return RectangleWorld(_numCols, newCells);
  }

  // Copy this as a clockwise 90 degree rotation.
  RectangleWorld clockwise90() {
    final newCells = List<bool>(_numRows * _numCols);
    final newIndex = (int i, int j) => (j * _numRows) + (_numRows - 1 - i);
    for (int i = 0; i < _numRows; i++) {
      for (int j = 0; j < _numCols; j++) {
        newCells[newIndex(i, j)] = isAlive(i, j);
      }
    }
    return RectangleWorld(_numCols, newCells);
  }

  // Copy this as a counter-clockwise 90 degree rotation.
  RectangleWorld counterClockwise90() {
    final newCells = List<bool>(_numRows * _numCols);
    final newIndex = (int i, int j) => ((_numCols - 1 - j) * _numRows) + i;
    for (int i = 0; i < _numRows; i++) {
      for (int j = 0; j < _numCols; j++) {
        newCells[newIndex(i, j)] = isAlive(i, j);
      }
    }
    return RectangleWorld(_numCols, newCells);
  }

  // Paste the other world into this one, placing the other
  // world's {0,0} at this world's {cI,cJ}.  This world won't grow
  // to fit.  If other world is too big or too far 'down' or 'right'
  // it will overwrite cells due to boundary wrapping.
  _paste(final int cI, final int cJ, final RectangleWorld other) {
    for (int i = 0; i < other.nRows; i++) {
      final int tI = (cI + i) % _numRows;
      for (int j = 0; j < other.nCols; j++) {
        _cells[index(tI, (cJ + j) % _numCols)] = other.isAlive(i, j);
      }
    }
  }

  // Copy this with the other world pasted in at the given location.
  // Result will be large enough to contain both.
  RectangleWorld paste(final int cI, final int cJ, final RectangleWorld other) {
    var w = RectangleWorld.empty(
        max(_numRows, cI + other.nRows), max(_numCols, cJ + other.nCols));
    w._paste(0, 0, this);
    w._paste(cI, cJ, other);
    return w;
  }

  // Copy this, adding padding on left.
  RectangleWorld padLeft(int n) {
    var w = RectangleWorld.empty(_numRows, _numCols + n);
    w._paste(0, n, this);
    return w;
  }

  // Copy this, adding padding on right.
  RectangleWorld padRight(int n) {
    var w = RectangleWorld.empty(_numRows, _numCols + n);
    w._paste(0, 0, this);
    return w;
  }

  // Copy this, adding padding on top.
  RectangleWorld padTop(int n) {
    var w = RectangleWorld.empty(_numRows + n, _numCols);
    w._paste(n, 0, this);
    return w;
  }

  // Copy this, adding padding on bottom.
  RectangleWorld padBottom(int n) {
    var w = RectangleWorld.empty(_numRows + n, _numCols);
    w._paste(0, 0, this);
    return w;
  }

  // Append the other world to the right of this one.
  // Fill empty lines as needed on the bottom of the
  // shorter of the two.
  // No attempt to center the shorter one.
  RectangleWorld appendRight(RectangleWorld other) {
    return paste(0, _numCols, other);
  }

  // Append the other world to the bottom of this one.
  // Fill empty columns as needed on the right of the
  // thinner of the two.
  // No attempt to center the thinner one.
  RectangleWorld appendBottom(RectangleWorld other) {
    return paste(_numRows, 0, other);
  }
}
