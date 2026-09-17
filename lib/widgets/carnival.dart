import 'package:flutter/material.dart';
import '../config/theme.dart';

class CarnivalRibbon extends StatelessWidget {
  const CarnivalRibbon(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 7),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8C00), Color(0xFFEA5422)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFA83917), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0xFFD8BD77), offset: Offset(0, 3)),
        ],
      ),
      child: Text(
        text.toUpperCase(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Baloo2',
          fontSize: 20,
          height: 1.1,
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class CarnivalButton extends StatelessWidget {
  const CarnivalButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppTheme.green,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color.lerp(color, Colors.black, 0.35)!,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.lerp(color, Colors.white, 0.22)!, color],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Color.lerp(color, Colors.black, 0.2)!,
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Baloo2',
                        fontSize: 18,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black26, offset: Offset(0, 2)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class CarnivalPennants extends StatelessWidget {
  const CarnivalPennants({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 30,
    width: double.infinity,
    child: CustomPaint(painter: _PennantsPainter()),
  );
}

class _PennantsPainter extends CustomPainter {
  const _PennantsPainter();
  @override
  void paint(Canvas canvas, Size size) {
    const colors = [
      AppTheme.orange,
      AppTheme.green,
      AppTheme.red,
      AppTheme.blue,
      AppTheme.purple,
      AppTheme.gold,
    ];
    final count = (size.width / 32).ceil();
    for (var i = 0; i < count; i++) {
      final x = i * 32.0;
      canvas.drawPath(
        Path()
          ..moveTo(x, 0)
          ..lineTo(x + 28, 0)
          ..lineTo(x + 14, 22)
          ..close(),
        Paint()..color = colors[i % colors.length],
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
