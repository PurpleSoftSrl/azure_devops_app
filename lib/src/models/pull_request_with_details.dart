import 'dart:convert';

import 'package:azure_devops/src/models/commit.dart';
import 'package:azure_devops/src/models/pull_request.dart';
import 'package:azure_devops/src/models/pull_request_policies.dart';
import 'package:http/http.dart';

class PullRequestWithDetails {
  PullRequestWithDetails({
    required this.pr,
    required this.changes,
    required this.updates,
    required this.conflicts,
    required this.policies,
  });

  final PullRequest pr;
  final List<CommitWithChangeEntry> changes;
  final List<PullRequestUpdate> updates;
  final List<Conflict> conflicts;
  final List<Policy> policies;

  PullRequestWithDetails copyWith({
    PullRequest? pr,
    List<CommitWithChangeEntry>? changes,
    List<PullRequestUpdate>? updates,
    List<Conflict>? conflicts,
    List<Policy>? policies,
  }) {
    return PullRequestWithDetails(
      pr: pr ?? this.pr,
      changes: changes ?? this.changes,
      updates: updates ?? this.updates,
      conflicts: conflicts ?? this.conflicts,
      policies: policies ?? this.policies,
    );
  }
}

class IterationsRes {
  IterationsRes({required this.iterations});

  factory IterationsRes.fromResponse(Response res) =>
      IterationsRes.fromJson(json.decode(res.body) as Map<String, dynamic>);

  factory IterationsRes.fromJson(Map<String, dynamic> json) => IterationsRes(
        iterations: List<Iteration>.from(
          (json['value'] as List<dynamic>).map((i) => Iteration.fromJson(i as Map<String, dynamic>)),
        ),
      );

  final List<Iteration> iterations;
}

class Iteration {
  Iteration({
    required this.id,
    required this.description,
    required this.author,
    required this.createdDate,
    required this.updatedDate,
    required this.sourceRefCommit,
    required this.commonRefCommit,
    this.commits,
  });

  factory Iteration.fromJson(Map<String, dynamic> json) => Iteration(
        id: json['id'] as int,
        description: json['description'] as String,
        author: _Author.fromJson(json['author'] as Map<String, dynamic>),
        createdDate: DateTime.parse(json['createdDate']!.toString()).toLocal(),
        updatedDate: DateTime.parse(json['updatedDate']!.toString()).toLocal(),
        sourceRefCommit: _RefCommit.fromJson(json['sourceRefCommit'] as Map<String, dynamic>? ?? {}),
        commonRefCommit: _RefCommit.fromJson(json['commonRefCommit'] as Map<String, dynamic>? ?? {}),
        commits: (json['commits'] as List<dynamic>?)?.map((e) => Commit.fromJson(e as Map<String, dynamic>)).toList(),
      );

  final int id;
  final String description;
  final _Author author;
  final DateTime createdDate;
  final DateTime updatedDate;
  final _RefCommit sourceRefCommit;
  final _RefCommit commonRefCommit;
  final List<Commit>? commits;
}

class _Author {
  _Author({
    required this.displayName,
    required this.id,
    required this.uniqueName,
    required this.descriptor,
  });

  factory _Author.fromJson(Map<String, dynamic> json) => _Author(
        displayName: json['displayName'] as String,
        id: json['id'] as String,
        uniqueName: json['uniqueName'] as String,
        descriptor: json['descriptor'] as String,
      );

  final String displayName;
  final String id;
  final String uniqueName;
  final String descriptor;
}

class _RefCommit {
  _RefCommit({required this.commitId});

  factory _RefCommit.fromJson(Map<String, dynamic> json) => _RefCommit(commitId: json['commitId'] as String? ?? '');

  final String commitId;
}

class ChangesRes {
  ChangesRes({required this.changes});

  factory ChangesRes.fromResponse(Response res) => ChangesRes.fromJson(json.decode(res.body) as Map<String, dynamic>);

  factory ChangesRes.fromJson(Map<String, dynamic> json) => ChangesRes(
        changes: List<ChangeEntry>.from(
          (json['changeEntries'] as List<dynamic>).map((e) => ChangeEntry.fromJson(e as Map<String, dynamic>)),
        ),
      );

  final List<ChangeEntry> changes;
}

class CommitWithChangeEntry {
  CommitWithChangeEntry({required this.changes, required this.iteration});

  final List<ChangeEntry> changes;
  final Iteration iteration;
}

class ChangeEntry {
  ChangeEntry({
    required this.changeTrackingId,
    required this.changeId,
    required this.item,
    required this.changeType,
    this.originalPath,
  });

  factory ChangeEntry.fromJson(Map<String, dynamic> json) => ChangeEntry(
        changeTrackingId: json['changeTrackingId'] as int,
        changeId: json['changeId'] as int,
        item: _Item.fromJson(json['item'] as Map<String, dynamic>),
        changeType: json['changeType'] as String,
        originalPath: json['originalPath'] as String?,
      );

