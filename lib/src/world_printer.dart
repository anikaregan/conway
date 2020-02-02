import 'flat_world.dart';

class WorldPrinter {
  // Returns something like '{3x5}'.
  String asString(FlatWorld w) {
    return '{${w.nRows}x${w.nCols}}';
  }
}
