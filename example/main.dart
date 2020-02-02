import 'package:conway/conway.dart';

main() {
  ConwayWorld.movie(ConwayWorld.blinker, 80);
  ConwayWorld.movie(ConwayWorld.pentaDecathlon, 80);
  ConwayWorld.movie(ConwayWorld.lightweightSpaceship.padRight(30).padBottom(1), 80);
  ConwayWorld.movie(ConwayWorld.glider.padRight(30).padBottom(30), 80);
  ConwayWorld.movie(ConwayWorld.gunFight(), 1000);
}
