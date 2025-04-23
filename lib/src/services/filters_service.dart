import 'package:azure_devops/src/services/storage_service.dart';
import 'package:collection/collection.dart';

typedef _ResultWithMessage = ({bool result, String message});

/// This class is responsible for persisting filters to and retrieving them
/// from local storage by using [storage].
///
/// Filters can be different for each organization, that's why we need [organization].
class FiltersService {
  FiltersService({required this.storage, required this.organization});

  final StorageService storage;
  final String organization;

  WorkItemsFilters getWorkItemsSavedFilters() {
    final workItemsFilters = _getAreaFilter(area: FilterAreas.workItems);

    return WorkItemsFilters(
      projects: _getFilters(workItemsFilters, attribute: WorkItemsFilters.projectsKey),
      states: _getFilters(workItemsFilters, attribute: WorkItemsFilters.statesKey),
      categories: _getFilters(workItemsFilters, attribute: WorkItemsFilters.categoriesKey),
      types: _getFilters(workItemsFilters, attribute: WorkItemsFilters.typesKey),
      assignees: _getFilters(workItemsFilters, attribute: WorkItemsFilters.assigneesKey),
      area: _getFilters(workItemsFilters, attribute: WorkItemsFilters.areaKey),
      iteration: _getFilters(workItemsFilters, attribute: WorkItemsFilters.iterationKey),
    );
  }

  void saveWorkItemsProjectsFilter(Set<String> projectNames) {
    storage.saveFilter(organization, FilterAreas.workItems, WorkItemsFilters.projectsKey, projectNames);
  }

  void saveWorkItemsStatesFilter(Set<String> stateNames) {
    storage.saveFilter(organization, FilterAreas.workItems, WorkItemsFilters.statesKey, stateNames);
  }

  void saveWorkItemsCategoriesFilter(Set<String> categories) {
    storage.saveFilter(organization, FilterAreas.workItems, WorkItemsFilters.categoriesKey, categories);
  }

  void saveWorkItemsTypesFilter(Set<String> typeNames) {
    storage.saveFilter(organization, FilterAreas.workItems, WorkItemsFilters.typesKey, typeNames);
  }

  void saveWorkItemsAssigneesFilter(Set<String> userEmails) {
    storage.saveFilter(organization, FilterAreas.workItems, WorkItemsFilters.assigneesKey, userEmails);
  }

  void saveWorkItemsAreaFilter(String area) {
    storage.saveFilter(
      organization,
      FilterAreas.workItems,
      WorkItemsFilters.areaKey,
      area.isEmpty ? {} : {area},
    );
  }

  void saveWorkItemsIterationFilter(String iteration) {
    storage.saveFilter(
      organization,
      FilterAreas.workItems,
      WorkItemsFilters.iterationKey,
      iteration.isEmpty ? {} : {iteration},
    );
  }

  void resetWorkItemsFilters() {
    storage.resetFilter(organization, FilterAreas.workItems);
  }

  CommitsFilters getCommitsSavedFilters() {
    final commitsFilters = _getAreaFilter(area: FilterAreas.commits);

    return CommitsFilters(
      projects: _getFilters(commitsFilters, attribute: CommitsFilters.projectsKey),
      authors: _getFilters(commitsFilters, attribute: CommitsFilters.authorsKey),
      repository: _getFilters(commitsFilters, attribute: CommitsFilters.repositoryKey),
    );
  }

  void saveCommitsProjectsFilter(Set<String> projectNames) {
    storage.saveFilter(organization, FilterAreas.commits, CommitsFilters.projectsKey, projectNames);
  }

  void saveCommitsAuthorsFilter(Set<String> userEmails) {
    storage.saveFilter(organization, FilterAreas.commits, CommitsFilters.authorsKey, userEmails);
  }

  void saveCommitsRepositoryFilter(Set<String> repository) {
    storage.saveFilter(
      organization,
      FilterAreas.commits,
      CommitsFilters.repositoryKey,
      repository.isEmpty ? {} : repository,
    );
  }

