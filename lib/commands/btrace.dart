import 'package:args/command_runner.dart';
import 'package:trace_analyzer/commands/btrace/sequentiality.dart';

class BtraceCommand extends Command {
  BtraceCommand() {
    addSubcommand(SequentialityCommand());
  }
  @override
  String get description => 'btrace result analyzer';

  @override
  String get name => 'btrace';
}
