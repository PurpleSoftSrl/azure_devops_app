// ignore_for_file: long-parameter-list

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:azure_devops/src/extensions/area_or_iteration_extension.dart';
import 'package:azure_devops/src/extensions/commit_extension.dart';
import 'package:azure_devops/src/extensions/reponse_extension.dart';
import 'package:azure_devops/src/extensions/work_item_update_extension.dart';
import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:azure_devops/src/models/areas_and_iterations.dart';
import 'package:azure_devops/src/models/commit.dart';
import 'package:azure_devops/src/models/commit_detail.dart';
import 'package:azure_devops/src/models/commits_tags.dart';
import 'package:azure_devops/src/models/file_diff.dart';
import 'package:azure_devops/src/models/identity_response.dart';
import 'package:azure_devops/src/models/organization.dart';
import 'package:azure_devops/src/models/pipeline.dart';
import 'package:azure_devops/src/models/processes.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/project_languages.dart';
import 'package:azure_devops/src/models/pull_request.dart';
import 'package:azure_devops/src/models/pull_request_policies.dart';
import 'package:azure_devops/src/models/pull_request_with_details.dart';
import 'package:azure_devops/src/models/repository.dart';
import 'package:azure_devops/src/models/repository_branches.dart';
import 'package:azure_devops/src/models/repository_items.dart';
import 'package:azure_devops/src/models/team.dart';
import 'package:azure_devops/src/models/team_member.dart' as t;
import 'package:azure_devops/src/models/timeline.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/models/user_entitlements.dart';
import 'package:azure_devops/src/models/work_item_comments.dart';
import 'package:azure_devops/src/models/work_item_fields.dart';
import 'package:azure_devops/src/models/work_item_type_rules.dart';
import 'package:azure_devops/src/models/work_item_type_with_transitions.dart';
import 'package:azure_devops/src/models/work_item_updates.dart';
import 'package:azure_devops/src/models/work_items.dart';
import 'package:azure_devops/src/services/msal_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:xml/xml.dart';

typedef WorkItemRule = ({ActionType action, List<Condition> conditions});

typedef WorkItemTypeRules = Map<String, List<WorkItemRule>>;

typedef LabeledWorkItemFields = Map<String, Set<WorkItemField>>;

abstract class AzureApiService {
  const AzureApiService();

  String get organization;

  UserMe? get user;

  Map<String, String>? get headers;

  String get basePath;

  List<GraphUser> get allUsers;

  /// Work item types for each project
  Map<String, List<WorkItemType>> get workItemTypes;

  /// Work item states for each work item type for each project
  Map<String, Map<String, List<WorkItemState>>> get workItemStates;

  /// Work item area paths for each project
  Map<String, List<AreaOrIteration>> get workItemAreas;

  /// Work item iteration paths for each project
  Map<String, List<AreaOrIteration>> get workItemIterations;

  bool get isImageUnauthorized;

  String getUserAvatarUrl(String userDescriptor);

  Future<LoginStatus> login(String accessToken);

  Future<void> setOrganization(String org);

  void switchOrganization(String org);

  Future<ApiResponse<List<Organization>>> getOrganizations();

  void setChosenProjects(List<Project> chosenProjects);

  Future<ApiResponse<List<Project>>> getProjects();

  Future<ApiResponse<ProjectDetail>> getProject({required String projectName});

  Future<ApiResponse<List<WorkItem>>> getWorkItems({
    Project? project,
    WorkItemType? type,
    WorkItemState? status,
    GraphUser? assignedTo,
    AreaOrIteration? area,
    AreaOrIteration? iteration,
  });

  Future<ApiResponse<List<WorkItem>>> getMyRecentWorkItems();

  Future<ApiResponse<Map<String, List<WorkItemType>>>> getWorkItemTypes({bool force = false});

  Future<ApiResponse<WorkItemFieldsWithRules>> getWorkItemTypeFields({
    required String projectName,
    required String workItemName,
  });

  Future<ApiResponse<WorkItemWithUpdates>> getWorkItemDetail({
    required String projectName,
    required int workItemId,
  });

  Future<ApiResponse<Uint8List>> getWorkItemAttachment({
    required String projectName,
    required String attachmentId,
    required String fileName,
  });

  Future<ApiResponse<WorkItem>> createWorkItem({
    required String projectName,
    required WorkItemType type,
    required GraphUser? assignedTo,
    required String title,
    required String description,
    AreaOrIteration? area,
    AreaOrIteration? iteration,
    required Map<String, String> formFields,
  });

  Future<ApiResponse<WorkItem>> editWorkItem({
    required String projectName,
    required int id,
    WorkItemType? type,
    GraphUser? assignedTo,
    String? title,
    String? description,
    String? state,
    AreaOrIteration? area,
    AreaOrIteration? iteration,
    required Map<String, String> formFields,
  });

  Future<ApiResponse<bool>> addWorkItemComment({
    required String projectName,
    required int id,
    required String text,
  });

  Future<ApiResponse<bool>> editWorkItemComment({
    required String projectName,
    required CommentItemUpdate update,
    required String text,
  });

  Future<ApiResponse<bool>> deleteWorkItemComment({
    required String projectName,
    required CommentItemUpdate update,
  });

  Future<ApiResponse<bool>> addWorkItemAttachment({
    required String projectName,
    required String fileName,
    required String filePath,
    required int workItemId,
  });

  Future<ApiResponse<bool>> deleteWorkItem({required String projectName, required int id, required String type});

  Future<ApiResponse<List<PullRequest>>> getPullRequests({
    required PullRequestState filter,
    GraphUser? creator,
    Project? project,
    GraphUser? reviewer,
  });

  Future<ApiResponse<List<GitRepository>>> getProjectRepositories({required String projectName});

  Future<ApiResponse<List<LanguageBreakdown>>> getProjectLanguages({required String projectName});

  Future<ApiResponse<List<RepoItem>>> getRepositoryItems({
    required String projectName,
    required String repoName,
    required String path,
    String? branch,
  });

  Future<ApiResponse<List<Branch>>> getRepositoryBranches({
    required String projectName,
    required String repoName,
  });

  Future<ApiResponse<FileDetailResponse>> getFileDetail({
    required String projectName,
    required String repoName,
    required String path,
    String? branch,
    String? commitId,
    bool previousChange,
  });

  Future<ApiResponse<List<Commit>>> getRecentCommits({Project? project, String? author, int? maxCount});

  Future<TagsData?> getTags(List<Commit> commits);

  Future<ApiResponse<CommitWithChanges>> getCommitDetail({
    required String projectId,
    required String repositoryId,
    required String commitId,
  });

  Future<ApiResponse<Diff>> getCommitDiff({
    required Commit commit,
    required String filePath,
    required bool isAdded,
    required bool isDeleted,
  });

  Future<ApiResponse<List<Pipeline>>> getRecentPipelines({
    Project? project,
    int? definition,
    PipelineResult result,
    PipelineStatus status,
    String? triggeredBy,
  });

  Future<ApiResponse<PipelineWithTimeline>> getPipeline({required String projectName, required int id});

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

  Future<ApiResponse<GraphUser>> getUserFromDisplayName({required String name});

  Future<ApiResponse<String>> getUserToMention({required String email});

  Future<ApiResponse<List<TeamWithMembers>>> getProjectTeams({required String projectId});

  Future<ApiResponse<PullRequestWithDetails>> getPullRequest({
    required String projectName,
    required String repositoryId,
    required int id,
  });

  Future<ApiResponse<Identity?>> getIdentityFromGuid({required String guid});

  Future<ApiResponse<bool>> votePullRequest({
    required String projectName,
    required String repositoryId,
    required int id,
    required Reviewer reviewer,
  });

  Future<ApiResponse<bool>> editPullRequest({
    required String projectName,
    required String repositoryId,
    required int id,
    PullRequestState? status,
    bool? isDraft,
    String? commitId,
    bool? autocomplete,
    PullRequestCompletionOptions? completionOptions,
  });

  Future<ApiResponse<bool>> editPullRequestThreadStatus({
    required String projectName,
    required String repositoryId,
    required int pullRequestId,
    required int threadId,
    required ThreadStatus status,
  });

  Future<ApiResponse<bool>> addPullRequestComment({
    required String projectName,
    required String repositoryId,
    required int pullRequestId,
    required String text,
    required int? threadId,
    required int? parentCommentId,
    String? filePath,
    int? lineNumber,
    int? lineLength,
    bool isRightFile,
  });

  Future<ApiResponse<bool>> editPullRequestComment({
    required String projectName,
    required String repositoryId,
    required int pullRequestId,
    required int threadId,
    required PrComment comment,
    required String text,
  });

  Future<ApiResponse<bool>> deletePullRequestComment({
    required String projectName,
    required String repositoryId,
    required int pullRequestId,
    required int threadId,
    required PrComment comment,
  });

  Future<void> logout();
}

