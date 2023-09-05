// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:azure_devops/src/models/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

typedef PullRequestCompletionOptions = ({
  String? commitMessage,
  bool completeWorkItems,
  bool deleteSourceBranch,
  int mergeType
});

class GetPullRequestsResponse {
  GetPullRequestsResponse({required this.pullRequests});

  factory GetPullRequestsResponse.fromJson(Map<String, dynamic> json) => GetPullRequestsResponse(
        pullRequests:
            (json['value'] as List<dynamic>).map((e) => PullRequest.fromJson(e as Map<String, dynamic>)).toList(),
      );

  static List<PullRequest> fromResponse(Response res) =>
      GetPullRequestsResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).pullRequests;

  final List<PullRequest> pullRequests;
}

class PullRequest {
  PullRequest({
    required this.repository,
    required this.pullRequestId,
    required this.codeReviewId,
    required this.status,
    required this.createdBy,
    required this.creationDate,
    required this.title,
    this.description,
    required this.sourceRefName,
    required this.targetRefName,
    this.mergeStatus,
    required this.isDraft,
    required this.mergeId,
    required this.reviewers,
    this.labels,
    this.autoCompleteSetBy,
  });

  factory PullRequest.fromJson(Map<String, dynamic> json) => PullRequest(
        repository: Repository.fromJson(json['repository'] as Map<String, dynamic>),
        pullRequestId: json['pullRequestId'] as int,
        codeReviewId: json['codeReviewId'] as int,
        status: PullRequestState.fromString(json['status'] as String),
        createdBy: CreatedBy.fromJson(json['createdBy'] as Map<String, dynamic>),
        creationDate: DateTime.parse(json['creationDate']!.toString()).toLocal(),
        title: json['title'] as String,
        description: json['description'] as String?,
        sourceRefName: json['sourceRefName'] as String,
        targetRefName: json['targetRefName'] as String,
        mergeStatus: json['mergeStatus'] as String?,
        isDraft: json['isDraft'] as bool,
        mergeId: json['mergeId'] as String,
        reviewers: List<Reviewer>.from(
          (json['reviewers'] as List<dynamic>).map((e) => Reviewer.fromJson(e as Map<String, dynamic>)),
        ),
        labels: (json['labels'] as List<dynamic>?)?.map((e) => _Label.fromJson(e as Map<String, dynamic>)).toList(),
        autoCompleteSetBy: json['autoCompleteSetBy'] == null
            ? null
            : AutoCompleteSetBy.fromJson(json['autoCompleteSetBy'] as Map<String, dynamic>),
      );

  static PullRequest fromResponse(Response res) => PullRequest.fromJson(jsonDecode(res.body) as Map<String, dynamic>);

  final Repository repository;
  final int pullRequestId;
  final int codeReviewId;
  final PullRequestState status;
  final CreatedBy createdBy;
  final DateTime creationDate;
  final String title;
  final String? description;
  final String sourceRefName;
  final String targetRefName;
  final String? mergeStatus;
  final bool isDraft;
  final String mergeId;
  final List<Reviewer> reviewers;
  final List<_Label>? labels;
  final AutoCompleteSetBy? autoCompleteSetBy;

  @visibleForTesting
  static PullRequest empty() => PullRequest(
        repository: Repository(
          id: '',
          name: '',
          url: '',
          project: RepositoryProject(
            id: '',
            name: '',
            state: '',
            visibility: '',
            lastUpdateTime: DateTime.now(),
          ),
        ),
        pullRequestId: -1,
        codeReviewId: -1,
        status: PullRequestState.notSet,
        createdBy: CreatedBy(
          displayName: '',
          url: '',
          links: Links(
            self: Avatar(href: ''),
            memberships: Avatar(href: ''),
            membershipState: Avatar(href: ''),
            storageKey: Avatar(href: ''),
            avatar: Avatar(href: ''),
          ),
          id: '',
          uniqueName: '',
          imageUrl: '',
          descriptor: '',
        ),
        creationDate: DateTime.now(),
        title: '',
        sourceRefName: '',
        targetRefName: '',
        isDraft: false,
        mergeId: '',
        reviewers: [],
      );

