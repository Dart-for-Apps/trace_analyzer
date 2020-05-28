import 'dart:io';
import 'package:image/image.dart';

void drawCDF(Map<int, int> data, {int width = 1024, int height = 720}) async {
  final image = Image(width, height);

  final xdata = (data.keys.toList())..sort();
  final xrange = [xdata.first, xdata.last];

  // fill(image, getColor(255, 255, 255));

  drawLine(image, 0, 0, 320, 240, getColor(255, 0, 0), thickness: 3);

  await File('test.png').writeAsBytes(encodePng(image));
}
