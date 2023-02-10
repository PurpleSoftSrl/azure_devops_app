import 'package:azure_devops/src/models/shared.dart';

class GetTeamMembersResponse {
  GetTeamMembersResponse({
    required this.members,
    required this.count,
  });

  factory GetTeamMembersResponse.fromJson(Map<String, dynamic> json) => GetTeamMembersResponse(
        members: json['value'] == null
            ? []
            : List<TeamMember>.from(
                (json['value'] as List<dynamic>).map((x) => TeamMember.fromJson(x as Map<String, dynamic>)),
              ),
        count: json['count'] as int?,
      );

  final List<TeamMember>? members;
  final int? count;

  Map<String, dynamic> toJson() => {
        'value': members == null ? <dynamic>[] : List<dynamic>.from(members!.map((x) => x.toJson())),
        'count': count,
      };
}

class TeamMember {
  TeamMember({
    required this.isTeamAdmin,
    required this.identity,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        isTeamAdmin: json['isTeamAdmin'] as bool?,
        identity: Identity.fromJson(json['identity'] as Map<String, dynamic>),
      );

  final bool? isTeamAdmin;
  final Identity? identity;

  Map<String, dynamic> toJson() => {
        'isTeamAdmin': isTeamAdmin,
        'identity': identity!.toJson(),
      };

  @override
  String toString() => 'TeamMember(isTeamAdmin: $isTeamAdmin, identity: $identity)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TeamMember && other.isTeamAdmin == isTeamAdmin && other.identity == identity;
  }

  @override
  int get hashCode => isTeamAdmin.hashCode ^ identity.hashCode;
}

class Identity {
  Identity({
    required this.displayName,
    required this.url,
    required this.links,
    required this.id,
    required this.uniqueName,
    required this.imageUrl,
    required this.descriptor,
  });

  factory Identity.fromJson(Map<String, dynamic> json) => Identity(
        displayName: json['displayName'] as String?,
        url: json['url'] as String?,
        links: json['Links'] == null ? null : Links.fromJson(json['Links'] as Map<String, dynamic>),
        id: json['id'] as String?,
        uniqueName: json['uniqueName'] as String?,
        imageUrl: json['imageUrl'] as String?,
        descriptor: json['descriptor'] as String?,
      );

  final String? displayName;
  final String? url;
  final Links? links;
  final String? id;
  final String? uniqueName;
  final String? imageUrl;
  final String? descriptor;

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'url': url,
        'Links': links!.toJson(),
        'id': id,
        'uniqueName': uniqueName,
        'imageUrl': imageUrl,
        'descriptor': descriptor,
      };

  @override
  String toString() {
    return 'Identity(displayName: $displayName, url: $url, links: $links, id: $id, uniqueName: $uniqueName, imageUrl: $imageUrl, descriptor: $descriptor)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Identity &&
        other.displayName == displayName &&
        other.url == url &&
        other.links == links &&
        other.id == id &&
        other.uniqueName == uniqueName &&
        other.imageUrl == imageUrl &&
        other.descriptor == descriptor;
  }

  @override
  int get hashCode {
    return displayName.hashCode ^
        url.hashCode ^
        links.hashCode ^
        id.hashCode ^
        uniqueName.hashCode ^
        imageUrl.hashCode ^
        descriptor.hashCode;
  }
}
