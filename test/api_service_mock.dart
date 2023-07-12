//ignore_for_file: avoid-top-level-members-in-tests

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
import 'package:azure_devops/src/models/pull_request_with_details.dart' as pr;
import 'package:azure_devops/src/models/repository.dart';
import 'package:azure_devops/src/models/repository_branches.dart';
import 'package:azure_devops/src/models/repository_items.dart';
import 'package:azure_devops/src/models/team_member.dart';
import 'package:azure_devops/src/models/user.dart';
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
  bool get isLoggedInWithMicrosoft => false;

  @override
  Future<ApiResponse<Pipeline>> cancelPipeline({required int buildId, required String projectId}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<CommitWithChanges>> getCommitDetail({
    required String projectId,
    required String repositoryId,
    required String commitId,
  }) async {
    return ApiResponse.ok(
      CommitWithChanges(
        commit: Commit(
          commitId: '123456789',
          comment: 'Test commit message',
          author: Author(
            name: 'Test author',
            email: 'test@author.email',
            date: DateTime.now(),
          ),
          remoteUrl: 'https://dev.azure.com/xamapps/TestProject/_git/test_repo/commit/123456789',
        ),
        changes: CommitChanges(
          changes: [
            for (var i = 0; i < 3; i++)
              Change(
                item: Item(
                  objectId: '',
                  originalObjectId: '',
                  gitObjectType: 'blob',
                  commitId: commitId,
                  path: 'added_file.$i',
                  url: '',
                ),
                changeType: 'add',
              ),
            for (var i = 0; i < 5; i++)
              Change(
                item: Item(
                  objectId: '',
                  originalObjectId: '',
                  gitObjectType: 'blob',
                  commitId: commitId,
                  path: 'edited_file.$i',
                  url: '',
                ),
                changeType: 'edit',
              ),
            Change(
              item: Item(
                objectId: '',
                originalObjectId: '',
                gitObjectType: 'blob',
                commitId: commitId,
                path: 'deleted_file.0',
                url: '',
              ),
              changeType: 'delete',
            ),
          ],
        ),
      ),
    );
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
  }) async {
    final emptyWorkItem = PullRequest.empty();
    final firstItem = emptyWorkItem.copyWith(
      title: 'Pull request title 1',
      createdBy: emptyWorkItem.createdBy.copyWith(
        displayName: 'Test User 1',
      ),
      repository: emptyWorkItem.repository.copyWith(
        name: 'Repository name 1',
      ),
      creationDate: DateTime(2000, 1, 5),
    );
    final secondItem = emptyWorkItem.copyWith(
      title: 'Pull request title 2',
      createdBy: emptyWorkItem.createdBy.copyWith(
        displayName: 'Test User 2',
      ),
      repository: emptyWorkItem.repository.copyWith(
        name: 'Repository name 2',
      ),
      creationDate: DateTime(2000, 1, 7),
    );
    final thirdItem = emptyWorkItem.copyWith(
      title: 'Pull request title 3',
      createdBy: emptyWorkItem.createdBy.copyWith(
        displayName: 'Test User 3',
      ),
      repository: emptyWorkItem.repository.copyWith(
        name: 'Repository name 3',
      ),
      creationDate: DateTime(2000, 1, 9),
    );
    return ApiResponse.ok([firstItem, secondItem, thirdItem]);
  }

  @override
  String getUserAvatarUrl(String userDescriptor) {
    return '';
  }

  @override
  Future<ApiResponse<GraphUser>> getUserFromEmail({required String email}) async {
    return ApiResponse.ok(GraphUser(mailAddress: email));
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
  }) async {
    final emptyWorkItem = WorkItem.empty();
    final firstItem = emptyWorkItem.copyWith(
      id: 1,
      fields: emptyWorkItem.fields.copyWith(
        systemTitle: 'Work item title 1',
        systemTeamProject: 'Project 1',
      ),
    );
    final secondItem = emptyWorkItem.copyWith(
      id: 2,
      fields: emptyWorkItem.fields.copyWith(
        systemTitle: 'Work item title 2',
        systemTeamProject: 'Project 2',
      ),
    );
    final thirdItem = emptyWorkItem.copyWith(
      id: 3,
      fields: emptyWorkItem.fields.copyWith(
        systemTitle: 'Work item title 3',
        systemTeamProject: 'Project 3',
      ),
    );
    return ApiResponse.ok([firstItem, secondItem, thirdItem]);
  }

  @override
  Future<ApiResponse<List<WorkItem>>> getMyRecentWorkItems() {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<Map<String, List<WorkItemType>>>> getWorkItemTypes({bool force = false}) async {
    return ApiResponse.ok(<String, List<WorkItemType>>{});
  }

  @override
  Map<String, String>? get headers => {};

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
  void switchOrganization(String org) {
    throw UnimplementedError();
  }

  @override
  UserMe? get user => throw UnimplementedError();

  @override
  Future<ApiResponse<WorkItemWithUpdates>> getWorkItemDetail({
    required String projectName,
    required int workItemId,
  }) async {
    return ApiResponse.ok(
      WorkItemWithUpdates(
        item: WorkItem(
          id: 1234,
          rev: 0,
          fields: ItemFields(
            systemTeamProject: 'TestProject',
            systemWorkItemType: 'TestType',
            systemState: 'Active',
            systemCreatedDate: DateTime.now(),
            systemChangedDate: DateTime.now(),
            systemTitle: 'Test work item title',
            systemReason: '',
            systemCommentCount: 0,
            microsoftVstsCommonStateChangeDate: DateTime.now(),
            systemAssignedTo: WorkItemUser(
              id: '',
              imageUrl: '',
              descriptor: '',
              uniqueName: 'Test User Assignee',
              displayName: 'Test User Assignee',
            ),
            systemCreatedBy: WorkItemUser(
              id: '',
              imageUrl: '',
              descriptor: '',
              uniqueName: 'Test User Creator',
              displayName: 'Test User Creator',
            ),
            systemChangedBy: WorkItemUser(
              id: '',
              imageUrl: '',
              descriptor: '',
              uniqueName: 'Test User Creator',
              displayName: 'Test User Creator',
            ),
          ),
        ),
        updates: [],
      ),
    );
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
  Future<ApiResponse<PipelineWithTimeline>> getPipeline({required String projectName, required int id}) async {
    return ApiResponse.ok(
      PipelineWithTimeline(
        pipeline: Pipeline(
          id: 1234,
          project: Project(name: 'TestProject'),
          buildNumber: '5678',
          queueTime: DateTime.now(),
          repository: PipelineRepository(id: '', type: '', name: 'test_repo', url: ''),
          requestedFor: LastChangedBy(displayName: 'Test User'),
          triggerInfo: TriggerInfo(ciMessage: 'Test commit message', ciSourceSha: '123456789'),
          sourceBranch: 'refs/heads/test_branch',
        ),
        timeline: [],
      ),
    );
  }

  @override
  Future<ApiResponse<pr.PullRequestWithDetails>> getPullRequest({
    required String projectName,
    required String repositoryId,
    required int id,
  }) async {
    return ApiResponse.ok(
      pr.PullRequestWithDetails(
        pr: PullRequest(
          pullRequestId: 1234,
          status: PullRequestState.active,
          creationDate: DateTime.now(),
          title: 'Test pull request title',
          sourceRefName: 'dev',
          targetRefName: 'main',
          repository: Repository(
            id: '1',
            name: 'test_repo',
            url: '',
            project: RepositoryProject(
              id: '1',
              name: 'TestProject',
              state: '',
              visibility: '',
              lastUpdateTime: DateTime.now(),
            ),
          ),
          codeReviewId: 1,
          createdBy: CreatedBy(
            displayName: 'Test User Creator',
            url: '',
            id: '1',
            uniqueName: 'Test User Creator',
            imageUrl: '',
            descriptor: '',
          ),
          isDraft: false,
          mergeId: '',
          reviewers: [],
        ),
        changes: [],
        updates: [],
        conflicts: [],
      ),
    );
  }

  @override
  Future<ApiResponse<ProjectDetail>> getProject({required String projectName}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<List<LanguageBreakdown>>> getProjectLanguages({required String projectName}) {
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
  Future<ApiResponse<WorkItem>> createWorkItem({
    required String projectName,
    required WorkItemType type,
    required GraphUser? assignedTo,
    required String title,
    required String description,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<WorkItem>> editWorkItem({
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
  Future<ApiResponse<bool>> addWorkItemComment({required String projectName, required int id, required String text}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<bool>> editWorkItemComment({
    required String projectName,
    required CommentItemUpdate update,
    required String text,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<bool>> deleteWorkItemComment({
    required String projectName,
    required CommentItemUpdate update,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<bool>> addWorkItemAttachment({
    required String projectName,
    required String fileName,
    required String filePath,
    required int workItemId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<bool>> deleteWorkItem({required String projectName, required int id, required String type}) {
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
  Map<String, Map<String, List<WorkItemState>>> get workItemStates => {};

  @override
  Future<ApiResponse<String>> getUserToMention({required String email}) {
    throw UnimplementedError();
  }
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

extension on WorkItem {
  WorkItem copyWith({
    int? id,
    int? rev,
    ItemFields? fields,
  }) {
    return WorkItem(
      id: id ?? this.id,
      rev: rev ?? this.rev,
      fields: fields ?? this.fields,
    );
  }
}

extension on ItemFields {
  ItemFields copyWith({
    String? systemTeamProject,
    String? systemWorkItemType,
    String? systemState,
    DateTime? systemCreatedDate,
    DateTime? systemChangedDate,
    String? systemTitle,
  }) {
    return ItemFields(
      systemTeamProject: systemTeamProject ?? this.systemTeamProject,
      systemWorkItemType: systemWorkItemType ?? this.systemWorkItemType,
      systemState: systemState ?? this.systemState,
      systemCreatedDate: systemCreatedDate ?? this.systemCreatedDate,
      systemChangedDate: systemChangedDate ?? this.systemChangedDate,
      systemTitle: systemTitle ?? this.systemTitle,
    );
  }
}

extension on CreatedBy {
  CreatedBy copyWith({String? displayName}) {
    return CreatedBy(
      displayName: displayName ?? this.displayName,
      url: url,
      links: links,
      id: id,
      uniqueName: uniqueName,
      imageUrl: imageUrl,
      descriptor: descriptor,
    );
  }
}

extension on Repository {
  Repository copyWith({
    String? id,
    String? name,
    String? url,
  }) {
    return Repository(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      project: project,
    );
  }
}
