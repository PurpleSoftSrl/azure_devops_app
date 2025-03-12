import 'dart:convert';

import 'package:http/http.dart';

mixin ApiErrorHelper {
  final projectNotFoundException = 'ProjectDoesNotExistWithNameException';

  String getErrorMessage(Response res) {
    var errorMsg = '';

    try {
      final responseBody = res.body;
      final apiErrorMessage = jsonDecode(responseBody) as Map<String, dynamic>;
      final msg = apiErrorMessage['message'] as String? ?? '';

      errorMsg += msg.replaceAll(RegExp("['«»:]"), '').trim();
    } catch (_) {
      // ignore
    }

    return errorMsg;
  }

  ({String msg, String type}) getErrorMessageAndType(Response res) {
    var errorMsg = '';
    var type = '';

    try {
      final responseBody = res.body;
      final apiErrorMessage = jsonDecode(responseBody) as Map<String, dynamic>;
      final msg = apiErrorMessage['message'] as String? ?? '';
      type = apiErrorMessage['typeKey'] as String? ?? '';

      errorMsg += msg.replaceAll(RegExp("['«».:]"), '').trim();
    } catch (_) {
      // ignore
    }

    return (msg: errorMsg, type: type);
  }

  String? parseProjectNotFoundName(String errorMessage) {
    return errorMessage.split('The following project does not exist').lastOrNull?.trim().split(' ').firstOrNull;
  }

  // work item specific error handling

  final _workItemProjectNotFoundError = 'The project specified is not found in hierarchy';
  final _workItemAreaNotFoundError = 'The specified area path does not exist';
  final _workItemIterationNotFoundError = 'The specified iteration path does not exist';

  bool isWorkItemProjectNotFoundError(String errorMessage) {
    return errorMessage.toLowerCase().contains(_workItemProjectNotFoundError.toLowerCase());
  }

  bool isWorkItemAreaNotFoundError(String errorMessage) {
    return errorMessage.toLowerCase().contains(_workItemAreaNotFoundError.toLowerCase());
  }

  bool isWorkItemIterationNotFoundError(String errorMessage) {
    return errorMessage.toLowerCase().contains(_workItemIterationNotFoundError.toLowerCase());
  }

  String? getWorkItemErrorObjectName(Response res) {
    String? errorMsg;
    try {
      final responseBody = res.body;
      final apiErrorMessage = jsonDecode(responseBody) as Map<String, dynamic>;
      final msg = apiErrorMessage['message'] as String? ?? '';

      errorMsg = msg.splitMapJoin(
        RegExp("«'(.*)'»"),
        onMatch: (m) => m.group(1) ?? '',
        onNonMatch: (_) => '',
      );
    } catch (_) {
      // ignore
    }

    return errorMsg;
  }
}
