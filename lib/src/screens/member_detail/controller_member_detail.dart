part of member_detail;

class _MemberDetailController {
  _MemberDetailController._(this.userDescriptor, this.apiService);

  final String userDescriptor;

  final AzureApiService apiService;

  final recentCommits = ValueNotifier<List<Commit>?>(null);

  final user = ValueNotifier<ApiResponse<GraphUser>?>(null);

  Future<void> init() async {
    final userRes = await apiService.getUserFromDescriptor(descriptor: userDescriptor);

    if (userRes.isError || userRes.data == null) {
      recentCommits.value = [];
      user.value = userRes;
      return;
    }

    user.value = userRes;

    final res = await apiService.getRecentCommits(authors: {user.value!.data!.mailAddress ?? ''}, maxCount: 20);
    res.data?.sort((a, b) => b.author!.date!.compareTo(a.author!.date!));

    final commits = res.data?.take(10);

    recentCommits.value = commits?.toList();
  }

  void goToCommitDetail(Commit commit) {
    AppRouter.goToCommitDetail(
      project: commit.projectName,
      repository: commit.repositoryName,
      commitId: commit.commitId!,
    );
  }
}
