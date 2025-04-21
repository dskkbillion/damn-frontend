import 'dart:io'; // Needed for File in mock SendMessage
import 'dart:async';
import 'dart:math'; // For Random in mock data
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dartz/dartz.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import for date formatting initialization
import 'package:dio/dio.dart';

// Core imports
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart'; // For NoParams
import 'package:dskk_flutter_refactor/core/config/app_theme.dart'; // Assuming theme exists
import 'package:dskk_flutter_refactor/core/navigation/navigation_service.dart'; // For mock navigation

// Chat feature imports (Domain)
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_room.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/participant.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/repositories/i_chat_repository.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/repositories/i_file_repository.dart'; // Corrected import path
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/get_chat_room_list.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/get_message_list.dart'; // Corrected import path
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/send_message.dart'; // Corrected import path
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/revoke_message.dart'; // Corrected import path
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/get_chat_room_details.dart'; // Corrected import path
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/delete_chat_message.dart'; // Import DeleteChatMessage
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/create_chat_room.dart'; // Import CreateChatRoom

// Auth feature imports (Domain) - Assuming these exist now
import 'package:dskk_flutter_refactor/features/auth/domain/entities/user.dart'; // Corrected import path
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_user_repository.dart'; // Corrected import path
import 'package:dskk_flutter_refactor/core/error/failures.dart'; // Import Failures

// Chat feature imports (Data)
import 'package:dskk_flutter_refactor/features/chat/data/datasources/i_chat_web_socket_data_source.dart'; // Import WS Interface
import 'package:dskk_flutter_refactor/features/chat/data/datasources/chat_web_socket_data_source.impl.dart'; // Import WS Implementation
import 'package:dskk_flutter_refactor/features/chat/data/datasources/chat_remote_data_source.impl.dart';
import 'package:dskk_flutter_refactor/features/chat/data/datasources/file_remote_data_source.impl.dart';
import 'package:dskk_flutter_refactor/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:dskk_flutter_refactor/features/chat/data/repositories/file_repository_impl.dart';

// Chat feature imports (Presentation)
import 'package:dskk_flutter_refactor/features/chat/presentation/bloc/chat_list/chat_list_bloc.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/bloc/chat_messages/chat_messages_bloc.dart'; // Need ChatMessagesBloc
import 'package:dskk_flutter_refactor/features/chat/presentation/pages/chat_list_page.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/pages/chat_room_page.dart'; // Need ChatRoomPage
import 'package:dskk_flutter_refactor/features/chat/presentation/widgets/chat_message_bubble.dart'; // Import ChatMessageBubble

// FIX: Add imports for DataSource interfaces
import 'package:dskk_flutter_refactor/features/chat/data/datasources/i_chat_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/chat/data/datasources/i_file_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/chat/data/datasources/i_chat_web_socket_data_source.dart';
// Import implementations
import 'package:dskk_flutter_refactor/features/chat/data/datasources/chat_remote_data_source.impl.dart';
import 'package:dskk_flutter_refactor/features/chat/data/datasources/file_remote_data_source.impl.dart';
import 'package:dskk_flutter_refactor/features/chat/data/datasources/chat_web_socket_data_source.impl.dart';
import 'package:dskk_flutter_refactor/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:dskk_flutter_refactor/features/chat/data/repositories/file_repository_impl.dart';
// Import the HeaderInterceptor
import 'package:dskk_flutter_refactor/core/network/header_interceptor.dart';

final sl = GetIt.instance;

// --- Mock Implementations ---

// Mock Participants and User
const mockUser = User(id: 1, commonUserId: 'user-123', nickName: 'Me', type: 'MEMBER'); // User.id is commonUserId (1)
// FIX: Add referId to mock participants matching their corresponding commonUserId (or id for simplicity)
const mockCurrentUserParticipant = Participant(id: 1, nickName: 'Me', type: 'MEMBER', referId: 1); 
const mockOpponent1 = Participant(id: 2, nickName: 'Alice', avatar: null, type: 'MEMBER', referId: 2);
const mockOpponent2 = Participant(id: 3, nickName: 'Bob', avatar: null, type: 'MEMBER', referId: 3);
const mockOpponent3 = Participant(id: 4, nickName: 'Charlie', type: 'MEMBER', avatar: null, referId: 4);

