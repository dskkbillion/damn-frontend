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

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "ai_docs_add_image": MessageLookupByLibrary.simpleMessage("Add Image"),
    "ai_docs_assistant_title": MessageLookupByLibrary.simpleMessage(
      "AI Assistant",
    ),
    "ai_docs_conversation_list": MessageLookupByLibrary.simpleMessage(
      "Conversation List",
    ),
    "ai_docs_dispatched": MessageLookupByLibrary.simpleMessage("Dispatched"),
    "ai_docs_enter_message": MessageLookupByLibrary.simpleMessage(
      "Enter message...",
    ),
    "ai_docs_image_picking_error": m0,
    "ai_docs_let_them_see": MessageLookupByLibrary.simpleMessage(
      "Let them see",
    ),
    "ai_docs_loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "ai_docs_match_button": MessageLookupByLibrary.simpleMessage("Match"),
    "ai_docs_mic_permission_denied": MessageLookupByLibrary.simpleMessage(
      "Microphone permission denied",
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
    "language_settings": MessageLookupByLibrary.simpleMessage(
      "Language Settings",
    ),
    "system_language": MessageLookupByLibrary.simpleMessage("System Language"),
    "system_language_description": MessageLookupByLibrary.simpleMessage(
      "Automatically use device language settings",
    ),
  };
}
