extension NumExt on num {
  String get formatted => (this == toInt() ? toInt() : this).toString();
}
