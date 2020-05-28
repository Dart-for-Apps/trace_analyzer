import 'dart:io';
import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:indexed_iterable/indexed_iterable.dart';

import '../../utils/validator.dart';

class DrawSequentiality extends Command {
  DrawSequentiality() {
    argParser
      ..addSeparator('Options')
      ..addOption(
        'files',
        abbr: 'f',
        help: 'Sequentiality files, created by this tools `btrace seq` command',
      )
      ..addOption(
        'width',
        abbr: 'w',
        defaultsTo: '1280',
        help: 'Output width in pixel',
      )
      ..addOption(
        'height',
        abbr: 'h',
        defaultsTo: '720',
        help: 'Ouput height in pixel',
      )
      ..addOption(
        'format',
        abbr: 'F',
        defaultsTo: 'png',
        help: 'Output format',
      );
  }

  @override
  Future run() async {
    ArgsValidator.mustBeGiven(argResults, ['files']);
    final files = argResults['files'];
    final width = int.parse(argResults['width']);
    final height = int.parse(argResults['height']);
    final format = argResults['format'];
    for (final fileName in IndexedIterable(files)) {
      final file = File(fileName.value);
      final ioStream = utf8.decoder.bind(file.openRead()).transform(LineSplitter());
    }
  }

  @override
  String get description => 'Draw sequentiality using files';

  @override
  String get name => 'seq';
}