  void resetCommitsFilters() {
    storage.resetFilter(organization, FilterAreas.commits);
  }

  PipelinesFilters getPipelinesSavedFilters() {
    final pipelinesFilters = _getAreaFilter(area: FilterAreas.pipelines);

    return PipelinesFilters(
      projects: _getFilters(pipelinesFilters, attribute: PipelinesFilters.projectsKey),
      pipelines: _getFilters(pipelinesFilters, attribute: PipelinesFilters.pipelinesKey),
      triggeredBy: _getFilters(pipelinesFilters, attribute: PipelinesFilters.triggeredByKey),
      result: _getFilters(pipelinesFilters, attribute: PipelinesFilters.resultKey),
      status: _getFilters(pipelinesFilters, attribute: PipelinesFilters.statusKey),
    );
  }

  void savePipelinesProjectsFilter(Set<String> projectNames) {
    storage.saveFilter(organization, FilterAreas.pipelines, PipelinesFilters.projectsKey, projectNames);
  }

  void savePipelinesNamesFilter(Set<String> names) {
    storage.saveFilter(organization, FilterAreas.pipelines, PipelinesFilters.pipelinesKey, names);
  }

  void savePipelinesTriggeredByFilter(Set<String> userEmails) {
    storage.saveFilter(organization, FilterAreas.pipelines, PipelinesFilters.triggeredByKey, userEmails);
  }

  void savePipelinesResultFilter(String result) {
    storage.saveFilter(organization, FilterAreas.pipelines, PipelinesFilters.resultKey, {result});
  }

  void savePipelinesStatusFilter(String status) {
    storage.saveFilter(organization, FilterAreas.pipelines, PipelinesFilters.statusKey, {status});
  }

  void resetPipelinesFilters() {
    storage.resetFilter(organization, FilterAreas.pipelines);
  }

  PullRequestsFilters getPullRequestsSavedFilters() {
    final pullRequestsFilters = _getAreaFilter(area: FilterAreas.pullRequests);

    return PullRequestsFilters(
      projects: _getFilters(pullRequestsFilters, attribute: PullRequestsFilters.projectsKey),
      status: _getFilters(pullRequestsFilters, attribute: PullRequestsFilters.statusKey),
      openedBy: _getFilters(pullRequestsFilters, attribute: PullRequestsFilters.openedByKey),
      assignedTo: _getFilters(pullRequestsFilters, attribute: PullRequestsFilters.assignedToKey),
    );
  }

  void savePullRequestsProjectsFilter(Set<String> projectNames) {
    storage.saveFilter(organization, FilterAreas.pullRequests, PullRequestsFilters.projectsKey, projectNames);
  }

  void savePullRequestsStatusFilter(String status) {
    storage.saveFilter(organization, FilterAreas.pullRequests, PullRequestsFilters.statusKey, {status});
  }

  void savePullRequestsOpenedByFilter(Set<String> userEmails) {
    storage.saveFilter(organization, FilterAreas.pullRequests, PullRequestsFilters.openedByKey, userEmails);
  }

  void savePullRequestsAssignedToFilter(Set<String> userEmails) {
    storage.saveFilter(organization, FilterAreas.pullRequests, PullRequestsFilters.assignedToKey, userEmails);
  }

  void resetPullRequestsFilters() {
    storage.resetFilter(organization, FilterAreas.pullRequests);
  }

  List<StorageFilter> _getAreaFilter({required String area}) {
    final savedFilters = storage.getFilters();
    return savedFilters.where((f) => f.organization == organization && f.area == area).toList();
  }

  Set<String> _getFilters(List<StorageFilter> allFilters, {required String attribute}) {
    return allFilters.firstWhereOrNull((f) => f.attribute == attribute)?.filters ?? {};
  }

  List<SavedShortcut> getOrganizationShortcuts() {
    final shortcuts = storage.getSavedShortcuts();
    return shortcuts.where((s) => s.organization == organization).toList();
  }

