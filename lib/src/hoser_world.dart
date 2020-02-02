import 'dart:math';

class SimplePrinter {
  // Returns something like '{3x5}'.
  String asString(SimpleWorld rw) {
    return '{${rw.nRows}x${rw.nCols}}';
  }
}

// Uses ANSI terminal control sequences to paint
// the world to a terminal.
//
// See: https://en.wikipedia.org/wiki/ANSI_escape_code#Unix-like_systems
//
class SimplePrinterAnsi extends SimplePrinter {
  static const _csi = "\x1B[";
  static const _csiClear = _csi + "2J";
  static const _csiReset = _csi + "00m";
  static const _csiBrownBackground = _csi + "43m";
  static const _csiBlackBackground = _csi + "40m";
  static const _csiCyanBackground = _csi + "46m";

  static const _fancyAlive = _csiCyanBackground + " " + _csiReset;
  static const _fancyDead = _csiBlackBackground + " " + _csiReset;

  @override
  String asString(SimpleWorld rw) {
    var lines = StringBuffer();
    lines.write(_csiClear);
    for (var i = 0; i < rw.nRows; i++) {
      var sb = StringBuffer();
      for (var j = 0; j < rw.nCols; j++) {
        sb.write(rw.isAlive(i, j) ? _fancyAlive : _fancyDead);
      }
      lines.writeln(sb);
    }
    lines.write(_csiReset);
    return lines.toString();
  }
}

class SimplePrinterPlain extends SimplePrinter {
  static const _charAlive = "#";

  @override
  String asString(SimpleWorld rw) {
    var lines = StringBuffer();
    for (var i = 0; i < rw.nRows; i++) {
      var sb = StringBuffer();
      for (var j = 0; j < rw.nCols; j++) {
        sb.write(rw.isAlive(i, j) ? _charAlive : SimpleWorld.charDead);
      }
      lines.writeln(sb);
    }
    return lines.toString();
  }
}

class SimpleWorld {
  // The world has fixed dimensions.
  final int _numRows;
  final int _numCols;

  // The cell list must have length _numRows * _numCols.
  // A true entry is alive, a false entry is not alive.
  List<bool> _cells;

  int get nRows => _numRows;

  int get nCols => _numCols;

  // Return an index into cells using {row,column} notation.
  int index(int i, int j) => (i * _numCols) + j;

  bool isAlive(int i, int j) => _cells[index(i, j)];

  bool customIsAlive(f, int i, int j) => _cells[f(i, j)];

  SimpleWorld(int numRows, int numCols, List<bool> cells)
      : _numRows = numRows,
        _numCols = numCols,
        _cells = cells;

  factory SimpleWorld.empty(int nR, int nC) {
    return SimpleWorld(nR, nC, List<bool>.filled(nR * nC, false));
  }

  factory SimpleWorld.identity(int nR) {
    final w = SimpleWorld.empty(nR, nR);
    for (int i = 0; i < nR; i++) {
      w._cells[w.index(i, i)] = true;
    }
    return w;
  }

  String asString(SimplePrinter p) {
    return p.asString(this);
  }

  static final SimplePrinter _defaultPrinter = SimplePrinterPlain();

  @override
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
  factory SimpleWorld.fromString(String x) {
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
        list.add(ch != SimpleWorld.charDead);
      });
    });
    return SimpleWorld(nR, nC, list);
  }
}

// Copy as the transpose.
SimpleWorld transpose(SimpleWorld w) {
  final newCells = List<bool>(w._numRows * w._numCols);
  final newIndex = (int j, int i) => (j * w._numRows) + i;
  for (int i = 0; i < w._numRows; i++) {
    for (int j = 0; j < w._numCols; j++) {
      newCells[newIndex(j, i)] = w.isAlive(i, j);
    }
  }
  return SimpleWorld(w._numCols, w._numRows, newCells);
}

// Mutate in place, pasting the incoming world.
// The world won't grow to fit.  If incoming world is
// too big or too far 'down' or 'right' it will
// overwrite cells due to boundary wrapping.
SimpleWorld paste(
    SimpleWorld w, final int cI, final int cJ, final SimpleWorld incoming) {
  for (int i = 0; i < incoming.nRows; i++) {
    final int tI = (cI + i) % w._numRows;
    for (int j = 0; j < incoming.nCols; j++) {
      w._cells[w.index(tI, (cJ + j) % w._numCols)] = incoming.isAlive(i, j);
    }
  }
  return w;
}

// Copy as a world big enough to accept the paste.
SimpleWorld expandToPaste(
    SimpleWorld w, final int cI, final int cJ, final SimpleWorld incoming) {
  SimpleWorld empty = SimpleWorld.empty(max(w._numRows, cI + incoming.nRows),
      max(w._numCols, cJ + incoming.nCols));
  return paste(paste(empty, 0, 0, w), cI, cJ, incoming);
}

// Copy as a clockwise 90 degree rotation.
SimpleWorld clockwise90(SimpleWorld w) {
  final newCells = List<bool>(w._numRows * w._numCols);
  final newIndex = (int i, int j) => (j * w._numRows) + (w._numRows - 1 - i);
  for (int i = 0; i < w._numRows; i++) {
    for (int j = 0; j < w._numCols; j++) {
      newCells[newIndex(i, j)] = w.isAlive(i, j);
    }
  }
  return SimpleWorld(w._numCols, w._numRows, newCells);
}

// Copy as a counter-clockwise 90 degree rotation.
SimpleWorld counterClockwise90(SimpleWorld w) {
  final newCells = List<bool>(w._numRows * w._numCols);
  final newIndex = (int i, int j) => ((w._numCols - 1 - j) * w._numRows) + i;
  for (int i = 0; i < w._numRows; i++) {
    for (int j = 0; j < w._numCols; j++) {
      newCells[newIndex(i, j)] = w.isAlive(i, j);
    }
  }
  return SimpleWorld(w._numCols, w._numRows, newCells);
}

// Copy, adding padding on left.
SimpleWorld padLeft(SimpleWorld w, int n) {
  return paste(SimpleWorld.empty(w._numRows, w._numCols + n), 0, n, w);
}

// Copy, adding padding on right.
SimpleWorld padRight(SimpleWorld w, int n) {
  return paste(SimpleWorld.empty(w._numRows, w._numCols + n), 0, 0, w);
}

// Copy, adding padding on top.
SimpleWorld padTop(SimpleWorld w, int n) {
  return paste(SimpleWorld.empty(w._numRows + n, w._numCols), n, 0, w);
}

// Copy, adding padding on bottom.
SimpleWorld padBottom(SimpleWorld w, int n) {
  return paste(SimpleWorld.empty(w._numRows + n, w._numCols), 0, 0, w);
}

// Copy, appending the other world on the right.
// Fill empty lines as needed on the bottom of
// the shorter of the two.
// No attempt to center the shorter one.
SimpleWorld appendRight(SimpleWorld w, other) {
  return expandToPaste(w, 0, w._numCols, other);
}

// Copy, appending the other world to the bottom.
// Fill empty columns as needed on the right of
// the thinner of the two.
// No attempt to center the thinner one.
SimpleWorld appendBottom(SimpleWorld w, other) {
  return expandToPaste(w, w._numRows, 0, other);
}