class AzureApiServiceImpl with AppLogger implements AzureApiService {
  factory AzureApiServiceImpl() {
    return instance ??= AzureApiServiceImpl._();
  }

  AzureApiServiceImpl._();

  static AzureApiServiceImpl? instance;

  final _client = SentryHttpClient();

  @override
  String get organization => _organization;
  String _organization = '';

  String _accessToken = '';

  @override
  UserMe? get user => _user;
  UserMe? _user;

  @override
  String get basePath => _basePath;
  String get _basePath => 'https://dev.azure.com/$_organization';

  String get _usersBasePath => 'https://vssps.dev.azure.com';

  String get _apiVersion => 'api-version=7.0';

  @override
  List<GraphUser> get allUsers => _allUsers;
  List<GraphUser> _allUsers = [];

  @override
  bool get isImageUnauthorized => _isImageUnauthorized;
  bool _isImageUnauthorized = false;

  bool _isJwt = false;

  @override
  Map<String, String>? get headers => {
        'Content-Type': 'application/json',
        'Authorization': _isJwt ? 'Bearer $_accessToken' : 'Basic ${base64.encode(utf8.encode(':$_accessToken'))}',
      };

  List<Project> _projects = [];
  Iterable<Project>? _chosenProjects;

  StorageService get storageService => StorageServiceCore.instance!;

  @override
  Map<String, List<WorkItemType>> get workItemTypes => _workItemTypes;
  final Map<String, List<WorkItemType>> _workItemTypes = {};

  @override
  Map<String, Map<String, List<WorkItemState>>> get workItemStates => _workItemStates;
  final Map<String, Map<String, List<WorkItemState>>> _workItemStates = {};

  final Map<String, Map<String, WorkItemFieldsWithRules>> _workItemFields = {};

  @override
  Map<String, List<AreaOrIteration>> get workItemAreas => _workItemAreas;
  final Map<String, List<AreaOrIteration>> _workItemAreas = {};

  @override
  Map<String, List<AreaOrIteration>> get workItemIterations => _workItemIterations;
  final Map<String, List<AreaOrIteration>> _workItemIterations = {};

  static const _fieldNamesToSkip = [
    'System.Id',
    'System.Title',
    'System.State',
    'System.Reason',
    'System.AssignedTo',
    'System.AreaPath',
    'System.IterationPath',
    'Microsoft.VSTS.Common.ResolvedReason',
  ];

  void dispose() {
    instance = null;
  }

  @override
  String getUserAvatarUrl(String userDescriptor) {
    return '$_basePath/_apis/GraphProfile/MemberAvatars/$userDescriptor?size=large';
  }

  Future<Response> _get(String url) async {
    logDebug('GET $url');

    Future<Response> req() => _client.get(Uri.parse(url), headers: headers);
    var res = await req();
    res = await _checkExpiredToken(res, req);

    _logApiCall(url, 'GET', res, '');

    return res;
  }

  Future<Response> _patch(String url, {Map<String, Object>? body, String? contentType}) async {
    logDebug('PATCH $url');

    final realHeaders = contentType != null ? ({...headers!, 'Content-Type': contentType}) : headers!;
    Future<Response> req() => _client.patch(Uri.parse(url), headers: realHeaders, body: jsonEncode(body));
    var res = await req();
    res = await _checkExpiredToken(res, req);

    _logApiCall(url, 'PATCH', res, body);

    return res;
  }

  Future<Response> _patchList(String url, {List<Map<String, dynamic>>? body, String? contentType}) async {
    logDebug('PATCH $url');

    final realHeaders = contentType != null ? ({...headers!, 'Content-Type': contentType}) : headers!;
    Future<Response> req() => _client.patch(Uri.parse(url), headers: realHeaders, body: jsonEncode(body));
    var res = await req();
    res = await _checkExpiredToken(res, req);

    _logApiCall(url, 'PATCH', res, body);

    return res;
  }

  Future<Response> _post(String url, {Map<String, dynamic>? body, Object? bodyObject, String? contentType}) async {
    logDebug('POST $url');

    final realHeaders = contentType != null ? ({...headers!, 'Content-Type': contentType}) : headers!;
    Future<Response> req() => _client.post(Uri.parse(url), headers: realHeaders, body: bodyObject ?? jsonEncode(body));
    var res = await req();
    res = await _checkExpiredToken(res, req);

    _logApiCall(url, 'POST', res, body);

    return res;
  }

  Future<Response> _postList(String url, {List<Map<String, dynamic>>? body, String? contentType}) async {
    logDebug('POST $url');

    final realHeaders = contentType != null ? ({...headers!, 'Content-Type': contentType}) : headers!;
    Future<Response> req() => _client.post(Uri.parse(url), headers: realHeaders, body: jsonEncode(body));
    var res = await req();
    res = await _checkExpiredToken(res, req);

    _logApiCall(url, 'POST', res, body);

    return res;
  }

  Future<Response> _put(String url, {Map<String, dynamic>? body}) async {
    logDebug('PUT $url');

    Future<Response> req() => _client.put(Uri.parse(url), headers: headers, body: jsonEncode(body));
    var res = await req();
    res = await _checkExpiredToken(res, req);

    _logApiCall(url, 'PUT', res, body);

    return res;
  }

  Future<Response> _delete(String url) async {
    logDebug('DELETE $url');

    Future<Response> req() => _client.delete(Uri.parse(url), headers: headers);
    var res = await req();
    res = await _checkExpiredToken(res, req);

    _logApiCall(url, 'DELETE', res, '');

    return res;
  }

  // error debouncer
  static bool _isLoggingError = false;

  void _logApiCall(String url, String method, Response res, Object? body) {
    logDebug('$method $url ${res.statusCode} ${res.reasonPhrase} ${res.isError ? '- res body: ${res.body}' : ''}');

    if (res.isError && _user != null && ![401, 403].contains(res.statusCode)) {
      if (_isLoggingError) return;

      _isLoggingError = true;
      Timer(Duration(seconds: 2), () => _isLoggingError = false);

      final title = '${res.statusCode} ${res.reasonPhrase}';

      Sentry.captureEvent(
        SentryEvent(
          level: SentryLevel.warning,
          message: SentryMessage(
            title,
            template: 'Response body: %s, \n Request body: %s',
            params: [if (res.body.isNotEmpty) res.body, if (body != null && body != '') body],
          ),
        ),
      );
    }
  }

  Future<Response> _checkExpiredToken(Response res, Future<Response> Function() req) async {
    if (_isJwt && [203, 302].contains(res.statusCode)) {
      // refresh expired token
      final newToken = await MsalService().loginSilently();
      _accessToken = newToken ?? _accessToken;
      final retry = await req();
      logDebug('@@ retry: ${retry.statusCode}');
      return retry;
    }
    return res;
  }

  @override
  Future<LoginStatus> login(String accessToken) async {
    if (accessToken.isEmpty) return LoginStatus.unauthorized;

    _isJwt = accessToken.startsWith('ey') && accessToken.split('.').length == 3;

    final oldToken = _accessToken;

    _accessToken = accessToken;

    if (_isJwt) {
      final newToken = await MsalService().loginSilently();
      if (newToken != null) _accessToken = newToken;
    }

    var profileEndpoint = '$_usersBasePath/_apis/profile/profiles/me?$_apiVersion-preview';

    _organization = storageService.getOrganization();

    if (_organization.isNotEmpty) {
      profileEndpoint = '$_usersBasePath/$_organization/_apis/profile/profiles/me?$_apiVersion-preview';
    }

    final accountsRes = await _get(profileEndpoint);

    if ([HttpStatus.unauthorized, HttpStatus.nonAuthoritativeInformation].contains(accountsRes.statusCode)) {
      _accessToken = oldToken;
      await setOrganization('');
      return LoginStatus.unauthorized;
    }

    if (accountsRes.isError) {
      _accessToken = oldToken;
      await setOrganization('');
      return LoginStatus.failed;
    }

    storageService.setToken(accessToken);

    final user = UserMe.fromJson(jsonDecode(accountsRes.body) as Map<String, dynamic>);
    _user = user;

    _organization = storageService.getOrganization();

    if (_organization.isEmpty) {
      return LoginStatus.orgNotSet;
    }

    unawaited(_getUsers());

    _chosenProjects = storageService.getChosenProjects();

    if (_chosenProjects!.isEmpty) {
      return LoginStatus.projectsNotSet;
    }

    return LoginStatus.ok;
  }

  @override
  Future<void> setOrganization(String org) async {
    _organization = org.endsWith('/') ? org.substring(0, org.length - 1) : org;
    storageService.setOrganization(_organization);

    if (user != null) unawaited(_getUsers());
  }

  @override
  void switchOrganization(String org) {
    storageService.setOrganization(org);
    setChosenProjects([]);
    _workItemTypes.clear();
    _workItemStates.clear();
    _workItemAreas.clear();
    _workItemIterations.clear();
    _workItemFields.clear();
  }

