import 'dart:math';

import 'package:flutter/material.dart';

import '../theme.dart';

/// The EduNexus mark: an open book with a network of connected nodes rising
/// from it — learning that connects school, parents and students.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 72});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.brand,
        borderRadius: BorderRadius.circular(size * 0.26),
        boxShadow: [BoxShadow(color: AppColors.violet.withValues(alpha: 0.35), blurRadius: size * 0.3, offset: Offset(0, size * 0.1))],
      ),
      child: CustomPaint(painter: _MarkPainter()),
    );
  }
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final white = Paint()..color = Colors.white;
    final line = Paint()
      ..color = Colors.white
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;

    // book
    final left = Path()
      ..moveTo(w * 0.5, w * 0.78)
      ..quadraticBezierTo(w * 0.36, w * 0.68, w * 0.18, w * 0.70)
      ..lineTo(w * 0.18, w * 0.52)
      ..quadraticBezierTo(w * 0.36, w * 0.50, w * 0.5, w * 0.60)
      ..close();
    final right = Path()
      ..moveTo(w * 0.5, w * 0.78)
      ..quadraticBezierTo(w * 0.64, w * 0.68, w * 0.82, w * 0.70)
      ..lineTo(w * 0.82, w * 0.52)
      ..quadraticBezierTo(w * 0.64, w * 0.50, w * 0.5, w * 0.60)
      ..close();
    canvas.drawPath(left, white);
    canvas.drawPath(right, Paint()..color = Colors.white.withValues(alpha: 0.85));

    // nexus nodes
    final c = Offset(w * 0.5, w * 0.36);
    final nodes = [
      for (final a in [-150.0, -90.0, -30.0])
        c + Offset(cos(a * pi / 180), sin(a * pi / 180)) * (w * 0.2),
    ];
    for (final n in nodes) {
      canvas.drawLine(c, n, line);
    }
    canvas.drawLine(c, Offset(w * 0.5, w * 0.58), line);
    for (final n in nodes) {
      canvas.drawCircle(n, w * 0.055, white);
    }
    canvas.drawCircle(c, w * 0.085, Paint()..color = AppColors.saffron);
    canvas.drawCircle(c, w * 0.085, Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Decorative pseudo-QR used on ID cards and pickup passes in the demo.
class PseudoQr extends StatelessWidget {
  const PseudoQr({super.key, required this.data, this.size = 140});
  final String data;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8),
        child: SizedBox(width: size, height: size, child: CustomPaint(painter: _QrPainter(data))),
      );
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.data);
  final String data;

  @override
  void paint(Canvas canvas, Size s) {
    const n = 25;
    final cell = s.width / n;
    final p = Paint()..color = Colors.black;
    final r = Random(data.hashCode);
    bool finder(int x, int y) => (x < 7 && y < 7) || (x >= n - 7 && y < 7) || (x < 7 && y >= n - 7);
    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        if (finder(x, y)) continue;
        if (r.nextBool()) canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), p);
      }
    }
    for (final o in [Offset.zero, Offset((n - 7) * cell, 0), Offset(0, (n - 7) * cell)]) {
      canvas.drawRect(o & Size(cell * 7, cell * 7), p);
      canvas.drawRect((o + Offset(cell, cell)) & Size(cell * 5, cell * 5), Paint()..color = Colors.white);
      canvas.drawRect((o + Offset(cell * 2, cell * 2)) & Size(cell * 3, cell * 3), p);
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter old) => old.data != data;
}
