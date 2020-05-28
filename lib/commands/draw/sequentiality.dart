import 'dart:io';
import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:indexed_iterable/indexed_iterable.dart';

import '../../image/cdf_drawer.dart';
import '../../utils/validator.dart';

class DrawSequentiality extends Command {
  DrawSequentiality() {
    argParser
      ..addSeparator('Options')
      ..addMultiOption(
        'files',
        abbr: 'f',
        splitCommas: true,
        help: 'Sequentiality files, created by this tools `btrace seq` command',
      )
      ..addOption(
        'width',
        abbr: 'w',
        defaultsTo: 1280,
        help: 'Output width in pixel',
      )
      ..addOption(
        'height',
        abbr: 'H',
        defaultsTo: 720,
        help: 'Ouput height in pixel',
      )
      ..addOption(
        'format',
        abbr: 'F',
        defaultsTo: 'png',
        help: 'Output format',
      )
      ..addOption(
        'left-padding',
        defaultsTo: 120,
      )
      ..addOption(
        'right-padding',
        defaultsTo: 60,
      )
      ..addOption(
        'top-padding',
        defaultsTo: 40,
      )
      ..addOption(
        'bottom-padding',
        defaultsTo: 80,
      );
  }

  @override
  Future run() async {
    ArgsValidator.mustBeGiven(argResults, ['files']);
    final files = argResults['files'];
    final width = argResults['width'];
    final height = argResults['height'];
    final format = argResults['format'];
    for (final fileName in IndexedIterable(files)) {
      final file = File(fileName.value);
      final ioStream = utf8.decoder.bind(file.openRead()).transform(LineSplitter());
      final seqMap = <int, int>{};

      await for (final seq in ioStream.IS) {
        final key = int.parse(seq.value.split(' ')[0]);
        final value = int.parse(seq.value.split(' ')[1]);
        seqMap[key] = value;
      }
      final cdfDrawer = CDFDrawer(seqMap, width: width, height: height)..drawCDF();
    }
  }

  @override
  String get description => 'Draw sequentiality using files';

  @override
  String get name => 'seq';
}
