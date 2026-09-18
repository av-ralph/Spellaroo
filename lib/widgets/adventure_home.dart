import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/audio_service.dart';

/// Real, focusable controls over the illustrated home scene.
class AdventureButton extends StatelessWidget {
  const AdventureButton({
    super.key,
    required this.label,
    required this.icon,
    required this.colors,
    required this.onPressed,
    this.primary = false,
  });
  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final radius = BorderRadius.circular(bounds.maxHeight * .32);
      final fontSize = math.min(
        primary ? 28.0 : 21.0,
        bounds.maxWidth / (primary ? 11 : 7.4),
      );
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: .85),
              offset: const Offset(0, 5),
            ),
            const BoxShadow(
              color: Color(0x55032F20),
              blurRadius: 10,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: .35),
                width: 3,
              ),
            ),
            child: InkWell(
              onTap: () {
                AudioService.playClick();
                onPressed();
              },
              child: Stack(
                children: [
                  Positioned(
                    left: -20,
                    top: -bounds.maxHeight * .6,
                    child: Container(
                      width: bounds.maxWidth * .9,
                      height: bounds.maxHeight,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .09),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  if (primary) ...[
                    const Positioned(
                      left: 15,
                      bottom: 12,
                      child: Icon(
                        Icons.eco,
                        color: Color(0xFFA6E33C),
                        size: 31,
                      ),
                    ),
                    const Positioned(
                      right: 14,
                      bottom: 9,
                      child: Icon(
                        Icons.eco,
                        color: Color(0xFFA6E33C),
                        size: 36,
                      ),
                    ),
                  ],
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: primary ? 45 : 13,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            color: Colors.white,
                            size: primary ? 45 : 31,
                          ),
                          SizedBox(width: primary ? 15 : 10),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: fontSize,
                                  shadows: const [
                                    Shadow(
                                      color: Color(0x550B3B34),
                                      blurRadius: 3,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: primary ? 12 : 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white.withValues(alpha: .9),
                            size: primary ? 33 : 26,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class AdventureGreeting extends StatelessWidget {
  const AdventureGreeting(this.nickname, {super.key});
  final String nickname;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        flex: 6,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Stack(
            children: [
              Text(
                'Welcome, $nickname!',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 48,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 8
                    ..color = const Color(0xFF082650),
                  shadows: const [
                    Shadow(
                      color: Color(0x66002341),
                      offset: Offset(0, 5),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
              Text(
                'Welcome, $nickname!',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 48,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 5),
      const Expanded(
        flex: 5,
        child: FittedBox(
          child: Text(
            'Small steps make\nbig words!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              height: 1.2,
              fontSize: 25,
              letterSpacing: 1,
              color: Colors.white,
            ),
          ),
        ),
      ),
      Container(
        margin: const EdgeInsets.only(top: 5),
        width: 48,
        height: 3,
        decoration: BoxDecoration(
          color: const Color(0xFFFFDC46),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    ],
  );
}
