import 'package:azure_devops/src/models/commit.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/saved_query.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/screens/choose_projects/base_choose_projects.dart';
import 'package:azure_devops/src/screens/choose_subscription/base_choose_subscription.dart';
import 'package:azure_devops/src/screens/commit_detail/base_commit_detail.dart';
import 'package:azure_devops/src/screens/commits/base_commits.dart';
import 'package:azure_devops/src/screens/create_or_edit_work_item/base_create_or_edit_work_item.dart';
import 'package:azure_devops/src/screens/file_detail/base_file_detail.dart';
import 'package:azure_devops/src/screens/file_diff/base_file_diff.dart';
import 'package:azure_devops/src/screens/home/base_home.dart';
import 'package:azure_devops/src/screens/login/base_login.dart';
import 'package:azure_devops/src/screens/member_detail/base_member_detail.dart';
import 'package:azure_devops/src/screens/pipeline_detail/base_pipeline_detail.dart';
import 'package:azure_devops/src/screens/pipeline_logs/base_pipeline_logs.dart';
import 'package:azure_devops/src/screens/pipelines/base_pipelines.dart';
import 'package:azure_devops/src/screens/profile/base_profile.dart';
import 'package:azure_devops/src/screens/project_detail/base_project_detail.dart';
import 'package:azure_devops/src/screens/pull_request_detail/base_pull_request_detail.dart';
import 'package:azure_devops/src/screens/pull_requests/base_pull_requests.dart';
import 'package:azure_devops/src/screens/repository_detail/base_repository_detail.dart';
import 'package:azure_devops/src/screens/saved_queries/base_saved_queries.dart';
import 'package:azure_devops/src/screens/settings/base_settings.dart';
import 'package:azure_devops/src/screens/tabs/base_tabs.dart';
import 'package:azure_devops/src/screens/work_item_detail/base_work_item_detail.dart';
import 'package:azure_devops/src/screens/work_items/base_work_items.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/widgets/error_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef WorkItemsArgs = ({Project? project, SavedShortcut? shortcut, ChildQuery? savedQuery});
typedef WorkItemDetailArgs = ({String project, int id});
typedef CreateOrEditWorkItemArgs = ({String? project, int? id, String? area, String? iteration});
typedef SavedQueriesArgs = ({String? project, String? path, String? queryId});
typedef PullRequestArgs = ({Project? project, SavedShortcut? shortcut});
typedef PullRequestDetailArgs = ({String project, String repository, int id});
typedef CommitsArgs = ({Project? project, GraphUser? author, SavedShortcut? shortcut});
typedef CommitDetailArgs = ({String project, String repository, String commitId});
typedef FileDiffArgs = ({Commit commit, String filePath, bool isAdded, bool isDeleted, int? pullRequestId});
typedef PipelineLogsArgs = ({String project, int pipelineId, String taskId, String parentTaskId, int logId});
typedef PipelinesArgs = ({Project? project, int? definition, SavedShortcut? shortcut});

