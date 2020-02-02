import 'dart:io';

import 'package:conway/conway.dart';

void movie(FlatWorld w, int n) {
  final pr = WorldPrinterAnsi();
  print(pr.asString(w));
  final e = ConwayEvolver(w);
  for (int i = 0; i < n; i++) {
    e.takeStep();
    sleep(const Duration(milliseconds: 100));
    print(pr.asString(e.w));
  }
}

main() {
  movie(ConwayEvolver.blinker, 80);
  movie(ConwayEvolver.pentaDecathlon, 80);
  movie(
      ConwayEvolver.lightweightSpaceship.padRight(30).padBottom(1), 80);
  movie(ConwayEvolver.glider.padRight(30).padBottom(30), 80);
  movie(ConwayEvolver.gunFight(), 1000);
}
