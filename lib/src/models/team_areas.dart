import 'dart:convert';

import 'package:http/http.dart';

class TeamAreasResponse {
  TeamAreasResponse({
    required this.defaultValue,
    required this.values,
  });

  factory TeamAreasResponse.fromJson(Map<String, dynamic> json) => TeamAreasResponse(
        defaultValue: json['defaultValue'] as String? ?? '',
        values: List<TeamArea>.from(
          (json['values'] as List<dynamic>? ?? []).map((x) => TeamArea.fromJson(x as Map<String, dynamic>? ?? {})),
        ),
      );

  static TeamAreasResponse fromResponse(Response res) =>
      TeamAreasResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>);

  final String defaultValue;
  final List<TeamArea> values;
}

class TeamArea {
  TeamArea({
    required this.value,
    required this.includeChildren,
  });

  factory TeamArea.fromJson(Map<String, dynamic> json) => TeamArea(
        value: json['value'] as String? ?? '',
        includeChildren: json['includeChildren'] as bool? ?? false,
      );

  final String value;
  final bool includeChildren;
}
