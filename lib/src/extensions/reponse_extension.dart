import 'dart:io';

import 'package:http/http.dart';

extension ResponseExt on Response {
  bool get isError => statusCode != HttpStatus.ok;
}
