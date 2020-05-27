import 'dart:io';
import 'dart:convert';
import 'package:indexed_iterable/indexed_iterable.dart';
import 'package:args/command_runner.dart';

import '../../utils/validator.dart';
import '../../utils/btrace_line.dart';

class ContinuityCommand extends Command {
  ContinuityCommand() {
    argParser
      ..addSeparator('Options')
      ..addMultiOption(
        'file',
        abbr: 'f',
        splitCommas: true,
        help: 'btrace files to be analyzed',
      )
      ..addFlag(
        'write',
        abbr: 'w',
        defaultsTo: true,
        help: 'Analyze Write IO',
      )
      ..addFlag(
        'read',
        abbr: 'r',
        defaultsTo: true,
        help: 'Analyze Read IO',
      )
      ..addFlag(
        'others',
        abbr: 'o',
        defaultsTo: false,
        help: 'Analyze the others except for RW',
      );
  }

  @override
  String get description => 'Analyze continuity';

  @override
  // TODO: implement name
  String get name => 'cont';

  @override
  Future run() async {
    final fileList = argResults['file'] as List<String>;
    ArgsValidator.mustBeGiven(argResults, ['file']);
    for (final filePath in II(fileList)) {
      final file = File(filePath.value);
      if (!(await file.exists())) {
        continue;
      }
      final lines = await file.length();
      final ioStream = utf8.decoder.bind(file.openRead()).transform(LineSplitter());
      await for (String line in ioStream) {
        final btLine = BtraceLine(line);
        print(btLine);
      }
    }
    return 1;
  }
}
