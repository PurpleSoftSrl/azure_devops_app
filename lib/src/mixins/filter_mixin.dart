import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/utils/utils.dart';
import 'package:collection/collection.dart';

mixin FilterMixin {
  final projectAll = Project.all();
  late Project projectFilter = projectAll;
  Set<Project> projectsFilter = {};

  bool get isDefaultProjectsFilter => projectsFilter.isEmpty;

  final userAll = GraphUser.all();
  Set<GraphUser> usersFilter = {};

  bool get isDefaultUsersFilter => usersFilter.isEmpty;

  bool hasManyUsers(AzureApiService api) => getSortedUsers(api, withUserAll: false).length > 10;

  List<GraphUser> getSortedUsers(AzureApiService api, {bool withUserAll = true}) {
    final users = api.allUsers
        .where((u) => u.domain != 'Build' && u.domain != 'AgentPool' && u.domain != 'LOCAL AUTHORITY')
        .toSet()
        .sorted((a, b) => a.displayName!.toLowerCase().compareTo(b.displayName!.toLowerCase()))
        .toList();

    final me = api.allUsers.firstWhereOrNull((u) => u.mailAddress == api.user?.emailAddress);

    final otherUsers = users.where((u) => u != me);

    return [
      if (withUserAll) userAll,
      if (me != null) me.copyWith(displayName: '${me.displayName} (me)'),
      ...otherUsers,
    ];
  }

  List<GraphUser> searchUser(String query, AzureApiService api) {
    final loweredQuery = query.toLowerCase().trim();
    final users = getSortedUsers(api, withUserAll: false);
    return users.where((u) => u.displayName != null && u.displayName!.toLowerCase().contains(loweredQuery)).toList();
  }

  String getFormattedUser(GraphUser user, AzureApiService api) {
    final users = getSortedUsers(api);
    final hasHomonyms = users
            .where((u) => user.displayName != null && u.displayName?.toLowerCase() == user.displayName?.toLowerCase())
            .length >
        1;

    if (hasHomonyms) return user.mailAddress ?? '';

    return user.displayName ?? '';
  }

  bool hasManyProjects(StorageService storage) => storage.getChosenProjects().length > projectsCountThreshold;

  List<Project> getProjects(StorageService storage, {bool withProjectAll = true}) {
    return [if (withProjectAll) projectAll, ...storage.getChosenProjects()];
  }

  List<Project> searchProject(String query, StorageService storage) {
    final loweredQuery = query.toLowerCase().trim();
    final projects = getProjects(storage);
    return projects.where((p) => p.name != null && p.name!.toLowerCase().contains(loweredQuery)).toList();
  }
}
