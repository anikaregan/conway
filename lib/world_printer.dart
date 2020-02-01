import 'package:conway/rectangle_world.dart';

class WorldPrinter {
  // Returns something like '{3x5}'.
  String asString(RectangleWorld rw) {
    return '{${rw.nRows}x${rw.nCols}}';
  }
}
