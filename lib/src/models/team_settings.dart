import 'dart:convert';

import 'package:http/http.dart';

class TeamSettingsResponse {
  TeamSettingsResponse({
    required this.backlogVisibilities,
  });

  factory TeamSettingsResponse.fromJson(Map<String, dynamic> json) => TeamSettingsResponse(
        backlogVisibilities: Map<String, bool>.from(json['backlogVisibilities'] as Map<String, dynamic>? ?? {}),
      );

  static TeamSettingsResponse fromResponse(Response res) =>
      TeamSettingsResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>);

  final Map<String, bool> backlogVisibilities;
}
