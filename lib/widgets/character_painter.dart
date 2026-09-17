import 'package:flutter/material.dart';

class Equipment {
  final String name;
  final String colorName;
  Equipment({required this.name, required this.colorName});
}

class CharacterPainter extends CustomPainter {
  final String characterKey;
  final Map<String, Equipment> equippedByCategory;

  CharacterPainter({
    required this.characterKey,
    this.equippedByCategory = const {},
  });

  static const Map<String, _CharDef> _charDefs = {
    'kangaroo': _CharDef(
      bodyColor: 0xFFD9945F,
      bodyDark: 0xFFB9713A,
      earShape: 'tall',
      hasTail: true,
    ),
    'cat': _CharDef(
      bodyColor: 0xFFE8A855,
      bodyDark: 0xFFC4823A,
      earShape: 'triangle',
      hasTail: true,
    ),
    'bunny': _CharDef(
      bodyColor: 0xFFF4E4D6,
      bodyDark: 0xFFE0C7AE,
      earShape: 'long',
      hasTail: false,
    ),
    'bear': _CharDef(
      bodyColor: 0xFF8B5A3C,
      bodyDark: 0xFF6B4128,
      earShape: 'round',
      hasTail: false,
    ),
    'panda': _CharDef(
      bodyColor: 0xFFFAFAFA,
      bodyDark: 0xFF2B2B2B,
      earShape: 'round',
      hasTail: false,
    ),
    'fox': _CharDef(
      bodyColor: 0xFFE07A3E,
      bodyDark: 0xFFB85A26,
      earShape: 'triangle',
      hasTail: true,
    ),
  };

  static final List<List<dynamic>> _nameColorPatterns = [
    [RegExp(r'denim', caseSensitive: false), 0xFF3B5998],
    [RegExp(r'yellow|golden|gold', caseSensitive: false), 0xFFFACC15],
    [RegExp(r'rainbow|galaxy|festival', caseSensitive: false), 0xFFA855F7],
    [RegExp(r'white|snow|pearl', caseSensitive: false), 0xFFE5E7EB],
    [RegExp(r'black|shadow', caseSensitive: false), 0xFF374151],
    [RegExp(r'pink|heart|flower', caseSensitive: false), 0xFFEC4899],
    [RegExp(r'green|nature|leaf', caseSensitive: false), 0xFF22C55E],
    [RegExp(r'blue|sky|ocean', caseSensitive: false), 0xFF3B82F6],
    [RegExp(r'red|fire', caseSensitive: false), 0xFFEF4444],
    [RegExp(r'orange|sunshine|sun', caseSensitive: false), 0xFFF97316],
    [RegExp(r'purple|magic|wizard', caseSensitive: false), 0xFFA855F7],
    [
      RegExp(r'brown|explorer|hiking|adventure', caseSensitive: false),
      0xFF92400E,
    ],
    [RegExp(r'silver|sport|cleat', caseSensitive: false), 0xFF94A3B8],
  ];

  static final _palette = [
    0xFFF97316,
    0xFFFACC15,
    0xFF22C55E,
    0xFF3B82F6,
    0xFFA855F7,
    0xFFEC4899,
    0xFFEF4444,
    0xFF14B8A6,
    0xFF6366F1,
    0xFFF59E0B,
  ];

