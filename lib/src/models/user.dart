import 'package:azure_devops/src/models/shared.dart';

class GetUsersResponse {
  GetUsersResponse({
    required this.count,
    required this.users,
  });

  factory GetUsersResponse.fromJson(Map<String, dynamic> json) => GetUsersResponse(
        count: json['count'] as int?,
        users: json['value'] == null
            ? []
            : List<GraphUser>.from(
                (json['value'] as List<dynamic>).map((x) => GraphUser.fromJson(x as Map<String, dynamic>)),
              ),
      );

  final int? count;
  final List<GraphUser>? users;

  Map<String, dynamic> toJson() => {
        'count': count,
        'value': users == null ? <dynamic>[] : List<dynamic>.from(users!.map((x) => x.toJson())),
      };
}

class GraphUser {
  GraphUser({
    required this.subjectKind,
    required this.domain,
    required this.principalName,
    required this.mailAddress,
    required this.origin,
    required this.originId,
    required this.displayName,
    required this.links,
    required this.url,
    required this.descriptor,
    required this.metaType,
    required this.directoryAlias,
  });

  factory GraphUser.fromJson(Map<String, dynamic> json) => GraphUser(
        subjectKind: json['subjectKind'] as String?,
        domain: json['domain'] as String?,
        principalName: json['principalName'] as String?,
        mailAddress: json['mailAddress'] as String?,
        origin: json['origin'] as String?,
        originId: json['originId'] as String?,
        displayName: json['displayName'] as String?,
        links: json['Links'] == null ? null : Links.fromJson(json['Links'] as Map<String, dynamic>),
        url: json['url'] as String?,
        descriptor: json['descriptor'] as String?,
        metaType: json['metaType'] as String?,
        directoryAlias: json['directoryAlias'] as String?,
      );

  final String? subjectKind;
  final String? domain;
  final String? principalName;
  final String? mailAddress;
  final String? origin;
  final String? originId;
  final String? displayName;
  final Links? links;
  final String? url;
  final String? descriptor;
  final String? metaType;
  final String? directoryAlias;

  Map<String, dynamic> toJson() => {
        'subjectKind': subjectKind,
        'domain': domain,
        'principalName': principalName,
        'mailAddress': mailAddress,
        'origin': origin,
        'originId': originId,
        'displayName': displayName,
        'Links': links!.toJson(),
        'url': url,
        'descriptor': descriptor,
        'metaType': metaType,
        'directoryAlias': directoryAlias,
      };

  @override
  String toString() {
    return 'User(subjectKind: $subjectKind, domain: $domain, principalName: $principalName, mailAddress: $mailAddress, origin: $origin, originId: $originId, displayName: $displayName, links: $links, url: $url, descriptor: $descriptor, metaType: $metaType, directoryAlias: $directoryAlias)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GraphUser &&
        other.subjectKind == subjectKind &&
        other.domain == domain &&
        other.principalName == principalName &&
        other.mailAddress == mailAddress &&
        other.origin == origin &&
        other.originId == originId &&
        other.displayName == displayName &&
        other.links == links &&
        other.url == url &&
        other.descriptor == descriptor &&
        other.metaType == metaType &&
        other.directoryAlias == directoryAlias;
  }

  @override
  int get hashCode {
    return subjectKind.hashCode ^
        domain.hashCode ^
        principalName.hashCode ^
        mailAddress.hashCode ^
        origin.hashCode ^
        originId.hashCode ^
        displayName.hashCode ^
        links.hashCode ^
        url.hashCode ^
        descriptor.hashCode ^
        metaType.hashCode ^
        directoryAlias.hashCode;
  }
}

class UserMe {
  UserMe({
    required this.displayName,
    required this.publicAlias,
    required this.emailAddress,
    required this.coreRevision,
    required this.timeStamp,
    required this.id,
    required this.revision,
  });

  factory UserMe.fromJson(Map<String, dynamic> json) => UserMe(
        displayName: json['displayName'] as String?,
        publicAlias: json['publicAlias'] as String?,
        emailAddress: json['emailAddress'] as String?,
        coreRevision: json['coreRevision'] as int?,
        timeStamp: DateTime.tryParse(json['timeStamp']?.toString() ?? '')?.toLocal(),
        id: json['id'] as String?,
        revision: json['revision'] as int?,
      );

  final String? displayName;
  final String? publicAlias;
  final String? emailAddress;
  final int? coreRevision;
  final DateTime? timeStamp;
  final String? id;
  final int? revision;

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'publicAlias': publicAlias,
        'emailAddress': emailAddress,
        'coreRevision': coreRevision,
        'timeStamp': timeStamp?.toIso8601String(),
        'id': id,
        'revision': revision,
      };

  @override
  String toString() {
    return 'MiniUser(displayName: $displayName, publicAlias: $publicAlias, emailAddress: $emailAddress, coreRevision: $coreRevision, timeStamp: $timeStamp, id: $id, revision: $revision)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserMe &&
        other.displayName == displayName &&
        other.publicAlias == publicAlias &&
        other.emailAddress == emailAddress &&
        other.coreRevision == coreRevision &&
        other.timeStamp == timeStamp &&
        other.id == id &&
        other.revision == revision;
  }

  @override
  int get hashCode {
    return displayName.hashCode ^
        publicAlias.hashCode ^
        emailAddress.hashCode ^
        coreRevision.hashCode ^
        timeStamp.hashCode ^
        id.hashCode ^
        revision.hashCode;
  }
}
