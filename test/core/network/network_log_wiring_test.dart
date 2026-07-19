import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all production Dio clients use the safe network logger', () {
    const clientFiles = [
      'lib/app/di/injection_container.dart',
      'lib/core/api/api_client.dart',
      'lib/core/network/core_dio_client.dart',
      'lib/core/network/dio_http_client.dart',
      'lib/features/seller/data/datasources/seller_remote_data_source_impl.dart',
    ];
    final unsafeLogInterceptor = RegExp(r'\bLogInterceptor\(');

    for (final path in clientFiles) {
      final source = File(path).readAsStringSync();
      expect(source, contains('SafeNetworkLogInterceptor('), reason: path);
      expect(unsafeLogInterceptor.hasMatch(source), isFalse, reason: path);
    }
  });

  test('credential-bearing UI and WebSocket paths do not log raw values', () {
    final unifiedLogin = File(
      'lib/features/auth/presentation/pages/unified_login_page.dart',
    ).readAsStringSync();
    final legacyLogin = File(
      'lib/features/auth/presentation/pages/sms_login_page.dart',
    ).readAsStringSync();
    final webSocket = File(
      'lib/features/chat/data/datasources/'
      'chat_web_socket_data_source.impl.dart',
    ).readAsStringSync();
    final headerInterceptor = File(
      'lib/core/network/header_interceptor.dart',
    ).readAsStringSync();
    final dioHttpClient = File(
      'lib/core/network/dio_http_client.dart',
    ).readAsStringSync();
    final aiChat = File(
      'lib/features/ai_docs/data/datasources/'
      'ai_chat_remote_data_source_impl.dart',
    ).readAsStringSync();
    final userInfo = File(
      'lib/features/auth/data/datasources/'
      'user_info_remote_data_source_impl.dart',
    ).readAsStringSync();
    final bindContact = File(
      'lib/features/profile/presentation/bloc/bind_contact_cubit.dart',
    ).readAsStringSync();
    final injectionContainer = File(
      'lib/app/di/injection_container.dart',
    ).readAsStringSync();
    final aiChatBloc = File(
      'lib/features/ai_docs/presentation/bloc/ai_chat/ai_chat_bloc.dart',
    ).readAsStringSync();
    final sendMessage = File(
      'lib/features/chat/domain/usecases/send_message.dart',
    ).readAsStringSync();
    final chatRemote = File(
      'lib/features/chat/data/datasources/chat_remote_data_source.impl.dart',
    ).readAsStringSync();
    final chatBloc = File(
      'lib/features/chat/presentation/bloc/chat_messages/'
      'chat_messages_bloc.dart',
    ).readAsStringSync();
    final sellerRemote = File(
      'lib/features/seller/data/datasources/'
      'seller_remote_data_source_impl.dart',
    ).readAsStringSync();
    final homeRemote = File(
      'lib/features/home/data/datasources/home_remote_data_source.dart',
    ).readAsStringSync();
    final productReviews = File(
      'lib/features/home/data/datasources/'
      'product_reviews_remote_data_source.dart',
    ).readAsStringSync();
    final chatMessageDto = File(
      'lib/features/chat/data/models/chat_message_dto.dart',
    ).readAsStringSync();
    final globalNotification = File(
      'lib/core/widgets/global_message_notification.dart',
    ).readAsStringSync();
    final fileRemote = File(
      'lib/features/chat/data/datasources/file_remote_data_source.impl.dart',
    ).readAsStringSync();
    final messageInput = File(
      'lib/features/chat/presentation/widgets/message_input_bar.dart',
    ).readAsStringSync();
    final messageBubble = File(
      'lib/features/chat/presentation/widgets/chat_message_bubble.dart',
    ).readAsStringSync();
    final customInput = File(
      'lib/features/chat/presentation/widgets/custom_input_bar.dart',
    ).readAsStringSync();
    final chatPreload = File(
      'lib/features/chat/presentation/services/chat_preload_service.dart',
    ).readAsStringSync();

    final rawCodeLog = RegExp(
      r'(?:print|debugPrint)\([\s\S]{0,160}_codeController\.text',
    );
    expect(rawCodeLog.hasMatch(unifiedLogin), isFalse);
    expect(rawCodeLog.hasMatch(legacyLogin), isFalse);
    expect(unifiedLogin, isNot(contains('debugPrint(')));
    expect(legacyLogin,
        isNot(contains("print('Requesting code for \$fullPhone')")));
    expect(webSocket, isNot(contains('Connecting to: \$url')));
    expect(webSocket, isNot(contains('Sending Auth: \$authMessage')));
    expect(webSocket, isNot(contains('Received raw: \$message')));
    expect(webSocket, isNot(contains('Raw message: \$message')));
    expect(webSocket, isNot(contains('context=\$preview')));
    expect(webSocket, isNot(contains('\$senderName - \$content')));
    expect(dioHttpClient, isNot(contains('Body: \${request.body}')));
    expect(dioHttpClient, isNot(contains('Received chunk: \$chunkString')));
    expect(
        dioHttpClient, isNot(contains('Error response body: \$responseBody')));
    expect(dioHttpClient, isNot(contains('Data: \${error.response?.data}')));
    expect(aiChat, isNot(contains('jsonEncode(msgJson)')));
    expect(aiChat, isNot(contains('with data: \$requestData')));
    expect(aiChat, isNot(contains('Content chunk: \$contentChunk')));
    expect(aiChat, isNot(contains('Adding transcription: \$transcription')));
    expect(aiChat, isNot(contains('Data: \$data')));
    expect(userInfo, isNot(contains('响应数据: \${response.data}')));
    expect(userInfo, isNot(contains('解析用户数据: \$userData')));
    expect(bindContact, isNot(contains('发送验证码到: \$contact')));
    expect(bindContact, isNot(contains('绑定联系方式: \$contact')));
    expect(injectionContainer, isNot(contains('最终headers: \$safeHeaders')));
    expect(aiChatBloc, isNot(contains("Received stream chunk: '\$chunk'")));
    expect(aiChatBloc, isNot(contains('收到流式数据块: \${event.chunk}')));
    expect(aiChatBloc, isNot(contains('Starting upload for: \$imagePath')));
    expect(aiChatBloc, isNot(contains('Allocation successful: \$summary')));
    expect(aiChatBloc, isNot(contains('发送消息请求参数: \$sendMessageParams')));
    expect(aiChatBloc, isNot(contains('收到控制标记: \$chunk')));
    expect(sendMessage, isNot(contains('Context: \${messageToSend.context}')));
    expect(sendMessage, isNot(contains('URL: \$fileUrl')));
    expect(chatRemote, isNot(contains('Sending message: \${message.context}')));
    expect(chatBloc, isNot(contains('DTO: \${messageDto.toJson()}')));
    expect(chatBloc, isNot(contains('content: \${msg.context.substring')));
    expect(chatBloc, isNot(contains('Context=\${sentMessage.context}')));
    expect(sellerRemote, isNot(contains('完整请求数据: \$data')));
    expect(sellerRemote, isNot(contains('Response data fetched: \$data')));
    expect(sellerRemote, isNot(contains('草稿API响应: \$data')));
    expect(
        sellerRemote,
        isNot(contains(
            'Unexpected response format for notifications: \${response.data}')));
    expect(sellerRemote,
        isNot(contains('_mergeProductData - originalData: \$originalData')));
    expect(sellerRemote, isNot(contains('认证审核信息: \$auditInfo')));
    expect(sellerRemote, isNot(contains('解析认证图片: \$images')));
    expect(homeRemote, isNot(contains('API响应内容: \${response.body}')));
    expect(homeRemote, isNot(contains('搜索API请求体: \$body')));
    expect(productReviews, isNot(contains('API请求体: \$requestBody')));
    expect(productReviews, isNot(contains('API响应内容: \${response.body}')));
    expect(chatMessageDto, isNot(contains("context: '\$context'")));
    expect(globalNotification,
        isNot(contains('Notification displayed: \${event.content}')));
    expect(fileRemote, isNot(contains('Uploading file: \${file.path}')));
    expect(fileRemote, isNot(contains('File upload successful. URL:')));
    expect(fileRemote, isNot(contains('Response: \$responseData')));
    expect(fileRemote, isNot(contains('Response: \${e.response?.data}')));
    expect(
        messageInput, isNot(contains('Recording started: \$_recordingPath')));
    expect(messageInput, isNot(contains('Recording stopped: \$path')));
    expect(messageInput,
        isNot(contains('Image processed: \${processResult.finalFile.path}')));
    expect(messageBubble, isNot(contains('预加载音频时长: \$audioUrl')));
    expect(messageBubble, isNot(contains('加载错误: \$url')));
    expect(customInput, isNot(contains('Sending audio file: \$path')));
    expect(chatPreload, isNot(contains('preload image: \$url')));
    expect(chatPreload, isNot(contains('preloading image \$url')));
    expect(
      headerInterceptor,
      isNot(contains('当前headers: \${options.headers}')),
    );
  });
}