  static int resolveColor(String? colorName) {
    if (colorName == null || colorName.isEmpty) return 0xFF94A3B8;
    for (final pattern in _nameColorPatterns) {
      final regex = pattern[0] as RegExp;
      final color = pattern[1] as int;
      if (regex.hasMatch(colorName)) return color;
    }
    var hash = 0;
    for (var i = 0; i < colorName.length; i++) {
      hash = (31 * hash + colorName.codeUnitAt(i)) % 997;
    }
    return _palette[hash % _palette.length];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final def = _charDefs[characterKey] ?? _charDefs['kangaroo']!;
    final scale = size.width / 200;
    final stroke = Paint()
      ..color = const Color(0xFF3F2A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scale;

    final bodyColor = Color(def.bodyColor);
    final bodyDark = Color(def.bodyDark);

    final hairColor = _resolveCat('hair') ?? bodyDark;
    final headwearColor = _resolveCat('headwear');
    final topsColor = _resolveCat('tops') ?? bodyColor;
    final bottomsColor = _resolveCat('bottoms') ?? bodyDark;
    final shoesColor = _resolveCat('shoes') ?? bodyDark;
    final glassesColor = _resolveCat('glasses');
    final accessoriesColor = _resolveCat('accessories');
    final bagsColor = _resolveCat('bags');
    final effectsColor = _resolveCat('effects');

    canvas.save();
    canvas.scale(scale, scale);

    // Effects aura
    if (effectsColor != null) {
      final effectsPaint = Paint()
        ..color = effectsColor.withValues(alpha: 0.15);
      canvas.drawCircle(const Offset(100, 140), 95, effectsPaint);
      final dotPaint = Paint()..color = effectsColor.withValues(alpha: 0.6);
      canvas.drawCircle(const Offset(40, 70), 6, dotPaint);
      canvas.drawCircle(const Offset(165, 100), 5, dotPaint);
      canvas.drawCircle(const Offset(30, 180), 4, dotPaint);
      canvas.drawCircle(const Offset(172, 190), 6, dotPaint);
    }

    // Tail
    if (def.hasTail) {
      final tailPath = Path()
        ..moveTo(128, 190)
        ..quadraticBezierTo(168, 195, 162, 232)
        ..quadraticBezierTo(156, 248, 138, 242)
        ..quadraticBezierTo(152, 225, 144, 208)
        ..quadraticBezierTo(138, 198, 128, 195)
        ..close();
      canvas.drawPath(tailPath, Paint()..color = bodyDark);
      canvas.drawPath(tailPath, stroke);
    }

    // Legs
    final legPaint = Paint()..color = bottomsColor;
    _roundRect(canvas, Offset(76, 186), 20, 54, 10, legPaint, stroke);
    _roundRect(canvas, Offset(104, 186), 20, 54, 10, legPaint, stroke);

    // Shoes
    final shoePaint = Paint()..color = shoesColor;
    _ellipse(canvas, const Offset(86, 244), 17, 11, shoePaint, stroke);
    _ellipse(canvas, const Offset(114, 244), 17, 11, shoePaint, stroke);

    // Arms
    final armPaint = Paint()..color = topsColor;
    _roundRect(canvas, Offset(44, 126), 22, 56, 11, armPaint, stroke);
    _roundRect(canvas, Offset(134, 126), 22, 56, 11, armPaint, stroke);

    // Body
    _roundRect(canvas, Offset(67, 120), 66, 72, 22, armPaint, stroke);

    // Bag
    if (bagsColor != null) {
      _roundRect(
        canvas,
        Offset(130, 148),
        20,
        28,
        5,
        Paint()..color = bagsColor,
        stroke,
      );
    }

    // Accessories
    if (accessoriesColor != null) {
      canvas.drawCircle(
        const Offset(100, 142),
        9,
        Paint()..color = accessoriesColor,
      );
      canvas.drawCircle(const Offset(100, 142), 9, stroke);
    }

    // Ears
    _drawEars(canvas, def.earShape, bodyColor, bodyDark, stroke);

    // Head
    canvas.drawCircle(const Offset(100, 70), 40, Paint()..color = bodyColor);
    canvas.drawCircle(const Offset(100, 70), 40, stroke);

    // Eyes
    canvas.drawCircle(
      const Offset(87, 68),
      4.5,
      Paint()..color = const Color(0xFF2B2117),
    );
    canvas.drawCircle(
      const Offset(113, 68),
      4.5,
      Paint()..color = const Color(0xFF2B2117),
    );

    // Nose
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(100, 80), width: 12, height: 8),
      Paint()..color = bodyDark,
    );

    // Mouth
    final mouthPath = Path()
      ..moveTo(92, 88)
      ..quadraticBezierTo(100, 94, 108, 88);
    canvas.drawPath(
      mouthPath,
      Paint()
        ..color = const Color(0xFF2B2117)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Hair
    final hairPath = Path()
      ..moveTo(60, 58)
      ..quadraticBezierTo(100, 12, 140, 58)
      ..quadraticBezierTo(140, 38, 100, 28)
      ..quadraticBezierTo(60, 38, 60, 58)
      ..close();
    canvas.drawPath(hairPath, Paint()..color = hairColor);
    canvas.drawPath(hairPath, stroke);

    // Headwear
    if (headwearColor != null) {
      _roundRect(
        canvas,
        Offset(62, 22),
        76,
        15,
        7.5,
        Paint()..color = headwearColor,
        stroke,
      );
    }

    // Glasses
    if (glassesColor != null) {
      final glassesPaint = Paint()
        ..color = glassesColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;
      canvas.drawCircle(const Offset(87, 68), 10, glassesPaint);
      canvas.drawCircle(const Offset(113, 68), 10, glassesPaint);
      canvas.drawLine(
        const Offset(97, 68),
        const Offset(103, 68),
        glassesPaint,
      );
    }

    canvas.restore();
  }