  final int changeTrackingId;
  final int changeId;
  final _Item item;
  final String changeType;
  final String? originalPath;
}

class _Item {
  _Item({this.objectId, this.originalObjectId, this.path});

  factory _Item.fromJson(Map<String, dynamic> json) => _Item(
        objectId: json['objectId'] as String?,
        originalObjectId: json['originalObjectId'] as String?,
        path: json['path'] as String?,
      );

  final String? objectId;
  final String? originalObjectId;
  final String? path;
}

class ThreadsRes {
  ThreadsRes({required this.threads});

  factory ThreadsRes.fromResponse(Response res) => ThreadsRes.fromJson(json.decode(res.body) as Map<String, dynamic>);

  factory ThreadsRes.fromJson(Map<String, dynamic> json) => ThreadsRes(
        threads:
            List<Thread>.from((json['value'] as List<dynamic>).map((t) => Thread.fromJson(t as Map<String, dynamic>))),
      );

  final List<Thread> threads;
}

class Thread {
  Thread({
    required this.id,
    required this.publishedDate,
    required this.lastUpdatedDate,
    required this.comments,
    required this.isDeleted,
    this.properties,
    this.identities,
    this.threadContext,
    this.status,
  });

  factory Thread.fromJson(Map<String, dynamic> json) => Thread(
        id: json['id'] as int,
        publishedDate: DateTime.parse(json['publishedDate']!.toString()).toLocal(),
        lastUpdatedDate: DateTime.parse(json['lastUpdatedDate']!.toString()).toLocal(),
        comments: List<PrComment>.from(
          (json['comments'] as List<dynamic>).map((c) => PrComment.fromJson(c as Map<String, dynamic>)),
        ),
        isDeleted: json['isDeleted'] as bool,
        properties:
            json['properties'] == null ? null : _Properties.fromJson(json['properties'] as Map<String, dynamic>),
        identities: json['identities'] == null ? null : json['identities'] as Map<String, dynamic>,
        threadContext: json['threadContext'] == null
            ? null
            : ThreadContext.fromJson(json['threadContext'] as Map<String, dynamic>),
        status: ThreadStatus.fromString(json['status'] as String?),
      );

  final int id;
  final DateTime publishedDate;
  final DateTime lastUpdatedDate;
  final List<PrComment> comments;
  final bool isDeleted;
  final _Properties? properties;
  final Map<String, dynamic>? identities;
  final ThreadContext? threadContext;
  final ThreadStatus? status;

  Thread copyWith({List<PrComment>? comments}) {
    return Thread(
      id: id,
      publishedDate: publishedDate,
      lastUpdatedDate: lastUpdatedDate,
      comments: comments ?? this.comments,
      isDeleted: isDeleted,
      identities: identities,
      properties: properties,
    );
  }
}

class _Properties {
  _Properties({this.type, this.newCommits, this.newCommitsCount});

  factory _Properties.fromJson(Map<String, dynamic> json) => _Properties(
        type: json['CodeReviewThreadType'] == null
            ? null
            : _Property.fromJson(json['CodeReviewThreadType'] as Map<String, dynamic>),
        newCommits: json['CodeReviewRefNewCommits'] == null
            ? null
            : _Property.fromJson(json['CodeReviewRefNewCommits'] as Map<String, dynamic>),
        newCommitsCount: json['CodeReviewRefNewCommitsCount'] == null
            ? null
            : _Property.fromJson(json['CodeReviewRefNewCommitsCount'] as Map<String, dynamic>),
      );

  final _Property<String>? type;
  final _Property<String>? newCommits;
  final _Property<int>? newCommitsCount;
}

class _Property<T> {
  _Property({required this.type, required this.value});

  factory _Property.fromJson(Map<String, dynamic> json) => _Property(
        type: json['\u0024type'] as String,
        value: json['\u0024value'] as T,
      );
  final String type;
  final T value;
}

class PrComment {
  PrComment({
    required this.id,
    required this.parentCommentId,
    required this.author,
    required this.content,
    required this.publishedDate,
    required this.lastUpdatedDate,
    required this.commentType,
    required this.isDeleted,
  });

  factory PrComment.fromJson(Map<String, dynamic> json) => PrComment(
        id: json['id'] as int,
        parentCommentId: json['parentCommentId'] as int,
        author: _Author.fromJson(json['author'] as Map<String, dynamic>),
        content: json['content'] as String? ?? '',
        publishedDate: DateTime.parse(json['publishedDate']!.toString()).toLocal(),
        lastUpdatedDate: DateTime.parse(json['lastUpdatedDate']!.toString()).toLocal(),
        commentType: json['commentType'] as String?,
        isDeleted: json['isDeleted'] as bool? ?? false,
      );

  final int id;
  final int parentCommentId;
  final _Author author;
  final String content;
  final DateTime publishedDate;
  final DateTime lastUpdatedDate;
  final String? commentType;
  final bool isDeleted;

