import 'dart:convert';

import 'package:azure_devops/src/models/team_member.dart';
import 'package:http/http.dart';

typedef TeamWithMembers = ({Team team, List<TeamMember> members});

class GetTeamsResponse {
  GetTeamsResponse({required this.teams});

  factory GetTeamsResponse.fromJson(Map<String, dynamic> json) => GetTeamsResponse(
        teams: List<Team>.from(
          (json['value'] as List<dynamic>? ?? []).map((x) => Team.fromJson(x as Map<String, dynamic>)),
        ),
      );

  static List<Team> fromResponse(Response res) =>
      GetTeamsResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).teams;

  final List<Team> teams;
}

class Team {
  Team({
    required this.id,
    required this.name,
    required this.description,
    required this.projectName,
    required this.projectId,
  });

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        projectName: json['projectName'] as String? ?? '',
        projectId: json['projectId'] as String? ?? '',
      );

  final String id;
  final String name;
  final String description;
  final String projectName;
  final String projectId;

  @override
  bool operator ==(covariant Team other) {
    if (identical(this, other)) return true;

    return other.id == id && other.projectId == projectId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ projectId.hashCode;
  }
}
