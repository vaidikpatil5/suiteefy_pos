import 'package:flutter/material.dart';

class MandalaBackground extends StatelessWidget {
  final Widget child;
  const MandalaBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      color: bgColor, // use theme background color
      child: Stack(
        children: [
          // Centered mandala image with opacity
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: 0.65,
                child: Image.asset(
                  'assets/mandala_top.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Foreground content
          child,
        ],
      ),
    );
  }
}
