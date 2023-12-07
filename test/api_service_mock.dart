//ignore_for_file: avoid-top-level-members-in-tests

import 'dart:typed_data';

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
import 'package:azure_devops/src/models/pull_request_with_details.dart' as pr;
import 'package:azure_devops/src/models/repository.dart';
import 'package:azure_devops/src/models/repository_branches.dart';
import 'package:azure_devops/src/models/repository_items.dart';
import 'package:azure_devops/src/models/team.dart';
import 'package:azure_devops/src/models/team_member.dart' as t;
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/models/work_item_fields.dart';
import 'package:azure_devops/src/models/work_item_updates.dart';
import 'package:azure_devops/src/models/work_items.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';

class AzureApiServiceMock implements AzureApiService {
  @override
  String get basePath => 'https://dev.azure.com/organization';

  @override
  List<GraphUser> get allUsers => [];

  @override
  Map<String, List<WorkItemType>> get workItemTypes => {};

  @override
  Map<String, List<AreaOrIteration>> get workItemAreas => {};

  @override
  Map<String, List<AreaOrIteration>> get workItemIterations => {};

  @override
  bool get isImageUnauthorized => false;

  @override
  Future<ApiResponse<Pipeline>> cancelPipeline(
      {required int buildId, required String projectId}) {
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
          remoteUrl:
              'https://dev.azure.com/xamapps/TestProject/_git/test_repo/commit/123456789',
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
    int? definition,
    PipelineResult result = PipelineResult.all,
    PipelineStatus status = PipelineStatus.all,
    String? triggeredBy,
  }) async {
    final emptyPipe = Pipeline.empty();
    final firstPipe = emptyPipe
        .copyWithStatus(PipelineStatus.completed)
        .copyWithResult(PipelineResult.succeeded)
        .copyWithRequestedFor('Test User 1');
    final secondPipe = emptyPipe
        .copyWithStatus(PipelineStatus.inProgress)
        .copyWithRequestedFor('Test User 2');
    final thirdPipe = emptyPipe
        .copyWithStatus(PipelineStatus.notStarted)
        .copyWithRequestedFor('Test User 3');
    return ApiResponse.ok([firstPipe, secondPipe, thirdPipe]);
  }

  @override
  Future<ApiResponse<List<Commit>>> getRecentCommits(
      {Project? project, String? author, int? maxCount}) async {
    final emptyCommit = Commit.empty();
    final firstCommit = emptyCommit.copyWithDateAndAuthorName(
        DateTime(2000, 2, 3), 'Test User 1');
    final secondCommit = emptyCommit.copyWithDateAndAuthorName(
        DateTime(2000, 2, 5), 'Test User 2');
    final thirdCommit = emptyCommit.copyWithDateAndAuthorName(
        DateTime(2000, 2, 4), 'Test User 3');
    return ApiResponse.ok([firstCommit, secondCommit, thirdCommit]);
  }

  @override
  Future<TagsData?> getTags(List<Commit> commits) async {
    return null;
  }

  @override
  Future<ApiResponse<List<Organization>>> getOrganizations() {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<List<GitRepository>>> getProjectRepositories(
      {required String projectName}) async {
    return ApiResponse.ok(<GitRepository>[]);
  }

  @override
  Future<ApiResponse<List<TeamWithMembers>>> getProjectTeams(
      {required String projectId}) async {
    final team = Team(
      id: 'team id',
      name: 'team name',
      description: 'team description',
      projectName: 'team projectName',
      projectId: projectId,
    );
    final member1 = t.TeamMember(
      isTeamAdmin: false,
      identity: t.Identity(
        displayName: 'member_1_name',
        id: 'member 1 id',
        uniqueName: 'aabbcc',
        imageUrl: null,
        descriptor: '',
      ),
    );
    final member2 = t.TeamMember(
      isTeamAdmin: true,
      identity: t.Identity(
        displayName: 'member_2_name',
        id: 'member 2 id',
        uniqueName: 'ddeeff',
        imageUrl: null,
        descriptor: null,
      ),
    );
    final x = [member1, member2];
    final teamsWithMembers1 = <TeamWithMembers>[(members: x, team: team)];

    return ApiResponse.ok(teamsWithMembers1);
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
    GraphUser? reviewer,
  }) async {
    final emptyPullRequest = PullRequest.empty();
    final firstItem = emptyPullRequest.copyWith(
      pullRequestId: 1,
      title: 'Pull request title 1',
      createdBy: emptyPullRequest.createdBy.copyWith(
        displayName: 'Test User 1',
      ),
      repository: emptyPullRequest.repository.copyWith(
        name: 'Repository name 1',
      ),
      creationDate: DateTime(2000, 1, 5),
    );
    final secondItem = emptyPullRequest.copyWith(
      pullRequestId: 2,
      title: 'Pull request title 2',
      createdBy: emptyPullRequest.createdBy.copyWith(
        displayName: 'Test User 2',
      ),
      repository: emptyPullRequest.repository.copyWith(
        name: 'Repository name 2',
      ),
      creationDate: DateTime(2000, 1, 7),
    );
    final thirdItem = emptyPullRequest.copyWith(
      pullRequestId: 3,
      title: 'Pull request title 3',
      createdBy: emptyPullRequest.createdBy.copyWith(
        displayName: 'Test User 3',
      ),
      repository: emptyPullRequest.repository.copyWith(
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
  Future<ApiResponse<GraphUser>> getUserFromEmail(
      {required String email}) async {
    return ApiResponse.ok(GraphUser(mailAddress: null));
  }

  @override
  Future<ApiResponse<GraphUser>> getUserFromDescriptor({
    required String descriptor,
  }) async {
    throw UnimplementedError();
    return ApiResponse.ok(
      GraphUser(
        displayName: 'name test',
        mailAddress: 'mail test',
        descriptor: 'descriptor test',
        subjectKind: 'user',
        metaType: 'member',
        domain: 'domain',
      ),
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
  Future<ApiResponse<Map<String, List<WorkItemType>>>> getWorkItemTypes(
      {bool force = false}) async {
    return ApiResponse.ok(<String, List<WorkItemType>>{});
  }

  @override
  Future<ApiResponse<WorkItemFieldsWithRules>> getWorkItemTypeFields({
    required String projectName,
    required String workItemName,
  }) async {
    return ApiResponse.ok(
        WorkItemFieldsWithRules(fields: {}, rules: {}, transitions: {}));
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
  UserMe? get user => UserMe(
        displayName: 'test name',
        publicAlias: 'test alias',
        emailAddress: 'test email',
        coreRevision: 1,
        timeStamp: DateTime.now(),
        id: 'test id',
        revision: 1,
      );

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
            systemAreaPath: 'TestArea',
            systemIterationPath: 'TestIteration',
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
  Future<ApiResponse<PipelineWithTimeline>> getPipeline(
      {required String projectName, required int id}) async {
    return ApiResponse.ok(
      PipelineWithTimeline(
        pipeline: Pipeline(
          id: 1234,
          project: Project(name: 'TestProject'),
          buildNumber: '5678',
          queueTime: DateTime.now(),
          repository:
              PipelineRepository(id: '', type: '', name: 'test_repo', url: ''),
          requestedFor: LastChangedBy(displayName: 'Test User'),
          triggerInfo: TriggerInfo(
              ciMessage: 'Test commit message', ciSourceSha: '123456789'),
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
        policies: [],
      ),
    );
  }

  @override
  Future<ApiResponse<Identity?>> getIdentityFromGuid(
      {required String guid}) async {
    return ApiResponse.ok(null);
  }

  @override
  Future<ApiResponse<bool>> votePullRequest({
    required String projectName,
    required String repositoryId,
    required int id,
    required Reviewer reviewer,
  }) async {
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
    return ApiResponse.ok(true);
  }

  @override
  Future<ApiResponse<ProjectDetail>> getProject(
      {required String projectName}) async {
    final data = ProjectDetail(
      project: Project(
        id: 'project id',
        name: 'project name',
        description: 'description',
        url: '',
      ),
    );
    return ApiResponse.ok(data);
  }

  @override
  Future<ApiResponse<List<LanguageBreakdown>>> getProjectLanguages(
      {required String projectName}) async {
    final lang1 = LanguageBreakdown(name: 'en-EN');
    return ApiResponse.ok([lang1]);
  }

  @override
  Future<ApiResponse<String>> getPipelineTaskLogs({
    required String projectName,
    required int pipelineId,
    required int logId,
  }) async {
    return ApiResponse.ok('log test');
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
    String? state,
    AreaOrIteration? area,
    AreaOrIteration? iteration,
    required Map<String, String> formFields,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<bool>> addWorkItemComment(
      {required String projectName, required int id, required String text}) {
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
  Future<ApiResponse<bool>> deleteWorkItem(
      {required String projectName, required int id, required String type}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<List<RepoItem>>> getRepositoryItems({
    required String projectName,
    required String repoName,
    required String path,
    String? branch,
  }) async {
    final item1 = RepoItem(
      objectId: 'item 1 ID',
      commitId: '111111',
      path: 'item 1',
      url: '',
    );
    final item2 = RepoItem(
      objectId: 'item 2 ID',
      commitId: '222222',
      path: 'item 2',
      url: '',
    );
    return ApiResponse.ok([item1, item2]);
  }

  @override
  Future<ApiResponse<List<Branch>>> getRepositoryBranches({
    required String projectName,
    required String repoName,
  }) async {
    return ApiResponse.ok(<Branch>[]);
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
    return ApiResponse.ok(
      FileDetailResponse(content: 'body test', isBinary: false),
    );
  }

  @override
  Future<ApiResponse<GraphUser>> getUserFromDisplayName(
      {required String name}) {
    throw UnimplementedError();
  }

  @override
  Map<String, Map<String, List<WorkItemState>>> get workItemStates => {};

  @override
  Future<ApiResponse<String>> getUserToMention({required String email}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<bool>> editPullRequestThreadStatus({
    required String projectName,
    required String repositoryId,
    required int pullRequestId,
    required int threadId,
    required pr.ThreadStatus status,
  }) {
    throw UnimplementedError();
  }

  @override
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
    bool isRightFile = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<bool>> deletePullRequestComment({
    required String projectName,
    required String repositoryId,
    required int pullRequestId,
    required int threadId,
    required pr.PrComment comment,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<bool>> editPullRequestComment({
    required String projectName,
    required String repositoryId,
    required int pullRequestId,
    required int threadId,
    required pr.PrComment comment,
    required String text,
  }) {
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
  void setChosenProjects(Iterable<Project> projects) {}

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
  void increaseNumberOfSessions() {}

  @override
  int get numberOfSessions => 1;
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
      systemAreaPath: systemAreaPath,
      systemIterationPath: systemIterationPath,
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
