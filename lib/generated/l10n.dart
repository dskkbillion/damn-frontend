// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Language Settings`
  String get language_settings {
    return Intl.message(
      'Language Settings',
      name: 'language_settings',
      desc: '',
      args: [],
    );
  }

  /// `System Language`
  String get system_language {
    return Intl.message(
      'System Language',
      name: 'system_language',
      desc: '',
      args: [],
    );
  }

  /// `Automatically use device language settings`
  String get system_language_description {
    return Intl.message(
      'Automatically use device language settings',
      name: 'system_language_description',
      desc: '',
      args: [],
    );
  }

  /// `AI Assistant`
  String get ai_docs_assistant_title {
    return Intl.message(
      'AI Assistant',
      name: 'ai_docs_assistant_title',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed Conversation`
  String get ai_docs_unnamed_conversation {
    return Intl.message(
      'Unnamed Conversation',
      name: 'ai_docs_unnamed_conversation',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get ai_docs_loading {
    return Intl.message(
      'Loading...',
      name: 'ai_docs_loading',
      desc: '',
      args: [],
    );
  }

  /// `Match`
  String get ai_docs_match_button {
    return Intl.message(
      'Match',
      name: 'ai_docs_match_button',
      desc: '',
      args: [],
    );
  }

  /// `Please select a conversation first`
  String get ai_docs_select_conversation_first {
    return Intl.message(
      'Please select a conversation first',
      name: 'ai_docs_select_conversation_first',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a message`
  String get ai_docs_please_enter_message {
    return Intl.message(
      'Please enter a message',
      name: 'ai_docs_please_enter_message',
      desc: '',
      args: [],
    );
  }

  /// `Recommended Services`
  String get ai_docs_recommended_services {
    return Intl.message(
      'Recommended Services',
      name: 'ai_docs_recommended_services',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load recommendations: {error}`
  String ai_docs_recommendations_error(String error) {
    return Intl.message(
      'Failed to load recommendations: $error',
      name: 'ai_docs_recommendations_error',
      desc: '',
      args: [error],
    );
  }

  /// `No recommendations available`
  String get ai_docs_no_recommendations {
    return Intl.message(
      'No recommendations available',
      name: 'ai_docs_no_recommendations',
      desc: '',
      args: [],
    );
  }

  /// `Dispatched`
  String get ai_docs_dispatched {
    return Intl.message(
      'Dispatched',
      name: 'ai_docs_dispatched',
      desc: '',
      args: [],
    );
  }

  /// `Enter Chat`
  String get ai_docs_enter_chat {
    return Intl.message(
      'Enter Chat',
      name: 'ai_docs_enter_chat',
      desc: '',
      args: [],
    );
  }

  /// `Let them see`
  String get ai_docs_let_them_see {
    return Intl.message(
      'Let them see',
      name: 'ai_docs_let_them_see',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to AI Assistant`
  String get ai_docs_welcome_title {
    return Intl.message(
      'Welcome to AI Assistant',
      name: 'ai_docs_welcome_title',
      desc: '',
      args: [],
    );
  }

  /// `Just send a message to start chatting, and the system will automatically create a chat room for you`
  String get ai_docs_welcome_message {
    return Intl.message(
      'Just send a message to start chatting, and the system will automatically create a chat room for you',
      name: 'ai_docs_welcome_message',
      desc: '',
      args: [],
    );
  }

  /// `No conversation selected, automatically creating a new conversation and sending message`
  String get ai_docs_auto_create_text {
    return Intl.message(
      'No conversation selected, automatically creating a new conversation and sending message',
      name: 'ai_docs_auto_create_text',
      desc: '',
      args: [],
    );
  }

  /// `No conversation selected, automatically creating a new conversation and sending voice message`
  String get ai_docs_auto_create_voice {
    return Intl.message(
      'No conversation selected, automatically creating a new conversation and sending voice message',
      name: 'ai_docs_auto_create_voice',
      desc: '',
      args: [],
    );
  }

  /// `Cancelling generation...`
  String get ai_docs_cancelling_generation {
    return Intl.message(
      'Cancelling generation...',
      name: 'ai_docs_cancelling_generation',
      desc: '',
      args: [],
    );
  }

  /// `Allocating`
  String get allocating_step1 {
    return Intl.message(
      'Allocating',
      name: 'allocating_step1',
      desc: '',
      args: [],
    );
  }

  /// `Allocating.`
  String get allocating_step2 {
    return Intl.message(
      'Allocating.',
      name: 'allocating_step2',
      desc: '',
      args: [],
    );
  }

  /// `Allocating..`
  String get allocating_step3 {
    return Intl.message(
      'Allocating..',
      name: 'allocating_step3',
      desc: '',
      args: [],
    );
  }

  /// `Allocating...`
  String get allocating_step4 {
    return Intl.message(
      'Allocating...',
      name: 'allocating_step4',
      desc: '',
      args: [],
    );
  }

  /// `Add Image`
  String get ai_docs_add_image {
    return Intl.message(
      'Add Image',
      name: 'ai_docs_add_image',
      desc: '',
      args: [],
    );
  }

  /// `Stop Recording`
  String get ai_docs_stop_recording {
    return Intl.message(
      'Stop Recording',
      name: 'ai_docs_stop_recording',
      desc: '',
      args: [],
    );
  }

  /// `Record Voice`
  String get ai_docs_start_recording {
    return Intl.message(
      'Record Voice',
      name: 'ai_docs_start_recording',
      desc: '',
      args: [],
    );
  }

  /// `Recording... tap to stop`
  String get ai_docs_recording {
    return Intl.message(
      'Recording... tap to stop',
      name: 'ai_docs_recording',
      desc: '',
      args: [],
    );
  }

  /// `Enter message...`
  String get ai_docs_enter_message {
    return Intl.message(
      'Enter message...',
      name: 'ai_docs_enter_message',
      desc: '',
      args: [],
    );
  }

  /// `Stop Generation`
  String get ai_docs_stop_generation {
    return Intl.message(
      'Stop Generation',
      name: 'ai_docs_stop_generation',
      desc: '',
      args: [],
    );
  }

  /// `Send Message`
  String get ai_docs_send_message {
    return Intl.message(
      'Send Message',
      name: 'ai_docs_send_message',
      desc: '',
      args: [],
    );
  }

  /// `Images uploading, please wait...`
  String get ai_docs_uploading_images {
    return Intl.message(
      'Images uploading, please wait...',
      name: 'ai_docs_uploading_images',
      desc: '',
      args: [],
    );
  }

  /// `Microphone permission denied`
  String get ai_docs_mic_permission_denied {
    return Intl.message(
      'Microphone permission denied',
      name: 'ai_docs_mic_permission_denied',
      desc: '',
      args: [],
    );
  }

  /// `Error starting recording: {error}`
  String ai_docs_recording_error(String error) {
    return Intl.message(
      'Error starting recording: $error',
      name: 'ai_docs_recording_error',
      desc: '',
      args: [error],
    );
  }

  /// `Error: Recording file not found`
  String get ai_docs_recording_file_not_found {
    return Intl.message(
      'Error: Recording file not found',
      name: 'ai_docs_recording_file_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Error stopping recording`
  String get ai_docs_stop_recording_error {
    return Intl.message(
      'Error stopping recording',
      name: 'ai_docs_stop_recording_error',
      desc: '',
      args: [],
    );
  }

  /// `Error stopping recording: {error}`
  String ai_docs_stop_recording_error_with_reason(String error) {
    return Intl.message(
      'Error stopping recording: $error',
      name: 'ai_docs_stop_recording_error_with_reason',
      desc: '',
      args: [error],
    );
  }

  /// `Error selecting image: {error}`
  String ai_docs_image_picking_error(String error) {
    return Intl.message(
      'Error selecting image: $error',
      name: 'ai_docs_image_picking_error',
      desc: '',
      args: [error],
    );
  }

  /// `Conversation List`
  String get ai_docs_conversation_list {
    return Intl.message(
      'Conversation List',
      name: 'ai_docs_conversation_list',
      desc: '',
      args: [],
    );
  }

  /// `No messages yet. Start chatting!`
  String get ai_docs_no_messages {
    return Intl.message(
      'No messages yet. Start chatting!',
      name: 'ai_docs_no_messages',
      desc: '',
      args: [],
    );
  }

  /// `New Chat`
  String get ai_docs_new_chat {
    return Intl.message(
      'New Chat',
      name: 'ai_docs_new_chat',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load conversations`
  String get ai_docs_load_conversations_failed {
    return Intl.message(
      'Failed to load conversations',
      name: 'ai_docs_load_conversations_failed',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get ai_docs_retry {
    return Intl.message(
      'Retry',
      name: 'ai_docs_retry',
      desc: '',
      args: [],
    );
  }

  /// `No conversations yet`
  String get ai_docs_no_conversations {
    return Intl.message(
      'No conversations yet',
      name: 'ai_docs_no_conversations',
      desc: '',
      args: [],
    );
  }

  /// `Delete conversation`
  String get ai_docs_delete_conversation_tooltip {
    return Intl.message(
      'Delete conversation',
      name: 'ai_docs_delete_conversation_tooltip',
      desc: '',
      args: [],
    );
  }

  /// `Delete conversation?`
  String get ai_docs_delete_conversation_title {
    return Intl.message(
      'Delete conversation?',
      name: 'ai_docs_delete_conversation_title',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to permanently delete this conversation?`
  String get ai_docs_delete_conversation_content {
    return Intl.message(
      'Are you sure you want to permanently delete this conversation?',
      name: 'ai_docs_delete_conversation_content',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get ai_docs_cancel {
    return Intl.message(
      'Cancel',
      name: 'ai_docs_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get ai_docs_delete {
    return Intl.message(
      'Delete',
      name: 'ai_docs_delete',
      desc: '',
      args: [],
    );
  }

  /// `Please select the conversation to delete first`
  String get ai_docs_please_select_conversation_to_delete {
    return Intl.message(
      'Please select the conversation to delete first',
      name: 'ai_docs_please_select_conversation_to_delete',
      desc: '',
      args: [],
    );
  }

  /// `AI Generate Title`
  String get ai_docs_generate_title {
    return Intl.message(
      'AI Generate Title',
      name: 'ai_docs_generate_title',
      desc: '',
      args: [],
    );
  }

  /// `Let AI generate a title for this conversation`
  String get ai_docs_generate_title_tooltip {
    return Intl.message(
      'Let AI generate a title for this conversation',
      name: 'ai_docs_generate_title_tooltip',
      desc: '',
      args: [],
    );
  }

  /// `Generating title...`
  String get ai_docs_generating_title {
    return Intl.message(
      'Generating title...',
      name: 'ai_docs_generating_title',
      desc: '',
      args: [],
    );
  }

  /// `Title generated`
  String get ai_docs_title_generated {
    return Intl.message(
      'Title generated',
      name: 'ai_docs_title_generated',
      desc: '',
      args: [],
    );
  }

  /// `Title generation failed: {error}`
  String ai_docs_title_generation_failed(String error) {
    return Intl.message(
      'Title generation failed: $error',
      name: 'ai_docs_title_generation_failed',
      desc: '',
      args: [error],
    );
  }

  /// `Edit Title`
  String get ai_docs_edit_title {
    return Intl.message(
      'Edit Title',
      name: 'ai_docs_edit_title',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a new title`
  String get ai_docs_edit_title_hint {
    return Intl.message(
      'Please enter a new title',
      name: 'ai_docs_edit_title_hint',
      desc: '',
      args: [],
    );
  }

  /// `Title updated`
  String get ai_docs_title_updated {
    return Intl.message(
      'Title updated',
      name: 'ai_docs_title_updated',
      desc: '',
      args: [],
    );
  }

  /// `Title update failed: {error}`
  String ai_docs_title_update_failed(String error) {
    return Intl.message(
      'Title update failed: $error',
      name: 'ai_docs_title_update_failed',
      desc: '',
      args: [error],
    );
  }

  /// `Title cannot exceed 50 characters`
  String get ai_docs_title_too_long {
    return Intl.message(
      'Title cannot exceed 50 characters',
      name: 'ai_docs_title_too_long',
      desc: '',
      args: [],
    );
  }

  /// `Title cannot be empty`
  String get ai_docs_title_empty {
    return Intl.message(
      'Title cannot be empty',
      name: 'ai_docs_title_empty',
      desc: '',
      args: [],
    );
  }

  /// `DSKK`
  String get nav_ai_assistant {
    return Intl.message(
      'DSKK',
      name: 'nav_ai_assistant',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get nav_home {
    return Intl.message(
      'Home',
      name: 'nav_home',
      desc: '',
      args: [],
    );
  }

  /// `Messages`
  String get nav_messages {
    return Intl.message(
      'Messages',
      name: 'nav_messages',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get nav_profile {
    return Intl.message(
      'Profile',
      name: 'nav_profile',
      desc: '',
      args: [],
    );
  }

  /// `Dev`
  String get nav_dev {
    return Intl.message(
      'Dev',
      name: 'nav_dev',
      desc: '',
      args: [],
    );
  }

  /// `Analytics`
  String get nav_seller_analytics {
    return Intl.message(
      'Analytics',
      name: 'nav_seller_analytics',
      desc: '',
      args: [],
    );
  }

  /// `Products`
  String get nav_seller_products {
    return Intl.message(
      'Products',
      name: 'nav_seller_products',
      desc: '',
      args: [],
    );
  }

  /// `Messages`
  String get nav_seller_messages {
    return Intl.message(
      'Messages',
      name: 'nav_seller_messages',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get nav_seller_profile {
    return Intl.message(
      'Profile',
      name: 'nav_seller_profile',
      desc: '',
      args: [],
    );
  }

  /// `Chat List`
  String get chat_list_title {
    return Intl.message(
      'Chat List',
      name: 'chat_list_title',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get chat_loading {
    return Intl.message(
      'Loading...',
      name: 'chat_loading',
      desc: '',
      args: [],
    );
  }

  /// `Loading failed: {error}`
  String chat_error_loading(String error) {
    return Intl.message(
      'Loading failed: $error',
      name: 'chat_error_loading',
      desc: '',
      args: [error],
    );
  }

  /// `No messages yet. Start chatting!`
  String get chat_no_messages {
    return Intl.message(
      'No messages yet. Start chatting!',
      name: 'chat_no_messages',
      desc: '',
      args: [],
    );
  }

  /// `System Admin`
  String get chat_admin_title {
    return Intl.message(
      'System Admin',
      name: 'chat_admin_title',
      desc: '',
      args: [],
    );
  }

  /// `Notification Center`
  String get chat_notification_center {
    return Intl.message(
      'Notification Center',
      name: 'chat_notification_center',
      desc: '',
      args: [],
    );
  }

  /// `System, orders, reviews and important notifications`
  String get chat_notification_description {
    return Intl.message(
      'System, orders, reviews and important notifications',
      name: 'chat_notification_description',
      desc: '',
      args: [],
    );
  }

  /// `Enter message...`
  String get chat_enter_message {
    return Intl.message(
      'Enter message...',
      name: 'chat_enter_message',
      desc: '',
      args: [],
    );
  }

  /// `Yesterday`
  String get chat_yesterday {
    return Intl.message(
      'Yesterday',
      name: 'chat_yesterday',
      desc: '',
      args: [],
    );
  }

  /// `[Image]`
  String get chat_image_message {
    return Intl.message(
      '[Image]',
      name: 'chat_image_message',
      desc: '',
      args: [],
    );
  }

  /// `[Audio]`
  String get chat_audio_message {
    return Intl.message(
      '[Audio]',
      name: 'chat_audio_message',
      desc: '',
      args: [],
    );
  }

  /// `[Message withdrawn]`
  String get chat_revoked_message {
    return Intl.message(
      '[Message withdrawn]',
      name: 'chat_revoked_message',
      desc: '',
      args: [],
    );
  }

  /// `[Unknown message]`
  String get chat_unknown_message {
    return Intl.message(
      '[Unknown message]',
      name: 'chat_unknown_message',
      desc: '',
      args: [],
    );
  }

  /// `Unknown User`
  String get chat_unknown_user {
    return Intl.message(
      'Unknown User',
      name: 'chat_unknown_user',
      desc: '',
      args: [],
    );
  }

  /// `Invalid session`
  String get chat_invalid_session {
    return Intl.message(
      'Invalid session',
      name: 'chat_invalid_session',
      desc: '',
      args: [],
    );
  }

  /// `Cannot find the other party's information`
  String get chat_opponent_not_found {
    return Intl.message(
      'Cannot find the other party\'s information',
      name: 'chat_opponent_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Message recalled`
  String get chat_message_recalled {
    return Intl.message(
      'Message recalled',
      name: 'chat_message_recalled',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get chat_copy {
    return Intl.message(
      'Copy',
      name: 'chat_copy',
      desc: '',
      args: [],
    );
  }

  /// `Recall`
  String get chat_recall {
    return Intl.message(
      'Recall',
      name: 'chat_recall',
      desc: '',
      args: [],
    );
  }

  /// `Copied to clipboard`
  String get chat_copied_to_clipboard {
    return Intl.message(
      'Copied to clipboard',
      name: 'chat_copied_to_clipboard',
      desc: '',
      args: [],
    );
  }

  /// `Me`
  String get chat_me {
    return Intl.message(
      'Me',
      name: 'chat_me',
      desc: '',
      args: [],
    );
  }

  /// `Buyer`
  String get chat_buyer {
    return Intl.message(
      'Buyer',
      name: 'chat_buyer',
      desc: '',
      args: [],
    );
  }

  /// `I want the seller to see`
  String get chat_i_want_seller_to_see {
    return Intl.message(
      'I want the seller to see',
      name: 'chat_i_want_seller_to_see',
      desc: '',
      args: [],
    );
  }

  /// `wants to see`
  String get chat_wants_to_see {
    return Intl.message(
      'wants to see',
      name: 'chat_wants_to_see',
      desc: '',
      args: [],
    );
  }

  /// `Collapse`
  String get chat_collapse {
    return Intl.message(
      'Collapse',
      name: 'chat_collapse',
      desc: '',
      args: [],
    );
  }

  /// `Expand`
  String get chat_expand {
    return Intl.message(
      'Expand',
      name: 'chat_expand',
      desc: '',
      args: [],
    );
  }

  /// `Unable to connect to system admin`
  String get chat_admin_connection_error {
    return Intl.message(
      'Unable to connect to system admin',
      name: 'chat_admin_connection_error',
      desc: '',
      args: [],
    );
  }

  /// `Pause`
  String get chat_audio_pause {
    return Intl.message(
      'Pause',
      name: 'chat_audio_pause',
      desc: '',
      args: [],
    );
  }

  /// `Play`
  String get chat_audio_play {
    return Intl.message(
      'Play',
      name: 'chat_audio_play',
      desc: '',
      args: [],
    );
  }

  /// `This is a level 1 heading`
  String get chat_markdown_example_title1 {
    return Intl.message(
      'This is a level 1 heading',
      name: 'chat_markdown_example_title1',
      desc: '',
      args: [],
    );
  }

  /// `This is a level 2 heading`
  String get chat_markdown_example_title2 {
    return Intl.message(
      'This is a level 2 heading',
      name: 'chat_markdown_example_title2',
      desc: '',
      args: [],
    );
  }

  /// `This is **bold** text and *italic* text.`
  String get chat_markdown_example_bold_italic {
    return Intl.message(
      'This is **bold** text and *italic* text.',
      name: 'chat_markdown_example_bold_italic',
      desc: '',
      args: [],
    );
  }

  /// `This is list item 1`
  String get chat_markdown_example_list1 {
    return Intl.message(
      'This is list item 1',
      name: 'chat_markdown_example_list1',
      desc: '',
      args: [],
    );
  }

  /// `This is list item 2`
  String get chat_markdown_example_list2 {
    return Intl.message(
      'This is list item 2',
      name: 'chat_markdown_example_list2',
      desc: '',
      args: [],
    );
  }

  /// `This is a nested list item`
  String get chat_markdown_example_list3 {
    return Intl.message(
      'This is a nested list item',
      name: 'chat_markdown_example_list3',
      desc: '',
      args: [],
    );
  }

  /// `This is a quote text, supporting multiple lines`
  String get chat_markdown_example_quote {
    return Intl.message(
      'This is a quote text, supporting multiple lines',
      name: 'chat_markdown_example_quote',
      desc: '',
      args: [],
    );
  }

  /// `Column 1`
  String get chat_markdown_example_table_col1 {
    return Intl.message(
      'Column 1',
      name: 'chat_markdown_example_table_col1',
      desc: '',
      args: [],
    );
  }

  /// `Column 2`
  String get chat_markdown_example_table_col2 {
    return Intl.message(
      'Column 2',
      name: 'chat_markdown_example_table_col2',
      desc: '',
      args: [],
    );
  }

  /// `Content 1`
  String get chat_markdown_example_table_content1 {
    return Intl.message(
      'Content 1',
      name: 'chat_markdown_example_table_content1',
      desc: '',
      args: [],
    );
  }

  /// `Content 2`
  String get chat_markdown_example_table_content2 {
    return Intl.message(
      'Content 2',
      name: 'chat_markdown_example_table_content2',
      desc: '',
      args: [],
    );
  }

  /// `Content 3`
  String get chat_markdown_example_table_content3 {
    return Intl.message(
      'Content 3',
      name: 'chat_markdown_example_table_content3',
      desc: '',
      args: [],
    );
  }

  /// `Content 4`
  String get chat_markdown_example_table_content4 {
    return Intl.message(
      'Content 4',
      name: 'chat_markdown_example_table_content4',
      desc: '',
      args: [],
    );
  }

  /// `Pick from Gallery`
  String get chat_pick_from_gallery {
    return Intl.message(
      'Pick from Gallery',
      name: 'chat_pick_from_gallery',
      desc: '',
      args: [],
    );
  }

  /// `Take Photo`
  String get chat_take_photo {
    return Intl.message(
      'Take Photo',
      name: 'chat_take_photo',
      desc: '',
      args: [],
    );
  }

  /// `Send Markdown Example`
  String get chat_send_markdown {
    return Intl.message(
      'Send Markdown Example',
      name: 'chat_send_markdown',
      desc: '',
      args: [],
    );
  }

  /// `Switch to Text Input`
  String get chat_switch_to_text {
    return Intl.message(
      'Switch to Text Input',
      name: 'chat_switch_to_text',
      desc: '',
      args: [],
    );
  }

  /// `Switch to Voice Input`
  String get chat_switch_to_voice {
    return Intl.message(
      'Switch to Voice Input',
      name: 'chat_switch_to_voice',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get chat_send {
    return Intl.message(
      'Send',
      name: 'chat_send',
      desc: '',
      args: [],
    );
  }

  /// `Send Image/File`
  String get chat_attach {
    return Intl.message(
      'Send Image/File',
      name: 'chat_attach',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get chat_filter_all {
    return Intl.message(
      'All',
      name: 'chat_filter_all',
      desc: '',
      args: [],
    );
  }

  /// `My Purchases`
  String get chat_filter_buyer {
    return Intl.message(
      'My Purchases',
      name: 'chat_filter_buyer',
      desc: '',
      args: [],
    );
  }

  /// `My Sales`
  String get chat_filter_seller {
    return Intl.message(
      'My Sales',
      name: 'chat_filter_seller',
      desc: '',
      args: [],
    );
  }

  /// `Showing all chats`
  String get chat_filter_mode_all {
    return Intl.message(
      'Showing all chats',
      name: 'chat_filter_mode_all',
      desc: '',
      args: [],
    );
  }

  /// `Showing my purchase chats only`
  String get chat_filter_mode_buyer {
    return Intl.message(
      'Showing my purchase chats only',
      name: 'chat_filter_mode_buyer',
      desc: '',
      args: [],
    );
  }

  /// `Showing my sales chats only`
  String get chat_filter_mode_seller {
    return Intl.message(
      'Showing my sales chats only',
      name: 'chat_filter_mode_seller',
      desc: '',
      args: [],
    );
  }

  /// `Press to Talk`
  String get chat_press_to_talk {
    return Intl.message(
      'Press to Talk',
      name: 'chat_press_to_talk',
      desc: '',
      args: [],
    );
  }

  /// `Release to Send ({duration}s)`
  String chat_release_to_send(int duration) {
    return Intl.message(
      'Release to Send (${duration}s)',
      name: 'chat_release_to_send',
      desc: '',
      args: [duration],
    );
  }

  /// `Camera Permission Denied`
  String get chat_camera_permission_denied_title {
    return Intl.message(
      'Camera Permission Denied',
      name: 'chat_camera_permission_denied_title',
      desc: '',
      args: [],
    );
  }

  /// `Please enable camera permission in system settings to use the photo feature.`
  String get chat_camera_permission_denied_message {
    return Intl.message(
      'Please enable camera permission in system settings to use the photo feature.',
      name: 'chat_camera_permission_denied_message',
      desc: '',
      args: [],
    );
  }

  /// `Microphone Permission Denied`
  String get chat_mic_permission_denied_title {
    return Intl.message(
      'Microphone Permission Denied',
      name: 'chat_mic_permission_denied_title',
      desc: '',
      args: [],
    );
  }

  /// `Please enable microphone permission in system settings to use the recording feature.`
  String get chat_mic_permission_denied_message {
    return Intl.message(
      'Please enable microphone permission in system settings to use the recording feature.',
      name: 'chat_mic_permission_denied_message',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get chat_permission_denied_cancel {
    return Intl.message(
      'Cancel',
      name: 'chat_permission_denied_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get chat_permission_denied_settings {
    return Intl.message(
      'Settings',
      name: 'chat_permission_denied_settings',
      desc: '',
      args: [],
    );
  }

  /// `Microphone permission denied, cannot record`
  String get chat_mic_permission_denied {
    return Intl.message(
      'Microphone permission denied, cannot record',
      name: 'chat_mic_permission_denied',
      desc: '',
      args: [],
    );
  }

  /// `Camera permission denied, cannot take photo`
  String get chat_camera_permission_denied {
    return Intl.message(
      'Camera permission denied, cannot take photo',
      name: 'chat_camera_permission_denied',
      desc: '',
      args: [],
    );
  }

  /// `Error starting recording: {error}`
  String chat_recording_error(String error) {
    return Intl.message(
      'Error starting recording: $error',
      name: 'chat_recording_error',
      desc: '',
      args: [error],
    );
  }

  /// `Error stopping recording: {error}`
  String chat_stop_recording_error(String error) {
    return Intl.message(
      'Error stopping recording: $error',
      name: 'chat_stop_recording_error',
      desc: '',
      args: [error],
    );
  }

  /// `Error selecting image: {error}`
  String chat_image_picking_error(String error) {
    return Intl.message(
      'Error selecting image: $error',
      name: 'chat_image_picking_error',
      desc: '',
      args: [error],
    );
  }

  /// `Recording is not supported on Web platform`
  String get chat_web_recording_not_supported {
    return Intl.message(
      'Recording is not supported on Web platform',
      name: 'chat_web_recording_not_supported',
      desc: '',
      args: [],
    );
  }

  /// `Personal Center`
  String get profile_personal_center {
    return Intl.message(
      'Personal Center',
      name: 'profile_personal_center',
      desc: '',
      args: [],
    );
  }

  /// `Please login to view your profile`
  String get profile_login_prompt {
    return Intl.message(
      'Please login to view your profile',
      name: 'profile_login_prompt',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get profile_login_button {
    return Intl.message(
      'Login',
      name: 'profile_login_button',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get auth_phone_number {
    return Intl.message(
      'Phone Number',
      name: 'auth_phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Select Country/Region`
  String get auth_select_country_region {
    return Intl.message(
      'Select Country/Region',
      name: 'auth_select_country_region',
      desc: '',
      args: [],
    );
  }

  /// `Please enter phone number`
  String get auth_phone_validation_empty {
    return Intl.message(
      'Please enter phone number',
      name: 'auth_phone_validation_empty',
      desc: '',
      args: [],
    );
  }

  /// `Please enter 11-digit phone number`
  String get auth_phone_validation_invalid_cn {
    return Intl.message(
      'Please enter 11-digit phone number',
      name: 'auth_phone_validation_invalid_cn',
      desc: '',
      args: [],
    );
  }

  /// `Phone number must start with 1`
  String get auth_phone_validation_invalid_cn_start {
    return Intl.message(
      'Phone number must start with 1',
      name: 'auth_phone_validation_invalid_cn_start',
      desc: '',
      args: [],
    );
  }

  /// `Please enter 10-digit phone number`
  String get auth_phone_validation_invalid_us {
    return Intl.message(
      'Please enter 10-digit phone number',
      name: 'auth_phone_validation_invalid_us',
      desc: '',
      args: [],
    );
  }

  /// `Please enter 10 or 11-digit phone number`
  String get auth_phone_validation_invalid_jp_kr {
    return Intl.message(
      'Please enter 10 or 11-digit phone number',
      name: 'auth_phone_validation_invalid_jp_kr',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid phone number`
  String get auth_phone_validation_invalid_general {
    return Intl.message(
      'Please enter a valid phone number',
      name: 'auth_phone_validation_invalid_general',
      desc: '',
      args: [],
    );
  }

  /// `Loading failed: {error}`
  String profile_loading_error(String error) {
    return Intl.message(
      'Loading failed: $error',
      name: 'profile_loading_error',
      desc: '',
      args: [error],
    );
  }

  /// `My DSKK`
  String get profile_my_dskk {
    return Intl.message(
      'My DSKK',
      name: 'profile_my_dskk',
      desc: '',
      args: [],
    );
  }

  /// `Favorites`
  String get profile_favorites {
    return Intl.message(
      'Favorites',
      name: 'profile_favorites',
      desc: '',
      args: [],
    );
  }

  /// `My Wallet`
  String get profile_my_wallet {
    return Intl.message(
      'My Wallet',
      name: 'profile_my_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Wallet`
  String get profile_wallet {
    return Intl.message(
      'Wallet',
      name: 'profile_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get profile_settings {
    return Intl.message(
      'Settings',
      name: 'profile_settings',
      desc: '',
      args: [],
    );
  }

  /// `Account & Security`
  String get profile_account_security {
    return Intl.message(
      'Account & Security',
      name: 'profile_account_security',
      desc: '',
      args: [],
    );
  }

  /// `Message Notifications`
  String get profile_message_notifications {
    return Intl.message(
      'Message Notifications',
      name: 'profile_message_notifications',
      desc: '',
      args: [],
    );
  }

  /// `About Us`
  String get profile_about_us {
    return Intl.message(
      'About Us',
      name: 'profile_about_us',
      desc: '',
      args: [],
    );
  }

  /// `Assistant's Mission`
  String get profile_assistant_mission {
    return Intl.message(
      'Assistant\'s Mission',
      name: 'profile_assistant_mission',
      desc: '',
      args: [],
    );
  }

  /// `Switch to Seller Mode`
  String get profile_switch_to_seller {
    return Intl.message(
      'Switch to Seller Mode',
      name: 'profile_switch_to_seller',
      desc: '',
      args: [],
    );
  }

  /// `Unable to switch to seller mode: {error}`
  String profile_switch_error(String error) {
    return Intl.message(
      'Unable to switch to seller mode: $error',
      name: 'profile_switch_error',
      desc: '',
      args: [error],
    );
  }

  /// `Edit Nickname`
  String get profile_edit_nickname {
    return Intl.message(
      'Edit Nickname',
      name: 'profile_edit_nickname',
      desc: '',
      args: [],
    );
  }

  /// `Please enter new nickname`
  String get profile_nickname_hint {
    return Intl.message(
      'Please enter new nickname',
      name: 'profile_nickname_hint',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get profile_cancel {
    return Intl.message(
      'Cancel',
      name: 'profile_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get profile_save {
    return Intl.message(
      'Save',
      name: 'profile_save',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get profile_default_name {
    return Intl.message(
      'User',
      name: 'profile_default_name',
      desc: '',
      args: [],
    );
  }

  /// `Online`
  String get profile_online {
    return Intl.message(
      'Online',
      name: 'profile_online',
      desc: '',
      args: [],
    );
  }

  /// `Offline`
  String get profile_offline {
    return Intl.message(
      'Offline',
      name: 'profile_offline',
      desc: '',
      args: [],
    );
  }

  /// `Avatar upload failed, please try again`
  String get profile_avatar_upload_failed {
    return Intl.message(
      'Avatar upload failed, please try again',
      name: 'profile_avatar_upload_failed',
      desc: '',
      args: [],
    );
  }

  /// `My Orders`
  String get profile_orders {
    return Intl.message(
      'My Orders',
      name: 'profile_orders',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get profile_pending_payment {
    return Intl.message(
      'Pending',
      name: 'profile_pending_payment',
      desc: '',
      args: [],
    );
  }

  /// `To Submit`
  String get profile_in_progress {
    return Intl.message(
      'To Submit',
      name: 'profile_in_progress',
      desc: '',
      args: [],
    );
  }

  /// `To Receive`
  String get profile_completed {
    return Intl.message(
      'To Receive',
      name: 'profile_completed',
      desc: '',
      args: [],
    );
  }

  /// `Support`
  String get profile_refund {
    return Intl.message(
      'Support',
      name: 'profile_refund',
      desc: '',
      args: [],
    );
  }

  /// `Unable to navigate to order list: {error}`
  String profile_navigation_error(String error) {
    return Intl.message(
      'Unable to navigate to order list: $error',
      name: 'profile_navigation_error',
      desc: '',
      args: [error],
    );
  }

  /// `Home`
  String get home_title {
    return Intl.message(
      'Home',
      name: 'home_title',
      desc: '',
      args: [],
    );
  }

  /// `Search services`
  String get home_search_hint {
    return Intl.message(
      'Search services',
      name: 'home_search_hint',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get home_loading {
    return Intl.message(
      'Loading...',
      name: 'home_loading',
      desc: '',
      args: [],
    );
  }

  /// `Loading failed: {error}`
  String home_loading_failed(String error) {
    return Intl.message(
      'Loading failed: $error',
      name: 'home_loading_failed',
      desc: '',
      args: [error],
    );
  }

  /// `Retry`
  String get home_retry {
    return Intl.message(
      'Retry',
      name: 'home_retry',
      desc: '',
      args: [],
    );
  }

  /// `End of list`
  String get home_end_of_list {
    return Intl.message(
      'End of list',
      name: 'home_end_of_list',
      desc: '',
      args: [],
    );
  }

  /// `No recommended content`
  String get home_no_content {
    return Intl.message(
      'No recommended content',
      name: 'home_no_content',
      desc: '',
      args: [],
    );
  }

  /// `Pull to refresh for recommendations`
  String get home_pull_to_refresh {
    return Intl.message(
      'Pull to refresh for recommendations',
      name: 'home_pull_to_refresh',
      desc: '',
      args: [],
    );
  }

  /// `Banner clicked: {targetType} - {targetValue}`
  String home_banner_clicked(String targetType, String targetValue) {
    return Intl.message(
      'Banner clicked: $targetType - $targetValue',
      name: 'home_banner_clicked',
      desc: '',
      args: [targetType, targetValue],
    );
  }

  /// `Service card clicked: {name}`
  String home_product_card_clicked(String name) {
    return Intl.message(
      'Service card clicked: $name',
      name: 'home_product_card_clicked',
      desc: '',
      args: [name],
    );
  }

  /// `Let them see button clicked: {name}`
  String home_recommend_clicked(String name) {
    return Intl.message(
      'Let them see button clicked: $name',
      name: 'home_recommend_clicked',
      desc: '',
      args: [name],
    );
  }

  /// `Let them see`
  String get product_recommend_button {
    return Intl.message(
      'Let them see',
      name: 'product_recommend_button',
      desc: '',
      args: [],
    );
  }

  /// `Image loading failed`
  String get product_image_loading_failed {
    return Intl.message(
      'Image loading failed',
      name: 'product_image_loading_failed',
      desc: '',
      args: [],
    );
  }

  /// `Product`
  String get product_default_name {
    return Intl.message(
      'Product',
      name: 'product_default_name',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search_title {
    return Intl.message(
      'Search',
      name: 'search_title',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search_button {
    return Intl.message(
      'Search',
      name: 'search_button',
      desc: '',
      args: [],
    );
  }

  /// `Hot Keywords`
  String get search_hot_keywords {
    return Intl.message(
      'Hot Keywords',
      name: 'search_hot_keywords',
      desc: '',
      args: [],
    );
  }

  /// `Search History`
  String get search_history {
    return Intl.message(
      'Search History',
      name: 'search_history',
      desc: '',
      args: [],
    );
  }

  /// `No relevant services found`
  String get search_no_results {
    return Intl.message(
      'No relevant services found',
      name: 'search_no_results',
      desc: '',
      args: [],
    );
  }

  /// `Search failed: {error}`
  String search_failed(String error) {
    return Intl.message(
      'Search failed: $error',
      name: 'search_failed',
      desc: '',
      args: [error],
    );
  }

  /// `Loading failed: {error}`
  String product_detail_loading_failed(String error) {
    return Intl.message(
      'Loading failed: $error',
      name: 'product_detail_loading_failed',
      desc: '',
      args: [error],
    );
  }

  /// `Retry`
  String get product_detail_retry {
    return Intl.message(
      'Retry',
      name: 'product_detail_retry',
      desc: '',
      args: [],
    );
  }

  /// `Please wait...`
  String get product_detail_please_wait {
    return Intl.message(
      'Please wait...',
      name: 'product_detail_please_wait',
      desc: '',
      args: [],
    );
  }

  /// `Contact Seller`
  String get product_detail_contact_seller {
    return Intl.message(
      'Contact Seller',
      name: 'product_detail_contact_seller',
      desc: '',
      args: [],
    );
  }

  /// `Verified`
  String get product_detail_verified_label {
    return Intl.message(
      'Verified',
      name: 'product_detail_verified_label',
      desc: '',
      args: [],
    );
  }

  /// `Published`
  String get product_detail_published_status {
    return Intl.message(
      'Published',
      name: 'product_detail_published_status',
      desc: '',
      args: [],
    );
  }

  /// `More`
  String get product_detail_more {
    return Intl.message(
      'More',
      name: 'product_detail_more',
      desc: '',
      args: [],
    );
  }

  /// `Collapse`
  String get product_detail_collapse {
    return Intl.message(
      'Collapse',
      name: 'product_detail_collapse',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Times`
  String get product_detail_delivery_times {
    return Intl.message(
      'Delivery Times',
      name: 'product_detail_delivery_times',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Period`
  String get product_detail_delivery_period {
    return Intl.message(
      'Delivery Period',
      name: 'product_detail_delivery_period',
      desc: '',
      args: [],
    );
  }

  /// `Buy Now (1)`
  String get product_detail_buy_now {
    return Intl.message(
      'Buy Now (1)',
      name: 'product_detail_buy_now',
      desc: '',
      args: [],
    );
  }

  /// `Buy Now ¥{price}`
  String product_detail_buy_now_with_price(String price) {
    return Intl.message(
      'Buy Now ¥$price',
      name: 'product_detail_buy_now_with_price',
      desc: '',
      args: [price],
    );
  }

  /// `FAQ`
  String get product_detail_faq {
    return Intl.message(
      'FAQ',
      name: 'product_detail_faq',
      desc: '',
      args: [],
    );
  }

  /// `Case Showcase`
  String get product_detail_case_showcase {
    return Intl.message(
      'Case Showcase',
      name: 'product_detail_case_showcase',
      desc: '',
      args: [],
    );
  }

  /// `No cases available`
  String get product_detail_no_cases {
    return Intl.message(
      'No cases available',
      name: 'product_detail_no_cases',
      desc: '',
      args: [],
    );
  }

  /// `Reviews ({count})`
  String product_detail_reviews(int count) {
    return Intl.message(
      'Reviews ($count)',
      name: 'product_detail_reviews',
      desc: '',
      args: [count],
    );
  }

  /// `View All`
  String get product_detail_view_all {
    return Intl.message(
      'View All',
      name: 'product_detail_view_all',
      desc: '',
      args: [],
    );
  }

  /// `No reviews yet`
  String get product_detail_no_reviews {
    return Intl.message(
      'No reviews yet',
      name: 'product_detail_no_reviews',
      desc: '',
      args: [],
    );
  }

  /// `Basic`
  String get product_detail_basic_package {
    return Intl.message(
      'Basic',
      name: 'product_detail_basic_package',
      desc: '',
      args: [],
    );
  }

  /// `Standard`
  String get product_detail_standard_package {
    return Intl.message(
      'Standard',
      name: 'product_detail_standard_package',
      desc: '',
      args: [],
    );
  }

  /// `Premium`
  String get product_detail_premium_package {
    return Intl.message(
      'Premium',
      name: 'product_detail_premium_package',
      desc: '',
      args: [],
    );
  }

  /// `Basic`
  String get product_detail_basic_tier {
    return Intl.message(
      'Basic',
      name: 'product_detail_basic_tier',
      desc: '',
      args: [],
    );
  }

  /// `Standard`
  String get product_detail_standard_tier {
    return Intl.message(
      'Standard',
      name: 'product_detail_standard_tier',
      desc: '',
      args: [],
    );
  }

  /// `Premium`
  String get product_detail_premium_tier {
    return Intl.message(
      'Premium',
      name: 'product_detail_premium_tier',
      desc: '',
      args: [],
    );
  }

  /// `Great service, very patient`
  String get product_detail_sample_review {
    return Intl.message(
      'Great service, very patient',
      name: 'product_detail_sample_review',
      desc: '',
      args: [],
    );
  }

  /// `Ray123`
  String get product_detail_sample_user {
    return Intl.message(
      'Ray123',
      name: 'product_detail_sample_user',
      desc: '',
      args: [],
    );
  }

  /// `Reviews`
  String get product_reviews_title {
    return Intl.message(
      'Reviews',
      name: 'product_reviews_title',
      desc: '',
      args: [],
    );
  }

  /// `Loading failed: {error}`
  String product_reviews_loading_failed(String error) {
    return Intl.message(
      'Loading failed: $error',
      name: 'product_reviews_loading_failed',
      desc: '',
      args: [error],
    );
  }

  /// `Retry`
  String get product_reviews_retry {
    return Intl.message(
      'Retry',
      name: 'product_reviews_retry',
      desc: '',
      args: [],
    );
  }

  /// `No reviews yet`
  String get product_reviews_no_reviews {
    return Intl.message(
      'No reviews yet',
      name: 'product_reviews_no_reviews',
      desc: '',
      args: [],
    );
  }

  /// `Great service, very patient`
  String get product_reviews_sample_content {
    return Intl.message(
      'Great service, very patient',
      name: 'product_reviews_sample_content',
      desc: '',
      args: [],
    );
  }

  /// `{count} years ago`
  String product_reviews_years_ago(int count) {
    return Intl.message(
      '$count years ago',
      name: 'product_reviews_years_ago',
      desc: '',
      args: [count],
    );
  }

  /// `{count} months ago`
  String product_reviews_months_ago(int count) {
    return Intl.message(
      '$count months ago',
      name: 'product_reviews_months_ago',
      desc: '',
      args: [count],
    );
  }

  /// `{count} days ago`
  String product_reviews_days_ago(int count) {
    return Intl.message(
      '$count days ago',
      name: 'product_reviews_days_ago',
      desc: '',
      args: [count],
    );
  }

  /// `{count} hours ago`
  String product_reviews_hours_ago(int count) {
    return Intl.message(
      '$count hours ago',
      name: 'product_reviews_hours_ago',
      desc: '',
      args: [count],
    );
  }

  /// `{count} minutes ago`
  String product_reviews_minutes_ago(int count) {
    return Intl.message(
      '$count minutes ago',
      name: 'product_reviews_minutes_ago',
      desc: '',
      args: [count],
    );
  }

  /// `Just now`
  String get product_reviews_just_now {
    return Intl.message(
      'Just now',
      name: 'product_reviews_just_now',
      desc: '',
      args: [],
    );
  }

  /// `Seller Reply`
  String get product_reviews_seller_reply {
    return Intl.message(
      'Seller Reply',
      name: 'product_reviews_seller_reply',
      desc: '',
      args: [],
    );
  }

  /// `{count} reviews`
  String product_reviews_total_count(int count) {
    return Intl.message(
      '$count reviews',
      name: 'product_reviews_total_count',
      desc: '',
      args: [count],
    );
  }

  /// `All`
  String get product_reviews_filter_all {
    return Intl.message(
      'All',
      name: 'product_reviews_filter_all',
      desc: '',
      args: [],
    );
  }

  /// `With Images`
  String get product_reviews_filter_with_images {
    return Intl.message(
      'With Images',
      name: 'product_reviews_filter_with_images',
      desc: '',
      args: [],
    );
  }

  /// `Good`
  String get product_reviews_filter_good {
    return Intl.message(
      'Good',
      name: 'product_reviews_filter_good',
      desc: '',
      args: [],
    );
  }

  /// `Medium`
  String get product_reviews_filter_medium {
    return Intl.message(
      'Medium',
      name: 'product_reviews_filter_medium',
      desc: '',
      args: [],
    );
  }

  /// `Bad`
  String get product_reviews_filter_bad {
    return Intl.message(
      'Bad',
      name: 'product_reviews_filter_bad',
      desc: '',
      args: [],
    );
  }

  /// `Seller Profile`
  String get seller_profile_default_title {
    return Intl.message(
      'Seller Profile',
      name: 'seller_profile_default_title',
      desc: '',
      args: [],
    );
  }

  /// `Seller`
  String get seller_profile_seller {
    return Intl.message(
      'Seller',
      name: 'seller_profile_seller',
      desc: '',
      args: [],
    );
  }

  /// `No description`
  String get seller_profile_no_description {
    return Intl.message(
      'No description',
      name: 'seller_profile_no_description',
      desc: '',
      args: [],
    );
  }

  /// `{count} followers`
  String seller_profile_followers(int count) {
    return Intl.message(
      '$count followers',
      name: 'seller_profile_followers',
      desc: '',
      args: [count],
    );
  }

  /// `Following`
  String get seller_profile_followed {
    return Intl.message(
      'Following',
      name: 'seller_profile_followed',
      desc: '',
      args: [],
    );
  }

  /// `Follow`
  String get seller_profile_follow {
    return Intl.message(
      'Follow',
      name: 'seller_profile_follow',
      desc: '',
      args: [],
    );
  }

  /// `Unfollowed successfully`
  String get seller_profile_unfollow_success {
    return Intl.message(
      'Unfollowed successfully',
      name: 'seller_profile_unfollow_success',
      desc: '',
      args: [],
    );
  }

  /// `Followed successfully`
  String get seller_profile_follow_success {
    return Intl.message(
      'Followed successfully',
      name: 'seller_profile_follow_success',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create chat: {error}`
  String seller_profile_chat_failed(String error) {
    return Intl.message(
      'Failed to create chat: $error',
      name: 'seller_profile_chat_failed',
      desc: '',
      args: [error],
    );
  }

  /// `Error occurred: {error}`
  String seller_profile_error_occurred(String error) {
    return Intl.message(
      'Error occurred: $error',
      name: 'seller_profile_error_occurred',
      desc: '',
      args: [error],
    );
  }

  /// `About Merchant`
  String get seller_profile_about_merchant {
    return Intl.message(
      'About Merchant',
      name: 'seller_profile_about_merchant',
      desc: '',
      args: [],
    );
  }

  /// `My Services`
  String get seller_profile_my_services {
    return Intl.message(
      'My Services',
      name: 'seller_profile_my_services',
      desc: '',
      args: [],
    );
  }

  /// `No merchant information`
  String get seller_profile_no_merchant_info {
    return Intl.message(
      'No merchant information',
      name: 'seller_profile_no_merchant_info',
      desc: '',
      args: [],
    );
  }

  /// `Member Level`
  String get seller_profile_member_level {
    return Intl.message(
      'Member Level',
      name: 'seller_profile_member_level',
      desc: '',
      args: [],
    );
  }

  /// `Level 2 Member`
  String get seller_profile_level_two {
    return Intl.message(
      'Level 2 Member',
      name: 'seller_profile_level_two',
      desc: '',
      args: [],
    );
  }

  /// `Seller Rating`
  String get seller_profile_seller_rating {
    return Intl.message(
      'Seller Rating',
      name: 'seller_profile_seller_rating',
      desc: '',
      args: [],
    );
  }

  /// `Response Time`
  String get seller_profile_response_time {
    return Intl.message(
      'Response Time',
      name: 'seller_profile_response_time',
      desc: '',
      args: [],
    );
  }

  /// `3 hours`
  String get seller_profile_response_hours {
    return Intl.message(
      '3 hours',
      name: 'seller_profile_response_hours',
      desc: '',
      args: [],
    );
  }

  /// `Certification Status`
  String get seller_profile_certification_status {
    return Intl.message(
      'Certification Status',
      name: 'seller_profile_certification_status',
      desc: '',
      args: [],
    );
  }

  /// `Certified`
  String get seller_profile_certified {
    return Intl.message(
      'Certified',
      name: 'seller_profile_certified',
      desc: '',
      args: [],
    );
  }

  /// `Not Certified`
  String get seller_profile_not_certified {
    return Intl.message(
      'Not Certified',
      name: 'seller_profile_not_certified',
      desc: '',
      args: [],
    );
  }

  /// `No products`
  String get seller_profile_no_products {
    return Intl.message(
      'No products',
      name: 'seller_profile_no_products',
      desc: '',
      args: [],
    );
  }

  /// `Image loading failed`
  String get seller_profile_image_load_failed {
    return Intl.message(
      'Image loading failed',
      name: 'seller_profile_image_load_failed',
      desc: '',
      args: [],
    );
  }

  /// `No image`
  String get seller_profile_no_image {
    return Intl.message(
      'No image',
      name: 'seller_profile_no_image',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get seller_profile_title {
    return Intl.message(
      'Profile',
      name: 'seller_profile_title',
      desc: '',
      args: [],
    );
  }

  /// `Auth`
  String get seller_profile_auth_management {
    return Intl.message(
      'Auth',
      name: 'seller_profile_auth_management',
      desc: '',
      args: [],
    );
  }

  /// `Wallet`
  String get seller_profile_my_wallet {
    return Intl.message(
      'Wallet',
      name: 'seller_profile_my_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Schedule`
  String get seller_profile_time_management {
    return Intl.message(
      'Schedule',
      name: 'seller_profile_time_management',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get seller_profile_settings {
    return Intl.message(
      'Settings',
      name: 'seller_profile_settings',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get seller_profile_notifications {
    return Intl.message(
      'Notifications',
      name: 'seller_profile_notifications',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get seller_profile_about_us {
    return Intl.message(
      'About',
      name: 'seller_profile_about_us',
      desc: '',
      args: [],
    );
  }

  /// `Mission`
  String get seller_profile_mission {
    return Intl.message(
      'Mission',
      name: 'seller_profile_mission',
      desc: '',
      args: [],
    );
  }

  /// `Ray`
  String get seller_profile_user_name {
    return Intl.message(
      'Ray',
      name: 'seller_profile_user_name',
      desc: '',
      args: [],
    );
  }

  /// `Seller Mode: Online`
  String get seller_profile_seller_mode_online {
    return Intl.message(
      'Seller Mode: Online',
      name: 'seller_profile_seller_mode_online',
      desc: '',
      args: [],
    );
  }

  /// `Seller Mode`
  String get seller_profile_seller_mode {
    return Intl.message(
      'Seller Mode',
      name: 'seller_profile_seller_mode',
      desc: '',
      args: [],
    );
  }

  /// `Buyer Mode`
  String get seller_profile_buyer_mode {
    return Intl.message(
      'Buyer Mode',
      name: 'seller_profile_buyer_mode',
      desc: '',
      args: [],
    );
  }

  /// `My Orders`
  String get seller_profile_my_orders {
    return Intl.message(
      'My Orders',
      name: 'seller_profile_my_orders',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get seller_profile_order_pending {
    return Intl.message(
      'Pending',
      name: 'seller_profile_order_pending',
      desc: '',
      args: [],
    );
  }

  /// `Processing`
  String get seller_profile_order_processing {
    return Intl.message(
      'Processing',
      name: 'seller_profile_order_processing',
      desc: '',
      args: [],
    );
  }

  /// `Delivered`
  String get seller_profile_order_delivered {
    return Intl.message(
      'Delivered',
      name: 'seller_profile_order_delivered',
      desc: '',
      args: [],
    );
  }

  /// `Refund/Support`
  String get seller_profile_order_refund {
    return Intl.message(
      'Refund/Support',
      name: 'seller_profile_order_refund',
      desc: '',
      args: [],
    );
  }

  /// `{feature} feature not yet implemented`
  String seller_profile_feature_not_implemented(String feature) {
    return Intl.message(
      '$feature feature not yet implemented',
      name: 'seller_profile_feature_not_implemented',
      desc: '',
      args: [feature],
    );
  }

  /// `Loading failed`
  String get seller_home_loading_failed {
    return Intl.message(
      'Loading failed',
      name: 'seller_home_loading_failed',
      desc: '',
      args: [],
    );
  }

  /// `No data`
  String get seller_home_no_data {
    return Intl.message(
      'No data',
      name: 'seller_home_no_data',
      desc: '',
      args: [],
    );
  }

  /// `No store information`
  String get seller_home_no_store_info {
    return Intl.message(
      'No store information',
      name: 'seller_home_no_store_info',
      desc: '',
      args: [],
    );
  }

  /// `Online`
  String get seller_home_online {
    return Intl.message(
      'Online',
      name: 'seller_home_online',
      desc: '',
      args: [],
    );
  }

  /// `Offline`
  String get seller_home_offline {
    return Intl.message(
      'Offline',
      name: 'seller_home_offline',
      desc: '',
      args: [],
    );
  }

  /// `Completion Rate {rate}%`
  String seller_home_completion_rate(String rate) {
    return Intl.message(
      'Completion Rate $rate%',
      name: 'seller_home_completion_rate',
      desc: '',
      args: [rate],
    );
  }

  /// `Switch to Buyer Mode`
  String get seller_home_switch_to_buyer {
    return Intl.message(
      'Switch to Buyer Mode',
      name: 'seller_home_switch_to_buyer',
      desc: '',
      args: [],
    );
  }

  /// `Unable to switch to buyer mode: {error}`
  String seller_home_switch_failed(String error) {
    return Intl.message(
      'Unable to switch to buyer mode: $error',
      name: 'seller_home_switch_failed',
      desc: '',
      args: [error],
    );
  }

  /// `Revenue`
  String get seller_home_income {
    return Intl.message(
      'Revenue',
      name: 'seller_home_income',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get seller_home_view_details {
    return Intl.message(
      'Details',
      name: 'seller_home_view_details',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get seller_home_total_income {
    return Intl.message(
      'Total',
      name: 'seller_home_total_income',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get seller_home_today_income {
    return Intl.message(
      'Today',
      name: 'seller_home_today_income',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get seller_home_pending_settlement {
    return Intl.message(
      'Pending',
      name: 'seller_home_pending_settlement',
      desc: '',
      args: [],
    );
  }

  /// `Orders`
  String get seller_home_orders {
    return Intl.message(
      'Orders',
      name: 'seller_home_orders',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get seller_home_view_all {
    return Intl.message(
      'View All',
      name: 'seller_home_view_all',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get seller_home_orders_all {
    return Intl.message(
      'All',
      name: 'seller_home_orders_all',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get seller_home_orders_pending {
    return Intl.message(
      'Pending',
      name: 'seller_home_orders_pending',
      desc: '',
      args: [],
    );
  }

  /// `Processing`
  String get seller_home_orders_processing {
    return Intl.message(
      'Processing',
      name: 'seller_home_orders_processing',
      desc: '',
      args: [],
    );
  }

  /// `After Sales`
  String get seller_home_orders_aftersales {
    return Intl.message(
      'After Sales',
      name: 'seller_home_orders_aftersales',
      desc: '',
      args: [],
    );
  }

  /// `Awaiting Delivery`
  String get seller_home_orders_awaiting_delivery {
    return Intl.message(
      'Awaiting Delivery',
      name: 'seller_home_orders_awaiting_delivery',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get seller_home_orders_completed {
    return Intl.message(
      'Completed',
      name: 'seller_home_orders_completed',
      desc: '',
      args: [],
    );
  }

  /// `Canceled`
  String get seller_home_orders_canceled {
    return Intl.message(
      'Canceled',
      name: 'seller_home_orders_canceled',
      desc: '',
      args: [],
    );
  }

  /// `Functions`
  String get seller_home_functions {
    return Intl.message(
      'Functions',
      name: 'seller_home_functions',
      desc: '',
      args: [],
    );
  }

  /// `Wallet`
  String get seller_home_wallet {
    return Intl.message(
      'Wallet',
      name: 'seller_home_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Auth`
  String get seller_home_auth_management {
    return Intl.message(
      'Auth',
      name: 'seller_home_auth_management',
      desc: '',
      args: [],
    );
  }

  /// `Schedule`
  String get seller_home_time_management {
    return Intl.message(
      'Schedule',
      name: 'seller_home_time_management',
      desc: '',
      args: [],
    );
  }

  /// `Auto Reply`
  String get seller_home_auto_reply {
    return Intl.message(
      'Auto Reply',
      name: 'seller_home_auto_reply',
      desc: '',
      args: [],
    );
  }

  /// `Recent Revenue`
  String get seller_home_recent_income {
    return Intl.message(
      'Recent Revenue',
      name: 'seller_home_recent_income',
      desc: '',
      args: [],
    );
  }

  /// `No recent revenue data`
  String get seller_home_no_recent_income {
    return Intl.message(
      'No recent revenue data',
      name: 'seller_home_no_recent_income',
      desc: '',
      args: [],
    );
  }

  /// `No revenue data`
  String get seller_home_no_income_data {
    return Intl.message(
      'No revenue data',
      name: 'seller_home_no_income_data',
      desc: '',
      args: [],
    );
  }

  /// `Analytics`
  String get seller_statistics_title {
    return Intl.message(
      'Analytics',
      name: 'seller_statistics_title',
      desc: '',
      args: [],
    );
  }

  /// `Seller Profile`
  String get seller_statistics_seller_homepage {
    return Intl.message(
      'Seller Profile',
      name: 'seller_statistics_seller_homepage',
      desc: '',
      args: [],
    );
  }

  /// `Heat`
  String get seller_statistics_heat_value {
    return Intl.message(
      'Heat',
      name: 'seller_statistics_heat_value',
      desc: '',
      args: [],
    );
  }

  /// `Reply Rate`
  String get seller_statistics_reply_rate {
    return Intl.message(
      'Reply Rate',
      name: 'seller_statistics_reply_rate',
      desc: '',
      args: [],
    );
  }

  /// `Completion`
  String get seller_statistics_completion_rate {
    return Intl.message(
      'Completion',
      name: 'seller_statistics_completion_rate',
      desc: '',
      args: [],
    );
  }

  /// `Rating`
  String get seller_statistics_positive_rate {
    return Intl.message(
      'Rating',
      name: 'seller_statistics_positive_rate',
      desc: '',
      args: [],
    );
  }

  /// `Upgrade to Next Level`
  String get seller_statistics_upgrade_to_next_level {
    return Intl.message(
      'Upgrade to Next Level',
      name: 'seller_statistics_upgrade_to_next_level',
      desc: '',
      args: [],
    );
  }

  /// `Level 3 Seller for {days} days`
  String seller_statistics_become_level3_seller(String days) {
    return Intl.message(
      'Level 3 Seller for $days days',
      name: 'seller_statistics_become_level3_seller',
      desc: '',
      args: [days],
    );
  }

  /// `Complete {orderNum} orders`
  String seller_statistics_complete_orders(String orderNum) {
    return Intl.message(
      'Complete $orderNum orders',
      name: 'seller_statistics_complete_orders',
      desc: '',
      args: [orderNum],
    );
  }

  /// `Earn ${amount}`
  String seller_statistics_profit_amount(String amount) {
    return Intl.message(
      'Earn \$$amount',
      name: 'seller_statistics_profit_amount',
      desc: '',
      args: [amount],
    );
  }

  /// `Metrics`
  String get seller_statistics_indicators {
    return Intl.message(
      'Metrics',
      name: 'seller_statistics_indicators',
      desc: '',
      args: [],
    );
  }

  /// `Total Revenue`
  String get seller_statistics_total_earnings {
    return Intl.message(
      'Total Revenue',
      name: 'seller_statistics_total_earnings',
      desc: '',
      args: [],
    );
  }

  /// `Monthly Revenue`
  String get seller_statistics_monthly_earnings {
    return Intl.message(
      'Monthly Revenue',
      name: 'seller_statistics_monthly_earnings',
      desc: '',
      args: [],
    );
  }

  /// `Total Orders`
  String get seller_statistics_total_orders {
    return Intl.message(
      'Total Orders',
      name: 'seller_statistics_total_orders',
      desc: '',
      args: [],
    );
  }

  /// `Active Orders`
  String get seller_statistics_active_orders {
    return Intl.message(
      'Active Orders',
      name: 'seller_statistics_active_orders',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get seller_statistics_pending {
    return Intl.message(
      'Pending',
      name: 'seller_statistics_pending',
      desc: '',
      args: [],
    );
  }

  /// `Incomplete Orders`
  String get seller_statistics_incomplete_orders {
    return Intl.message(
      'Incomplete Orders',
      name: 'seller_statistics_incomplete_orders',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get seller_statistics_pending_completion {
    return Intl.message(
      'Pending',
      name: 'seller_statistics_pending_completion',
      desc: '',
      args: [],
    );
  }

  /// `Receipt`
  String get seller_statistics_receipt {
    return Intl.message(
      'Receipt',
      name: 'seller_statistics_receipt',
      desc: '',
      args: [],
    );
  }

  /// `Next Delivery`
  String get seller_statistics_next_delivery_date {
    return Intl.message(
      'Next Delivery',
      name: 'seller_statistics_next_delivery_date',
      desc: '',
      args: [],
    );
  }

  /// `Earliest`
  String get seller_statistics_earliest {
    return Intl.message(
      'Earliest',
      name: 'seller_statistics_earliest',
      desc: '',
      args: [],
    );
  }

  /// `Loading failed: {error}`
  String seller_statistics_loading_failed(String error) {
    return Intl.message(
      'Loading failed: $error',
      name: 'seller_statistics_loading_failed',
      desc: '',
      args: [error],
    );
  }

  /// `Retry`
  String get seller_statistics_retry {
    return Intl.message(
      'Retry',
      name: 'seller_statistics_retry',
      desc: '',
      args: [],
    );
  }

  /// `Authentication Management`
  String get seller_auth_management_title {
    return Intl.message(
      'Authentication Management',
      name: 'seller_auth_management_title',
      desc: '',
      args: [],
    );
  }

  /// `Certified Items`
  String get seller_auth_management_certified_items {
    return Intl.message(
      'Certified Items',
      name: 'seller_auth_management_certified_items',
      desc: '',
      args: [],
    );
  }

  /// `Open Certification`
  String get seller_auth_management_open_certification {
    return Intl.message(
      'Open Certification',
      name: 'seller_auth_management_open_certification',
      desc: '',
      args: [],
    );
  }

  /// `No certification items`
  String get seller_auth_management_no_items {
    return Intl.message(
      'No certification items',
      name: 'seller_auth_management_no_items',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Status`
  String get seller_auth_management_unknown_status {
    return Intl.message(
      'Unknown Status',
      name: 'seller_auth_management_unknown_status',
      desc: '',
      args: [],
    );
  }

  /// `Certified`
  String get seller_auth_management_certified {
    return Intl.message(
      'Certified',
      name: 'seller_auth_management_certified',
      desc: '',
      args: [],
    );
  }

  /// `Under Review`
  String get seller_auth_management_pending {
    return Intl.message(
      'Under Review',
      name: 'seller_auth_management_pending',
      desc: '',
      args: [],
    );
  }

  /// `Not Approved`
  String get seller_auth_management_rejected {
    return Intl.message(
      'Not Approved',
      name: 'seller_auth_management_rejected',
      desc: '',
      args: [],
    );
  }

  /// `Not Submitted`
  String get seller_auth_management_not_submitted {
    return Intl.message(
      'Not Submitted',
      name: 'seller_auth_management_not_submitted',
      desc: '',
      args: [],
    );
  }

  /// `Server Response Timeout`
  String get seller_auth_management_server_timeout {
    return Intl.message(
      'Server Response Timeout',
      name: 'seller_auth_management_server_timeout',
      desc: '',
      args: [],
    );
  }

  /// `Server took too long to process the request, please try again later`
  String get seller_auth_management_server_timeout_desc {
    return Intl.message(
      'Server took too long to process the request, please try again later',
      name: 'seller_auth_management_server_timeout_desc',
      desc: '',
      args: [],
    );
  }

  /// `Network Connection Error`
  String get seller_auth_management_network_error {
    return Intl.message(
      'Network Connection Error',
      name: 'seller_auth_management_network_error',
      desc: '',
      args: [],
    );
  }

  /// `Unable to connect to server, please check network settings`
  String get seller_auth_management_network_error_desc {
    return Intl.message(
      'Unable to connect to server, please check network settings',
      name: 'seller_auth_management_network_error_desc',
      desc: '',
      args: [],
    );
  }

  /// `Loading Failed`
  String get seller_auth_management_loading_failed {
    return Intl.message(
      'Loading Failed',
      name: 'seller_auth_management_loading_failed',
      desc: '',
      args: [],
    );
  }

  /// `An unknown error occurred, please retry`
  String get seller_auth_management_unknown_error {
    return Intl.message(
      'An unknown error occurred, please retry',
      name: 'seller_auth_management_unknown_error',
      desc: '',
      args: [],
    );
  }

  /// `Troubleshooting Suggestions:`
  String get seller_auth_management_troubleshooting {
    return Intl.message(
      'Troubleshooting Suggestions:',
      name: 'seller_auth_management_troubleshooting',
      desc: '',
      args: [],
    );
  }

  /// `• Check if network connection is stable`
  String get seller_auth_management_check_network {
    return Intl.message(
      '• Check if network connection is stable',
      name: 'seller_auth_management_check_network',
      desc: '',
      args: [],
    );
  }

  /// `• Wait a few minutes and try again`
  String get seller_auth_management_wait_retry {
    return Intl.message(
      '• Wait a few minutes and try again',
      name: 'seller_auth_management_wait_retry',
      desc: '',
      args: [],
    );
  }

  /// `• If the problem persists, please contact customer service`
  String get seller_auth_management_contact_support {
    return Intl.message(
      '• If the problem persists, please contact customer service',
      name: 'seller_auth_management_contact_support',
      desc: '',
      args: [],
    );
  }

  /// `• Check WiFi or mobile data connection`
  String get seller_auth_management_check_wifi {
    return Intl.message(
      '• Check WiFi or mobile data connection',
      name: 'seller_auth_management_check_wifi',
      desc: '',
      args: [],
    );
  }

  /// `• Try switching network environment`
  String get seller_auth_management_switch_network {
    return Intl.message(
      '• Try switching network environment',
      name: 'seller_auth_management_switch_network',
      desc: '',
      args: [],
    );
  }

  /// `• Close and reopen the application`
  String get seller_auth_management_restart_app {
    return Intl.message(
      '• Close and reopen the application',
      name: 'seller_auth_management_restart_app',
      desc: '',
      args: [],
    );
  }

  /// `• Check network connection status`
  String get seller_auth_management_check_connection {
    return Intl.message(
      '• Check network connection status',
      name: 'seller_auth_management_check_connection',
      desc: '',
      args: [],
    );
  }

  /// `• Try again later`
  String get seller_auth_management_try_later {
    return Intl.message(
      '• Try again later',
      name: 'seller_auth_management_try_later',
      desc: '',
      args: [],
    );
  }

  /// `• If the problem persists, please contact technical support`
  String get seller_auth_management_contact_tech {
    return Intl.message(
      '• If the problem persists, please contact technical support',
      name: 'seller_auth_management_contact_tech',
      desc: '',
      args: [],
    );
  }

  /// `Reload`
  String get seller_auth_management_reload {
    return Intl.message(
      'Reload',
      name: 'seller_auth_management_reload',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get seller_auth_management_back {
    return Intl.message(
      'Back',
      name: 'seller_auth_management_back',
      desc: '',
      args: [],
    );
  }

  /// `{type} Certification`
  String seller_auth_application_title(String type) {
    return Intl.message(
      '$type Certification',
      name: 'seller_auth_application_title',
      desc: '',
      args: [type],
    );
  }

  /// `{type} Certification Description`
  String seller_auth_application_desc(String type) {
    return Intl.message(
      '$type Certification Description',
      name: 'seller_auth_application_desc',
      desc: '',
      args: [type],
    );
  }

  /// `Certification review usually takes 1-3 business days, please be patient.`
  String get seller_auth_application_review_time {
    return Intl.message(
      'Certification review usually takes 1-3 business days, please be patient.',
      name: 'seller_auth_application_review_time',
      desc: '',
      args: [],
    );
  }

  /// `Basic Information`
  String get seller_auth_application_basic_info {
    return Intl.message(
      'Basic Information',
      name: 'seller_auth_application_basic_info',
      desc: '',
      args: [],
    );
  }

  /// `Company Name`
  String get seller_auth_application_company_name {
    return Intl.message(
      'Company Name',
      name: 'seller_auth_application_company_name',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the full company name`
  String get seller_auth_application_company_name_hint {
    return Intl.message(
      'Please enter the full company name',
      name: 'seller_auth_application_company_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter company name`
  String get seller_auth_application_company_name_required {
    return Intl.message(
      'Please enter company name',
      name: 'seller_auth_application_company_name_required',
      desc: '',
      args: [],
    );
  }

  /// `Unified Social Credit Code`
  String get seller_auth_application_credit_code {
    return Intl.message(
      'Unified Social Credit Code',
      name: 'seller_auth_application_credit_code',
      desc: '',
      args: [],
    );
  }

  /// `Please enter 18-digit unified social credit code`
  String get seller_auth_application_credit_code_hint {
    return Intl.message(
      'Please enter 18-digit unified social credit code',
      name: 'seller_auth_application_credit_code_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter unified social credit code`
  String get seller_auth_application_credit_code_required {
    return Intl.message(
      'Please enter unified social credit code',
      name: 'seller_auth_application_credit_code_required',
      desc: '',
      args: [],
    );
  }

  /// `Unified social credit code should be 18 digits`
  String get seller_auth_application_credit_code_invalid {
    return Intl.message(
      'Unified social credit code should be 18 digits',
      name: 'seller_auth_application_credit_code_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Company Introduction`
  String get seller_auth_application_company_intro {
    return Intl.message(
      'Company Introduction',
      name: 'seller_auth_application_company_intro',
      desc: '',
      args: [],
    );
  }

  /// `Please briefly describe the company's business and situation`
  String get seller_auth_application_company_intro_hint {
    return Intl.message(
      'Please briefly describe the company\'s business and situation',
      name: 'seller_auth_application_company_intro_hint',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get seller_auth_application_real_name {
    return Intl.message(
      'Name',
      name: 'seller_auth_application_real_name',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your real name`
  String get seller_auth_application_real_name_hint {
    return Intl.message(
      'Please enter your real name',
      name: 'seller_auth_application_real_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter name`
  String get seller_auth_application_real_name_required {
    return Intl.message(
      'Please enter name',
      name: 'seller_auth_application_real_name_required',
      desc: '',
      args: [],
    );
  }

  /// `ID Number`
  String get seller_auth_application_id_number {
    return Intl.message(
      'ID Number',
      name: 'seller_auth_application_id_number',
      desc: '',
      args: [],
    );
  }

  /// `Please enter 18-digit ID number`
  String get seller_auth_application_id_number_hint {
    return Intl.message(
      'Please enter 18-digit ID number',
      name: 'seller_auth_application_id_number_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter ID number`
  String get seller_auth_application_id_number_required {
    return Intl.message(
      'Please enter ID number',
      name: 'seller_auth_application_id_number_required',
      desc: '',
      args: [],
    );
  }

  /// `ID number should be 18 digits`
  String get seller_auth_application_id_number_invalid {
    return Intl.message(
      'ID number should be 18 digits',
      name: 'seller_auth_application_id_number_invalid',
      desc: '',
      args: [],
    );
  }

  /// `School Name`
  String get seller_auth_application_school_name {
    return Intl.message(
      'School Name',
      name: 'seller_auth_application_school_name',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the full school name`
  String get seller_auth_application_school_name_hint {
    return Intl.message(
      'Please enter the full school name',
      name: 'seller_auth_application_school_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter school name`
  String get seller_auth_application_school_name_required {
    return Intl.message(
      'Please enter school name',
      name: 'seller_auth_application_school_name_required',
      desc: '',
      args: [],
    );
  }

  /// `Degree/Education`
  String get seller_auth_application_degree {
    return Intl.message(
      'Degree/Education',
      name: 'seller_auth_application_degree',
      desc: '',
      args: [],
    );
  }

  /// `e.g., Bachelor's, Master's, etc.`
  String get seller_auth_application_degree_hint {
    return Intl.message(
      'e.g., Bachelor\'s, Master\'s, etc.',
      name: 'seller_auth_application_degree_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter degree/education`
  String get seller_auth_application_degree_required {
    return Intl.message(
      'Please enter degree/education',
      name: 'seller_auth_application_degree_required',
      desc: '',
      args: [],
    );
  }

  /// `Major`
  String get seller_auth_application_major {
    return Intl.message(
      'Major',
      name: 'seller_auth_application_major',
      desc: '',
      args: [],
    );
  }

  /// `Please enter major name`
  String get seller_auth_application_major_hint {
    return Intl.message(
      'Please enter major name',
      name: 'seller_auth_application_major_hint',
      desc: '',
      args: [],
    );
  }

  /// `Profession/Position`
  String get seller_auth_application_profession {
    return Intl.message(
      'Profession/Position',
      name: 'seller_auth_application_profession',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your profession or position`
  String get seller_auth_application_profession_hint {
    return Intl.message(
      'Please enter your profession or position',
      name: 'seller_auth_application_profession_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter profession/position`
  String get seller_auth_application_profession_required {
    return Intl.message(
      'Please enter profession/position',
      name: 'seller_auth_application_profession_required',
      desc: '',
      args: [],
    );
  }

  /// `Certificate Number`
  String get seller_auth_application_cert_number {
    return Intl.message(
      'Certificate Number',
      name: 'seller_auth_application_cert_number',
      desc: '',
      args: [],
    );
  }

  /// `Please enter professional qualification certificate number`
  String get seller_auth_application_cert_number_hint {
    return Intl.message(
      'Please enter professional qualification certificate number',
      name: 'seller_auth_application_cert_number_hint',
      desc: '',
      args: [],
    );
  }

  /// `Work Experience`
  String get seller_auth_application_work_experience {
    return Intl.message(
      'Work Experience',
      name: 'seller_auth_application_work_experience',
      desc: '',
      args: [],
    );
  }

  /// `Please briefly describe your work experience`
  String get seller_auth_application_work_experience_hint {
    return Intl.message(
      'Please briefly describe your work experience',
      name: 'seller_auth_application_work_experience_hint',
      desc: '',
      args: [],
    );
  }

  /// `Certification Name`
  String get seller_auth_application_auth_name {
    return Intl.message(
      'Certification Name',
      name: 'seller_auth_application_auth_name',
      desc: '',
      args: [],
    );
  }

  /// `Please enter certification name`
  String get seller_auth_application_auth_name_hint {
    return Intl.message(
      'Please enter certification name',
      name: 'seller_auth_application_auth_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter certification name`
  String get seller_auth_application_auth_name_required {
    return Intl.message(
      'Please enter certification name',
      name: 'seller_auth_application_auth_name_required',
      desc: '',
      args: [],
    );
  }

  /// `Certification Identifier`
  String get seller_auth_application_auth_identifier {
    return Intl.message(
      'Certification Identifier',
      name: 'seller_auth_application_auth_identifier',
      desc: '',
      args: [],
    );
  }

  /// `Please enter certification identifier or number`
  String get seller_auth_application_auth_identifier_hint {
    return Intl.message(
      'Please enter certification identifier or number',
      name: 'seller_auth_application_auth_identifier_hint',
      desc: '',
      args: [],
    );
  }

  /// `Certification Description`
  String get seller_auth_application_auth_description {
    return Intl.message(
      'Certification Description',
      name: 'seller_auth_application_auth_description',
      desc: '',
      args: [],
    );
  }

  /// `Please describe the certification content`
  String get seller_auth_application_auth_description_hint {
    return Intl.message(
      'Please describe the certification content',
      name: 'seller_auth_application_auth_description_hint',
      desc: '',
      args: [],
    );
  }

  /// `Upload Supporting Materials`
  String get seller_auth_application_upload_materials {
    return Intl.message(
      'Upload Supporting Materials',
      name: 'seller_auth_application_upload_materials',
      desc: '',
      args: [],
    );
  }

  /// `Upload File`
  String get seller_auth_application_upload_file {
    return Intl.message(
      'Upload File',
      name: 'seller_auth_application_upload_file',
      desc: '',
      args: [],
    );
  }

  /// `{count} file(s) selected`
  String seller_auth_application_selected_files(int count) {
    return Intl.message(
      '$count file(s) selected',
      name: 'seller_auth_application_selected_files',
      desc: '',
      args: [count],
    );
  }

  /// `Selected Images:`
  String get seller_auth_application_selected_images {
    return Intl.message(
      'Selected Images:',
      name: 'seller_auth_application_selected_images',
      desc: '',
      args: [],
    );
  }

  /// `Load Failed`
  String get seller_auth_application_load_failed {
    return Intl.message(
      'Load Failed',
      name: 'seller_auth_application_load_failed',
      desc: '',
      args: [],
    );
  }

  /// `Please upload clear photos of both sides of your ID card, ensuring information is clearly visible without obstruction or alteration`
  String get seller_auth_application_id_upload_hint {
    return Intl.message(
      'Please upload clear photos of both sides of your ID card, ensuring information is clearly visible without obstruction or alteration',
      name: 'seller_auth_application_id_upload_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please upload educational certificates, degree certificates and other supporting materials with complete information`
  String get seller_auth_application_education_upload_hint {
    return Intl.message(
      'Please upload educational certificates, degree certificates and other supporting materials with complete information',
      name: 'seller_auth_application_education_upload_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please upload professional qualification certificates, professional skill certificates and other supporting materials`
  String get seller_auth_application_profession_upload_hint {
    return Intl.message(
      'Please upload professional qualification certificates, professional skill certificates and other supporting materials',
      name: 'seller_auth_application_profession_upload_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please upload business license, organization code certificate and other enterprise qualification certificates`
  String get seller_auth_application_company_upload_hint {
    return Intl.message(
      'Please upload business license, organization code certificate and other enterprise qualification certificates',
      name: 'seller_auth_application_company_upload_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please upload relevant supporting materials, ensuring images are clear and information is complete`
  String get seller_auth_application_default_upload_hint {
    return Intl.message(
      'Please upload relevant supporting materials, ensuring images are clear and information is complete',
      name: 'seller_auth_application_default_upload_hint',
      desc: '',
      args: [],
    );
  }

  /// `I have read and agree to`
  String get seller_auth_application_agreement_read {
    return Intl.message(
      'I have read and agree to',
      name: 'seller_auth_application_agreement_read',
      desc: '',
      args: [],
    );
  }

  /// `Certification Service Agreement`
  String get seller_auth_application_agreement_link {
    return Intl.message(
      'Certification Service Agreement',
      name: 'seller_auth_application_agreement_link',
      desc: '',
      args: [],
    );
  }

  /// `, and guarantee that the information provided is true and valid`
  String get seller_auth_application_agreement_guarantee {
    return Intl.message(
      ', and guarantee that the information provided is true and valid',
      name: 'seller_auth_application_agreement_guarantee',
      desc: '',
      args: [],
    );
  }

  /// `Certification Service Agreement`
  String get seller_auth_application_agreement_title {
    return Intl.message(
      'Certification Service Agreement',
      name: 'seller_auth_application_agreement_title',
      desc: '',
      args: [],
    );
  }

  /// `This agreement is a legal agreement between you and the DSKK platform regarding certification services. Please read the following terms carefully to ensure you fully understand all rights and obligations in this agreement.\n\n1. Service Content\nThe DSKK platform provides certification services aimed at verifying the authenticity of the identity, qualifications and other information you provide, and improving your credibility on the platform.\n\n2. User Obligations\n1. You shall provide true, accurate and complete certification information and materials.\n2. You shall ensure that the certification materials provided do not infringe on any third party's legitimate rights and interests.\n\n3. Platform Rights and Obligations\n1. The platform has the right to review the certification information and materials you provide.\n2. The platform will complete the review within a reasonable time and notify you of the review results.`
  String get seller_auth_application_agreement_content {
    return Intl.message(
      'This agreement is a legal agreement between you and the DSKK platform regarding certification services. Please read the following terms carefully to ensure you fully understand all rights and obligations in this agreement.\n\n1. Service Content\nThe DSKK platform provides certification services aimed at verifying the authenticity of the identity, qualifications and other information you provide, and improving your credibility on the platform.\n\n2. User Obligations\n1. You shall provide true, accurate and complete certification information and materials.\n2. You shall ensure that the certification materials provided do not infringe on any third party\'s legitimate rights and interests.\n\n3. Platform Rights and Obligations\n1. The platform has the right to review the certification information and materials you provide.\n2. The platform will complete the review within a reasonable time and notify you of the review results.',
      name: 'seller_auth_application_agreement_content',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get seller_auth_application_agreement_close {
    return Intl.message(
      'Close',
      name: 'seller_auth_application_agreement_close',
      desc: '',
      args: [],
    );
  }

  /// `Agree`
  String get seller_auth_application_agreement_agree {
    return Intl.message(
      'Agree',
      name: 'seller_auth_application_agreement_agree',
      desc: '',
      args: [],
    );
  }

  /// `Submit Certification Application`
  String get seller_auth_application_submit {
    return Intl.message(
      'Submit Certification Application',
      name: 'seller_auth_application_submit',
      desc: '',
      args: [],
    );
  }

  /// `Please check if the form is filled correctly`
  String get seller_auth_application_check_form {
    return Intl.message(
      'Please check if the form is filled correctly',
      name: 'seller_auth_application_check_form',
      desc: '',
      args: [],
    );
  }

  /// `Submission Successful`
  String get seller_auth_application_submit_success {
    return Intl.message(
      'Submission Successful',
      name: 'seller_auth_application_submit_success',
      desc: '',
      args: [],
    );
  }

  /// `Your certification application has been submitted. We will complete the review within 1-3 business days. Please be patient.`
  String get seller_auth_application_submit_success_desc {
    return Intl.message(
      'Your certification application has been submitted. We will complete the review within 1-3 business days. Please be patient.',
      name: 'seller_auth_application_submit_success_desc',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get seller_auth_application_ok {
    return Intl.message(
      'OK',
      name: 'seller_auth_application_ok',
      desc: '',
      args: [],
    );
  }

  /// `File selection failed: {error}`
  String seller_auth_application_select_file_failed(String error) {
    return Intl.message(
      'File selection failed: $error',
      name: 'seller_auth_application_select_file_failed',
      desc: '',
      args: [error],
    );
  }

  /// `Product Management`
  String get product_management_title {
    return Intl.message(
      'Product Management',
      name: 'product_management_title',
      desc: '',
      args: [],
    );
  }

  /// `On Sale`
  String get product_management_tab_on_sale {
    return Intl.message(
      'On Sale',
      name: 'product_management_tab_on_sale',
      desc: '',
      args: [],
    );
  }

  /// `Drafts`
  String get product_management_tab_draft {
    return Intl.message(
      'Drafts',
      name: 'product_management_tab_draft',
      desc: '',
      args: [],
    );
  }

  /// `Off Shelf`
  String get product_management_tab_off_shelf {
    return Intl.message(
      'Off Shelf',
      name: 'product_management_tab_off_shelf',
      desc: '',
      args: [],
    );
  }

  /// `Off Shelf`
  String get product_management_action_off_shelf {
    return Intl.message(
      'Off Shelf',
      name: 'product_management_action_off_shelf',
      desc: '',
      args: [],
    );
  }

  /// `On Shelf`
  String get product_management_action_on_shelf {
    return Intl.message(
      'On Shelf',
      name: 'product_management_action_on_shelf',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get product_management_action_edit {
    return Intl.message(
      'Edit',
      name: 'product_management_action_edit',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get product_management_action_delete {
    return Intl.message(
      'Delete',
      name: 'product_management_action_delete',
      desc: '',
      args: [],
    );
  }

  /// `Publish`
  String get product_management_action_publish {
    return Intl.message(
      'Publish',
      name: 'product_management_action_publish',
      desc: '',
      args: [],
    );
  }

  /// `Resubmit`
  String get product_management_action_resubmit {
    return Intl.message(
      'Resubmit',
      name: 'product_management_action_resubmit',
      desc: '',
      args: [],
    );
  }

  /// `Under Review`
  String get product_management_status_reviewing {
    return Intl.message(
      'Under Review',
      name: 'product_management_status_reviewing',
      desc: '',
      args: [],
    );
  }

  /// `Review Failed`
  String get product_management_status_rejected {
    return Intl.message(
      'Review Failed',
      name: 'product_management_status_rejected',
      desc: '',
      args: [],
    );
  }

  /// `On Shelf`
  String get product_management_status_on_shelf {
    return Intl.message(
      'On Shelf',
      name: 'product_management_status_on_shelf',
      desc: '',
      args: [],
    );
  }

  /// `Off Shelf`
  String get product_management_status_off_shelf {
    return Intl.message(
      'Off Shelf',
      name: 'product_management_status_off_shelf',
      desc: '',
      args: [],
    );
  }

  /// `Draft`
  String get product_management_status_draft {
    return Intl.message(
      'Draft',
      name: 'product_management_status_draft',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for Review`
  String get product_management_status_waiting_review {
    return Intl.message(
      'Waiting for Review',
      name: 'product_management_status_waiting_review',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get product_management_status_unknown {
    return Intl.message(
      'Unknown',
      name: 'product_management_status_unknown',
      desc: '',
      args: [],
    );
  }

  /// `Stock`
  String get product_management_stock_label {
    return Intl.message(
      'Stock',
      name: 'product_management_stock_label',
      desc: '',
      args: [],
    );
  }

  /// `Sales`
  String get product_management_sales_label {
    return Intl.message(
      'Sales',
      name: 'product_management_sales_label',
      desc: '',
      args: [],
    );
  }

  /// `Create Product`
  String get product_management_create_product {
    return Intl.message(
      'Create Product',
      name: 'product_management_create_product',
      desc: '',
      args: [],
    );
  }

  /// `No more products`
  String get product_management_no_more_products {
    return Intl.message(
      'No more products',
      name: 'product_management_no_more_products',
      desc: '',
      args: [],
    );
  }

  /// `No products on sale`
  String get product_management_empty_on_sale {
    return Intl.message(
      'No products on sale',
      name: 'product_management_empty_on_sale',
      desc: '',
      args: [],
    );
  }

  /// `No draft products`
  String get product_management_empty_draft {
    return Intl.message(
      'No draft products',
      name: 'product_management_empty_draft',
      desc: '',
      args: [],
    );
  }

  /// `No off-shelf products`
  String get product_management_empty_off_shelf {
    return Intl.message(
      'No off-shelf products',
      name: 'product_management_empty_off_shelf',
      desc: '',
      args: [],
    );
  }

  /// `No product data`
  String get product_management_empty_default {
    return Intl.message(
      'No product data',
      name: 'product_management_empty_default',
      desc: '',
      args: [],
    );
  }

  /// `Draft products need to be published before preview`
  String get product_management_draft_preview_hint {
    return Intl.message(
      'Draft products need to be published before preview',
      name: 'product_management_draft_preview_hint',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Off Shelf`
  String get product_management_confirm_off_shelf_title {
    return Intl.message(
      'Confirm Off Shelf',
      name: 'product_management_confirm_off_shelf_title',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to take the product "{name}" off shelf?`
  String product_management_confirm_off_shelf_message(String name) {
    return Intl.message(
      'Are you sure you want to take the product "$name" off shelf?',
      name: 'product_management_confirm_off_shelf_message',
      desc: '',
      args: [name],
    );
  }

  /// `After off shelf:`
  String get product_management_confirm_off_shelf_desc {
    return Intl.message(
      'After off shelf:',
      name: 'product_management_confirm_off_shelf_desc',
      desc: '',
      args: [],
    );
  }

  /// `• Buyers will not be able to see or purchase this product`
  String get product_management_confirm_off_shelf_point1 {
    return Intl.message(
      '• Buyers will not be able to see or purchase this product',
      name: 'product_management_confirm_off_shelf_point1',
      desc: '',
      args: [],
    );
  }

  /// `• You can put it back on shelf at any time`
  String get product_management_confirm_off_shelf_point2 {
    return Intl.message(
      '• You can put it back on shelf at any time',
      name: 'product_management_confirm_off_shelf_point2',
      desc: '',
      args: [],
    );
  }

  /// `• Product data will be retained`
  String get product_management_confirm_off_shelf_point3 {
    return Intl.message(
      '• Product data will be retained',
      name: 'product_management_confirm_off_shelf_point3',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Delete`
  String get product_management_confirm_delete_title {
    return Intl.message(
      'Confirm Delete',
      name: 'product_management_confirm_delete_title',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this product? This action cannot be undone.`
  String get product_management_confirm_delete_message {
    return Intl.message(
      'Are you sure you want to delete this product? This action cannot be undone.',
      name: 'product_management_confirm_delete_message',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get product_management_cancel {
    return Intl.message(
      'Cancel',
      name: 'product_management_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Off Shelf`
  String get product_management_confirm {
    return Intl.message(
      'Confirm Off Shelf',
      name: 'product_management_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get product_management_delete {
    return Intl.message(
      'Delete',
      name: 'product_management_delete',
      desc: '',
      args: [],
    );
  }

  /// `Create Product`
  String get product_edit_title_create {
    return Intl.message(
      'Create Product',
      name: 'product_edit_title_create',
      desc: '',
      args: [],
    );
  }

  /// `Edit Product`
  String get product_edit_title_edit {
    return Intl.message(
      'Edit Product',
      name: 'product_edit_title_edit',
      desc: '',
      args: [],
    );
  }

  /// `Basic Information`
  String get product_edit_basic_info {
    return Intl.message(
      'Basic Information',
      name: 'product_edit_basic_info',
      desc: '',
      args: [],
    );
  }

  /// `Product Name`
  String get product_edit_product_name {
    return Intl.message(
      'Product Name',
      name: 'product_edit_product_name',
      desc: '',
      args: [],
    );
  }

  /// `Please enter product name`
  String get product_edit_product_name_hint {
    return Intl.message(
      'Please enter product name',
      name: 'product_edit_product_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Product Description`
  String get product_edit_product_description {
    return Intl.message(
      'Product Description',
      name: 'product_edit_product_description',
      desc: '',
      args: [],
    );
  }

  /// `Please enter product description`
  String get product_edit_product_description_hint {
    return Intl.message(
      'Please enter product description',
      name: 'product_edit_product_description_hint',
      desc: '',
      args: [],
    );
  }

  /// `Product Price`
  String get product_edit_product_price {
    return Intl.message(
      'Product Price',
      name: 'product_edit_product_price',
      desc: '',
      args: [],
    );
  }

  /// `Product Images`
  String get product_edit_product_images {
    return Intl.message(
      'Product Images',
      name: 'product_edit_product_images',
      desc: '',
      args: [],
    );
  }

  /// `Add Image`
  String get product_edit_add_image {
    return Intl.message(
      'Add Image',
      name: 'product_edit_add_image',
      desc: '',
      args: [],
    );
  }

  /// `Uploading...`
  String get product_edit_uploading {
    return Intl.message(
      'Uploading...',
      name: 'product_edit_uploading',
      desc: '',
      args: [],
    );
  }

  /// `Service Tier Settings`
  String get product_edit_service_tiers {
    return Intl.message(
      'Service Tier Settings',
      name: 'product_edit_service_tiers',
      desc: '',
      args: [],
    );
  }

  /// `Detail Introduction`
  String get product_edit_detail_intro {
    return Intl.message(
      'Detail Introduction',
      name: 'product_edit_detail_intro',
      desc: '',
      args: [],
    );
  }

  /// `Save Draft`
  String get product_edit_save_draft {
    return Intl.message(
      'Save Draft',
      name: 'product_edit_save_draft',
      desc: '',
      args: [],
    );
  }

  /// `Publish Product`
  String get product_edit_publish_product {
    return Intl.message(
      'Publish Product',
      name: 'product_edit_publish_product',
      desc: '',
      args: [],
    );
  }

  /// `Preview Product`
  String get product_edit_preview_product {
    return Intl.message(
      'Preview Product',
      name: 'product_edit_preview_product',
      desc: '',
      args: [],
    );
  }

  /// `Please upload at least one product image`
  String get product_edit_at_least_one_image {
    return Intl.message(
      'Please upload at least one product image',
      name: 'product_edit_at_least_one_image',
      desc: '',
      args: [],
    );
  }

  /// `Save Draft`
  String get product_edit_save_draft_dialog_title {
    return Intl.message(
      'Save Draft',
      name: 'product_edit_save_draft_dialog_title',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to save as draft?`
  String get product_edit_save_draft_dialog_message {
    return Intl.message(
      'Do you want to save as draft?',
      name: 'product_edit_save_draft_dialog_message',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get product_edit_save_draft_dialog_confirm {
    return Intl.message(
      'Save',
      name: 'product_edit_save_draft_dialog_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Edit Product Attributes`
  String get product_edit_edit_attribute {
    return Intl.message(
      'Edit Product Attributes',
      name: 'product_edit_edit_attribute',
      desc: '',
      args: [],
    );
  }

  /// `Please enter product name`
  String get product_edit_validation_name_required {
    return Intl.message(
      'Please enter product name',
      name: 'product_edit_validation_name_required',
      desc: '',
      args: [],
    );
  }

  /// `Please enter product description`
  String get product_edit_validation_description_required {
    return Intl.message(
      'Please enter product description',
      name: 'product_edit_validation_description_required',
      desc: '',
      args: [],
    );
  }

  /// `Please upload at least one product image`
  String get product_edit_validation_image_required {
    return Intl.message(
      'Please upload at least one product image',
      name: 'product_edit_validation_image_required',
      desc: '',
      args: [],
    );
  }

  /// `Current Seller`
  String get product_preview_current_seller {
    return Intl.message(
      'Current Seller',
      name: 'product_preview_current_seller',
      desc: '',
      args: [],
    );
  }

  /// `Seller User`
  String get product_preview_seller_user {
    return Intl.message(
      'Seller User',
      name: 'product_preview_seller_user',
      desc: '',
      args: [],
    );
  }

  /// `Success Cases`
  String get product_edit_success_cases {
    return Intl.message(
      'Success Cases',
      name: 'product_edit_success_cases',
      desc: '',
      args: [],
    );
  }

  /// `Add Success Case`
  String get product_edit_add_success_case {
    return Intl.message(
      'Add Success Case',
      name: 'product_edit_add_success_case',
      desc: '',
      args: [],
    );
  }

  /// `Edit Success Case`
  String get product_edit_edit_success_case {
    return Intl.message(
      'Edit Success Case',
      name: 'product_edit_edit_success_case',
      desc: '',
      args: [],
    );
  }

  /// `Uploading {uploaded}/{total}`
  String product_edit_uploading_progress(int uploaded, int total) {
    return Intl.message(
      'Uploading $uploaded/$total',
      name: 'product_edit_uploading_progress',
      desc: '',
      args: [uploaded, total],
    );
  }

  /// `Please enter information label`
  String get product_edit_please_enter_label {
    return Intl.message(
      'Please enter information label',
      name: 'product_edit_please_enter_label',
      desc: '',
      args: [],
    );
  }

  /// `Please enter attribute name`
  String get product_edit_please_enter_attribute_name {
    return Intl.message(
      'Please enter attribute name',
      name: 'product_edit_please_enter_attribute_name',
      desc: '',
      args: [],
    );
  }

  /// `Please enter attribute name`
  String get product_edit_attribute_name_hint {
    return Intl.message(
      'Please enter attribute name',
      name: 'product_edit_attribute_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `e.g., Please select color, Please enter model`
  String get product_edit_placeholder_hint {
    return Intl.message(
      'e.g., Please select color, Please enter model',
      name: 'product_edit_placeholder_hint',
      desc: '',
      args: [],
    );
  }

  /// `Placeholder Text`
  String get product_edit_placeholder_label {
    return Intl.message(
      'Placeholder Text',
      name: 'product_edit_placeholder_label',
      desc: '',
      args: [],
    );
  }

  /// `Product Preview`
  String get product_edit_product_preview_title {
    return Intl.message(
      'Product Preview',
      name: 'product_edit_product_preview_title',
      desc: '',
      args: [],
    );
  }

  /// `Publish Service`
  String get product_edit_publish_service {
    return Intl.message(
      'Publish Service',
      name: 'product_edit_publish_service',
      desc: '',
      args: [],
    );
  }

  /// `Edit Service`
  String get product_edit_edit_service {
    return Intl.message(
      'Edit Service',
      name: 'product_edit_edit_service',
      desc: '',
      args: [],
    );
  }

  /// `Max {max} characters`
  String product_edit_max_characters(int max) {
    return Intl.message(
      'Max $max characters',
      name: 'product_edit_max_characters',
      desc: '',
      args: [max],
    );
  }

  /// `After-sales Review`
  String get after_sales_review_title {
    return Intl.message(
      'After-sales Review',
      name: 'after_sales_review_title',
      desc: '',
      args: [],
    );
  }

  /// `After-sales Details`
  String get after_sales_detail_title {
    return Intl.message(
      'After-sales Details',
      name: 'after_sales_detail_title',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get after_sales_refresh {
    return Intl.message(
      'Refresh',
      name: 'after_sales_refresh',
      desc: '',
      args: [],
    );
  }

  /// `No pending after-sales requests`
  String get after_sales_no_pending {
    return Intl.message(
      'No pending after-sales requests',
      name: 'after_sales_no_pending',
      desc: '',
      args: [],
    );
  }

  /// `Load failed, please try again`
  String get after_sales_load_failed {
    return Intl.message(
      'Load failed, please try again',
      name: 'after_sales_load_failed',
      desc: '',
      args: [],
    );
  }

  /// `After-sales request not found`
  String get after_sales_not_found {
    return Intl.message(
      'After-sales request not found',
      name: 'after_sales_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Order Number`
  String get after_sales_order_number {
    return Intl.message(
      'Order Number',
      name: 'after_sales_order_number',
      desc: '',
      args: [],
    );
  }

  /// `Request Type`
  String get after_sales_apply_type {
    return Intl.message(
      'Request Type',
      name: 'after_sales_apply_type',
      desc: '',
      args: [],
    );
  }

  /// `Request Time`
  String get after_sales_apply_time {
    return Intl.message(
      'Request Time',
      name: 'after_sales_apply_time',
      desc: '',
      args: [],
    );
  }

  /// `Refund Amount`
  String get after_sales_refund_amount {
    return Intl.message(
      'Refund Amount',
      name: 'after_sales_refund_amount',
      desc: '',
      args: [],
    );
  }

  /// `Refund Type`
  String get after_sales_refund_type {
    return Intl.message(
      'Refund Type',
      name: 'after_sales_refund_type',
      desc: '',
      args: [],
    );
  }

  /// `Request Reason`
  String get after_sales_apply_reason {
    return Intl.message(
      'Request Reason',
      name: 'after_sales_apply_reason',
      desc: '',
      args: [],
    );
  }

  /// `Image Evidence`
  String get after_sales_image_evidence {
    return Intl.message(
      'Image Evidence',
      name: 'after_sales_image_evidence',
      desc: '',
      args: [],
    );
  }

  /// `Image View`
  String get after_sales_image_view {
    return Intl.message(
      'Image View',
      name: 'after_sales_image_view',
      desc: '',
      args: [],
    );
  }

  /// `Image load failed`
  String get after_sales_image_load_failed {
    return Intl.message(
      'Image load failed',
      name: 'after_sales_image_load_failed',
      desc: '',
      args: [],
    );
  }

  /// `Reject`
  String get after_sales_reject {
    return Intl.message(
      'Reject',
      name: 'after_sales_reject',
      desc: '',
      args: [],
    );
  }

  /// `Approve`
  String get after_sales_agree {
    return Intl.message(
      'Approve',
      name: 'after_sales_agree',
      desc: '',
      args: [],
    );
  }

  /// `Reject Request`
  String get after_sales_reject_application {
    return Intl.message(
      'Reject Request',
      name: 'after_sales_reject_application',
      desc: '',
      args: [],
    );
  }

  /// `Approve Request`
  String get after_sales_agree_application {
    return Intl.message(
      'Approve Request',
      name: 'after_sales_agree_application',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get after_sales_confirm {
    return Intl.message(
      'Confirm',
      name: 'after_sales_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get after_sales_cancel {
    return Intl.message(
      'Cancel',
      name: 'after_sales_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get after_sales_confirm_title {
    return Intl.message(
      'Confirm',
      name: 'after_sales_confirm_title',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to approve this after-sales request?`
  String get after_sales_confirm_message {
    return Intl.message(
      'Are you sure you want to approve this after-sales request?',
      name: 'after_sales_confirm_message',
      desc: '',
      args: [],
    );
  }

  /// `Rejection Reason`
  String get after_sales_reject_reason {
    return Intl.message(
      'Rejection Reason',
      name: 'after_sales_reject_reason',
      desc: '',
      args: [],
    );
  }

  /// `Please enter rejection reason`
  String get after_sales_reject_reason_hint {
    return Intl.message(
      'Please enter rejection reason',
      name: 'after_sales_reject_reason_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter rejection reason`
  String get after_sales_reject_reason_required {
    return Intl.message(
      'Please enter rejection reason',
      name: 'after_sales_reject_reason_required',
      desc: '',
      args: [],
    );
  }

  /// `Refund Only`
  String get after_sales_type_refund_only {
    return Intl.message(
      'Refund Only',
      name: 'after_sales_type_refund_only',
      desc: '',
      args: [],
    );
  }

  /// `Return & Refund`
  String get after_sales_type_refund_return {
    return Intl.message(
      'Return & Refund',
      name: 'after_sales_type_refund_return',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Type`
  String get after_sales_type_unknown {
    return Intl.message(
      'Unknown Type',
      name: 'after_sales_type_unknown',
      desc: '',
      args: [],
    );
  }

  /// `Pending Review`
  String get after_sales_status_wait_audit {
    return Intl.message(
      'Pending Review',
      name: 'after_sales_status_wait_audit',
      desc: '',
      args: [],
    );
  }

  /// `Rejected`
  String get after_sales_status_refused {
    return Intl.message(
      'Rejected',
      name: 'after_sales_status_refused',
      desc: '',
      args: [],
    );
  }

  /// `Approved`
  String get after_sales_status_audit_pass {
    return Intl.message(
      'Approved',
      name: 'after_sales_status_audit_pass',
      desc: '',
      args: [],
    );
  }

  /// `Buyer Shipped`
  String get after_sales_status_buyer_shipped {
    return Intl.message(
      'Buyer Shipped',
      name: 'after_sales_status_buyer_shipped',
      desc: '',
      args: [],
    );
  }

  /// `Seller Received`
  String get after_sales_status_seller_received {
    return Intl.message(
      'Seller Received',
      name: 'after_sales_status_seller_received',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get after_sales_status_finished {
    return Intl.message(
      'Completed',
      name: 'after_sales_status_finished',
      desc: '',
      args: [],
    );
  }

  /// `Canceled`
  String get after_sales_status_canceled {
    return Intl.message(
      'Canceled',
      name: 'after_sales_status_canceled',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Status`
  String get after_sales_status_unknown {
    return Intl.message(
      'Unknown Status',
      name: 'after_sales_status_unknown',
      desc: '',
      args: [],
    );
  }

  /// `Time Management`
  String get time_management_title {
    return Intl.message(
      'Time Management',
      name: 'time_management_title',
      desc: '',
      args: [],
    );
  }

  /// `Current Status`
  String get time_management_current_status {
    return Intl.message(
      'Current Status',
      name: 'time_management_current_status',
      desc: '',
      args: [],
    );
  }

  /// `Online`
  String get time_management_online {
    return Intl.message(
      'Online',
      name: 'time_management_online',
      desc: '',
      args: [],
    );
  }

  /// `Offline`
  String get time_management_offline {
    return Intl.message(
      'Offline',
      name: 'time_management_offline',
      desc: '',
      args: [],
    );
  }

  /// `Online Status Description`
  String get time_management_online_status_description {
    return Intl.message(
      'Online Status Description',
      name: 'time_management_online_status_description',
      desc: '',
      args: [],
    );
  }

  /// `Offline Status Description`
  String get time_management_offline_status_description {
    return Intl.message(
      'Offline Status Description',
      name: 'time_management_offline_status_description',
      desc: '',
      args: [],
    );
  }

  /// `You are currently online. Buyers can send you messages and you will receive notifications for new messages. Please ensure timely responses to buyer messages as maintaining a good response rate helps improve your service quality rating.`
  String get time_management_online_description {
    return Intl.message(
      'You are currently online. Buyers can send you messages and you will receive notifications for new messages. Please ensure timely responses to buyer messages as maintaining a good response rate helps improve your service quality rating.',
      name: 'time_management_online_description',
      desc: '',
      args: [],
    );
  }

  /// `You are currently offline. Buyers can still send you messages but the system will inform them that you are temporarily unavailable. You will still receive notifications for new messages but may not be able to respond immediately. Staying offline for extended periods may affect your order efficiency.`
  String get time_management_offline_description {
    return Intl.message(
      'You are currently offline. Buyers can still send you messages but the system will inform them that you are temporarily unavailable. You will still receive notifications for new messages but may not be able to respond immediately. Staying offline for extended periods may affect your order efficiency.',
      name: 'time_management_offline_description',
      desc: '',
      args: [],
    );
  }

  /// `Save Settings`
  String get time_management_save_settings {
    return Intl.message(
      'Save Settings',
      name: 'time_management_save_settings',
      desc: '',
      args: [],
    );
  }

  /// `Settings Saved`
  String get time_management_settings_saved {
    return Intl.message(
      'Settings Saved',
      name: 'time_management_settings_saved',
      desc: '',
      args: [],
    );
  }

  /// `Load Failed`
  String get time_management_load_failed {
    return Intl.message(
      'Load Failed',
      name: 'time_management_load_failed',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get time_management_retry {
    return Intl.message(
      'Retry',
      name: 'time_management_retry',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Status`
  String get time_management_unknown_status {
    return Intl.message(
      'Unknown Status',
      name: 'time_management_unknown_status',
      desc: '',
      args: [],
    );
  }

  /// `Auto Reply Settings`
  String get auto_reply_title {
    return Intl.message(
      'Auto Reply Settings',
      name: 'auto_reply_title',
      desc: '',
      args: [],
    );
  }

  /// `Auto Reply`
  String get auto_reply_enable {
    return Intl.message(
      'Auto Reply',
      name: 'auto_reply_enable',
      desc: '',
      args: [],
    );
  }

  /// `Reply Content`
  String get auto_reply_content {
    return Intl.message(
      'Reply Content',
      name: 'auto_reply_content',
      desc: '',
      args: [],
    );
  }

  /// `Please enter auto reply content`
  String get auto_reply_content_hint {
    return Intl.message(
      'Please enter auto reply content',
      name: 'auto_reply_content_hint',
      desc: '',
      args: [],
    );
  }

  /// `When customers send messages, the system will automatically reply with this content`
  String get auto_reply_content_description {
    return Intl.message(
      'When customers send messages, the system will automatically reply with this content',
      name: 'auto_reply_content_description',
      desc: '',
      args: [],
    );
  }

  /// `Save Settings`
  String get auto_reply_save_settings {
    return Intl.message(
      'Save Settings',
      name: 'auto_reply_save_settings',
      desc: '',
      args: [],
    );
  }

  /// `Settings Saved`
  String get auto_reply_settings_saved {
    return Intl.message(
      'Settings Saved',
      name: 'auto_reply_settings_saved',
      desc: '',
      args: [],
    );
  }

  /// `Reply content cannot be empty`
  String get auto_reply_content_required {
    return Intl.message(
      'Reply content cannot be empty',
      name: 'auto_reply_content_required',
      desc: '',
      args: [],
    );
  }

  /// `Load failed, please try again`
  String get auto_reply_load_failed {
    return Intl.message(
      'Load failed, please try again',
      name: 'auto_reply_load_failed',
      desc: '',
      args: [],
    );
  }

  /// `Order Delivery`
  String get order_delivery_title {
    return Intl.message(
      'Order Delivery',
      name: 'order_delivery_title',
      desc: '',
      args: [],
    );
  }

  /// `Order Delivery: {orderSn}`
  String order_delivery_title_with_sn(String orderSn) {
    return Intl.message(
      'Order Delivery: $orderSn',
      name: 'order_delivery_title_with_sn',
      desc: '',
      args: [orderSn],
    );
  }

  /// `Submitting delivery content...`
  String get order_delivery_submitting {
    return Intl.message(
      'Submitting delivery content...',
      name: 'order_delivery_submitting',
      desc: '',
      args: [],
    );
  }

  /// `Load failed, please try again`
  String get order_delivery_load_failed {
    return Intl.message(
      'Load failed, please try again',
      name: 'order_delivery_load_failed',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Instructions`
  String get order_delivery_instruction_title {
    return Intl.message(
      'Delivery Instructions',
      name: 'order_delivery_instruction_title',
      desc: '',
      args: [],
    );
  }

  /// `Please submit your delivery content for this order. You can provide detailed instructions and attach relevant files to ensure the buyer clearly understands the services or products you provide.`
  String get order_delivery_instruction_content {
    return Intl.message(
      'Please submit your delivery content for this order. You can provide detailed instructions and attach relevant files to ensure the buyer clearly understands the services or products you provide.',
      name: 'order_delivery_instruction_content',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Content Description:`
  String get order_delivery_content_label {
    return Intl.message(
      'Delivery Content Description:',
      name: 'order_delivery_content_label',
      desc: '',
      args: [],
    );
  }

  /// `Please describe your delivery content...`
  String get order_delivery_content_hint {
    return Intl.message(
      'Please describe your delivery content...',
      name: 'order_delivery_content_hint',
      desc: '',
      args: [],
    );
  }

  /// `Attachment Files:`
  String get order_delivery_attachments_label {
    return Intl.message(
      'Attachment Files:',
      name: 'order_delivery_attachments_label',
      desc: '',
      args: [],
    );
  }

  /// `Submit Delivery`
  String get order_delivery_submit_button {
    return Intl.message(
      'Submit Delivery',
      name: 'order_delivery_submit_button',
      desc: '',
      args: [],
    );
  }

  /// `Please enter delivery content description`
  String get order_delivery_content_required {
    return Intl.message(
      'Please enter delivery content description',
      name: 'order_delivery_content_required',
      desc: '',
      args: [],
    );
  }

  /// `Delivery content submitted successfully`
  String get order_delivery_submit_success {
    return Intl.message(
      'Delivery content submitted successfully',
      name: 'order_delivery_submit_success',
      desc: '',
      args: [],
    );
  }

  /// `Logistics Company`
  String get order_delivery_logistics_company {
    return Intl.message(
      'Logistics Company',
      name: 'order_delivery_logistics_company',
      desc: '',
      args: [],
    );
  }

  /// `Tracking Number`
  String get order_delivery_tracking_number {
    return Intl.message(
      'Tracking Number',
      name: 'order_delivery_tracking_number',
      desc: '',
      args: [],
    );
  }

  /// `Shipping Address`
  String get order_delivery_shipping_address {
    return Intl.message(
      'Shipping Address',
      name: 'order_delivery_shipping_address',
      desc: '',
      args: [],
    );
  }

  /// `Receiving Address`
  String get order_delivery_receiving_address {
    return Intl.message(
      'Receiving Address',
      name: 'order_delivery_receiving_address',
      desc: '',
      args: [],
    );
  }

  /// `Pending Shipment`
  String get order_delivery_status_pending {
    return Intl.message(
      'Pending Shipment',
      name: 'order_delivery_status_pending',
      desc: '',
      args: [],
    );
  }

  /// `Shipped`
  String get order_delivery_status_shipped {
    return Intl.message(
      'Shipped',
      name: 'order_delivery_status_shipped',
      desc: '',
      args: [],
    );
  }

  /// `Received`
  String get order_delivery_status_received {
    return Intl.message(
      'Received',
      name: 'order_delivery_status_received',
      desc: '',
      args: [],
    );
  }

  /// `In Transit`
  String get order_delivery_status_in_transit {
    return Intl.message(
      'In Transit',
      name: 'order_delivery_status_in_transit',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Shipment`
  String get order_delivery_confirm_shipment {
    return Intl.message(
      'Confirm Shipment',
      name: 'order_delivery_confirm_shipment',
      desc: '',
      args: [],
    );
  }

  /// `View Details`
  String get order_delivery_view_details {
    return Intl.message(
      'View Details',
      name: 'order_delivery_view_details',
      desc: '',
      args: [],
    );
  }

  /// `No pending orders`
  String get order_delivery_no_pending_orders {
    return Intl.message(
      'No pending orders',
      name: 'order_delivery_no_pending_orders',
      desc: '',
      args: [],
    );
  }

  /// `Notification Center`
  String get notification_center_title {
    return Intl.message(
      'Notification Center',
      name: 'notification_center_title',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get notification_tab_all {
    return Intl.message(
      'All',
      name: 'notification_tab_all',
      desc: '',
      args: [],
    );
  }

  /// `Orders`
  String get notification_tab_order {
    return Intl.message(
      'Orders',
      name: 'notification_tab_order',
      desc: '',
      args: [],
    );
  }

  /// `System`
  String get notification_tab_system {
    return Intl.message(
      'System',
      name: 'notification_tab_system',
      desc: '',
      args: [],
    );
  }

  /// `After-sales`
  String get notification_tab_refund {
    return Intl.message(
      'After-sales',
      name: 'notification_tab_refund',
      desc: '',
      args: [],
    );
  }

  /// `Messages`
  String get notification_tab_message {
    return Intl.message(
      'Messages',
      name: 'notification_tab_message',
      desc: '',
      args: [],
    );
  }

  /// `Order Notification`
  String get notification_type_order {
    return Intl.message(
      'Order Notification',
      name: 'notification_type_order',
      desc: '',
      args: [],
    );
  }

  /// `System Notification`
  String get notification_type_system {
    return Intl.message(
      'System Notification',
      name: 'notification_type_system',
      desc: '',
      args: [],
    );
  }

  /// `After-sales Notification`
  String get notification_type_refund {
    return Intl.message(
      'After-sales Notification',
      name: 'notification_type_refund',
      desc: '',
      args: [],
    );
  }

  /// `Message Notification`
  String get notification_type_message {
    return Intl.message(
      'Message Notification',
      name: 'notification_type_message',
      desc: '',
      args: [],
    );
  }

  /// `Review Notification`
  String get notification_type_review {
    return Intl.message(
      'Review Notification',
      name: 'notification_type_review',
      desc: '',
      args: [],
    );
  }

  /// `Authentication Notification`
  String get notification_type_authentication {
    return Intl.message(
      'Authentication Notification',
      name: 'notification_type_authentication',
      desc: '',
      args: [],
    );
  }

  /// `Other Notification`
  String get notification_type_other {
    return Intl.message(
      'Other Notification',
      name: 'notification_type_other',
      desc: '',
      args: [],
    );
  }

  /// `Unread`
  String get notification_status_unread {
    return Intl.message(
      'Unread',
      name: 'notification_status_unread',
      desc: '',
      args: [],
    );
  }

  /// `Read`
  String get notification_status_read {
    return Intl.message(
      'Read',
      name: 'notification_status_read',
      desc: '',
      args: [],
    );
  }

  /// `Mark All as Read`
  String get notification_mark_all_read {
    return Intl.message(
      'Mark All as Read',
      name: 'notification_mark_all_read',
      desc: '',
      args: [],
    );
  }

  /// `No notifications`
  String get notification_empty_all {
    return Intl.message(
      'No notifications',
      name: 'notification_empty_all',
      desc: '',
      args: [],
    );
  }

  /// `No order notifications`
  String get notification_empty_order {
    return Intl.message(
      'No order notifications',
      name: 'notification_empty_order',
      desc: '',
      args: [],
    );
  }

  /// `No system notifications`
  String get notification_empty_system {
    return Intl.message(
      'No system notifications',
      name: 'notification_empty_system',
      desc: '',
      args: [],
    );
  }

  /// `No after-sales notifications`
  String get notification_empty_refund {
    return Intl.message(
      'No after-sales notifications',
      name: 'notification_empty_refund',
      desc: '',
      args: [],
    );
  }

  /// `No message notifications`
  String get notification_empty_message {
    return Intl.message(
      'No message notifications',
      name: 'notification_empty_message',
      desc: '',
      args: [],
    );
  }

  /// `No review notifications`
  String get notification_empty_review {
    return Intl.message(
      'No review notifications',
      name: 'notification_empty_review',
      desc: '',
      args: [],
    );
  }

  /// `No authentication notifications`
  String get notification_empty_authentication {
    return Intl.message(
      'No authentication notifications',
      name: 'notification_empty_authentication',
      desc: '',
      args: [],
    );
  }

  /// `No other notifications`
  String get notification_empty_other {
    return Intl.message(
      'No other notifications',
      name: 'notification_empty_other',
      desc: '',
      args: [],
    );
  }

  /// `No notifications`
  String get notification_empty_generic {
    return Intl.message(
      'No notifications',
      name: 'notification_empty_generic',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get notification_refresh {
    return Intl.message(
      'Refresh',
      name: 'notification_refresh',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get notification_retry {
    return Intl.message(
      'Retry',
      name: 'notification_retry',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load notification center: {error}`
  String notification_load_failed(String error) {
    return Intl.message(
      'Failed to load notification center: $error',
      name: 'notification_load_failed',
      desc: '',
      args: [error],
    );
  }

  /// `Notification Details`
  String get notification_detail_title {
    return Intl.message(
      'Notification Details',
      name: 'notification_detail_title',
      desc: '',
      args: [],
    );
  }

  /// `View Details`
  String get notification_detail_view {
    return Intl.message(
      'View Details',
      name: 'notification_detail_view',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get notification_detail_close {
    return Intl.message(
      'Close',
      name: 'notification_detail_close',
      desc: '',
      args: [],
    );
  }

  /// `Click to view details`
  String get notification_click_to_view {
    return Intl.message(
      'Click to view details',
      name: 'notification_click_to_view',
      desc: '',
      args: [],
    );
  }

  /// `Notification`
  String get notification_default_title {
    return Intl.message(
      'Notification',
      name: 'notification_default_title',
      desc: '',
      args: [],
    );
  }

  /// `Just now`
  String get notification_time_just_now {
    return Intl.message(
      'Just now',
      name: 'notification_time_just_now',
      desc: '',
      args: [],
    );
  }

  /// `{minutes} minutes ago`
  String notification_time_minutes_ago(int minutes) {
    return Intl.message(
      '$minutes minutes ago',
      name: 'notification_time_minutes_ago',
      desc: '',
      args: [minutes],
    );
  }

  /// `{hours} hours ago`
  String notification_time_hours_ago(int hours) {
    return Intl.message(
      '$hours hours ago',
      name: 'notification_time_hours_ago',
      desc: '',
      args: [hours],
    );
  }

  /// `{days} days ago`
  String notification_time_days_ago(int days) {
    return Intl.message(
      '$days days ago',
      name: 'notification_time_days_ago',
      desc: '',
      args: [days],
    );
  }

  /// `{months} months ago`
  String notification_time_months_ago(int months) {
    return Intl.message(
      '$months months ago',
      name: 'notification_time_months_ago',
      desc: '',
      args: [months],
    );
  }

  /// `Materials Info`
  String get materialsInfo {
    return Intl.message(
      'Materials Info',
      name: 'materialsInfo',
      desc: '',
      args: [],
    );
  }

  /// `Buyer Submitted Materials`
  String get buyerSubmittedMaterials {
    return Intl.message(
      'Buyer Submitted Materials',
      name: 'buyerSubmittedMaterials',
      desc: '',
      args: [],
    );
  }

  /// `Seller Delivery Content`
  String get sellerDeliveryContent {
    return Intl.message(
      'Seller Delivery Content',
      name: 'sellerDeliveryContent',
      desc: '',
      args: [],
    );
  }

  /// `No buyer submitted materials`
  String get noBuyerMaterials {
    return Intl.message(
      'No buyer submitted materials',
      name: 'noBuyerMaterials',
      desc: '',
      args: [],
    );
  }

  /// `No delivery from seller yet`
  String get noSellerDelivery {
    return Intl.message(
      'No delivery from seller yet',
      name: 'noSellerDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Attachments:`
  String get attachments {
    return Intl.message(
      'Attachments:',
      name: 'attachments',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Files:`
  String get deliveryFiles {
    return Intl.message(
      'Delivery Files:',
      name: 'deliveryFiles',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Description`
  String get deliveryDescription {
    return Intl.message(
      'Delivery Description',
      name: 'deliveryDescription',
      desc: '',
      args: [],
    );
  }

  /// `Tap to preview`
  String get tapToPreview {
    return Intl.message(
      'Tap to preview',
      name: 'tapToPreview',
      desc: '',
      args: [],
    );
  }

  /// `Tap to open`
  String get tapToOpen {
    return Intl.message(
      'Tap to open',
      name: 'tapToOpen',
      desc: '',
      args: [],
    );
  }

  /// `Download file`
  String get downloadFile {
    return Intl.message(
      'Download file',
      name: 'downloadFile',
      desc: '',
      args: [],
    );
  }

  /// `Storage permission denied`
  String get storagePermissionDenied {
    return Intl.message(
      'Storage permission denied',
      name: 'storagePermissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `Cancel download`
  String get cancelDownload {
    return Intl.message(
      'Cancel download',
      name: 'cancelDownload',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load page`
  String get pageLoadFailed {
    return Intl.message(
      'Failed to load page',
      name: 'pageLoadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Open file`
  String get openFile {
    return Intl.message(
      'Open file',
      name: 'openFile',
      desc: '',
      args: [],
    );
  }

  /// `Downloaded`
  String get downloaded {
    return Intl.message(
      'Downloaded',
      name: 'downloaded',
      desc: '',
      args: [],
    );
  }

  /// `Download completed`
  String get downloadCompleted {
    return Intl.message(
      'Download completed',
      name: 'downloadCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Download failed`
  String get downloadFailed {
    return Intl.message(
      'Download failed',
      name: 'downloadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Failed to open file`
  String get openFileFailed {
    return Intl.message(
      'Failed to open file',
      name: 'openFileFailed',
      desc: '',
      args: [],
    );
  }

  /// `Storage permission required to download files`
  String get storagePermissionRequired {
    return Intl.message(
      'Storage permission required to download files',
      name: 'storagePermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load PDF`
  String get pdfLoadFailed {
    return Intl.message(
      'Failed to load PDF',
      name: 'pdfLoadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
