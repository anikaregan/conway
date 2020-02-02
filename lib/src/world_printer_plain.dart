import 'flat_world.dart';
import 'world_printer.dart';

class WorldPrinterPlain extends WorldPrinter {
  @override
  String asString(FlatWorld w) {
    var lines = StringBuffer();
    for (var i = 0; i < w.nRows; i++) {
      var sb = StringBuffer();
      for (var j = 0; j < w.nCols; j++) {
        sb.writeCharCode(
            w.isAlive(i, j) ? FlatWorld.chAlive : FlatWorld.chDead);
      }
      lines.writeln(sb);
    }
    return lines.toString();
  }
}
