import 'package:flutter/material.dart';
import 'package:snake_game/game.dart';
import 'package:snake_game/game_audio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GameAudio.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Game(),
    );
  }
}
