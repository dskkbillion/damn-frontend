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

  /// `Let them see`
  String get ai_docs_let_them_see {
    return Intl.message(
      'Let them see',
      name: 'ai_docs_let_them_see',
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
