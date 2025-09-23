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

  static String m15(error) => "Failed to load notification center: ${error}";

  static String m16(days) => "${days} days ago";

  static String m17(hours) => "${hours} hours ago";

  static String m18(minutes) => "${minutes} minutes ago";

  static String m19(months) => "${months} months ago";

  static String m20(orderSn) => "Order Delivery: ${orderSn}";

  static String m21(price) => "Buy Now ¥${price}";

  static String m22(error) => "Loading failed: ${error}";

  static String m23(count) => "Reviews (${count})";

  static String m24(max) => "Max ${max} characters";

  static String m25(uploaded, total) => "Uploading ${uploaded}/${total}";

  static String m26(name) =>
      "Are you sure you want to take the product \"${name}\" off shelf?";

  static String m27(count) => "${count} days ago";

  static String m28(count) => "${count} hours ago";

  static String m29(error) => "Loading failed: ${error}";

  static String m30(count) => "${count} minutes ago";

  static String m31(count) => "${count} months ago";

  static String m32(count) => "${count} reviews";

  static String m33(count) => "${count} years ago";

  static String m34(error) => "Loading failed: ${error}";

  static String m35(error) => "Unable to navigate to order list: ${error}";

  static String m36(error) => "Unable to switch to seller mode: ${error}";

  static String m37(error) => "Search failed: ${error}";

  static String m38(type) => "${type} Certification Description";

  static String m39(error) => "File selection failed: ${error}";

  static String m40(count) => "${count} file(s) selected";

  static String m41(type) => "${type} Certification";

  static String m42(rate) => "Completion Rate ${rate}%";

  static String m43(error) => "Unable to switch to buyer mode: ${error}";

  static String m44(error) => "Failed to create chat: ${error}";

  static String m45(error) => "Error occurred: ${error}";

  static String m46(feature) => "${feature} feature not yet implemented";

  static String m47(count) => "${count} followers";

  static String m48(days) => "Level 3 Seller for ${days} days";

  static String m49(orderNum) => "Complete ${orderNum} orders";

  static String m50(error) => "Loading failed: ${error}";

  static String m51(amount) => "Earn \$${amount}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "after_sales_agree": MessageLookupByLibrary.simpleMessage("Approve"),
        "after_sales_agree_application":
            MessageLookupByLibrary.simpleMessage("Approve Request"),
        "after_sales_apply_reason":
            MessageLookupByLibrary.simpleMessage("Request Reason"),
        "after_sales_apply_time":
            MessageLookupByLibrary.simpleMessage("Request Time"),
        "after_sales_apply_type":
            MessageLookupByLibrary.simpleMessage("Request Type"),
        "after_sales_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "after_sales_confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "after_sales_confirm_message": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to approve this after-sales request?"),
        "after_sales_confirm_title":
            MessageLookupByLibrary.simpleMessage("Confirm"),
        "after_sales_detail_title":
            MessageLookupByLibrary.simpleMessage("After-sales Details"),
        "after_sales_image_evidence":
            MessageLookupByLibrary.simpleMessage("Image Evidence"),
        "after_sales_image_load_failed":
            MessageLookupByLibrary.simpleMessage("Image load failed"),
        "after_sales_image_view":
            MessageLookupByLibrary.simpleMessage("Image View"),
        "after_sales_load_failed": MessageLookupByLibrary.simpleMessage(
            "Load failed, please try again"),
        "after_sales_no_pending": MessageLookupByLibrary.simpleMessage(
            "No pending after-sales requests"),
        "after_sales_not_found": MessageLookupByLibrary.simpleMessage(
            "After-sales request not found"),
        "after_sales_order_number":
            MessageLookupByLibrary.simpleMessage("Order Number"),
        "after_sales_refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
        "after_sales_refund_amount":
            MessageLookupByLibrary.simpleMessage("Refund Amount"),
        "after_sales_refund_type":
            MessageLookupByLibrary.simpleMessage("Refund Type"),
        "after_sales_reject": MessageLookupByLibrary.simpleMessage("Reject"),
        "after_sales_reject_application":
            MessageLookupByLibrary.simpleMessage("Reject Request"),
        "after_sales_reject_reason":
            MessageLookupByLibrary.simpleMessage("Rejection Reason"),
        "after_sales_reject_reason_hint": MessageLookupByLibrary.simpleMessage(
            "Please enter rejection reason"),
        "after_sales_reject_reason_required":
            MessageLookupByLibrary.simpleMessage(
                "Please enter rejection reason"),
        "after_sales_review_title":
            MessageLookupByLibrary.simpleMessage("After-sales Review"),
        "after_sales_status_audit_pass":
            MessageLookupByLibrary.simpleMessage("Approved"),
        "after_sales_status_buyer_shipped":
            MessageLookupByLibrary.simpleMessage("Buyer Shipped"),
        "after_sales_status_canceled":
            MessageLookupByLibrary.simpleMessage("Canceled"),
        "after_sales_status_finished":
            MessageLookupByLibrary.simpleMessage("Completed"),
        "after_sales_status_refused":
            MessageLookupByLibrary.simpleMessage("Rejected"),
        "after_sales_status_seller_received":
            MessageLookupByLibrary.simpleMessage("Seller Received"),
        "after_sales_status_unknown":
            MessageLookupByLibrary.simpleMessage("Unknown Status"),
        "after_sales_status_wait_audit":
            MessageLookupByLibrary.simpleMessage("Pending Review"),
        "after_sales_type_refund_only":
            MessageLookupByLibrary.simpleMessage("Refund Only"),
        "after_sales_type_refund_return":
            MessageLookupByLibrary.simpleMessage("Return & Refund"),
        "after_sales_type_unknown":
            MessageLookupByLibrary.simpleMessage("Unknown Type"),
        "ai_docs_add_image": MessageLookupByLibrary.simpleMessage("Add Image"),
        "ai_docs_assistant_title":
            MessageLookupByLibrary.simpleMessage("AI Assistant"),
        "ai_docs_auto_create_text": MessageLookupByLibrary.simpleMessage(
            "No conversation selected, automatically creating a new conversation and sending message"),
        "ai_docs_auto_create_voice": MessageLookupByLibrary.simpleMessage(
            "No conversation selected, automatically creating a new conversation and sending voice message"),
        "ai_docs_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "ai_docs_cancelling_generation":
            MessageLookupByLibrary.simpleMessage("Cancelling generation..."),
        "ai_docs_conversation_list":
            MessageLookupByLibrary.simpleMessage("Conversation List"),
        "ai_docs_delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "ai_docs_delete_conversation_content":
            MessageLookupByLibrary.simpleMessage(
                "Are you sure you want to permanently delete this conversation?"),
        "ai_docs_delete_conversation_title":
            MessageLookupByLibrary.simpleMessage("Delete conversation?"),
        "ai_docs_delete_conversation_tooltip":
            MessageLookupByLibrary.simpleMessage("Delete conversation"),
        "ai_docs_dispatched":
            MessageLookupByLibrary.simpleMessage("Dispatched"),
        "ai_docs_edit_title":
            MessageLookupByLibrary.simpleMessage("Edit Title"),
        "ai_docs_edit_title_hint":
            MessageLookupByLibrary.simpleMessage("Please enter a new title"),
        "ai_docs_enter_chat":
            MessageLookupByLibrary.simpleMessage("Enter Chat"),
        "ai_docs_enter_message":
            MessageLookupByLibrary.simpleMessage("Enter message..."),
        "ai_docs_generate_title":
            MessageLookupByLibrary.simpleMessage("AI Generate Title"),
        "ai_docs_generate_title_tooltip": MessageLookupByLibrary.simpleMessage(
            "Let AI generate a title for this conversation"),
        "ai_docs_generating_title":
            MessageLookupByLibrary.simpleMessage("Generating title..."),
        "ai_docs_image_picking_error": m0,
        "ai_docs_let_them_see":
            MessageLookupByLibrary.simpleMessage("Let them see"),
        "ai_docs_load_conversations_failed":
            MessageLookupByLibrary.simpleMessage(
                "Failed to load conversations"),
        "ai_docs_loading": MessageLookupByLibrary.simpleMessage("Loading..."),
        "ai_docs_match_button": MessageLookupByLibrary.simpleMessage("Match"),
        "ai_docs_mic_permission_denied": MessageLookupByLibrary.simpleMessage(
            "Microphone permission denied"),
        "ai_docs_new_chat": MessageLookupByLibrary.simpleMessage("New Chat"),
        "ai_docs_no_conversations":
            MessageLookupByLibrary.simpleMessage("No conversations yet"),
        "ai_docs_no_messages": MessageLookupByLibrary.simpleMessage(
            "No messages yet. Start chatting!"),
        "ai_docs_no_recommendations": MessageLookupByLibrary.simpleMessage(
            "No recommendations available"),
        "ai_docs_please_enter_message":
            MessageLookupByLibrary.simpleMessage("Please enter a message"),
        "ai_docs_please_select_conversation_to_delete":
            MessageLookupByLibrary.simpleMessage(
                "Please select the conversation to delete first"),
        "ai_docs_recommendations_error": m1,
        "ai_docs_recommended_services":
            MessageLookupByLibrary.simpleMessage("Recommended Services"),
        "ai_docs_recording":
            MessageLookupByLibrary.simpleMessage("Recording... tap to stop"),
        "ai_docs_recording_error": m2,
        "ai_docs_recording_file_not_found":
            MessageLookupByLibrary.simpleMessage(
                "Error: Recording file not found"),
        "ai_docs_retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "ai_docs_select_conversation_first":
            MessageLookupByLibrary.simpleMessage(
                "Please select a conversation first"),
        "ai_docs_send_message":
            MessageLookupByLibrary.simpleMessage("Send Message"),
        "ai_docs_start_recording":
            MessageLookupByLibrary.simpleMessage("Record Voice"),
        "ai_docs_stop_generation":
            MessageLookupByLibrary.simpleMessage("Stop Generation"),
        "ai_docs_stop_recording":
            MessageLookupByLibrary.simpleMessage("Stop Recording"),
        "ai_docs_stop_recording_error":
            MessageLookupByLibrary.simpleMessage("Error stopping recording"),
        "ai_docs_stop_recording_error_with_reason": m3,
        "ai_docs_title_empty":
            MessageLookupByLibrary.simpleMessage("Title cannot be empty"),
        "ai_docs_title_generated":
            MessageLookupByLibrary.simpleMessage("Title generated"),
        "ai_docs_title_generation_failed": m4,
        "ai_docs_title_too_long": MessageLookupByLibrary.simpleMessage(
            "Title cannot exceed 50 characters"),
        "ai_docs_title_update_failed": m5,
        "ai_docs_title_updated":
            MessageLookupByLibrary.simpleMessage("Title updated"),
        "ai_docs_unnamed_conversation":
            MessageLookupByLibrary.simpleMessage("Unnamed Conversation"),
        "ai_docs_uploading_images": MessageLookupByLibrary.simpleMessage(
            "Images uploading, please wait..."),
        "ai_docs_welcome_message": MessageLookupByLibrary.simpleMessage(
            "Just send a message to start chatting, and the system will automatically create a chat room for you"),
        "ai_docs_welcome_title":
            MessageLookupByLibrary.simpleMessage("Welcome to AI Assistant"),
        "allocating_step1": MessageLookupByLibrary.simpleMessage("Allocating"),
        "allocating_step2": MessageLookupByLibrary.simpleMessage("Allocating."),
        "allocating_step3":
            MessageLookupByLibrary.simpleMessage("Allocating.."),
        "allocating_step4":
            MessageLookupByLibrary.simpleMessage("Allocating..."),
        "attachments": MessageLookupByLibrary.simpleMessage("Attachments:"),
        "auth_phone_number":
            MessageLookupByLibrary.simpleMessage("Phone Number"),
        "auth_phone_validation_empty":
            MessageLookupByLibrary.simpleMessage("Please enter phone number"),
        "auth_phone_validation_invalid_cn":
            MessageLookupByLibrary.simpleMessage(
                "Please enter 11-digit phone number"),
        "auth_phone_validation_invalid_cn_start":
            MessageLookupByLibrary.simpleMessage(
                "Phone number must start with 1"),
        "auth_phone_validation_invalid_general":
            MessageLookupByLibrary.simpleMessage(
                "Please enter a valid phone number"),
        "auth_phone_validation_invalid_jp_kr":
            MessageLookupByLibrary.simpleMessage(
                "Please enter 10 or 11-digit phone number"),
        "auth_phone_validation_invalid_us":
            MessageLookupByLibrary.simpleMessage(
                "Please enter 10-digit phone number"),
        "auth_select_country_region":
            MessageLookupByLibrary.simpleMessage("Select Country/Region"),
        "auto_reply_content":
            MessageLookupByLibrary.simpleMessage("Reply Content"),
        "auto_reply_content_description": MessageLookupByLibrary.simpleMessage(
            "When customers send messages, the system will automatically reply with this content"),
        "auto_reply_content_hint": MessageLookupByLibrary.simpleMessage(
            "Please enter auto reply content"),
        "auto_reply_content_required": MessageLookupByLibrary.simpleMessage(
            "Reply content cannot be empty"),
        "auto_reply_enable": MessageLookupByLibrary.simpleMessage("Auto Reply"),
        "auto_reply_load_failed": MessageLookupByLibrary.simpleMessage(
            "Load failed, please try again"),
        "auto_reply_save_settings":
            MessageLookupByLibrary.simpleMessage("Save Settings"),
        "auto_reply_settings_saved":
            MessageLookupByLibrary.simpleMessage("Settings Saved"),
        "auto_reply_title":
            MessageLookupByLibrary.simpleMessage("Auto Reply Settings"),
        "buyerSubmittedMaterials":
            MessageLookupByLibrary.simpleMessage("Buyer Submitted Materials"),
        "cancelDownload":
            MessageLookupByLibrary.simpleMessage("Cancel download"),
        "chat_admin_connection_error": MessageLookupByLibrary.simpleMessage(
            "Unable to connect to system admin"),
        "chat_admin_title":
            MessageLookupByLibrary.simpleMessage("System Admin"),
        "chat_attach": MessageLookupByLibrary.simpleMessage("Send Image/File"),
        "chat_audio_message": MessageLookupByLibrary.simpleMessage("[Audio]"),
        "chat_audio_pause": MessageLookupByLibrary.simpleMessage("Pause"),
        "chat_audio_play": MessageLookupByLibrary.simpleMessage("Play"),
        "chat_buyer": MessageLookupByLibrary.simpleMessage("Buyer"),
        "chat_camera_permission_denied": MessageLookupByLibrary.simpleMessage(
            "Camera permission denied, cannot take photo"),
        "chat_camera_permission_denied_message":
            MessageLookupByLibrary.simpleMessage(
                "Please enable camera permission in system settings to use the photo feature."),
        "chat_camera_permission_denied_title":
            MessageLookupByLibrary.simpleMessage("Camera Permission Denied"),
        "chat_collapse": MessageLookupByLibrary.simpleMessage("Collapse"),
        "chat_copied_to_clipboard":
            MessageLookupByLibrary.simpleMessage("Copied to clipboard"),
        "chat_copy": MessageLookupByLibrary.simpleMessage("Copy"),
        "chat_enter_message":
            MessageLookupByLibrary.simpleMessage("Enter message..."),
        "chat_error_loading": m6,
        "chat_expand": MessageLookupByLibrary.simpleMessage("Expand"),
        "chat_filter_all": MessageLookupByLibrary.simpleMessage("All"),
        "chat_filter_buyer":
            MessageLookupByLibrary.simpleMessage("My Purchases"),
        "chat_filter_mode_all":
            MessageLookupByLibrary.simpleMessage("Showing all chats"),
        "chat_filter_mode_buyer": MessageLookupByLibrary.simpleMessage(
            "Showing my purchase chats only"),
        "chat_filter_mode_seller":
            MessageLookupByLibrary.simpleMessage("Showing my sales chats only"),
        "chat_filter_seller": MessageLookupByLibrary.simpleMessage("My Sales"),
        "chat_i_want_seller_to_see":
            MessageLookupByLibrary.simpleMessage("I want the seller to see"),
        "chat_image_message": MessageLookupByLibrary.simpleMessage("[Image]"),
        "chat_image_picking_error": m7,
        "chat_invalid_session":
            MessageLookupByLibrary.simpleMessage("Invalid session"),
        "chat_list_title": MessageLookupByLibrary.simpleMessage("Chat List"),
        "chat_loading": MessageLookupByLibrary.simpleMessage("Loading..."),
        "chat_markdown_example_bold_italic":
            MessageLookupByLibrary.simpleMessage(
                "This is **bold** text and *italic* text."),
        "chat_markdown_example_list1":
            MessageLookupByLibrary.simpleMessage("This is list item 1"),
        "chat_markdown_example_list2":
            MessageLookupByLibrary.simpleMessage("This is list item 2"),
        "chat_markdown_example_list3":
            MessageLookupByLibrary.simpleMessage("This is a nested list item"),
        "chat_markdown_example_quote": MessageLookupByLibrary.simpleMessage(
            "This is a quote text, supporting multiple lines"),
        "chat_markdown_example_table_col1":
            MessageLookupByLibrary.simpleMessage("Column 1"),
        "chat_markdown_example_table_col2":
            MessageLookupByLibrary.simpleMessage("Column 2"),
        "chat_markdown_example_table_content1":
            MessageLookupByLibrary.simpleMessage("Content 1"),
        "chat_markdown_example_table_content2":
            MessageLookupByLibrary.simpleMessage("Content 2"),
        "chat_markdown_example_table_content3":
            MessageLookupByLibrary.simpleMessage("Content 3"),
        "chat_markdown_example_table_content4":
            MessageLookupByLibrary.simpleMessage("Content 4"),
        "chat_markdown_example_title1":
            MessageLookupByLibrary.simpleMessage("This is a level 1 heading"),
        "chat_markdown_example_title2":
            MessageLookupByLibrary.simpleMessage("This is a level 2 heading"),
        "chat_me": MessageLookupByLibrary.simpleMessage("Me"),
        "chat_message_recalled":
            MessageLookupByLibrary.simpleMessage("Message recalled"),
        "chat_mic_permission_denied": MessageLookupByLibrary.simpleMessage(
            "Microphone permission denied, cannot record"),
        "chat_mic_permission_denied_message": MessageLookupByLibrary.simpleMessage(
            "Please enable microphone permission in system settings to use the recording feature."),
        "chat_mic_permission_denied_title":
            MessageLookupByLibrary.simpleMessage(
                "Microphone Permission Denied"),
        "chat_no_messages": MessageLookupByLibrary.simpleMessage(
            "No messages yet. Start chatting!"),
        "chat_notification_center":
            MessageLookupByLibrary.simpleMessage("Notification Center"),
        "chat_notification_description": MessageLookupByLibrary.simpleMessage(
            "System, orders, reviews and important notifications"),
        "chat_opponent_not_found": MessageLookupByLibrary.simpleMessage(
            "Cannot find the other party\'s information"),
        "chat_permission_denied_cancel":
            MessageLookupByLibrary.simpleMessage("Cancel"),
        "chat_permission_denied_settings":
            MessageLookupByLibrary.simpleMessage("Settings"),
        "chat_pick_from_gallery":
            MessageLookupByLibrary.simpleMessage("Pick from Gallery"),
        "chat_press_to_talk":
            MessageLookupByLibrary.simpleMessage("Press to Talk"),
        "chat_recall": MessageLookupByLibrary.simpleMessage("Recall"),
        "chat_recording_error": m8,
        "chat_release_to_send": m9,
        "chat_revoked_message":
            MessageLookupByLibrary.simpleMessage("[Message withdrawn]"),
        "chat_send": MessageLookupByLibrary.simpleMessage("Send"),
        "chat_send_markdown":
            MessageLookupByLibrary.simpleMessage("Send Markdown Example"),
        "chat_stop_recording_error": m10,
        "chat_switch_to_text":
            MessageLookupByLibrary.simpleMessage("Switch to Text Input"),
        "chat_switch_to_voice":
            MessageLookupByLibrary.simpleMessage("Switch to Voice Input"),
        "chat_take_photo": MessageLookupByLibrary.simpleMessage("Take Photo"),
        "chat_unknown_message":
            MessageLookupByLibrary.simpleMessage("[Unknown message]"),
        "chat_unknown_user":
            MessageLookupByLibrary.simpleMessage("Unknown User"),
        "chat_wants_to_see":
            MessageLookupByLibrary.simpleMessage("wants to see"),
        "chat_web_recording_not_supported":
            MessageLookupByLibrary.simpleMessage(
                "Recording is not supported on Web platform"),
        "chat_yesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
        "deliveryDescription":
            MessageLookupByLibrary.simpleMessage("Delivery Description"),
        "deliveryFiles":
            MessageLookupByLibrary.simpleMessage("Delivery Files:"),
        "downloadCompleted":
            MessageLookupByLibrary.simpleMessage("Download completed"),
        "downloadFailed":
            MessageLookupByLibrary.simpleMessage("Download failed"),
        "downloadFile": MessageLookupByLibrary.simpleMessage("Download file"),
        "downloaded": MessageLookupByLibrary.simpleMessage("Downloaded"),
        "home_banner_clicked": m11,
        "home_end_of_list": MessageLookupByLibrary.simpleMessage("End of list"),
        "home_loading": MessageLookupByLibrary.simpleMessage("Loading..."),
        "home_loading_failed": m12,
        "home_no_content":
            MessageLookupByLibrary.simpleMessage("No recommended content"),
        "home_product_card_clicked": m13,
        "home_pull_to_refresh": MessageLookupByLibrary.simpleMessage(
            "Pull to refresh for recommendations"),
        "home_recommend_clicked": m14,
        "home_retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "home_search_hint":
            MessageLookupByLibrary.simpleMessage("Search services"),
        "home_title": MessageLookupByLibrary.simpleMessage("Home"),
        "language_settings":
            MessageLookupByLibrary.simpleMessage("Language Settings"),
        "materialsInfo": MessageLookupByLibrary.simpleMessage("Materials Info"),
        "nav_ai_assistant": MessageLookupByLibrary.simpleMessage("DSKK"),
        "nav_dev": MessageLookupByLibrary.simpleMessage("Dev"),
        "nav_home": MessageLookupByLibrary.simpleMessage("Home"),
        "nav_messages": MessageLookupByLibrary.simpleMessage("Messages"),
        "nav_profile": MessageLookupByLibrary.simpleMessage("Profile"),
        "nav_seller_analytics":
            MessageLookupByLibrary.simpleMessage("Analytics"),
        "nav_seller_messages": MessageLookupByLibrary.simpleMessage("Messages"),
        "nav_seller_products": MessageLookupByLibrary.simpleMessage("Products"),
        "nav_seller_profile": MessageLookupByLibrary.simpleMessage("Profile"),
        "noBuyerMaterials": MessageLookupByLibrary.simpleMessage(
            "No buyer submitted materials"),
        "noSellerDelivery":
            MessageLookupByLibrary.simpleMessage("No delivery from seller yet"),
        "notification_center_title":
            MessageLookupByLibrary.simpleMessage("Notification Center"),
        "notification_click_to_view":
            MessageLookupByLibrary.simpleMessage("Click to view details"),
        "notification_default_title":
            MessageLookupByLibrary.simpleMessage("Notification"),
        "notification_detail_close":
            MessageLookupByLibrary.simpleMessage("Close"),
        "notification_detail_title":
            MessageLookupByLibrary.simpleMessage("Notification Details"),
        "notification_detail_view":
            MessageLookupByLibrary.simpleMessage("View Details"),
        "notification_empty_all":
            MessageLookupByLibrary.simpleMessage("No notifications"),
        "notification_empty_authentication":
            MessageLookupByLibrary.simpleMessage(
                "No authentication notifications"),
        "notification_empty_generic":
            MessageLookupByLibrary.simpleMessage("No notifications"),
        "notification_empty_message":
            MessageLookupByLibrary.simpleMessage("No message notifications"),
        "notification_empty_order":
            MessageLookupByLibrary.simpleMessage("No order notifications"),
        "notification_empty_other":
            MessageLookupByLibrary.simpleMessage("No other notifications"),
        "notification_empty_refund": MessageLookupByLibrary.simpleMessage(
            "No after-sales notifications"),
        "notification_empty_review":
            MessageLookupByLibrary.simpleMessage("No review notifications"),
        "notification_empty_system":
            MessageLookupByLibrary.simpleMessage("No system notifications"),
        "notification_load_failed": m15,
        "notification_mark_all_read":
            MessageLookupByLibrary.simpleMessage("Mark All as Read"),
        "notification_refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
        "notification_retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "notification_status_read":
            MessageLookupByLibrary.simpleMessage("Read"),
        "notification_status_unread":
            MessageLookupByLibrary.simpleMessage("Unread"),
        "notification_tab_all": MessageLookupByLibrary.simpleMessage("All"),
        "notification_tab_message":
            MessageLookupByLibrary.simpleMessage("Messages"),
        "notification_tab_order":
            MessageLookupByLibrary.simpleMessage("Orders"),
        "notification_tab_refund":
            MessageLookupByLibrary.simpleMessage("After-sales"),
        "notification_tab_system":
            MessageLookupByLibrary.simpleMessage("System"),
        "notification_time_days_ago": m16,
        "notification_time_hours_ago": m17,
        "notification_time_just_now":
            MessageLookupByLibrary.simpleMessage("Just now"),
        "notification_time_minutes_ago": m18,
        "notification_time_months_ago": m19,
        "notification_type_authentication":
            MessageLookupByLibrary.simpleMessage("Authentication Notification"),
        "notification_type_message":
            MessageLookupByLibrary.simpleMessage("Message Notification"),
        "notification_type_order":
            MessageLookupByLibrary.simpleMessage("Order Notification"),
        "notification_type_other":
            MessageLookupByLibrary.simpleMessage("Other Notification"),
        "notification_type_refund":
            MessageLookupByLibrary.simpleMessage("After-sales Notification"),
        "notification_type_review":
            MessageLookupByLibrary.simpleMessage("Review Notification"),
        "notification_type_system":
            MessageLookupByLibrary.simpleMessage("System Notification"),
        "openFile": MessageLookupByLibrary.simpleMessage("Open file"),
        "openFileFailed":
            MessageLookupByLibrary.simpleMessage("Failed to open file"),
        "order_delivery_attachments_label":
            MessageLookupByLibrary.simpleMessage("Attachment Files:"),
        "order_delivery_confirm_shipment":
            MessageLookupByLibrary.simpleMessage("Confirm Shipment"),
        "order_delivery_content_hint": MessageLookupByLibrary.simpleMessage(
            "Please describe your delivery content..."),
        "order_delivery_content_label": MessageLookupByLibrary.simpleMessage(
            "Delivery Content Description:"),
        "order_delivery_content_required": MessageLookupByLibrary.simpleMessage(
            "Please enter delivery content description"),
        "order_delivery_instruction_content": MessageLookupByLibrary.simpleMessage(
            "Please submit your delivery content for this order. You can provide detailed instructions and attach relevant files to ensure the buyer clearly understands the services or products you provide."),
        "order_delivery_instruction_title":
            MessageLookupByLibrary.simpleMessage("Delivery Instructions"),
        "order_delivery_load_failed": MessageLookupByLibrary.simpleMessage(
            "Load failed, please try again"),
        "order_delivery_logistics_company":
            MessageLookupByLibrary.simpleMessage("Logistics Company"),
        "order_delivery_no_pending_orders":
            MessageLookupByLibrary.simpleMessage("No pending orders"),
        "order_delivery_receiving_address":
            MessageLookupByLibrary.simpleMessage("Receiving Address"),
        "order_delivery_shipping_address":
            MessageLookupByLibrary.simpleMessage("Shipping Address"),
        "order_delivery_status_in_transit":
            MessageLookupByLibrary.simpleMessage("In Transit"),
        "order_delivery_status_pending":
            MessageLookupByLibrary.simpleMessage("Pending Shipment"),
        "order_delivery_status_received":
            MessageLookupByLibrary.simpleMessage("Received"),
        "order_delivery_status_shipped":
            MessageLookupByLibrary.simpleMessage("Shipped"),
        "order_delivery_submit_button":
            MessageLookupByLibrary.simpleMessage("Submit Delivery"),
        "order_delivery_submit_success": MessageLookupByLibrary.simpleMessage(
            "Delivery content submitted successfully"),
        "order_delivery_submitting": MessageLookupByLibrary.simpleMessage(
            "Submitting delivery content..."),
        "order_delivery_title":
            MessageLookupByLibrary.simpleMessage("Order Delivery"),
        "order_delivery_title_with_sn": m20,
        "order_delivery_tracking_number":
            MessageLookupByLibrary.simpleMessage("Tracking Number"),
        "order_delivery_view_details":
            MessageLookupByLibrary.simpleMessage("View Details"),
        "pageLoadFailed":
            MessageLookupByLibrary.simpleMessage("Failed to load page"),
        "pdfLoadFailed":
            MessageLookupByLibrary.simpleMessage("Failed to load PDF"),
        "product_default_name": MessageLookupByLibrary.simpleMessage("Product"),
        "product_detail_basic_package":
            MessageLookupByLibrary.simpleMessage("Basic"),
        "product_detail_basic_tier":
            MessageLookupByLibrary.simpleMessage("Basic"),
        "product_detail_buy_now":
            MessageLookupByLibrary.simpleMessage("Buy Now (1)"),
        "product_detail_buy_now_with_price": m21,
        "product_detail_case_showcase":
            MessageLookupByLibrary.simpleMessage("Case Showcase"),
        "product_detail_collapse":
            MessageLookupByLibrary.simpleMessage("Collapse"),
        "product_detail_contact_seller":
            MessageLookupByLibrary.simpleMessage("Contact Seller"),
        "product_detail_delivery_period":
            MessageLookupByLibrary.simpleMessage("Delivery Period"),
        "product_detail_delivery_times":
            MessageLookupByLibrary.simpleMessage("Delivery Times"),
        "product_detail_faq": MessageLookupByLibrary.simpleMessage("FAQ"),
        "product_detail_loading_failed": m22,
        "product_detail_more": MessageLookupByLibrary.simpleMessage("More"),
        "product_detail_no_cases":
            MessageLookupByLibrary.simpleMessage("No cases available"),
        "product_detail_no_reviews":
            MessageLookupByLibrary.simpleMessage("No reviews yet"),
        "product_detail_please_wait":
            MessageLookupByLibrary.simpleMessage("Please wait..."),
        "product_detail_premium_package":
            MessageLookupByLibrary.simpleMessage("Premium"),
        "product_detail_premium_tier":
            MessageLookupByLibrary.simpleMessage("Premium"),
        "product_detail_published_status":
            MessageLookupByLibrary.simpleMessage("Published"),
        "product_detail_retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "product_detail_reviews": m23,
        "product_detail_sample_review":
            MessageLookupByLibrary.simpleMessage("Great service, very patient"),
        "product_detail_sample_user":
            MessageLookupByLibrary.simpleMessage("Ray123"),
        "product_detail_standard_package":
            MessageLookupByLibrary.simpleMessage("Standard"),
        "product_detail_standard_tier":
            MessageLookupByLibrary.simpleMessage("Standard"),
        "product_detail_verified_label":
            MessageLookupByLibrary.simpleMessage("Verified"),
        "product_detail_view_all":
            MessageLookupByLibrary.simpleMessage("View All"),
        "product_edit_add_image":
            MessageLookupByLibrary.simpleMessage("Add Image"),
        "product_edit_add_success_case":
            MessageLookupByLibrary.simpleMessage("Add Success Case"),
        "product_edit_at_least_one_image": MessageLookupByLibrary.simpleMessage(
            "Please upload at least one product image"),
        "product_edit_attribute_name_hint":
            MessageLookupByLibrary.simpleMessage("Please enter attribute name"),
        "product_edit_basic_info":
            MessageLookupByLibrary.simpleMessage("Basic Information"),
        "product_edit_detail_intro":
            MessageLookupByLibrary.simpleMessage("Detail Introduction"),
        "product_edit_edit_attribute":
            MessageLookupByLibrary.simpleMessage("Edit Product Attributes"),
        "product_edit_edit_service":
            MessageLookupByLibrary.simpleMessage("Edit Service"),
        "product_edit_edit_success_case":
            MessageLookupByLibrary.simpleMessage("Edit Success Case"),
        "product_edit_max_characters": m24,
        "product_edit_placeholder_hint": MessageLookupByLibrary.simpleMessage(
            "e.g., Please select color, Please enter model"),
        "product_edit_placeholder_label":
            MessageLookupByLibrary.simpleMessage("Placeholder Text"),
        "product_edit_please_enter_attribute_name":
            MessageLookupByLibrary.simpleMessage("Please enter attribute name"),
        "product_edit_please_enter_label": MessageLookupByLibrary.simpleMessage(
            "Please enter information label"),
        "product_edit_preview_product":
            MessageLookupByLibrary.simpleMessage("Preview Product"),
        "product_edit_product_description":
            MessageLookupByLibrary.simpleMessage("Product Description"),
        "product_edit_product_description_hint":
            MessageLookupByLibrary.simpleMessage(
                "Please enter product description"),
        "product_edit_product_images":
            MessageLookupByLibrary.simpleMessage("Product Images"),
        "product_edit_product_name":
            MessageLookupByLibrary.simpleMessage("Product Name"),
        "product_edit_product_name_hint":
            MessageLookupByLibrary.simpleMessage("Please enter product name"),
        "product_edit_product_preview_title":
            MessageLookupByLibrary.simpleMessage("Product Preview"),
        "product_edit_product_price":
            MessageLookupByLibrary.simpleMessage("Product Price"),
        "product_edit_publish_product":
            MessageLookupByLibrary.simpleMessage("Publish Product"),
        "product_edit_publish_service":
            MessageLookupByLibrary.simpleMessage("Publish Service"),
        "product_edit_save_draft":
            MessageLookupByLibrary.simpleMessage("Save Draft"),
        "product_edit_save_draft_dialog_confirm":
            MessageLookupByLibrary.simpleMessage("Save"),
        "product_edit_save_draft_dialog_message":
            MessageLookupByLibrary.simpleMessage(
                "Do you want to save as draft?"),
        "product_edit_save_draft_dialog_title":
            MessageLookupByLibrary.simpleMessage("Save Draft"),
        "product_edit_service_tiers":
            MessageLookupByLibrary.simpleMessage("Service Tier Settings"),
        "product_edit_success_cases":
            MessageLookupByLibrary.simpleMessage("Success Cases"),
        "product_edit_title_create":
            MessageLookupByLibrary.simpleMessage("Create Product"),
        "product_edit_title_edit":
            MessageLookupByLibrary.simpleMessage("Edit Product"),
        "product_edit_uploading":
            MessageLookupByLibrary.simpleMessage("Uploading..."),
        "product_edit_uploading_progress": m25,
        "product_edit_validation_description_required":
            MessageLookupByLibrary.simpleMessage(
                "Please enter product description"),
        "product_edit_validation_image_required":
            MessageLookupByLibrary.simpleMessage(
                "Please upload at least one product image"),
        "product_edit_validation_name_required":
            MessageLookupByLibrary.simpleMessage("Please enter product name"),
        "product_image_loading_failed":
            MessageLookupByLibrary.simpleMessage("Image loading failed"),
        "product_management_action_delete":
            MessageLookupByLibrary.simpleMessage("Delete"),
        "product_management_action_edit":
            MessageLookupByLibrary.simpleMessage("Edit"),
        "product_management_action_off_shelf":
            MessageLookupByLibrary.simpleMessage("Off Shelf"),
        "product_management_action_on_shelf":
            MessageLookupByLibrary.simpleMessage("On Shelf"),
        "product_management_action_publish":
            MessageLookupByLibrary.simpleMessage("Publish"),
        "product_management_action_resubmit":
            MessageLookupByLibrary.simpleMessage("Resubmit"),
        "product_management_cancel":
            MessageLookupByLibrary.simpleMessage("Cancel"),
        "product_management_confirm":
            MessageLookupByLibrary.simpleMessage("Confirm Off Shelf"),
        "product_management_confirm_delete_message":
            MessageLookupByLibrary.simpleMessage(
                "Are you sure you want to delete this product? This action cannot be undone."),
        "product_management_confirm_delete_title":
            MessageLookupByLibrary.simpleMessage("Confirm Delete"),
        "product_management_confirm_off_shelf_desc":
            MessageLookupByLibrary.simpleMessage("After off shelf:"),
        "product_management_confirm_off_shelf_message": m26,
        "product_management_confirm_off_shelf_point1":
            MessageLookupByLibrary.simpleMessage(
                "• Buyers will not be able to see or purchase this product"),
        "product_management_confirm_off_shelf_point2":
            MessageLookupByLibrary.simpleMessage(
                "• You can put it back on shelf at any time"),
        "product_management_confirm_off_shelf_point3":
            MessageLookupByLibrary.simpleMessage(
                "• Product data will be retained"),
        "product_management_confirm_off_shelf_title":
            MessageLookupByLibrary.simpleMessage("Confirm Off Shelf"),
        "product_management_create_product":
            MessageLookupByLibrary.simpleMessage("Create Product"),
        "product_management_delete":
            MessageLookupByLibrary.simpleMessage("Delete"),
        "product_management_draft_preview_hint":
            MessageLookupByLibrary.simpleMessage(
                "Draft products need to be published before preview"),
        "product_management_empty_default":
            MessageLookupByLibrary.simpleMessage("No product data"),
        "product_management_empty_draft":
            MessageLookupByLibrary.simpleMessage("No draft products"),
        "product_management_empty_off_shelf":
            MessageLookupByLibrary.simpleMessage("No off-shelf products"),
        "product_management_empty_on_sale":
            MessageLookupByLibrary.simpleMessage("No products on sale"),
        "product_management_no_more_products":
            MessageLookupByLibrary.simpleMessage("No more products"),
        "product_management_sales_label":
            MessageLookupByLibrary.simpleMessage("Sales"),
        "product_management_status_draft":
            MessageLookupByLibrary.simpleMessage("Draft"),
        "product_management_status_off_shelf":
            MessageLookupByLibrary.simpleMessage("Off Shelf"),
        "product_management_status_on_shelf":
            MessageLookupByLibrary.simpleMessage("On Shelf"),
        "product_management_status_rejected":
            MessageLookupByLibrary.simpleMessage("Review Failed"),
        "product_management_status_reviewing":
            MessageLookupByLibrary.simpleMessage("Under Review"),
        "product_management_status_unknown":
            MessageLookupByLibrary.simpleMessage("Unknown"),
        "product_management_status_waiting_review":
            MessageLookupByLibrary.simpleMessage("Waiting for Review"),
        "product_management_stock_label":
            MessageLookupByLibrary.simpleMessage("Stock"),
        "product_management_tab_draft":
            MessageLookupByLibrary.simpleMessage("Drafts"),
        "product_management_tab_off_shelf":
            MessageLookupByLibrary.simpleMessage("Off Shelf"),
        "product_management_tab_on_sale":
            MessageLookupByLibrary.simpleMessage("On Sale"),
        "product_management_title":
            MessageLookupByLibrary.simpleMessage("Product Management"),
        "product_preview_current_seller":
            MessageLookupByLibrary.simpleMessage("Current Seller"),
        "product_preview_seller_user":
            MessageLookupByLibrary.simpleMessage("Seller User"),
        "product_recommend_button":
            MessageLookupByLibrary.simpleMessage("Let them see"),
        "product_reviews_days_ago": m27,
        "product_reviews_filter_all":
            MessageLookupByLibrary.simpleMessage("All"),
        "product_reviews_filter_bad":
            MessageLookupByLibrary.simpleMessage("Bad"),
        "product_reviews_filter_good":
            MessageLookupByLibrary.simpleMessage("Good"),
        "product_reviews_filter_medium":
            MessageLookupByLibrary.simpleMessage("Medium"),
        "product_reviews_filter_with_images":
            MessageLookupByLibrary.simpleMessage("With Images"),
        "product_reviews_hours_ago": m28,
        "product_reviews_just_now":
            MessageLookupByLibrary.simpleMessage("Just now"),
        "product_reviews_loading_failed": m29,
        "product_reviews_minutes_ago": m30,
        "product_reviews_months_ago": m31,
        "product_reviews_no_reviews":
            MessageLookupByLibrary.simpleMessage("No reviews yet"),
        "product_reviews_retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "product_reviews_sample_content":
            MessageLookupByLibrary.simpleMessage("Great service, very patient"),
        "product_reviews_seller_reply":
            MessageLookupByLibrary.simpleMessage("Seller Reply"),
        "product_reviews_title":
            MessageLookupByLibrary.simpleMessage("Reviews"),
        "product_reviews_total_count": m32,
        "product_reviews_years_ago": m33,
        "profile_about_us": MessageLookupByLibrary.simpleMessage("About Us"),
        "profile_account_security":
            MessageLookupByLibrary.simpleMessage("Account & Security"),
        "profile_assistant_mission":
            MessageLookupByLibrary.simpleMessage("Assistant\'s Mission"),
        "profile_avatar_upload_failed": MessageLookupByLibrary.simpleMessage(
            "Avatar upload failed, please try again"),
        "profile_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "profile_completed": MessageLookupByLibrary.simpleMessage("To Receive"),
        "profile_default_name": MessageLookupByLibrary.simpleMessage("User"),
        "profile_edit_nickname":
            MessageLookupByLibrary.simpleMessage("Edit Nickname"),
        "profile_favorites": MessageLookupByLibrary.simpleMessage("Favorites"),
        "profile_in_progress":
            MessageLookupByLibrary.simpleMessage("To Submit"),
        "profile_loading_error": m34,
        "profile_login_button": MessageLookupByLibrary.simpleMessage("Login"),
        "profile_login_prompt": MessageLookupByLibrary.simpleMessage(
            "Please login to view your profile"),
        "profile_message_notifications":
            MessageLookupByLibrary.simpleMessage("Message Notifications"),
        "profile_my_dskk": MessageLookupByLibrary.simpleMessage("My DSKK"),
        "profile_my_wallet": MessageLookupByLibrary.simpleMessage("My Wallet"),
        "profile_navigation_error": m35,
        "profile_nickname_hint":
            MessageLookupByLibrary.simpleMessage("Please enter new nickname"),
        "profile_offline": MessageLookupByLibrary.simpleMessage("Offline"),
        "profile_online": MessageLookupByLibrary.simpleMessage("Online"),
        "profile_orders": MessageLookupByLibrary.simpleMessage("My Orders"),
        "profile_pending_payment":
            MessageLookupByLibrary.simpleMessage("Pending"),
        "profile_personal_center":
            MessageLookupByLibrary.simpleMessage("Personal Center"),
        "profile_refund": MessageLookupByLibrary.simpleMessage("Support"),
        "profile_save": MessageLookupByLibrary.simpleMessage("Save"),
        "profile_settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "profile_switch_error": m36,
        "profile_switch_to_seller":
            MessageLookupByLibrary.simpleMessage("Switch to Seller Mode"),
        "profile_wallet": MessageLookupByLibrary.simpleMessage("Wallet"),
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "search_button": MessageLookupByLibrary.simpleMessage("Search"),
        "search_failed": m37,
        "search_history":
            MessageLookupByLibrary.simpleMessage("Search History"),
        "search_hot_keywords":
            MessageLookupByLibrary.simpleMessage("Hot Keywords"),
        "search_no_results":
            MessageLookupByLibrary.simpleMessage("No relevant services found"),
        "search_title": MessageLookupByLibrary.simpleMessage("Search"),
        "sellerDeliveryContent":
            MessageLookupByLibrary.simpleMessage("Seller Delivery Content"),
        "seller_auth_application_agreement_agree":
            MessageLookupByLibrary.simpleMessage("Agree"),
        "seller_auth_application_agreement_close":
            MessageLookupByLibrary.simpleMessage("Close"),
        "seller_auth_application_agreement_content":
            MessageLookupByLibrary.simpleMessage(
                "This agreement is a legal agreement between you and the DSKK platform regarding certification services. Please read the following terms carefully to ensure you fully understand all rights and obligations in this agreement.\n\n1. Service Content\nThe DSKK platform provides certification services aimed at verifying the authenticity of the identity, qualifications and other information you provide, and improving your credibility on the platform.\n\n2. User Obligations\n1. You shall provide true, accurate and complete certification information and materials.\n2. You shall ensure that the certification materials provided do not infringe on any third party\'s legitimate rights and interests.\n\n3. Platform Rights and Obligations\n1. The platform has the right to review the certification information and materials you provide.\n2. The platform will complete the review within a reasonable time and notify you of the review results."),
        "seller_auth_application_agreement_guarantee":
            MessageLookupByLibrary.simpleMessage(
                ", and guarantee that the information provided is true and valid"),
        "seller_auth_application_agreement_link":
            MessageLookupByLibrary.simpleMessage(
                "Certification Service Agreement"),
        "seller_auth_application_agreement_read":
            MessageLookupByLibrary.simpleMessage("I have read and agree to"),
        "seller_auth_application_agreement_title":
            MessageLookupByLibrary.simpleMessage(
                "Certification Service Agreement"),
        "seller_auth_application_auth_description":
            MessageLookupByLibrary.simpleMessage("Certification Description"),
        "seller_auth_application_auth_description_hint":
            MessageLookupByLibrary.simpleMessage(
                "Please describe the certification content"),
        "seller_auth_application_auth_identifier":
            MessageLookupByLibrary.simpleMessage("Certification Identifier"),
        "seller_auth_application_auth_identifier_hint":
            MessageLookupByLibrary.simpleMessage(
                "Please enter certification identifier or number"),
        "seller_auth_application_auth_name":
            MessageLookupByLibrary.simpleMessage("Certification Name"),
        "seller_auth_application_auth_name_hint":
            MessageLookupByLibrary.simpleMessage(
                "Please enter certification name"),
        "seller_auth_application_auth_name_required":
            MessageLookupByLibrary.simpleMessage(
                "Please enter certification name"),
        "seller_auth_application_basic_info":
            MessageLookupByLibrary.simpleMessage("Basic Information"),
        "seller_auth_application_cert_number":
            MessageLookupByLibrary.simpleMessage("Certificate Number"),
        "seller_auth_application_cert_number_hint":
            MessageLookupByLibrary.simpleMessage(
                "Please enter professional qualification certificate number"),
        "seller_auth_application_check_form":
            MessageLookupByLibrary.simpleMessage(
                "Please check if the form is filled correctly"),
        "seller_auth_application_company_intro":
            MessageLookupByLibrary.simpleMessage("Company Introduction"),
        "seller_auth_application_company_intro_hint":
            MessageLookupByLibrary.simpleMessage(
                "Please briefly describe the company\'s business and situation"),
        "seller_auth_application_company_name":
            MessageLookupByLibrary.simpleMessage("Company Name"),
        "seller_auth_application_company_name_hint":
            MessageLookupByLibrary.simpleMessage(
                "Please enter the full company name"),
        "seller_auth_application_company_name_required":
            MessageLookupByLibrary.simpleMessage("Please enter company name"),
        "seller_auth_application_company_upload_hint":
            MessageLookupByLibrary.simpleMessage(
                "Please upload business license, organization code certificate and other enterprise qualification certificates"),
        "seller_auth_application_credit_code":
            MessageLookupByLibrary.simpleMessage("Unified Social Credit Code"),
        "seller_auth_application_credit_code_hint":
            MessageLookupByLibrary.simpleMessage(
                "Please enter 18-digit unified social credit code"),
        "seller_auth_application_credit_code_invalid":
            MessageLookupByLibrary.simpleMessage(
                "Unified social credit code should be 18 digits"),
        "seller_auth_application_credit_code_required":
            MessageLookupByLibrary.simpleMessage(
                "Please enter unified social credit code"),
        "seller_auth_application_default_upload_hint":
            MessageLookupByLibrary.simpleMessage(
                "Please upload relevant supporting materials, ensuring images are clear and information is complete"),
        "seller_auth_application_degree":
            MessageLookupByLibrary.simpleMessage("Degree/Education"),
        "seller_auth_application_degree_hint":
            MessageLookupByLibrary.simpleMessage(
                "e.g., Bachelor\'s, Master\'s, etc."),
        "seller_auth_application_degree_required":
            MessageLookupByLibrary.simpleMessage(
                "Please enter degree/education"),
        "seller_auth_application_desc": m38,
        "seller_auth_application_education_upload_hint":
            MessageLookupByLibrary.simpleMessage(
                "Please upload educational certificates, degree certificates and other supporting materials with complete information"),
        "seller_auth_application_id_number":
            MessageLookupByLibrary.simpleMessage("ID Number"),
        "seller_auth_application_id_number_hint":
            MessageLookupByLibrary.simpleMessage(
                "Please enter 18-digit ID number"),
        "seller_auth_application_id_number_invalid":
            MessageLookupByLibrary.simpleMessage(
                "ID number should be 18 digits"),
        "seller_auth_application_id_number_required":
            MessageLookupByLibrary.simpleMessage("Please enter ID number"),
        "seller_auth_application_id_upload_hint":
            MessageLookupByLibrary.simpleMessage(
                "Please upload clear photos of both sides of your ID card, ensuring information is clearly visible without obstruction or alteration"),
        "seller_auth_application_load_failed":
            MessageLookupByLibrary.simpleMessage("Load Failed"),
        "seller_auth_application_major":
            MessageLookupByLibrary.simpleMessage("Major"),
        "seller_auth_application_major_hint":
            MessageLookupByLibrary.simpleMessage("Please enter major name"),
        "seller_auth_application_ok":
            MessageLookupByLibrary.simpleMessage("OK"),
        "seller_auth_application_profession":
            MessageLookupByLibrary.simpleMessage("Profession/Position"),
        "seller_auth_application_profession_hint":
            MessageLookupByLibrary.simpleMessage(
                "Please enter your profession or position"),
        "seller_auth_application_profession_required":
            MessageLookupByLibrary.simpleMessage(
                "Please enter profession/position"),
        "seller_auth_application_profession_upload_hint":
            MessageLookupByLibrary.simpleMessage(
                "Please upload professional qualification certificates, professional skill certificates and other supporting materials"),
        "seller_auth_application_real_name":
            MessageLookupByLibrary.simpleMessage("Name"),
        "seller_auth_application_real_name_hint":
            MessageLookupByLibrary.simpleMessage("Please enter your real name"),
        "seller_auth_application_real_name_required":
            MessageLookupByLibrary.simpleMessage("Please enter name"),
        "seller_auth_application_review_time": MessageLookupByLibrary.simpleMessage(
            "Certification review usually takes 1-3 business days, please be patient."),
        "seller_auth_application_school_name":
            MessageLookupByLibrary.simpleMessage("School Name"),
        "seller_auth_application_school_name_hint":
            MessageLookupByLibrary.simpleMessage(
                "Please enter the full school name"),
        "seller_auth_application_school_name_required":
            MessageLookupByLibrary.simpleMessage("Please enter school name"),
        "seller_auth_application_select_file_failed": m39,
        "seller_auth_application_selected_files": m40,
        "seller_auth_application_selected_images":
            MessageLookupByLibrary.simpleMessage("Selected Images:"),
        "seller_auth_application_submit": MessageLookupByLibrary.simpleMessage(
            "Submit Certification Application"),
        "seller_auth_application_submit_success":
            MessageLookupByLibrary.simpleMessage("Submission Successful"),
        "seller_auth_application_submit_success_desc":
            MessageLookupByLibrary.simpleMessage(
                "Your certification application has been submitted. We will complete the review within 1-3 business days. Please be patient."),
        "seller_auth_application_title": m41,
        "seller_auth_application_upload_file":
            MessageLookupByLibrary.simpleMessage("Upload File"),
        "seller_auth_application_upload_materials":
            MessageLookupByLibrary.simpleMessage("Upload Supporting Materials"),
        "seller_auth_application_work_experience":
            MessageLookupByLibrary.simpleMessage("Work Experience"),
        "seller_auth_application_work_experience_hint":
            MessageLookupByLibrary.simpleMessage(
                "Please briefly describe your work experience"),
        "seller_auth_management_back":
            MessageLookupByLibrary.simpleMessage("Back"),
        "seller_auth_management_certified":
            MessageLookupByLibrary.simpleMessage("Certified"),
        "seller_auth_management_certified_items":
            MessageLookupByLibrary.simpleMessage("Certified Items"),
        "seller_auth_management_check_connection":
            MessageLookupByLibrary.simpleMessage(
                "• Check network connection status"),
        "seller_auth_management_check_network":
            MessageLookupByLibrary.simpleMessage(
                "• Check if network connection is stable"),
        "seller_auth_management_check_wifi":
            MessageLookupByLibrary.simpleMessage(
                "• Check WiFi or mobile data connection"),
        "seller_auth_management_contact_support":
            MessageLookupByLibrary.simpleMessage(
                "• If the problem persists, please contact customer service"),
        "seller_auth_management_contact_tech":
            MessageLookupByLibrary.simpleMessage(
                "• If the problem persists, please contact technical support"),
        "seller_auth_management_loading_failed":
            MessageLookupByLibrary.simpleMessage("Loading Failed"),
        "seller_auth_management_network_error":
            MessageLookupByLibrary.simpleMessage("Network Connection Error"),
        "seller_auth_management_network_error_desc":
            MessageLookupByLibrary.simpleMessage(
                "Unable to connect to server, please check network settings"),
        "seller_auth_management_no_items":
            MessageLookupByLibrary.simpleMessage("No certification items"),
        "seller_auth_management_not_submitted":
            MessageLookupByLibrary.simpleMessage("Not Submitted"),
        "seller_auth_management_open_certification":
            MessageLookupByLibrary.simpleMessage("Open Certification"),
        "seller_auth_management_pending":
            MessageLookupByLibrary.simpleMessage("Under Review"),
        "seller_auth_management_rejected":
            MessageLookupByLibrary.simpleMessage("Not Approved"),
        "seller_auth_management_reload":
            MessageLookupByLibrary.simpleMessage("Reload"),
        "seller_auth_management_restart_app":
            MessageLookupByLibrary.simpleMessage(
                "• Close and reopen the application"),
        "seller_auth_management_server_timeout":
            MessageLookupByLibrary.simpleMessage("Server Response Timeout"),
        "seller_auth_management_server_timeout_desc":
            MessageLookupByLibrary.simpleMessage(
                "Server took too long to process the request, please try again later"),
        "seller_auth_management_switch_network":
            MessageLookupByLibrary.simpleMessage(
                "• Try switching network environment"),
        "seller_auth_management_title":
            MessageLookupByLibrary.simpleMessage("Authentication Management"),
        "seller_auth_management_troubleshooting":
            MessageLookupByLibrary.simpleMessage(
                "Troubleshooting Suggestions:"),
        "seller_auth_management_try_later":
            MessageLookupByLibrary.simpleMessage("• Try again later"),
        "seller_auth_management_unknown_error":
            MessageLookupByLibrary.simpleMessage(
                "An unknown error occurred, please retry"),
        "seller_auth_management_unknown_status":
            MessageLookupByLibrary.simpleMessage("Unknown Status"),
        "seller_auth_management_wait_retry":
            MessageLookupByLibrary.simpleMessage(
                "• Wait a few minutes and try again"),
        "seller_home_auth_management":
            MessageLookupByLibrary.simpleMessage("Auth"),
        "seller_home_auto_reply":
            MessageLookupByLibrary.simpleMessage("Auto Reply"),
        "seller_home_completion_rate": m42,
        "seller_home_functions":
            MessageLookupByLibrary.simpleMessage("Functions"),
        "seller_home_income": MessageLookupByLibrary.simpleMessage("Revenue"),
        "seller_home_loading_failed":
            MessageLookupByLibrary.simpleMessage("Loading failed"),
        "seller_home_no_data": MessageLookupByLibrary.simpleMessage("No data"),
        "seller_home_no_income_data":
            MessageLookupByLibrary.simpleMessage("No revenue data"),
        "seller_home_no_recent_income":
            MessageLookupByLibrary.simpleMessage("No recent revenue data"),
        "seller_home_no_store_info":
            MessageLookupByLibrary.simpleMessage("No store information"),
        "seller_home_offline": MessageLookupByLibrary.simpleMessage("Offline"),
        "seller_home_online": MessageLookupByLibrary.simpleMessage("Online"),
        "seller_home_orders": MessageLookupByLibrary.simpleMessage("Orders"),
        "seller_home_orders_aftersales":
            MessageLookupByLibrary.simpleMessage("After Sales"),
        "seller_home_orders_all": MessageLookupByLibrary.simpleMessage("All"),
        "seller_home_orders_awaiting_delivery":
            MessageLookupByLibrary.simpleMessage("Awaiting Delivery"),
        "seller_home_orders_canceled":
            MessageLookupByLibrary.simpleMessage("Canceled"),
        "seller_home_orders_completed":
            MessageLookupByLibrary.simpleMessage("Completed"),
        "seller_home_orders_pending":
            MessageLookupByLibrary.simpleMessage("Pending"),
        "seller_home_orders_processing":
            MessageLookupByLibrary.simpleMessage("Processing"),
        "seller_home_pending_settlement":
            MessageLookupByLibrary.simpleMessage("Pending"),
        "seller_home_recent_income":
            MessageLookupByLibrary.simpleMessage("Recent Revenue"),
        "seller_home_switch_failed": m43,
        "seller_home_switch_to_buyer":
            MessageLookupByLibrary.simpleMessage("Switch to Buyer Mode"),
        "seller_home_time_management":
            MessageLookupByLibrary.simpleMessage("Schedule"),
        "seller_home_today_income":
            MessageLookupByLibrary.simpleMessage("Today"),
        "seller_home_total_income":
            MessageLookupByLibrary.simpleMessage("Total"),
        "seller_home_view_all":
            MessageLookupByLibrary.simpleMessage("View All"),
        "seller_home_view_details":
            MessageLookupByLibrary.simpleMessage("Details"),
        "seller_home_wallet": MessageLookupByLibrary.simpleMessage("Wallet"),
        "seller_profile_about_merchant":
            MessageLookupByLibrary.simpleMessage("About Merchant"),
        "seller_profile_about_us":
            MessageLookupByLibrary.simpleMessage("About"),
        "seller_profile_auth_management":
            MessageLookupByLibrary.simpleMessage("Auth"),
        "seller_profile_buyer_mode":
            MessageLookupByLibrary.simpleMessage("Buyer Mode"),
        "seller_profile_certification_status":
            MessageLookupByLibrary.simpleMessage("Certification Status"),
        "seller_profile_certified":
            MessageLookupByLibrary.simpleMessage("Certified"),
        "seller_profile_chat_failed": m44,
        "seller_profile_default_title":
            MessageLookupByLibrary.simpleMessage("Seller Profile"),
        "seller_profile_error_occurred": m45,
        "seller_profile_feature_not_implemented": m46,
        "seller_profile_follow": MessageLookupByLibrary.simpleMessage("Follow"),
        "seller_profile_follow_success":
            MessageLookupByLibrary.simpleMessage("Followed successfully"),
        "seller_profile_followed":
            MessageLookupByLibrary.simpleMessage("Following"),
        "seller_profile_followers": m47,
        "seller_profile_image_load_failed":
            MessageLookupByLibrary.simpleMessage("Image loading failed"),
        "seller_profile_level_two":
            MessageLookupByLibrary.simpleMessage("Level 2 Member"),
        "seller_profile_member_level":
            MessageLookupByLibrary.simpleMessage("Member Level"),
        "seller_profile_mission":
            MessageLookupByLibrary.simpleMessage("Mission"),
        "seller_profile_my_orders":
            MessageLookupByLibrary.simpleMessage("My Orders"),
        "seller_profile_my_services":
            MessageLookupByLibrary.simpleMessage("My Services"),
        "seller_profile_my_wallet":
            MessageLookupByLibrary.simpleMessage("Wallet"),
        "seller_profile_no_description":
            MessageLookupByLibrary.simpleMessage("No description"),
        "seller_profile_no_image":
            MessageLookupByLibrary.simpleMessage("No image"),
        "seller_profile_no_merchant_info":
            MessageLookupByLibrary.simpleMessage("No merchant information"),
        "seller_profile_no_products":
            MessageLookupByLibrary.simpleMessage("No products"),
        "seller_profile_not_certified":
            MessageLookupByLibrary.simpleMessage("Not Certified"),
        "seller_profile_notifications":
            MessageLookupByLibrary.simpleMessage("Notifications"),
        "seller_profile_order_delivered":
            MessageLookupByLibrary.simpleMessage("Delivered"),
        "seller_profile_order_pending":
            MessageLookupByLibrary.simpleMessage("Pending"),
        "seller_profile_order_processing":
            MessageLookupByLibrary.simpleMessage("Processing"),
        "seller_profile_order_refund":
            MessageLookupByLibrary.simpleMessage("Refund/Support"),
        "seller_profile_response_hours":
            MessageLookupByLibrary.simpleMessage("3 hours"),
        "seller_profile_response_time":
            MessageLookupByLibrary.simpleMessage("Response Time"),
        "seller_profile_seller": MessageLookupByLibrary.simpleMessage("Seller"),
        "seller_profile_seller_mode":
            MessageLookupByLibrary.simpleMessage("Seller Mode"),
        "seller_profile_seller_mode_online":
            MessageLookupByLibrary.simpleMessage("Seller Mode: Online"),
        "seller_profile_seller_rating":
            MessageLookupByLibrary.simpleMessage("Seller Rating"),
        "seller_profile_settings":
            MessageLookupByLibrary.simpleMessage("Settings"),
        "seller_profile_time_management":
            MessageLookupByLibrary.simpleMessage("Schedule"),
        "seller_profile_title": MessageLookupByLibrary.simpleMessage("Profile"),
        "seller_profile_unfollow_success":
            MessageLookupByLibrary.simpleMessage("Unfollowed successfully"),
        "seller_profile_user_name": MessageLookupByLibrary.simpleMessage("Ray"),
        "seller_statistics_active_orders":
            MessageLookupByLibrary.simpleMessage("Active Orders"),
        "seller_statistics_become_level3_seller": m48,
        "seller_statistics_complete_orders": m49,
        "seller_statistics_completion_rate":
            MessageLookupByLibrary.simpleMessage("Completion"),
        "seller_statistics_earliest":
            MessageLookupByLibrary.simpleMessage("Earliest"),
        "seller_statistics_heat_value":
            MessageLookupByLibrary.simpleMessage("Heat"),
        "seller_statistics_incomplete_orders":
            MessageLookupByLibrary.simpleMessage("Incomplete Orders"),
        "seller_statistics_indicators":
            MessageLookupByLibrary.simpleMessage("Metrics"),
        "seller_statistics_loading_failed": m50,
        "seller_statistics_monthly_earnings":
            MessageLookupByLibrary.simpleMessage("Monthly Revenue"),
        "seller_statistics_next_delivery_date":
            MessageLookupByLibrary.simpleMessage("Next Delivery"),
        "seller_statistics_pending":
            MessageLookupByLibrary.simpleMessage("Pending"),
        "seller_statistics_pending_completion":
            MessageLookupByLibrary.simpleMessage("Pending"),
        "seller_statistics_positive_rate":
            MessageLookupByLibrary.simpleMessage("Rating"),
        "seller_statistics_profit_amount": m51,
        "seller_statistics_receipt":
            MessageLookupByLibrary.simpleMessage("Receipt"),
        "seller_statistics_reply_rate":
            MessageLookupByLibrary.simpleMessage("Reply Rate"),
        "seller_statistics_retry":
            MessageLookupByLibrary.simpleMessage("Retry"),
        "seller_statistics_seller_homepage":
            MessageLookupByLibrary.simpleMessage("Seller Profile"),
        "seller_statistics_title":
            MessageLookupByLibrary.simpleMessage("Analytics"),
        "seller_statistics_total_earnings":
            MessageLookupByLibrary.simpleMessage("Total Revenue"),
        "seller_statistics_total_orders":
            MessageLookupByLibrary.simpleMessage("Total Orders"),
        "seller_statistics_upgrade_to_next_level":
            MessageLookupByLibrary.simpleMessage("Upgrade to Next Level"),
        "storagePermissionDenied":
            MessageLookupByLibrary.simpleMessage("Storage permission denied"),
        "storagePermissionRequired": MessageLookupByLibrary.simpleMessage(
            "Storage permission required to download files"),
        "system_language":
            MessageLookupByLibrary.simpleMessage("System Language"),
        "system_language_description": MessageLookupByLibrary.simpleMessage(
            "Automatically use device language settings"),
        "tapToOpen": MessageLookupByLibrary.simpleMessage("Tap to open"),
        "tapToPreview": MessageLookupByLibrary.simpleMessage("Tap to preview"),
        "time_management_current_status":
            MessageLookupByLibrary.simpleMessage("Current Status"),
        "time_management_load_failed":
            MessageLookupByLibrary.simpleMessage("Load Failed"),
        "time_management_offline":
            MessageLookupByLibrary.simpleMessage("Offline"),
        "time_management_offline_description": MessageLookupByLibrary.simpleMessage(
            "You are currently offline. Buyers can still send you messages but the system will inform them that you are temporarily unavailable. You will still receive notifications for new messages but may not be able to respond immediately. Staying offline for extended periods may affect your order efficiency."),
        "time_management_offline_status_description":
            MessageLookupByLibrary.simpleMessage("Offline Status Description"),
        "time_management_online":
            MessageLookupByLibrary.simpleMessage("Online"),
        "time_management_online_description": MessageLookupByLibrary.simpleMessage(
            "You are currently online. Buyers can send you messages and you will receive notifications for new messages. Please ensure timely responses to buyer messages as maintaining a good response rate helps improve your service quality rating."),
        "time_management_online_status_description":
            MessageLookupByLibrary.simpleMessage("Online Status Description"),
        "time_management_retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "time_management_save_settings":
            MessageLookupByLibrary.simpleMessage("Save Settings"),
        "time_management_settings_saved":
            MessageLookupByLibrary.simpleMessage("Settings Saved"),
        "time_management_title":
            MessageLookupByLibrary.simpleMessage("Time Management"),
        "time_management_unknown_status":
            MessageLookupByLibrary.simpleMessage("Unknown Status")
      };
}
