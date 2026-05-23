part of 'ai_chat_bloc.dart';

/// 频率限制信息
class RateLimitInfo extends Equatable {
  final int remaining;
  final int resetInSeconds;
  final List<RuleStatus> rulesStatus;

  const RateLimitInfo({
    required this.remaining,
    required this.resetInSeconds,
    required this.rulesStatus,
  });

  @override
  List<Object?> get props => [remaining, resetInSeconds, rulesStatus];
}

/// 规则状态信息
class RuleStatus extends Equatable {
  final String name;
  final int currentCount;
  final int limit;
  final int remaining;
  final int windowMinutes;

  const RuleStatus({
    required this.name,
    required this.currentCount,
    required this.limit,
    required this.remaining,
    required this.windowMinutes,
  });

  @override
  List<Object?> get props => [name, currentCount, limit, remaining, windowMinutes];
}

/// 频率限制状态枚举
enum RateLimitStatus {
  initial,
  loading,
  loaded,
  error,
  limitExceeded,
}

/// Represents the status of AI chat operations (main chat area).
enum AiChatStatus {
  initial, // Initial state before loading
  loadingHistory, // Loading historical messages
  historyLoadSuccess, // Successfully loaded history
  historyLoadFailure, // Failed to load history
  sendingMessage, // Uploading files (if any) and sending message
  waitingForResponse, // <-- Add this status
  streamingResponse, // AI is generating and streaming response
  cancellingGeneration, // User requested cancellation of ongoing generation
  messageSendSuccess, // AI finished responding successfully
  messageSendFailure, // Failed to send message or stream response
  loadingRecommendations, // Loading related services
  recommendationsLoadSuccess, // Loaded related services
  recommendationsLoadFailure, // Failed to load related services
  allocatingResource, // Triggering allocation
  allocationSuccess, // Allocation successful
  allocationFailure, // Allocation failed
  transcribingAudio, // Transcribing audio
  transcriptionSuccess, // Transcription successful
  transcriptionFailure, // Transcription failed
}

/// Represents the status of the conversation list loading operation.
enum ConversationsStatus {
   initial,
   loading,
   loaded,
   error,
}

/// Represents the status of the recommendations loading operation.
enum RecommendationsStatus {
  initial,
  loading,
  loaded,
  error,
}

/// 已分发服务追溯入口(#347)的加载状态。
enum DispatchHistoryStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Represents the status of a service allocation.
enum AllocationStatus {
  initial, // 初始状态
  loading, // 正在分发中
  success, // 分发成功
  failure, // 分发失败
}

/// Represents the status of title operations.
enum TitleStatus {
  initial,
  generating, // AI正在生成标题
  updating,   // 正在更新标题
  success,    // 操作成功
  failure,    // 操作失败
}

// --- Define Image Upload State --- 
enum ImageUploadStatus { uploading, success, failure }

/// Represents the state of a single image upload.
class ImageUploadState extends Equatable {
  final ImageUploadStatus status;
  final String? url; // Only present on success
  final String? error; // Only present on failure

  const ImageUploadState._({
    required this.status,
    this.url,
    this.error,
  });

  // Factory constructors for convenience
  const factory ImageUploadState.uploading() = _Uploading;
  const factory ImageUploadState.success(String url) = _Success;
  const factory ImageUploadState.failure(String error) = _Failure;
  
  @override
  List<Object?> get props => [status, url, error];
}

// Private classes implementing the states
class _Uploading extends ImageUploadState {
  const _Uploading() : super._(status: ImageUploadStatus.uploading);
}
class _Success extends ImageUploadState {
  const _Success(String url) : super._(status: ImageUploadStatus.success, url: url);
}
class _Failure extends ImageUploadState {
  const _Failure(String error) : super._(status: ImageUploadStatus.failure, error: error);
}

/// {@template ai_chat_state}
/// Represents the state of the AI chat feature.
/// {@endtemplate}
class AiChatState extends Equatable {
  /// The current status of chat operations.
  final AiChatStatus status;
  /// The list of messages in the current conversation.
  final List<AiChatMessageEntity> messages;
  /// Flag indicating if there are more historical messages to load.
  final bool hasMoreHistory;
  /// The current text being streamed from the AI.
  final String streamingResponseText;
  /// List of text chunks for fade-in animation effect

  /// An error message if the last operation failed.
  final String? errorMessage;

  /// Conversation list state
  final ConversationsStatus conversationsStatus;
  final List<AiConversationEntity> conversations;
  final int? selectedConversationId;
  final String? conversationListErrorMessage;
  
  /// --- New fields for conversations pagination ---
  /// 是否正在加载更多对话
  final bool isLoadingMoreConversations;
  /// 对话列表当前页码
  final int conversationsCurrentPage;
  /// 对话列表总页数（如果后端提供）
  final int conversationsTotalPages;
  /// 对话列表总数（如果后端提供）
  final int totalConversationsCount;
  /// 对话列表是否还有更多页面
  final bool conversationsHasMore;

