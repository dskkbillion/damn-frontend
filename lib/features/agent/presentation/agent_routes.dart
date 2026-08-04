import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/core/router/smart_router_utils.dart';
import '../data/agent_repository.dart';
import '../../../core/dasn/data/dasn_task_repository.dart';
import '../../../core/dasn/data/dsn_order_repository.dart';
import 'device_authorization_page.dart';
import 'agent_request_review_page.dart';
import 'dsn_order_flow_page.dart';
import 'dsn_task_page.dart';
import 'provider_task_center_page.dart';
import '../../../core/dasn/data/dsn_provider_repository.dart';
import '../../../core/dasn/data/dsn_provider_task_repository.dart';

class AgentRoutes {
  AgentRoutes._();
  static AgentRepository _repository() =>
      DioAgentRepository(GetIt.instance<Dio>());

  static DasnTaskRepository _taskRepository() =>
      DioDasnTaskRepository(GetIt.instance<Dio>());

  static DsnOrderRepository _orderRepository() =>
      DioDsnOrderRepository(GetIt.instance<Dio>());

  static DsnProviderRepository _providerRepository() =>
      DioDsnProviderRepository(GetIt.instance<Dio>());

  static DsnProviderTaskRepository _providerTaskRepository() =>
      DioDsnProviderTaskRepository(GetIt.instance<Dio>());

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
              orderRepository: _orderRepository(),
              requestId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
            ),
            name: 'agentRequestReview',
            source: 'agent_request_handoff',
          ),
        ),
        GoRoute(
          path: '/requests/:id/order',
          name: 'agentOrderFlow',
          pageBuilder: (context, state) => state.buildSmartPage(
            DsnOrderFlowPage(
              requestRepository: _repository(),
              orderRepository: _orderRepository(),
              taskRepository: _taskRepository(),
              requestId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
            ),
            name: 'agentOrderFlow',
            source: 'agent_dasn_buyer_order',
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
        GoRoute(
          path: '/provider/tasks',
          name: 'providerTaskCenter',
          pageBuilder: (context, state) => state.buildSmartPage(
            DsnProviderTaskCenterPage(
              taskRepository: _providerTaskRepository(),
              providerRepository: _providerRepository(),
            ),
            name: 'providerTaskCenter',
            source: 'provider_dasn_task_center',
          ),
        ),
      ];
}
