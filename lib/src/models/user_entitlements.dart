import 'dart:convert';

import 'package:http/http.dart';

class GetUserEntitlementsResponse {
  factory GetUserEntitlementsResponse.fromJson(Map<String, dynamic> json) => GetUserEntitlementsResponse(
        members: List<_Member>.from(
          (json['members'] as List<dynamic>).map((m) => _Member.fromJson(m as Map<String, dynamic>)),
        ),
      );

  GetUserEntitlementsResponse({required this.members});

  static List<_Member> fromResponse(Response res) =>
      GetUserEntitlementsResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).members;

  final List<_Member> members;
}

class _Member {
  factory _Member.fromJson(Map<String, dynamic> json) => _Member(
        user: _User.fromJson(json['user'] as Map<String, dynamic>),
        id: json['id'] as String,
        lastAccessedDate: DateTime.parse(json['lastAccessedDate']!.toString()).toLocal(),
        dateCreated: DateTime.parse(json['dateCreated']!.toString()).toLocal(),
      );

  _Member({
    required this.user,
    required this.id,
    required this.lastAccessedDate,
    required this.dateCreated,
  });

  final _User user;
  final String id;
  final DateTime lastAccessedDate;
  final DateTime dateCreated;
}

class _User {
  factory _User.fromJson(Map<String, dynamic> json) => _User(
        subjectKind: json['subjectKind'] as String,
        metaType: json['metaType'] as String?,
        directoryAlias: json['directoryAlias'] as String?,
        domain: json['domain'] as String,
        principalName: json['principalName'] as String,
        mailAddress: json['mailAddress'] as String,
        origin: json['origin'] as String,
        originId: json['originId'] as String?,
        displayName: json['displayName'] as String,
        url: json['url'] as String,
        descriptor: json['descriptor'] as String,
      );

  _User({
    required this.subjectKind,
    required this.metaType,
    required this.directoryAlias,
    required this.domain,
    required this.principalName,
    required this.mailAddress,
    required this.origin,
    required this.originId,
    required this.displayName,
    required this.url,
    required this.descriptor,
  });

  final String subjectKind;
  final String? metaType;
  final String? directoryAlias;
  final String domain;
  final String principalName;
  final String mailAddress;
  final String origin;
  final String? originId;
  final String displayName;
  final String url;
  final String descriptor;
}