  /// The list of recommended services.
  final List<RelatedServiceEntity> recommendations;

  /// --- New fields for recommendations state ---
  final RecommendationsStatus recommendationsStatus;
  final String? recommendationsErrorMessage;

  /// 当前 conversation 的已分发商品历史(#347)。
  /// null = 未拉取 / 拉取失败回退;empty list = 拉取成功但无记录。
  final List<AllocatedItemEntity>? dispatchHistory;
  final DispatchHistoryStatus dispatchHistoryStatus;
  final String? dispatchHistoryErrorMessage;

  /// --- New field for service allocation status ---
  /// 用于跟踪每个服务的分发状态，键为服务ID，值为分发状态
  final Map<int, AllocationStatus> serviceAllocationStatus;

  /// --- New field for created chat room ID ---
  /// 存储通过优化分发流程创建的聊天室ID
  final int? createdChatRoomId;

  /// --- New fields for title operations ---
  final TitleStatus titleStatus;
  final String? titleErrorMessage;
  final Map<int, TitleStatus> conversationTitleStatus; // 跟踪每个会话的标题状态

  // --- Fields for image handling (Updated) ---
  /// Locally selected image files for preview before sending.
  final List<File>? pendingImageFiles;
  /// Tracks the upload state for each pending image file (path -> state).
  final Map<String, ImageUploadState>? imageUploadStates;

  // --- New fields for pagination ---
  /// 是否正在加载更多历史消息
  final bool isLoadingMoreHistory;
  /// 当前页码
  final int currentPage;
  /// 总页数（如果后端提供）
  final int totalPages;
  /// 总消息数（如果后端提供）
  final int totalMessages;
  /// 是否应该自动滚动到底部
  final bool shouldScrollToBottom;

  /// --- New fields for rate limit ---
  /// 频率限制状态
  final RateLimitStatus rateLimitStatus;
  /// 会话推荐的频率限制信息
  final RateLimitInfo? conversationRateLimit;
  /// 个性化推荐的频率限制信息
  final RateLimitInfo? personalizedRateLimit;
  /// 频率限制错误信息
  final String? rateLimitErrorMessage;

  /// {@macro ai_chat_state}
  const AiChatState({
    this.status = AiChatStatus.initial,
    this.messages = const [],
    this.hasMoreHistory = true,
    this.streamingResponseText = '',

    this.errorMessage,
    this.conversationsStatus = ConversationsStatus.initial,
    this.conversations = const [],
    this.selectedConversationId,
    this.conversationListErrorMessage,
    this.recommendationsStatus = RecommendationsStatus.initial,
    this.recommendations = const [],
    this.recommendationsErrorMessage,
    this.dispatchHistory,
    this.dispatchHistoryStatus = DispatchHistoryStatus.initial,
    this.dispatchHistoryErrorMessage,
    this.serviceAllocationStatus = const {}, // 默认为空映射
    this.createdChatRoomId,
    this.titleStatus = TitleStatus.initial,
    this.titleErrorMessage,
    this.conversationTitleStatus = const {},
    this.pendingImageFiles = const [],
    this.imageUploadStates = const {}, // Default to empty map
    // Pagination fields
    this.isLoadingMoreHistory = false,
    this.currentPage = 1,
    this.totalPages = 0,
    this.totalMessages = 0,
    this.shouldScrollToBottom = false,
    // Conversations pagination fields
    this.isLoadingMoreConversations = false,
    this.conversationsCurrentPage = 1,
    this.conversationsTotalPages = 0,
    this.totalConversationsCount = 0,
    this.conversationsHasMore = true,
    // Rate limit fields
    this.rateLimitStatus = RateLimitStatus.initial,
    this.conversationRateLimit,
    this.personalizedRateLimit,
    this.rateLimitErrorMessage,
  });

