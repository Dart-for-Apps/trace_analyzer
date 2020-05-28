import 'dart:io';
import 'package:image/image.dart';
import 'package:indexed_iterable/indexed_iterable.dart';

class CDFDrawer {
  CDFDrawer(
    this.target, {
    this.color = 0xffff00ff,
    this.height = 720,
    this.width = 1280,
    this.format = 'png',
    this.leftPadding = 120,
    this.rightPadding = 60,
    this.topPadding = 40,
    this.bottomPadding = 80,
  }) : image = Image(width, height) {
    _xdata = (target.keys.toList())..sort();
    _xdelta = _calculateXDelta(_xdata.first, _xdata.last);
    final ylast = target.values.reduce((value, element) => value + element);
    _ydelta = _calculateYDelta(0, ylast);
    fill(image, 0xffffffff);
  }
  final int width;
  final int height;
  final Image image;
  final int color;
  final String format;
  final int leftPadding;
  final int rightPadding;
  final int bottomPadding;
  final int topPadding;

  Map<int, int> target;
  double _xdelta;
  double _ydelta;
  List<int> _xdata;

  void drawTitle(String title) {}

  void drawLegend() {}

  void drawXbarBottom() {}

  void drawXbarTop() {}

  void drawYbarLeft() {}

  void drawYbarRight() {}

  void drawXticsBottom() {}

  void drawXticsTop() {}

  void drawYticsLeft() {}

  void drawYticsRight() {}

  void drawCDF({int color}) async {
    var cdf = 0;
    var prevXOffset = _xStart;
    var prevYOffset = _yStart;

    for (final data in IndexedIterable(_xdata)) {
      final key = data.value;
      final value = target[key];

      final xOffset = _getXoffset(key);
      cdf += value;

      final yOffset = _getYoffset(cdf);

      drawLine(image, prevXOffset, prevYOffset, xOffset, yOffset, color ?? this.color);

      prevXOffset = xOffset;
      prevYOffset = yOffset;
    }

    await File('test.png').writeAsBytes(encodePng(image));
  }

  int get _graphWidth => width - leftPadding - rightPadding;
  int get _graphHeight => height - topPadding - bottomPadding;

  int get _xStart => leftPadding;
  int get _xEnd => width - rightPadding;
  int get _yStart => height - bottomPadding;
  int get _yEnd => topPadding;

  int _getXoffset(int x) => (_xStart + (x * _xdelta)).toInt();
  int _getYoffset(int y) => (_yStart - (y * _ydelta)).toInt();

  double _calculateYDelta(int start, int end) {
    if (start > end) {
      final temp = start;
      start = end;
      end = temp;
    }
    return _graphHeight / (end - start + 1);
  }

  double _calculateXDelta(int start, int end) {
    if (start > end) {
      final temp = start;
      start = end;
      end = temp;
    }
    return _graphWidth / (end - start + 1);
  }
}
