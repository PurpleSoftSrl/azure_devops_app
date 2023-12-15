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
      projects: workItemsFilters.firstWhereOrNull((f) => f.attribute == WorkItemsFilters.projectsKey)?.filters ?? {},
      states: workItemsFilters.firstWhereOrNull((f) => f.attribute == WorkItemsFilters.statesKey)?.filters ?? {},
      types: workItemsFilters.firstWhereOrNull((f) => f.attribute == WorkItemsFilters.typesKey)?.filters ?? {},
      assignees: workItemsFilters.firstWhereOrNull((f) => f.attribute == WorkItemsFilters.assigneesKey)?.filters ?? {},
      area: workItemsFilters.firstWhereOrNull((f) => f.attribute == WorkItemsFilters.areaKey)?.filters ?? {},
      iteration: workItemsFilters.firstWhereOrNull((f) => f.attribute == WorkItemsFilters.iterationKey)?.filters ?? {},
    );
  }

  void saveWorkItemsProjectsFilter(Set<String> projectNames) {
    storageService.saveFilter(organization, _FilterAreas.workItems, WorkItemsFilters.projectsKey, projectNames);
  }

  void saveWorkItemsStatesFilter(Set<String> stateNames) {
    storageService.saveFilter(organization, _FilterAreas.workItems, WorkItemsFilters.statesKey, stateNames);
  }

  void saveWorkItemsTypesFilter(Set<String> typeNames) {
    storageService.saveFilter(organization, _FilterAreas.workItems, WorkItemsFilters.typesKey, typeNames);
  }

  void saveWorkItemsAssigneesFilter(Set<String> userEmails) {
    storageService.saveFilter(organization, _FilterAreas.workItems, WorkItemsFilters.assigneesKey, userEmails);
  }

  void saveWorkItemsAreaFilter(String area) {
    storageService.saveFilter(organization, _FilterAreas.workItems, WorkItemsFilters.areaKey, {area});
  }

  void saveWorkItemsIterationFilter(String iteration) {
    storageService.saveFilter(organization, _FilterAreas.workItems, WorkItemsFilters.iterationKey, {iteration});
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
      projects: commitsFilters.firstWhereOrNull((f) => f.attribute == CommitsFilters.projectsKey)?.filters ?? {},
      authors: commitsFilters.firstWhereOrNull((f) => f.attribute == CommitsFilters.authorsKey)?.filters ?? {},
    );
  }

  void saveCommitsProjectsFilter(Set<String> projectNames) {
    storageService.saveFilter(organization, _FilterAreas.commits, CommitsFilters.projectsKey, projectNames);
  }

  void saveCommitsAuthorsFilter(Set<String> userEmails) {
    storageService.saveFilter(organization, _FilterAreas.commits, CommitsFilters.authorsKey, userEmails);
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
      projects: pipelinesFilters.firstWhereOrNull((f) => f.attribute == PipelinesFilters.projectsKey)?.filters ?? {},
      triggeredBy:
          pipelinesFilters.firstWhereOrNull((f) => f.attribute == PipelinesFilters.triggeredByKey)?.filters ?? {},
      result: pipelinesFilters.firstWhereOrNull((f) => f.attribute == PipelinesFilters.resultKey)?.filters ?? {},
      status: pipelinesFilters.firstWhereOrNull((f) => f.attribute == PipelinesFilters.statusKey)?.filters ?? {},
    );
  }

  void savePipelinesProjectsFilter(Set<String> projectNames) {
    storageService.saveFilter(organization, _FilterAreas.pipelines, PipelinesFilters.projectsKey, projectNames);
  }

  void savePipelinesTriggeredByFilter(Set<String> userEmails) {
    storageService.saveFilter(organization, _FilterAreas.pipelines, PipelinesFilters.triggeredByKey, userEmails);
  }

  void savePipelinesResultFilter(String result) {
    storageService.saveFilter(organization, _FilterAreas.pipelines, PipelinesFilters.resultKey, {result});
  }

  void savePipelinesStatusFilter(String status) {
    storageService.saveFilter(organization, _FilterAreas.pipelines, PipelinesFilters.statusKey, {status});
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
      projects:
          pullRequestsFilters.firstWhereOrNull((f) => f.attribute == PullRequestsFilters.projectsKey)?.filters ?? {},
      status: pullRequestsFilters.firstWhereOrNull((f) => f.attribute == PullRequestsFilters.statusKey)?.filters ?? {},
      openedBy:
          pullRequestsFilters.firstWhereOrNull((f) => f.attribute == PullRequestsFilters.openedByKey)?.filters ?? {},
      assignedTo:
          pullRequestsFilters.firstWhereOrNull((f) => f.attribute == PullRequestsFilters.assignedToKey)?.filters ?? {},
    );
  }

  void savePullRequestsProjectsFilter(Set<String> projectNames) {
    storageService.saveFilter(organization, _FilterAreas.pullRequests, PullRequestsFilters.projectsKey, projectNames);
  }

  void savePullRequestsStatusFilter(String status) {
    storageService.saveFilter(organization, _FilterAreas.pullRequests, PullRequestsFilters.statusKey, {status});
  }

  void savePullRequestsOpenedByFilter(Set<String> userEmails) {
    storageService.saveFilter(organization, _FilterAreas.pullRequests, PullRequestsFilters.openedByKey, userEmails);
  }

  void savePullRequestsAssignedToFilter(Set<String> userEmails) {
    storageService.saveFilter(organization, _FilterAreas.pullRequests, PullRequestsFilters.assignedToKey, userEmails);
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

  static const projectsKey = 'projects';
  static const statesKey = 'states';
  static const typesKey = 'types';
  static const assigneesKey = 'assignees';
  static const areaKey = 'area';
  static const iterationKey = 'iteration';

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

  static const projectsKey = 'projects';
  static const authorsKey = 'authors';

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

  static const projectsKey = 'projects';
  static const triggeredByKey = 'triggeredBy';
  static const resultKey = 'result';
  static const statusKey = 'status';

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

  static const projectsKey = 'projects';
  static const statusKey = 'status';
  static const openedByKey = 'openedBy';
  static const assignedToKey = 'assignedTo';

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
