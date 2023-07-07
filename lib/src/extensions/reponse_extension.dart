import 'dart:io';

import 'package:http/http.dart';

extension ResponseExt on Response {
  bool get isError => ![
        HttpStatus.ok,
        HttpStatus.created,
        HttpStatus.noContent,
        HttpStatus.partialContent,
      ].contains(statusCode);
}
