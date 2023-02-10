import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:azure_devops/src/extensions/reponse_extension.dart';
import 'package:azure_devops/src/models/commit.dart';
import 'package:azure_devops/src/models/commit_detail.dart';
import 'package:azure_devops/src/models/organization.dart';
import 'package:azure_devops/src/models/pipeline.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/project_languages.dart';
import 'package:azure_devops/src/models/pull_request.dart';
import 'package:azure_devops/src/models/repository.dart';
import 'package:azure_devops/src/models/team.dart';
import 'package:azure_devops/src/models/team_member.dart';
import 'package:azure_devops/src/models/timeline.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/models/user_entitlements.dart';
import 'package:azure_devops/src/models/work_item.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class AzureApiService {
  const AzureApiService();

  String get organization;

  String get accessToken;

  UserMe? get user;

  Map<String, String>? get headers;

  String get basePath;

  List<GraphUser> get allUsers;

  String getUserAvatarUrl(String userDescriptor);

  Future<LoginStatus> login(String accessToken);

  Future<void> setOrganization(String org);

  Future<ApiResponse<List<Organization>>> getOrganizations();

  void setChosenProjects(List<Project> chosenProjects);

  Future<ApiResponse<List<Project>>> getProjects();

  Future<ApiResponse<Project>> getProject({required String projectName});

  Future<ApiResponse<List<WorkItem>>> getWorkItems();

  Future<ApiResponse<WorkItemDetail>> getWorkItemDetail({
    required String projectName,
    required int workItemId,
  });

  Future<ApiResponse<List<PullRequest>>> getPullRequests({
    required PullRequestState filter,
    GraphUser? creator,
    Project? project,
  });

  Future<ApiResponse<List<GitRepository>>> getProjectRepositories({required String projectName});

  Future<ApiResponse<List<Pipeline>>> getProjectPipelines({
    required String projectName,
    required int top,
    required DateTime to,
  });

  Future<ApiResponse<List<PullRequest>>> getProjectPullRequests({required String projectName});

  Future<ApiResponse<List<LanguageBreakdown>>> getProjectLanguages({required String projectName});

  Future<ApiResponse<List<Commit>>> getRepositoryCommits({
    required String projectName,
    required String repoName,
    required int top,
    required int skip,
  });

  Future<ApiResponse<List<Commit>>> getRecentCommits({Project? project, String? author, int? maxCount});

  Future<ApiResponse<CommitDetail>> getCommitDetail({
    required String projectId,
    required String repositoryId,
    required String commitId,
  });

  Future<ApiResponse<List<Pipeline>>> getRecentPipelines({
    PipelineResult result,
    PipelineStatus status,
    String? triggeredBy,
  });

  Future<ApiResponse<Pipeline>> getPipeline({required String projectName, required int id});

  Future<ApiResponse<List<Record>>> getPipelineTimeline({required String projectName, required int id});

  Future<ApiResponse<String>> getPipelineTaskLogs({
    required String projectName,
    required int pipelineId,
    required int logId,
  });

  Future<ApiResponse<Pipeline>> cancelPipeline({required int buildId, required String projectId});

  Future<ApiResponse<Pipeline>> rerunPipeline({
    required int definitionId,
    required String projectId,
    required String branch,
  });

  Future<ApiResponse<GraphUser>> getUserFromEmail({required String email});

  Future<ApiResponse<GraphUser>> getUserFromDescriptor({required String descriptor});

  Future<ApiResponse<List<TeamMember>>> getProjectTeams({required String projectId});

  Future<ApiResponse<PullRequest>> getPullRequest({required String projectName, required int id});

  Future<void> logout();
}

class AzureApiServiceImpl implements AzureApiService {
  factory AzureApiServiceImpl() {
    return instance ??= AzureApiServiceImpl._();
  }

  AzureApiServiceImpl._();

  static AzureApiServiceImpl? instance;

  final _client = Client();

  String _accessToken = '';

  String _organization = '';

  UserMe? _user;

  @override
  String get organization => _organization;

  @override
  String get accessToken => _accessToken;

  @override
  UserMe? get user => _user;

  @override
  String get basePath => _basePath;
  String get _basePath => 'https://dev.azure.com/$_organization';

  String get _usersBasePath => 'https://vssps.dev.azure.com';

  String get _apiVersion => 'api-version=7.0';

  @override
  List<GraphUser> get allUsers => _allUsers;
  List<GraphUser> _allUsers = [];

