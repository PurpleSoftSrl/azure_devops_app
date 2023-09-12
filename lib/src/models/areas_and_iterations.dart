import 'dart:convert';

import 'package:http/http.dart';

class AreasAndIterationsResponse {
  AreasAndIterationsResponse({required this.areasAndIterations});

  factory AreasAndIterationsResponse.fromResponse(Response res) =>
      AreasAndIterationsResponse._fromJson(jsonDecode(res.body) as Map<String, dynamic>);

  factory AreasAndIterationsResponse._fromJson(Map<String, dynamic> json) => AreasAndIterationsResponse(
        areasAndIterations: List<AreaOrIteration>.from(
          (json['value'] as List<dynamic>).map((v) => AreaOrIteration.fromJson(v as Map<String, dynamic>)),
        ),
      );

  final List<AreaOrIteration> areasAndIterations;
}

class AreaOrIteration {
  AreaOrIteration({
    required this.id,
    required this.name,
    required this.structureType,
    required this.hasChildren,
    this.children,
    required this.path,
    this.attributes,
  });

  factory AreaOrIteration.fromJson(Map<String, dynamic> json) => AreaOrIteration(
        id: json['id'] as int,
        name: json['name'] as String,
        structureType: json['structureType'] as String,
        hasChildren: json['hasChildren'] as bool,
        children: json['children'] == null
            ? []
            : (json['children'] as List<dynamic>)
                .map((c) => AreaOrIteration.fromJson(c as Map<String, dynamic>))
                .toList(),
        path: json['path'] as String,
        attributes: json['attributes'] == null ? null : Attributes.fromJson(json['attributes'] as Map<String, dynamic>),
      );

  /// Used to reset area filter
  factory AreaOrIteration.all() => AreaOrIteration(
        id: -1,
        name: 'All',
        structureType: '',
        hasChildren: false,
        path: '',
      );

  final int id;
  final String name;
  final String structureType;
  final bool hasChildren;
  final List<AreaOrIteration>? children;
  final String path;
  final Attributes? attributes;

  @override
  String toString() {
    return 'AreaOrIteration(id: $id, name: $name, structureType: $structureType, hasChildren: $hasChildren, children: $children, path: $path, attributes: $attributes)';
  }
}

class Attributes {
  Attributes({
    required this.startDate,
    required this.finishDate,
  });

  factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
        startDate: DateTime.parse(json['startDate']!.toString()).toLocal(),
        finishDate: DateTime.parse(json['finishDate']!.toString()).toLocal(),
      );

  final DateTime startDate;
  final DateTime finishDate;
}
