class GetUserEntitlementsResponse {
  factory GetUserEntitlementsResponse.fromJson(Map<String, dynamic> json) => GetUserEntitlementsResponse(
        members:
            List<_Item>.from((json['members'] as List<dynamic>).map((m) => _Item.fromJson(m as Map<String, dynamic>))),
      );
  GetUserEntitlementsResponse({
    required this.members,
  });

  final List<_Item> members;

  Map<String, dynamic> toJson() => {
        'members': List<dynamic>.from(members.map((x) => x.toJson())),
      };
}

class _Item {
  factory _Item.fromJson(Map<String, dynamic> json) => _Item(
        user: _User.fromJson(json['user'] as Map<String, dynamic>),
        extensions: List<dynamic>.from((json['extensions'] as List<dynamic>).map((x) => x)),
        id: json['id'] as String,
        accessLevel: _AccessLevel.fromJson(json['accessLevel'] as Map<String, dynamic>),
        lastAccessedDate: DateTime.parse(json['lastAccessedDate']!.toString()).toLocal(),
        dateCreated: DateTime.parse(json['dateCreated']!.toString()).toLocal(),
        projectEntitlements: List<dynamic>.from((json['projectEntitlements'] as List<dynamic>).map((x) => x)),
        groupAssignments: List<dynamic>.from((json['groupAssignments'] as List<dynamic>).map((x) => x)),
      );
  _Item({
    required this.user,
    required this.extensions,
    required this.id,
    required this.accessLevel,
    required this.lastAccessedDate,
    required this.dateCreated,
    required this.projectEntitlements,
    required this.groupAssignments,
  });

  final _User user;
  final List<dynamic> extensions;
  final String id;
  final _AccessLevel accessLevel;
  final DateTime lastAccessedDate;
  final DateTime dateCreated;
  final List<dynamic> projectEntitlements;
  final List<dynamic> groupAssignments;

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'extensions': List<dynamic>.from(extensions.map((x) => x)),
        'id': id,
        'accessLevel': accessLevel.toJson(),
        'lastAccessedDate': lastAccessedDate.toIso8601String(),
        'dateCreated': dateCreated.toIso8601String(),
        'projectEntitlements': List<dynamic>.from(projectEntitlements.map((x) => x)),
        'groupAssignments': List<dynamic>.from(groupAssignments.map((x) => x)),
      };
}

class _AccessLevel {
  factory _AccessLevel.fromJson(Map<String, dynamic> json) => _AccessLevel(
        licensingSource: json['licensingSource'] as String,
        accountLicenseType: json['accountLicenseType'] as String,
        msdnLicenseType: json['msdnLicenseType'] as String,
        licenseDisplayName: json['licenseDisplayName'] as String,
        status: json['status'] as String,
        statusMessage: json['statusMessage'] as String,
        assignmentSource: json['assignmentSource'] as String,
      );
  _AccessLevel({
    required this.licensingSource,
    required this.accountLicenseType,
    required this.msdnLicenseType,
    required this.licenseDisplayName,
    required this.status,
    required this.statusMessage,
    required this.assignmentSource,
  });

  final String licensingSource;
  final String accountLicenseType;
  final String msdnLicenseType;
  final String licenseDisplayName;
  final String status;
  final String statusMessage;
  final String assignmentSource;

  Map<String, dynamic> toJson() => {
        'licensingSource': licensingSource,
        'accountLicenseType': accountLicenseType,
        'msdnLicenseType': msdnLicenseType,
        'licenseDisplayName': licenseDisplayName,
        'status': status,
        'statusMessage': statusMessage,
        'assignmentSource': assignmentSource,
      };
}

class _User {
  factory _User.fromJson(Map<String, dynamic> json) => _User(
        subjectKind: json['subjectKind'] as String,
        metaType: json['metaType'] as String,
        directoryAlias: json['directoryAlias'] as String,
        domain: json['domain'] as String,
        principalName: json['principalName'] as String,
        mailAddress: json['mailAddress'] as String,
        origin: json['origin'] as String,
        originId: json['originId'] as String,
        displayName: json['displayName'] as String,
        links: _Links.fromJson(json['_links'] as Map<String, dynamic>),
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
    required this.links,
    required this.url,
    required this.descriptor,
  });

  final String subjectKind;
  final String metaType;
  final String directoryAlias;
  final String domain;
  final String principalName;
  final String mailAddress;
  final String origin;
  final String originId;
  final String displayName;
  final _Links links;
  final String url;
  final String descriptor;

  Map<String, dynamic> toJson() => {
        'subjectKind': subjectKind,
        'metaType': metaType,
        'directoryAlias': directoryAlias,
        'domain': domain,
        'principalName': principalName,
        'mailAddress': mailAddress,
        'origin': origin,
        'originId': originId,
        'displayName': displayName,
        '_links': links.toJson(),
        'url': url,
        'descriptor': descriptor,
      };
}

class _Links {
  factory _Links.fromJson(Map<String, dynamic> json) => _Links(
        self: _Avatar.fromJson(json['self'] as Map<String, dynamic>),
        memberships: _Avatar.fromJson(json['memberships'] as Map<String, dynamic>),
        membershipState: _Avatar.fromJson(json['membershipState'] as Map<String, dynamic>),
        storageKey: _Avatar.fromJson(json['storageKey'] as Map<String, dynamic>),
        avatar: _Avatar.fromJson(json['avatar'] as Map<String, dynamic>),
      );
  _Links({
    required this.self,
    required this.memberships,
    required this.membershipState,
    required this.storageKey,
    required this.avatar,
  });

  final _Avatar self;
  final _Avatar memberships;
  final _Avatar membershipState;
  final _Avatar storageKey;
  final _Avatar avatar;

  Map<String, dynamic> toJson() => {
        'self': self.toJson(),
        'memberships': memberships.toJson(),
        'membershipState': membershipState.toJson(),
        'storageKey': storageKey.toJson(),
        'avatar': avatar.toJson(),
      };
}

class _Avatar {
  factory _Avatar.fromJson(Map<String, dynamic> json) => _Avatar(
        href: json['href'] as String,
      );
  _Avatar({
    required this.href,
  });

  final String href;

  Map<String, dynamic> toJson() => {
        'href': href,
      };
}
