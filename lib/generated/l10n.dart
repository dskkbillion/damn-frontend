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
  String ai_docs_recommendations_error(Object error) {
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
  String ai_docs_recording_error(Object error) {
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
  String ai_docs_stop_recording_error_with_reason(Object error) {
    return Intl.message(
      'Error stopping recording: $error',
      name: 'ai_docs_stop_recording_error_with_reason',
      desc: '',
      args: [error],
    );
  }

  /// `Error selecting image: {error}`
  String ai_docs_image_picking_error(Object error) {
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
