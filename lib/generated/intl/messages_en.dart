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

  static String m4(error) => "Title generation failed: ${error}";

  static String m5(error) => "Title update failed: ${error}";

  static String m6(error) => "Loading failed: ${error}";

  static String m7(error) => "Error selecting image: ${error}";

  static String m8(error) => "Error starting recording: ${error}";

  static String m9(duration) => "Release to Send (${duration}s)";

  static String m10(error) => "Error stopping recording: ${error}";

  static String m11(targetType, targetValue) =>
      "Banner clicked: ${targetType} - ${targetValue}";

  static String m12(error) => "Loading failed: ${error}";

  static String m13(name) => "Service card clicked: ${name}";

  static String m14(name) => "Let them see button clicked: ${name}";

  static String m15(error) => "Loading failed: ${error}";

  static String m16(count) => "Reviews (${count})";

  static String m17(count) => "${count} days ago";

  static String m18(count) => "${count} hours ago";

  static String m19(error) => "Loading failed: ${error}";

  static String m20(count) => "${count} minutes ago";

  static String m21(count) => "${count} months ago";

  static String m22(count) => "${count} years ago";

  static String m23(error) => "Loading failed: ${error}";

  static String m24(error) => "Unable to navigate to order list: ${error}";

  static String m25(error) => "Unable to switch to seller mode: ${error}";

  static String m26(error) => "Search failed: ${error}";

  static String m27(rate) => "Completion Rate ${rate}%";

  static String m28(error) => "Unable to switch to buyer mode: ${error}";

  static String m29(error) => "Failed to create chat: ${error}";

  static String m30(error) => "Error occurred: ${error}";

  static String m31(feature) => "${feature} feature not yet implemented";

  static String m32(count) => "${count} followers";

  static String m33(days) => "Level 3 Seller for ${days} days";

  static String m34(orderNum) => "Complete ${orderNum} orders";

  static String m35(error) => "Loading failed: ${error}";

  static String m36(amount) => "Earn \$${amount}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "ai_docs_add_image": MessageLookupByLibrary.simpleMessage("Add Image"),
    "ai_docs_assistant_title": MessageLookupByLibrary.simpleMessage(
      "AI Assistant",
    ),
    "ai_docs_auto_create_text": MessageLookupByLibrary.simpleMessage(
      "No conversation selected, automatically creating a new conversation and sending message",
    ),
    "ai_docs_auto_create_voice": MessageLookupByLibrary.simpleMessage(
      "No conversation selected, automatically creating a new conversation and sending voice message",
    ),
    "ai_docs_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "ai_docs_cancelling_generation": MessageLookupByLibrary.simpleMessage(
      "Cancelling generation...",
    ),
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
    "ai_docs_edit_title": MessageLookupByLibrary.simpleMessage("Edit Title"),
    "ai_docs_edit_title_hint": MessageLookupByLibrary.simpleMessage(
      "Please enter a new title",
    ),
    "ai_docs_enter_chat": MessageLookupByLibrary.simpleMessage("Enter Chat"),
    "ai_docs_enter_message": MessageLookupByLibrary.simpleMessage(
      "Enter message...",
    ),
    "ai_docs_generate_title": MessageLookupByLibrary.simpleMessage(
      "AI Generate Title",
    ),
    "ai_docs_generate_title_tooltip": MessageLookupByLibrary.simpleMessage(
      "Let AI generate a title for this conversation",
    ),
    "ai_docs_generating_title": MessageLookupByLibrary.simpleMessage(
      "Generating title...",
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
    "ai_docs_title_empty": MessageLookupByLibrary.simpleMessage(
      "Title cannot be empty",
    ),
    "ai_docs_title_generated": MessageLookupByLibrary.simpleMessage(
      "Title generated",
    ),
    "ai_docs_title_generation_failed": m4,
    "ai_docs_title_too_long": MessageLookupByLibrary.simpleMessage(
      "Title cannot exceed 50 characters",
    ),
    "ai_docs_title_update_failed": m5,
    "ai_docs_title_updated": MessageLookupByLibrary.simpleMessage(
      "Title updated",
    ),
    "ai_docs_unnamed_conversation": MessageLookupByLibrary.simpleMessage(
      "Unnamed Conversation",
    ),
    "ai_docs_uploading_images": MessageLookupByLibrary.simpleMessage(
      "Images uploading, please wait...",
    ),
    "ai_docs_welcome_message": MessageLookupByLibrary.simpleMessage(
      "Just send a message to start chatting, and the system will automatically create a chat room for you",
    ),
    "ai_docs_welcome_title": MessageLookupByLibrary.simpleMessage(
      "Welcome to AI Assistant",
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
    "chat_error_loading": m6,
    "chat_expand": MessageLookupByLibrary.simpleMessage("Expand"),
    "chat_i_want_seller_to_see": MessageLookupByLibrary.simpleMessage(
      "I want the seller to see",
    ),
    "chat_image_message": MessageLookupByLibrary.simpleMessage("[Image]"),
    "chat_image_picking_error": m7,
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
    "chat_recording_error": m8,
    "chat_release_to_send": m9,
    "chat_revoked_message": MessageLookupByLibrary.simpleMessage(
      "[Message withdrawn]",
    ),
    "chat_send": MessageLookupByLibrary.simpleMessage("Send"),
    "chat_send_markdown": MessageLookupByLibrary.simpleMessage(
      "Send Markdown Example",
    ),
    "chat_stop_recording_error": m10,
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
    "home_banner_clicked": m11,
    "home_end_of_list": MessageLookupByLibrary.simpleMessage("End of list"),
    "home_loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "home_loading_failed": m12,
    "home_product_card_clicked": m13,
    "home_recommend_clicked": m14,
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
    "product_detail_basic_package": MessageLookupByLibrary.simpleMessage(
      "Basic",
    ),
    "product_detail_buy_now": MessageLookupByLibrary.simpleMessage(
      "Buy Now (1)",
    ),
    "product_detail_case_showcase": MessageLookupByLibrary.simpleMessage(
      "Case Showcase",
    ),
    "product_detail_contact_seller": MessageLookupByLibrary.simpleMessage(
      "Contact Seller",
    ),
    "product_detail_delivery_period": MessageLookupByLibrary.simpleMessage(
      "Delivery Period",
    ),
    "product_detail_delivery_times": MessageLookupByLibrary.simpleMessage(
      "Delivery Times",
    ),
    "product_detail_faq": MessageLookupByLibrary.simpleMessage("FAQ"),
    "product_detail_loading_failed": m15,
    "product_detail_more": MessageLookupByLibrary.simpleMessage("More"),
    "product_detail_no_cases": MessageLookupByLibrary.simpleMessage(
      "No cases available",
    ),
    "product_detail_no_reviews": MessageLookupByLibrary.simpleMessage(
      "No reviews yet",
    ),
    "product_detail_please_wait": MessageLookupByLibrary.simpleMessage(
      "Please wait...",
    ),
    "product_detail_published_status": MessageLookupByLibrary.simpleMessage(
      "Published",
    ),
    "product_detail_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "product_detail_reviews": m16,
    "product_detail_sample_review": MessageLookupByLibrary.simpleMessage(
      "Great service, very patient",
    ),
    "product_detail_sample_user": MessageLookupByLibrary.simpleMessage(
      "Ray123",
    ),
    "product_detail_verified_label": MessageLookupByLibrary.simpleMessage(
      "Verified",
    ),
    "product_detail_view_all": MessageLookupByLibrary.simpleMessage("View All"),
    "product_image_loading_failed": MessageLookupByLibrary.simpleMessage(
      "Image loading failed",
    ),
    "product_recommend_button": MessageLookupByLibrary.simpleMessage(
      "Let them see",
    ),
    "product_reviews_days_ago": m17,
    "product_reviews_hours_ago": m18,
    "product_reviews_just_now": MessageLookupByLibrary.simpleMessage(
      "Just now",
    ),
    "product_reviews_loading_failed": m19,
    "product_reviews_minutes_ago": m20,
    "product_reviews_months_ago": m21,
    "product_reviews_no_reviews": MessageLookupByLibrary.simpleMessage(
      "No reviews yet",
    ),
    "product_reviews_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "product_reviews_sample_content": MessageLookupByLibrary.simpleMessage(
      "Great service, very patient",
    ),
    "product_reviews_title": MessageLookupByLibrary.simpleMessage("Reviews"),
    "product_reviews_years_ago": m22,
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
    "profile_loading_error": m23,
    "profile_login_button": MessageLookupByLibrary.simpleMessage("Login"),
    "profile_login_prompt": MessageLookupByLibrary.simpleMessage(
      "Please login to view your profile",
    ),
    "profile_message_notifications": MessageLookupByLibrary.simpleMessage(
      "Message Notifications",
    ),
    "profile_my_dskk": MessageLookupByLibrary.simpleMessage("My DSKK"),
    "profile_my_wallet": MessageLookupByLibrary.simpleMessage("My Wallet"),
    "profile_navigation_error": m24,
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
    "profile_switch_error": m25,
    "profile_switch_to_seller": MessageLookupByLibrary.simpleMessage(
      "Switch to Seller Mode",
    ),
    "profile_wallet": MessageLookupByLibrary.simpleMessage("Wallet"),
    "search_button": MessageLookupByLibrary.simpleMessage("Search"),
    "search_failed": m26,
    "search_history": MessageLookupByLibrary.simpleMessage("Search History"),
    "search_hot_keywords": MessageLookupByLibrary.simpleMessage("Hot Keywords"),
    "search_no_results": MessageLookupByLibrary.simpleMessage(
      "No relevant services found",
    ),
    "search_title": MessageLookupByLibrary.simpleMessage("Search"),
    "seller_home_auth_management": MessageLookupByLibrary.simpleMessage("Auth"),
    "seller_home_auto_reply": MessageLookupByLibrary.simpleMessage(
      "Auto Reply",
    ),
    "seller_home_completion_rate": m27,
    "seller_home_functions": MessageLookupByLibrary.simpleMessage("Tools"),
    "seller_home_income": MessageLookupByLibrary.simpleMessage("Revenue"),
    "seller_home_loading_failed": MessageLookupByLibrary.simpleMessage(
      "Loading failed",
    ),
    "seller_home_no_data": MessageLookupByLibrary.simpleMessage("No data"),
    "seller_home_no_income_data": MessageLookupByLibrary.simpleMessage(
      "No revenue data",
    ),
    "seller_home_no_recent_income": MessageLookupByLibrary.simpleMessage(
      "No recent revenue data",
    ),
    "seller_home_no_store_info": MessageLookupByLibrary.simpleMessage(
      "No store information",
    ),
    "seller_home_offline": MessageLookupByLibrary.simpleMessage("Offline"),
    "seller_home_online": MessageLookupByLibrary.simpleMessage("Online"),
    "seller_home_orders": MessageLookupByLibrary.simpleMessage("Orders"),
    "seller_home_orders_aftersales": MessageLookupByLibrary.simpleMessage(
      "Support",
    ),
    "seller_home_orders_all": MessageLookupByLibrary.simpleMessage("All"),
    "seller_home_orders_pending": MessageLookupByLibrary.simpleMessage(
      "Pending",
    ),
    "seller_home_orders_processing": MessageLookupByLibrary.simpleMessage(
      "Active",
    ),
    "seller_home_pending_settlement": MessageLookupByLibrary.simpleMessage(
      "Pending",
    ),
    "seller_home_recent_income": MessageLookupByLibrary.simpleMessage(
      "Recent Revenue",
    ),
    "seller_home_switch_failed": m28,
    "seller_home_switch_to_buyer": MessageLookupByLibrary.simpleMessage(
      "Switch to Buyer Mode",
    ),
    "seller_home_time_management": MessageLookupByLibrary.simpleMessage(
      "Schedule",
    ),
    "seller_home_today_income": MessageLookupByLibrary.simpleMessage("Today"),
    "seller_home_total_income": MessageLookupByLibrary.simpleMessage("Total"),
    "seller_home_view_all": MessageLookupByLibrary.simpleMessage("View All"),
    "seller_home_view_details": MessageLookupByLibrary.simpleMessage("Details"),
    "seller_home_wallet": MessageLookupByLibrary.simpleMessage("Wallet"),
    "seller_profile_about_merchant": MessageLookupByLibrary.simpleMessage(
      "About Merchant",
    ),
    "seller_profile_about_us": MessageLookupByLibrary.simpleMessage("About"),
    "seller_profile_auth_management": MessageLookupByLibrary.simpleMessage(
      "Auth",
    ),
    "seller_profile_buyer_mode": MessageLookupByLibrary.simpleMessage(
      "Buyer Mode",
    ),
    "seller_profile_certification_status": MessageLookupByLibrary.simpleMessage(
      "Certification Status",
    ),
    "seller_profile_certified": MessageLookupByLibrary.simpleMessage(
      "Certified",
    ),
    "seller_profile_chat_failed": m29,
    "seller_profile_default_title": MessageLookupByLibrary.simpleMessage(
      "Seller Profile",
    ),
    "seller_profile_error_occurred": m30,
    "seller_profile_feature_not_implemented": m31,
    "seller_profile_follow": MessageLookupByLibrary.simpleMessage("Follow"),
    "seller_profile_follow_success": MessageLookupByLibrary.simpleMessage(
      "Followed successfully",
    ),
    "seller_profile_followed": MessageLookupByLibrary.simpleMessage(
      "Following",
    ),
    "seller_profile_followers": m32,
    "seller_profile_image_load_failed": MessageLookupByLibrary.simpleMessage(
      "Image loading failed",
    ),
    "seller_profile_level_two": MessageLookupByLibrary.simpleMessage(
      "Level 2 Member",
    ),
    "seller_profile_member_level": MessageLookupByLibrary.simpleMessage(
      "Member Level",
    ),
    "seller_profile_mission": MessageLookupByLibrary.simpleMessage("Mission"),
    "seller_profile_my_orders": MessageLookupByLibrary.simpleMessage(
      "My Orders",
    ),
    "seller_profile_my_services": MessageLookupByLibrary.simpleMessage(
      "My Services",
    ),
    "seller_profile_my_wallet": MessageLookupByLibrary.simpleMessage("Wallet"),
    "seller_profile_no_description": MessageLookupByLibrary.simpleMessage(
      "No description",
    ),
    "seller_profile_no_image": MessageLookupByLibrary.simpleMessage("No image"),
    "seller_profile_no_merchant_info": MessageLookupByLibrary.simpleMessage(
      "No merchant information",
    ),
    "seller_profile_no_products": MessageLookupByLibrary.simpleMessage(
      "No products",
    ),
    "seller_profile_not_certified": MessageLookupByLibrary.simpleMessage(
      "Not Certified",
    ),
    "seller_profile_notifications": MessageLookupByLibrary.simpleMessage(
      "Notifications",
    ),
    "seller_profile_order_delivered": MessageLookupByLibrary.simpleMessage(
      "Delivered",
    ),
    "seller_profile_order_pending": MessageLookupByLibrary.simpleMessage(
      "Pending",
    ),
    "seller_profile_order_processing": MessageLookupByLibrary.simpleMessage(
      "Processing",
    ),
    "seller_profile_order_refund": MessageLookupByLibrary.simpleMessage(
      "Refund/Support",
    ),
    "seller_profile_response_hours": MessageLookupByLibrary.simpleMessage(
      "3 hours",
    ),
    "seller_profile_response_time": MessageLookupByLibrary.simpleMessage(
      "Response Time",
    ),
    "seller_profile_seller": MessageLookupByLibrary.simpleMessage("Seller"),
    "seller_profile_seller_mode": MessageLookupByLibrary.simpleMessage(
      "Seller Mode",
    ),
    "seller_profile_seller_mode_online": MessageLookupByLibrary.simpleMessage(
      "Seller Mode: Online",
    ),
    "seller_profile_seller_rating": MessageLookupByLibrary.simpleMessage(
      "Seller Rating",
    ),
    "seller_profile_settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "seller_profile_time_management": MessageLookupByLibrary.simpleMessage(
      "Schedule",
    ),
    "seller_profile_title": MessageLookupByLibrary.simpleMessage("Profile"),
    "seller_profile_unfollow_success": MessageLookupByLibrary.simpleMessage(
      "Unfollowed successfully",
    ),
    "seller_profile_user_name": MessageLookupByLibrary.simpleMessage("Ray"),
    "seller_statistics_active_orders": MessageLookupByLibrary.simpleMessage(
      "Active Orders",
    ),
    "seller_statistics_become_level3_seller": m33,
    "seller_statistics_complete_orders": m34,
    "seller_statistics_completion_rate": MessageLookupByLibrary.simpleMessage(
      "Completion",
    ),
    "seller_statistics_earliest": MessageLookupByLibrary.simpleMessage(
      "Earliest",
    ),
    "seller_statistics_heat_value": MessageLookupByLibrary.simpleMessage(
      "Heat",
    ),
    "seller_statistics_incomplete_orders": MessageLookupByLibrary.simpleMessage(
      "Incomplete Orders",
    ),
    "seller_statistics_indicators": MessageLookupByLibrary.simpleMessage(
      "Metrics",
    ),
    "seller_statistics_loading_failed": m35,
    "seller_statistics_monthly_earnings": MessageLookupByLibrary.simpleMessage(
      "Monthly Revenue",
    ),
    "seller_statistics_next_delivery_date":
        MessageLookupByLibrary.simpleMessage("Next Delivery"),
    "seller_statistics_pending": MessageLookupByLibrary.simpleMessage(
      "Pending",
    ),
    "seller_statistics_pending_completion":
        MessageLookupByLibrary.simpleMessage("Pending"),
    "seller_statistics_positive_rate": MessageLookupByLibrary.simpleMessage(
      "Rating",
    ),
    "seller_statistics_profit_amount": m36,
    "seller_statistics_receipt": MessageLookupByLibrary.simpleMessage(
      "Receipt",
    ),
    "seller_statistics_reply_rate": MessageLookupByLibrary.simpleMessage(
      "Reply Rate",
    ),
    "seller_statistics_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "seller_statistics_seller_homepage": MessageLookupByLibrary.simpleMessage(
      "Seller Profile",
    ),
    "seller_statistics_title": MessageLookupByLibrary.simpleMessage(
      "Analytics",
    ),
    "seller_statistics_total_earnings": MessageLookupByLibrary.simpleMessage(
      "Total Revenue",
    ),
    "seller_statistics_total_orders": MessageLookupByLibrary.simpleMessage(
      "Total Orders",
    ),
    "seller_statistics_upgrade_to_next_level":
        MessageLookupByLibrary.simpleMessage("Upgrade to Next Level"),
    "system_language": MessageLookupByLibrary.simpleMessage("System Language"),
    "system_language_description": MessageLookupByLibrary.simpleMessage(
      "Automatically use device language settings",
    ),
  };
}
