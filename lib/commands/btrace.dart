import 'package:args/command_runner.dart';

class BtraceCommand extends Command {
  @override
  String get description => 'btrace result analyzer';

  @override
  String get name => 'btrace';
}
