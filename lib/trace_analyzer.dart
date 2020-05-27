import 'dart:io';
import 'package:args/command_runner.dart';

import 'commands/btrace.dart';
import 'commands/btrace/continuity.dart';

Future<int> traceAnalyzer(List<String> args) async {
  final runner = CommandRunner('trace_analyzer', 'A CLI analyzes traces.');
  runner
    ..addCommand(
      BtraceCommand()..addSubcommand(ContinuityCommand()),
    );

  return await runner.run(args).catchError((e) {
    stderr.writeln('${e ?? "An error occured"}');
    exitCode = 1;
    return 1;
  });
}
