import 'dart:typed_data';

import 'package:azure_devops/src/models/commit.dart';
import 'package:azure_devops/src/models/commit_detail.dart';
import 'package:azure_devops/src/models/file_diff.dart';
import 'package:azure_devops/src/models/organization.dart';
import 'package:azure_devops/src/models/pipeline.dart';
import 'package:azure_devops/src/models/processes.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/project_languages.dart';
import 'package:azure_devops/src/models/pull_request.dart';
import 'package:azure_devops/src/models/repository.dart';
import 'package:azure_devops/src/models/repository_branches.dart';
import 'package:azure_devops/src/models/repository_items.dart';
import 'package:azure_devops/src/models/team_member.dart';
import 'package:azure_devops/src/models/timeline.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/models/work_item.dart';
import 'package:azure_devops/src/models/work_item_updates.dart';
import 'package:azure_devops/src/models/work_items.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';

class AzureApiServiceMock implements AzureApiService {
  @override
  String get accessToken => throw UnimplementedError();

  @override
  String get basePath => throw UnimplementedError();

  @override
  List<GraphUser> get allUsers => [];

  @override
  Map<String, List<WorkItemType>> get workItemTypes => {};

  @override
  bool get isImageUnauthorized => false;

  @override
  Future<ApiResponse<Pipeline>> cancelPipeline({required int buildId, required String projectId}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<Commit>> getCommitDetail({
    required String projectId,
    required String repositoryId,
    required String commitId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<CommitChanges>> getCommitChanges({
    required String projectId,
    required String repositoryId,
    required String commitId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<Diff>> getCommitDiff({
    required Commit commit,
    required String filePath,
    required bool isAdded,
    required bool isDeleted,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<List<Pipeline>>> getRecentPipelines({
    Project? project,
    PipelineResult result = PipelineResult.all,
    PipelineStatus status = PipelineStatus.all,
    String? triggeredBy,
  }) async {
    final emptyPipe = Pipeline.empty();
    final firstPipe = emptyPipe
        .copyWithStatus(PipelineStatus.completed)
        .copyWithResult(PipelineResult.succeeded)
        .copyWithRequestedFor('Test User 1');
    final secondPipe = emptyPipe.copyWithStatus(PipelineStatus.inProgress).copyWithRequestedFor('Test User 2');
    final thirdPipe = emptyPipe.copyWithStatus(PipelineStatus.notStarted).copyWithRequestedFor('Test User 3');
    return ApiResponse.ok([firstPipe, secondPipe, thirdPipe]);
  }

  @override
  Future<ApiResponse<List<Commit>>> getRecentCommits({Project? project, String? author, int? maxCount}) async {
    final emptyCommit = Commit.empty();
    final firstCommit = emptyCommit.copyWithDateAndAuthorName(DateTime(2000, 2, 3), 'Test User 1');
    final secondCommit = emptyCommit.copyWithDateAndAuthorName(DateTime(2000, 2, 5), 'Test User 2');
    final thirdCommit = emptyCommit.copyWithDateAndAuthorName(DateTime(2000, 2, 4), 'Test User 3');
    return ApiResponse.ok([firstCommit, secondCommit, thirdCommit]);
  }

  @override
  Future<ApiResponse<List<Organization>>> getOrganizations() {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<List<GitRepository>>> getProjectRepositories({required String projectName}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<List<TeamMember>>> getProjectTeams({required String projectId}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<List<Project>>> getProjects() async {
    return ApiResponse.ok([
      Project(
        id: '0',
        name: 'p1',
        description: 'p1 desc',
      ),
    ]);
  }

  @override
  Future<ApiResponse<List<PullRequest>>> getPullRequests({
    required PullRequestState filter,
    GraphUser? creator,
    Project? project,
  }) {
    throw UnimplementedError();
  }

  @override
  String getUserAvatarUrl(String userDescriptor) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<GraphUser>> getUserFromEmail({required String email}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<GraphUser>> getUserFromDescriptor({required String descriptor}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<List<WorkItem>>> getWorkItems({
    Project? project,
    WorkItemType? type,
    WorkItemState? status,
    GraphUser? assignedTo,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<Map<String, List<WorkItemType>>>> getWorkItemTypes() {
    throw UnimplementedError();
  }

  @override
  Map<String, String>? get headers => throw UnimplementedError();

  @override
  Future<LoginStatus> login(String accessToken) async {
    if (accessToken == 'validToken') return LoginStatus.ok;
    if (accessToken == 'singleOrgToken') return LoginStatus.unauthorized;

    return LoginStatus.failed;
  }

  @override
  Future<void> logout() {
    throw UnimplementedError();
  }

  @override
  String get organization => 'PurpleSoft S.r.l';

  @override
  Future<ApiResponse<Pipeline>> rerunPipeline({
    required int definitionId,
    required String projectId,
    required String branch,
  }) {
    throw UnimplementedError();
  }

  @override
  void setChosenProjects(List<Project> chosenProjects) {
    throw UnimplementedError();
  }

  @override
  Future<void> setOrganization(String org) {
    throw UnimplementedError();
  }

  @override
  UserMe? get user => throw UnimplementedError();

  @override
  Future<ApiResponse<WorkItemDetail>> getWorkItemDetail({
    required String projectName,
    required int workItemId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<List<WorkItemUpdate>>> getWorkItemUpdates({
    required String projectName,
    required int workItemId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<Uint8List>> getWorkItemAttachment({
    required String projectName,
    required String attachmentId,
    required String fileName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<Pipeline>> getPipeline({required String projectName, required int id}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<PullRequest>> getPullRequest({required String projectName, required int id}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<Project>> getProject({required String projectName}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<List<LanguageBreakdown>>> getProjectLanguages({required String projectName}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<List<Record>>> getPipelineTimeline({required String projectName, required int id}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<String>> getPipelineTaskLogs({
    required String projectName,
    required int pipelineId,
    required int logId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<WorkItemDetail>> createWorkItem({
    required String projectName,
    required WorkItemType type,
    required GraphUser? assignedTo,
    required String title,
    required String description,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<WorkItemDetail>> editWorkItem({
    required String projectName,
    required int id,
    WorkItemType? type,
    GraphUser? assignedTo,
    String? title,
    String? description,
    String? status,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<bool>> deleteWorkItem({required String projectName, required int id}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<List<RepoItem>>> getRepositoryItems({
    required String projectName,
    required String repoName,
    required String path,
    String? branch,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<List<Branch>>> getRepositoryBranches({
    required String projectName,
    required String repoName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<FileDetailResponse>> getFileDetail({
    required String projectName,
    required String repoName,
    required String path,
    String? branch,
    String? commitId,
    bool previousChange = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<GraphUser>> getUserFromDisplayName({required String name}) {
    throw UnimplementedError();
  }

  @override
  Map<String, Map<String, List<WorkItemState>>> get workItemStates => throw UnimplementedError();
}

class StorageServiceMock implements StorageService {
  @override
  void clearNoToken() {
    throw UnimplementedError();
  }

  @override
  Iterable<Project> getChosenProjects() {
    return [];
  }

  @override
  String getOrganization() {
    return 'org';
  }

  @override
  String getThemeMode() {
    throw UnimplementedError();
  }

  @override
  String getToken() {
    throw UnimplementedError();
  }

  @override
  void setChosenProjects(Iterable<Project> projects) {
    throw UnimplementedError();
  }

  @override
  void setOrganization(String organization) {
    throw UnimplementedError();
  }

  @override
  void setThemeMode(String mode) {
    throw UnimplementedError();
  }

  @override
  void setToken(String accessToken) {
    throw UnimplementedError();
  }

  @override
  void clear() {
    throw UnimplementedError();
  }

  @override
  void increaseNumberOfSessions() {
    throw UnimplementedError();
  }

  @override
  int get numberOfSessions => throw UnimplementedError();
}
