class Links {
  Links({
    required this.self,
    required this.memberships,
    required this.membershipState,
    required this.storageKey,
    required this.avatar,
  });

  factory Links.fromJson(Map<String, dynamic> json) => Links(
    self: Avatar.fromJson(json['self'] as Map<String, dynamic>),
    memberships: Avatar.fromJson(json['memberships'] as Map<String, dynamic>),
    membershipState: Avatar.fromJson(json['membershipState'] as Map<String, dynamic>),
    storageKey: Avatar.fromJson(json['storageKey'] as Map<String, dynamic>),
    avatar: Avatar.fromJson(json['avatar'] as Map<String, dynamic>),
  );

  final Avatar? self;
  final Avatar? memberships;
  final Avatar? membershipState;
  final Avatar? storageKey;
  final Avatar? avatar;
}

class Avatar {
  Avatar({required this.href});

  factory Avatar.fromJson(Map<String, dynamic> json) => Avatar(href: json['href'] as String?);

  final String? href;
}