  @override
  String toString() {
    return 'PullRequest(repository: $repository, pullRequestId: $pullRequestId, codeReviewId: $codeReviewId, status: $status, createdBy: $createdBy, creationDate: $creationDate, title: $title, description: $description, sourceRefName: $sourceRefName, targetRefName: $targetRefName, mergeStatus: $mergeStatus, isDraft: $isDraft, mergeId: $mergeId, reviewers: $reviewers, labels: $labels)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PullRequest &&
        other.repository == repository &&
        other.pullRequestId == pullRequestId &&
        other.codeReviewId == codeReviewId &&
        other.status == status &&
        other.createdBy == createdBy &&
        other.creationDate == creationDate &&
        other.title == title &&
        other.description == description &&
        other.sourceRefName == sourceRefName &&
        other.targetRefName == targetRefName &&
        other.mergeStatus == mergeStatus &&
        other.isDraft == isDraft &&
        other.mergeId == mergeId &&
        listEquals(other.reviewers, reviewers) &&
        listEquals(other.labels, labels);
  }

  @override
  int get hashCode {
    return repository.hashCode ^
        pullRequestId.hashCode ^
        codeReviewId.hashCode ^
        status.hashCode ^
        createdBy.hashCode ^
        creationDate.hashCode ^
        title.hashCode ^
        description.hashCode ^
        sourceRefName.hashCode ^
        targetRefName.hashCode ^
        mergeStatus.hashCode ^
        isDraft.hashCode ^
        mergeId.hashCode ^
        reviewers.hashCode ^
        labels.hashCode;
  }

  PullRequest copyWith({
    Repository? repository,
    int? pullRequestId,
    PullRequestState? status,
    CreatedBy? createdBy,
    DateTime? creationDate,
    String? title,
    String? description,
  }) {
    return PullRequest(
      codeReviewId: codeReviewId,
      sourceRefName: sourceRefName,
      targetRefName: targetRefName,
      isDraft: isDraft,
      mergeId: mergeId,
      reviewers: reviewers,
      repository: repository ?? this.repository,
      pullRequestId: pullRequestId ?? this.pullRequestId,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      creationDate: creationDate ?? this.creationDate,
      title: title ?? this.title,
      description: description ?? this.description,
      labels: labels,
      mergeStatus: mergeStatus,
      autoCompleteSetBy: autoCompleteSetBy,
    );
  }
}

class AutoCompleteSetBy {
  AutoCompleteSetBy({
    required this.displayName,
    required this.id,
    required this.uniqueName,
    required this.descriptor,
  });

  factory AutoCompleteSetBy.fromJson(Map<String, dynamic> json) => AutoCompleteSetBy(
        descriptor: json['descriptor'] as String,
        displayName: json['displayName'] as String,
        id: json['id'] as String,
        uniqueName: json['uniqueName'] as String,
      );

  final String displayName;
  final String id;
  final String uniqueName;
  final String descriptor;
}

class CreatedBy {
  CreatedBy({
    required this.displayName,
    required this.url,
    this.links,
    required this.id,
    required this.uniqueName,
    required this.imageUrl,
    required this.descriptor,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
        displayName: json['displayName'] as String,
        url: json['url'] as String,
        links: json['Links'] == null ? null : Links.fromJson(json['Links'] as Map<String, dynamic>),
        id: json['id'] as String,
        uniqueName: json['uniqueName'] as String,
        imageUrl: json['imageUrl'] as String,
        descriptor: json['descriptor'] as String,
      );

  final String displayName;
  final String url;
  final Links? links;
  final String id;
  final String uniqueName;
  final String imageUrl;
  final String descriptor;

  @override
  String toString() {
    return '_CreatedBy(displayName: $displayName, url: $url, links: $links, id: $id, uniqueName: $uniqueName, imageUrl: $imageUrl, descriptor: $descriptor)';
  }
}

class _Label {
  _Label({
    required this.id,
    required this.name,
    required this.active,
  });

  factory _Label.fromJson(Map<String, dynamic> json) => _Label(
        id: json['id'] as String,
        name: json['name'] as String,
        active: json['active'] as bool,
      );

  final String id;
  final String name;
  final bool active;

  @override
  String toString() => '_Label(id: $id, name: $name, active: $active)';
}

class Repository {
  Repository({
    required this.id,
    required this.name,
    required this.url,
    required this.project,
  });

  factory Repository.fromJson(Map<String, dynamic> json) => Repository(
        id: json['id'] as String,
        name: json['name'] as String,
        url: json['url'] as String,
        project: RepositoryProject.fromJson(json['project'] as Map<String, dynamic>),
      );

  final String id;
  final String name;
  final String url;
  final RepositoryProject project;

