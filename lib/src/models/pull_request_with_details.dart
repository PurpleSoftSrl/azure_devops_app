import 'dart:convert';

import 'package:azure_devops/src/models/pull_request.dart';
import 'package:http/http.dart';

class PullRequestWithDetails {
  PullRequestWithDetails({
    required this.pr,
    required this.changes,
    required this.threads,
  });

  final PullRequest pr;
  final List<CommitWithChangeEntry> changes;
  final List<Thread> threads;
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
  });

  factory Iteration.fromRawJson(String str) => Iteration.fromJson(json.decode(str) as Map<String, dynamic>);

  factory Iteration.fromJson(Map<String, dynamic> json) => Iteration(
        id: json['id'] as int,
        description: json['description'] as String,
        author: Author.fromJson(json['author'] as Map<String, dynamic>),
        createdDate: DateTime.parse(json['createdDate']!.toString()).toLocal(),
        updatedDate: DateTime.parse(json['updatedDate']!.toString()).toLocal(),
        sourceRefCommit: RefCommit.fromJson(json['sourceRefCommit'] as Map<String, dynamic>),
      );

  final int id;
  final String description;
  final Author author;
  final DateTime createdDate;
  final DateTime updatedDate;
  final RefCommit sourceRefCommit;
}

class Author {
  Author({
    required this.displayName,
    required this.id,
    required this.uniqueName,
    required this.descriptor,
  });

  factory Author.fromRawJson(String str) => Author.fromJson(json.decode(str) as Map<String, dynamic>);

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

  factory RefCommit.fromRawJson(String str) => RefCommit.fromJson(json.decode(str) as Map<String, dynamic>);

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
  });

  factory ChangeEntry.fromRawJson(String str) => ChangeEntry.fromJson(json.decode(str) as Map<String, dynamic>);

  factory ChangeEntry.fromJson(Map<String, dynamic> json) => ChangeEntry(
        changeTrackingId: json['changeTrackingId'] as int,
        changeId: json['changeId'] as int,
        item: Item.fromJson(json['item'] as Map<String, dynamic>),
        changeType: json['changeType'] as String,
      );

  final int changeTrackingId;
  final int changeId;
  final Item item;
  final String changeType;
}

class Item {
  Item({this.objectId, this.originalObjectId, this.path});

  factory Item.fromRawJson(String str) => Item.fromJson(json.decode(str) as Map<String, dynamic>);

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

  factory Thread.fromRawJson(String str) => Thread.fromJson(json.decode(str) as Map<String, dynamic>);

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
}

class Properties {
  Properties({this.type, this.newCommits, this.newCommitsCount});

  factory Properties.fromRawJson(String str) => Properties.fromJson(json.decode(str) as Map<String, dynamic>);

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

  factory Property.fromRawJson(String str) => Property.fromJson(json.decode(str) as Map<String, dynamic>);

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

  factory Comment.fromRawJson(String str) => Comment.fromJson(json.decode(str) as Map<String, dynamic>);

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
}
