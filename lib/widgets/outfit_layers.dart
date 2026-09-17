import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'character_painter.dart';

/// Coordinates are fitted to the original artwork, before portrait cropping.
class OutfitFit {
  final List<Offset> top, bottom;
  final Offset forehead, eyes, neck;
  final double headWidth;
  const OutfitFit(
    this.top,
    this.bottom,
    this.forehead,
    this.eyes,
    this.neck,
    this.headWidth,
  );

  static List<Offset> points(List<num> values) => [
    for (var i = 0; i < values.length; i += 2)
      Offset(values[i].toDouble(), values[i + 1].toDouble()),
  ];
  static OutfitFit forCharacter(String key) {
    if (key == 'kangaroo') {
      return OutfitFit(
        points([
          395,
          639,
          454,
          627,
          570,
          688,
          655,
          739,
          679,
          654,
          710,
          671,
          724,
          703,
          803,
          730,
          817,
          793,
          877,
          826,
          862,
          860,
          817,
          877,
          781,
          851,
          807,
          962,
          812,
          995,
          699,
          1021,
          543,
          1007,
          531,
          963,
          483,
          922,
          433,
          896,
          408,
          860,
          365,
          853,
          328,
          877,
          347,
          804,
          377,
          728,
        ]),
        points([
          538,
          1025,
          659,
          1052,
          810,
          1014,
          834,
          1090,
          807,
          1173,
          755,
          1280,
          638,
          1316,
          607,
          1261,
          561,
          1329,
          480,
          1328,
          526,
          1214,
          550,
          1145,
        ]),
        const Offset(592, 283),
        const Offset(586, 393),
        const Offset(638, 718),
        360,
      );
    }
    final top = switch (key) {
      'bunny' => [
        637.0,
        517,
        704,
        525,
        793,
        588,
        812,
        611,
        847,
        545,
        886,
        535,
        912,
        554,
        911,
        597,
        957,
        646,
        980,
        695,
        985,
        739,
        972,
        762,
        958,
        721,
        927,
        705,
        915,
        712,
        939,
        760,
        935,
        812,
        862,
        839,
        781,
        839,
        648,
        813,
        638,
        792,
        672,
        781,
        688,
        786,
        718,
        761,
        737,
        717,
        710,
        714,
        681,
        735,
        678,
        767,
        651,
        785,
        606,
        766,
        587,
        718,
        593,
        677,
        625,
        617,
        618,
        589,
      ],
      'bear' => [
        586.0,
        462,
        655,
        474,
        732,
        502,
        796,
        550,
        820,
        563,
        857,
        507,
        900,
        496,
        935,
        520,
        941,
        565,
        978,
        609,
        1007,
        669,
        1016,
        713,
        1002,
        740,
        988,
        723,
        976,
        692,
        956,
        682,
        937,
        691,
        950,
        730,
        978,
        754,
        959,
        784,
        950,
        811,
        851,
        826,
        736,
        819,
        612,
        789,
        605,
        767,
        646,
        756,
        659,
        765,
        683,
        747,
        706,
        711,
        693,
        688,
        671,
        691,
        652,
        720,
        654,
        745,
        617,
        762,
        579,
        734,
        550,
        702,
        540,
        665,
        552,
        610,
        579,
        540,
        567,
        505,
      ],
      'panda' => [
        568.0,
        480,
        636,
        480,
        719,
        511,
        784,
        560,
        818,
        593,
        857,
        535,
        886,
        526,
        922,
        548,
        938,
        597,
        977,
        630,
        1007,
        685,
        1016,
        728,
        1001,
        755,
        983,
        769,
        981,
        739,
        962,
        704,
        941,
        696,
        926,
        700,
        948,
        755,
        951,
        787,
        947,
        821,
        856,
        843,
        724,
        835,
        587,
        797,
        586,
        775,
        627,
        780,
        653,
        777,
        681,
        748,
        707,
        701,
        695,
        692,
        666,
        697,
        634,
        727,
        622,
        761,
        590,
        773,
        553,
        742,
        522,
        698,
        529,
        657,
        557,
        603,
        543,
        560,
      ],
      'fox' => [
        613.0,
        480,
        674,
        476,
        728,
        513,
        798,
        555,
        817,
        584,
        847,
        524,
        881,
        515,
        912,
        548,
        914,
        584,
        953,
        621,
        986,
        672,
        1003,
        711,
        1001,
        740,
        979,
        759,
        973,
        728,
        949,
        704,
        929,
        704,
        916,
        713,
        939,
        761,
        941,
        798,
        930,
        826,
        839,
        839,
        743,
        826,
        634,
        803,
        632,
        781,
        661,
        775,
        693,
        785,
        716,
        757,
        730,
        718,
        709,
        710,
        691,
        721,
        672,
        750,
        669,
        772,
        636,
        781,
        600,
        760,
        567,
        721,
        559,
        684,
        573,
        643,
        604,
        590,
        585,
        560,
      ],
      _ => [
        624.0,
        452,
        680,
        458,
        734,
        498,
        790,
        541,
        812,
        550,
        841,
        481,
        874,
        465,
        903,
        485,
        905,
        520,
        943,
        568,
        973,
        622,
        987,
        671,
        981,
        704,
        963,
        720,
        960,
        690,
        940,
        666,
        921,
        666,
        910,
        677,
        928,
        711,
        938,
        741,
        936,
        779,
        901,
        799,
        821,
        810,
        727,
        796,
        629,
        778,
        625,
        751,
        672,
        739,
        691,
        750,
        715,
        724,
        733,
        681,
        706,
        680,
        685,
        699,
        670,
        730,
        670,
        739,
        638,
        744,
        600,
        724,
        574,
        695,
        565,
        660,
        579,
        615,
        611,
        549,
        598,
        516,
      ],
    };
    final bottom = switch (key) {
      'bunny' => [
        647.0,
        811,
        739,
        835,
        836,
        841,
        929,
        816,
        944,
        870,
        909,
        885,
        819,
        900,
        797,
        878,
        778,
        903,
        697,
        896,
        623,
        873,
      ],
      'bear' => [
        610.0,
        790,
        735,
        821,
        850,
        828,
        945,
        808,
        957,
        901,
        888,
        921,
        790,
        914,
        782,
        863,
        762,
        918,
        665,
        922,
        579,
        902,
      ],
      'panda' => [
        585.0,
        799,
        720,
        838,
        849,
        844,
        944,
        821,
        963,
        908,
        882,
        929,
        780,
        928,
        770,
        873,
        745,
        931,
        647,
        930,
        554,
        908,
      ],
      'fox' => [
        634.0,
        807,
        743,
        830,
        843,
        840,
        931,
        815,
        957,
        898,
        893,
        919,
        795,
        919,
        787,
        872,
        773,
        921,
        688,
        918,
        608,
        897,
      ],
      _ => [
        630.0,
        783,
        727,
        799,
        824,
        812,
        921,
        793,
        944,
        895,
        860,
        911,
        786,
        906,
        788,
        851,
        765,
        909,
        692,
        909,
        595,
        891,
      ],
    };
    return OutfitFit(
      points(top),
      points(bottom),
      Offset(800, key == 'bunny' ? 278 : 192),
      Offset(794, key == 'bunny' ? 377 : 322),
      Offset(811, key == 'cat' ? 529 : 575),
      key == 'bunny' ? 350 : 390,
    );
  }
}