  @override
  Map<String, String>? get headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Basic ${base64.encode(utf8.encode(':$_accessToken'))}',
      };

  List<Project> _projects = [];
  Iterable<Project>? _chosenProjects;

  void dispose() {
    instance = null;
  }

  @override
  String getUserAvatarUrl(String userDescriptor) {
    return '$_basePath/_apis/GraphProfile/MemberAvatars/$userDescriptor?size=large';
  }

  Future<Response> _get(String url) async {
    print('GET $url');
    final res = await _client.get(
      Uri.parse(url),
      headers: headers,
    );

    _addSentryBreadcrumb(url, 'GET', res);

    return res;
  }

  Future<Response> _patch(String url, {Map<String, String>? body}) async {
    print('PATCH $url');
    final res = await _client.patch(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    _addSentryBreadcrumb(url, 'PATCH', res);

    return res;
  }

  Future<Response> _post(String url, {Map<String, String>? body}) async {
    print('POST $url');
    final res = await _client.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    _addSentryBreadcrumb(url, 'POST', res);

    return res;
  }

  void _addSentryBreadcrumb(String url, String method, Response res) {
    Sentry.addBreadcrumb(
      Breadcrumb.http(url: Uri.parse(url), method: method, reason: res.reasonPhrase, statusCode: res.statusCode),
    );
  }

  @override
  Future<LoginStatus> login(String accessToken) async {
    final oldToken = _accessToken;

    _accessToken = accessToken;

    final accountsRes = await _get('$_usersBasePath/_apis/profile/profiles/me?$_apiVersion-preview');

    if (accountsRes.statusCode == HttpStatus.unauthorized) {
      _accessToken = oldToken;
      return LoginStatus.unauthorized;
    }

    if (accountsRes.statusCode != HttpStatus.ok) {
      _accessToken = oldToken;
      return LoginStatus.failed;
    }

    StorageServiceCore.instance!.setToken(accessToken);

    final user = UserMe.fromJson(jsonDecode(accountsRes.body) as Map<String, dynamic>);
    _user = user;

    _organization = StorageServiceCore().getOrganization();

    unawaited(_getUsers());

    if (_organization.isEmpty) {
      return LoginStatus.orgNotSet;
    }

    _chosenProjects = StorageServiceCore().getChosenProjects();

    if (_chosenProjects!.isEmpty) {
      return LoginStatus.projectsNotSet;
    }

    return LoginStatus.ok;
  }

  @override
  Future<void> setOrganization(String org) async {
    _organization = org.endsWith('/') ? org.substring(0, org.length - 1) : org;

    StorageServiceCore.instance!.setOrganization(_organization);
  }

  @override
  Future<ApiResponse<List<Organization>>> getOrganizations() async {
    final orgsRes =
        await _get('https://app.vssps.visualstudio.com/_apis/accounts?memberId=${user!.publicAlias}&$_apiVersion');

    if (orgsRes.isError) return ApiResponse.error();

    return ApiResponse.ok(
      GetOrganizationsResponse.fromJson(jsonDecode(orgsRes.body) as Map<String, dynamic>).organizations,
    );
  }

  @override
  void setChosenProjects(List<Project> chosenProjects) {
    _chosenProjects = chosenProjects.toList();

    StorageServiceCore().setChosenProjects(_chosenProjects!);
  }

  @override
  Future<ApiResponse<List<Project>>> getProjects() async {
    _chosenProjects = StorageServiceCore().getChosenProjects();

    final projectsRes = await _get('$_basePath/_apis/projects?$_apiVersion&getDefaultTeamImageUrl=true');
    if (projectsRes.isError) return ApiResponse.error();

    final res = GetProjectsResponse.fromJson(jsonDecode(projectsRes.body) as Map<String, dynamic>);
    _projects = res.projects;

    return ApiResponse.ok(_projects);
  }

  @override
  Future<ApiResponse<Project>> getProject({required String projectName}) async {
    final projectRes = await _get('$_basePath/_apis/projects/$projectName?$_apiVersion');
    if (projectRes.isError) return ApiResponse.error();

    final project = Project.fromJson(jsonDecode(projectRes.body) as Map<String, dynamic>);

    return ApiResponse.ok(project);
  }

  @override
  Future<ApiResponse<List<WorkItem>>> getWorkItems() async {
    final workItemsRes = await _get('$_basePath/_apis/work/accountmyworkrecentactivity?$_apiVersion');
    if (workItemsRes.isError) return ApiResponse.error();

    final projects = StorageServiceCore().getChosenProjects();
    return ApiResponse.ok(
      GetWorkItemsResponse.fromJson(jsonDecode(workItemsRes.body) as Map<String, dynamic>)
          .workItems
          .where((i) => projects.map((p) => p.name!.toLowerCase()).contains(i.teamProject.toLowerCase()))
          .toList(),
    );
  }

  @override
  Future<ApiResponse<WorkItemDetail>> getWorkItemDetail({
    required String projectName,
    required int workItemId,
  }) async {
    final workItemRes = await _get('$_basePath/$projectName/_apis/wit/workitems/$workItemId?$_apiVersion');
    if (workItemRes.isError) return ApiResponse.error();

    return ApiResponse.ok(WorkItemDetail.fromJson(jsonDecode(workItemRes.body) as Map<String, dynamic>));
  }

  @override
  Future<ApiResponse<List<PullRequest>>> getPullRequests({
    required PullRequestState filter,
    GraphUser? creator,
    Project? project,
  }) async {
    var creatorFilter = '';
    if (creator != null) {
      final creatorSearch = "&\$filter=name eq '${creator.mailAddress}'";
      final r =
          await _get('https://vsaex.dev.azure.com/$_organization/_apis/userentitlements?$_apiVersion$creatorSearch');

      final entitlement =
          GetUserEntitlementsResponse.fromJson(jsonDecode(r.body) as Map<String, dynamic>).members.first;

      creatorFilter = '&searchCriteria.creatorId=${entitlement.id}';
    }

    final projectsToSearch = project != null ? [project] : (_chosenProjects ?? _projects);

    final allProjectPrs = await Future.wait([
      for (final project in projectsToSearch)
        _get(
          '$_basePath/${project.name}/_apis/git/pullrequests?$_apiVersion&searchCriteria.status=${filter.name}$creatorFilter',
        ),
    ]);

    for (final res in allProjectPrs) {
      if (res.isError) return ApiResponse.error();
    }

    return ApiResponse.ok(
      allProjectPrs
          .map((e) => GetPullRequestsResponse.fromJson(jsonDecode(e.body) as Map<String, dynamic>).pullRequests)
          .expand((b) => b)
          .toList(),
    );
  }

  @override
  Future<ApiResponse<List<GitRepository>>> getProjectRepositories({required String projectName}) async {
    final repositoriesRes = await _get('$_basePath/$projectName/_apis/git/repositories?$_apiVersion');
    if (repositoriesRes.isError) return ApiResponse.error();

    return ApiResponse.ok(
      GetRepositoriesResponse.fromJson(jsonDecode(repositoriesRes.body) as Map<String, dynamic>).repositories,
    );
  }

  @override
  Future<ApiResponse<List<Pipeline>>> getProjectPipelines({
    required String projectName,
    required int top,
    required DateTime to,
  }) async {
    final topSearch = '&\$top=$top';
    final toSearch = '&maxTime=${to.toUtc().toIso8601String()}';
    final orderSearch = '&queryOrder=queueTimeDescending';

    final pipelinesRes =
        await _get('$_basePath/$projectName/_apis/build/builds?$_apiVersion$topSearch$toSearch$orderSearch');
    if (pipelinesRes.isError) return ApiResponse.error();

    return ApiResponse.ok(
      GetPipelineResponse.fromJson(jsonDecode(pipelinesRes.body) as Map<String, dynamic>).pipelines,
    );
  }

  @override
  Future<ApiResponse<List<TeamMember>>> getProjectTeams({required String projectId}) async {
    final teamsRes = await _get('$_basePath/_apis/teams?$_apiVersion-preview');
    if (teamsRes.isError) return ApiResponse.error();

    final teams = GetTeamsResponse.fromJson(jsonDecode(teamsRes.body) as Map<String, dynamic>).teams!;
    final team = teams.firstWhere((t) => t!.projectId == projectId || t.projectName == projectId)!;

    final membersRes = await _get('$_basePath/_apis/projects/$projectId/teams/${team.id}/members?$_apiVersion');
    if (membersRes.isError) return ApiResponse.error();

    return ApiResponse.ok(
      GetTeamMembersResponse.fromJson(jsonDecode(membersRes.body) as Map<String, dynamic>).members,
    );
  }

  @override
  Future<ApiResponse<List<PullRequest>>> getProjectPullRequests({required String projectName}) async {
    final prsRes = await _get('$_basePath/$projectName/_apis/git/pullrequests?$_apiVersion');
    if (prsRes.isError) return ApiResponse.error();

    return ApiResponse.ok(
      GetPullRequestsResponse.fromJson(jsonDecode(prsRes.body) as Map<String, dynamic>).pullRequests,
    );
  }

  @override
  Future<ApiResponse<PullRequest>> getPullRequest({required String projectName, required int id}) async {
    final prRes = await _get('$_basePath/$projectName/_apis/git/pullrequests/$id?$_apiVersion');
    if (prRes.isError) return ApiResponse.error();

    return ApiResponse.ok(PullRequest.fromJson(jsonDecode(prRes.body) as Map<String, dynamic>));
  }

  @override
  Future<ApiResponse<List<Commit>>> getRepositoryCommits({
    required String projectName,
    required String repoName,
    required int top,
    required int skip,
  }) async {
    final topSearch = '&searchCriteria.\$top=$top';
    final skipSearch = '&searchCriteria.\$skip=$skip';

    final commitsRes = await _get(
      '$_basePath/$projectName/_apis/git/repositories/$repoName/commits?$_apiVersion$topSearch$skipSearch',
    );
    if (commitsRes.isError) return ApiResponse.error();

    return ApiResponse.ok(
      GetCommitsResponse.fromJson(jsonDecode(commitsRes.body) as Map<String, dynamic>).commits.toList(),
    );
  }

  @override
  Future<ApiResponse<List<LanguageBreakdown>>> getProjectLanguages({required String projectName}) async {
    final langsRes = await _get(
      '$_basePath/$projectName/_apis/projectanalysis/languagemetrics',
    );

    if (langsRes.isError) return ApiResponse.error();

    return ApiResponse.ok(
      GetProjectLanguagesResponse.fromJson(jsonDecode(langsRes.body) as Map<String, dynamic>)
          .languageBreakdown
          .toList(),
    );
  }

  @override
  Future<ApiResponse<List<Pipeline>>> getRecentPipelines({
    PipelineResult result = PipelineResult.all,
    PipelineStatus status = PipelineStatus.all,
    String? triggeredBy,
  }) async {
    final orderSearch = '&queryOrder=queueTimeDescending';
    final resultSearch = '&resultFilter=${result.stringValue}';
    final statusSearch = result != PipelineResult.all ? '' : '&statusFilter=${status.stringValue}';
    final triggeredBySearch = triggeredBy == null ? '' : '&requestedFor=$triggeredBy';

    final queryParams = '$_apiVersion$orderSearch$resultSearch$statusSearch$triggeredBySearch';

    final allProjectPipelines = await Future.wait([
      for (final project in _chosenProjects ?? _projects)
        _get('$_basePath/${project.name}/_apis/build/builds?$queryParams'),
    ]);

    for (final res in allProjectPipelines) {
      if (res.isError) return ApiResponse.error();
    }

    final res = allProjectPipelines
        .map((e) => GetPipelineResponse.fromJson(jsonDecode(e.body) as Map<String, dynamic>).pipelines)
        .expand((b) => b)
        .toList();

    return ApiResponse.ok(res);
  }

  @override
  Future<ApiResponse<Pipeline>> getPipeline({required String projectName, required int id}) async {
    final pipelineRes = await _get('$_basePath/$projectName/_apis/build/builds/$id?$_apiVersion');

    if (pipelineRes.isError) return ApiResponse.error();

    final pipeline = Pipeline.fromJson(jsonDecode(pipelineRes.body) as Map<String, dynamic>);

    return ApiResponse.ok(pipeline);
  }

  @override
  Future<ApiResponse<List<Record>>> getPipelineTimeline({required String projectName, required int id}) async {
    final timelineRes = await _get('$_basePath/$projectName/_apis/build/builds/$id/timeline?$_apiVersion');
    if (timelineRes.isError) return ApiResponse.error();

    return ApiResponse.ok(GetTimelineResponse.fromRawJson(timelineRes.body).records);
  }

  @override
  Future<ApiResponse<String>> getPipelineTaskLogs({
    required String projectName,
    required int pipelineId,
    required int logId,
  }) async {
    final logsRes = await _get('$_basePath/$projectName/_apis/build/builds/$pipelineId/logs/$logId?$_apiVersion');
    if (logsRes.isError) return ApiResponse.error();

    return ApiResponse.ok(logsRes.body);
  }

  @override
  Future<ApiResponse<List<Commit>>> getRecentCommits({Project? project, String? author, int? maxCount}) async {
    final projectsToSearch = project != null ? [project] : (_chosenProjects ?? _projects);

    final allProjectRepos = await Future.wait([
      for (final project in projectsToSearch) _get('$_basePath/${project.name}/_apis/git/repositories?$_apiVersion'),
    ]);

    for (final res in allProjectRepos) {
      if (res.isError) return ApiResponse.error();
    }

    final repos = allProjectRepos
        .map((res) => GetRepositoriesResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).repositories)
        .expand((r) => r)
        .toList();

    final authorSearch = author != null ? '&searchCriteria.author=$author' : '';
    final topSearch = maxCount != null ? '&searchCriteria.\$top=$maxCount' : '';

    final allProjectCommits = await Future.wait([
      for (final repo in repos)
        _get(
          '$_basePath/${repo.project!.name}/_apis/git/repositories/${repo.name}/commits?$_apiVersion$authorSearch$topSearch',
        ),
    ]);

    for (final res in allProjectCommits) {
      if (res.isError) return ApiResponse.error();
    }

    final res = allProjectCommits
        .map((res) => GetCommitsResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).commits)
        .expand((c) => c)
        .toList();

    return ApiResponse.ok(res);
  }

  @override
  Future<ApiResponse<CommitDetail>> getCommitDetail({
    required String projectId,
    required String repositoryId,
    required String commitId,
  }) async {
    final commitDetail =
        await _get('$_basePath/$projectId/_apis/git/repositories/$repositoryId/commits/$commitId/changes?$_apiVersion');
    if (commitDetail.isError) return ApiResponse.error();

    return ApiResponse.ok(CommitDetail.fromJson(jsonDecode(commitDetail.body) as Map<String, dynamic>));
  }

  @override
  Future<ApiResponse<Pipeline>> cancelPipeline({required int buildId, required String projectId}) async {
    final cancelRes = await _patch(
      '$_basePath/$projectId/_apis/build/builds/$buildId?$_apiVersion',
      body: {'status': PipelineStatus.cancelling.stringValue},
    );
    if (cancelRes.isError) return ApiResponse.error();

    final res = Pipeline.fromJson(jsonDecode(cancelRes.body) as Map<String, dynamic>);
    return ApiResponse.ok(res);
  }

  @override
  Future<ApiResponse<Pipeline>> rerunPipeline({
    required int definitionId,
    required String projectId,
    required String branch,
  }) async {
    final rerunRes = await _post(
      '$_basePath/$projectId/_apis/build/builds?definitionId=$definitionId&$_apiVersion',
      body: {'sourceBranch': branch},
    );

    if (rerunRes.isError) return ApiResponse.error();

    final res = Pipeline.fromJson(jsonDecode(rerunRes.body) as Map<String, dynamic>);
    return ApiResponse.ok(res);
  }

  @override
  Future<ApiResponse<GraphUser>> getUserFromEmail({
    required String email,
  }) async {
    if (_allUsers.isEmpty) {
      await _getUsers();
    }

    return ApiResponse.ok(_allUsers.firstWhereOrNull((u) => u.mailAddress == email));
  }

  @override
  Future<ApiResponse<GraphUser>> getUserFromDescriptor({
    required String descriptor,
  }) async {
    if (_allUsers.isEmpty) {
      await _getUsers();
    }

    return ApiResponse.ok(_allUsers.firstWhereOrNull((u) => u.descriptor == descriptor));
  }

  Future<ApiResponse> _getUsers() async {
    final usersRes = await _get('$_usersBasePath/$_organization/_apis/graph/users?$_apiVersion-preview');
    if (usersRes.isError) return ApiResponse.error();

    _allUsers = GetUsersResponse.fromJson(jsonDecode(usersRes.body) as Map<String, dynamic>).users!;
    return ApiResponse.ok(_allUsers);
  }

  @override
  Future<void> logout() async {
    StorageServiceCore().clear();
    _organization = '';
    _chosenProjects = null;
    _allUsers.clear();
    dispose();
  }
}

class AzureApiServiceInherited extends InheritedWidget {
  const AzureApiServiceInherited({
    super.key,
    required super.child,
    required this.apiService,
  });

  final AzureApiService apiService;

  static AzureApiServiceInherited of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AzureApiServiceInherited>()!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

enum LoginStatus {
  ok,
  failed,
  orgNotSet,
  projectsNotSet,
  unauthorized,
}

class ApiResponse<T extends Object?> {
  ApiResponse({
    required this.isError,
    required this.data,
  });

  ApiResponse.ok(this.data) : isError = false;

  ApiResponse.error()
      : isError = true,
        data = null;

  final bool isError;
  final T? data;

  ApiResponse<T> copyWith({
    bool? isError,
    T? data,
  }) {
    return ApiResponse<T>(
      isError: isError ?? this.isError,
      data: data ?? this.data,
    );
  }
}
