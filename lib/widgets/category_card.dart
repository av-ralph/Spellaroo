import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String label;
  final String gradientColors;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.label,
    required this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _parseGradient(gradientColors),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _parseGradient(
                gradientColors,
              ).first.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Baloo2',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _parseGradient(String colors) {
    switch (colors) {
      case 'from-lime-400 to-green-500':
        return [const Color(0xFFA3E635), const Color(0xFF22C55E)];
      case 'from-amber-400 to-orange-500':
        return [const Color(0xFFFBBF24), const Color(0xFFF97316)];
      case 'from-rose-400 to-red-500':
        return [const Color(0xFFFB7185), const Color(0xFFEF4444)];
      case 'from-violet-400 to-fuchsia-500':
        return [const Color(0xFFA78BFA), const Color(0xFFD946EF)];
      default:
        return [const Color(0xFFFBBF24), const Color(0xFFF97316)];
    }
  }
}
