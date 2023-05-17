import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:collection/collection.dart';

mixin FilterMixin {
  final projectAll = Project.all();
  late Project projectFilter = projectAll;

  final userAll = GraphUser.all();
  late GraphUser userFilter = userAll;

  List<GraphUser> getSortedUsers(AzureApiService apiService, {bool withUserAll = true}) {
    final users = apiService.allUsers
        .where((u) => u.domain != 'Build' && u.domain != 'AgentPool' && u.domain != 'LOCAL AUTHORITY')
        .sorted((a, b) => a.displayName!.toLowerCase().compareTo(b.displayName!.toLowerCase()))
        .toList();

    final me = apiService.allUsers.firstWhereOrNull((u) => u.mailAddress == apiService.user?.emailAddress);

    return [
      if (withUserAll) userAll,
      if (me != null) me.copyWith(displayName: '${me.displayName} (me)'),
      ...users.where((u) => u != me),
    ];
  }

  List<Project> getProjects(StorageService storageService) {
    return [projectAll, ...storageService.getChosenProjects()];
  }
}
