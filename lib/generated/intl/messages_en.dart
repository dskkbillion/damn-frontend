// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(error) => "Error selecting image: ${error}";

  static String m1(error) => "Failed to load recommendations: ${error}";

  static String m2(error) => "Error starting recording: ${error}";

  static String m3(error) => "Error stopping recording: ${error}";

  static String m4(error) => "Loading failed: ${error}";

  static String m5(error) => "Error selecting image: ${error}";

  static String m6(error) => "Error starting recording: ${error}";

  static String m7(duration) => "Release to Send (${duration}s)";

  static String m8(error) => "Error stopping recording: ${error}";

  static String m9(targetType, targetValue) =>
      "Banner clicked: ${targetType} - ${targetValue}";

  static String m10(error) => "Loading failed: ${error}";

  static String m11(name) => "Service card clicked: ${name}";

  static String m12(name) => "Let them see button clicked: ${name}";

  static String m13(error) => "Loading failed: ${error}";

  static String m14(error) => "Unable to navigate to order list: ${error}";

  static String m15(error) => "Unable to switch to seller mode: ${error}";

  static String m16(error) => "Search failed: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "ai_docs_add_image": MessageLookupByLibrary.simpleMessage("Add Image"),
    "ai_docs_assistant_title": MessageLookupByLibrary.simpleMessage(
      "AI Assistant",
    ),
    "ai_docs_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "ai_docs_conversation_list": MessageLookupByLibrary.simpleMessage(
      "Conversation List",
    ),
    "ai_docs_delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "ai_docs_delete_conversation_content": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to permanently delete this conversation?",
    ),
    "ai_docs_delete_conversation_title": MessageLookupByLibrary.simpleMessage(
      "Delete conversation?",
    ),
    "ai_docs_delete_conversation_tooltip": MessageLookupByLibrary.simpleMessage(
      "Delete conversation",
    ),
    "ai_docs_dispatched": MessageLookupByLibrary.simpleMessage("Dispatched"),
    "ai_docs_enter_message": MessageLookupByLibrary.simpleMessage(
      "Enter message...",
    ),
    "ai_docs_image_picking_error": m0,
    "ai_docs_let_them_see": MessageLookupByLibrary.simpleMessage(
      "Let them see",
    ),
    "ai_docs_load_conversations_failed": MessageLookupByLibrary.simpleMessage(
      "Failed to load conversations",
    ),
    "ai_docs_loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "ai_docs_match_button": MessageLookupByLibrary.simpleMessage("Match"),
    "ai_docs_mic_permission_denied": MessageLookupByLibrary.simpleMessage(
      "Microphone permission denied",
    ),
    "ai_docs_new_chat": MessageLookupByLibrary.simpleMessage("New Chat"),
    "ai_docs_no_conversations": MessageLookupByLibrary.simpleMessage(
      "No conversations yet",
    ),
    "ai_docs_no_messages": MessageLookupByLibrary.simpleMessage(
      "No messages yet. Start chatting!",
    ),
    "ai_docs_no_recommendations": MessageLookupByLibrary.simpleMessage(
      "No recommendations available",
    ),
    "ai_docs_please_enter_message": MessageLookupByLibrary.simpleMessage(
      "Please enter a message",
    ),
    "ai_docs_please_select_conversation_to_delete":
        MessageLookupByLibrary.simpleMessage(
          "Please select the conversation to delete first",
        ),
    "ai_docs_recommendations_error": m1,
    "ai_docs_recommended_services": MessageLookupByLibrary.simpleMessage(
      "Recommended Services",
    ),
    "ai_docs_recording": MessageLookupByLibrary.simpleMessage(
      "Recording... tap to stop",
    ),
    "ai_docs_recording_error": m2,
    "ai_docs_recording_file_not_found": MessageLookupByLibrary.simpleMessage(
      "Error: Recording file not found",
    ),
    "ai_docs_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "ai_docs_select_conversation_first": MessageLookupByLibrary.simpleMessage(
      "Please select a conversation first",
    ),
    "ai_docs_send_message": MessageLookupByLibrary.simpleMessage(
      "Send Message",
    ),
    "ai_docs_start_recording": MessageLookupByLibrary.simpleMessage(
      "Record Voice",
    ),
    "ai_docs_stop_generation": MessageLookupByLibrary.simpleMessage(
      "Stop Generation",
    ),
    "ai_docs_stop_recording": MessageLookupByLibrary.simpleMessage(
      "Stop Recording",
    ),
    "ai_docs_stop_recording_error": MessageLookupByLibrary.simpleMessage(
      "Error stopping recording",
    ),
    "ai_docs_stop_recording_error_with_reason": m3,
    "ai_docs_unnamed_conversation": MessageLookupByLibrary.simpleMessage(
      "Unnamed Conversation",
    ),
    "ai_docs_uploading_images": MessageLookupByLibrary.simpleMessage(
      "Images uploading, please wait...",
    ),
    "allocating_step1": MessageLookupByLibrary.simpleMessage("Allocating"),
    "allocating_step2": MessageLookupByLibrary.simpleMessage("Allocating."),
    "allocating_step3": MessageLookupByLibrary.simpleMessage("Allocating.."),
    "allocating_step4": MessageLookupByLibrary.simpleMessage("Allocating..."),
    "chat_admin_connection_error": MessageLookupByLibrary.simpleMessage(
      "Unable to connect to system admin",
    ),
    "chat_admin_title": MessageLookupByLibrary.simpleMessage("System Admin"),
    "chat_attach": MessageLookupByLibrary.simpleMessage("Send Image/File"),
    "chat_audio_message": MessageLookupByLibrary.simpleMessage("[Audio]"),
    "chat_audio_pause": MessageLookupByLibrary.simpleMessage("Pause"),
    "chat_audio_play": MessageLookupByLibrary.simpleMessage("Play"),
    "chat_buyer": MessageLookupByLibrary.simpleMessage("Buyer"),
    "chat_camera_permission_denied": MessageLookupByLibrary.simpleMessage(
      "Camera permission denied, cannot take photo",
    ),
    "chat_camera_permission_denied_message": MessageLookupByLibrary.simpleMessage(
      "Please enable camera permission in system settings to use the photo feature.",
    ),
    "chat_camera_permission_denied_title": MessageLookupByLibrary.simpleMessage(
      "Camera Permission Denied",
    ),
    "chat_collapse": MessageLookupByLibrary.simpleMessage("Collapse"),
    "chat_copied_to_clipboard": MessageLookupByLibrary.simpleMessage(
      "Copied to clipboard",
    ),
    "chat_copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "chat_enter_message": MessageLookupByLibrary.simpleMessage(
      "Enter message...",
    ),
    "chat_error_loading": m4,
    "chat_expand": MessageLookupByLibrary.simpleMessage("Expand"),
    "chat_i_want_seller_to_see": MessageLookupByLibrary.simpleMessage(
      "I want the seller to see",
    ),
    "chat_image_message": MessageLookupByLibrary.simpleMessage("[Image]"),
    "chat_image_picking_error": m5,
    "chat_invalid_session": MessageLookupByLibrary.simpleMessage(
      "Invalid session",
    ),
    "chat_list_title": MessageLookupByLibrary.simpleMessage("Chat List"),
    "chat_loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "chat_markdown_example_bold_italic": MessageLookupByLibrary.simpleMessage(
      "This is **bold** text and *italic* text.",
    ),
    "chat_markdown_example_list1": MessageLookupByLibrary.simpleMessage(
      "This is list item 1",
    ),
    "chat_markdown_example_list2": MessageLookupByLibrary.simpleMessage(
      "This is list item 2",
    ),
    "chat_markdown_example_list3": MessageLookupByLibrary.simpleMessage(
      "This is a nested list item",
    ),
    "chat_markdown_example_quote": MessageLookupByLibrary.simpleMessage(
      "This is a quote text, supporting multiple lines",
    ),
    "chat_markdown_example_table_col1": MessageLookupByLibrary.simpleMessage(
      "Column 1",
    ),
    "chat_markdown_example_table_col2": MessageLookupByLibrary.simpleMessage(
      "Column 2",
    ),
    "chat_markdown_example_table_content1":
        MessageLookupByLibrary.simpleMessage("Content 1"),
    "chat_markdown_example_table_content2":
        MessageLookupByLibrary.simpleMessage("Content 2"),
    "chat_markdown_example_table_content3":
        MessageLookupByLibrary.simpleMessage("Content 3"),
    "chat_markdown_example_table_content4":
        MessageLookupByLibrary.simpleMessage("Content 4"),
    "chat_markdown_example_title1": MessageLookupByLibrary.simpleMessage(
      "This is a level 1 heading",
    ),
    "chat_markdown_example_title2": MessageLookupByLibrary.simpleMessage(
      "This is a level 2 heading",
    ),
    "chat_me": MessageLookupByLibrary.simpleMessage("Me"),
    "chat_message_recalled": MessageLookupByLibrary.simpleMessage(
      "Message recalled",
    ),
    "chat_mic_permission_denied": MessageLookupByLibrary.simpleMessage(
      "Microphone permission denied, cannot record",
    ),
    "chat_mic_permission_denied_message": MessageLookupByLibrary.simpleMessage(
      "Please enable microphone permission in system settings to use the recording feature.",
    ),
    "chat_mic_permission_denied_title": MessageLookupByLibrary.simpleMessage(
      "Microphone Permission Denied",
    ),
    "chat_no_messages": MessageLookupByLibrary.simpleMessage(
      "No messages yet. Start chatting!",
    ),
    "chat_notification_center": MessageLookupByLibrary.simpleMessage(
      "Notification Center",
    ),
    "chat_notification_description": MessageLookupByLibrary.simpleMessage(
      "System, orders, reviews and important notifications",
    ),
    "chat_opponent_not_found": MessageLookupByLibrary.simpleMessage(
      "Cannot find the other party\'s information",
    ),
    "chat_permission_denied_cancel": MessageLookupByLibrary.simpleMessage(
      "Cancel",
    ),
    "chat_permission_denied_settings": MessageLookupByLibrary.simpleMessage(
      "Settings",
    ),
    "chat_pick_from_gallery": MessageLookupByLibrary.simpleMessage(
      "Pick from Gallery",
    ),
    "chat_press_to_talk": MessageLookupByLibrary.simpleMessage("Press to Talk"),
    "chat_recall": MessageLookupByLibrary.simpleMessage("Recall"),
    "chat_recording_error": m6,
    "chat_release_to_send": m7,
    "chat_revoked_message": MessageLookupByLibrary.simpleMessage(
      "[Message withdrawn]",
    ),
    "chat_send": MessageLookupByLibrary.simpleMessage("Send"),
    "chat_send_markdown": MessageLookupByLibrary.simpleMessage(
      "Send Markdown Example",
    ),
    "chat_stop_recording_error": m8,
    "chat_switch_to_text": MessageLookupByLibrary.simpleMessage(
      "Switch to Text Input",
    ),
    "chat_switch_to_voice": MessageLookupByLibrary.simpleMessage(
      "Switch to Voice Input",
    ),
    "chat_take_photo": MessageLookupByLibrary.simpleMessage("Take Photo"),
    "chat_unknown_message": MessageLookupByLibrary.simpleMessage(
      "[Unknown message]",
    ),
    "chat_unknown_user": MessageLookupByLibrary.simpleMessage("Unknown User"),
    "chat_wants_to_see": MessageLookupByLibrary.simpleMessage("wants to see"),
    "chat_web_recording_not_supported": MessageLookupByLibrary.simpleMessage(
      "Recording is not supported on Web platform",
    ),
    "chat_yesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
    "home_banner_clicked": m9,
    "home_end_of_list": MessageLookupByLibrary.simpleMessage("End of list"),
    "home_loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "home_loading_failed": m10,
    "home_product_card_clicked": m11,
    "home_recommend_clicked": m12,
    "home_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "home_search_hint": MessageLookupByLibrary.simpleMessage("Search services"),
    "home_title": MessageLookupByLibrary.simpleMessage("Home"),
    "language_settings": MessageLookupByLibrary.simpleMessage(
      "Language Settings",
    ),
    "nav_ai_assistant": MessageLookupByLibrary.simpleMessage("DSKK"),
    "nav_dev": MessageLookupByLibrary.simpleMessage("Dev"),
    "nav_home": MessageLookupByLibrary.simpleMessage("Home"),
    "nav_messages": MessageLookupByLibrary.simpleMessage("Messages"),
    "nav_profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "nav_seller_analytics": MessageLookupByLibrary.simpleMessage("Analytics"),
    "nav_seller_messages": MessageLookupByLibrary.simpleMessage("Messages"),
    "nav_seller_products": MessageLookupByLibrary.simpleMessage("Products"),
    "nav_seller_profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "product_default_name": MessageLookupByLibrary.simpleMessage("Product"),
    "product_image_loading_failed": MessageLookupByLibrary.simpleMessage(
      "Image loading failed",
    ),
    "product_recommend_button": MessageLookupByLibrary.simpleMessage(
      "Let them see",
    ),
    "profile_about_us": MessageLookupByLibrary.simpleMessage("About Us"),
    "profile_account_security": MessageLookupByLibrary.simpleMessage(
      "Account & Security",
    ),
    "profile_assistant_mission": MessageLookupByLibrary.simpleMessage(
      "Assistant\'s Mission",
    ),
    "profile_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "profile_completed": MessageLookupByLibrary.simpleMessage("Completed"),
    "profile_default_name": MessageLookupByLibrary.simpleMessage("User"),
    "profile_edit_nickname": MessageLookupByLibrary.simpleMessage(
      "Edit Nickname",
    ),
    "profile_favorites": MessageLookupByLibrary.simpleMessage("Favorites"),
    "profile_in_progress": MessageLookupByLibrary.simpleMessage("Processing"),
    "profile_loading_error": m13,
    "profile_login_button": MessageLookupByLibrary.simpleMessage("Login"),
    "profile_login_prompt": MessageLookupByLibrary.simpleMessage(
      "Please login to view your profile",
    ),
    "profile_message_notifications": MessageLookupByLibrary.simpleMessage(
      "Message Notifications",
    ),
    "profile_my_dskk": MessageLookupByLibrary.simpleMessage("My DSKK"),
    "profile_my_wallet": MessageLookupByLibrary.simpleMessage("My Wallet"),
    "profile_navigation_error": m14,
    "profile_nickname_hint": MessageLookupByLibrary.simpleMessage(
      "Please enter new nickname",
    ),
    "profile_offline": MessageLookupByLibrary.simpleMessage("Offline"),
    "profile_online": MessageLookupByLibrary.simpleMessage("Online"),
    "profile_orders": MessageLookupByLibrary.simpleMessage("My Orders"),
    "profile_pending_payment": MessageLookupByLibrary.simpleMessage("Pending"),
    "profile_personal_center": MessageLookupByLibrary.simpleMessage(
      "Personal Center",
    ),
    "profile_refund": MessageLookupByLibrary.simpleMessage("Support"),
    "profile_save": MessageLookupByLibrary.simpleMessage("Save"),
    "profile_settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "profile_switch_error": m15,
    "profile_switch_to_seller": MessageLookupByLibrary.simpleMessage(
      "Switch to Seller Mode",
    ),
    "profile_wallet": MessageLookupByLibrary.simpleMessage("Wallet"),
    "search_button": MessageLookupByLibrary.simpleMessage("Search"),
    "search_failed": m16,
    "search_history": MessageLookupByLibrary.simpleMessage("Search History"),
    "search_hot_keywords": MessageLookupByLibrary.simpleMessage("Hot Keywords"),
    "search_no_results": MessageLookupByLibrary.simpleMessage(
      "No relevant services found",
    ),
    "search_title": MessageLookupByLibrary.simpleMessage("Search"),
    "system_language": MessageLookupByLibrary.simpleMessage("System Language"),
    "system_language_description": MessageLookupByLibrary.simpleMessage(
      "Automatically use device language settings",
    ),
  };
}
