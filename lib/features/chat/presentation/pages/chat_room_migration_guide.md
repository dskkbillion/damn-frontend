# Chat Room Migration Guide

## Overview
This guide explains how to migrate from the old ChatRoomPage to the new ChatRoomPageRefactored that uses flutter_chat_ui.

## Key Changes

### 1. Architecture Changes
- **Old**: Single BLoC pattern (ChatMessagesBloc)
- **New**: Multiple Cubits for separation of concerns:
  - `ChatCubit`: Manages chat room state
  - `MessageListCubit`: Handles message list operations
  - `WebSocketCubit`: Manages WebSocket connections
  - `MessageQueueCubit`: Handles message sending queue

### 2. UI Library
- **Old**: Custom ListView implementation
- **New**: flutter_chat_ui library with custom widgets

### 3. Data Flow
- **Old**: Direct BLoC events and states
- **New**: Cubit-based state management with adapters

## Migration Steps

### Step 1: Update Navigation
Replace navigation to ChatRoomPage with ChatRoomPageRefactored:

```dart
// Old
context.push('/chat/$chatId').then((value) {
  // Handle return value
});

// New
context.push('/chat/refactored/$chatId').then((value) {
  // Handle return value
});
```

### Step 2: Update Route Configuration
In your router configuration:

```dart
// Add new route
GoRoute(
  path: '/chat/refactored/:chatId',
  builder: (context, state) {
    final chatId = int.parse(state.pathParameters['chatId']!);
    return ChatRoomPageRefactored(
      chatId: chatId,
      onMessagesLoaded: () {
        // Update unread count
      },
      onMessageRevoked: (chatId, newLastMessage) {
        // Update last message
      },
      onMessageSent: () {
        // Refresh chat list
      },
    );
  },
),
```

### Step 3: Update Parent Components
Update components that navigate to chat:

```dart
// ChatListPage
onChatTap: (chatRoom) {
  context.push('/chat/refactored/${chatRoom.id}');
}

// Product detail page
onChatWithSeller: () {
  context.push('/chat/refactored/$chatId');
}
```

### Step 4: Testing Phase
1. Keep both implementations side by side
2. Add feature flag to switch between old and new
3. Test new implementation thoroughly
4. Remove old implementation once stable

## Feature Comparison

| Feature | Old ChatRoomPage | New ChatRoomPageRefactored |
|---------|-----------------|---------------------------|
| Text messages | ✅ | ✅ |
| Image messages | ✅ | ✅ |
| Audio messages | ✅ | ✅ |
| File attachments | ✅ | ✅ |
| Allocate messages | ✅ | ✅ (Custom bubble) |
| Message withdrawal | ✅ | ✅ |
| Message deletion | ✅ | ✅ |
| Product header | ✅ | ✅ |
| Pagination | ✅ | ✅ |
| WebSocket | ✅ | ✅ (Improved) |
| Offline support | ❌ | ✅ (Local caching) |
| Performance | Good | Better |

## Testing Checklist

- [ ] Text message sending/receiving
- [ ] Image upload and display
- [ ] Audio recording and playback
- [ ] Message withdrawal within 2 minutes
- [ ] Message deletion
- [ ] Product header display
- [ ] Scroll to bottom on new message
- [ ] Load more messages on scroll
- [ ] WebSocket reconnection
- [ ] Offline message queue
- [ ] Read receipts
- [ ] Typing indicators (if implemented)

## Rollback Plan
If issues are found:
1. Revert navigation to use old ChatRoomPage
2. Keep new implementation for further testing
3. Fix issues in development environment
4. Re-deploy when stable

## Benefits of Migration
1. **Better Performance**: flutter_chat_ui is optimized for chat interfaces
2. **Cleaner Code**: Separation of concerns with multiple Cubits
3. **Better UX**: Smoother animations and interactions
4. **Offline Support**: Local caching for better offline experience
5. **Maintainability**: Easier to add new features and fix bugs