import 'dart:convert';

import 'package:azure_devops/src/models/commit_detail.dart';
import 'package:azure_devops/src/models/commits_tags.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class GetCommitsResponse {
  GetCommitsResponse({required this.commits});

  factory GetCommitsResponse.fromJson(Map<String, dynamic> source) =>
      GetCommitsResponse(commits: Commit.listFromJson(json.decode(jsonEncode(source['value'])))!);

  static List<Commit> fromResponse(Response res) =>
      GetCommitsResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).commits;

  final List<Commit> commits;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GetCommitsResponse && listEquals(other.commits, commits);
  }

  @override
  int get hashCode => commits.hashCode;
}

class CommitWithChanges {
  CommitWithChanges({required this.commit, required this.changes});

  final Commit commit;
  final CommitChanges? changes;

  @override
  String toString() => 'CommitWithChanges(commit: $commit, changes: $changes)';
}

class Commit {
  Commit({
    this.commitId,
    this.author,
    this.committer,
    this.comment,
    this.changeCounts,
    this.url,
    this.remoteUrl,
    this.parents,
  });

  factory Commit.fromResponse(Response res) => Commit.fromJson(jsonDecode(res.body) as Map<String, dynamic>);

  factory Commit.fromJson(Map<String, dynamic> json) => Commit(
        commitId: json['commitId'] as String?,
        author: Author.fromJson(json['author'] as Map<String, dynamic>),
        committer: Author.fromJson(json['committer'] as Map<String, dynamic>),
        comment: json['comment'] as String?,
        changeCounts:
            json['changeCounts'] == null ? null : _ChangeCounts.fromJson(json['changeCounts'] as Map<String, dynamic>),
        url: json['url'] as String?,
        remoteUrl: json['remoteUrl'] as String?,
        parents: json['parents'] == null ? null : List<String>.from(json['parents'] as List<dynamic>),
      );

  final String? commitId;
  final Author? author;
  final Author? committer;
  final String? comment;
  final _ChangeCounts? changeCounts;
  final String? url;
  final String? remoteUrl;
  final List<String>? parents;
  List<Tag>? tags;

  static Commit empty() {
    return Commit(
      author: Author(),
      remoteUrl: 'https://dev.azure.com/TestOrg/TestProject/_git/TestRepo/commit/testCommitId',
    );
  }

  Commit copyWithDateAndAuthorName(DateTime newDate, String newAuthorName) {
    return copyWith(author: author!.copyWith(date: newDate, name: newAuthorName));
  }

  static List<Commit>? listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <Commit>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Commit.fromJson(row as Map<String, dynamic>);
        result.add(value);
      }
    }
    return result.toList(growable: growable);
  }

  @override
  String toString() {
    return 'Commit(commitId: $commitId, author: $author, committer: $committer, comment: $comment, changeCounts: $changeCounts, url: $url, remoteUrl: $remoteUrl, parents: $parents)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Commit &&
        other.commitId == commitId &&
        other.author == author &&
        other.committer == committer &&
        other.comment == comment &&
        other.changeCounts == changeCounts &&
        other.url == url &&
        other.remoteUrl == remoteUrl;
  }

  @override
  int get hashCode {
    return commitId.hashCode ^
        author.hashCode ^
        committer.hashCode ^
        comment.hashCode ^
        changeCounts.hashCode ^
        url.hashCode ^
        remoteUrl.hashCode;
  }

  Commit copyWith({
    String? commitId,
    Author? author,
    Author? committer,
    String? comment,
    _ChangeCounts? changeCounts,
    String? url,
    String? remoteUrl,
  }) {
    return Commit(
      commitId: commitId ?? this.commitId,
      author: author ?? this.author,
      committer: committer ?? this.committer,
      comment: comment ?? this.comment,
      changeCounts: changeCounts ?? this.changeCounts,
      url: url ?? this.url,
      remoteUrl: remoteUrl ?? this.remoteUrl,
    );
  }
}

class Author {
  Author({
    this.name,
    this.email,
    this.date,
    this.imageUrl,
  });

  factory Author.fromJson(Map<String, dynamic> json) => Author(
        name: json['name'] as String?,
        email: json['email'] as String?,
        date: json['date'] == null ? null : DateTime.parse(json['date'].toString()).toLocal(),
        imageUrl: json['imageUrl'] as String?,
      );

  final String? name;
  final String? email;
  final DateTime? date;
  final String? imageUrl;

  Author copyWith({
    String? name,
    String? email,
    DateTime? date,
  }) {
    return Author(
      name: name ?? this.name,
      email: email ?? this.email,
      date: date ?? this.date,
    );
  }

  @override
  String toString() => 'Author(name: $name, email: $email, date: $date)';
}

class _ChangeCounts {
  _ChangeCounts({
    required this.add,
    required this.edit,
    required this.delete,
  });

  factory _ChangeCounts.fromJson(Map<String, dynamic> json) => _ChangeCounts(
        add: json['Add'] as int?,
        edit: json['Edit'] as int?,
        delete: json['Delete'] as int?,
      );

  final int? add;
  final int? edit;
  final int? delete;

  @override
  String toString() => '_ChangeCounts(add: $add, edit: $edit, delete: $delete)';
}