class MockChatRepository implements IChatRepository {
  final Map<int, List<ChatMessage>> _mockMessages = {
    101: [
      ChatMessage(id: 1001, chatId: 101, senderId: 2, memberId: 2, doctorId: 1, context: 'Hey Me!', type: 'text', createTime: DateTime.now().subtract(const Duration(minutes: 10)), withdrawFlag: false, status: MessageStatus.sent),
      ChatMessage(id: 1002, chatId: 101, senderId: 1, memberId: 1, doctorId: 2, context: 'Hey Alice! How are you?', type: 'text', createTime: DateTime.now().subtract(const Duration(minutes: 5)), withdrawFlag: false, status: MessageStatus.sent),
      ChatMessage(id: 1003, chatId: 101, senderId: 2, memberId: 2, doctorId: 1, context: 'https://via.placeholder.com/300/92c952', type: 'image', createTime: DateTime.now().subtract(const Duration(minutes: 2)), withdrawFlag: false, status: MessageStatus.sent),
    ],
    102: [
      ChatMessage(id: 2001, chatId: 102, senderId: 3, memberId: 3, doctorId: 1, context: 'Did you see the report?', type: 'text', createTime: DateTime.now().subtract(const Duration(hours: 3)), withdrawFlag: false, status: MessageStatus.sent),
      ChatMessage(id: 2002, chatId: 102, senderId: 1, memberId: 1, doctorId: 3, context: 'Okay, sounds good.', type: 'text', createTime: DateTime.now().subtract(const Duration(hours: 2)), withdrawFlag: false, status: MessageStatus.sent),
    ],
    103: [
      ChatMessage(id: 3001, chatId: 103, senderId: 1, memberId: 1, doctorId: 4, context: 'Meeting reminder for tomorrow.', type: 'text', createTime: DateTime.now().subtract(const Duration(days: 1)), withdrawFlag: false, status: MessageStatus.sent),
    ],
  };

  late final Map<int, ChatRoom> _mockRoomDetails = {
    101: ChatRoom(
      id: 101,
      // FIX: Use updated participant mocks with referId
      participant1: mockCurrentUserParticipant,
      participant2: mockOpponent1, 
      unreadCount: 2,
      lastMessage: ChatMessage(
          id: 1, chatId: 101, senderId: mockOpponent1.id, memberId: mockOpponent1.id, context: 'Hello there!', type: 'text', createTime: DateTime.now().subtract(const Duration(minutes: 5)), withdrawFlag: false, status: MessageStatus.sent)
    ),
    102: ChatRoom(
      id: 102,
      // FIX: Use updated participant mocks with referId
      participant1: mockCurrentUserParticipant, 
      participant2: mockOpponent2,
      unreadCount: 0,
      lastMessage: ChatMessage(
          id: 2, chatId: 102, senderId: mockCurrentUserParticipant.id, memberId: mockCurrentUserParticipant.id, context: 'Image sent', type: 'image', createTime: DateTime.now().subtract(const Duration(hours: 1)), withdrawFlag: false, status: MessageStatus.sent)
    ),
     103: ChatRoom(
      id: 103,
       // FIX: Use updated participant mocks with referId
      participant1: mockOpponent3, 
      participant2: mockCurrentUserParticipant,
      unreadCount: 1,
      lastMessage: ChatMessage(
          id: 3, chatId: 103, senderId: mockOpponent3.id, memberId: mockOpponent3.id, context: 'Audio message', type: 'audio', createTime: DateTime.now().subtract(const Duration(days: 1)), withdrawFlag: false, status: MessageStatus.sent)
    ),
  };