class GarmentClipper extends CustomClipper<Path> {
  final List<Offset> points;
  GarmentClipper(this.points);
  @override
  Path getClip(Size size) => Path()..addPolygon(points, true);
  @override
  bool shouldReclip(GarmentClipper oldClipper) => oldClipper.points != points;
}

class OutfitAccessoriesPainter extends CustomPainter {
  final String characterKey;
  final Map<String, Equipment> equipment;
  OutfitAccessoriesPainter(this.characterKey, this.equipment);
  Color color(Equipment item) =>
      Color(CharacterPainter.resolveColor(item.colorName));
  void shape(Canvas c, Path path, Color color) {
    c.drawShadow(path, Colors.black54, 5, false);
    c.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Color.lerp(color, Colors.white, .35)!,
            color,
            Color.lerp(color, Colors.black, .25)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(path.getBounds()),
    );
    c.drawPath(
      path,
      Paint()
        ..color = Color.lerp(color, Colors.black, .35)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round,
    );
  }

  Path star(Offset center, double r) {
    return Path()..addPolygon([
      for (var i = 0; i < 10; i++)
        Offset(
          center.dx +
              math.cos(-math.pi / 2 + i * math.pi / 5) *
                  r *
                  (i.isEven ? 1 : .45),
          center.dy +
              math.sin(-math.pi / 2 + i * math.pi / 5) *
                  r *
                  (i.isEven ? 1 : .45),
        ),
    ], true);
  }

  @override
  void paint(Canvas c, Size size) {
    final fit = OutfitFit.forCharacter(characterKey);
    final bottom = equipment['bottoms'];
    if (characterKey == 'kangaroo' && bottom != null) {
      final shorts = Path()
        ..moveTo(359, 1011)
        ..quadraticBezierTo(404, 1000, 425, 1020)
        ..quadraticBezierTo(450, 1060, 506, 1042)
        ..quadraticBezierTo(680, 1056, 818, 992)
        ..quadraticBezierTo(863, 1108, 851, 1237)
        ..quadraticBezierTo(780, 1295, 670, 1280)
        ..lineTo(630, 1190)
        ..lineTo(596, 1310)
        ..quadraticBezierTo(471, 1352, 354, 1275)
        ..quadraticBezierTo(315, 1140, 359, 1011)
        ..close();
      shape(c, shorts, color(bottom));
      final seam = Paint()
        ..color = Colors.white.withValues(alpha: .55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      c.drawPath(
        Path()
          ..moveTo(364, 1043)
          ..quadraticBezierTo(574, 1110, 823, 1026),
        seam,
      );
      c.drawPath(
        Path()
          ..moveTo(639, 1081)
          ..lineTo(630, 1190),
        seam,
      );
      c.drawPath(
        Path()
          ..moveTo(365, 1250)
          ..quadraticBezierTo(470, 1325, 590, 1287),
        seam,
      );
      c.drawPath(
        Path()
          ..moveTo(674, 1254)
          ..quadraticBezierTo(776, 1270, 843, 1217),
        seam,
      );
      c.drawPath(
        Path()
          ..moveTo(371, 1073)
          ..quadraticBezierTo(420, 1109, 402, 1185)
          ..quadraticBezierTo(460, 1210, 493, 1166)
          ..lineTo(505, 1094),
        seam,
      );
    }
    final band = equipment['headbands'];
    if (band != null) {
      final p = fit.forehead;
      final w = fit.headWidth / 2;
      shape(
        c,
        Path()
          ..moveTo(p.dx - w, p.dy + 27)
          ..quadraticBezierTo(p.dx, p.dy - 33, p.dx + w, p.dy + 27)
          ..lineTo(p.dx + w - 5, p.dy + 61)
          ..quadraticBezierTo(p.dx, p.dy + 4, p.dx - w + 5, p.dy + 61)
          ..close(),
        color(band),
      );
      if (band.name.toLowerCase().contains('bow')) {
        final x = p.dx + w * .55, y = p.dy + 5;
        shape(
          c,
          Path()
            ..moveTo(x, y)
            ..lineTo(x - 52, y - 33)
            ..quadraticBezierTo(x - 68, y, x - 49, y + 29)
            ..close(),
          color(band),
        );
        shape(
          c,
          Path()
            ..moveTo(x, y)
            ..lineTo(x + 52, y - 33)
            ..quadraticBezierTo(x + 68, y, x + 49, y + 29)
            ..close(),
          color(band),
        );
        c.drawCircle(Offset(x, y), 13, Paint()..color = Colors.white70);
      } else {
        shape(c, star(Offset(p.dx, p.dy + 24), 22), const Color(0xFFFFD54F));
      }
    }
    final hat = equipment['headwear'] ?? equipment['special'];
    if (hat != null) {
      final p = fit.forehead;
      final w = fit.headWidth * .37;
      final name = hat.name.toLowerCase();
      if (name.contains('crown')) {
        shape(
          c,
          Path()
            ..moveTo(p.dx - w, p.dy)
            ..lineTo(p.dx - w - 9, p.dy - 95)
            ..lineTo(p.dx - w * .4, p.dy - 56)
            ..lineTo(p.dx, p.dy - 123)
            ..lineTo(p.dx + w * .4, p.dy - 56)
            ..lineTo(p.dx + w + 9, p.dy - 95)
            ..lineTo(p.dx + w, p.dy)
            ..close(),
          color(hat),
        );
        for (final x in [-.6, 0.0, .6]) {
          c.drawCircle(
            Offset(p.dx + x * w, p.dy - 26),
            9,
            Paint()..color = Colors.redAccent,
          );
        }
      } else {
        shape(
          c,
          Path()
            ..moveTo(p.dx - w, p.dy)
            ..quadraticBezierTo(p.dx - w * .7, p.dy - 40, p.dx - 10, p.dy - 150)
            ..quadraticBezierTo(p.dx + 20, p.dy - 132, p.dx + w, p.dy)
            ..close(),
          color(hat),
        );
        shape(
          c,
          Path()
            ..addOval(Rect.fromCenter(center: p, width: w * 2.5, height: 32)),
          color(hat),
        );
        shape(c, star(Offset(p.dx, p.dy - 60), 25), const Color(0xFFFFD54F));
      }
    }
    final glasses = equipment['glasses'];
    if (glasses != null) {
      final p = fit.eyes;
      final w = fit.headWidth * .20;
      final gap = fit.headWidth * .24;
      for (final sign in [-1, 1]) {
        final rect = Rect.fromCenter(
          center: Offset(p.dx + sign * gap, p.dy),
          width: w * 2,
          height: w * 1.9,
        );
        c.drawOval(
          rect,
          Paint()
            ..color = glasses.name.contains('Sunglasses')
                ? Colors.black87
                : Colors.lightBlueAccent.withValues(alpha: .12),
        );
        c.drawOval(
          rect,
          Paint()
            ..color = color(glasses)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 13,
        );
      }
      c.drawLine(
        Offset(p.dx - gap + w, p.dy - 10),
        Offset(p.dx + gap - w, p.dy - 10),
        Paint()
          ..color = color(glasses)
          ..strokeWidth = 12,
      );
    }
    final accessory = equipment['accessories'];
    if (accessory != null) {
      final p = fit.neck;
      final name = accessory.name.toLowerCase();
      if (name.contains('bow')) {
        shape(
          c,
          Path()
            ..moveTo(p.dx, p.dy)
            ..lineTo(p.dx - 63, p.dy - 27)
            ..quadraticBezierTo(p.dx - 78, p.dy, p.dx - 59, p.dy + 37)
            ..close(),
          color(accessory),
        );
        shape(
          c,
          Path()
            ..moveTo(p.dx, p.dy)
            ..lineTo(p.dx + 63, p.dy - 27)
            ..quadraticBezierTo(p.dx + 78, p.dy, p.dx + 59, p.dy + 37)
            ..close(),
          color(accessory),
        );
        shape(
          c,
          Path()..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: p, width: 31, height: 40),
              const Radius.circular(9),
            ),
          ),
          color(accessory),
        );
      } else {
        c.drawPath(
          Path()
            ..moveTo(p.dx - 63, p.dy - 12)
            ..quadraticBezierTo(p.dx - 65, p.dy + 95, p.dx, p.dy + 107)
            ..quadraticBezierTo(p.dx + 65, p.dy + 95, p.dx + 63, p.dy - 12),
          Paint()
            ..color = color(accessory)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10,
        );
        shape(c, star(Offset(p.dx, p.dy + 108), 28), color(accessory));
      }
    }
    if (equipment['effects'] case final effect?) {
      for (var i = 0; i < 7; i++) {
        shape(
          c,
          star(
            Offset(
              size.width * (i.isEven ? 0.27 : 0.72),
              size.height * (.20 + i * .10),
            ),
            12 + i.toDouble(),
          ),
          color(effect),
        );
      }
    }
  }

  @override
  bool shouldRepaint(OutfitAccessoriesPainter oldDelegate) =>
      oldDelegate.characterKey != characterKey ||
      oldDelegate.equipment != equipment;
}
