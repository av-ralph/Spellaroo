import 'package:flutter/material.dart';
import 'character_painter.dart';
import 'outfit_layers.dart';

/// Display-only framing leaves the original uploaded image files untouched.
/// Bounds include ears, hands and tails while excluding unused side background.
class CharacterPortrait extends StatelessWidget {
  const CharacterPortrait({
    super.key,
    required this.characterKey,
    this.equippedByCategory = const {},
  });
  final String characterKey;
  final Map<String, Equipment> equippedByCategory;
  static const assets = {
    'kangaroo': 'assets/images/Spellaroo.png',
    'cat': 'assets/images/Character 2.png',
    'bunny': 'assets/images/Character 3.png',
    'bear': 'assets/images/Character 4.png',
    'fox': 'assets/images/Character 5.png',
    'panda': 'assets/images/Character 6.png',
  };
  static const _sideBounds = {
    'cat': (left: 390.0, right: 1130.0),
    'bunny': (left: 460.0, right: 1130.0),
    'bear': (left: 450.0, right: 1130.0),
    'fox': (left: 390.0, right: 1130.0),
    'panda': (left: 440.0, right: 1140.0),
  };

  @override
  Widget build(BuildContext context) {
    final key = assets.containsKey(characterKey) ? characterKey : 'kangaroo';
    final bounds = _sideBounds[key];
    final sourceWidth = key == 'kangaroo' ? 1024.0 : 1536.0;
    final sourceHeight = key == 'kangaroo' ? 1536.0 : 1024.0;
    final left = bounds?.left ?? 0;
    final width = bounds == null ? sourceWidth : bounds.right - bounds.left;
    final fit = OutfitFit.forCharacter(key);
    Widget artwork() => Image.asset(
      assets[key]!,
      width: sourceWidth,
      height: sourceHeight,
      fit: BoxFit.fill,
      gaplessPlayback: true,
    );
    Widget garment(String category, List<Offset> polygon) {
      final color = Color(
        CharacterPainter.resolveColor(equippedByCategory[category]!.colorName),
      );
      final r = color.r, g = color.g, b = color.b;
      return ClipPath(
        clipper: GarmentClipper(polygon),
        child: ColorFiltered(
          colorFilter: ColorFilter.matrix([
            .32 * r,
            1.07 * r,
            .11 * r,
            0,
            20 * r,
            .32 * g,
            1.07 * g,
            .11 * g,
            0,
            20 * g,
            .32 * b,
            1.07 * b,
            .11 * b,
            0,
            20 * b,
            0,
            0,
            0,
            1,
            0,
          ]),
          child: artwork(),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: width,
        height: sourceHeight,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: sourceWidth,
            maxWidth: sourceWidth,
            minHeight: sourceHeight,
            maxHeight: sourceHeight,
            child: Transform.translate(
              offset: Offset(-left, 0),
              child: SizedBox(
                width: sourceWidth,
                height: sourceHeight,
                child: Stack(
                  children: [
                    artwork(),
                    if (equippedByCategory.containsKey('tops'))
                      garment('tops', fit.top),
                    if (key != 'kangaroo' &&
                        equippedByCategory.containsKey('bottoms'))
                      garment('bottoms', fit.bottom),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: OutfitAccessoriesPainter(
                            key,
                            equippedByCategory,
                          ),
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
}
