import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:snake_game/game.dart';

class Dpad extends StatelessWidget {
  const Dpad({super.key, required this.onTap});

  final void Function(Direction direction) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(32),
      width: 160,
      child: Transform.rotate(
        angle: 45 * math.pi / 180,
        child: GridView.count(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            _buildArrowButton(Icons.keyboard_arrow_up, Direction.up),
            _buildArrowButton(Icons.keyboard_arrow_right, Direction.right),
            _buildArrowButton(Icons.keyboard_arrow_left, Direction.left),
            _buildArrowButton(Icons.keyboard_arrow_down, Direction.down),
          ],
        ),
      ),
    );
  }

  /// Creates an arrow button
  Widget _buildArrowButton(IconData icon, Direction direction) {
    return Center(
      child: GestureDetector(
        onTap: () => onTap(direction),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            shape: BoxShape.circle,
          ),
          child: Transform.rotate(
            angle: -45 * math.pi / 180,
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
