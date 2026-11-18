import 'package:flutter/material.dart';

class MyCardHighlight extends StatelessWidget {
  final bool isMyCard;
  final Widget child;

  const MyCardHighlight({
    super.key,
    required this.isMyCard,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return isMyCard
        ? Container(
            padding: const EdgeInsets.all(1.0), // outer glow thickness
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF5FD2), // pink neon
                  Color(0xFF7C4DFF), // purple neon
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.6),
                  blurRadius: 6,
                  spreadRadius: 0.5,
                ),
              ],
            ),
            child: Container(
              // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(5),
              ),
              child: child,
            ),
          )
        : child;
  }
}
