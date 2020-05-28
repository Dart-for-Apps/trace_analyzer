import 'dart:io';
import 'package:image/image.dart';
import 'package:indexed_iterable/indexed_iterable.dart';

const kColorBlack = 0xff000000;
const kColorWhite = 0xffffffff;

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
    _xMax = _xdata.last;
    _xdelta = _calculateXDelta(_xdata.first, _xMax);
    _yMax = target.values.reduce((value, element) => value + element);
    _ydelta = _calculateYDelta(0, _yMax);
    fill(image, 0xffffffff);

    drawXbarBottom();
    drawYbarLeft();
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
  int _xMax;
  int _yMax;

  void drawTitle(String title) {}

  void drawLegend() {}

  void drawXbarBottom() {
    drawLine(image, _xStart, _yStart, _xEnd, _yStart, 0xff000000);
  }

  void drawXbarTop() {
    drawLine(image, _xStart, _yEnd, _xEnd, _yEnd, 0xff000000);
  }

  void drawYbarLeft() {
    drawLine(image, _xStart, _yStart, _xStart, _yEnd, 0xff000000);
  }

  void drawYbarRight() {
    drawLine(image, _xEnd, _yStart, _xEnd, _yEnd, 0xff000000);
  }

  void writeGraphOrigin() {
    drawString(image, arial_24, _xStart - 12, _yStart + 10, '0', color: 0xff000000);
  }

  /// draw xtics by percent or value
  void drawXticsBottom({
    List<int> tics = const [0, 20, 40, 60, 80, 100],
    TicBy ticBy = TicBy.percent,
    bool needTicLabel = true,
  }) {
    for (final tic in IndexedIterable(tics)) {
      final ticValue = (ticBy == TicBy.value) ? tic.value : tic.value * _xMax ~/ 100;
      final xOffset = _getXoffset(ticValue);

      drawLine(image, xOffset, _yStart, xOffset, _yStart - 10, kColorBlack);

      if (needTicLabel) {
        _drawStringCenteredOn(
          image,
          '$ticValue',
          xOffset,
          _yStart + 10,
        );
      }
    }
  }

  void drawXticsTop() {}

  void drawYticsLeft({
    List<int> tics = const [0, 20, 40, 60, 80, 100],
    TicBy ticBy = TicBy.percent,
    bool needTicLabel = true,
  }) {
    for (final tic in IndexedIterable(tics)) {
      final ticValue = (ticBy == TicBy.value) ? tic.value : tic.value * _yMax ~/ 100;
      final yOffset = _getYoffset(ticValue);

      drawLine(image, _xStart, yOffset, _xStart + 10, yOffset, kColorBlack);
      if (needTicLabel) {
        final stringImage = Image(500, 500);
        drawStringCentered(
          stringImage,
          arial_14,
          '${ticBy == TicBy.value ? ticValue : tic.value}',
          color: kColorBlack,
        );
        final rotatedImage = copyRotate(stringImage, 270);
        drawImage(
          image,
          rotatedImage,
          dstX: _xStart - 10 - stringImage.width ~/ 2,
          dstY: yOffset - stringImage.height ~/ 2,
        );
      }
    }
  }

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

      drawLine(
        image,
        prevXOffset,
        prevYOffset,
        xOffset,
        yOffset,
        color ?? this.color,
        thickness: 3,
      );

      prevXOffset = xOffset;
      prevYOffset = yOffset;
    }
  }

  void saveToFile(String filePath) async {
    await File(filePath).writeAsBytes(_encodeImage(format, image));
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

List<int> _encodeImage(String format, Image image) {
  switch (format) {
    case 'png':
      return encodePng(image);
    case 'jpg':
    case 'jpeg':
      return encodeJpg(image);
    default:
      return encodePng(image);
  }
}

enum TicBy { percent, value }

void _drawStringCenteredOn(Image image, String string, int x, int y) {
  final stringImage = Image(500, 500);
  drawStringCentered(stringImage, arial_14, string, color: kColorBlack);
  final rotatedImage = copyRotate(stringImage, 270);
  copyInto(
    image,
    stringImage,
    dstX: x - stringImage.width ~/ 2,
    dstY: y - stringImage.height ~/ 2,
  );
}
