class GetProjectLanguagesResponse {
  factory GetProjectLanguagesResponse.fromJson(Map<String, dynamic> json) => GetProjectLanguagesResponse(
        url: json['url'] as String,
        resultPhase: json['resultPhase'] as String,
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

  GetProjectLanguagesResponse({
    required this.url,
    required this.resultPhase,
    required this.languageBreakdown,
    required this.repositoryLanguageAnalytics,
    required this.id,
  });

  final String url;
  final String resultPhase;
  final List<LanguageBreakdown> languageBreakdown;
  final List<_RepositoryLanguageAnalytic> repositoryLanguageAnalytics;
  final String id;

  Map<String, dynamic> toJson() => {
        'url': url,
        'resultPhase': resultPhase,
        'languageBreakdown': List<dynamic>.from(languageBreakdown.map((x) => x.toJson())),
        'repositoryLanguageAnalytics': List<dynamic>.from(repositoryLanguageAnalytics.map((x) => x.toJson())),
        'id': id,
      };
}

class LanguageBreakdown {
  factory LanguageBreakdown.fromJson(Map<String, dynamic> json) => LanguageBreakdown(
        name: json['name'] as String,
        files: json['files'] as int,
        filesPercentage: json['filesPercentage'] as double,
        bytes: json['bytes'] as int,
        languagePercentage: json['languagePercentage'] as double?,
      );

  LanguageBreakdown({
    required this.name,
    required this.files,
    required this.filesPercentage,
    required this.bytes,
    this.languagePercentage,
  });

  final String name;
  final int files;
  final double filesPercentage;
  final int bytes;
  final double? languagePercentage;

  Map<String, dynamic> toJson() => {
        'name': name,
        'files': files,
        'filesPercentage': filesPercentage,
        'bytes': bytes,
        'languagePercentage': languagePercentage,
      };
}

class _RepositoryLanguageAnalytic {
  factory _RepositoryLanguageAnalytic.fromJson(Map<String, dynamic> json) => _RepositoryLanguageAnalytic(
        name: json['name'] as String,
        resultPhase: json['resultPhase'] as String,
        updatedTime: DateTime.parse(json['updatedTime']!.toString()).toLocal(),
        languageBreakdown: List<LanguageBreakdown>.from(
          (json['languageBreakdown'] as List<dynamic>)
              .map((l) => LanguageBreakdown.fromJson(l as Map<String, dynamic>)),
        ),
        id: json['id'] as String,
      );

  _RepositoryLanguageAnalytic({
    required this.name,
    required this.resultPhase,
    required this.updatedTime,
    required this.languageBreakdown,
    required this.id,
  });

  final String name;
  final String resultPhase;
  final DateTime updatedTime;
  final List<LanguageBreakdown> languageBreakdown;
  final String id;

  Map<String, dynamic> toJson() => {
        'name': name,
        'resultPhase': resultPhase,
        'updatedTime': updatedTime.toIso8601String(),
        'languageBreakdown': List<dynamic>.from(languageBreakdown.map((x) => x.toJson())),
        'id': id,
      };
}
