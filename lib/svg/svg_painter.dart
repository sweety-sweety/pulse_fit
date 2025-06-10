import 'package:flutter/material.dart';
import 'models.dart';

class SvgPainter extends CustomPainter {
  const SvgPainter(this.pathSvgItem, this.onTap);
  final PathSvgItem pathSvgItem;
  final VoidCallback onTap;

  @override
  void paint(Canvas canvas, Size size) {
    Path path = pathSvgItem.path;

    final paint = Paint();

    if (pathSvgItem.fill != Colors.white) {
      print(pathSvgItem.fill);
      paint.color = pathSvgItem.fill ?? Colors.grey;
      paint.style = PaintingStyle.fill;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool? hitTest(Offset position) {
    Path path = pathSvgItem.path;
    if (path.contains(position)) {
      onTap();
      return true;
    }
    return super.hitTest(position);
  }

  @override
  bool shouldRepaint(SvgPainter oldDelegate) {
    return pathSvgItem != oldDelegate.pathSvgItem;
  }
}

class SvgPainterImage extends StatelessWidget {
  const SvgPainterImage({
    super.key,
    required this.item,
    required this.size,
    required this.onTap,
  });

  final PathSvgItem item;
  final Size size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      foregroundPainter: SvgPainter(item, onTap),
    );
  }
}
