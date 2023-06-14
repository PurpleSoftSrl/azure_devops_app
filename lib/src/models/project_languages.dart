// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:http/http.dart';

class GetProjectLanguagesResponse {
  GetProjectLanguagesResponse({
    required this.languageBreakdown,
    required this.repositoryLanguageAnalytics,
    required this.id,
  });

  factory GetProjectLanguagesResponse.fromJson(Map<String, dynamic> json) => GetProjectLanguagesResponse(
        languageBreakdown: List<LanguageBreakdown>.from(
          (json['languageBreakdown'] as List<dynamic>)
              .map((l) => LanguageBreakdown.fromJson(l as Map<String, dynamic>)),
        ),
        repositoryLanguageAnalytics: List<_RepositoryLanguageAnalytic>.from(
          (json['repositoryLanguageAnalytics'] as List<dynamic>)
              .map((a) => _RepositoryLanguageAnalytic.fromJson(a as Map<String, dynamic>)),
        ),
        id: json['id'] as String,
      );

  static List<LanguageBreakdown> fromResponse(Response res) =>
      GetProjectLanguagesResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).languageBreakdown;

  final List<LanguageBreakdown> languageBreakdown;
  final List<_RepositoryLanguageAnalytic> repositoryLanguageAnalytics;
  final String id;
}

class LanguageBreakdown {
  LanguageBreakdown({
    required this.name,
    this.files,
    this.filesPercentage,
    this.languagePercentage,
  });

  factory LanguageBreakdown.fromJson(Map<String, dynamic> json) => LanguageBreakdown(
        name: json['name'] as String,
        files: json['files'] as int?,
        filesPercentage: json['filesPercentage'] as double?,
        languagePercentage: json['languagePercentage'] as double?,
      );

  final String name;
  final int? files;
  final double? filesPercentage;
  final double? languagePercentage;
}

class _RepositoryLanguageAnalytic {
  _RepositoryLanguageAnalytic({
    required this.name,
    required this.updatedTime,
    required this.languageBreakdown,
    required this.id,
  });

  factory _RepositoryLanguageAnalytic.fromJson(Map<String, dynamic> json) => _RepositoryLanguageAnalytic(
        name: json['name'] as String,
        updatedTime: DateTime.parse(json['updatedTime']!.toString()).toLocal(),
        languageBreakdown: List<LanguageBreakdown>.from(
          (json['languageBreakdown'] as List<dynamic>)
              .map((l) => LanguageBreakdown.fromJson(l as Map<String, dynamic>)),
        ),
        id: json['id'] as String,
      );

  final String name;
  final DateTime updatedTime;
  final List<LanguageBreakdown> languageBreakdown;
  final String id;
}
