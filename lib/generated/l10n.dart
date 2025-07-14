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
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
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
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
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
    return Intl.message('Retry', name: 'ai_docs_retry', desc: '', args: []);
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
    return Intl.message('Cancel', name: 'ai_docs_cancel', desc: '', args: []);
  }

  /// `Delete`
  String get ai_docs_delete {
    return Intl.message('Delete', name: 'ai_docs_delete', desc: '', args: []);
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
    return Intl.message('DSKK', name: 'nav_ai_assistant', desc: '', args: []);
  }

  /// `Home`
  String get nav_home {
    return Intl.message('Home', name: 'nav_home', desc: '', args: []);
  }

  /// `Messages`
  String get nav_messages {
    return Intl.message('Messages', name: 'nav_messages', desc: '', args: []);
  }

  /// `Profile`
  String get nav_profile {
    return Intl.message('Profile', name: 'nav_profile', desc: '', args: []);
  }

  /// `Dev`
  String get nav_dev {
    return Intl.message('Dev', name: 'nav_dev', desc: '', args: []);
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
    return Intl.message('Loading...', name: 'chat_loading', desc: '', args: []);
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
    return Intl.message('Copy', name: 'chat_copy', desc: '', args: []);
  }

  /// `Recall`
  String get chat_recall {
    return Intl.message('Recall', name: 'chat_recall', desc: '', args: []);
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
    return Intl.message('Me', name: 'chat_me', desc: '', args: []);
  }

  /// `Buyer`
  String get chat_buyer {
    return Intl.message('Buyer', name: 'chat_buyer', desc: '', args: []);
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
    return Intl.message('Collapse', name: 'chat_collapse', desc: '', args: []);
  }

  /// `Expand`
  String get chat_expand {
    return Intl.message('Expand', name: 'chat_expand', desc: '', args: []);
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
    return Intl.message('Pause', name: 'chat_audio_pause', desc: '', args: []);
  }

  /// `Play`
  String get chat_audio_play {
    return Intl.message('Play', name: 'chat_audio_play', desc: '', args: []);
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
    return Intl.message('Send', name: 'chat_send', desc: '', args: []);
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
    return Intl.message('My DSKK', name: 'profile_my_dskk', desc: '', args: []);
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
    return Intl.message('Wallet', name: 'profile_wallet', desc: '', args: []);
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
    return Intl.message('Cancel', name: 'profile_cancel', desc: '', args: []);
  }

  /// `Save`
  String get profile_save {
    return Intl.message('Save', name: 'profile_save', desc: '', args: []);
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
    return Intl.message('Online', name: 'profile_online', desc: '', args: []);
  }

  /// `Offline`
  String get profile_offline {
    return Intl.message('Offline', name: 'profile_offline', desc: '', args: []);
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

  /// `Processing`
  String get profile_in_progress {
    return Intl.message(
      'Processing',
      name: 'profile_in_progress',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get profile_completed {
    return Intl.message(
      'Completed',
      name: 'profile_completed',
      desc: '',
      args: [],
    );
  }

  /// `Support`
  String get profile_refund {
    return Intl.message('Support', name: 'profile_refund', desc: '', args: []);
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
    return Intl.message('Home', name: 'home_title', desc: '', args: []);
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
    return Intl.message('Loading...', name: 'home_loading', desc: '', args: []);
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
    return Intl.message('Retry', name: 'home_retry', desc: '', args: []);
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
    return Intl.message('Search', name: 'search_title', desc: '', args: []);
  }

  /// `Search`
  String get search_button {
    return Intl.message('Search', name: 'search_button', desc: '', args: []);
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
    return Intl.message('FAQ', name: 'product_detail_faq', desc: '', args: []);
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