class AppRouter {
  AppRouter._();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'Root navigator key');

  static const _splash = '/';
  static const _login = '/login';
  static const _chooseProjects = '/choose-projects';
  static const _tabs = '/tabs';
  static const home = '/home';
  static const profile = '/profile';
  static const settings = '/settings';
  static const _pipelines = '/pipelines';
  static const _commits = '/commits';
  static const _workItems = '/workItems';
  static const _pullRequests = '/pullRequests';
  static const _pipelineDetail = '/pipeline-detail';
  static const _pipelineLogs = '/pipeline-logs';
  static const _commitDetail = '/commit-detail';
  static const _fileDiff = '/file-diff';
  static const _projectDetail = '/project-detail';
  static const _repoDetail = '/repo-detail';
  static const _fileDetail = '/file-detail';
  static const _memberDetail = '/member-detail';
  static const _workItemDetail = '/workitem-detail';
  static const _pullRequestDetail = '/pullrequest-detail';
  static const _createOrEditWorkItem = '/create-or-edit-workitem';
  static const _chooseSubscription = '/choose-subscription';
  static const _savedQueries = '/saved-queries';
  static const _error = '/error';

  static int index = 0;

  static List<GlobalKey<NavigatorState>>? _keys;

  static NavigatorState? get rootNavigator => navigatorKey.currentState;

  static NavigatorState? get _currentNavigator => _currentTab ?? rootNavigator;

  static NavigatorState? get _currentTab {
    if (_keys == null) return null;

    return _keys![index].currentState;
  }

  static set tabKeys(List<GlobalKey<NavigatorState>> keys) {
    _keys = keys;
  }

  static Map<String, Widget Function(BuildContext)> routes = {
    _login: (_) => LoginPage(),
    _tabs: (_) => TabsPage(),
    _chooseProjects: (_) => ChooseProjectsPage(),
    home: (_) => HomePage(),
    profile: (_) => ProfilePage(),
    settings: (_) => SettingsPage(),
    _pipelines: (_) => PipelinesPage(),
    _commits: (_) => CommitsPage(),
    _workItems: (_) => WorkItemsPage(),
    _pullRequests: (_) => PullRequestsPage(),
    _pipelineDetail: (_) => PipelineDetailPage(),
    _pipelineLogs: (_) => PipelineLogsPage(),
    _commitDetail: (_) => CommitDetailPage(),
    _fileDiff: (_) => FileDiffPage(),
    _projectDetail: (_) => ProjectDetailPage(),
    _repoDetail: (_) => RepositoryDetailPage(),
    _fileDetail: (_) => FileDetailPage(),
    _memberDetail: (_) => MemberDetailPage(),
    _workItemDetail: (_) => WorkItemDetailPage(),
    _pullRequestDetail: (_) => PullRequestDetailPage(),
    _createOrEditWorkItem: (_) => CreateOrEditWorkItemPage(),
    _chooseSubscription: (_) => ChooseSubscriptionPage(),
    _savedQueries: (_) => SavedQueriesPage(),
    _error: (_) => ErrorPage(description: 'Something went wrong', onRetry: goToSplash),
  };

  static Future<void> goToSplash() async {
    await rootNavigator!.pushNamedAndRemoveUntil(_splash, (_) => false);
  }

  static Future<void> goToLogin() async {
    await rootNavigator!.pushNamedAndRemoveUntil(_login, (_) => false);
  }

  static Future<void> goToTabs() async {
    await rootNavigator!.pushNamedAndRemoveUntil(_tabs, (_) => false);
  }

  static Future<void> goToChooseProjects({bool removeRoutes = true}) async {
    if (removeRoutes) {
      await rootNavigator!.pushNamedAndRemoveUntil(_chooseProjects, (_) => false, arguments: removeRoutes);
    } else {
      await rootNavigator!.pushNamed(_chooseProjects, arguments: removeRoutes);
    }
  }

  static bool getChooseProjectArgs(BuildContext context) => _getArgs(context);

  static Future<void> goToPipelines({PipelinesArgs? args}) => _goTo(_pipelines, args: args);

  static PipelinesArgs? getPipelinesArgs(BuildContext context) => _getArgs(context);

  static Future<void> goToPipelineDetail({required int id, required String project}) =>
      _goTo(_pipelineDetail, args: (id: id, project: project));

  static ({String project, int id}) getPipelineDetailArgs(BuildContext context) => _getArgs(context);

  static Future<void> goToPipelineLogs(PipelineLogsArgs pipeline) =>
      _goTo<PipelineLogsArgs>(_pipelineLogs, args: pipeline);

  static PipelineLogsArgs getPipelineLogsArgs(BuildContext context) => _getArgs(context);

  static Future<void> goToCommits({Project? project, GraphUser? author, SavedShortcut? shortcut}) =>
      _goTo(_commits, args: (project: project, author: author, shortcut: shortcut));

  static CommitsArgs? getCommitsArgs(BuildContext context) => _getArgs(context);

  static Future<void> goToCommitDetail({
    required String project,
    required String repository,
    required String commitId,
  }) async =>
      _goTo<CommitDetailArgs>(_commitDetail, args: (project: project, repository: repository, commitId: commitId));

  static CommitDetailArgs getCommitDetailArgs(BuildContext context) => _getArgs(context);

  static Future<void> goToFileDiff(FileDiffArgs args) => _goTo<FileDiffArgs>(_fileDiff, args: args);

  static FileDiffArgs getCommitDiffArgs(BuildContext context) => _getArgs(context);

  static Future<void> goToProjectDetail(String projectName) => _goTo(_projectDetail, args: projectName);

  static String getProjectDetailArgs(BuildContext context) => _getArgs(context);

  static Future<void> goToWorkItems({WorkItemsArgs? args}) => _goTo(_workItems, args: args);

  static WorkItemsArgs? getWorkItemsArgs(BuildContext context) => _getArgs(context);

  static Future<void> goToWorkItemDetail({required String project, required int id}) =>
      _goTo<WorkItemDetailArgs>(_workItemDetail, args: (project: project, id: id));

  static WorkItemDetailArgs getWorkItemDetailArgs(BuildContext context) => _getArgs(context);

  static Future<void> goToCreateOrEditWorkItem({CreateOrEditWorkItemArgs? args}) =>
      _goTo<CreateOrEditWorkItemArgs>(_createOrEditWorkItem, args: args);

  static Future<void> goToChooseSubscription() => _goTo(_chooseSubscription);

  static CreateOrEditWorkItemArgs getCreateOrEditWorkItemArgs(BuildContext context) => _getArgs(context);

  static Future<void> goToSavedQueries({SavedQueriesArgs? args}) => _goTo<SavedQueriesArgs?>(_savedQueries, args: args);

  static SavedQueriesArgs? getSavedQueriesArgs(BuildContext context) => _getArgs(context);

  static Future<void> goToPullRequests({PullRequestArgs? args}) => _goTo(_pullRequests, args: args);

  static PullRequestArgs? getPullRequestsArgs(BuildContext context) => _getArgs(context);

  static Future<void> goToPullRequestDetail({required String project, required String repository, required int id}) =>
      _goTo<PullRequestDetailArgs>(_pullRequestDetail, args: (project: project, repository: repository, id: id));

  static PullRequestDetailArgs getPullRequestDetailArgs(BuildContext context) => _getArgs(context);

  static Future<void> goToRepositoryDetail(RepoDetailArgs args) => _goTo(_repoDetail, args: args);

  static RepoDetailArgs getRepositoryDetailArgs(BuildContext context) => _getArgs(context);

  static Future<void> goToFileDetail(RepoDetailArgs args) => _goTo(_fileDetail, args: args);

  static RepoDetailArgs getFileDetailArgs(BuildContext context) => _getArgs(context);

  static Future<void> goToMemberDetail(String userDescriptor) => _goTo(_memberDetail, args: userDescriptor);

  static String getMemberDetailArgs(BuildContext context) => _getArgs(context);

  static Future<void> goToError({required String description}) => _goTo(_error, args: description);

  static void pop({bool? result}) {
    _currentNavigator!.pop(result);
  }

  static void popRoute() {
    rootNavigator!.pop();
  }

  static Future<void> askBeforeClosingApp({required bool didPop}) async {
    if (didPop) return;

    final shouldPop = await OverlayService.confirm('Attention', description: 'Do you really want to close the app?');

    if (shouldPop) {
      await Future<void>.delayed(Duration(milliseconds: 100));
      await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }

  static Future<void> _goTo<T>(String page, {T? args}) => _currentNavigator!.pushNamed(page, arguments: args);

  static T _getArgs<T extends Object?>(BuildContext context) => ModalRoute.of(context)!.settings.arguments as T;
}

class RepoDetailArgs {
  RepoDetailArgs({
    required this.projectName,
    required this.repositoryName,
    this.filePath,
    this.branch,
  });

  final String projectName;
  final String repositoryName;
  final String? filePath;
  final String? branch;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RepoDetailArgs &&
        other.projectName == projectName &&
        other.repositoryName == repositoryName &&
        other.filePath == filePath &&
        other.branch == branch;
  }

  @override
  int get hashCode {
    return projectName.hashCode ^ repositoryName.hashCode ^ filePath.hashCode ^ branch.hashCode;
  }

  @override
  String toString() {
    return 'RepoDetailArgs(projectName: $projectName, repositoryName: $repositoryName, filePath: $filePath, branch: $branch)';
  }

  RepoDetailArgs copyWith({
    String? projectName,
    String? repositoryName,
    String? filePath,
    String? branch,
  }) {
    return RepoDetailArgs(
      projectName: projectName ?? this.projectName,
      repositoryName: repositoryName ?? this.repositoryName,
      filePath: filePath ?? this.filePath,
      branch: branch ?? this.branch,
    );
  }
}
