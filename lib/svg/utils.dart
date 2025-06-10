import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';
import 'models.dart';
import 'package:http/http.dart' as http;

Future<String> getSvgData(String url) async {
  final http.Response data = await http.get(Uri.parse(url));
  return data.body;
}

Future<VectorImage> getVectorImage(BuildContext context, String assetPath) async {
  final String svgData = await DefaultAssetBundle.of(context).loadString(assetPath);
  final VectorImage vectorImage = getVectorImageFromStringXml(svgData);
  return vectorImage;
}

VectorImage getVectorImageFromStringXml(String svgData) {
  List<PathSvgItem> items = [];

  // step 1: parse the xml
  XmlDocument document = XmlDocument.parse(svgData);

  // step 2: get the size of the svg
  Size? size;
  String? width = document.findAllElements('svg').first.getAttribute('width');
  String? height = document.findAllElements('svg').first.getAttribute('height');
  String? viewBox = document.findAllElements('svg').first.getAttribute('viewBox');
  if (width != null && height != null) {
    width = width.replaceAll(RegExp(r'[^0-9.]'), '');
    height = height.replaceAll(RegExp(r'[^0-9.]'), '');
    size = Size(double.parse(width), double.parse(height));
  } else if (viewBox != null) {
    List<String> viewBoxList = viewBox.split(' ');
    size = Size(double.parse(viewBoxList[2]), double.parse(viewBoxList[3]));
  }


  // step 3: get the paths
  final List<XmlElement> paths = document.findAllElements('path').toList();
  for (int i = 0; i < paths.length; i++) {
    final XmlElement element = paths[i];

    // get the path
    String? pathString = element.getAttribute('d');
    if (pathString == null) {
      continue;
    }
    Path path = parseSvgPathData(pathString);

    // get the fill color
    String? fill = element.getAttribute('fill');
    String? style = element.getAttribute('style');

    // get the transformations
    String? transformAttribute = element.getAttribute('transform');
    double scaleX = 1.0;
    double scaleY = 1.0;
    double? translateX;
    double? translateY;
    if (transformAttribute != null) {
      ({double x, double y})? scale = _getScale(transformAttribute);
      if (scale != null) {
        scaleX = scale.x;
        scaleY = scale.y;
      }
      ({double x, double y})? translate = _getTranslate(transformAttribute);
      if (translate != null) {
        translateX = translate.x;
        translateY = translate.y;
      }
    }

    final Matrix4 matrix4 = Matrix4.identity();
    if (translateX != null && translateY != null) {
      matrix4.translate(translateX, translateY);
    }
    matrix4.scale(scaleX, scaleY);

    path = path.transform(matrix4.storage);

    items.add(PathSvgItem(
      fill: _getColorFromString(fill) ?? Colors.white,
      path: path,
    ));
  }

  return VectorImage(items: items, size: size);
}

({double x, double y})? _getScale(String data) {
  RegExp regExp = RegExp(r'scale\(([^,]+),([^)]+)\)');
  var match = regExp.firstMatch(data);

  if (match != null) {
    double scaleX = double.parse(match.group(1)!);
    double scaleY = double.parse(match.group(2)!);

    return (x: scaleX, y: scaleY);
  } else {
    return null;
  }
}

({double x, double y})? _getTranslate(String data) {
  RegExp regExp = RegExp(r'translate\(([^,]+),([^)]+)\)');
  var match = regExp.firstMatch(data);

  if (match != null) {
    double translateX = double.parse(match.group(1)!);
    double translateY = double.parse(match.group(2)!);

    return (x: translateX, y: translateY);
  } else {
    return null;
  }
}

Color? _getColorFromString(String? colorString) {
  print(colorString);
  print(colorString == "none");
  if (colorString == "none") return null;
  else return Colors.grey;
}
