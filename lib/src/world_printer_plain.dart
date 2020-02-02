import 'rectangle_world.dart';
import 'world_printer.dart';

class WorldPrinterPlain extends WorldPrinter {
  @override
  String asString(RectangleWorld rw) {
    var lines = StringBuffer();
    for (var i = 0; i < rw.nRows; i++) {
      var sb = StringBuffer();
      for (var j = 0; j < rw.nCols; j++) {
        sb.writeCharCode(
            rw.isAlive(i, j) ? RectangleWorld.chAlive : RectangleWorld.chDead);
      }
      lines.writeln(sb);
    }
    return lines.toString();
  }
}
