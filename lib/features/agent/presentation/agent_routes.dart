import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/core/router/smart_router_utils.dart';
import '../data/agent_repository.dart';
import '../../../core/dasn/data/dasn_task_repository.dart';
import 'device_authorization_page.dart';
import 'agent_request_review_page.dart';
import 'dsn_task_page.dart';

class AgentRoutes {
  AgentRoutes._();
  static AgentRepository _repository() =>
      DioAgentRepository(GetIt.instance<Dio>());

  static DasnTaskRepository _taskRepository() =>
      DioDasnTaskRepository(GetIt.instance<Dio>());

  static List<RouteBase> get routes => [
        GoRoute(
          path: '/agent/connect',
          name: 'agentConnect',
          pageBuilder: (context, state) => state.buildSmartPage(
            DeviceAuthorizationPage(
              repository: _repository(),
              initialCode: state.uri.queryParameters['code'],
            ),
            name: 'agentConnect',
            source: 'agent_device_flow',
          ),
        ),
        GoRoute(
          path: '/requests/:id/review',
          name: 'agentRequestReview',
          pageBuilder: (context, state) => state.buildSmartPage(
            AgentRequestReviewPage(
              repository: _repository(),
              requestId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
            ),
            name: 'agentRequestReview',
            source: 'agent_request_handoff',
          ),
        ),
        GoRoute(
          path: '/agent/tasks/:taskTraceId',
          name: 'agentTaskStatus',
          pageBuilder: (context, state) => state.buildSmartPage(
            DsnTaskPage(
              repository: _taskRepository(),
              taskTraceId: state.pathParameters['taskTraceId'] ?? '',
            ),
            name: 'agentTaskStatus',
            source: 'agent_dasn_task_projection',
          ),
        ),
      ];
}
