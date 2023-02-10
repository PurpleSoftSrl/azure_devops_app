extension DurationExt on Duration {
  String get toMinutes {
    final seconds = inSeconds % 60;
    return inMinutes <= 0 ? '$seconds s' : '$inMinutes m $seconds s';
  }
}
