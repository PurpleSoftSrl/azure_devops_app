import 'dart:convert';

import 'package:azure_devops/src/models/project.dart';
import 'package:collection/collection.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageService {
  String getOrganization();
  void setOrganization(String organization);

  Iterable<Project> getChosenProjects();
  void setChosenProjects(Iterable<Project> projects);

  String getThemeMode();
  void setThemeMode(String mode);

  String getToken();
  void setToken(String accessToken);

  void clearNoToken();

  void clear();

  int get numberOfSessions;

  void increaseNumberOfSessions();

  List<StorageFilter> getFilters();

  void saveFilter(
    String organization,
    String area,
    String filterAttribute,
    Set<String> filters,
  );

  void resetFilter(String organization, String area);
}

class StorageServiceCore implements StorageService {
  factory StorageServiceCore() {
    return instance ??= StorageServiceCore._();
  }

  StorageServiceCore._() {
    _helper = _StorageServiceHelper();
  }

  static StorageServiceCore? instance;

  late _StorageServiceHelper _helper;

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    await _helper.init();
  }

  @override
  String getOrganization() {
    return _helper.getString(_Keys.org) ?? '';
  }

  @override
  void setOrganization(String organization) {
    _helper.setString(_Keys.org, organization);
  }

  @override
  Iterable<Project> getChosenProjects() {
    final strings = _helper.getStringList(_Keys.chosenProjects) ?? [];
    return strings.map((p) => Project.fromJson(jsonDecode(p) as Map<String, dynamic>));
  }

  @override
  void setChosenProjects(Iterable<Project> projects) {
    _helper.setStringList(
      _Keys.chosenProjects,
      projects.map(jsonEncode).toList(),
    );
  }

  @override
  String getThemeMode() {
    return _helper.getString(_Keys.theme) ?? '';
  }

  @override
  void setThemeMode(String mode) {
    _helper.setString(_Keys.theme, mode.toLowerCase());
  }

  @override
  String getToken() {
    return _helper.getString(_Keys.token) ?? '';
  }

  @override
  void setToken(String accessToken) {
    _helper.setString(_Keys.token, accessToken);
  }

  @override
  void clearNoToken() {
    final keys = _helper.getKeys();

    for (final k in keys) {
      if ([_Keys.token, _Keys.theme, _Keys.filters].contains(k)) continue;

      _helper.remove(k);
    }
  }

  @override
  void clear() {
    _helper.clear();
  }

  @override
  int get numberOfSessions => _helper.getInt(_Keys.numberOfSessions) ?? 0;

  @override
  void increaseNumberOfSessions() {
    _helper.setInt(_Keys.numberOfSessions, numberOfSessions + 1);
  }

  @override
  List<StorageFilter> getFilters() {
    final filters = _helper.getStringList(_Keys.filters) ?? [];
    return filters.map(StorageFilter.fromJson).toList();
  }

  @override
  void saveFilter(
    String organization,
    String area,
    String attribute,
    Set<String> filters,
  ) {
    final savedFilters = getFilters();

    final attributeFilters = savedFilters.firstWhereOrNull(
      (f) => f.organization == organization && f.area == area && f.attribute == attribute,
    );
    final hasAttributeFilters = attributeFilters != null;
    if (hasAttributeFilters) {
      attributeFilters.filters.clear();
      attributeFilters.filters.addAll(filters);
    } else {
      final filterToSave = StorageFilter(
        organization: organization,
        area: area,
        attribute: attribute,
        filters: filters,
      );

      savedFilters.add(filterToSave);
    }

    _helper.setStringList(
      _Keys.filters,
      savedFilters.map((f) => f.toJson()).toList(),
    );
  }

  @override
  void resetFilter(String organization, String area) {
    final savedFilters = getFilters();

    final otherFilters = savedFilters.whereNot(
      (f) => f.organization == organization && f.area == area,
    );

    _helper.setStringList(
      _Keys.filters,
      otherFilters.map((f) => f.toJson()).toList(),
    );
  }
}

class _StorageServiceHelper {
  factory _StorageServiceHelper() {
    return instance ??= _StorageServiceHelper._();
  }

  _StorageServiceHelper._();

  static _StorageServiceHelper? instance;

  void dispose() {
    instance = null;
  }

  static SharedPreferences? _instance;

  Future<void> init() async {
    _StorageServiceHelper();
    _instance = await SharedPreferences.getInstance();
  }

  void setString(String key, String value) {
    _assertIsInitialized();
    _instance!.setString(key, value);
  }

  String? getString(String key) {
    _assertIsInitialized();
    return _instance!.getString(key);
  }

  void setInt(String key, int value) {
    _assertIsInitialized();
    _instance!.setInt(key, value);
  }

  int? getInt(String key) {
    _assertIsInitialized();
    return _instance!.getInt(key);
  }

  void setStringList(String key, List<String> value) {
    _assertIsInitialized();
    _instance!.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    _assertIsInitialized();
    return _instance!.getStringList(key);
  }

  Set<String> getKeys() {
    _assertIsInitialized();
    return _instance!.getKeys();
  }

  void remove(String key) {
    _assertIsInitialized();
    _instance!.remove(key);
  }

  void clear() {
    _assertIsInitialized();
    _instance!.clear();
  }

  void _assertIsInitialized() {
    assert(_instance != null, 'Storage service must be initialized calling init()');
  }
}

class _Keys {
  static const token = 'token';
  static const chosenProjects = 'chosenProjects';
  static const theme = 'theme';
  static const org = 'org';
  static const numberOfSessions = 'numberOfSessions';
  static const filters = 'filters';
}

class StorageServiceInherited extends InheritedWidget {
  const StorageServiceInherited({super.key, required this.storageService, required super.child});

  final StorageService storageService;

  static StorageServiceInherited of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<StorageServiceInherited>()!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

/// Filters are grouped by organization, area and attribute, where
/// area can be one of (commits, pipelines, workItems, pullRequests) and
/// attribute can be one of (projects, authors, states, etc.).
class StorageFilter {
  StorageFilter({
    required this.organization,
    required this.area,
    required this.attribute,
    required this.filters,
  });

  factory StorageFilter.fromMap(Map<String, dynamic> map) {
    return StorageFilter(
      organization: map['organization'] as String,
      area: map['area'] as String,
      attribute: map['filterAttribute'] as String,
      filters: Set<String>.from(map['filters'] as List<dynamic>),
    );
  }

  factory StorageFilter.fromJson(String source) => StorageFilter.fromMap(json.decode(source) as Map<String, dynamic>);

  final String organization;
  final String area;
  final String attribute;
  final Set<String> filters;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'organization': organization,
      'area': area,
      'filterAttribute': attribute,
      'filters': filters.toList(),
    };
  }

  String toJson() => json.encode(toMap());

  static List<StorageFilter>? listFromJson(
    String json, {
    bool growable = false,
  }) {
    final list = jsonDecode(json) as List<dynamic>?;
    final result = <StorageFilter>[];
    if (list != null) {
      for (final row in list) {
        final value = StorageFilter.fromJson(row as String);
        result.add(value);
      }
    }
    return result.toList(growable: growable);
  }
}