  CommitsFilters getCommitsShortcut(String label) {
    final shortcut = _getAreaShortcut(area: FilterAreas.commits, label: label)!;

    return CommitsFilters(
      projects: _getShortcutFilters(shortcut, attribute: CommitsFilters.projectsKey),
      authors: _getShortcutFilters(shortcut, attribute: CommitsFilters.authorsKey),
      repository: _getShortcutFilters(shortcut, attribute: CommitsFilters.repositoryKey),
    );
  }

  _ResultWithMessage saveCommitsShortcut(String label, {required CommitsFilters filters}) {
    return _saveShortcut(FilterAreas.commits, label, filters.toMap());
  }

  PipelinesFilters getPipelinesShortcut(String label) {
    final shortcut = _getAreaShortcut(area: FilterAreas.pipelines, label: label)!;

    return PipelinesFilters(
      projects: _getShortcutFilters(shortcut, attribute: PipelinesFilters.projectsKey),
      pipelines: _getShortcutFilters(shortcut, attribute: PipelinesFilters.pipelinesKey),
      result: _getShortcutFilters(shortcut, attribute: PipelinesFilters.resultKey),
      status: _getShortcutFilters(shortcut, attribute: PipelinesFilters.statusKey),
      triggeredBy: _getShortcutFilters(shortcut, attribute: PipelinesFilters.triggeredByKey),
    );
  }

  _ResultWithMessage savePipelinesShortcut(String label, {required PipelinesFilters filters}) {
    return _saveShortcut(FilterAreas.pipelines, label, filters.toMap());
  }

  PullRequestsFilters getPullRequestsShortcut(String label) {
    final shortcut = _getAreaShortcut(area: FilterAreas.pullRequests, label: label)!;

    return PullRequestsFilters(
      projects: _getShortcutFilters(shortcut, attribute: PullRequestsFilters.projectsKey),
      status: _getShortcutFilters(shortcut, attribute: PipelinesFilters.statusKey),
      assignedTo: _getShortcutFilters(shortcut, attribute: PullRequestsFilters.assignedToKey),
      openedBy: _getShortcutFilters(shortcut, attribute: PullRequestsFilters.openedByKey),
    );
  }

  _ResultWithMessage savePullRequestsShortcut(String label, {required PullRequestsFilters filters}) {
    return _saveShortcut(FilterAreas.pullRequests, label, filters.toMap());
  }

  WorkItemsFilters getWorkItemsShortcut(String label) {
    final shortcut = _getAreaShortcut(area: FilterAreas.workItems, label: label)!;

    return WorkItemsFilters(
      projects: _getShortcutFilters(shortcut, attribute: WorkItemsFilters.projectsKey),
      categories: _getShortcutFilters(shortcut, attribute: WorkItemsFilters.categoriesKey),
      states: _getShortcutFilters(shortcut, attribute: WorkItemsFilters.statesKey),
      types: _getShortcutFilters(shortcut, attribute: WorkItemsFilters.typesKey),
      assignees: _getShortcutFilters(shortcut, attribute: WorkItemsFilters.assigneesKey),
      area: _getShortcutFilters(shortcut, attribute: WorkItemsFilters.areaKey),
      iteration: _getShortcutFilters(shortcut, attribute: WorkItemsFilters.iterationKey),
    );
  }

  _ResultWithMessage saveWorkItemsShortcut(String label, {required WorkItemsFilters filters}) {
    return _saveShortcut(FilterAreas.workItems, label, filters.toMap());
  }

  _ResultWithMessage _saveShortcut(String area, String label, Map<String, Set<String>> filters) {
    final savedShortcuts = storage.getSavedShortcuts();

    final hasShortcutWithSameLabel = savedShortcuts.any((s) => s.organization == organization && s.label == label);

    if (hasShortcutWithSameLabel) {
      return (result: false, message: 'There is already a saved filter with this label');
    }

    storage.saveShortcut(organization, area, label, filters);

    return (result: true, message: 'Filter saved successfully!');
  }

