import 'dart:convert';

import 'package:azure_devops/src/models/project.dart';
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
}

class StorageServiceCore implements StorageService {
  factory StorageServiceCore() {
    return instance ??= StorageServiceCore._();
  }

  StorageServiceCore._() {
    _helper = _StorageServiceHelper();
  }

  static StorageServiceCore? instance;

  static _StorageServiceHelper? _helper;

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    await _helper!.init();
  }

  @override
  String getOrganization() {
    return _helper!.getString(_Keys.org) ?? '';
  }

  @override
  void setOrganization(String organization) {
    _helper!.setString(_Keys.org, organization);
  }

  @override
  Iterable<Project> getChosenProjects() {
    final strings = _helper!.getStringList(_Keys.chosenProjects) ?? [];
    return strings.map((p) => Project.fromJson(jsonDecode(p) as Map<String, dynamic>));
  }

  @override
  void setChosenProjects(Iterable<Project> projects) {
    _helper!.setStringList(
      _Keys.chosenProjects,
      projects.map(jsonEncode).toList(),
    );
  }

  @override
  String getThemeMode() {
    return _helper!.getString(_Keys.theme) ?? '';
  }

  @override
  void setThemeMode(String mode) {
    _helper!.setString(_Keys.theme, mode.toLowerCase());
  }

  @override
  String getToken() {
    return _helper!.getString(_Keys.token) ?? '';
  }

  @override
  void setToken(String accessToken) {
    _helper!.setString(_Keys.token, accessToken);
  }

  @override
  void clearNoToken() {
    final keys = _helper!.getKeys();

    for (final k in keys) {
      if (k == _Keys.token) continue;

      _helper!.remove(k);
    }
  }

  @override
  void clear() {
    _helper!.clear();
  }

  @override
  int get numberOfSessions => _helper!.getInt(_Keys.numberOfSessions) ?? 0;

  @override
  void increaseNumberOfSessions() {
    _helper!.setInt(_Keys.numberOfSessions, numberOfSessions + 1);
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
