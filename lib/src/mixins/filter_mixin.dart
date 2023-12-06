import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:collection/collection.dart';

mixin FilterMixin {
  final projectAll = Project.all();
  late Project projectFilter = projectAll;
  Set<Project> projectsFilter = {};

  final userAll = GraphUser.all();
  late GraphUser userFilter = userAll;
  Set<GraphUser> usersFilter = {};

  bool hasManyUsers(AzureApiService apiService) => getSortedUsers(apiService, withUserAll: false).length > 10;

  List<GraphUser> getSortedUsers(AzureApiService apiService, {bool withUserAll = true}) {
    final users = apiService.allUsers
        .where((u) => u.domain != 'Build' && u.domain != 'AgentPool' && u.domain != 'LOCAL AUTHORITY')
        .toSet()
        .sorted((a, b) => a.displayName!.toLowerCase().compareTo(b.displayName!.toLowerCase()))
        .toList();

    final me = apiService.allUsers.firstWhereOrNull((u) => u.mailAddress == apiService.user?.emailAddress);

    final otherUsers = users.where((u) => u != me);

    return [
      if (withUserAll) userAll,
      if (me != null) me.copyWith(displayName: '${me.displayName} (me)'),
      ...otherUsers,
    ];
  }

  List<GraphUser> searchUser(String query, AzureApiService apiService) {
    final loweredQuery = query.toLowerCase().trim();
    final users = getSortedUsers(apiService, withUserAll: false);
    return users.where((u) => u.displayName != null && u.displayName!.toLowerCase().contains(loweredQuery)).toList();
  }

  String getFormattedUser(GraphUser user, AzureApiService apiService) {
    final users = getSortedUsers(apiService);
    final hasHomonyms = users
            .where((u) => user.displayName != null && u.displayName?.toLowerCase() == user.displayName?.toLowerCase())
            .length >
        1;

    if (hasHomonyms) return user.mailAddress ?? '';

    return user.displayName ?? '';
  }

  bool hasManyProjects(StorageService storageService) => storageService.getChosenProjects().length > 10;

  List<Project> getProjects(StorageService storageService) {
    return [projectAll, ...storageService.getChosenProjects()];
  }

  List<Project> searchProject(String query, StorageService storageService) {
    final loweredQuery = query.toLowerCase().trim();
    final projects = getProjects(storageService);
    return projects.where((p) => p.name != null && p.name!.toLowerCase().contains(loweredQuery)).toList();
  }
}
