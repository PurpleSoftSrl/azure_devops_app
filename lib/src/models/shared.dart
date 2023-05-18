class Links {
  Links({
    required this.self,
    required this.memberships,
    required this.membershipState,
    required this.storageKey,
    required this.avatar,
  });

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        self: _Avatar.fromJson(json['self'] as Map<String, dynamic>),
        memberships: _Avatar.fromJson(json['memberships'] as Map<String, dynamic>),
        membershipState: _Avatar.fromJson(json['membershipState'] as Map<String, dynamic>),
        storageKey: _Avatar.fromJson(json['storageKey'] as Map<String, dynamic>),
        avatar: _Avatar.fromJson(json['avatar'] as Map<String, dynamic>),
      );

  final _Avatar? self;
  final _Avatar? memberships;
  final _Avatar? membershipState;
  final _Avatar? storageKey;
  final _Avatar? avatar;
}

class _Avatar {
  _Avatar({
    required this.href,
  });

  factory _Avatar.fromJson(Map<String, dynamic> json) => _Avatar(
        href: json['href'] as String?,
      );

  final String? href;
}
