import 'package:args/args.dart';

class ArgsValidator {
  static void mustBeGiven(ArgResults argResults, List<String> args) {
    for (final arg in args) {
      final given = argResults[arg];
      if (given == null || (given as List).isEmpty) {
        throw ArgumentError('--$arg option must be given');
      }
    }
  }
}
