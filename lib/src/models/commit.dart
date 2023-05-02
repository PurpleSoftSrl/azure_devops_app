import 'dart:convert';

import 'package:flutter/foundation.dart';

class GetCommitsResponse {
  GetCommitsResponse({required this.commits});

  factory GetCommitsResponse.fromJson(Map<String, dynamic> source) =>
      GetCommitsResponse(commits: Commit.listFromJson(json.decode(jsonEncode(source['value'])))!);

  final List<Commit> commits;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GetCommitsResponse && listEquals(other.commits, commits);
  }

  @override
  int get hashCode => commits.hashCode;
}

class Commit {
  factory Commit.fromJson(Map<String, dynamic> json) => Commit(
        commitId: json['commitId'] as String?,
        author: Author.fromJson(json['author'] as Map<String, dynamic>),
        committer: Author.fromJson(json['committer'] as Map<String, dynamic>),
        comment: json['comment'] as String?,
        changeCounts:
            json['changeCounts'] == null ? null : _ChangeCounts.fromJson(json['changeCounts'] as Map<String, dynamic>),
        url: json['url'] as String?,
        remoteUrl: json['remoteUrl'] as String?,
      );

  Commit({
    required this.commitId,
    required this.author,
    required this.committer,
    required this.comment,
    required this.changeCounts,
    required this.url,
    required this.remoteUrl,
  });

  final String? commitId;
  final Author? author;
  final Author? committer;
  final String? comment;
  final _ChangeCounts? changeCounts;
  final String? url;
  final String? remoteUrl;

  Map<String, dynamic> toJson() => {
        'commitId': commitId,
        'author': author!.toJson(),
        'committer': committer!.toJson(),
        'comment': comment,
        'changeCounts': changeCounts!.toJson(),
        'url': url,
        'remoteUrl': remoteUrl,
      };

  static Commit empty() {
    return Commit(
      commitId: null,
      author: Author(name: null, email: null, date: null),
      committer: null,
      comment: null,
      changeCounts: null,
      url: null,
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
    return 'Commit(commitId: $commitId, author: $author, committer: $committer, comment: $comment, changeCounts: $changeCounts, url: $url, remoteUrl: $remoteUrl)';
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
  factory Author.fromJson(Map<String, dynamic> json) => Author(
        name: json['name'] as String?,
        email: json['email'] as String?,
        date: DateTime.tryParse(json['date']?.toString() ?? '')?.toLocal(),
      );

  Author({
    required this.name,
    required this.email,
    required this.date,
  });

  final String? name;
  final String? email;
  final DateTime? date;

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'date': date?.toIso8601String(),
      };

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
  factory _ChangeCounts.fromJson(Map<String, dynamic> json) => _ChangeCounts(
        add: json['Add'] as int?,
        edit: json['Edit'] as int?,
        delete: json['Delete'] as int?,
      );

  _ChangeCounts({
    required this.add,
    required this.edit,
    required this.delete,
  });

  final int? add;
  final int? edit;
  final int? delete;

  Map<String, dynamic> toJson() => {
        'Add': add,
        'Edit': edit,
        'Delete': delete,
      };

  @override
  String toString() => '_ChangeCounts(add: $add, edit: $edit, delete: $delete)';
}
