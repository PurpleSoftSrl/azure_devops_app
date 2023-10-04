import 'package:azure_devops/src/extensions/datetime_extension.dart';
import 'package:azure_devops/src/extensions/num_extension.dart';

extension StringExt on String {
  String get formatted {
    final date = DateTime.tryParse(this);
    final number = num.tryParse(this);

    if (date != null) return date.toDate();

    // check that number doesn't end with '.' to allow inputting a double
    if (number != null && !endsWith('.')) return number.formatted;

    return this;
  }
}
