import 'package:indexed_iterable/indexed_iterable.dart';

/// swap key and value
Map inverMapKV(Map map) {
  final returnMap = {};

  for (final entry in IndexedMap(map)) {
    returnMap[entry.value] = entry.key;
  }

  return returnMap;
}
