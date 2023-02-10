class GetTeamsResponse {
  GetTeamsResponse({
    required this.teams,
    required this.count,
  });

  factory GetTeamsResponse.fromJson(Map<String, dynamic> json) => GetTeamsResponse(
        teams: json['value'] == null
            ? []
            : List<_Team?>.from((json['value'] as List<dynamic>).map((x) => _Team.fromJson(x as Map<String, dynamic>))),
        count: json['count'] as int?,
      );

  final List<_Team?>? teams;
  final int? count;

  Map<String, dynamic> toJson() => {
        'value': teams == null ? <dynamic>[] : List<dynamic>.from(teams!.map((x) => x!.toJson())),
        'count': count,
      };
}

class _Team {
  _Team({
    required this.id,
    required this.name,
    required this.url,
    required this.description,
    required this.identityUrl,
    required this.projectName,
    required this.projectId,
  });

  factory _Team.fromJson(Map<String, dynamic> json) => _Team(
        id: json['id'] as String?,
        name: json['name'] as String?,
        url: json['url'] as String?,
        description: json['description'] as String?,
        identityUrl: json['identityUrl'] as String?,
        projectName: json['projectName'] as String?,
        projectId: json['projectId'] as String?,
      );

  final String? id;
  final String? name;
  final String? url;
  final String? description;
  final String? identityUrl;
  final String? projectName;
  final String? projectId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'description': description,
        'identityUrl': identityUrl,
        'projectName': projectName,
        'projectId': projectId,
      };
}
