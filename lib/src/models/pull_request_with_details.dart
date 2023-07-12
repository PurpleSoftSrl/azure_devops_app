import 'dart:convert';

import 'package:azure_devops/src/models/commit.dart';
import 'package:azure_devops/src/models/pull_request.dart';
import 'package:http/http.dart';

class PullRequestWithDetails {
  PullRequestWithDetails({
    required this.pr,
    required this.changes,
    required this.updates,
    required this.conflicts,
  });

  final PullRequest pr;
  final List<CommitWithChangeEntry> changes;
  final List<PullRequestUpdate> updates;
  final List<Conflict> conflicts;

  PullRequestWithDetails copyWith({
    PullRequest? pr,
    List<CommitWithChangeEntry>? changes,
    List<PullRequestUpdate>? updates,
    List<Conflict>? conflicts,
  }) {
    return PullRequestWithDetails(
      pr: pr ?? this.pr,
      changes: changes ?? this.changes,
      updates: updates ?? this.updates,
      conflicts: conflicts ?? this.conflicts,
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
        author: Author.fromJson(json['author'] as Map<String, dynamic>),
        createdDate: DateTime.parse(json['createdDate']!.toString()).toLocal(),
        updatedDate: DateTime.parse(json['updatedDate']!.toString()).toLocal(),
        sourceRefCommit: RefCommit.fromJson(json['sourceRefCommit'] as Map<String, dynamic>),
        commonRefCommit: RefCommit.fromJson(json['commonRefCommit'] as Map<String, dynamic>),
        commits: (json['commits'] as List<dynamic>?)?.map((e) => Commit.fromJson(e as Map<String, dynamic>)).toList(),
      );

  final int id;
  final String description;
  final Author author;
  final DateTime createdDate;
  final DateTime updatedDate;
  final RefCommit sourceRefCommit;
  final RefCommit commonRefCommit;
  final List<Commit>? commits;
}

class Author {
  Author({
    required this.displayName,
    required this.id,
    required this.uniqueName,
    required this.descriptor,
  });

  factory Author.fromJson(Map<String, dynamic> json) => Author(
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

class RefCommit {
  RefCommit({required this.commitId});

  factory RefCommit.fromJson(Map<String, dynamic> json) => RefCommit(commitId: json['commitId'] as String);

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
        item: Item.fromJson(json['item'] as Map<String, dynamic>),
        changeType: json['changeType'] as String,
        originalPath: json['originalPath'] as String?,
      );

  final int changeTrackingId;
  final int changeId;
  final Item item;
  final String changeType;
  final String? originalPath;
}

class Item {
  Item({this.objectId, this.originalObjectId, this.path});

  factory Item.fromJson(Map<String, dynamic> json) => Item(
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
  });

  factory Thread.fromJson(Map<String, dynamic> json) => Thread(
        id: json['id'] as int,
        publishedDate: DateTime.parse(json['publishedDate']!.toString()).toLocal(),
        lastUpdatedDate: DateTime.parse(json['lastUpdatedDate']!.toString()).toLocal(),
        comments: List<Comment>.from(
          (json['comments'] as List<dynamic>).map((c) => Comment.fromJson(c as Map<String, dynamic>)),
        ),
        isDeleted: json['isDeleted'] as bool,
        properties: json['properties'] == null ? null : Properties.fromJson(json['properties'] as Map<String, dynamic>),
        identities: json['identities'] == null ? null : json['identities'] as Map<String, dynamic>,
      );

  final int id;
  final DateTime publishedDate;
  final DateTime lastUpdatedDate;
  final List<Comment> comments;
  final bool isDeleted;
  final Properties? properties;
  final Map<String, dynamic>? identities;

  Thread copyWith({List<Comment>? comments}) {
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

class Properties {
  Properties({this.type, this.newCommits, this.newCommitsCount});

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
        type: json['CodeReviewThreadType'] == null
            ? null
            : Property.fromJson(json['CodeReviewThreadType'] as Map<String, dynamic>),
        newCommits: json['CodeReviewRefNewCommits'] == null
            ? null
            : Property.fromJson(json['CodeReviewRefNewCommits'] as Map<String, dynamic>),
        newCommitsCount: json['CodeReviewRefNewCommitsCount'] == null
            ? null
            : Property.fromJson(json['CodeReviewRefNewCommitsCount'] as Map<String, dynamic>),
      );

  final Property<String>? type;
  final Property<String>? newCommits;
  final Property<int>? newCommitsCount;
}

class Property<T> {
  Property({required this.type, required this.value});

  factory Property.fromJson(Map<String, dynamic> json) => Property(
        type: json['\u0024type'] as String,
        value: json['\u0024value'] as T,
      );
  final String type;
  final T value;
}

class Comment {
  Comment({
    required this.id,
    required this.parentCommentId,
    required this.author,
    required this.content,
    required this.publishedDate,
    required this.lastUpdatedDate,
    required this.commentType,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'] as int,
        parentCommentId: json['parentCommentId'] as int,
        author: Author.fromJson(json['author'] as Map<String, dynamic>),
        content: json['content'] as String? ?? '',
        publishedDate: DateTime.parse(json['publishedDate']!.toString()).toLocal(),
        lastUpdatedDate: DateTime.parse(json['lastUpdatedDate']!.toString()).toLocal(),
        commentType: json['commentType'] as String,
      );

  final int id;
  final int parentCommentId;
  final Author author;
  final String content;
  final DateTime publishedDate;
  final DateTime lastUpdatedDate;
  final String commentType;

  Comment copyWith({String? content}) {
    return Comment(
      id: id,
      parentCommentId: parentCommentId,
      author: author,
      content: content ?? this.content,
      publishedDate: publishedDate,
      lastUpdatedDate: lastUpdatedDate,
      commentType: commentType,
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

sealed class PullRequestUpdate {
  PullRequestUpdate({required this.date, required this.author, required this.identity, required this.content});

  final DateTime date;
  final Author author;
  final dynamic identity;
  final String content;
}

final class CommentUpdate extends PullRequestUpdate {
  CommentUpdate({
    required super.date,
    required super.author,
    required super.identity,
    required super.content,
    required this.updatedDate,
    required this.parentCommentId,
  });

  final DateTime updatedDate;
  final int parentCommentId;

  CommentUpdate copyWith({String? content}) => CommentUpdate(
        content: content ?? this.content,
        author: author,
        date: date,
        identity: identity,
        parentCommentId: parentCommentId,
        updatedDate: updatedDate,
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
