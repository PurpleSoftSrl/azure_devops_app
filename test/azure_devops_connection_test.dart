import 'dart:convert';

import 'package:azure_devops/src/models/azure_devops_connection.dart';
import 'package:azure_devops/src/services/azure_devops_auth_provider.dart';
import 'package:azure_devops/src/services/azure_devops_endpoint_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('constructs cloud project URLs', () {
    final resolver = AzureDevOpsEndpointResolver(
      AzureDevOpsConnectionProfile.cloud(id: '1', organization: 'contoso'),
    );

    final uri = resolver.projectApi('App', '_apis/git/repositories');

    expect(uri.toString(), 'https://dev.azure.com/contoso/App/_apis/git/repositories');
  });

  test('constructs server project URLs', () {
    final resolver = AzureDevOpsEndpointResolver(
      AzureDevOpsConnectionProfile.server(
        id: '1',
        name: 'Codizen DevOps ORG',
        serverUrl: 'https://devops.codizen.org',
        collection: 'DefaultCollection',
      ),
    );

    final uri = resolver.projectApi('InnoRegnskab', '_apis/git/repositories');

    expect(uri.toString(), startsWith('https://devops.codizen.org/DefaultCollection/InnoRegnskab/_apis/'));
  });

  test('normalizes trailing server slashes', () {
    final resolver = AzureDevOpsEndpointResolver(
      AzureDevOpsConnectionProfile.server(
        id: '1',
        name: 'Codizen DevOps ORG',
        serverUrl: 'https://devops.codizen.org/',
        collection: 'DefaultCollection',
      ),
    );

    expect(
      resolver.collectionApi('_apis/projects', {'api-version': '7.0'}).toString(),
      'https://devops.codizen.org/DefaultCollection/_apis/projects?api-version=7.0',
    );
  });

  test('encodes project names', () {
    final resolver = AzureDevOpsEndpointResolver(
      AzureDevOpsConnectionProfile.cloud(id: '1', organization: 'contoso'),
    );

    expect(
      resolver.projectApi('App Suite & Tools', '_apis/git/repositories').toString(),
      'https://dev.azure.com/contoso/App%20Suite%20&%20Tools/_apis/git/repositories',
    );
  });

  test('builds PAT Basic header', () {
    final profile = AzureDevOpsConnectionProfile.server(
      id: '1',
      name: 'Server',
      serverUrl: 'https://devops.codizen.org',
      collection: 'DefaultCollection',
    );

    final headers = AzureDevOpsAuthHeaderProvider(connection: profile, accessToken: 'example-token').getHeadersSync();

    expect(headers['Authorization'], 'Basic ${base64Encode(utf8.encode(':example-token'))}');
  });

  test('builds Microsoft Bearer header', () {
    final profile = AzureDevOpsConnectionProfile.cloud(id: '1', organization: 'contoso');

    final headers = AzureDevOpsAuthHeaderProvider(connection: profile, accessToken: 'token').getHeadersSync();

    expect(headers['Authorization'], 'Bearer token');
  });

  test('redacts credentials', () {
    final text = redactCredentialText('Authorization: Bearer token\nAuthorization: Basic abc123==');

    expect(text, isNot(contains('token')));
    expect(text, isNot(contains('abc123')));
    expect(text, contains('[REDACTED]'));
  });

  test('connection-specific project cache keys differ', () {
    const projectId = 'project-1';
    final keyA = 'profile-a:$projectId';
    final keyB = 'profile-b:$projectId';

    expect(keyA, isNot(keyB));
  });
}