  @override
  Future<ApiResponse<List<Organization>>> getOrganizations() async {
    final orgsRes =
        await _get('https://app.vssps.visualstudio.com/_apis/accounts?memberId=${user!.publicAlias}&$_apiVersion');

    if (orgsRes.isError) return ApiResponse.error(orgsRes);

    return ApiResponse.ok(GetOrganizationsResponse.fromResponse(orgsRes));
  }

  @override
  void setChosenProjects(List<Project> chosenProjects) {
    _chosenProjects = chosenProjects.toList();

    storageService.setChosenProjects(_chosenProjects!);
  }

  @override
  Future<ApiResponse<List<Project>>> getProjects() async {
    _chosenProjects = storageService.getChosenProjects();

    final projectsRes = await _get('$_basePath/_apis/projects?$_apiVersion&getDefaultTeamImageUrl=true');
    if (projectsRes.isError) return ApiResponse.error(projectsRes);

    _projects = GetProjectsResponse.fromResponse(projectsRes);

    // check if user is authorized to get images. This is done to avoid throwing many exceptions
    if (_projects.isNotEmpty) {
      final url = _projects.firstWhereOrNull((p) => p.defaultTeamImageUrl != null);
      if (url != null) {
        final imageRes = await _get(url.defaultTeamImageUrl!);
        if (imageRes.isError) _isImageUnauthorized = true;
      }
    }

    return ApiResponse.ok(_projects);
  }

  @override
  Future<ApiResponse<ProjectDetail>> getProject({required String projectName}) async {
    final projectRes = await _get('$_basePath/_apis/projects/$projectName?$_apiVersion');
    if (projectRes.isError) return ApiResponse.error(projectRes);

    final summaryRes = await _post(
      '$_basePath/_apis/Contribution/HierarchyQuery/project/$projectName?$_apiVersion-preview',
      body: _getContributionBody(projectName),
    );

    final lastWeek = DateTime.now().subtract(Duration(days: 7));
    final metricsRes = await _get(
      '$_basePath/$projectName/_apis/build/Metrics/Daily?minMetricsTime=${lastWeek.toIso8601String()}?$_apiVersion-preview',
    );

    final project = Project.fromResponse(projectRes);

    Gitmetrics? gitmetrics;
    WorkMetrics? workMetrics;
    if (!summaryRes.isError) {
      final summary = CommitsAndWorkItems.fromResponse(summaryRes);
      gitmetrics = summary.dataProviders.commitsSummary?.gitmetrics;
      workMetrics = summary.dataProviders.workItemsSummary?.workMetrics;
    }

    PipelinesMetrics? pipelinesMetrics;
    if (!metricsRes.isError) {
      pipelinesMetrics = _getMetricsFromResponse(metricsRes);
    }

    return ApiResponse.ok(
      ProjectDetail(
        project: project,
        gitmetrics: gitmetrics,
        workMetrics: workMetrics,
        pipelinesMetrics: pipelinesMetrics,
      ),
    );
  }

  Map<String, dynamic> _getContributionBody(String projectName) {
    return {
      'contributionIds': [
        'ms.vss-work-web.work-item-metrics-data-provider-verticals',
        'ms.vss-code-web.code-metrics-data-provider-verticals',
      ],
      'dataProviderContext': {
        'properties': {
          'numOfDays': 7,
          'sourcePage': {
            'routeValues': {'project': projectName},
          },
        },
      },
    };
  }

  PipelinesMetrics? _getMetricsFromResponse(Response res) {
    final metrics = PipelinesSummary.fromResponse(res).metrics;
    final total = metrics.where((m) => m.name == 'TotalBuilds').fold(0, (a, b) => a + b.intValue);
    final successful = metrics.where((m) => m.name == 'SuccessfulBuilds').fold(0, (a, b) => a + b.intValue);
    final partiallySuccessful =
        metrics.where((m) => m.name == 'PartiallySuccessfulBuilds').fold(0, (a, b) => a + b.intValue);
    final failed = metrics.where((m) => m.name == 'FailedBuilds').fold(0, (a, b) => a + b.intValue);
    final canceled = metrics.where((m) => m.name == 'CanceledBuilds').fold(0, (a, b) => a + b.intValue);

    return PipelinesMetrics(
      total: total,
      successful: successful,
      partiallySuccessful: partiallySuccessful,
      failed: failed,
      canceled: canceled,
    );
  }

  @override
  Future<ApiResponse<List<WorkItem>>> getWorkItems({
    Project? project,
    WorkItemType? type,
    WorkItemState? status,
    GraphUser? assignedTo,
    AreaOrIteration? area,
    AreaOrIteration? iteration,
  }) async {
    final query = <String>[];
    if (project != null) {
      query.add(" [System.TeamProject] = '${project.name}' ");
    } else {
      final projectsToSearch = (_chosenProjects ?? _projects).toList();

      if (projectsToSearch.length == 1) {
        query.add(" [System.TeamProject] = '${projectsToSearch.first.name}' ");
      } else {
        var projectsQuery = '';

        for (var i = 0; i < projectsToSearch.length; i++) {
          if (i == 0) {
            projectsQuery += " ( [System.TeamProject] = '${projectsToSearch[i].name}' OR ";
          } else if (i == projectsToSearch.length - 1) {
            projectsQuery += " [System.TeamProject] = '${projectsToSearch[i].name}' ) ";
          } else {
            projectsQuery += " [System.TeamProject] = '${projectsToSearch[i].name}' OR ";
          }
        }

        query.add(projectsQuery);
      }
    }

    if (type != null) query.add(" [System.WorkItemType] = '${type.name}' ");

    if (status != null) query.add(" [System.State] = '${status.name}' ");

    if (assignedTo != null) query.add(" [System.AssignedTo] = '${assignedTo.mailAddress}' ");

    if (area != null) {
      query.add(" [System.AreaPath] = '${area.escapedAreaPath}' ");
    }

    if (iteration != null) {
      query.add(" [System.IterationPath] = '${iteration.escapedIterationPath}' ");
    }

    var queryStr = '';
    if (query.isNotEmpty) {
      queryStr = query.join(' and ');
      queryStr = ' Where $queryStr ';
    }

    final workItemIdsRes = await _post(
      '$_basePath/_apis/wit/wiql?\$top=200&$_apiVersion',
      body: {'query': 'Select [System.Id] From WorkItems $queryStr Order By [System.ChangedDate] desc'},
    );
    if (workItemIdsRes.isError) return ApiResponse.error(workItemIdsRes);

    final workItemIds = GetWorkItemIds.fromResponse(workItemIdsRes);
    if (workItemIds.isEmpty) return ApiResponse.ok([]);

    final ids = workItemIds.map((e) => e.id).join(',');

    final allWorkItemsRes = await _get('$_basePath/_apis/wit/workitems?ids=$ids&$_apiVersion');

    if (allWorkItemsRes.isError) return ApiResponse.error(allWorkItemsRes);

    return ApiResponse.ok(GetWorkItemsResponse.fromResponse(allWorkItemsRes));
  }

  @override
  Future<ApiResponse<List<WorkItem>>> getMyRecentWorkItems() async {
    const myQueryStr = ' Where [System.ChangedDate] = @today AND [System.ChangedBy] = @Me ';
    final myWorkItemIdsRes = await _post(
      '$_basePath/_apis/wit/wiql?\$top=200&$_apiVersion',
      body: {'query': 'Select [System.Id] From WorkItems $myQueryStr Order By [System.ChangedDate] desc'},
    );
    if (myWorkItemIdsRes.isError) return ApiResponse.error(myWorkItemIdsRes);

    final workItemIds = GetWorkItemIds.fromResponse(myWorkItemIdsRes);
    if (workItemIds.isEmpty) return ApiResponse.ok([]);

    final ids = workItemIds.map((e) => e.id).join(',');

    final myWorkItemsRes = await _get('$_basePath/_apis/wit/workitems?ids=$ids&$_apiVersion');
    if (myWorkItemsRes.isError) return ApiResponse.error(myWorkItemsRes);

    return ApiResponse.ok(GetWorkItemsResponse.fromResponse(myWorkItemsRes));
  }

