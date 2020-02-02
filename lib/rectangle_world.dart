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
    for (int i = 1; i < lines.length; i++) {
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
    return RectangleWorld(nR, nC, List<bool>.filled(nR * nC, false));
  }

  factory RectangleWorld.identity(int nR) {
    final rw = RectangleWorld.empty(nR, nR);
    for (int i = 0; i < nR; i++) {
      rw._cells[rw.index(i, i)] = true;
    }
    return rw;
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
    return RectangleWorld(_numCols, _numRows, newCells);
  }

  // Paste the incoming world into this one, placing the incoming
  // world's {0,0} at this world's {cI,cJ}.  This world won't grow
  // to fit.  If incoming world is too big or too far 'down' or 'right'
  // it will overwrite cells due to boundary wrapping.
  RectangleWorld paste(final int cI, final int cJ, final RectangleWorld rw) {
    for (int i = 0; i < rw.nRows; i++) {
      final int tI = (cI + i) % _numRows;
      for (int j = 0; j < rw.nCols; j++) {
        _cells[index(tI, (cJ + j) % _numCols)] = rw.isAlive(i, j);
      }
    }
    return this;
  }

  // Like paste, but a new world is returned big enough to cleanly
  // accept the paste.
  RectangleWorld expandToPaste(
      final int cI, final int cJ, final RectangleWorld incoming) {
    RectangleWorld rw = RectangleWorld.empty(
        max(_numRows, cI + incoming.nRows), max(_numCols, cJ + incoming.nCols));
    return rw.paste(0, 0, this).paste(cI, cJ, incoming);
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
    return RectangleWorld(_numCols, _numRows, newCells);
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
    return RectangleWorld(_numCols, _numRows, newCells);
  }

  // Copy this, adding padding on left.
  RectangleWorld padLeft(int n) {
    var rw = RectangleWorld.empty(_numRows, _numCols + n);
    return rw.paste(0, n, this);
  }

  // Copy this, adding padding on right.
  RectangleWorld padRight(int n) {
    var rw = RectangleWorld.empty(_numRows, _numCols + n);
    return rw.paste(0, 0, this);
  }

  // Copy this, adding padding on top.
  RectangleWorld padTop(int n) {
    var rw = RectangleWorld.empty(_numRows + n, _numCols);
    return rw.paste(n, 0, this);
  }

  // Copy this, adding padding on bottom.
  RectangleWorld padBottom(int n) {
    var rw = RectangleWorld.empty(_numRows + n, _numCols);
    return rw.paste(0, 0, this);
  }

  // Append the other world to the right of this one.
  // Fill empty lines as needed on the bottom of the
  // shorter of the two.
  // No attempt to center the shorter one.
  RectangleWorld appendRight(RectangleWorld other) {
    return expandToPaste(0, _numCols, other);
  }

  // Append the other world to the bottom of this one.
  // Fill empty columns as needed on the right of the
  // thinner of the two.
  // No attempt to center the thinner one.
  RectangleWorld appendBottom(RectangleWorld other) {
    return expandToPaste(_numRows, 0, other);
  }
}
