import 'package:azure_devops/src/models/identity_response.dart';
import 'package:azure_devops/src/models/pull_request.dart';
import 'package:azure_devops/src/models/pull_request_with_details.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:collection/collection.dart';

typedef _ThreadCommentMention = ({int threadId, int commentId, String mentionGuid, String? displayName});

mixin PullRequestHelper {
  String _basePath = '';
  String _projectId = '';

  /// Replaces work items links with valid markdown links in description and comments.
  /// Also, replaces markdown mentions with html mentions with names.
  Future<({PullRequest? pr, List<PullRequestUpdate> updates})> getReplacedPrAndThreads({
    required String basePath,
    required String projectId,
    PullRequestWithDetails? data,
    required Future<ApiResponse<Identity?>> Function(String) getIdentity,
  }) async {
    _basePath = basePath;
    _projectId = projectId;
    
    final mentionsToReplace = _getMentionsToReplace(data: data);
    final mentionsWithNames = await _getIdentitiesFromGuids(mentionsToReplace, getIdentity);

    final description = data?.pr.description ?? '';

    PullRequest? pr;

    if (description.isNotEmpty) {
      final replacedDescription = _replaceWorkItemLinks(description);
      pr = data!.pr.copyWith(description: replacedDescription);
    }

    final updates = <PullRequestUpdate>[];

    for (final update in data?.updates ?? <PullRequestUpdate>[]) {
      if (update is ThreadUpdate) {
        final replacedComments = <PrComment>[];
        for (final comment in update.comments) {
          var replacedComment = _replaceWorkItemLinks(comment.content);

          final mentions = mentionsWithNames.where((m) => m.threadId == update.id && m.commentId == comment.id);
          for (final mention in mentions) {
            replacedComment = _replaceMention(replacedComment, mention: mention);
          }

          replacedComments.add(comment.copyWith(content: replacedComment));
        }
        updates.add(update.copyWith(comments: replacedComments));
      } else {
        updates.add(update);
      }
    }

    return (pr: pr, updates: updates);
  }

  List<_ThreadCommentMention> _getMentionsToReplace({PullRequestWithDetails? data}) {
    if (data == null) return [];

    final threads = data.updates.whereType<ThreadUpdate>().where((t) => t.comments.any((c) => c.commentType == 'text'));

    if (threads.isEmpty) return [];

    final mentions = <_ThreadCommentMention>[];

    for (final thread in threads) {
      for (final comment in thread.comments) {
        final mentionGuids = _getMentionGuids(comment.content);
        if (mentionGuids.isNotEmpty) {
          for (final guid in mentionGuids) {
            mentions.add(
              (
                threadId: thread.id,
                commentId: comment.id,
                mentionGuid: guid,
                displayName: null,
              ),
            );
          }
        }
      }
    }

    return mentions;
  }

  final _mentionRegExp = RegExp('@<[a-zA-Z0-9-]+>');

  List<String> _getMentionGuids(String text) {
    final allMatches = _mentionRegExp.allMatches(text);
    if (allMatches.isEmpty) return [];

    final res = <String>[];

    for (final match in allMatches) {
      res.add(text.substring(match.start + 2, match.end - 1).trim());
    }

    return res;
  }

  Future<List<_ThreadCommentMention>> _getIdentitiesFromGuids(
    List<_ThreadCommentMention> mentionsToReplace,
    Future<ApiResponse<Identity?>> Function(String) getIdentity,
  ) async {
    final distinctGuids = mentionsToReplace.map((m) => m.mentionGuid).toSet();

    final res = await Future.wait([
      for (final mention in distinctGuids) getIdentity(mention),
    ]);

    final identitites = res.where((r) => !r.isError && r.data != null).map((r) => r.data!);

    return mentionsToReplace
        .map(
          (m) => (
            threadId: m.threadId,
            commentId: m.commentId,
            mentionGuid: m.mentionGuid,
            displayName:
                identitites.firstWhereOrNull((i) => i.guid?.toLowerCase() == m.mentionGuid.toLowerCase())?.displayName
          ),
        )
        .toList();
  }

  String _getWorkItemLinkHtml(String itemId) =>
      '<div> <a href="$_basePath/$_projectId/_workitems/edit/$itemId" data-vss-mention="version:1.0">#$itemId</a>&nbsp;<br></div>';

  String _replaceWorkItemLinks(String text) {
    return text.splitMapJoin(
      RegExp('#[0-9]+'),
      onMatch: (p0) {
        final item = p0.group(0);
        if (item == null) return p0.input;

        final itemId = item.substring(1);
        return _getWorkItemLinkHtml(itemId);
      },
    );
  }

  String _replaceMention(String text, {required _ThreadCommentMention mention}) {
    if (mention.displayName == null) return text;

    final guidIndex = text.indexOf(mention.mentionGuid);
    final startIndex = guidIndex - 2;
    final endIndex = guidIndex + mention.mentionGuid.length + 1;
    return text.replaceRange(startIndex, endIndex, _getMentionHtml(mention.mentionGuid, mention.displayName!));
  }

  String _getMentionHtml(String guid, String name) => '<a href="#" data-vss-mention="version:2.0,$guid">@$name</a>';
}
