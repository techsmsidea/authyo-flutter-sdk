import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Success state shown inside the card after verification: a green ring
/// that sweeps closed, then a check mark and the message — the same
/// animation the web widget plays.
class AuthyoVerifiedBadge extends StatefulWidget {
  const AuthyoVerifiedBadge({
    super.key,
    this.message = 'Verified successfully',
    this.fontFamily,
    this.color = const Color(0xFF4CAF50),
    this.size = 100,
  });

  final String message;
  final String? fontFamily;
  final Color color;
  final double size;

  @override
  State<AuthyoVerifiedBadge> createState() => _AuthyoVerifiedBadgeState();
}

class _AuthyoVerifiedBadgeState extends State<AuthyoVerifiedBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final sweep = Curves.easeOut.transform(_ctrl.value);
        // Check fades in over the last part of the sweep.
        final check = ((_ctrl.value - 0.8) / 0.2).clamp(0.0, 1.0);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _RingPainter(widget.color, sweep),
                child: Center(
                  child: Opacity(
                    opacity: check,
                    child: Icon(
                      Icons.check_rounded,
                      color: widget.color,
                      size: widget.size * 0.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: widget.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: widget.color,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.color, this.sweep);
  final Color color;
  final double sweep;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final rect = Offset.zero & size;
    canvas.drawArc(
      rect.deflate(3),
      -math.pi / 2,
      2 * math.pi * sweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.sweep != sweep || old.color != color;
}
