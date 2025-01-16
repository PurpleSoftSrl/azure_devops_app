import 'dart:convert';

import 'package:http/http.dart';

mixin ApiErrorHelper {
  final projectNotFoundException = 'ProjectDoesNotExistWithNameException';

  ({String msg, String type}) getErrorMessageAndType(Response res) {
    var errorMsg = '';
    var type = '';
    try {
      final responseBody = res.body;
      final apiErrorMessage = jsonDecode(responseBody) as Map<String, dynamic>;
      final msg = apiErrorMessage['message'] as String? ?? '';
      type = apiErrorMessage['typeKey'] as String? ?? '';

      errorMsg += msg.replaceAll(RegExp("['«».:]"), '').trim();
    } catch (e) {
      // ignore
    }
    return (msg: errorMsg, type: type);
  }

  String? parseProjectNotFoundName(String errorMessage) {
    return errorMessage.split('The following project does not exist').lastOrNull?.trim().split(' ').firstOrNull;
  }
}
