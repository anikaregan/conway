import 'package:conway/rectangle_world.dart';
import 'package:test/test.dart';

void main() {
  const _halfArrow = '''
..#..
..##.
..###
..#..
..#..
..#..
''';
  const _identity = '''
#.....
.#....
..#...
...#..
....#.
.....#
''';

  test('construction from string', () {
    expect(
        RectangleWorld.fromString(_halfArrow).toString(), equals(_halfArrow));
  });

  test('counterClockwise90', () {
    var w = RectangleWorld.fromString(_halfArrow);
    w = w.counterClockwise90();
    expect(w.toString(), equals('''
..#...
.##...
######
......
......
'''));
    expect(
        w
            .counterClockwise90()
            .counterClockwise90()
            .counterClockwise90()
            .toString(),
        equals(_halfArrow));
  });

  test('clockwise90', () {
    var w = RectangleWorld.fromString(_halfArrow);
    w = w.clockwise90();
    expect(w.toString(), equals('''
......
......
######
...##.
...#..
'''));
    expect(w.clockwise90().clockwise90().clockwise90().toString(),
        equals(_halfArrow));
  });

  test('transpose', () {
    var w = RectangleWorld.fromString(_halfArrow);
    w = w.transpose();
    expect(w.toString(), equals('''
......
......
######
.##...
..#...
'''));
    expect(RectangleWorld.fromString(_identity).transpose().toString(),
        equals(_identity));
    w = RectangleWorld.fromString('''
...#...
..#.#..
.#.#.#.
...#...
...#...
...#...
''');
    w = w.transpose();
    expect(w.toString(), equals('''
......
..#...
.#....
#.####
.#....
..#...
......
'''));
  });

  test('leftPadded', () {
    var w = RectangleWorld.fromString(_halfArrow).padLeft(2);
    expect(w.toString(), equals('''
....#..
....##.
....###
....#..
....#..
....#..
'''));
  });

  test('rightPadded', () {
    var w = RectangleWorld.fromString(_halfArrow).padRight(2);
    expect(w.toString(), equals('''
..#....
..##...
..###..
..#....
..#....
..#....
'''));
  });

  test('topPadded', () {
    var w = RectangleWorld.fromString(_halfArrow).padTop(2);
    expect(w.toString(), equals('''
.....
.....
..#..
..##.
..###
..#..
..#..
..#..
'''));
  });

  test('bottomPadded', () {
    var w = RectangleWorld.fromString(_halfArrow).padBottom(2);
    expect(w.toString(), equals('''
..#..
..##.
..###
..#..
..#..
..#..
.....
.....
'''));
  });

  test('append', () {
    var w = RectangleWorld.fromString(_halfArrow);
    w = w.appendRight(w).appendRight(w).appendRight(w);
    expect(w.toString(), equals('''
..#....#....#....#..
..##...##...##...##.
..###..###..###..###
..#....#....#....#..
..#....#....#....#..
..#....#....#....#..
'''));
    expect(w.appendBottom(w).toString(), equals('''
..#....#....#....#..
..##...##...##...##.
..###..###..###..###
..#....#....#....#..
..#....#....#....#..
..#....#....#....#..
..#....#....#....#..
..##...##...##...##.
..###..###..###..###
..#....#....#....#..
..#....#....#....#..
..#....#....#....#..
'''));
  });

  test('irregularAppendRight', () {
    var w = RectangleWorld.fromString(_halfArrow);
    w = w.appendRight(w.padTop(3));
    expect(w.toString(), equals('''
..#.......
..##......
..###.....
..#....#..
..#....##.
..#....###
.......#..
.......#..
.......#..
'''));
  });

  test('irregularAppendBottom', () {
    var w = RectangleWorld.fromString(_halfArrow);
    w = w.appendRight(w).appendRight(w);
    w = w.appendBottom(w.padLeft(3));
    expect(w.toString(), equals('''
..#....#....#.....
..##...##...##....
..###..###..###...
..#....#....#.....
..#....#....#.....
..#....#....#.....
.....#....#....#..
.....##...##...##.
.....###..###..###
.....#....#....#..
.....#....#....#..
.....#....#....#..
'''));
  });

  test('bigX', () {
    var ident = RectangleWorld.fromString(_identity);
    var v = ident.appendRight(ident.clockwise90());
    var x = v.appendBottom(v.clockwise90().clockwise90());
    expect(x.toString(), equals('''
#..........#
.#........#.
..#......#..
...#....#...
....#..#....
.....##.....
.....##.....
....#..#....
...#....#...
..#......#..
.#........#.
#..........#
'''));
  });

  test('mixItUp', () {
    var w = RectangleWorld.fromString(_halfArrow).padRight(2);
    var w1 = w.appendRight(w.clockwise90());
    var w2 = w.counterClockwise90().appendRight(w);
    w = w1.appendBottom(w2);
    expect(w.toString(), equals('''
..#..........
..##.........
..###..######
..#.......##.
..#.......#..
..#..........
.............
........#....
........##...
..#.....###..
.##.....#....
######..#....
........#....
.............
'''));
  });
}