import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:collection/collection.dart';

/// This class is responsible for persisting filters to local storage.
class FiltersService {
  FiltersService({required this.storageService, required this.apiService});

  final StorageService storageService;
  final AzureApiService apiService;

  String get organization => apiService.organization;

  WorkItemsFilters getWorkItemsSavedFilters() {
    final savedFilters = storageService.getFilters();

    final workItemsFilters = savedFilters
        .where(
          (f) => f.organization == organization && f.area == _FilterAreas.workItems,
        )
        .toList();

    return WorkItemsFilters(
      projects: workItemsFilters.firstWhereOrNull((f) => f.attribute == _FilterKeys.projects)?.filters ?? {},
      states: workItemsFilters.firstWhereOrNull((f) => f.attribute == _FilterKeys.states)?.filters ?? {},
      types: workItemsFilters.firstWhereOrNull((f) => f.attribute == _FilterKeys.types)?.filters ?? {},
      assignees: workItemsFilters.firstWhereOrNull((f) => f.attribute == _FilterKeys.assignees)?.filters ?? {},
      area: workItemsFilters.firstWhereOrNull((f) => f.attribute == _FilterKeys.area)?.filters ?? {},
      iteration: workItemsFilters.firstWhereOrNull((f) => f.attribute == _FilterKeys.iteration)?.filters ?? {},
    );
  }

  void saveWorkItemsProjectsFilter(Set<String> projectNames) {
    storageService.saveFilter(organization, _FilterAreas.workItems, _FilterKeys.projects, projectNames);
  }

  void saveWorkItemsStatesFilter(Set<String> stateNames) {
    storageService.saveFilter(organization, _FilterAreas.workItems, _FilterKeys.states, stateNames);
  }

  void saveWorkItemsTypesFilter(Set<String> typeNames) {
    storageService.saveFilter(organization, _FilterAreas.workItems, _FilterKeys.types, typeNames);
  }

  void saveWorkItemsAssigneesFilter(Set<String> userEmails) {
    storageService.saveFilter(organization, _FilterAreas.workItems, _FilterKeys.assignees, userEmails);
  }

  void saveWorkItemsAreaFilter(String area) {
    storageService.saveFilter(organization, _FilterAreas.workItems, _FilterKeys.area, {area});
  }

  void saveWorkItemsIterationFilter(String iteration) {
    storageService.saveFilter(organization, _FilterAreas.workItems, _FilterKeys.iteration, {iteration});
  }

  void resetWorkItemsFilters() {
    storageService.resetFilter(organization, _FilterAreas.workItems);
  }

  CommitsFilters getCommitsSavedFilters() {
    final savedFilters = storageService.getFilters();

    final commitsFilters = savedFilters
        .where(
          (f) => f.organization == organization && f.area == _FilterAreas.commits,
        )
        .toList();

    return CommitsFilters(
      projects: commitsFilters.firstWhereOrNull((f) => f.attribute == _FilterKeys.projects)?.filters ?? {},
      authors: commitsFilters.firstWhereOrNull((f) => f.attribute == _FilterKeys.authors)?.filters ?? {},
    );
  }

  void saveCommitsProjectsFilter(Set<String> projectNames) {
    storageService.saveFilter(organization, _FilterAreas.commits, _FilterKeys.projects, projectNames);
  }

  void saveCommitsAuthorsFilter(Set<String> userEmails) {
    storageService.saveFilter(organization, _FilterAreas.commits, _FilterKeys.authors, userEmails);
  }

  void resetCommitsFilters() {
    storageService.resetFilter(organization, _FilterAreas.commits);
  }

  PipelinesFilters getPipelinesSavedFilters() {
    final savedFilters = storageService.getFilters();

    final pipelinesFilters = savedFilters
        .where(
          (f) => f.organization == organization && f.area == _FilterAreas.pipelines,
        )
        .toList();

    return PipelinesFilters(
      projects: pipelinesFilters.firstWhereOrNull((f) => f.attribute == _FilterKeys.projects)?.filters ?? {},
      triggeredBy: pipelinesFilters.firstWhereOrNull((f) => f.attribute == _FilterKeys.triggeredBy)?.filters ?? {},
      result: pipelinesFilters.firstWhereOrNull((f) => f.attribute == _FilterKeys.result)?.filters ?? {},
      status: pipelinesFilters.firstWhereOrNull((f) => f.attribute == _FilterKeys.status)?.filters ?? {},
    );
  }

