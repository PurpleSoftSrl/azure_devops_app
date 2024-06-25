import 'package:intl/intl.dart';

extension PurpleDateTime on DateTime {
  String toSimpleDate() => '${DateFormat.yMd().format(this)} ${DateFormat.Hm().format(this)}';

  String toDate() => DateFormat.yMd().format(toLocal());

  String get minutesAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inDays > 364) {
      return '${diff.inDays ~/ 364}y';
    }

    if (diff.inDays > 0) {
      return '${diff.inDays}d';
    }

    if (diff.inHours > 0) {
      return '${diff.inHours}h';
    }

    return diff.inMinutes <= 0 ? 'now' : '${diff.inMinutes}m';
  }

  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  String timeDifference(DateTime other) {
    final diff = difference(other);

    if (diff.inHours > 0) {
      return '${diff.inHours}h ${diff.inMinutes % 60}m';
    }

    if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ${diff.inSeconds % 60}s';
    }

    if (diff.inSeconds > 0) {
      return '${diff.inSeconds}s';
    }

    return '-';
  }
}
