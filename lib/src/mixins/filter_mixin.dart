import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:collection/collection.dart';

mixin FilterMixin {
  final userAll = GraphUser.all();
  late GraphUser userFilter = userAll;

  List<GraphUser> getSortedUsers(AzureApiService apiService, {bool withUserAll = true}) {
    final users = apiService.allUsers
        .where((u) => u.domain != 'Build' && u.domain != 'AgentPool' && u.domain != 'LOCAL AUTHORITY')
        .sorted((a, b) => a.displayName!.toLowerCase().compareTo(b.displayName!.toLowerCase()))
        .toList();

    return [if (withUserAll) userAll, ...users];
  }
}
