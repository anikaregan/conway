import 'dart:io';

import 'package:conway/rectangle_world.dart';
import 'package:conway/world_printer_ansi.dart';

// ConwayWorld holds an instance of Conway's Game of Life.
// It pushes a RectangleWorld through evolutionary steps
// obeying Conway's rules.
class ConwayWorld {
  RectangleWorld _w;

  ConwayWorld(RectangleWorld rw) : _w = rw;

  factory ConwayWorld.fromString(String x) {
    return ConwayWorld(RectangleWorld.fromString(x));
  }

  // Delegate a few methods for exposure.
  ConwayWorld clockwise90() => ConwayWorld(_w.clockwise90());

  ConwayWorld padLeft(int n) => ConwayWorld(_w.padLeft(n));

  ConwayWorld padRight(int n) => ConwayWorld(_w.padRight(n));

  ConwayWorld padTop(int n) => ConwayWorld(_w.padTop(n));

  ConwayWorld padBottom(int n) => ConwayWorld(_w.padBottom(n));

  ConwayWorld appendRight(ConwayWorld w) => ConwayWorld(_w.appendRight(w._w));

  ConwayWorld appendBottom(ConwayWorld w) => ConwayWorld(_w.appendBottom(w._w));

  String toString() => _w.toString();

  // Take N life steps.
  ConwayWorld takeSteps(int n) {
    for (int i = 0; i < n; i++) {
      takeStep();
    }
    return this;
  }

  // Take one step in the life of the world.
  ConwayWorld takeStep() {
    final List<bool> newCells = List<bool>(_w.nRows * _w.nCols);
    for (var i = 0; i < _w.nRows; i++) {
      for (var j = 0; j < _w.nCols; j++) {
        newCells[_w.index(i, j)] = _aliveAtNextStep(i, j);
      }
    }
    _w = RectangleWorld(_w.nRows, _w.nCols, newCells);
    return this;
  }

  // Returns true if the cell at {i,j} should be alive
  // in the next generation.
  // This method embodies Conway's Game of Life rules.
  bool _aliveAtNextStep(int i, int j) {
    int count = _neighborCountUpToFour(i, j);
    if (_w.isAlive(i, j)) {
      // It's alive, but will only stay alive if
      // exactly 2 or 3 neighbors are alive (i.e.,
      // the cell has some living friends, but not
      // so many that there's overpopulation).
      return count == 2 || count == 3;
    }
    // The cell is dead, but bring it to life if there
    // are exactly three neighbors.
    return count == 3;
  }

  // Returns count of the neighbors of cell {i,j},
  // stopping at four.
  // Per Conway's Game of Life rules, a count that
  // exceeds four has the same impact as a count of
  // four, so there's no reason to count past four.
  int _neighborCountUpToFour(int i, int j) {
    int count = 0;
    for (Function f in [
      _aboveLeft,
      _aboveSame,
      _aboveRight,
      _sameLeft,
      _sameRight,
      _downLeft,
      _downSame,
      _downRight,
    ]) {
      if (_w.customIsAlive(f, i, j)) {
        count++;
        if (count == 4) {
          return count;
        }
      }
    }
    return count;
  }

  // Thinking of the cell {i,j}, _aboveLeft returns the index
  // to the cell in the row above, in the column to the left.
  int _aboveLeft(int i, int j) => _w.index(_prevRow(i), _prevCol(j));

  int _aboveSame(int i, int j) => _w.index(_prevRow(i), j);

  int _aboveRight(int i, int j) => _w.index(_prevRow(i), _nextCol(j));

  int _sameLeft(int i, int j) => _w.index(i, _prevCol(j));

  // _sameSame isn't needed, but this is what it would look like:
  // int _sameSame(int i, int j) => index(i, j);

  int _sameRight(int i, int j) => _w.index(i, _nextCol(j));

  int _downLeft(int i, int j) => _w.index(_nextRow(i), _prevCol(j));

  int _downSame(int i, int j) => _w.index(_nextRow(i), j);

  int _downRight(int i, int j) => _w.index(_nextRow(i), _nextCol(j));

  // Given row i, find the previous row, wrapping around as needed.
  int _prevRow(int i) => (i + _w.nRows - 1) % _w.nRows;

  int _prevCol(int j) => (j + _w.nCols - 1) % _w.nCols;

  int _nextRow(int i) => (i + 1) % _w.nRows;

  int _nextCol(int j) => (j + 1) % _w.nCols;

  // This has a period of two.
  static final blinker = ConwayWorld.fromString('''
.....
..#..
..#..
..#..
.....
''');

// This has a period of fifteen.
  static final pentaDecathlon = ConwayWorld.fromString('''
...........
...........
...........
....###....
...#...#...
...#...#...
....###....
...........
...........
...........
...........
....###....
...#...#...
...#...#...
....###....
...........
...........
...........
''');

  // This moves to the right.
  static final lightweightSpaceship = ConwayWorld.fromString('''
.......
.#..#..
.....#.
.#...#.
..####.
.......
''');

  // This moves down and right.
  static final glider = ConwayWorld.fromString('''
.......
...#...
....#..
..###..
.......
''');

// This emits a glider every 15 iterations down and to the right.
  static final gosperGliderGun = ConwayWorld.fromString('''
......................................
.........................#............
.......................#.#............
.............##......##............##.
............#...#....##............##.
.##........#.....#...##...............
.##........#...#.##....#.#............
...........#.....#.......#............
............#...#.....................
.............##.......................
......................................
''');

  static ConwayWorld gliderFleet() {
    final g = glider.padRight(3).padBottom(2);
    print(g.toString());
    final w = g.appendRight(g).appendRight(g).appendRight(g).appendRight(g);
    print(w.toString());
    print(w.padLeft(3).toString());
    print(w.appendBottom(w.padLeft(3)).toString());
    return w.appendBottom(w.padLeft(3));
  }

  static ConwayWorld gunFight() {
    final g1 = gosperGliderGun.padLeft(2).padTop(2).padBottom(14).padRight(30);
    final g2 = g1.clockwise90().clockwise90();
    return g1.appendBottom(g2);
  }

  static void movie(ConwayWorld w, int n) {
    print(w._w.asString(WorldPrinterAnsi()));
    for (int i = 0; i < n; i++) {
      w.takeStep();
      sleep(const Duration(milliseconds: 100));
      print(w._w.asString(WorldPrinterAnsi()));
    }
  }
}

main() {
  ConwayWorld.movie(ConwayWorld.blinker, 80);
  ConwayWorld.movie(ConwayWorld.pentaDecathlon, 80);
  ConwayWorld.movie(ConwayWorld.lightweightSpaceship.padRight(30).padBottom(1), 80);
  ConwayWorld.movie(ConwayWorld.glider.padRight(30).padBottom(30), 80);
  ConwayWorld.movie(ConwayWorld.gunFight(), 1000);
}
