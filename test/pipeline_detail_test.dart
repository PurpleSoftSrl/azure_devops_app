import 'package:azure_devops/src/models/pipeline.dart';
import 'package:azure_devops/src/models/pipeline_approvals.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/timeline.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/screens/pipeline_detail/base_pipeline_detail.dart';
import 'package:azure_devops/src/services/ads_service.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show Response;
import 'package:visibility_detector/visibility_detector.dart';

import 'api_service_mock.dart';

/// Mock pipeline is taken from [AzureApiServiceMock.getPipeline]
void main() {
  setUp(() => VisibilityDetectorController.instance.updateInterval = Duration.zero);

  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Page building test', (t) async {
    final app = AdsServiceWidget(
      ads: AdsServiceMock(),
      child: AzureApiServiceWidget(
        api: AzureApiServiceMock(),
        child: MaterialApp(
          theme: mockTheme,
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => PipelineDetailPage(),
            settings: RouteSettings(arguments: (id: 1234, project: 'TestProject')),
          ),
        ),
      ),
    );

    await t.pumpWidget(app);

    await t.pump();

    expect(find.byType(PipelineDetailPage), findsOneWidget);
  });

  for (final version in [0, 1]) {
    testWidgets('ManualValidation@$version is separate from stage approvals and can resume', (tester) async {
      final api = _ValidationApi(version: version);
      api.approvals.add(_approval('validation-id', instructions: 'Check production deployment'));
      api.approvals.add(_approval('stage-id', instructions: 'Stage approval'));
      await tester.pumpWidget(_app(api));
      await tester.pump();

      expect(find.text('1 manual validation awaiting review'), findsOneWidget);
      expect(find.text('1 approval needs review before this run can continue'), findsOneWidget);
      expect(find.byTooltip('Review manual validation'), findsOneWidget);

      await tester.tap(find.text('View').last);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Check production deployment'), findsOneWidget);
      expect(find.text('Stage approval'), findsNothing);
      expect(find.text('Defer'), findsNothing);

      await tester.ensureVisible(find.text('Resume'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Resume'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Confirm'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(api.resumedIds, ['validation-id']);
      expect(api.pipelineRequests, greaterThan(1));
      expect(find.text('1 manual validation awaiting review'), findsNothing);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(seconds: 4));
    });
  }

  testWidgets('Only an in-progress task with a matching approval exposes manual actions', (tester) async {
    final api = _ValidationApi(version: 0, identifier: 'other-id');
    api.approvals.add(_approval('validation-id'));
    await tester.pumpWidget(_app(api));
    await tester.pump();

    expect(find.textContaining('manual validation awaiting review'), findsNothing);
    expect(find.byTooltip('Review manual validation'), findsNothing);
  });

  testWidgets('Banner includes manual tasks outside the displayed timeline order', (tester) async {
    final api = _ValidationApi(version: 0);
    api.timeline.add(
      _record(
        'Second validation',
        'Task',
        1001,
        parentId: 'job',
        identifier: 'second-id',
        taskName: 'ManualValidation',
        version: 1,
      ),
    );
    api.approvals.addAll([_approval('validation-id'), _approval('second-id', instructions: 'Check second release')]);
    await tester.pumpWidget(_app(api));
    await tester.pump();

    expect(find.text('2 manual validations awaiting review'), findsOneWidget);
    await tester.tap(find.text('View'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Check second release'), findsOneWidget);
    expect(find.text('Second validation'), findsOneWidget);
  });

  testWidgets('Blocked group member cannot act on a manual validation', (tester) async {
    final api = _ValidationApi(version: 1);
    api.approvals.add(_approval('validation-id', blockedDescriptor: 'group-descriptor'));
    await tester.pumpWidget(_app(api));
    await tester.pump();

    await tester.tap(find.text('View'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('You cannot act on this validation.'), findsOneWidget);
    expect(find.text('Resume'), findsNothing);
    expect(find.text('Reject'), findsNothing);
  });

  for (final state in ['pending', 'completed']) {
    testWidgets('$state manual validation cannot be acted on', (tester) async {
      final api = _ValidationApi(version: 0);
      api.approvals.add(_approval('validation-id'));
      api.timeline[3] = _record(
        'Validate deployment',
        'Task',
        1,
        parentId: 'job',
        identifier: 'validation-id',
        taskName: 'ManualValidation',
        state: state,
      );
      await tester.pumpWidget(_app(api));
      await tester.pump();

      expect(find.textContaining('manual validation awaiting review'), findsNothing);
      expect(find.byTooltip('Review manual validation'), findsNothing);
    });
  }

  testWidgets('Reject is sent for the matched validation', (tester) async {
    final api = _ValidationApi(version: 0);
    api.approvals.add(_approval('validation-id'));
    await tester.pumpWidget(_app(api));
    await tester.pump();

    await tester.tap(find.text('View'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.ensureVisible(find.text('Reject'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Reject'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Confirm'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(api.rejectedIds, ['validation-id']);
    expect(find.text('1 manual validation awaiting review'), findsNothing);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('Server denial keeps the validation pending', (tester) async {
    final api = _ValidationApi(version: 1)..denyActions = true;
    api.approvals.add(_approval('validation-id'));
    await tester.pumpWidget(_app(api));
    await tester.pump();

    await tester.tap(find.text('View'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.ensureVisible(find.text('Resume'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Resume'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Confirm'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Queue builds permission required'), findsOneWidget);
    expect(api.approvals, hasLength(1));
  });
}

Widget _app(_ValidationApi api) => AdsServiceWidget(
  ads: AdsServiceMock(),
  child: AzureApiServiceWidget(
    api: api,
    child: MaterialApp(
      navigatorKey: AppRouter.navigatorKey,
      scaffoldMessengerKey: OverlayService.scaffoldMessengerKey,
      theme: mockTheme,
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => PipelineDetailPage(),
        settings: RouteSettings(arguments: (id: 1234, project: 'TestProject')),
      ),
    ),
  ),
);

Approval _approval(String id, {String instructions = '', String? blockedDescriptor}) => Approval.fromJson({
  'id': id,
  'status': 'pending',
  'instructions': instructions,
  'pipeline': {
    'owner': {'id': 1234},
  },
  'steps': <Object>[],
  'blockedApprovers': [
    if (blockedDescriptor != null) {'descriptor': blockedDescriptor},
  ],
});

Record _record(
  String id,
  String type,
  int order, {
  String? parentId,
  String? identifier,
  String? taskName,
  int version = 0,
  String state = 'inProgress',
}) => Record.fromJson({
  'id': id,
  'type': type,
  'name': id,
  'order': order,
  'parentId': parentId,
  'identifier': identifier,
  'state': state,
  'result': null,
  'task': taskName == null ? null : {'id': 'task-definition', 'name': taskName, 'version': '$version.0.0'},
  'previousAttempts': <Object>[],
  'changeId': 1,
  'lastModified': '2026-09-27T12:00:00Z',
  'errorCount': 0,
  'warningCount': 0,
  'attempt': 1,
});

class _ValidationApi extends AzureApiServiceMock {
  _ValidationApi({required int version, String identifier = 'validation-id'})
    : timeline = [
        _record('stage', 'Stage', 1),
        _record('phase', 'Phase', 1, parentId: 'stage'),
        _record('job', 'Job', 1, parentId: 'phase'),
        _record(
          'Validate deployment',
          'Task',
          1,
          parentId: 'job',
          identifier: identifier,
          taskName: 'ManualValidation',
          version: version,
        ),
      ];

  final List<Record> timeline;
  final List<Approval> approvals = [];
  final List<String> resumedIds = [];
  final List<String> rejectedIds = [];
  bool denyActions = false;
  int pipelineRequests = 0;

  @override
  UserMe? get user => UserMe(
    displayName: 'Reviewer',
    publicAlias: 'reviewer',
    emailAddress: 'reviewer@example.com',
    coreRevision: 1,
    timeStamp: DateTime(2026),
    id: 'reviewer-id',
    revision: 1,
  );

  @override
  Future<ApiResponse<Set<String>>> getCurrentUserApproverDescriptors() async => ApiResponse.ok({'group-descriptor'});

  @override
  Future<ApiResponse<PipelineWithTimeline>> getPipeline({required String projectName, required int id}) async {
    pipelineRequests++;
    final response = await super.getPipeline(projectName: projectName, id: id);
    return ApiResponse.ok(
      PipelineWithTimeline(
        pipeline: response.data!.pipeline.copyWith(
          status: PipelineStatus.inProgress,
          project: Project(id: 'project-id', name: 'TestProject'),
        ),
        timeline: timeline,
      ),
    );
  }

  @override
  Future<ApiResponse<List<Approval>>> getPipelineApprovals({required Pipeline pipeline}) async =>
      ApiResponse.ok(approvals.toList());

  @override
  Future<ApiResponse<bool>> approvePipelineApproval({
    required Approval approval,
    required String projectId,
    DateTime? deferredTo,
  }) async {
    if (denyActions) return ApiResponse.error(Response('{"message":"Queue builds permission required"}', 403));
    resumedIds.add(approval.id);
    approvals.remove(approval);
    return ApiResponse.ok(true);
  }

  @override
  Future<ApiResponse<bool>> rejectPipelineApproval({required Approval approval, required String projectId}) async {
    rejectedIds.add(approval.id);
    approvals.remove(approval);
    return ApiResponse.ok(true);
  }
}
