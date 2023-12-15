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

    final savedWorkItemsFilters = savedFilters
        .where(
          (f) => f.organization == organization && f.area == _FilterAreas.workItems,
        )
        .toList();

    return WorkItemsFilters(
      projects: savedWorkItemsFilters.firstWhereOrNull((f) => f.attribute == _FilterKeys.projects)?.filters ?? {},
      states: savedWorkItemsFilters.firstWhereOrNull((f) => f.attribute == _FilterKeys.states)?.filters ?? {},
      types: savedWorkItemsFilters.firstWhereOrNull((f) => f.attribute == _FilterKeys.types)?.filters ?? {},
      assignees: savedWorkItemsFilters.firstWhereOrNull((f) => f.attribute == _FilterKeys.assignees)?.filters ?? {},
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

  void resetWorkItemsFilters() {
    storageService.resetFilter(organization, _FilterAreas.workItems);
  }
}

class WorkItemsFilters {
  WorkItemsFilters({
    required this.projects,
    required this.states,
    required this.types,
    required this.assignees,
  });

  final Set<String> projects;
  final Set<String> states;
  final Set<String> types;
  final Set<String> assignees;
}

class _FilterAreas {
  static const workItems = 'work-items';
  // TODO
  // static const commits = 'commits';
  // static const pipelines = 'pipelines';
  // static const pullRequests = 'pull-requests';
}

class _FilterKeys {
  static const projects = 'projects';
  static const states = 'states';
  static const types = 'types';
  static const assignees = 'assignees';
}
