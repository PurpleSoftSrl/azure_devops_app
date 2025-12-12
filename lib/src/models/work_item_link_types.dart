import 'dart:convert';

import 'package:http/http.dart';

class WorkItemLinkTypesResponse {
  WorkItemLinkTypesResponse({required this.linkTypes});

  factory WorkItemLinkTypesResponse.fromJson(Map<String, dynamic> json) => WorkItemLinkTypesResponse(
    linkTypes: List<LinkType>.from(
      (json['value'] as List<dynamic>).map((x) => LinkType.fromJson(x as Map<String, dynamic>)),
    ),
  );

  static List<LinkType> fromResponse(Response res) =>
      WorkItemLinkTypesResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).linkTypes;

  final List<LinkType> linkTypes;
}

class LinkType {
  LinkType({required this.attributes, required this.referenceName, required this.name});

  factory LinkType.fromJson(Map<String, dynamic> json) => LinkType(
    attributes: _Attributes.fromJson(json['attributes'] as Map<String, dynamic>),
    referenceName: json['referenceName'] as String? ?? '',
    name: json['name'] as String? ?? '',
  );

  final _Attributes attributes;
  final String referenceName;
  final String name;

  static Pattern namesToExclude = RegExp(
    'Microsoft.VSTS.TestCase.|Microsoft.VSTS.Common.Affects-|System.LinkTypes.Remote.',
  );
}

class _Attributes {
  _Attributes({required this.usage, required this.enabled, required this.remote});

  factory _Attributes.fromJson(Map<String, dynamic> json) => _Attributes(
    usage: Usage.fromString(json['usage'] as String? ?? ''),
    enabled: json['enabled'] as bool? ?? false,
    remote: json['remote'] as bool? ?? false,
  );

  final Usage usage;
  final bool enabled;
  final bool remote;
}

enum Usage {
  workItemLink,
  resourceLink,
  unknown;

  static Usage fromString(String value) {
    return switch (value) {
      'resourceLink' => Usage.resourceLink,
      'workItemLink' => Usage.workItemLink,
      _ => Usage.unknown,
    };
  }
}

class WorkItemLink {
  WorkItemLink({
    required this.linkTypeReferenceName,
    required this.linkTypeName,
    required this.linkedWorkItemId,
    required this.comment,
    this.isDeleted = false,
    required this.index,
  });

  WorkItemLink.withIndexOnly({required this.index})
    : linkTypeName = '',
      comment = '',
      linkedWorkItemId = 0,
      linkTypeReferenceName = '',
      isDeleted = false;

  String linkTypeReferenceName;
  String linkTypeName;
  int linkedWorkItemId;
  String comment;
  bool isDeleted;
  int index;
}
