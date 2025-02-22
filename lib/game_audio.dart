import 'package:flutter_soloud/flutter_soloud.dart';

class GameAudio {
  GameAudio._();

  static final _soloud = SoLoud.instance;
  static late AudioSource _biteSource;

  static Future<void> init() async {
    await _soloud.init();
    _biteSource = await _soloud.loadAsset('assets/bite.mp3');
  }

  static Future<void> playBite() async {
    await _soloud.play(_biteSource);
  }
}