  @override
  String toString() {
    return '_Repository(id: $id, name: $name, url: $url, project: $project)';
  }
}

class RepositoryProject {
  RepositoryProject({
    required this.id,
    required this.name,
    required this.state,
    required this.visibility,
    required this.lastUpdateTime,
  });

  factory RepositoryProject.fromJson(Map<String, dynamic> json) => RepositoryProject(
        id: json['id'] as String,
        name: json['name'] as String,
        state: json['state'] as String,
        visibility: json['visibility'] as String,
        lastUpdateTime: DateTime.parse(json['lastUpdateTime']!.toString()).toLocal(),
      );

  final String id;
  final String name;
  final String state;
  final String visibility;
  final DateTime lastUpdateTime;

  @override
  String toString() {
    return '_Project(id: $id, name: $name, state: $state, visibility: $visibility, lastUpdateTime: $lastUpdateTime)';
  }
}

enum PullRequestState {
  all,
  abandoned,
  active,
  completed,
  notSet;

  static PullRequestState fromString(String str) {
    switch (str) {
      case 'abandoned':
        return PullRequestState.abandoned;
      case 'active':
        return PullRequestState.active;
      case 'completed':
        return PullRequestState.completed;
      case 'notSet':
        return PullRequestState.notSet;
      case 'all':
        return PullRequestState.all;
      default:
        return PullRequestState.all;
    }
  }

  @override
  String toString() {
    switch (this) {
      case PullRequestState.abandoned:
        return 'Abandoned';
      case PullRequestState.active:
        return 'Active';
      case PullRequestState.completed:
        return 'Completed';
      case PullRequestState.notSet:
        return 'None';
      case PullRequestState.all:
        return 'All';
    }
  }

  Icon get icon {
    switch (this) {
      case PullRequestState.abandoned:
        return Icon(Icons.circle, color: color, size: 15);
      case PullRequestState.active:
        return Icon(Icons.circle, color: color, size: 15);
      case PullRequestState.completed:
        return Icon(Icons.circle, color: color, size: 15);
      case PullRequestState.notSet:
        return Icon(Icons.circle, color: color, size: 15);
      default:
        return Icon(Icons.circle, color: color, size: 15);
    }
  }

  Color get color {
    switch (this) {
      case PullRequestState.abandoned:
        return Color.fromRGBO(178, 178, 178, 1);
      case PullRequestState.active:
        return Color.fromRGBO(52, 120, 198, 1);
      case PullRequestState.completed:
        return Color.fromRGBO(82, 152, 66, 1);
      case PullRequestState.notSet:
        return Colors.transparent;
      default:
        return Colors.transparent;
    }
  }
}

class Reviewer {
  Reviewer({
    required this.vote,
    required this.hasDeclined,
    required this.isFlagged,
    required this.isRequired,
    required this.displayName,
    required this.id,
    required this.uniqueName,
  });

  factory Reviewer.fromJson(Map<String, dynamic> json) => Reviewer(
        vote: json['vote'] as int,
        hasDeclined: json['hasDeclined'] as bool,
        isFlagged: json['isFlagged'] as bool,
        isRequired: json['isRequired'] as bool? ?? false,
        displayName: json['displayName'] as String,
        id: json['id'] as String,
        uniqueName: json['uniqueName'] as String,
      );

  final int vote;
  final bool hasDeclined;
  final bool isFlagged;
  final bool isRequired;
  final String displayName;
  final String id;
  final String uniqueName;

  @override
  String toString() {
    return '_Reviewer(vote: $vote, hasDeclined: $hasDeclined, isFlagged: $isFlagged, isRequired: $isRequired, displayName: $displayName, id: $id, uniqueName: $uniqueName)';
  }

  Map<String, dynamic> toMap() {
    return {
      'vote': vote,
      'hasDeclined': hasDeclined,
      'isFlagged': isFlagged,
      'isRequired': isRequired,
      'id': id,
      'uniqueName': uniqueName,
    };
  }

  Reviewer copyWith({
    int? vote,
    bool? hasDeclined,
    bool? isFlagged,
    bool? isRequired,
    String? displayName,
    String? id,
    String? uniqueName,
  }) {
    return Reviewer(
      vote: vote ?? this.vote,
      hasDeclined: hasDeclined ?? this.hasDeclined,
      isFlagged: isFlagged ?? this.isFlagged,
      isRequired: isRequired ?? this.isRequired,
      displayName: displayName ?? this.displayName,
      id: id ?? this.id,
      uniqueName: uniqueName ?? this.uniqueName,
    );
  }
}
