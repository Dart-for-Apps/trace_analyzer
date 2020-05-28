import 'package:console/console.dart' as console;
import 'human_readable_digit.dart';

class ProgressPrinter {
  ProgressPrinter([this.delayInMilliseconds = 100]);
  final stw = Stopwatch()..start();
  var delayInMilliseconds;
  var prevElapsedMilliseconds = 0;

  void call(int current) {
    if (prevElapsedMilliseconds == 0 ||
        stw.elapsedMilliseconds - prevElapsedMilliseconds > delayInMilliseconds) {
      console.Console.write(
          '\r[${(stw.elapsedMilliseconds / 1000).toStringAsFixed(3)}s] ${current.hrd} lines  ');
      prevElapsedMilliseconds = stw.elapsedMilliseconds;
    }
  }
}