  Color? _resolveCat(String category) {
    final equip = equippedByCategory[category];
    if (equip == null) return null;
    return Color(resolveColor(equip.colorName));
  }

  void _drawEars(
    Canvas canvas,
    String shape,
    Color bodyColor,
    Color bodyDark,
    Paint stroke,
  ) {
    final earPaint = Paint()..color = bodyColor;
    final innerPaint = Paint()..color = bodyDark;

    switch (shape) {
      case 'tall':
        _ellipse(
          canvas,
          const Offset(76, 26),
          13,
          29,
          earPaint,
          stroke,
          rotation: -0.314,
        );
        _ellipse(
          canvas,
          const Offset(124, 26),
          13,
          29,
          earPaint,
          stroke,
          rotation: 0.314,
        );
        _ellipse(
          canvas,
          const Offset(76, 26),
          7,
          20,
          innerPaint,
          stroke,
          rotation: -0.314,
          skipStroke: true,
        );
        _ellipse(
          canvas,
          const Offset(124, 26),
          7,
          20,
          innerPaint,
          stroke,
          rotation: 0.314,
          skipStroke: true,
        );
        break;
      case 'long':
        _ellipse(
          canvas,
          const Offset(82, 8),
          10,
          38,
          earPaint,
          stroke,
          rotation: -0.14,
        );
        _ellipse(
          canvas,
          const Offset(118, 8),
          10,
          38,
          earPaint,
          stroke,
          rotation: 0.14,
        );
        _ellipse(
          canvas,
          const Offset(82, 8),
          5,
          28,
          innerPaint,
          stroke,
          rotation: -0.14,
          skipStroke: true,
        );
        _ellipse(
          canvas,
          const Offset(118, 8),
          5,
          28,
          innerPaint,
          stroke,
          rotation: 0.14,
          skipStroke: true,
        );
        break;
      case 'triangle':
        final triLeft = Path()
          ..moveTo(64, 40)
          ..lineTo(72, 6)
          ..lineTo(92, 34)
          ..close();
        final triRight = Path()
          ..moveTo(136, 40)
          ..lineTo(128, 6)
          ..lineTo(108, 34)
          ..close();
        canvas.drawPath(triLeft, earPaint);
        canvas.drawPath(triLeft, stroke);
        canvas.drawPath(triRight, earPaint);
        canvas.drawPath(triRight, stroke);
        break;
      default: // round
        canvas.drawCircle(const Offset(68, 38), 16, earPaint);
        canvas.drawCircle(const Offset(68, 38), 16, stroke);
        canvas.drawCircle(const Offset(132, 38), 16, earPaint);
        canvas.drawCircle(const Offset(132, 38), 16, stroke);
    }
  }

  void _roundRect(
    Canvas canvas,
    Offset pos,
    double w,
    double h,
    double r,
    Paint fill,
    Paint stroke,
  ) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pos.dx, pos.dy, w, h),
      Radius.circular(r),
    );
    canvas.drawRRect(rect, fill);
    canvas.drawRRect(rect, stroke);
  }

  void _ellipse(
    Canvas canvas,
    Offset center,
    double rx,
    double ry,
    Paint fill,
    Paint stroke, {
    double rotation = 0,
    bool skipStroke = false,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: rx * 2,
      height: ry * 2,
    );
    canvas.drawOval(rect, fill);
    if (!skipStroke) canvas.drawOval(rect, stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CharacterPainter oldDelegate) =>
      oldDelegate.characterKey != characterKey ||
      oldDelegate.equippedByCategory != equippedByCategory;
}

class _CharDef {
  final int bodyColor;
  final int bodyDark;
  final String earShape;
  final bool hasTail;
  const _CharDef({
    required this.bodyColor,
    required this.bodyDark,
    required this.earShape,
    required this.hasTail,
  });
}
