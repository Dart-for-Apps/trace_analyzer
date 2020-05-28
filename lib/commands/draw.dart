import 'package:args/command_runner.dart';

import 'draw/sequentiality.dart';

class DrawCommand extends Command {
  DrawCommand() {
    addSubcommand(DrawSequentiality());
  }

  @override
  String get description => 'Draw graphs';

  @override
  String get name => 'draw';
}
