import 'package:azure_devops/src/models/commit.dart';
import 'package:azure_devops/src/models/pipeline.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/pull_request.dart';
import 'package:azure_devops/src/models/timeline.dart';
import 'package:azure_devops/src/models/work_item.dart';
import 'package:azure_devops/src/screens/choose_projects/base_choose_projects.dart';
import 'package:azure_devops/src/screens/commit_detail/base_commit_detail.dart';
import 'package:azure_devops/src/screens/commits/base_commits.dart';
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
import 'package:azure_devops/src/screens/settings/base_settings.dart';
import 'package:azure_devops/src/screens/tabs/base_tabs.dart';
import 'package:azure_devops/src/screens/work_item_detail/base_work_item_detail.dart';
import 'package:azure_devops/src/screens/work_items/base_work_items.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/widgets/error_page.dart';
import 'package:flutter/material.dart';

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

  static const _error = '/error';

  static int index = 0;

  static List<GlobalKey<NavigatorState>>? _keys;

  static NavigatorState? get rootNavigator => navigatorKey.currentState;

  static NavigatorState? get _currentNavigator => _currentTab ?? rootNavigator;

  static NavigatorState? get _currentTab {
    if (_keys == null) return null;

    return _keys![index].currentState;
  }

  static void setTabKeys(List<GlobalKey<NavigatorState>> keys) {
    _keys = keys;
  }

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

  static bool getChooseProjectArgs(BuildContext context) {
    return ModalRoute.of(context)!.settings.arguments as bool;
  }

  static Future<void> goToPipelines({Project? project}) async {
    await _currentNavigator!.pushNamed(_pipelines, arguments: project);
  }

  static Project? getPipelinesArgs(BuildContext context) {
    return ModalRoute.of(context)!.settings.arguments as Project?;
  }

  static Future<void> goToPipelineDetail(Pipeline pipeline) async {
    await _currentNavigator!.pushNamed(_pipelineDetail, arguments: pipeline);
  }

  static Pipeline getPipelineDetailArgs(BuildContext context) {
    return ModalRoute.of(context)!.settings.arguments as Pipeline;
  }

  static Future<void> goToPipelineLogs(PipelineLogsArgs pipeline) async {
    await _currentNavigator!.pushNamed(_pipelineLogs, arguments: pipeline);
  }

  static PipelineLogsArgs getPipelineLogsArgs(BuildContext context) {
    return ModalRoute.of(context)!.settings.arguments as PipelineLogsArgs;
  }

  static Future<void> goToCommits({Project? project}) async {
    await _currentNavigator!.pushNamed(_commits, arguments: project);
  }

  static Project? getCommitsArgs(BuildContext context) {
    return ModalRoute.of(context)!.settings.arguments as Project?;
  }

  static Future<void> goToCommitDetail(Commit commit) async {
    await _currentNavigator!.pushNamed(_commitDetail, arguments: commit);
  }

  static Commit getCommitDetailArgs(BuildContext context) {
    return ModalRoute.of(context)!.settings.arguments as Commit;
  }

  static Future<void> goToFileDiff(FileDiffArgs args) async {
    await _currentNavigator!.pushNamed(_fileDiff, arguments: args);
  }

  static FileDiffArgs getCommitDiffArgs(BuildContext context) {
    return ModalRoute.of(context)!.settings.arguments as FileDiffArgs;
  }

  static Future<void> goToProjectDetail(String projectName) async {
    await _currentNavigator!.pushNamed(_projectDetail, arguments: projectName);
  }

  static String getProjectDetailArgs(BuildContext context) {
    return ModalRoute.of(context)!.settings.arguments as String;
  }

  static Future<void> goToWorkItems({Project? project}) async {
    await _currentNavigator!.pushNamed(_workItems, arguments: project);
  }

  static Project? getWorkItemsArgs(BuildContext context) {
    return ModalRoute.of(context)!.settings.arguments as Project?;
  }

  static Future<void> goToWorkItemDetail(WorkItem item) async {
    await _currentNavigator!.pushNamed(_workItemDetail, arguments: item);
  }

  static WorkItem getWorkItemDetailArgs(BuildContext context) {
    return ModalRoute.of(context)!.settings.arguments as WorkItem;
  }

  static Future<void> goToPullRequests({Project? project}) async {
    await _currentNavigator!.pushNamed(_pullRequests, arguments: project);
  }

  static Project? getPullRequestsArgs(BuildContext context) {
    return ModalRoute.of(context)!.settings.arguments as Project?;
  }

  static Future<void> goToPullRequestDetail(PullRequest pr) async {
    await _currentNavigator!.pushNamed(_pullRequestDetail, arguments: pr);
  }

  static PullRequest getPullRequestDetailArgs(BuildContext context) {
    return ModalRoute.of(context)!.settings.arguments as PullRequest;
  }

  static Future<void> goToRepositoryDetail(RepoDetailArgs args) async {
    await _currentNavigator!.pushNamed(_repoDetail, arguments: args);
  }

  static RepoDetailArgs getRepositoryDetailArgs(BuildContext context) {
    return ModalRoute.of(context)!.settings.arguments as RepoDetailArgs;
  }

  static Future<void> goToFileDetail(RepoDetailArgs args) async {
    await _currentNavigator!.pushNamed(_fileDetail, arguments: args);
  }

  static RepoDetailArgs getFileDetailArgs(BuildContext context) {
    return ModalRoute.of(context)!.settings.arguments as RepoDetailArgs;
  }

  static Future<void> goToMemberDetail(String userDescriptor) async {
    await _currentNavigator!.pushNamed(_memberDetail, arguments: userDescriptor);
  }

  static String getMemberDetailArgs(BuildContext context) {
    return ModalRoute.of(context)!.settings.arguments as String;
  }

  static Future<void> goToError({required String description}) async {
    await _currentNavigator!.pushNamed(_error, arguments: description);
  }

  static void pop({bool? result}) {
    _currentNavigator!.pop(result);
  }

  static void popRoute() {
    rootNavigator!.pop();
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
    _error: (_) => Material(
          child: ErrorPage(description: 'Something went wrong', onRetry: goToSplash),
        ),
  };

  static Future<bool> askBeforeClosingApp() async {
    final shouldPop = await OverlayService.confirm('Attention', description: 'Do you really want to close the app?');
    return shouldPop;
  }
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

class PipelineLogsArgs {
  PipelineLogsArgs({
    required this.pipeline,
    required this.task,
  });

  final Pipeline pipeline;
  final Record task;

  @override
  String toString() => 'PipelineLogsArgs(pipeline: $pipeline, task: $task)';
}

class FileDiffArgs {
  FileDiffArgs({
    required this.commit,
    required this.filePath,
    required this.isAdded,
    required this.isDeleted,
  });

  final Commit commit;
  final String filePath;
  final bool isAdded;
  final bool isDeleted;

  @override
  String toString() => 'FileDiffArgs(commit: $commit, filePath: $filePath, isAdded: $isAdded, isDeleted: $isDeleted)';
}
