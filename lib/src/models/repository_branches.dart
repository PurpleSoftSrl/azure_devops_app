// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:http/http.dart';

class RepositoryBranchesResponse {
  RepositoryBranchesResponse({
    required this.count,
    required this.branches,
  });

  factory RepositoryBranchesResponse.fromJson(Map<String, dynamic> json) => RepositoryBranchesResponse(
        count: json['count'] as int,
        branches:
            List<Branch>.from((json['value'] as List<dynamic>).map((b) => Branch.fromJson(b as Map<String, dynamic>))),
      );

  static List<Branch> fromResponse(Response res) =>
      RepositoryBranchesResponse.fromJson(json.decode(res.body) as Map<String, dynamic>).branches;

  final int count;
  final List<Branch> branches;
}

class Branch {
  Branch({
    required this.commit,
    required this.name,
    required this.aheadCount,
    required this.behindCount,
    required this.isBaseVersion,
  });

  factory Branch.fromRawJson(String str) => Branch.fromJson(json.decode(str) as Map<String, dynamic>);

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        commit: _Commit.fromJson(json['commit'] as Map<String, dynamic>),
        name: json['name'] as String,
        aheadCount: json['aheadCount'] as int,
        behindCount: json['behindCount'] as int,
        isBaseVersion: json['isBaseVersion'] as bool,
      );

  final _Commit commit;
  final String name;
  final int aheadCount;
  final int behindCount;
  final bool isBaseVersion;

  @override
  String toString() {
    return 'Branch(commit: $commit, name: $name, aheadCount: $aheadCount, behindCount: $behindCount, isBaseVersion: $isBaseVersion)';
  }
}

class _Commit {
  _Commit({
    required this.commitId,
    required this.author,
    required this.committer,
    required this.comment,
    required this.url,
    this.treeId,
    this.parents,
  });

  factory _Commit.fromJson(Map<String, dynamic> json) => _Commit(
        commitId: json['commitId'] as String,
        author: _Author.fromJson(json['author'] as Map<String, dynamic>),
        committer: _Author.fromJson(json['committer'] as Map<String, dynamic>),
        comment: json['comment'] as String,
        url: json['url'] as String,
        treeId: json['treeId'] as String?,
        parents: json['parents'] == null ? [] : List<String>.from((json['parents'] as List<dynamic>).map((x) => x)),
      );

  final String commitId;
  final _Author author;
  final _Author committer;
  final String comment;
  final String url;
  final String? treeId;
  final List<String>? parents;
}

class _Author {
  _Author({
    required this.name,
    required this.email,
    required this.date,
  });

  factory _Author.fromJson(Map<String, dynamic> json) => _Author(
        name: json['name'] as String,
        email: json['email'] as String?,
        date: json['date'] == null ? null : DateTime.parse(json['date'].toString()).toLocal(),
      );

  final String name;
  final String? email;
  final DateTime? date;
}
