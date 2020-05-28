extension HumanReadableDigit on int {
  String get hrd =>
      toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
}
