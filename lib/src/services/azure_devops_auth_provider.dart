import 'dart:convert';

import 'package:azure_devops/src/models/azure_devops_connection.dart';

abstract class AzureDevOpsAuthProvider {
  Future<Map<String, String>> getHeaders();
}

class MicrosoftAuthProvider implements AzureDevOpsAuthProvider {
  MicrosoftAuthProvider(this.accessToken);

  final String accessToken;

  @override
  Future<Map<String, String>> getHeaders() async {
    return {'Authorization': 'Bearer $accessToken'};
  }
}

class PatAuthProvider implements AzureDevOpsAuthProvider {
  PatAuthProvider(this.pat);

  final String pat;

  @override
  Future<Map<String, String>> getHeaders() async {
    final encoded = base64Encode(utf8.encode(':$pat'));
    return {'Authorization': 'Basic $encoded'};
  }
}

class AzureDevOpsAuthHeaderProvider {
  AzureDevOpsAuthHeaderProvider({
    required this.connection,
    required this.accessToken,
  });

  final AzureDevOpsConnectionProfile connection;
  final String accessToken;

  Future<Map<String, String>> getHeaders() {
    final auth = connection.authType == AzureDevOpsAuthType.microsoft
        ? MicrosoftAuthProvider(accessToken)
        : PatAuthProvider(accessToken);
    return auth.getHeaders();
  }

  Map<String, String> getHeadersSync() {
    if (connection.authType == AzureDevOpsAuthType.microsoft) {
      return {'Authorization': 'Bearer $accessToken'};
    }
    return {'Authorization': 'Basic ${base64Encode(utf8.encode(':$accessToken'))}'};
  }
}

String redactCredentialText(String value) {
  return value
      .replaceAll(RegExp(r'Bearer\s+[A-Za-z0-9._~+/=-]+'), 'Bearer [REDACTED]')
      .replaceAll(RegExp(r'Basic\s+[A-Za-z0-9+/=]+'), 'Basic [REDACTED]')
      .replaceAll(RegExp(r'Authorization:\s*[^,\n\r]+', caseSensitive: false), 'Authorization: [REDACTED]');
}
