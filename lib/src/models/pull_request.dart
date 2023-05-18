import 'package:azure_devops/src/models/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GetPullRequestsResponse {
  factory GetPullRequestsResponse.fromJson(Map<String, dynamic> json) => GetPullRequestsResponse(
        pullRequests: List<PullRequest>.from(
          (json['value'] as List<dynamic>).map((e) => PullRequest.fromJson(e as Map<String, dynamic>)),
        ),
        count: json['count'] as int,
      );
  GetPullRequestsResponse({
    required this.pullRequests,
    required this.count,
  });

  final List<PullRequest> pullRequests;
  final int count;

  @override
  String toString() => 'GetPullRequestsResponse(pullRequests: $pullRequests, count: $count)';
}

class PullRequest {
  factory PullRequest.fromJson(Map<String, dynamic> json) => PullRequest(
        repository: _Repository.fromJson(json['repository'] as Map<String, dynamic>),
        pullRequestId: json['pullRequestId'] as int,
        codeReviewId: json['codeReviewId'] as int,
        status: PullRequestState.fromString(json['status'] as String),
        createdBy: _CreatedBy.fromJson(json['createdBy'] as Map<String, dynamic>),
        creationDate: DateTime.parse(json['creationDate']!.toString()).toLocal(),
        title: json['title'] as String,
        description: json['description'] as String?,
        sourceRefName: json['sourceRefName'] as String,
        targetRefName: json['targetRefName'] as String,
        mergeStatus: json['mergeStatus'] as String?,
        isDraft: json['isDraft'] as bool,
        mergeId: json['mergeId'] as String,
        lastMergeSourceCommit: _LastMergeCommit.fromJson(json['lastMergeSourceCommit'] as Map<String, dynamic>),
        lastMergeTargetCommit: _LastMergeCommit.fromJson(json['lastMergeTargetCommit'] as Map<String, dynamic>),
        lastMergeCommit: json['lastMergeCommit'] == null
            ? null
            : _LastMergeCommit.fromJson(json['lastMergeCommit'] as Map<String, dynamic>),
        reviewers: List<Reviewer>.from(
          (json['reviewers'] as List<dynamic>).map((e) => Reviewer.fromJson(e as Map<String, dynamic>)),
        ),
        labels: (json['labels'] as List<dynamic>?)?.map((e) => _Label.fromJson(e as Map<String, dynamic>)).toList(),
        url: json['url'] as String,
        supportsIterations: json['supportsIterations'] as bool,
      );

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
    required this.mergeStatus,
    required this.isDraft,
    required this.mergeId,
    required this.lastMergeSourceCommit,
    required this.lastMergeTargetCommit,
    required this.lastMergeCommit,
    required this.reviewers,
    required this.labels,
    required this.url,
    required this.supportsIterations,
  });

  final _Repository repository;
  final int pullRequestId;
  final int codeReviewId;
  final PullRequestState status;
  final _CreatedBy createdBy;
  final DateTime creationDate;
  final String title;
  final String? description;
  final String sourceRefName;
  final String targetRefName;
  final String? mergeStatus;
  final bool isDraft;
  final String mergeId;
  final _LastMergeCommit lastMergeSourceCommit;
  final _LastMergeCommit lastMergeTargetCommit;
  final _LastMergeCommit? lastMergeCommit;
  final List<Reviewer> reviewers;
  final List<_Label>? labels;
  final String url;
  final bool supportsIterations;

  @override
  String toString() {
    return 'PullRequest(repository: $repository, pullRequestId: $pullRequestId, codeReviewId: $codeReviewId, status: $status, createdBy: $createdBy, creationDate: $creationDate, title: $title, description: $description, sourceRefName: $sourceRefName, targetRefName: $targetRefName, mergeStatus: $mergeStatus, isDraft: $isDraft, mergeId: $mergeId, lastMergeSourceCommit: $lastMergeSourceCommit, lastMergeTargetCommit: $lastMergeTargetCommit, lastMergeCommit: $lastMergeCommit, reviewers: $reviewers, labels: $labels, url: $url, supportsIterations: $supportsIterations)';
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
        other.lastMergeSourceCommit == lastMergeSourceCommit &&
        other.lastMergeTargetCommit == lastMergeTargetCommit &&
        other.lastMergeCommit == lastMergeCommit &&
        listEquals(other.reviewers, reviewers) &&
        listEquals(other.labels, labels) &&
        other.url == url &&
        other.supportsIterations == supportsIterations;
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
        lastMergeSourceCommit.hashCode ^
        lastMergeTargetCommit.hashCode ^
        lastMergeCommit.hashCode ^
        reviewers.hashCode ^
        labels.hashCode ^
        url.hashCode ^
        supportsIterations.hashCode;
  }
}

