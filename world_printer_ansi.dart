import 'package:scratch/rectangle_world.dart';
import 'package:scratch/world_printer.dart';

// Uses ANSI terminal control sequences to paint
// the world to a terminal.
//
// See: https://en.wikipedia.org/wiki/ANSI_escape_code#Unix-like_systems
//
class WorldPrinterAnsi extends WorldPrinter {
  static const _csi = "\x1B[";
  static const _csiClear = _csi + "2J";
  static const _csiReset = _csi + "00m";
  static const _csiBrownBackground = _csi + "43m";
  static const _csiBlackBackground = _csi + "40m";
  static const _csiCyanBackground = _csi + "46m";

  static const _fancyAlive = _csiCyanBackground + " " + _csiReset;
  static const _fancyDead = _csiBlackBackground + " " + _csiReset;

  @override
  String asString(RectangleWorld rw) {
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