  void savePipelinesProjectsFilter(Set<String> projectNames) {
    storageService.saveFilter(organization, _FilterAreas.pipelines, _FilterKeys.projects, projectNames);
  }

  void savePipelinesTriggeredByFilter(Set<String> userEmails) {
    storageService.saveFilter(organization, _FilterAreas.pipelines, _FilterKeys.triggeredBy, userEmails);
  }

  void savePipelinesResultFilter(String result) {
    storageService.saveFilter(organization, _FilterAreas.pipelines, _FilterKeys.result, {result});
  }

  void savePipelinesStatusFilter(String status) {
    storageService.saveFilter(organization, _FilterAreas.pipelines, _FilterKeys.status, {status});
  }

  void resetPipelinesFilters() {
    storageService.resetFilter(organization, _FilterAreas.pipelines);
  }

  PullRequestsFilters getPullRequestsSavedFilters() {
    final savedFilters = storageService.getFilters();

    final pullRequestsFilters = savedFilters
        .where(
          (f) => f.organization == organization && f.area == _FilterAreas.pullRequests,
        )
        .toList();

    return PullRequestsFilters(
      projects: pullRequestsFilters.firstWhereOrNull((f) => f.attribute == _FilterKeys.projects)?.filters ?? {},
      status: pullRequestsFilters.firstWhereOrNull((f) => f.attribute == _FilterKeys.status)?.filters ?? {},
      openedBy: pullRequestsFilters.firstWhereOrNull((f) => f.attribute == _FilterKeys.openedBy)?.filters ?? {},
      assignedTo: pullRequestsFilters.firstWhereOrNull((f) => f.attribute == _FilterKeys.assignees)?.filters ?? {},
    );
  }

  void savePullRequestsProjectsFilter(Set<String> projectNames) {
    storageService.saveFilter(organization, _FilterAreas.pullRequests, _FilterKeys.projects, projectNames);
  }

  void savePullRequestsStatusFilter(String status) {
    storageService.saveFilter(organization, _FilterAreas.pullRequests, _FilterKeys.status, {status});
  }

  void savePullRequestsOpenedByFilter(Set<String> userEmails) {
    storageService.saveFilter(organization, _FilterAreas.pullRequests, _FilterKeys.openedBy, userEmails);
  }

  void savePullRequestsAssignedToFilter(Set<String> userEmails) {
    storageService.saveFilter(organization, _FilterAreas.pullRequests, _FilterKeys.assignees, userEmails);
  }

  void resetPullRequestsFilters() {
    storageService.resetFilter(organization, _FilterAreas.pullRequests);
  }
}

class WorkItemsFilters {
  WorkItemsFilters({
    required this.projects,
    required this.states,
    required this.types,
    required this.assignees,
    required this.area,
    required this.iteration,
  });

  final Set<String> projects;
  final Set<String> states;
  final Set<String> types;
  final Set<String> assignees;
  final Set<String> area;
  final Set<String> iteration;
}

class CommitsFilters {
  CommitsFilters({
    required this.projects,
    required this.authors,
  });

  final Set<String> projects;
  final Set<String> authors;
}

class PipelinesFilters {
  PipelinesFilters({
    required this.projects,
    required this.triggeredBy,
    required this.result,
    required this.status,
  });

  final Set<String> projects;
  final Set<String> triggeredBy;
  final Set<String> result;
  final Set<String> status;
}

class PullRequestsFilters {
  PullRequestsFilters({
    required this.projects,
    required this.status,
    required this.openedBy,
    required this.assignedTo,
  });

  final Set<String> projects;
  final Set<String> status;
  final Set<String> openedBy;
  final Set<String> assignedTo;
}

class _FilterAreas {
  static const workItems = 'work-items';
  static const commits = 'commits';
  static const pipelines = 'pipelines';
  static const pullRequests = 'pull-requests';
}

// TODO move keys in each area class
class _FilterKeys {
  static const projects = 'projects';
  static const states = 'states';
  static const types = 'types';
  static const assignees = 'assignees';
  static const area = 'area';
  static const iteration = 'iteration';
  static const authors = 'authors';
  static const triggeredBy = 'triggeredBy';
  static const result = 'result';
  static const status = 'status';
  static const openedBy = 'openedBy';
}