class _CreatedBy {
  factory _CreatedBy.fromJson(Map<String, dynamic> json) => _CreatedBy(
        displayName: json['displayName'] as String,
        url: json['url'] as String,
        links: json['Links'] == null ? null : Links.fromJson(json['Links'] as Map<String, dynamic>),
        id: json['id'] as String,
        uniqueName: json['uniqueName'] as String,
        imageUrl: json['imageUrl'] as String,
        descriptor: json['descriptor'] as String,
      );

  _CreatedBy({
    required this.displayName,
    required this.url,
    required this.links,
    required this.id,
    required this.uniqueName,
    required this.imageUrl,
    required this.descriptor,
  });

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
  factory _Label.fromJson(Map<String, dynamic> json) => _Label(
        id: json['id'] as String,
        name: json['name'] as String,
        active: json['active'] as bool,
      );
  _Label({
    required this.id,
    required this.name,
    required this.active,
  });

  final String id;
  final String name;
  final bool active;

  @override
  String toString() => '_Label(id: $id, name: $name, active: $active)';
}

class _LastMergeCommit {
  factory _LastMergeCommit.fromJson(Map<String, dynamic> json) => _LastMergeCommit(
        commitId: json['commitId'] as String,
        url: json['url'] as String,
      );
  _LastMergeCommit({
    required this.commitId,
    required this.url,
  });

  final String commitId;
  final String url;

  @override
  String toString() => '_LastMergeCommit(commitId: $commitId, url: $url)';
}

class _Repository {
  factory _Repository.fromJson(Map<String, dynamic> json) => _Repository(
        id: json['id'] as String,
        name: json['name'] as String,
        url: json['url'] as String,
        project: _Project.fromJson(json['project'] as Map<String, dynamic>),
      );
  _Repository({
    required this.id,
    required this.name,
    required this.url,
    required this.project,
  });

  final String id;
  final String name;
  final String url;
  final _Project project;

  @override
  String toString() {
    return '_Repository(id: $id, name: $name, url: $url, project: $project)';
  }
}

class _Project {
  factory _Project.fromJson(Map<String, dynamic> json) => _Project(
        id: json['id'] as String,
        name: json['name'] as String,
        state: json['state'] as String,
        visibility: json['visibility'] as String,
        lastUpdateTime: DateTime.parse(json['lastUpdateTime']!.toString()).toLocal(),
      );
  _Project({
    required this.id,
    required this.name,
    required this.state,
    required this.visibility,
    required this.lastUpdateTime,
  });

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
        throw 'Unknown enum value: $str';
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
        throw 'Unknown enum value: $this';
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
        throw 'Unknown enum value: $this';
    }
  }
}

class Reviewer {
  factory Reviewer.fromJson(Map<String, dynamic> json) => Reviewer(
        reviewerUrl: json['reviewerUrl'] as String,
        vote: json['vote'] as int,
        hasDeclined: json['hasDeclined'] as bool,
        isFlagged: json['isFlagged'] as bool,
        isRequired: json['isRequired'] as bool? ?? false,
        displayName: json['displayName'] as String,
        url: json['url'] as String,
        links: json['Links'] == null ? null : Links.fromJson(json['Links'] as Map<String, dynamic>),
        id: json['id'] as String,
        uniqueName: json['uniqueName'] as String,
        imageUrl: json['imageUrl'] as String,
      );

  Reviewer({
    required this.reviewerUrl,
    required this.vote,
    required this.hasDeclined,
    required this.isFlagged,
    required this.isRequired,
    required this.displayName,
    required this.url,
    required this.links,
    required this.id,
    required this.uniqueName,
    required this.imageUrl,
  });

  final String reviewerUrl;
  final int vote;
  final bool hasDeclined;
  final bool isFlagged;
  final bool isRequired;
  final String displayName;
  final String url;
  final Links? links;
  final String id;
  final String uniqueName;
  final String imageUrl;

  @override
  String toString() {
    return '_Reviewer(reviewerUrl: $reviewerUrl, vote: $vote, hasDeclined: $hasDeclined, isFlagged: $isFlagged, isRequired: $isRequired, displayName: $displayName, url: $url, links: $links, id: $id, uniqueName: $uniqueName, imageUrl: $imageUrl)';
  }
}
