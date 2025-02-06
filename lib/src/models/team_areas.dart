import 'dart:convert';

import 'package:http/http.dart';

class TeamAreasResponse {
  TeamAreasResponse({
    required this.defaultValue,
    required this.values,
  });

  factory TeamAreasResponse.fromJson(Map<String, dynamic> json) => TeamAreasResponse(
        defaultValue: json['defaultValue'] as String? ?? '',
        values: List<_TeamArea>.from(
          (json['values'] as List<dynamic>? ?? []).map((x) => _TeamArea.fromJson(x as Map<String, dynamic>? ?? {})),
        ),
      );

  static TeamAreasResponse fromResponse(Response res) =>
      TeamAreasResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>);

  final String defaultValue;
  final List<_TeamArea> values;
}

class _TeamArea {
  _TeamArea({
    required this.value,
    required this.includeChildren,
  });

  factory _TeamArea.fromJson(Map<String, dynamic> json) => _TeamArea(
        value: json['value'] as String? ?? '',
        includeChildren: json['includeChildren'] as bool? ?? false,
      );

  final String value;
  final bool includeChildren;
}
