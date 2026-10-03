import 'package:azure_devops/src/models/azure_devops_connection.dart';

class AzureDevOpsEndpointResolver {
  AzureDevOpsEndpointResolver(this.connection);

  final AzureDevOpsConnectionProfile connection;

  String get apiVersion => connection.apiVersion ?? (connection.isCloud ? '7.0' : '7.0');

  String get apiVersionQuery => 'api-version=$apiVersion';

  String get apiVersionPreviewQuery => 'api-version=$apiVersion-preview';

  Uri get collectionBase {
    if (connection.isCloud) {
      final org = _required(connection.organization, 'organization');
      return Uri.parse('https://dev.azure.com/${Uri.encodeComponent(org)}');
    }

    final server = _normalizedServer(connection.serverUrl);
    final collection = _required(connection.collection, 'collection');
    return server.replace(
      pathSegments: [
        ...server.pathSegments.where((s) => s.isNotEmpty),
        collection,
      ],
      query: null,
      fragment: null,
    );
  }

  Uri get usersBase {
    if (connection.isCloud) {
      return Uri.parse('https://vssps.dev.azure.com');
    }

    return collectionBase;
  }

  Uri collectionApi(String path, [Map<String, String?> query = const {}]) {
    return _append(collectionBase, path, query);
  }

  Uri projectApi(String project, String path, [Map<String, String?> query = const {}]) {
    return _append(
      collectionBase,
      '$project/${_trimSlashes(path)}',
      query,
    );
  }

  String projectWebUrl(String project, String path) {
    return _append(
      collectionBase,
      '$project/${_trimSlashes(path)}',
      const {},
    ).toString();
  }

  Uri _append(Uri base, String path, Map<String, String?> query) {
    final segments = [
      ...base.pathSegments.where((s) => s.isNotEmpty),
      ..._trimSlashes(path).split('/').where((s) => s.isNotEmpty),
    ];
    final queryParameters = <String, String>{
      ...base.queryParameters,
      for (final entry in query.entries)
        if (entry.value != null) entry.key: entry.value!,
    };
    return base.replace(
      pathSegments: segments,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
      fragment: null,
    );
  }

  Uri _normalizedServer(String url) {
    final parsed = Uri.parse(url.trim());
    if (!parsed.hasScheme || parsed.host.isEmpty) {
      throw FormatException('Invalid Azure DevOps Server URL');
    }
    return parsed.replace(
      path: _trimTrailingSlash(parsed.path),
      query: null,
      fragment: null,
    );
  }

  String _required(String? value, String name) {
    if (value == null || value.trim().isEmpty) {
      throw StateError('Azure DevOps ${connection.hostType.name} connection requires $name');
    }
    return value.trim();
  }

  String _trimSlashes(String value) => value.replaceAll(RegExp(r'^/+|/+$'), '');

  String _trimTrailingSlash(String value) => value.replaceAll(RegExp(r'/+$'), '');
}