  PrComment copyWith({String? content}) {
    return PrComment(
      id: id,
      parentCommentId: parentCommentId,
      author: author,
      content: content ?? this.content,
      publishedDate: publishedDate,
      lastUpdatedDate: lastUpdatedDate,
      commentType: commentType,
      isDeleted: isDeleted,
    );
  }
}

class ConflictsResponse {
  ConflictsResponse({required this.conflicts});

  factory ConflictsResponse.fromResponse(Response res) =>
      ConflictsResponse.fromJson(json.decode(res.body) as Map<String, dynamic>);

  factory ConflictsResponse.fromJson(Map<String, dynamic> json) => ConflictsResponse(
        conflicts: List<Conflict>.from(
          (json['value'] as List<dynamic>).map((c) => Conflict.fromJson(c as Map<String, dynamic>)),
        ),
      );

  final List<Conflict> conflicts;
}

class Conflict {
  Conflict({
    required this.conflictId,
    required this.conflictType,
    required this.conflictPath,
  });

  factory Conflict.fromJson(Map<String, dynamic> json) => Conflict(
        conflictId: json['conflictId'] as int,
        conflictType: json['conflictType'] as String,
        conflictPath: json['conflictPath'] as String,
      );

  final int conflictId;
  final String conflictType;
  final String conflictPath;
}

class ThreadContext {
  ThreadContext({
    required this.filePath,
    required this.rightFileStart,
    required this.rightFileEnd,
    required this.leftFileStart,
    required this.leftFileEnd,
  });

  factory ThreadContext.fromJson(Map<String, dynamic> json) => ThreadContext(
        filePath: json['filePath'] as String,
        rightFileStart:
            json['rightFileStart'] == null ? null : _RightFile.fromJson(json['rightFileStart'] as Map<String, dynamic>),
        rightFileEnd:
            json['rightFileEnd'] == null ? null : _RightFile.fromJson(json['rightFileEnd'] as Map<String, dynamic>),
        leftFileStart:
            json['leftFileStart'] == null ? null : _RightFile.fromJson(json['leftFileStart'] as Map<String, dynamic>),
        leftFileEnd:
            json['leftFileEnd'] == null ? null : _RightFile.fromJson(json['leftFileEnd'] as Map<String, dynamic>),
      );

  final String filePath;
  final _RightFile? rightFileStart;
  final _RightFile? rightFileEnd;
  final _RightFile? leftFileStart;
  final _RightFile? leftFileEnd;
}

class _RightFile {
  _RightFile({
    required this.line,
    required this.offset,
  });

  factory _RightFile.fromJson(Map<String, dynamic> json) => _RightFile(
        line: json['line'] as int,
        offset: json['offset'] as int,
      );

  final int line;
  final int offset;
}

enum ThreadStatus {
  active('Active', 1),
  byDesign('By design', 6),
  closed('Closed', 4),
  fixed('Resolved', 2),
  pending('Pending', 6),
  unknown('Unknown', 6),
  wontFix("Wont't fix", 3);

  const ThreadStatus(this.description, this.intValue);

  final String description;
  final int intValue;

  static ThreadStatus fromString(String? str) {
    switch (str) {
      case 'active':
        return ThreadStatus.active;
      case 'byDesign':
        return ThreadStatus.byDesign;
      case 'closed':
        return ThreadStatus.closed;
      case 'fixed':
        return ThreadStatus.fixed;
      case 'pending':
        return ThreadStatus.pending;
      case 'wontFix':
        return ThreadStatus.wontFix;
      default:
        return ThreadStatus.unknown;
    }
  }
}

sealed class PullRequestUpdate {
  PullRequestUpdate({required this.date, required this.author, required this.identity, required this.content});

  final DateTime date;
  final _Author author;
  final dynamic identity;
  final String content;
}

final class ThreadUpdate extends PullRequestUpdate {
  ThreadUpdate({
    required super.date,
    required super.author,
    required super.identity,
    required super.content,
    required this.id,
    required this.comments,
    this.threadContext,
    this.status,
  });

  final int id;
  final List<PrComment> comments;
  final ThreadContext? threadContext;
  final ThreadStatus? status;

  ThreadUpdate copyWith({String? content, List<PrComment>? comments}) => ThreadUpdate(
        id: id,
        content: content ?? this.content,
        author: author,
        date: date,
        identity: identity,
        comments: comments ?? this.comments,
        threadContext: threadContext,
        status: status,
      );
}

final class IterationUpdate extends PullRequestUpdate {
  IterationUpdate({
    required super.date,
    required super.author,
    super.identity,
    required super.content,
    required this.id,
    required this.commits,
  });

  final int id;
  final List<Commit> commits;
}

final class VoteUpdate extends PullRequestUpdate {
  VoteUpdate({required super.date, required super.author, required super.identity, required super.content});
}

final class StatusUpdate extends PullRequestUpdate {
  StatusUpdate({required super.date, required super.author, required super.identity, required super.content});
}

final class SystemUpdate extends PullRequestUpdate {
  SystemUpdate({required super.date, required super.author, required super.identity, required super.content});
}
