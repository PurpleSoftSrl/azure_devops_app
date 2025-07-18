import 'dart:convert';

import 'package:http/http.dart';

class GetDirectoriesResponse {
  GetDirectoriesResponse({required this.data});

  factory GetDirectoriesResponse.fromJson(Map<String, dynamic> json) => GetDirectoriesResponse(
        data: DataProviders.fromJson(json['dataProviders'] as Map<String, dynamic>? ?? {}),
      );

  static MsVssTfsWebTenantPickerDataProvider fromResponse(Response res) =>
      GetDirectoriesResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).data.provider;

  final DataProviders data;
}

class DataProviders {
  DataProviders({required this.provider});

  factory DataProviders.fromJson(Map<String, dynamic> json) => DataProviders(
        provider: MsVssTfsWebTenantPickerDataProvider.fromJson(
            json['ms.vss-tfs-web.tenant-picker-data-provider'] as Map<String, dynamic>? ?? {}),
      );

  final MsVssTfsWebTenantPickerDataProvider provider;
}

class MsVssTfsWebTenantPickerDataProvider {
  MsVssTfsWebTenantPickerDataProvider({required this.tenantData, required this.user});

  factory MsVssTfsWebTenantPickerDataProvider.fromJson(Map<String, dynamic> json) =>
      MsVssTfsWebTenantPickerDataProvider(
        tenantData: UserTenantData.fromJson(json['userTenantData'] as Map<String, dynamic>? ?? {}),
        user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      );

  final UserTenantData tenantData;
  final User user;
}

class UserTenantData {
  UserTenantData({required this.tenants});

  factory UserTenantData.fromJson(Map<String, dynamic> json) => UserTenantData(
        tenants: List<UserTenant>.from(
            (json['userTenants'] as List<dynamic>? ?? []).map((x) => UserTenant.fromJson(x as Map<String, dynamic>))),
      );

  final List<UserTenant> tenants;
}

class UserTenant {
  UserTenant({
    required this.displayName,
    required this.id,
    required this.authUrl,
    this.isCurrent = false,
  });

  factory UserTenant.fromJson(Map<String, dynamic> json) => UserTenant(
        displayName: json['displayName'] as String? ?? '',
        id: json['id'] as String? ?? '',
        authUrl: json['authUrl'] as String? ?? '',
      );

  factory UserTenant.current({required String displayName, required String id}) => UserTenant(
        displayName: displayName,
        id: id,
        authUrl: '',
        isCurrent: true,
      );

  final String displayName;
  final String id;
  final String authUrl;

  final bool isCurrent;
}

class User {
  User({
    required this.name,
    required this.id,
    required this.email,
    required this.tenant,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        name: json['name'] as String? ?? '',
        id: json['id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        tenant: Tenant.fromJson(json['tenant'] as Map<String, dynamic>? ?? {}),
      );

  final String name;
  final String id;
  final String email;
  final Tenant tenant;
}

class Tenant {
  Tenant({
    required this.displayName,
    required this.id,
    required this.domain,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
        displayName: json['displayName'] as String? ?? '',
        id: json['id'] as String? ?? '',
        domain: json['domain'] as String? ?? '',
      );

  final String displayName;
  final String id;
  final String domain;
}
