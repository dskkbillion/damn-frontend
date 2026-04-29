/// 聊天模块 API 端点路径常量。
abstract final class ChatApiEndpoints {
  static const chatList = '/api/chat/list';
  static const messageList = '/api/chat/message/list';
  static const addChat = '/api/chat/addChat';
  static const sendMessage = '/common/chat/message/add';
  static const withdrawMessage = '/api/chat/message/withdraw';
  static const getChatRoom = '/api/chat/get';
  static const deleteMessages = '/api/chat/message/delete';
  static const uploadFile = '/api/common/public/upload';
  static const deleteChatRooms = '/api/chat/delete';
}
