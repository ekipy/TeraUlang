import 'dart:math' as math;
import 'package:flutter/material.dart';

class WaveBackground extends StatefulWidget {
  final Widget child;
  const WaveBackground({super.key, required this.child});

  @override
  State<WaveBackground> createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends State<WaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(); // wave animasi loop
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF81D4FA), // biru muda (langit)
                    Color(0xFF0277BD), // biru sedang
                    Color(0xFF01579B), // biru laut gelap
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _WavePainter(_controller.value),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;
  _WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // gradient untuk wave
    final gradient1 = LinearGradient(
      colors: [
        const Color(0xFF0277BD),
        const Color(0xFF4DD0E1),
      ], // biru → toska
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final gradient2 = LinearGradient(
      colors: [
        const Color(0xFF01579B),
        const Color(0xFF81D4FA),
      ], // biru tua → biru muda
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );

    final paint1 = Paint()
      ..shader = gradient1.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    final paint2 = Paint()
      ..shader = gradient2.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path1 = Path();
    final path2 = Path();

    // Wave pertama
    path1.moveTo(0, size.height * 0.8);
    for (double x = 0; x <= size.width; x++) {
      path1.lineTo(
        x,
        size.height * 0.8 +
            20 *
                math.sin(
                  (x / size.width * 2 * math.pi) +
                      (animationValue * 2 * math.pi),
                ),
      );
    }
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();

    // Wave kedua
    path2.moveTo(0, size.height * 0.85);
    for (double x = 0; x <= size.width; x++) {
      path2.lineTo(
        x,
        size.height * 0.85 +
            30 *
                math.sin(
                  (x / size.width * 2 * math.pi) +
                      (animationValue * 2 * math.pi) +
                      math.pi / 2,
                ),
      );
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    // gambar wave
    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => true;
}
