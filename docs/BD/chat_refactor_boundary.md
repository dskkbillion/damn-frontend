# Chat Module Refactoring with flutter_chat_ui

## Overview
This document defines the boundaries and implementation plan for refactoring the chat module using the flutter_chat_ui library while following Clean Architecture principles.

## Refactoring Goals
1. **Improve Performance**: Optimize message rendering with virtualized list
2. **Add Offline Support**: Implement local caching with Drift database
3. **Enhance Reliability**: Add WebSocket reconnection with exponential backoff
4. **Maintain Clean Architecture**: Preserve domain layer, enhance data and presentation layers
5. **Preserve Business Logic**: Keep all existing features including allocate messages

## Module Boundaries

### Domain Layer (No Changes)
- **Entities**: ChatMessage, Participant, ChatRoom remain unchanged
- **Use Cases**: All existing use cases preserved
- **Repository Interfaces**: Maintain current contracts

### Data Layer (Enhanced)
- **Local Data Source**: New SQLite tables for messages and chat rooms
- **Caching Strategy**: Write-through cache with offline queue
- **WebSocket Manager**: Enhanced with reconnection and ACK mechanism
- **Repository Implementation**: Updated to coordinate local and remote sources

### Presentation Layer (Refactored)
- **UI Components**: Migrate to flutter_chat_ui widgets
- **State Management**: Split into focused Cubits (Chat, MessageList, WebSocket, Queue)
- **Adapters**: Convert between domain entities and flutter_chat_ui types
- **Custom Widgets**: Allocate message bubble, media preview, audio player

## Dependencies
- `flutter_chat_ui: ^1.6.14` - Main chat UI library
- `drift` - Local database (already in project)
- `freezed` - State models (already in project)
- `flutter_bloc` - State management (already in project)

## Migration Strategy

### Phase 1: Setup and Dependencies ✅
- Create feature branch `refactor/chat-flutter-ui`
- Add flutter_chat_ui dependency
- Run code generation
- Create documentation

### Phase 2: Domain Layer Verification
- Review existing entities
- Confirm use cases remain unchanged
- Verify repository interfaces

### Phase 3: Data Layer Enhancement
- Design database schema
- Implement local data source
- Add caching to repository
- Enhance WebSocket reliability

### Phase 4: Presentation Adapters
- Create entity to UI type converters
- Handle custom message types
- Preserve existing features

### Phase 5: State Management
- Split monolithic BLoC into Cubits
- Use Freezed for state classes
- Implement queue management

### Phase 6: UI Migration
- Replace custom chat UI with flutter_chat_ui
- Configure theme to match design
- Integrate existing features

### Phase 7: Dependency Injection
- Update DI configuration
- Register new components
- Wire up dependencies

## Database Schema

### messages table
```sql
CREATE TABLE messages (
  id TEXT PRIMARY KEY,
  room_id TEXT NOT NULL,
  sender_id TEXT NOT NULL,
  content TEXT NOT NULL,
  type TEXT NOT NULL,
  timestamp INTEGER NOT NULL,
  status TEXT NOT NULL,
  metadata TEXT,
  FOREIGN KEY (room_id) REFERENCES chat_rooms(id)
);
```

### chat_rooms table
```sql
CREATE TABLE chat_rooms (
  id TEXT PRIMARY KEY,
  participants TEXT NOT NULL, -- JSON array
  last_message TEXT,
  updated_at INTEGER NOT NULL,
  unread_count INTEGER DEFAULT 0
);
```

## State Architecture

### Split BLoC Design
1. **ChatBloc**: Overall chat coordination
2. **MessageListCubit**: Message list management
3. **WebSocketCubit**: Connection status
4. **MessageQueueCubit**: Send queue management

### State Models (Freezed)
```dart
@freezed
class ChatState with _$ChatState {
  const factory ChatState.initial() = _Initial;
  const factory ChatState.loading() = _Loading;
  const factory ChatState.loaded(ChatRoom room) = _Loaded;
  const factory ChatState.error(String message) = _Error;
}
```

## Adapter Pattern

### Message Conversion
```dart
// Domain Entity -> UI Type
types.Message toUiMessage(ChatMessage entity)

// UI Type -> Domain Entity  
ChatMessage toDomainMessage(types.Message uiMessage)

// Custom allocate type handling
types.CustomMessage createAllocateMessage(AllocateData data)
```

## Testing Strategy
1. Unit tests for adapters
2. Widget tests for custom components
3. Integration tests for offline/online sync
4. Manual testing for UI/UX validation

## Rollback Plan
- Feature branch allows safe experimentation
- Domain layer unchanged enables easy rollback
- Parallel implementation allows A/B comparison

## Success Criteria
1. All existing features work as before
2. Message rendering performance improved
3. Offline messages queue and sync properly
4. WebSocket reconnects automatically
5. Clean Architecture principles maintained