  SavedShortcut? _getAreaShortcut({required String area, required String label}) {
    final shortcuts = storage.getSavedShortcuts();
    return shortcuts.firstWhereOrNull((s) => s.organization == organization && s.area == area && s.label == label);
  }

  Set<String> _getShortcutFilters(SavedShortcut shortcut, {required String attribute}) {
    return shortcut.filters.firstWhereOrNull((f) => f.attribute == attribute)?.filters ?? {};
  }

  void renameShortcut(SavedShortcut shortcut, {required String label}) {
    storage.renameShortcut(shortcut, label);
  }

  void deleteShortcut(SavedShortcut shortcut) {
    storage.deleteShortcut(shortcut);
  }
}

class WorkItemsFilters {
  WorkItemsFilters({
    required this.projects,
    required this.states,
    required this.categories,
    required this.types,
    required this.assignees,
    required this.area,
    required this.iteration,
  });

  static const projectsKey = 'projects';
  static const statesKey = 'states';
  static const categoriesKey = 'categories';
  static const typesKey = 'types';
  static const assigneesKey = 'assignees';
  static const areaKey = 'area';
  static const iterationKey = 'iteration';

  final Set<String> projects;
  final Set<String> states;
  final Set<String> categories;
  final Set<String> types;
  final Set<String> assignees;
  final Set<String> area;
  final Set<String> iteration;

  Map<String, Set<String>> toMap() {
    return {
      if (projects.isNotEmpty) projectsKey: projects,
      if (area.isNotEmpty) areaKey: area,
      if (assignees.isNotEmpty) assigneesKey: assignees,
      if (categories.isNotEmpty) categoriesKey: categories,
      if (iteration.isNotEmpty) iterationKey: iteration,
      if (states.isNotEmpty) statesKey: states,
      if (types.isNotEmpty) typesKey: types,
    };
  }
}

class CommitsFilters {
  CommitsFilters({
    required this.projects,
    required this.authors,
    required this.repository,
  });

  static const projectsKey = 'projects';
  static const authorsKey = 'authors';
  static const repositoryKey = 'repository';

  final Set<String> projects;
  final Set<String> authors;
  final Set<String> repository;

  Map<String, Set<String>> toMap() {
    return {
      if (authors.isNotEmpty) authorsKey: authors,
      if (projects.isNotEmpty) projectsKey: projects,
      if (repository.isNotEmpty) repositoryKey: repository,
    };
  }
}

class PipelinesFilters {
  PipelinesFilters({
    required this.projects,
    required this.pipelines,
    required this.triggeredBy,
    required this.result,
    required this.status,
  });

  static const projectsKey = 'projects';
  static const pipelinesKey = 'pipelines';
  static const triggeredByKey = 'triggeredBy';
  static const resultKey = 'result';
  static const statusKey = 'status';

  final Set<String> projects;
  final Set<String> pipelines;
  final Set<String> triggeredBy;
  final Set<String> result;
  final Set<String> status;

  Map<String, Set<String>> toMap() {
    return {
      if (projects.isNotEmpty) projectsKey: projects,
      if (result.isNotEmpty) resultKey: result,
      if (status.isNotEmpty) statusKey: status,
      if (triggeredBy.isNotEmpty) triggeredByKey: triggeredBy,
      if (pipelines.isNotEmpty) pipelinesKey: pipelines,
    };
  }
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

  Map<String, Set<String>> toMap() {
    return {
      if (projects.isNotEmpty) projectsKey: projects,
      if (status.isNotEmpty) statusKey: status,
      if (openedBy.isNotEmpty) openedByKey: openedBy,
      if (assignedTo.isNotEmpty) assignedToKey: assignedTo,
    };
  }
}

class FilterAreas {
  static const workItems = 'work-items';
  static const commits = 'commits';
  static const pipelines = 'pipelines';
  static const pullRequests = 'pull-requests';
}
