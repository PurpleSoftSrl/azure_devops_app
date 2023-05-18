import 'package:flutter/foundation.dart';

class GetOrganizationsResponse {
  GetOrganizationsResponse({
    required this.count,
    required this.organizations,
  });

  factory GetOrganizationsResponse.fromJson(Map<String, dynamic> json) => GetOrganizationsResponse(
        count: json['count'] as int?,
        organizations: json['value'] == null
            ? []
            : List<Organization>.from(
                (json['value'] as List<dynamic>).map((x) => Organization.fromJson(x as Map<String, dynamic>)),
              ),
      );

  final int? count;
  final List<Organization>? organizations;
}

class Organization {
  Organization({
    required this.accountId,
    required this.accountUri,
    required this.accountName,
    required this.properties,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
        accountId: json['accountId'] as String?,
        accountUri: json['accountUri'] as String?,
        accountName: json['accountName'] as String?,
        properties: json['properties'] as Map<String, dynamic>,
      );

  final String? accountId;
  final String? accountUri;
  final String? accountName;
  final Map<String, dynamic>? properties;

  @override
  String toString() {
    return 'Organization(accountId: $accountId, accountUri: $accountUri, accountName: $accountName, properties: $properties)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Organization &&
        other.accountId == accountId &&
        other.accountUri == accountUri &&
        other.accountName == accountName &&
        mapEquals(other.properties, properties);
  }

  @override
  int get hashCode {
    return accountId.hashCode ^ accountUri.hashCode ^ accountName.hashCode ^ properties.hashCode;
  }
}
