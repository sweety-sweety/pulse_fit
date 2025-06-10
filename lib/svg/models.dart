import 'dart:ui';

class VectorImage {
  const VectorImage({
    required this.items,
    this.size,
  });

  final List<PathSvgItem> items;
  final Size? size;
}

class PathSvgItem {
  const PathSvgItem({
    required this.path,
    this.fill,
    this.originalFill,
  });

  final Path path;
  final Color? fill;
  final Color? originalFill;

  PathSvgItem copyWith({Path? path, Color? fill, Color? originalFill}) {
    return PathSvgItem(
      path: path ?? this.path,
      fill: fill ?? this.fill,
      originalFill: originalFill ?? this.originalFill ?? this.fill,
    );
  }
}
