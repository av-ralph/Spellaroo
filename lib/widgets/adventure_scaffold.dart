import 'package:flutter/material.dart';

/// Quiet scenery and a readable paper surface shared by the adventure screens.
class AdventureScaffold extends StatelessWidget {
  const AdventureScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.extendBody = false,
    this.backgroundColor,
  });
  final PreferredSizeWidget? appBar;
  final Widget body;
  final bool extendBody;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) => Scaffold(
    extendBody: extendBody,
    backgroundColor: backgroundColor ?? const Color(0xFFEAF6F4),
    appBar: appBar,
    body: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/Homescreen_BG.png',
          fit: BoxFit.cover,
          excludeFromSemantics: true,
          opacity: const AlwaysStoppedAnimation(.22),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xBBE9F8FF), Color(0xF2FFFBEF), Color(0xDEEFF8E7)],
              stops: [0, .48, 1],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: body,
          ),
        ),
      ],
    ),
  );
}

class AdventureIntro extends StatelessWidget {
  const AdventureIntro({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.color = const Color(0xFF087E9D),
  });
  final String title, subtitle;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 16),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white, Color.lerp(color, Colors.white, .91)!],
      ),
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x10083448),
          blurRadius: 18,
          offset: Offset(0, 7),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: color, height: 1.1),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF526575),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
