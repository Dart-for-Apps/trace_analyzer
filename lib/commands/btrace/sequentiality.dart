import 'dart:async';
import 'package:pedantic/pedantic.dart';
import 'dart:io';
import 'dart:convert';
import 'package:indexed_iterable/indexed_iterable.dart';
import 'package:args/command_runner.dart';
import 'package:console/console.dart' as console;
import 'package:trace_analyzer/image/draw_cdf.dart';

import '../../utils/progress_printer.dart';
import '../../utils/validator.dart';
import '../../utils/btrace_line.dart';
import '../../utils/human_readable_digit.dart';

class SequentialityCommand extends Command {
  SequentialityCommand() {
    argParser
      ..addSeparator('Options')
      ..addMultiOption(
        'files',
        abbr: 'f',
        splitCommas: true,
        help: 'btrace files to be analyzed',
      )
      ..addOption(
        'threads',
        abbr: 't',
        defaultsTo: '-1',
        help:
            'Number of outstanding threads refining btrace files simultaneously. -1 means unlimited.',
      )
      ..addOption(
        'suffix',
        abbr: 's',
        defaultsTo: 'seq',
        help: 'output file suffix',
      )
      ..addFlag(
        'output',
        abbr: 'o',
        defaultsTo: true,
        help: 'save output to file',
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
        defaultsTo: false,
        help: 'Analyze Read IO',
      )
      ..addFlag(
        'others',
        abbr: 'O',
        defaultsTo: false,
        help: 'Analyze the others except for RW',
      );
  }

  @override
  String get description => 'Analyze sequentiality';

  @override
  // TODO: implement name
  String get name => 'seq';

  @override
  Future run() async {
    ArgsValidator.mustBeGiven(argResults, ['files']);
    final fileList = argResults['files'] as List<String>;
    final needOutput = argResults['output'];
    final needRead = argResults['read'];
    final needWrite = argResults['write'];
    final needOthers = argResults['others'];

    for (final filePath in II(fileList)) {
      final file = File(filePath.value);
      final ioStream = utf8.decoder.bind(file.openRead()).transform(LineSplitter());
      final sqWrapper = SequentialityWrapper(0, 0);
      final sqMap = <int, int>{};
      final progressPrinter = ProgressPrinter();

      unawaited(getFileLines(filePath.value));
      print('Calculate sequentiality of file ${filePath.value}');
      final loadingBar = console.LoadingBar()..start();
      await for (final lines in IndexedStream(ioStream)) {
        final btLine = BtraceLine(lines.value);
        if (!needRead) {
          if (btLine.io == IOType.read) continue;
        }
        if (!needWrite) {
          if (btLine.io == IOType.write) continue;
        }
        if (!needOthers) {
          if (btLine.io != IOType.read && btLine.io != IOType.write) continue;
        }
        if (sqWrapper.startOffset + sqWrapper.length == btLine.offset) {
          // continual (sequential) io
          sqWrapper.length += btLine.length;
        } else {
          // print wrapped data or count it
          sqMap[sqWrapper.length] = (sqMap[sqWrapper.length] ?? 0) + 1;
          sqWrapper.startOffset = btLine.offset;
          sqWrapper.length = btLine.length;
        }
        progressPrinter(lines.index);
      }
      loadingBar.stop();
      print('Print sequentiality');
      if (needOutput) {
        final outputSuffix = argResults['suffix'];
        final outputFile = File('${filePath.value}.$outputSuffix').openWrite();
        for (final sqData in IndexedMap(sqMap)) {
          outputFile.writeln('${sqData.key}, ${sqData.value}');
        }
      }
      drawCDF(sqMap);
    }
    print('Done');
    exitCode = 0;
  }
}

Future getFileLines(String filePath) async {
  print('Counting # of lines of file $filePath ...');
  unawaited(Process.run('wc', ['-l', filePath]).then((value) {
    print("Total ${int.parse((value.stdout as String).split(' ')[0]).hrd} Lines");
  }));
}

class SequentialityWrapper {
  SequentialityWrapper(this.startOffset, this.length);
  int startOffset;
  int length;
}
