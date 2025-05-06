import 'package:intl/intl.dart';

extension NumExt on num {
  String get formatted => (this == toInt() ? toInt() : this).toString();

  String toCurrency(String currency) => NumberFormat.simpleCurrency(name: currency).format(this);

  String toPercentage() => '$this%';
}
