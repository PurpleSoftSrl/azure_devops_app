import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:highlighting/languages/all.dart';

class ShareExtensionRouter {
  ShareExtensionRouter._();

  static Future<void> handleRoute(Uri url) async {
    final pathSegments = url.pathSegments;
    if (pathSegments.isEmpty) return;
    if (pathSegments.first != AzureApiServiceImpl().organization) return;

    if (_isCommitDetailUrl(pathSegments)) {
      final project = pathSegments[1];
      final repository = pathSegments[3];
      final commitId = pathSegments[5];
      return AppRouter.goToCommitDetail(project: project, repository: repository, commitId: commitId);
    }

    if (_isPipelineDetailUrl(pathSegments)) {
      final project = pathSegments[1];
      final pipelineId = int.tryParse(url.queryParameters['buildId'] ?? '');
      if (pipelineId == null) return;

      return AppRouter.goToPipelineDetail(id: pipelineId, project: project);
    }

    if (_isPullRequestDetailUrl(pathSegments)) {
      final project = pathSegments[1];
      final repository = pathSegments[3];
      final pullRequestId = int.parse(pathSegments[5]);
      return AppRouter.goToPullRequestDetail(project: project, repository: repository, id: pullRequestId);
    }

    if (_isWorkItemDetailUrl(pathSegments)) {
      final project = pathSegments[1];
      final workItemId = int.parse(pathSegments[4]);
      return AppRouter.goToWorkItemDetail(project: project, id: workItemId);
    }

    if (_isCommitsListUrl(pathSegments)) {
      final projectId = pathSegments[1];
      final project = Project(id: projectId, name: projectId);
      return AppRouter.goToCommits(project: project);
    }

    if (_isPipelinesListUrl(pathSegments)) {
      final projectId = pathSegments[1];
      final project = Project(id: projectId, name: projectId);
      final definition = int.tryParse(url.queryParameters['definitionId'] ?? '');

      return AppRouter.goToPipelines(args: (project: project, shortcut: null, definition: definition));
    }

    if (_isPullRequestsListUrl(pathSegments)) {
      final projectId = pathSegments[1];
      final project = Project(id: projectId, name: projectId);
      return AppRouter.goToPullRequests(args: (project: project, shortcut: null));
    }

    if (_isWorkItemsListUrl(pathSegments)) {
      final project = pathSegments[1];
      final args = (project: Project(name: project, id: project), shortcut: null, savedQuery: null);
      return AppRouter.goToWorkItems(args: args);
    }

    if (_isRepositoryUrl(pathSegments)) {
      // repository or file
      final project = pathSegments[1];
      final repository = pathSegments[3];
      final branch = url.queryParameters['version']?.substring(2);
      final path = url.queryParameters['path'];

      final isFile = (path ?? '').isNotEmpty && path!.contains('.') && allLanguages.keys.contains(path.split('.').last);

      final repoDetailArgs =
          RepoDetailArgs(projectName: project, repositoryName: repository, filePath: path, branch: branch);

      if (isFile) return AppRouter.goToFileDetail(repoDetailArgs);

      return AppRouter.goToRepositoryDetail(repoDetailArgs);
    }

    if (_isProjectUrl(pathSegments)) {
      final project = pathSegments[1];
      return AppRouter.goToProjectDetail(project);
    }
  }

  static bool _isRepositoryUrl(List<String> pathSegments) => pathSegments.length > 3 && pathSegments[2] == '_git';

  static bool _isWorkItemDetailUrl(List<String> pathSegments) =>
      pathSegments.length > 4 && pathSegments[2] == '_workitems' && pathSegments[3] == 'edit';

  static bool _isPullRequestDetailUrl(List<String> pathSegments) =>
      pathSegments.length > 5 && pathSegments[2] == '_git' && pathSegments[4] == 'pullrequest';

  static bool _isPipelineDetailUrl(List<String> pathSegments) =>
      pathSegments.length > 3 && pathSegments[2] == '_build' && pathSegments[3] == 'results';

  static bool _isCommitDetailUrl(List<String> pathSegments) =>
      pathSegments.length > 4 && pathSegments[2] == '_git' && pathSegments[4] == 'commit';

  static bool _isCommitsListUrl(List<String> pathSegments) =>
      pathSegments.length > 4 && pathSegments[2] == '_git' && pathSegments[4] == 'commits';

  static bool _isPipelinesListUrl(List<String> pathSegments) => pathSegments.length > 2 && pathSegments[2] == '_build';

  static bool _isWorkItemsListUrl(List<String> pathSegments) =>
      pathSegments.length > 3 && pathSegments[2] == '_workitems' && _workItemsTabs.contains(pathSegments[3]);

  static bool _isPullRequestsListUrl(List<String> pathSegments) =>
      pathSegments.length > 4 && pathSegments[2] == '_git' && pathSegments[4] == 'pullrequests';

  static bool _isProjectUrl(List<String> pathSegments) => pathSegments.length > 1;

  static const _workItemsTabs = [
    'assignedtome',
    'following',
    'mentioned',
    'myactivity',
    'recentlyupdated',
    'recentlycompleted',
    'recentlycreated',
  ];
}