  @override
  // ignore: long-method
  Future<ApiResponse<Map<String, List<WorkItemType>>>> getWorkItemTypes({bool force = false}) async {
    if (_workItemTypes.isNotEmpty && !force) {
      // return cached types to avoid too many api calls
      return ApiResponse.ok(_workItemTypes);
    }

    if (force) {
      _workItemTypes.clear();
      _workItemStates.clear();
      _workItemAreas.clear();
      _workItemIterations.clear();
    }

    final processesRes = await _get('$_basePath/_apis/work/processes?\$expand=projects&$_apiVersion');
    if (processesRes.isError) return ApiResponse.error(processesRes);

    final processes = GetProcessesResponse.fromResponse(processesRes).where((p) => p.projects.isNotEmpty).toList();

    final processWorkItems = <WorkProcess, List<WorkItemType>>{};

    await Future.wait([
      for (final proc in processes)
        _get('$_basePath/_apis/work/processes/${proc.typeId}/workItemTypes?\$expand=states&$_apiVersion').then(
          (res) {
            if (res.isError) return;

            final types = GetWorkItemTypesResponse.fromResponse(res).where((t) => !t.isDisabled).toList();
            final projectsToSearch = proc.projects.where((p) => (_chosenProjects ?? _projects).contains(p));
            for (final proj in projectsToSearch) {
              if (_workItemAreas[proj.name!] == null) {
                // ignore: unawaited_futures, reason: speed up work items page loading time
                _get('$_basePath/${proj.name}/_apis/wit/classificationnodes?\$depth=14&$_apiVersion').then((areaRes) {
                  final areasAndIterations = AreasAndIterationsResponse.fromResponse(areaRes);

                  _workItemAreas.putIfAbsent(
                    proj.name!,
                    () => areasAndIterations.areasAndIterations.where((i) => i.structureType == 'area').toList(),
                  );
                  _workItemIterations.putIfAbsent(
                    proj.name!,
                    () => areasAndIterations.areasAndIterations.where((i) => i.structureType == 'iteration').toList(),
                  );
                });
              }

              _workItemTypes.putIfAbsent(proj.name!, () => types);
              processWorkItems.putIfAbsent(proc, () => types);

              for (final wt in types) {
                final states = wt.states;
                _workItemStates.putIfAbsent(proj.name!, () => {wt.name: states});
                _workItemStates[proj.name]!.putIfAbsent(wt.name, () => states);
              }
            }
          },
        ),
    ]);

    return ApiResponse.ok(_workItemTypes);
  }

  @override
  Future<ApiResponse<WorkItemFieldsWithRules>> getWorkItemTypeFields({
    required String projectName,
    required String workItemName,
  }) async {
    final cachedFields = _workItemFields[projectName]?[workItemName];
    if (cachedFields != null) return ApiResponse.ok(cachedFields);

    final wtBasePath = '$_basePath/$projectName/_apis/wit/workItemTypes/$workItemName';

    // get xmlForm with all visible fields
    final typeRes = await _get('$wtBasePath?\$expand=allowedValues&$_apiVersion-preview');
    if (typeRes.isError) return ApiResponse.error(null);

    final typeWithTransitions = WorkItemTypeWithTransitions.fromResponse(typeRes);
    var refName = typeWithTransitions.referenceName;

    if (typeWithTransitions.xmlForm.isEmpty || refName.isEmpty) return ApiResponse.error(null);

    final visibleFields = _parseXmlForm(typeWithTransitions.xmlForm);

    // get all fields with more info (previous call doesn't return allowedValues)
    final fieldsRes = await _get('$wtBasePath/fields?\$expand=allowedValues&$_apiVersion-preview');
    if (fieldsRes.isError) return ApiResponse.error(null);

    final allFields = WorkItemTypeFieldsResponse.fromResponse(fieldsRes);

    final fields = _matchFields(visibleFields, allFields);

    final processesPath = '$_basePath/_apis/work/processes';

    final processesRes = await _get('$processesPath?\$expand=projects&$_apiVersion');
    if (processesRes.isError) return ApiResponse.error(null);

    final processes = GetProcessesResponse.fromResponse(processesRes).where((p) => p.projects.isNotEmpty).toList();
    final projectProcess = processes.firstWhere((p) => p.projects.any((proj) => proj.name == projectName));

    final isInheritedProcess = projectProcess.customizationType == 'inherited';
    if (isInheritedProcess) {
      final type = _workItemTypes[projectName]?.firstWhereOrNull((t) => t.name == workItemName);
      final isInheritedType = type?.customization == 'inherited';

      if (isInheritedType) {
        // inherited types have a different name format
        refName = '${projectProcess.name}.${workItemName.replaceAll(' ', '')}';
      }
    }

    // get all fields with more info (previous call doesn't return field data type)
    final processTypesRes = await _get(
      '$processesPath/${projectProcess.typeId}/workItemTypes/$refName/fields?$_apiVersion',
    );
    if (processTypesRes.isError) return ApiResponse.error(null);

    final processFields = WorkItemTypeFieldsResponse.fromResponse(processTypesRes);

    for (final entry in fields.entries) {
      for (final field in entry.value) {
        final processField = processFields.firstWhere((f) => f.referenceName == field.referenceName);
        field.type = processField.type;
      }
    }

    final fieldNames = fields.values.expand((f) => f).map((f) => f.referenceName);

    final rules = await _getWorkItemTypeRules(projectProcess, refName, fieldNames);

    final fieldsWithRules = WorkItemFieldsWithRules(
      fields: fields,
      rules: rules,
      transitions: typeWithTransitions.transitions,
    );

    _workItemFields.putIfAbsent(projectName, () => {workItemName: fieldsWithRules});
    _workItemFields[projectName]!.putIfAbsent(workItemName, () => fieldsWithRules);

    return ApiResponse.ok(fieldsWithRules);
  }

  Future<WorkItemTypeRules> _getWorkItemTypeRules(
    WorkProcess projectProcess,
    String refName,
    Iterable<String> fieldNames,
  ) async {
    final rulesRes = await _get(
      '$_basePath/_apis/work/processes/${projectProcess.typeId}/workItemTypes/$refName/rules?$_apiVersion',
    );

    final rules = WorkItemTypeRulesResponse.fromResponse(rulesRes).rules;

    final mappedRules = <String, List<WorkItemRule>>{};

    for (final r in rules.where((r) => r.conditions.isNotEmpty)) {
      final conditions = r.conditions;
      final actions = r.actions;

      final isVisibleField = actions.any((a) => fieldNames.contains(a.targetField));
      final isSupportedAction = actions.any((a) => !_fieldNamesToSkip.contains(a.targetField));

      for (final action in actions) {
        if (isVisibleField && isSupportedAction) {
          mappedRules.putIfAbsent(action.targetField, () => []);
          mappedRules[action.targetField]!.add((action: action.actionType, conditions: conditions));
        }
      }
    }

    return mappedRules;
  }

  @override
  Future<ApiResponse<WorkItemWithUpdates>> getWorkItemDetail({
    required String projectName,
    required int workItemId,
  }) async {
    final workItemPath = '$_basePath/$projectName/_apis/wit/workitems/$workItemId';
    final workItemRes = await _get('$workItemPath?$_apiVersion');
    if (workItemRes.isError) return ApiResponse.error(workItemRes);

    final updatesRes = await _get('$workItemPath/updates?$_apiVersion');
    if (updatesRes.isError) return ApiResponse.error(updatesRes);

    final commentsRes = await _get('$workItemPath/comments?$_apiVersion-preview');
    if (commentsRes.isError) return ApiResponse.error(commentsRes);

    final item = WorkItem.fromResponse(workItemRes);
    final updates = WorkItemUpdatesResponse.fromResponse(updatesRes);
    final comments = WorkItemCommentRes.fromResponse(commentsRes).comments;

    final itemUpdates = [
      ...comments.map(
        (c) => CommentItemUpdate(
          updateDate: c.createdDate,
          updatedBy: UpdateUser(descriptor: c.createdBy.descriptor, displayName: c.createdBy.displayName),
          id: c.id,
          workItemId: c.workItemId,
          text: c.text,
          isEdited: c.createdDate.isBefore(c.modifiedDate),
        ),
      ),
      ...updates.where((u) => u.hasSupportedChanges).map(
            (u) => SimpleItemUpdate(
              updateDate: u.fields?.systemChangedDate?.newValue == null
                  ? u.revisedDate
                  : DateTime.parse(u.fields!.systemChangedDate!.newValue!),
              updatedBy: UpdateUser(
                descriptor: u.revisedBy.descriptor ?? '',
                displayName: u.revisedBy.displayName ?? '',
              ),
              isFirst: u.rev == 1,
              type: u.fields?.systemWorkItemType,
              state: u.fields?.systemState,
              assignedTo: u.fields?.systemAssignedTo,
              effort: u.fields?.microsoftVstsSchedulingEffort,
              title: u.fields?.systemTitle,
              relations: u.relations,
            ),
          ),
    ]..sort((a, b) {
        final dateCompare = a.updateDate.compareTo(b.updateDate);
        if (dateCompare == 0) return a is SimpleItemUpdate ? -1 : 1;
        return dateCompare;
      });

    return ApiResponse.ok(WorkItemWithUpdates(item: item, updates: itemUpdates));
  }

  @override
  Future<ApiResponse<Uint8List>> getWorkItemAttachment({
    required String projectName,
    required String attachmentId,
    required String fileName,
  }) async {
    final attachmentRes =
        await _get('$_basePath/$projectName/_apis/wit/attachments/$attachmentId?fileName=$fileName&$_apiVersion');
    if (attachmentRes.isError) return ApiResponse.error(attachmentRes);

    return ApiResponse.ok(attachmentRes.bodyBytes);
  }

