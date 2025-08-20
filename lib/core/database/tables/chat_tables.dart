import 'package:drift/drift.dart';

/// Table for storing chat messages locally
@DataClassName('ChatMessageCache')
class ChatMessages extends Table {
  @override
  String get tableName => 'chat_messages';
  // Message ID from the server
  IntColumn get id => integer()();
  
  // Chat room ID
  IntColumn get chatId => integer()();
  
  // Sender's ID 
  IntColumn get senderId => integer()();
  
  // Member ID (if sender is a member)
  IntColumn get memberId => integer().nullable()();
  
  // Doctor ID (if sender is a doctor)
  IntColumn get doctorId => integer().nullable()();
  
  // Message content (text, JSON for complex types)
  TextColumn get content => text()();
  
  // Message type (text, image, audio, video, allocate, etc.)
  TextColumn get messageType => text()();
  
  // Creation timestamp
  DateTimeColumn get createTime => dateTime()();
  
  // Whether message is withdrawn
  BoolColumn get withdrawFlag => boolean().withDefault(const Constant(false))();
  
  // Whether message is read
  BoolColumn get readFlag => boolean().nullable()();
  
  // Local status (sending, sent, failed, read)
  TextColumn get status => text().withDefault(const Constant('sent'))();
  
  // Metadata for additional info (JSON)
  TextColumn get metadata => text().nullable()();
  
  // Local timestamp for sorting
  DateTimeColumn get localTimestamp => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
  
  @override
  List<String> get customConstraints => [
    'UNIQUE(id, chat_id)'  // Fixed: use snake_case for SQL column name
  ];
}

/// Table for storing chat rooms locally
@DataClassName('ChatRoomCache')  
class ChatRooms extends Table {
  @override
  String get tableName => 'chat_rooms';
  // Chat room ID from server
  IntColumn get id => integer()();
  
  // First participant info (JSON)
  TextColumn get participant1 => text()();
  
  // Second participant info (JSON)
  TextColumn get participant2 => text()();
  
  // Unread message count
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  
  // Last message ID
  IntColumn get lastMessageId => integer().nullable()();
  
  // Product info (JSON) - contains productId, productName, productImage, productPrice
  TextColumn get productInfo => text().nullable()();
  
  // Last activity timestamp
  DateTimeColumn get lastActivityTime => dateTime().nullable()();
  
  // Local update timestamp
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Table for offline message queue
@DataClassName('MessageQueueItem')
class MessageQueue extends Table {
  @override
  String get tableName => 'message_queue';
  // Local ID for queue management
  IntColumn get id => integer().autoIncrement()();
  
  // Chat room ID
  IntColumn get chatId => integer()();
  
  // Message content
  TextColumn get content => text()();
  
  // Message type
  TextColumn get messageType => text()();
  
  // Retry count
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  
  // Maximum retries allowed
  IntColumn get maxRetries => integer().withDefault(const Constant(3))();
  
  // Creation timestamp
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // Last retry timestamp
  DateTimeColumn get lastRetryAt => dateTime().nullable()();
  
  // Status (pending, sending, failed)
  TextColumn get status => text().withDefault(const Constant('pending'))();
  
  // Error message if failed
  TextColumn get errorMessage => text().nullable()();
}