  /// Creates a copy of the current state with updated values.
  AiChatState copyWith({
    AiChatStatus? status,
    List<AiChatMessageEntity>? messages,
    bool? hasMoreHistory,
    String? streamingResponseText,

    String? errorMessage,
    ConversationsStatus? conversationsStatus,
    List<AiConversationEntity>? conversations,
    int? selectedConversationId,
    Object? selectedConversationIdOrNull = const Object(),
    String? conversationListErrorMessage,
    RecommendationsStatus? recommendationsStatus,
    List<RelatedServiceEntity>? recommendations,
    String? recommendationsErrorMessage,
    List<AllocatedItemEntity>? dispatchHistory,
    DispatchHistoryStatus? dispatchHistoryStatus,
    String? dispatchHistoryErrorMessage,
    bool clearDispatchHistory = false,
    Map<int, AllocationStatus>? serviceAllocationStatus,
    int? createdChatRoomId,
    TitleStatus? titleStatus,
    String? titleErrorMessage,
    Map<int, TitleStatus>? conversationTitleStatus,
    List<File>? pendingImageFiles,
    Map<String, ImageUploadState>? imageUploadStates,
    // Pagination parameters
    bool? isLoadingMoreHistory,
    int? currentPage,
    int? totalPages,
    int? totalMessages,
    bool? shouldScrollToBottom,
    // Conversations pagination parameters
    bool? isLoadingMoreConversations,
    int? conversationsCurrentPage,
    int? conversationsTotalPages,
    int? totalConversationsCount,
    bool? conversationsHasMore,
    // Rate limit parameters
    RateLimitStatus? rateLimitStatus,
    RateLimitInfo? conversationRateLimit,
    RateLimitInfo? personalizedRateLimit,
    String? rateLimitErrorMessage,
    // Clear flags
    bool clearErrorMessage = false,
    bool clearConversationListErrorMessage = false,
    bool clearRecommendationsErrorMessage = false,
    bool clearTitleErrorMessage = false,
    bool clearPendingImages = false,
    bool clearImageUploadStates = false,
    bool clearRateLimitErrorMessage = false,
  }) {
    final newSelectedId = selectedConversationIdOrNull == const Object()
                              ? this.selectedConversationId
                              : selectedConversationIdOrNull as int?;
    return AiChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      streamingResponseText: streamingResponseText ?? this.streamingResponseText,
  
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      conversationsStatus: conversationsStatus ?? this.conversationsStatus,
      conversations: conversations ?? this.conversations,
      selectedConversationId: newSelectedId,
      conversationListErrorMessage: clearConversationListErrorMessage
                                        ? null
                                        : conversationListErrorMessage ?? this.conversationListErrorMessage,
      recommendationsStatus: recommendationsStatus ?? this.recommendationsStatus,
      recommendations: recommendations ?? this.recommendations,
      recommendationsErrorMessage: clearRecommendationsErrorMessage
                                        ? null
                                        : recommendationsErrorMessage ?? this.recommendationsErrorMessage,
      dispatchHistory: clearDispatchHistory ? null : dispatchHistory ?? this.dispatchHistory,
      dispatchHistoryStatus: dispatchHistoryStatus ?? this.dispatchHistoryStatus,
      dispatchHistoryErrorMessage: dispatchHistoryErrorMessage ?? this.dispatchHistoryErrorMessage,
      serviceAllocationStatus: serviceAllocationStatus ?? this.serviceAllocationStatus,
      createdChatRoomId: createdChatRoomId ?? this.createdChatRoomId,
      titleStatus: titleStatus ?? this.titleStatus,
      titleErrorMessage: clearTitleErrorMessage ? null : titleErrorMessage ?? this.titleErrorMessage,
      conversationTitleStatus: conversationTitleStatus ?? this.conversationTitleStatus,
      pendingImageFiles: clearPendingImages ? [] : pendingImageFiles ?? this.pendingImageFiles,
      imageUploadStates: clearImageUploadStates ? {} : imageUploadStates ?? this.imageUploadStates,
      // Pagination fields
      isLoadingMoreHistory: isLoadingMoreHistory ?? this.isLoadingMoreHistory,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalMessages: totalMessages ?? this.totalMessages,
      shouldScrollToBottom: shouldScrollToBottom ?? this.shouldScrollToBottom,
      // Conversations pagination fields
      isLoadingMoreConversations: isLoadingMoreConversations ?? this.isLoadingMoreConversations,
      conversationsCurrentPage: conversationsCurrentPage ?? this.conversationsCurrentPage,
      conversationsTotalPages: conversationsTotalPages ?? this.conversationsTotalPages,
      totalConversationsCount: totalConversationsCount ?? this.totalConversationsCount,
      conversationsHasMore: conversationsHasMore ?? this.conversationsHasMore,
      // Rate limit fields
      rateLimitStatus: rateLimitStatus ?? this.rateLimitStatus,
      conversationRateLimit: conversationRateLimit ?? this.conversationRateLimit,
      personalizedRateLimit: personalizedRateLimit ?? this.personalizedRateLimit,
      rateLimitErrorMessage: clearRateLimitErrorMessage ? null : rateLimitErrorMessage ?? this.rateLimitErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        messages,
        hasMoreHistory,
        streamingResponseText,
  
        errorMessage,
        conversationsStatus,
        conversations,
        selectedConversationId,
        conversationListErrorMessage,
        recommendationsStatus,
        recommendations,
        recommendationsErrorMessage,
        dispatchHistory,
        dispatchHistoryStatus,
        dispatchHistoryErrorMessage,
        serviceAllocationStatus,
        createdChatRoomId,
        titleStatus,
        titleErrorMessage,
        conversationTitleStatus,
        pendingImageFiles,
        imageUploadStates,
        // Pagination props
        isLoadingMoreHistory,
        currentPage,
        totalPages,
        totalMessages,
        shouldScrollToBottom,
        // Conversations pagination props
        isLoadingMoreConversations,
        conversationsCurrentPage,
        conversationsTotalPages,
        totalConversationsCount,
        conversationsHasMore,
        // Rate limit props
        rateLimitStatus,
        conversationRateLimit,
        personalizedRateLimit,
        rateLimitErrorMessage,
      ];
} 