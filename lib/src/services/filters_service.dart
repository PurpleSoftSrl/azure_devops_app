import 'package:azure_devops/src/services/storage_service.dart';
import 'package:collection/collection.dart';

/// This class is responsible for persisting filters to and retrieving them
/// from local storage by using [storageService].
///
/// Filters can be different for each organization, that's why we need [organization].
class FiltersService {
  FiltersService({required this.storageService, required this.organization});

  final StorageService storageService;
  final String organization;

  WorkItemsFilters getWorkItemsSavedFilters() {
    final workItemsFilters = _getAreaFilter(area: _FilterAreas.workItems);

    return WorkItemsFilters(
      projects: _getFilters(workItemsFilters, attribute: WorkItemsFilters.projectsKey),
      categories: _getFilters(workItemsFilters, attribute: WorkItemsFilters.categoriesKey),
      states: _getFilters(workItemsFilters, attribute: WorkItemsFilters.statesKey),
      categories: _getFilters(workItemsFilters, attribute: WorkItemsFilters.categoriesKey),
      types: _getFilters(workItemsFilters, attribute: WorkItemsFilters.typesKey),
      assignees: _getFilters(workItemsFilters, attribute: WorkItemsFilters.assigneesKey),
      area: _getFilters(workItemsFilters, attribute: WorkItemsFilters.areaKey),
      iteration: _getFilters(workItemsFilters, attribute: WorkItemsFilters.iterationKey),
    );
  }

  void saveWorkItemsProjectsFilter(Set<String> projectNames) {
    storageService.saveFilter(organization, _FilterAreas.workItems, WorkItemsFilters.projectsKey, projectNames);
  }

  void saveWorkItemsCategoriesFilter(Set<String> categoriesNames) {
    storageService.saveFilter(organization, _FilterAreas.workItems, WorkItemsFilters.categoriesKey, categoriesNames);
  }

  void saveWorkItemsStatesFilter(Set<String> stateNames) {
    storageService.saveFilter(organization, _FilterAreas.workItems, WorkItemsFilters.statesKey, stateNames);
  }

  void saveWorkItemsCategoriesFilter(Set<String> categories) {
    storageService.saveFilter(organization, _FilterAreas.workItems, WorkItemsFilters.categoriesKey, categories);
  }

  void saveWorkItemsTypesFilter(Set<String> typeNames) {
    storageService.saveFilter(organization, _FilterAreas.workItems, WorkItemsFilters.typesKey, typeNames);
  }

  void saveWorkItemsAssigneesFilter(Set<String> userEmails) {
    storageService.saveFilter(organization, _FilterAreas.workItems, WorkItemsFilters.assigneesKey, userEmails);
  }

  void saveWorkItemsAreaFilter(String area) {
    storageService.saveFilter(
      organization,
      _FilterAreas.workItems,
      WorkItemsFilters.areaKey,
      area.isEmpty ? {} : {area},
    );
  }

  void saveWorkItemsIterationFilter(String iteration) {
    storageService.saveFilter(
      organization,
      _FilterAreas.workItems,
      WorkItemsFilters.iterationKey,
      iteration.isEmpty ? {} : {iteration},
    );
  }

  void resetWorkItemsFilters() {
    storageService.resetFilter(organization, _FilterAreas.workItems);
  }

  CommitsFilters getCommitsSavedFilters() {
    final commitsFilters = _getAreaFilter(area: _FilterAreas.commits);

    return CommitsFilters(
      projects: _getFilters(commitsFilters, attribute: CommitsFilters.projectsKey),
      authors: _getFilters(commitsFilters, attribute: CommitsFilters.authorsKey),
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
    final pipelinesFilters = _getAreaFilter(area: _FilterAreas.pipelines);

    return PipelinesFilters(
      projects: _getFilters(pipelinesFilters, attribute: PipelinesFilters.projectsKey),
      triggeredBy: _getFilters(pipelinesFilters, attribute: PipelinesFilters.triggeredByKey),
      result: _getFilters(pipelinesFilters, attribute: PipelinesFilters.resultKey),
      status: _getFilters(pipelinesFilters, attribute: PipelinesFilters.statusKey),
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
    final pullRequestsFilters = _getAreaFilter(area: _FilterAreas.pullRequests);

    return PullRequestsFilters(
      projects: _getFilters(pullRequestsFilters, attribute: PullRequestsFilters.projectsKey),
      status: _getFilters(pullRequestsFilters, attribute: PullRequestsFilters.statusKey),
      openedBy: _getFilters(pullRequestsFilters, attribute: PullRequestsFilters.openedByKey),
      assignedTo: _getFilters(pullRequestsFilters, attribute: PullRequestsFilters.assignedToKey),
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

  List<StorageFilter> _getAreaFilter({required String area}) {
    final savedFilters = storageService.getFilters();
    return savedFilters.where((f) => f.organization == organization && f.area == area).toList();
  }

  Set<String> _getFilters(List<StorageFilter> allFilters, {required String attribute}) {
    return allFilters.firstWhereOrNull((f) => f.attribute == attribute)?.filters ?? {};
  }
}

class WorkItemsFilters {
  WorkItemsFilters({
    required this.projects,
    required this.categories,
    required this.states,
    required this.categories,
    required this.types,
    required this.assignees,
    required this.area,
    required this.iteration,
  });

  static const projectsKey = 'projects';
  static const categoriesKey = 'categories';
  static const statesKey = 'states';
  static const categoriesKey = 'categories';
  static const typesKey = 'types';
  static const assigneesKey = 'assignees';
  static const areaKey = 'area';
  static const iterationKey = 'iteration';

  final Set<String> projects;
  final Set<String> categories;
  final Set<String> states;
  final Set<String> categories;
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