  @override
  Future<Either<Failure, List<ChatRoom>>> getChatRooms() async {
    print('[MockChatRepository] Getting mock chat rooms...');
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    final mockRooms = _mockRoomDetails.values.toList();
    print('[MockChatRepository] Returning ${mockRooms.length} mock rooms.');
    return Right(mockRooms);
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(int chatId) async {
    print('[MockChatRepository] Getting mock messages for chatId: $chatId');
    await Future.delayed(const Duration(milliseconds: 500));
    if (_mockMessages.containsKey(chatId)) {
      print('[MockChatRepository] Found ${_mockMessages[chatId]!.length} messages.');
      // Simulate marking as read implicitly
      if (_mockRoomDetails.containsKey(chatId)) {
         _mockRoomDetails[chatId] = _mockRoomDetails[chatId]!.copyWith(unreadCount: 0);
      }
      return Right(List.from(_mockMessages[chatId]!)); // Return a copy
    } else {
      print('[MockChatRepository] Chat room not found.');
      return Left(ServerFailure(message: "Chat room not found"));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage(ChatMessage message) async {
    print('[MockChatRepository] Sending mock message: ${message.context}');
    await Future.delayed(const Duration(milliseconds: 300));
    final newMessage = message.copyWith(
      id: Random().nextInt(10000) + 5000, // Assign a mock ID
      createTime: DateTime.now(),
      status: MessageStatus.sent,
      senderId: mockCurrentUserParticipant.id, // Ensure senderId is set based on mock current user
    );
    if (_mockMessages.containsKey(message.chatId)) {
      _mockMessages[message.chatId]!.add(newMessage);
      _mockRoomDetails[message.chatId] = _mockRoomDetails[message.chatId]!.copyWith(lastMessage: newMessage);
       print('[MockChatRepository] Message added.');
      return Right(newMessage);
    } else {
       print('[MockChatRepository] Chat room not found for sending.');
      return Left(ServerFailure(message: "Cannot send message, chat room not found"));
    }
  }

   @override
  Future<Either<Failure, int>> createRoom(int participantId) async {
    print('[MockChatRepository] Creating mock room with participantId: $participantId');
    await Future.delayed(const Duration(seconds: 1));
    final newChatId = Random().nextInt(100) + 200;
    final opponent = participantId == 2 ? mockOpponent1 :
                     participantId == 3 ? mockOpponent2 :
                     participantId == 4 ? mockOpponent3 :
                     Participant(id: participantId, nickName: 'Unknown User $participantId', type: 'MEMBER'); // Added type

    final newRoom = ChatRoom(
        id: newChatId,
        participant1: mockCurrentUserParticipant,
        participant2: opponent,
        unreadCount: 0,
        lastMessage: null,
    );
    _mockRoomDetails[newChatId] = newRoom;
    _mockMessages[newChatId] = [];
    print('[MockChatRepository] Created mock room with ID: $newChatId');
    return Right(newChatId);
  }

  @override
  Future<Either<Failure, void>> revokeMessage(int messageId) async {
    print('[MockChatRepository] Revoking mock message: $messageId');
    await Future.delayed(const Duration(milliseconds: 200));
    bool found = false;
    for (var entry in _mockMessages.entries) {
      final chatId = entry.key;
      final roomMessages = entry.value;
      final index = roomMessages.indexWhere((msg) => msg.id == messageId);
      if (index != -1) {
        // Simulate only allowing sender to revoke within a time limit (e.g., 2 mins)
        if(roomMessages[index].senderId == mockCurrentUserParticipant.id /* && DateTime.now().difference(roomMessages[index].createTime!).inMinutes < 2 */){
            roomMessages[index] = roomMessages[index].copyWith(withdrawFlag: true, context: 'Message revoked', type: 'revoke');
            print('[MockChatRepository] Message revoked successfully.');
            found = true;
            // Update last message if this was the last one
            if(_mockRoomDetails.containsKey(chatId) && _mockRoomDetails[chatId]!.lastMessage?.id == messageId) {
                 _mockRoomDetails[chatId] = _mockRoomDetails[chatId]!.copyWith(lastMessage: roomMessages[index]);
            }
            return const Right(null);
        } else {
            print('[MockChatRepository] Revocation failed (not sender or time limit exceeded).');
             return Left(ServerFailure(message: "Cannot revoke message"));
        }
      }
    }
     print('[MockChatRepository] Message not found for revocation.');
    return Left(ServerFailure(message: "Message not found"));
  }

  @override
  Future<Either<Failure, ChatRoom>> getRoomDetails(int chatId) async {
    print('[MockChatRepository] Getting mock room details for chatId: $chatId');
    await Future.delayed(const Duration(milliseconds: 100));
    if (_mockRoomDetails.containsKey(chatId)) {
      print('[MockChatRepository] Found room details.');
      return Right(_mockRoomDetails[chatId]!);
    } else {
      print('[MockChatRepository] Room details not found.');
      return Left(ServerFailure(message: "Chat room details not found"));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChatMessages(List<int> messageIds, int chatId) async {
    print('[MockChatRepository] Deleting mock messages: $messageIds in chatId: $chatId');
    await Future.delayed(const Duration(milliseconds: 200));
    if (_mockMessages.containsKey(chatId)) {
      _mockMessages[chatId]!.removeWhere((msg) => messageIds.contains(msg.id));
      print('[MockChatRepository] Messages deleted.');
      // Potentially update last message if needed
      return const Right(null);
    } else {
      print('[MockChatRepository] Chat room not found for deletion.');
      return Left(ServerFailure(message: "Chat room not found"));
    }
  }

  // --- Implement other IChatRepository methods later --- 
}

// Add Mock IFileRepository if SendMessage needs it for image/audio
class MockFileRepository implements IFileRepository {
   @override
  Future<Either<Failure, String>> uploadFile(File file) async {
    print('[MockFileRepository] Uploading mock file: ${file.path}');
    await Future.delayed(const Duration(seconds: 2)); // Simulate upload
    // Return a mock URL
    final mockUrl = 'https://via.placeholder.com/300/aabbcc?text=Uploaded+${DateTime.now().millisecondsSinceEpoch}';
    print('[MockFileRepository] Mock upload complete: $mockUrl');
    return Right(mockUrl);
  }
}

// Add Mock IUserRepository
class MockUserRepository implements IUserRepository {
  // Simulate a logged-in user
  // FIX: Update mock user ID to reflect the referId 10307
  final mockUser = const User(id: 10307, commonUserId: 'user-mock-10307', nickName: 'Me (10307)', type: 'MEMBER');

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    print('[MockUserRepository] Getting mock current user...');
    await Future.delayed(const Duration(milliseconds: 50)); // Simulate short delay
    print('[MockUserRepository] Returning mock user: ${mockUser.nickName}');
    return Right(mockUser);
  }
  
  // Implement other methods if needed by Chat feature, otherwise throw UnimplementedError
  @override
  Future<Either<Failure, User>> getUserById(int userId) async {
    print('[MockUserRepository] Getting mock user by ID: $userId');
    // Simple mock: return the main mock user if ID matches, otherwise failure
    if (userId == mockUser.id) {
      return Right(mockUser);
    } else {
      // Simulate finding another user based on participant ID (needs more data)
       if(userId == 10304) return Right(User(id: 10307, commonUserId: 'user-mock-10307', nickName: 'Test (from 10304)', type: 'MEMBER'));
       if(userId == 10290) return Right(User(id: 1, commonUserId: 'user-mock-1', nickName: '瑞 (from 10290)', type: 'MEMBER'));
       if(userId == 10313) return Right(User(id: 10315, commonUserId: 'user-mock-10315', nickName: '133****3 (from 10313)', type: 'MEMBER'));
       if(userId == 10288) return Right(User(id: 10294, commonUserId: 'user-mock-10294', nickName: '188****9 (from 10288)', type: 'MEMBER'));
       if(userId == 10312) return Right(User(id: 1, commonUserId: 'user-mock-admin-1', nickName: '系统管理员 (from 10312)', type: 'ADMIN'));
       print('[MockUserRepository] User not found for ID: $userId');
       return Left(NotFoundFailure());
    }
  }
}

class MockNavigationService implements NavigationService {
  @override
  GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();

  @override
  void pop<T extends Object?>([T? result]) {
    print('[MockNavigation] pop called with result: $result');
    navigatorKey?.currentState?.pop(result);
  }

  @override
  Future<T?>? pushNamed<T extends Object?>(
    String name, {
    Map<String, String> params = const {},
    Map<String, dynamic> queryParams = const {},
    Object? extra,
  }) {
    print('[MockNavigation] pushNamed $name called with params: $params, query: $queryParams, extra: $extra');
    // Simulate navigation if needed, for now return null
    // navigatorKey?.currentState?.pushNamed(name, arguments: extra); 
    return Future.value(null); // Return a Future for compatibility
  }

  @override
  Future<T?>? navigateTo<T extends Object?>(String routeName, {Object? arguments}) {
    print('[MockNavigation] navigateTo $routeName called with arguments: $arguments');
    // Simulate navigation if needed
    // navigatorKey?.currentState?.pushNamed(routeName, arguments: arguments);
    return Future.value(null); // Return a Future for compatibility
  }

  @override
  void goBack<T extends Object?>([T? result]) {
    print('[MockNavigation] goBack called with result: $result');
    navigatorKey?.currentState?.pop(result);
  }

  // Implement other methods from NavigationService if they exist and are needed
  // e.g., pushReplacementNamed, etc.
}

// FIX: Define Mock Use Case Classes

class MockGetChatRoomList implements GetChatRoomList {
  @override
  Future<Either<Failure, List<ChatRoom>>> call(NoParams params) async {
    print('[MockGetChatRoomList] Called');
    // Simulate using MockChatRepository logic or return a predefined list
    final repo = sl<IChatRepository>(); // Can use the registered mock repo
    if (repo is MockChatRepository) {
      return await repo.getChatRooms(); // Leverage existing mock repo logic
    } else {
      // Fallback if repo isn't the expected mock type
      await Future.delayed(const Duration(milliseconds: 100));
      return Right([sl<MockChatRepository>()._mockRoomDetails[101]!]); // Example fallback
    }
  }
}

class MockGetMessageList implements GetMessageList {
  @override
  Future<Either<Failure, List<ChatMessage>>> call(GetMessageListParams params) async {
     print('[MockGetMessageList] Called for chatId: ${params.chatId}');
     final repo = sl<IChatRepository>();
     if (repo is MockChatRepository) {
      return await repo.getMessages(params.chatId);
    } else {
       await Future.delayed(const Duration(milliseconds: 100));
       return const Right([]);
    }
  }
}

class MockRevokeMessage implements RevokeMessage {
  @override
  Future<Either<Failure, void>> call(RevokeMessageParams params) async {
     print('[MockRevokeMessage] Called for messageId: ${params.messageId}');
      final repo = sl<IChatRepository>();
     if (repo is MockChatRepository) {
      return await repo.revokeMessage(params.messageId);
    } else {
       await Future.delayed(const Duration(milliseconds: 100));
       return const Right(null);
    }
  }
}

class MockGetChatRoomDetails implements GetChatRoomDetails {
  @override
  Future<Either<Failure, ChatRoom>> call(GetChatRoomDetailsParams params) async {
     print('[MockGetChatRoomDetails] Called for chatId: ${params.chatId}');
     final repo = sl<IChatRepository>();
     if (repo is MockChatRepository) {
      return await repo.getRoomDetails(params.chatId);
    } else {
       await Future.delayed(const Duration(milliseconds: 100));
       // Need a default ChatRoom mock if repo isn't the right mock
        return Left(ServerFailure(message: "Mock repo not found"));
    }
  }
}

class MockDeleteChatMessage implements DeleteChatMessage {
   @override
  Future<Either<Failure, void>> call(DeleteChatMessageParams params) async {
     print('[MockDeleteChatMessage] Called for messageIds: ${params.messageIds}, chatId: ${params.chatId}');
      final repo = sl<IChatRepository>();
     if (repo is MockChatRepository) {
      return await repo.deleteChatMessages(params.messageIds, params.chatId);
    } else {
       await Future.delayed(const Duration(milliseconds: 100));
       return const Right(null);
    }
  }
}

// Register CreateChatRoom Use Case
class MockCreateChatRoom implements CreateChatRoom {
  @override
  Future<Either<Failure, int>> call(CreateChatRoomParams params) async {
    print('[MockCreateChatRoom] Called for params: $params');
    final repo = sl<IChatRepository>();
    if (repo is MockChatRepository) {
      return await repo.createRoom(params.participantId);
    } else {
      await Future.delayed(const Duration(milliseconds: 100));
      return Left(ServerFailure(message: "Mock repo not found"));
    }
  }
}

// --- Dependency Injection Setup ---
Future<void> setupLocator() async {
  print('Setting up locator...');
  // Register Core Dependencies (if needed for preview, e.g., Theme)
  // sl.registerLazySingleton(() => AppTheme());

  // Register Auth Mock Dependencies (Needed for current user ID)
  sl.registerLazySingleton<IUserRepository>(() => MockUserRepository());

  // Register Chat Mock Dependencies
  // Comment out the mock repository to use the real one (if configured)
  // sl.registerLazySingleton<IChatRepository>(() => MockChatRepository());

  // Register Mock File Repository (Keep this mock unless SendMessage test needs real file upload)
  // FIX: Comment out mock and register real implementation
  // sl.registerLazySingleton<IFileRepository>(() => MockFileRepository());
  sl.registerLazySingleton<IFileRepository>(() => FileRepositoryImpl(remoteDataSource: sl()));

  // Register Mock WebSocket DataSource (Comment out if using real repo/ws)
  // sl.registerLazySingleton<IChatWebSocketDataSource>(() => MockChatWebSocketDataSource());

  // !!! IMPORTANT: Register REAL DataSources if NOT using Mock Repository !!!
  // These will be picked up by the real Repository implementation if it's used.
  // Ensure Dio is registered before these (or passed explicitly).
  // This setup assumes you want to test with REAL DataSources but potentially
  // mock the repository itself earlier. If you comment out MockChatRepository,
  // you likely want the REAL repository which depends on these REAL sources.

  // Register Mock RemoteDataSource first if needed (Keep commented)
  // sl.registerLazySingleton<IChatRemoteDataSource>(() => MockChatRemoteDataSource());
  // sl.registerLazySingleton<IFileRemoteDataSource>(() => MockFileRemoteDataSource());

  // --- Use Cases --- 
  // Assume UseCases depend on the Repository INTERFACE, so they work with Mock or Real Repo
  // FIX: Register IMPLEMENTATION classes AS the INTERFACE type
  sl.registerLazySingleton<GetChatRoomList>(() => GetChatRoomListImpl(sl()));
  sl.registerLazySingleton<GetMessageList>(() => GetMessageListImpl(sl()));
  sl.registerLazySingleton<SendMessage>(() => SendMessageImpl(sl(), sl())); // Requires IChatRepository & IFileRepository
  sl.registerLazySingleton<RevokeMessage>(() => RevokeMessageImpl(sl()));
  sl.registerLazySingleton<GetChatRoomDetails>(() => GetChatRoomDetailsImpl(sl()));
  sl.registerLazySingleton<DeleteChatMessage>(() => DeleteChatMessageImpl(sl()));
  // Register CreateChatRoom Use Case
  sl.registerLazySingleton<CreateChatRoom>(() => CreateChatRoomImpl(sl()));

  // --- Blocs --- 
  // Now ChatListBloc can resolve GetChatRoomList correctly
  // FIX: Provide createChatRoom dependency
  sl.registerFactory(() => ChatListBloc(getChatRoomList: sl(), createChatRoom: sl())); 
  sl.registerFactoryParam<ChatMessagesBloc, int, void>(
    (chatId, _) => ChatMessagesBloc(
      chatId: chatId,
      getMessageList: sl(),
      sendMessage: sl(),
      revokeMessage: sl(),
      getChatRoomDetails: sl(),
      userRepository: sl(), // Need Mock or Real User Repo
      deleteChatMessage: sl(),
      // Inject WebSocket DataSource - If using real repo, this needs real WS source
      webSocketDataSource: sl(), // Inject the REAL WS DataSource now
    ),
  );

   // Register Mock Navigation Service (Keep for preview)
   sl.registerLazySingleton<NavigationService>(() => MockNavigationService());

   // Register Dio (use a simple one for preview, or configure as needed)
   sl.registerLazySingleton<Dio>(() {
      print('--- Creating Dio Instance (Preview Setup - Real API) ---');
      // CONFIGURE DIO FOR REAL API
      final dio = Dio(BaseOptions(
         baseUrl: "https://app.duoshaokankan.com/prod-api", // UPDATE to HTTPS based on .env
         connectTimeout: const Duration(seconds: 15),
         receiveTimeout: const Duration(seconds: 30),
         headers: {
           'Accept': 'application/json',
           // Auth header will be added by interceptor now
         },
      ));
      // ADD INTERCEPTORS TO THIS PREVIEW INSTANCE AS WELL
      dio.interceptors.add(HeaderInterceptor()); // Add the header interceptor
      // dio.interceptors.add(LoggingInterceptor()); // Optional: Add logging
      // dio.interceptors.add(AuthInterceptor(sl())); // TODO: Add Auth Interceptor if needed for preview
      print('--- Dio Instance (Preview Setup - Real API) Created with Interceptors ---');
      return dio;
   });

   // --- REGISTER REAL DATASOURCES HERE SINCE MOCK REPOSITORY IS COMMENTED OUT --- 
   // Uncomment these lines if you want main_chat_preview to use REAL datasources
   // Ensure Dio is registered before these
   sl.registerLazySingleton<IChatRemoteDataSource>(
       () => ChatRemoteDataSourceImpl(dio: sl()));
   sl.registerLazySingleton<IFileRemoteDataSource>(
       () => FileRemoteDataSourceImpl(dio: sl()));
   sl.registerLazySingleton<IChatWebSocketDataSource>(
       () => ChatWebSocketDataSourceImpl()); // WebSocket Impl doesn't need Dio in constructor
   

    // --- REGISTER REAL REPOSITORY HERE SINCE MOCK REPOSITORY IS COMMENTED OUT --- 
   // Uncomment this if you want to use the real repository which depends on real sources
   // Ensure REAL sources are registered above
   sl.registerLazySingleton<IChatRepository>(
       () => ChatRepositoryImpl(
            remoteDataSource: sl(),
            // Assuming localDataSource is not used or mocked elsewhere if needed 
            // localDataSource: sl(), 
            // FIX: Provide the required userRepository dependency
            userRepository: sl(), 
            // FIX: Remove webSocketDataSource from constructor call as it's not needed
            // webSocketDataSource: sl(),
          ));
    
}

// --- Main Application ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize date formatting for the 'intl' package
  // You might want to use a specific locale if needed, e.g., 'zh_CN'
  await initializeDateFormatting('en_US', null);
  await setupLocator();
  runApp(const ChatPreviewApp());
}

class ChatPreviewApp extends StatelessWidget {
  const ChatPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Module Preview',
      theme: AppTheme.lightTheme, // Use a default theme or your AppTheme
      // === Restore ChatListPage as home ===
      home: BlocProvider(
        create: (_) => sl<ChatListBloc>()..add(LoadChatRoomList()), // Create ChatListBloc and load initial data
        child: const ChatListPage(), // Entry point is the ChatListPage
      ),
      // === Remove direct routing to ChatRoomPage ===
      // home: BlocProvider(
      //   create: (_) => sl<ChatMessagesBloc>(param1: 101) // Provide mock chatId 101
      //                  ..add(const LoadChatMessages(101)),
      //   child: const ChatRoomPage(chatId: 101), // Pass mock chatId
      // ),
      navigatorKey: sl<NavigationService>().navigatorKey, // Keep for potential mock navigation usage
    );
  }
} 