import 'rectangle_world.dart';
import 'world_printer.dart';

class WorldPrinterPlain extends WorldPrinter {

  static const _charAlive = "#";

  @override
  String asString(RectangleWorld rw) {
    var lines = StringBuffer();
    for (var i = 0; i < rw.nRows; i++) {
      var sb = StringBuffer();
      for (var j = 0; j < rw.nCols; j++) {
        sb.write(rw.isAlive(i, j) ? _charAlive : RectangleWorld.charDead);
      }
      lines.writeln(sb);
    }
    return lines.toString();
  }
}
