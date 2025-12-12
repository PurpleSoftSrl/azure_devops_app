import 'dart:convert';

import 'package:http/http.dart';

class IdentityResponse {
  IdentityResponse({required this.results});

  factory IdentityResponse.fromJson(Map<String, dynamic> json) => IdentityResponse(
    results: List<_IdentityResult>.from(
      (json['results'] as List<dynamic>).map((r) => _IdentityResult.fromJson(r as Map<String, dynamic>)),
    ),
  );

  static List<_IdentityResult> fromResponse(Response res) =>
      IdentityResponse.fromJson(json.decode(res.body) as Map<String, dynamic>).results;

  final List<_IdentityResult> results;
}

class _IdentityResult {
  _IdentityResult({required this.queryToken, required this.identities});

  factory _IdentityResult.fromJson(Map<String, dynamic> json) => _IdentityResult(
    queryToken: json['queryToken'] as String,
    identities: List<Identity>.from(
      (json['identities'] as List<dynamic>).map((i) => Identity.fromJson(i as Map<String, dynamic>)),
    ),
  );

  final String queryToken;
  final List<Identity> identities;
}

class Identity {
  Identity({required this.displayName, required this.mail});

  factory Identity.fromJson(Map<String, dynamic> json) =>
      Identity(displayName: json['displayName'] as String, mail: json['mail'] as String);

  final String displayName;
  final String mail;
  String? guid;
}