  @override
  Future<ApiResponse<WorkItem>> createWorkItem({
    required String projectName,
    required WorkItemType type,
    required GraphUser? assignedTo,
    required String title,
    required String description,
    AreaOrIteration? area,
    AreaOrIteration? iteration,
    required Map<String, String> formFields,
  }) async {
    final createRes = await _postList(
      '$_basePath/$projectName/_apis/wit/workitems/\$${type.name}?$_apiVersion-preview',
      body: [
        {
          'op': 'add',
          'value': title,
          'path': '/fields/System.Title',
        },
        if (assignedTo != null)
          {
            'op': 'add',
            'value': assignedTo.mailAddress,
            'path': '/fields/System.AssignedTo',
          },
        if (area != null)
          {
            'op': 'add',
            'path': '/fields/System.AreaPath',
            'value': area.escapedAreaPath,
          },
        if (iteration != null)
          {
            'op': 'add',
            'path': '/fields/System.IterationPath',
            'value': iteration.escapedIterationPath,
          },
        for (final field in formFields.entries)
          {
            'op': 'add',
            'path': '/fields/${field.key}',
            'value': field.value,
          },
      ],
      contentType: 'application/json-patch+json',
    );

    if (createRes.isError) return ApiResponse.error(createRes);

    return ApiResponse.ok(WorkItem.fromResponse(createRes));
  }

  @override
  Future<ApiResponse<WorkItem>> editWorkItem({
    required String projectName,
    required int id,
    WorkItemType? type,
    GraphUser? assignedTo,
    String? title,
    String? description,
    String? state,
    AreaOrIteration? area,
    AreaOrIteration? iteration,
    required Map<String, String> formFields,
  }) async {
    final editRes = await _patchList(
      '$_basePath/$projectName/_apis/wit/workitems/$id?$_apiVersion-preview',
      body: [
        if (title != null)
          {
            'op': 'replace',
            'value': title,
            'path': '/fields/System.Title',
          },
        if (assignedTo != null)
          {
            'op': 'replace',
            'value': assignedTo.mailAddress,
            'path': '/fields/System.AssignedTo',
          },
        if (type != null)
          {
            'op': 'replace',
            'value': type.name,
            'path': '/fields/System.WorkItemType',
          },
        if (state != null)
          {
            'op': 'replace',
            'value': state,
            'path': '/fields/System.State',
          },
        if (area != null)
          {
            'op': 'replace',
            'path': '/fields/System.AreaPath',
            'value': area.escapedAreaPath,
          },
        if (iteration != null)
          {
            'op': 'replace',
            'path': '/fields/System.IterationPath',
            'value': iteration.escapedIterationPath,
          },
        for (final field in formFields.entries)
          {
            'op': 'add',
            'path': '/fields/${field.key}',
            'value': field.value,
          },
      ],
      contentType: 'application/json-patch+json',
    );

    if (editRes.isError) return ApiResponse.error(editRes);

    return ApiResponse.ok(WorkItem.fromResponse(editRes));
  }

  @override
  Future<ApiResponse<bool>> addWorkItemComment({
    required String projectName,
    required int id,
    required String text,
  }) async {
    final commentRes = await _post(
      '$_basePath/$projectName/_apis/wit/workItems/$id/comments?format=html&$_apiVersion-preview',
      body: {'text': text},
    );
    if (commentRes.isError) return ApiResponse.error(commentRes);

    return ApiResponse.ok(true);
  }

  @override
  Future<ApiResponse<bool>> editWorkItemComment({
    required String projectName,
    required CommentItemUpdate update,
    required String text,
  }) async {
    final editRes = await _patch(
      '$_basePath/$projectName/_apis/wit/workItems/${update.workItemId}/comments/${update.id}?$_apiVersion-preview',
      body: {'text': text},
    );
    if (editRes.isError) return ApiResponse.error(editRes);

    return ApiResponse.ok(true);
  }

  @override
  Future<ApiResponse<bool>> deleteWorkItemComment({
    required String projectName,
    required CommentItemUpdate update,
  }) async {
    final deleteRes = await _delete(
      '$_basePath/$projectName/_apis/wit/workItems/${update.workItemId}/comments/${update.id}?$_apiVersion-preview',
    );
    if (deleteRes.isError) return ApiResponse.error(deleteRes);

    return ApiResponse.ok(true);
  }

  @override
  Future<ApiResponse<bool>> addWorkItemAttachment({
    required String projectName,
    required String fileName,
    required String filePath,
    required int workItemId,
  }) async {
    final response = await _post(
      '$_basePath/$projectName/_apis/wit/attachments?fileName=$fileName&uploadType=simple&$_apiVersion',
      bodyObject: await File(filePath).readAsBytes(),
      contentType: 'application/octet-stream',
    );
    if (response.isError) return ApiResponse.error(null);

    final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

    final commentRes = await _patchList(
      '$_basePath/$projectName/_apis/wit/workitems/$workItemId?$_apiVersion',
      contentType: 'application/json-patch+json',
      body: [
        {
          'op': 'add',
          'path': '/relations/-',
          'value': {
            'rel': 'AttachedFile',
            'url': decodedResponse['url'],
          },
        },
      ],
    );
    if (commentRes.isError) return ApiResponse.error(commentRes);

    return ApiResponse.ok(true);
  }

  @override
  Future<ApiResponse<bool>> deleteWorkItem({required String projectName, required int id, required String type}) async {
    if (type == 'Test Case') {
      // Test Case work items need special handling
      final testCaseRes = await _delete('$_basePath/$projectName/_apis/test/testcases/$id?$_apiVersion');
      if (testCaseRes.isError) return ApiResponse.error(testCaseRes);
    } else {
      final deleteRes = await _delete('$_basePath/$projectName/_apis/wit/workitems/$id?$_apiVersion');
      if (deleteRes.isError) return ApiResponse.error(deleteRes);
    }

    return ApiResponse.ok(true);
  }

  @override
  Future<ApiResponse<List<PullRequest>>> getPullRequests({
    required PullRequestState filter,
    GraphUser? creator,
    Project? project,
    GraphUser? reviewer,
  }) async {
    var creatorFilter = '';
    if (creator != null) {
      final creatorSearch = "&\$filter=name eq '${creator.mailAddress}'";
      final entitlementRes =
          await _get('https://vsaex.dev.azure.com/$_organization/_apis/userentitlements?$_apiVersion$creatorSearch');
      if (entitlementRes.isError) return ApiResponse.error(entitlementRes);

      final member = GetUserEntitlementsResponse.fromResponse(entitlementRes).firstOrNull;
      if (member == null) return ApiResponse.error(null);

      creatorFilter = '&searchCriteria.creatorId=${member.id}';
    }

    var reviewerFilter = '';
    if (reviewer != null) {
      final reviewerIdentity = await getUserToMention(email: reviewer.mailAddress!);
      reviewerFilter = '&searchCriteria.reviewerId=${reviewerIdentity.data}';
    }

    final projectsToSearch = project != null ? [project] : (_chosenProjects ?? _projects);

    final allProjectPrs = await Future.wait([
      for (final project in projectsToSearch)
        _get(
          '$_basePath/${project.name}/_apis/git/pullrequests?$_apiVersion&searchCriteria.status=${filter.name}$creatorFilter$reviewerFilter',
        ),
    ]);

    var isAllError = true;

    for (final res in allProjectPrs) {
      isAllError &= res.isError;
    }

    if (isAllError) return ApiResponse.error(allProjectPrs.firstOrNull);

    return ApiResponse.ok(
      allProjectPrs.where((r) => !r.isError).map(GetPullRequestsResponse.fromResponse).expand((b) => b).toList(),
    );
  }

  @override
  Future<ApiResponse<List<GitRepository>>> getProjectRepositories({required String projectName}) async {
    final repositoriesRes = await _get('$_basePath/$projectName/_apis/git/repositories?$_apiVersion');
    if (repositoriesRes.isError) return ApiResponse.error(repositoriesRes);

    return ApiResponse.ok(GetRepositoriesResponse.fromResponse(repositoriesRes));
  }

  @override
  Future<ApiResponse<List<TeamWithMembers>>> getProjectTeams({required String projectId}) async {
    final teamsRes = await _get('$_basePath/_apis/projects/$projectId/teams?$_apiVersion-preview');
    if (teamsRes.isError) return ApiResponse.error(teamsRes);

    final teams = GetTeamsResponse.fromResponse(teamsRes);

    if (teams.isEmpty) return ApiResponse.error(teamsRes);

    final teamsWithMembers = <TeamWithMembers>[];

    for (final team in teams) {
      final membersRes = await _get('$_basePath/_apis/projects/$projectId/teams/${team!.id}/members?$_apiVersion');
      if (membersRes.isError) return ApiResponse.error(membersRes);

      final members = t.GetTeamMembersResponse.fromResponse(membersRes)!;
      teamsWithMembers.add((team: team, members: members));
    }

    return ApiResponse.ok(teamsWithMembers);
  }

