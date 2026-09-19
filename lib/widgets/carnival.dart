import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/audio_service.dart';

class CarnivalRibbon extends StatelessWidget {
  const CarnivalRibbon(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFB9D5CD), endIndent: 12)),
        Flexible(
          flex: 5,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF176777),
              height: 1.15,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFB9D5CD), indent: 12)),
      ],
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
  Widget build(BuildContext context) {
    final tone = onPressed == null ? const Color(0xFF9DAFB0) : color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          boxShadow: [
            BoxShadow(
              color: Color.lerp(tone, Colors.black, .22)!,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: tone.withValues(alpha: .18),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(23),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.lerp(tone, Colors.white, .22)!, tone],
              ),
              borderRadius: BorderRadius.circular(23),
              border: Border.all(color: Colors.white54, width: 2),
            ),
            child: InkWell(
              onTap: onPressed == null
                  ? null
                  : () {
                      AudioService.playClick();
                      onPressed!();
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 17,
                ),
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
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          fontSize: 19,
                          height: 1.2,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Colors.black26, offset: Offset(0, 2)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white70,
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
}

/// Small trail marker replaces the busy carnival bunting.
class CarnivalPennants extends StatelessWidget {
  const CarnivalPennants({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: 16, bottom: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.eco_rounded, size: 15, color: Color(0xFF31A788)),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            'THE SPELLAROO ADVENTURE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w800,
              color: Color(0xFF527575),
            ),
          ),
        ),
        SizedBox(width: 8),
        Icon(Icons.auto_awesome, size: 14, color: Color(0xFFD4A22A)),
      ],
    ),
  );
}
