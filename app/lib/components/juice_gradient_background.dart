import 'package:flutter/material.dart';

class JuiceGradientBackground extends StatelessWidget {
  const JuiceGradientBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEFFFF4),
            Color(0xFFD5FFF0),
            Color(0xFFF8FFFB),
          ],
        ),
      ),
      child: child,
    );
  }
}