  @override
  // ignore: long-method
  Future<ApiResponse<PullRequestWithDetails>> getPullRequest({
    required String projectName,
    required String repositoryId,
    required int id,
  }) async {
    final prPath = '$_basePath/$projectName/_apis/git/repositories/$repositoryId/pullrequests/$id';

    final prRes = await _get('$prPath?$_apiVersion');
    if (prRes.isError) return ApiResponse.error(prRes);

    final pr = PullRequest.fromResponse(prRes);

    final artifactId = 'vstfs:///CodeReview/CodeReviewId/${pr.repository.project.id}/${pr.pullRequestId}';
    final policiesRes = await _get(
      '$_basePath/$projectName/_apis/policy/evaluations?artifactId=$artifactId&$_apiVersion-preview',
    );
    final policies = policiesRes.isError ? <Policy>[] : PoliciesResponse.fromResponse(policiesRes).policies;

    final conflicts = <Conflict>[];
    if (pr.mergeStatus == 'conflicts') {
      final conflictsRes = await _get('$prPath/conflicts?excludeResolved=true&$_apiVersion');
      if (!conflictsRes.isError) conflicts.addAll(ConflictsResponse.fromResponse(conflictsRes).conflicts);
    }

    final allChanges = <CommitWithChangeEntry>[];
    final iterationsRes = await _get('$prPath/iterations?includeCommits=true&$_apiVersion');

    final iterations = <Iteration>[];
    if (!iterationsRes.isError) {
      iterations.addAll(IterationsRes.fromResponse(iterationsRes).iterations);
      await Future.wait([
        for (final iteration in iterations)
          _get('$prPath/iterations/${iteration.id}/changes?$_apiVersion').then((changesRes) {
            if (changesRes.isError) return;

            final changes = ChangesRes.fromResponse(changesRes).changes;
            allChanges.add(CommitWithChangeEntry(changes: changes, iteration: iteration));
          }),
      ]);
    }

    var threads = <Thread>[];
    final threadsRes = await _get('$prPath/threads?$_apiVersion');
    if (!threadsRes.isError) {
      threads = ThreadsRes.fromResponse(threadsRes).threads.where((t) => !t.isDeleted).toList();
    }

    final voteUpdates = threads.where((t) => t.properties?.type?.value == 'VoteUpdate');
    final statusUpdates = threads.where((t) => t.properties?.type?.value == 'StatusUpdate');
    final otherUpdates =
        threads.where((t) => !['VoteUpdate', 'StatusUpdate', 'RefUpdate'].contains(t.properties?.type?.value));

    final threadUpdates = <ThreadUpdate>[];

    final threadsWithComments = threads.where((t) => t.comments.any((c) => c.commentType == 'text'));

    for (final t in threadsWithComments) {
      final textComments = t.comments.where((c) => c.commentType == 'text');
      final firstComment = textComments.first;
      threadUpdates.add(
        ThreadUpdate(
          id: t.id,
          date: firstComment.publishedDate,
          content: firstComment.content,
          author: firstComment.author,
          identity: t.identities?.entries.firstOrNull?.value,
          comments: textComments.toList(),
          threadContext: t.threadContext,
          status: t.status,
        ),
      );
    }

    final updates = [
      ...threadUpdates,
      ...iterations.map(
        (u) => IterationUpdate(
          date: u.createdDate,
          id: u.id,
          commits: u.commits ?? [],
          author: u.author,
          content: u.description,
        ),
      ),
      ...voteUpdates.map(
        (u) => VoteUpdate(
          date: u.publishedDate,
          content: u.comments.first.content,
          author: u.comments.first.author,
          identity: u.identities?.entries.firstOrNull?.value,
        ),
      ),
      ...statusUpdates.map(
        (u) => StatusUpdate(
          date: u.publishedDate,
          author: u.comments.first.author,
          identity: u.identities?.entries.firstOrNull?.value,
          content: u.comments.first.content,
        ),
      ),
      for (final t in otherUpdates)
        for (final c in t.comments.where((c) => c.commentType == 'system'))
          SystemUpdate(
            date: c.publishedDate,
            content: c.content,
            author: c.author,
            identity: t.identities?.entries.firstOrNull?.value,
          ),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return ApiResponse.ok(
      PullRequestWithDetails(
        pr: pr,
        changes: allChanges,
        updates: updates,
        conflicts: conflicts,
        policies: policies,
      ),
    );
  }

  @override
  Future<ApiResponse<Identity?>> getIdentityFromGuid({required String guid}) async {
    final identityRes = await _post(
      '$_basePath/_apis/IdentityPicker/Identities?$_apiVersion-preview',
      body: {
        'query': guid,
        'identityTypes': ['user'],
        'operationScopes': ['ims', 'source'],
        'queryTypeHint': 'uid',
        'options': {'MinResults': 1, 'MaxResults': 1},
        'properties': ['DisplayName', 'Mail'],
      },
    );

    if (identityRes.isError) return ApiResponse.error(null);

    final res = IdentityResponse.fromResponse(identityRes).firstOrNull;
    final identity = res?.identities.firstOrNull?..guid = res?.queryToken;
    return ApiResponse.ok(identity);
  }

  @override
  Future<ApiResponse<bool>> votePullRequest({
    required String projectName,
    required String repositoryId,
    required int id,
    required Reviewer reviewer,
  }) async {
    final identity = await _get(
      '$_usersBasePath/$_organization/_apis/identities?searchFilter=General&filterValue=${user!.emailAddress}&$_apiVersion',
    );
    if (identity.isError) return ApiResponse.error(null);

    final reviewerId = UserIdentity.fromResponse(identity).id;
    if (reviewerId == null) return ApiResponse.error(null);

    final reviewerPath =
        '$_basePath/$projectName/_apis/git/repositories/$repositoryId/pullrequests/$id/reviewers/$reviewerId?$_apiVersion';

    final voteRes = await _put(reviewerPath, body: reviewer.copyWith(id: reviewerId).toMap());
    if (voteRes.isError) return ApiResponse.error(voteRes);

    return ApiResponse.ok(true);
  }

  @override
  Future<ApiResponse<bool>> editPullRequest({
    required String projectName,
    required String repositoryId,
    required int id,
    PullRequestState? status,
    bool? isDraft,
    String? commitId,
    bool? autocomplete,
    PullRequestCompletionOptions? completionOptions,
  }) async {
    String? reviewerId;

    final isSettingAutocomplete = autocomplete != null && autocomplete;

    if (isSettingAutocomplete) {
      final identity = await _get(
        '$_usersBasePath/$_organization/_apis/identities?searchFilter=General&filterValue=${user!.emailAddress}&$_apiVersion',
      );
      if (identity.isError) return ApiResponse.error(null);

      reviewerId = UserIdentity.fromResponse(identity).id;
    }
    final prPath = '$_basePath/$projectName/_apis/git/repositories/$repositoryId/pullrequests/$id?$_apiVersion';

    final editRes = await _patch(
      prPath,
      body: {
        if (isDraft != null) 'isDraft': isDraft,
        if (status != null) 'status': status.name,
        if (status == PullRequestState.completed) 'lastMergeSourceCommit': {'commitId': commitId},
        if (autocomplete != null)
          'autoCompleteSetBy': {
            'id': autocomplete ? reviewerId : '00000000-0000-0000-0000-000000000000',
          },
        if (status == PullRequestState.completed || isSettingAutocomplete)
          'completionOptions': {
            'deleteSourceBranch': completionOptions!.deleteSourceBranch,
            'mergeCommitMessage': completionOptions.commitMessage,
            'mergeStrategy': completionOptions.mergeType,
            'transitionWorkItems': completionOptions.completeWorkItems,
          },
      },
    );
    if (editRes.isError) return ApiResponse.error(editRes);

    return ApiResponse.ok(true);
  }

  @override
  Future<ApiResponse<bool>> editPullRequestThreadStatus({
    required String projectName,
    required String repositoryId,
    required int threadId,
    required int pullRequestId,
    required ThreadStatus status,
  }) async {
    final res = await _patch(
      '$_basePath/_apis/git/repositories/$repositoryId/pullRequests/$pullRequestId/threads/$threadId?$_apiVersion',
      body: {'status': status.intValue},
    );

    if (res.isError) return ApiResponse.error(res);

    return ApiResponse.ok(true);
  }

  @override
  Future<ApiResponse<bool>> addPullRequestComment({
    required String projectName,
    required String repositoryId,
    required int? threadId,
    required int pullRequestId,
    required String text,
    required int? parentCommentId,
    String? filePath,
    int? lineNumber,
    int? lineLength,
    bool isRightFile = false,
  }) async {
    final threadsPath = '$_basePath/_apis/git/repositories/$repositoryId/pullRequests/$pullRequestId/threads';

    final prPath = threadId == null ? '$threadsPath?$_apiVersion' : '$threadsPath/$threadId/comments?$_apiVersion';

    final commentBody = {
      'content': text,
      'commentType': 1,
      if (parentCommentId != null) 'parentCommentId': parentCommentId,
    };

    final fileStart = isRightFile ? 'rightFileStart' : 'leftFileStart';
    final fileEnd = isRightFile ? 'rightFileEnd' : 'leftFileEnd';

    final createRes = await _post(
      prPath,
      body: threadId == null
          ? {
              'comments': [commentBody],
              if (filePath != null)
                'threadContext': {
                  'filePath': filePath,
                  fileStart: {'line': lineNumber, 'offset': 1},
                  fileEnd: {'line': lineNumber, 'offset': lineLength},
                },
            }
          : commentBody,
    );

    if (createRes.isError) return ApiResponse.error(createRes);

    return ApiResponse.ok(true);
  }

  @override
  Future<ApiResponse<bool>> editPullRequestComment({
    required String projectName,
    required String repositoryId,
    required int pullRequestId,
    required int threadId,
    required PrComment comment,
    required String text,
  }) async {
    final prPath =
        '$_basePath/_apis/git/repositories/$repositoryId/pullRequests/$pullRequestId/threads/$threadId/comments/${comment.id}?$_apiVersion';

    final commentBody = {
      'content': text,
      'commentType': 1,
    };

    final res = await _patch(
      prPath,
      body: commentBody,
    );

    if (res.isError) return ApiResponse.error(res);

    return ApiResponse.ok(true);
  }

  @override
  Future<ApiResponse<bool>> deletePullRequestComment({
    required String projectName,
    required String repositoryId,
    required int pullRequestId,
    required int threadId,
    required PrComment comment,
  }) async {
    final prPath =
        '$_basePath/_apis/git/repositories/$repositoryId/pullRequests/$pullRequestId/threads/$threadId/comments/${comment.id}?$_apiVersion';

    final res = await _delete(prPath);

    if (res.isError) return ApiResponse.error(res);

    return ApiResponse.ok(true);
  }

  @override
  Future<ApiResponse<List<RepoItem>>> getRepositoryItems({
    required String projectName,
    required String repoName,
    required String path,
    String? branch,
  }) async {
    var branchQuery = '';

    if (branch != null) {
      final encodedBranch = Uri.encodeQueryComponent(branch);
      branchQuery = 'versionDescriptor.version=$encodedBranch&versionDescriptor.versionType=branch&';
    }

    final encodedPath = Uri.encodeQueryComponent(path);
    final itemsRes = await _get(
      '$_basePath/$projectName/_apis/git/repositories/$repoName/items?scopePath=$encodedPath&recursionLevel=oneLevel&includeContentMetadata=true&includeContent=true&$branchQuery$_apiVersion',
    );
    if (itemsRes.isError) return ApiResponse.error(itemsRes);

    return ApiResponse.ok(GetRepoItemsResponse.fromResponse(itemsRes));
  }

  @override
  Future<ApiResponse<List<Branch>>> getRepositoryBranches({
    required String projectName,
    required String repoName,
  }) async {
    final branchesRes =
        await _get('$_basePath/$projectName/_apis/git/repositories/$repoName/stats/branches?$_apiVersion');
    if (branchesRes.isError) return ApiResponse.error(branchesRes);

    return ApiResponse.ok(RepositoryBranchesResponse.fromResponse(branchesRes));
  }

  @override
  Future<ApiResponse<FileDetailResponse>> getFileDetail({
    required String projectName,
    required String repoName,
    required String path,
    String? branch,
    String? commitId,
    bool previousChange = false,
  }) async {
    var versionQuery = '';

    if (commitId != null) {
      versionQuery = 'versionDescriptor.version=$commitId&versionDescriptor.versionType=commit&';
    } else if (branch != null) {
      final encodedBranch = Uri.encodeQueryComponent(branch);
      versionQuery = 'versionDescriptor.version=$encodedBranch&versionDescriptor.versionType=branch&';
    }

    if (previousChange) {
      versionQuery += 'versionDescriptor.versionOptions=previousChange&';
    }

    final encodedPath = Uri.encodeQueryComponent(path);
    final res = await _get(
      '$_basePath/$projectName/_apis/git/repositories/$repoName/items?path=$encodedPath&includeContentMetadata=true&includeContent=true&$versionQuery$_apiVersion',
    );
    if (res.isError) return ApiResponse.error(res);

    final isBinary = res.body.contains('\u0000');

    return ApiResponse.ok(FileDetailResponse(content: res.body, isBinary: isBinary));
  }

  @override
  Future<ApiResponse<List<LanguageBreakdown>>> getProjectLanguages({required String projectName}) async {
    final langsRes = await _get('$_basePath/$projectName/_apis/projectanalysis/languagemetrics');
    if (langsRes.isError) return ApiResponse.error(langsRes);

    return ApiResponse.ok(GetProjectLanguagesResponse.fromResponse(langsRes));
  }

  @override
  Future<ApiResponse<List<Pipeline>>> getRecentPipelines({
    Project? project,
    int? definition,
    PipelineResult result = PipelineResult.all,
    PipelineStatus status = PipelineStatus.all,
    String? triggeredBy,
  }) async {
    const orderSearch = '&queryOrder=queueTimeDescending';
    final resultSearch = '&resultFilter=${result.stringValue}';
    final statusSearch = result != PipelineResult.all ? '' : '&statusFilter=${status.stringValue}';
    final triggeredBySearch = triggeredBy == null ? '' : '&requestedFor=$triggeredBy';

    final definitionSearch = definition == null ? '' : '&definitions=$definition';

    final queryParams = '$_apiVersion$orderSearch$resultSearch$statusSearch$triggeredBySearch$definitionSearch';

    final projectsToSearch = (definition != null || project != null) ? [project!] : (_chosenProjects ?? _projects);

    final allProjectPipelines = await Future.wait([
      for (final project in projectsToSearch) _get('$_basePath/${project.name}/_apis/build/builds?$queryParams'),
    ]);

    var isAllError = true;

    for (final res in allProjectPipelines) {
      isAllError &= res.isError;
    }

    if (isAllError) return ApiResponse.error(allProjectPipelines.firstOrNull);

    final res =
        allProjectPipelines.where((r) => !r.isError).map(GetPipelineResponse.fromResponse).expand((b) => b).toList();

    return ApiResponse.ok(res);
  }

  @override
  Future<ApiResponse<PipelineWithTimeline>> getPipeline({required String projectName, required int id}) async {
    final pipelineRes = await _get('$_basePath/$projectName/_apis/build/builds/$id?$_apiVersion');
    if (pipelineRes.isError) return ApiResponse.error(pipelineRes);

    final timelineRes = await _get('$_basePath/$projectName/_apis/build/builds/$id/timeline?$_apiVersion');

    final pipeline = Pipeline.fromResponse(pipelineRes);
    final timeline = timelineRes.isError || timelineRes.statusCode == 204
        ? <Record>[]
        : GetTimelineResponse.fromResponse(timelineRes);
    return ApiResponse.ok(PipelineWithTimeline(pipeline: pipeline, timeline: timeline));
  }

  @override
  Future<ApiResponse<String>> getPipelineTaskLogs({
    required String projectName,
    required int pipelineId,
    required int logId,
  }) async {
    final logsRes = await _get('$_basePath/$projectName/_apis/build/builds/$pipelineId/logs/$logId?$_apiVersion');
    if (logsRes.isError) return ApiResponse.error(logsRes);

    return ApiResponse.ok(logsRes.body);
  }

  @override
  Future<ApiResponse<List<Commit>>> getRecentCommits({Project? project, String? author, int? maxCount}) async {
    final projectsToSearch = project != null ? [project] : (_chosenProjects ?? _projects);

    final allProjectRepos = await Future.wait([
      for (final project in projectsToSearch) _get('$_basePath/${project.name}/_apis/git/repositories?$_apiVersion'),
    ]);

    var isAllError = true;

    for (final res in allProjectRepos) {
      isAllError &= res.isError;
    }

    if (isAllError) return ApiResponse.error(allProjectRepos.firstOrNull);

    final repos =
        allProjectRepos.where((r) => !r.isError).map(GetRepositoriesResponse.fromResponse).expand((r) => r).toList();

    final authorSearch = author != null ? '&searchCriteria.author=$author' : '';
    final topSearch = maxCount != null ? '&searchCriteria.\$top=$maxCount' : '';

    final allProjectCommits = <Response>[];

    // get commits in slices to avoid 'too many open files' error happening on iOS
    final slices = repos.slices(50);
    for (final slice in slices) {
      allProjectCommits.addAll(
        await Future.wait([
          for (final repo in slice)
            _get(
              '$_basePath/${repo.project!.name}/_apis/git/repositories/${repo.name}/commits?$_apiVersion$authorSearch$topSearch',
            ),
        ]),
      );
    }

    var isAllCommitsError = true;

    for (final res in allProjectCommits) {
      isAllCommitsError &= res.isError;
    }

    if (isAllCommitsError) return ApiResponse.error(allProjectCommits.firstOrNull);

    final commits =
        allProjectCommits.where((r) => !r.isError).map(GetCommitsResponse.fromResponse).expand((c) => c).toList();

    return ApiResponse.ok(commits);
  }

  @override
  Future<TagsData?> getTags(List<Commit> commits) async {
    final tagsRes = await _post(
      '$_basePath/_apis/contribution/hierarchyQuery/project/${commits.first.projectId}?$_apiVersion-preview',
      body: {
        'contributionIds': ['ms.vss-code-web.commits-data-provider'],
        'dataProviderContext': {
          'properties': {
            'repositoryId': commits.first.repositoryId,
            'searchCriteria': {
              'gitArtifactsQueryArguments': {
                'fetchTags': true,
                'commitIds': commits.map((e) => e.commitId).toList(),
              },
            },
          },
        },
      },
    );

    if (tagsRes.isError) return null;

    return TagsResponse.fromResponse(tagsRes)
      ?..projectId = commits.first.projectId
      ..repositoryId = commits.first.repositoryId;
  }

  @override
  Future<ApiResponse<CommitWithChanges>> getCommitDetail({
    required String projectId,
    required String repositoryId,
    required String commitId,
  }) async {
    if (commitId.isEmpty) return ApiResponse.error(null);

    final detailRes =
        await _get('$_basePath/$projectId/_apis/git/repositories/$repositoryId/commits/$commitId?$_apiVersion');
    if (detailRes.isError) return ApiResponse.error(detailRes);

    final changesRes =
        await _get('$_basePath/$projectId/_apis/git/repositories/$repositoryId/commits/$commitId/changes?$_apiVersion');

    final commit = Commit.fromResponse(detailRes);
    final changes = changesRes.isError ? null : CommitChanges.fromResponse(changesRes);

    final tags = await getTags([commit]);
    commit.tags = tags?.tags[commitId];
    return ApiResponse.ok(CommitWithChanges(commit: commit, changes: changes));
  }

  @override
  Future<ApiResponse<Diff>> getCommitDiff({
    required Commit commit,
    required String filePath,
    required bool isAdded,
    required bool isDeleted,
  }) async {
    final hasParent = commit.parents?.isNotEmpty ?? false;
    final repoId = commit.repositoryId;
    final diffRes = await _post(
      '$_basePath/_apis/contribution/hierarchyQuery/project/${commit.projectId}?$_apiVersion-preview',
      body: {
        'contributionIds': ['ms.vss-code-web.file-diff-data-provider'],
        'dataProviderContext': {
          'properties': {
            'repositoryId': repoId,
            'diffParameters': {
              'includeCharDiffs': true,
              if (!isDeleted) 'modifiedPath': filePath,
              if (!isDeleted) 'modifiedVersion': 'GC${commit.commitId}',
              if (!isAdded) 'originalPath': filePath,
              if (!isAdded && hasParent) 'originalVersion': 'GC${commit.parents!.first}',
              'partialDiff': true,
              'forceLoad': false,
            },
          },
        },
      },
    );
    if (diffRes.isError) return ApiResponse.error(diffRes);

    return ApiResponse.ok(GetFileDiffResponse.fromResponse(diffRes));
  }

  @override
  Future<ApiResponse<Pipeline>> cancelPipeline({required int buildId, required String projectId}) async {
    final cancelRes = await _patch(
      '$_basePath/$projectId/_apis/build/builds/$buildId?$_apiVersion',
      body: {'status': PipelineStatus.cancelling.stringValue},
    );
    if (cancelRes.isError) return ApiResponse.error(cancelRes);

    return ApiResponse.ok(Pipeline.fromResponse(cancelRes));
  }

  @override
  Future<ApiResponse<Pipeline>> rerunPipeline({
    required int definitionId,
    required String projectId,
    required String branch,
  }) async {
    final rerunRes = await _post(
      '$_basePath/$projectId/_apis/build/builds?$_apiVersion',
      body: {
        'sourceBranch': branch,
        'definition': {'id': definitionId},
      },
    );
    if (rerunRes.isError) return ApiResponse.error(rerunRes);

    return ApiResponse.ok(Pipeline.fromResponse(rerunRes));
  }

  @override
  Future<ApiResponse<GraphUser>> getUserFromEmail({
    required String email,
  }) async {
    if (_allUsers.isEmpty) await _getUsers();

    return ApiResponse.ok(_allUsers.firstWhereOrNull((u) => u.mailAddress == email));
  }

  @override
  Future<ApiResponse<GraphUser>> getUserFromDescriptor({
    required String descriptor,
  }) async {
    if (_allUsers.isEmpty) await _getUsers();

    final user = _allUsers.firstWhereOrNull((u) => u.descriptor == descriptor);
    if (user == null) {
      return ApiResponse.error(Response('', 404, reasonPhrase: 'User not found'));
    }

    return ApiResponse.ok(user);
  }

  @override
  Future<ApiResponse<GraphUser>> getUserFromDisplayName({
    required String name,
  }) async {
    if (_allUsers.isEmpty) await _getUsers();

    final user = _allUsers.firstWhereOrNull((u) => u.displayName == name);
    if (user == null) {
      return ApiResponse.error(null);
    }

    return ApiResponse.ok(user);
  }

  @override
  Future<ApiResponse<String>> getUserToMention({required String email}) async {
    final identity = await _get(
      '$_usersBasePath/$_organization/_apis/identities?searchFilter=General&filterValue=$email&$_apiVersion',
    );
    if (identity.isError) return ApiResponse.error(null);

    return ApiResponse.ok(UserIdentity.fromResponse(identity).id);
  }

  Future<ApiResponse<List<GraphUser>>> _getUsers() async {
    final usersRes =
        await _get('$_usersBasePath/$_organization/_apis/graph/users?subjectTypes=aad,msa&$_apiVersion-preview');
    if (usersRes.isError) return ApiResponse.error(usersRes);

    _allUsers = GetUsersResponse.fromResponse(usersRes);
    return ApiResponse.ok(_allUsers);
  }

  @override
  Future<void> logout() async {
    storageService.clear();
    _organization = '';
    _chosenProjects = null;
    _allUsers.clear();
    _user = null;
    dispose();
  }

  Map<String, Set<String>> _parseXmlForm(String xmlForm) {
    final visibleFields = <String, Set<String>>{};

    final document = XmlDocument.parse(xmlForm);
    for (final desc in document.descendantElements) {
      if (desc.localName == 'Control') {
        final fieldName = desc.attributes.firstWhereOrNull((att) => att.localName == 'FieldName');
        if (fieldName != null) {
          final readOnlyAttribute = desc.attributes.firstWhereOrNull((att) => att.localName == 'ReadOnly');
          final isReadOnly = readOnlyAttribute != null && readOnlyAttribute.value == 'True';
          if (!isReadOnly && !_fieldNamesToSkip.contains(fieldName.value)) {
            // get field group's label
            final group = desc.ancestorElements.firstWhereOrNull((e) => e.localName == 'Group');
            final groupLabel = group?.attributes.firstWhereOrNull((att) => att.localName == 'Label')?.value ?? '';

            visibleFields.putIfAbsent(groupLabel, () => {fieldName.value});
            visibleFields[groupLabel]!.add(fieldName.value);
          }
        }
      }
    }

    return visibleFields;
  }

  LabeledWorkItemFields _matchFields(Map<String, Set<String>> visibleFields, List<WorkItemField> allFields) {
    final matchedFields = <String, Set<WorkItemField>>{};

    for (final entry in visibleFields.entries) {
      for (final field in entry.value) {
        final matched = allFields.firstWhereOrNull((f) => f.referenceName == field);
        if (matched != null && matched.referenceName != 'System.History' && matched.name != 'Id') {
          matchedFields.putIfAbsent(entry.key, () => {matched});
          matchedFields[entry.key]!.add(matched);
        }
      }
    }

    return matchedFields;
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
    required this.errorResponse,
  });

  ApiResponse.ok(this.data)
      : isError = false,
        errorResponse = null;

  ApiResponse.error(this.errorResponse)
      : isError = true,
        data = null;

  final bool isError;
  final T? data;
  final Response? errorResponse;

  ApiResponse<T> copyWith({
    bool? isError,
    T? data,
    Response? errorResponse,
  }) {
    return ApiResponse<T>(
      isError: isError ?? this.isError,
      data: data ?? this.data,
      errorResponse: errorResponse ?? this.errorResponse,
    );
  }

  @override
  String toString() => 'ApiResponse(isError: $isError, data: $data, errorResponse: $errorResponse)';
}

class FileDetailResponse {
  FileDetailResponse({
    required this.content,
    required this.isBinary,
  });

  final String content;
  final bool isBinary;
}
