import 'package:flutter/material.dart';

IconData resolveFoodIconData({String? foodName, String? categoryName}) {
  final category = (categoryName ?? '').toLowerCase().trim();

  switch (category) {
    case 'boiled':
      return Icons.soup_kitchen;
    case 'curry':
      return Icons.ramen_dining;
    case 'fried':
      return Icons.fastfood;
    case 'stir-fried':
      return Icons.local_dining;
    case 'grilled':
      return Icons.outdoor_grill;
    case 'dessert':
      return Icons.cake;
    case 'beverage':
      return Icons.local_cafe;
    default:
      return Icons.fastfood;
  }
}

Widget buildFoodCategoryIcon({
  String? categoryName,
  double size = 24,
  Color color = Colors.black87,
}) {
  final category = (categoryName ?? '').toLowerCase().trim();

  if (category == 'stir-fried') {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PanIconPainter(color: color),
      ),
    );
  }

  return Icon(
    resolveFoodIconData(categoryName: categoryName),
    size: size,
    color: color,
  );
}

class _PanIconPainter extends CustomPainter {
  const _PanIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.09;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bodyRect = Rect.fromLTWH(
      size.width * 0.33,
      size.height * 0.52,
      size.width * 0.48,
      size.height * 0.20,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, Radius.circular(size.width * 0.08)),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.54),
      Offset(size.width * 0.34, size.height * 0.60),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.07, size.height * 0.43),
      Offset(size.width * 0.18, size.height * 0.54),
      paint,
    );

    final handleRect = Rect.fromLTWH(
      size.width * 0.01,
      size.height * 0.35,
      size.width * 0.20,
      size.height * 0.10,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        handleRect,
        Radius.circular(size.width * 0.04),
      ),
      paint,
    );

    _drawSteam(canvas, size, paint, size.width * 0.52);
    _drawSteam(canvas, size, paint, size.width * 0.63);
    _drawSteam(canvas, size, paint, size.width * 0.74);
  }

  void _drawSteam(Canvas canvas, Size size, Paint paint, double x) {
    final path = Path()
      ..moveTo(x, size.height * 0.22)
      ..quadraticBezierTo(
        x - size.width * 0.035,
        size.height * 0.14,
        x,
        size.height * 0.07,
      )
      ..quadraticBezierTo(
        x + size.width * 0.035,
        size.height * 0.00,
        x,
        size.height * -0.07,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PanIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
