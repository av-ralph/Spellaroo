import 'package:flutter/material.dart';

class CoinBadge extends StatelessWidget {
  final int coins;
  const CoinBadge({super.key, required this.coins});
  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      label: '$coins coins',
      child: Container(
        constraints: const BoxConstraints(minHeight: 36),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE976), Color(0xFFFFBC29)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFFFEFAB), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22003958),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pets_rounded, size: 20, color: Color(0xFFC5800B)),
            const SizedBox(width: 6),
            Text(
              '$coins',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF67400A),
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
