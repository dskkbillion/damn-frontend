import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

/// Chat theme configuration matching the app's design
class ChatThemeConfig {
  /// Default chat theme
  static DefaultChatTheme get defaultTheme => const DefaultChatTheme(
    // Primary color for sent messages - matching original light blue
    primaryColor: Color(0xFFC9E6FF), // Light blue for current user (matching original)
    
    // Secondary color for received messages
    secondaryColor: Colors.white,
    
    // Background color
    backgroundColor: Color(0xFFEDEDED),
    
    // Input bar styling
    inputBackgroundColor: Colors.white,
    inputBorderRadius: BorderRadius.vertical(top: Radius.circular(0)),
    inputTextColor: Colors.black87,
    inputTextDecoration: InputDecoration(
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintText: '输入消息...',
      hintStyle: TextStyle(color: Colors.grey),
    ),
    inputPadding: EdgeInsets.all(12),
    inputMargin: EdgeInsets.zero,
    
    // Message styling - matching original padding
    messageBorderRadius: 16,
    messageInsetsHorizontal: 14, // Match original 14px horizontal
    messageInsetsVertical: 10,   // Match original 10px vertical
    
    // Sent message styling - dark text on light blue background
    sentMessageBodyTextStyle: TextStyle(
      color: Colors.black87,  // Dark text on light blue background
      fontSize: 15,  // Changed from 14 to 15 to match original
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    sentMessageLinkTitleTextStyle: TextStyle(
      color: Colors.black87,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    sentMessageLinkDescriptionTextStyle: TextStyle(
      color: Colors.black54,
      fontSize: 12,
    ),
    sentMessageDocumentIconColor: Colors.black54,
    sentMessageCaptionTextStyle: TextStyle(
      color: Colors.black54,
      fontSize: 12,
    ),
    
    // Received message styling
    receivedMessageBodyTextStyle: TextStyle(
      color: Colors.black87,
      fontSize: 15,  // Changed from 14 to 15 to match original
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    receivedMessageLinkTitleTextStyle: TextStyle(
      color: Colors.black87,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    receivedMessageLinkDescriptionTextStyle: TextStyle(
      color: Colors.black54,
      fontSize: 12,
    ),
    receivedMessageDocumentIconColor: Colors.black54,
    receivedMessageCaptionTextStyle: TextStyle(
      color: Colors.black54,
      fontSize: 12,
    ),
    
    // User avatar styling
    userAvatarNameColors: [
      Color(0xFF5B67F4),
      Color(0xFF00BCD4),
      Color(0xFF4CAF50),
      Color(0xFFFF9800),
      Color(0xFF9C27B0),
      Color(0xFFE91E63),
    ],
    userAvatarTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
    userNameTextStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.black54,
    ),
    
    // Date header styling
    dateDividerTextStyle: TextStyle(
      color: Colors.black54,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    dateDividerMargin: EdgeInsets.symmetric(vertical: 16),
    
    // Empty state styling
    emptyChatPlaceholderTextStyle: TextStyle(
      color: Colors.grey,
      fontSize: 14,
    ),
    
    // Error styling
    errorColor: Colors.red,
    errorIcon: Icon(Icons.error_outline),
    
    // Send button styling
    sendButtonIcon: Icon(Icons.send),
    sendButtonMargin: EdgeInsets.zero,
    
    // Attachment button styling
    attachmentButtonIcon: Icon(Icons.add_circle_outline),
    attachmentButtonMargin: EdgeInsets.zero,
    
    // Status icon theme
    deliveredIcon: Icon(Icons.done_all),
    seenIcon: Icon(Icons.done_all),
    sendingIcon: Icon(Icons.access_time),
    
    // Document icon
    documentIcon: Icon(Icons.insert_drive_file),
    
    // Reply message styling
    receivedEmojiMessageTextStyle: TextStyle(fontSize: 40),
    sentEmojiMessageTextStyle: TextStyle(fontSize: 40),
    
    // System message styling
    systemMessageTheme: SystemMessageTheme(
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      textStyle: TextStyle(
        color: Colors.black54,
        fontSize: 12,
      ),
    ),
    
    // Unread header
    unreadHeaderTheme: UnreadHeaderTheme(
      color: Color(0xFFE91E63),
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
    
    // Typography
    receivedMessageBodyBoldTextStyle: null,
    receivedMessageBodyCodeTextStyle: null,
    receivedMessageBodyLinkTextStyle: null,
    sentMessageBodyBoldTextStyle: null,
    sentMessageBodyCodeTextStyle: null,
    sentMessageBodyLinkTextStyle: null,
  );
  
  /// Dark theme variant (optional)
  static DarkChatTheme get darkTheme => const DarkChatTheme(
    primaryColor: Color(0xFF5B67F4),
    secondaryColor: Color(0xFF2B2B2B),
    backgroundColor: Color(0xFF1A1A1A),
    
    inputBackgroundColor: Color(0xFF2B2B2B),
    inputTextColor: Colors.white,
    inputTextDecoration: InputDecoration(
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintText: '输入消息...',
      hintStyle: TextStyle(color: Colors.grey),
    ),
    
    sentMessageBodyTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    
    receivedMessageBodyTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    
    userNameTextStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.grey,
    ),
    
    dateDividerTextStyle: TextStyle(
      color: Colors.grey,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    
    emptyChatPlaceholderTextStyle: TextStyle(
      color: Colors.grey,
      fontSize: 14,
    ),
  );
}