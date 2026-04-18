import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('zh'),
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('vi')
  ];

  /// No description provided for @language_settings.
  ///
  /// In zh, this message translates to:
  /// **'语言设置'**
  String get language_settings;

  /// No description provided for @system_language.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get system_language;

  /// No description provided for @system_language_description.
  ///
  /// In zh, this message translates to:
  /// **'自动使用设备的语言设置'**
  String get system_language_description;

  /// No description provided for @ai_docs_assistant_title.
  ///
  /// In zh, this message translates to:
  /// **'AI 助手'**
  String get ai_docs_assistant_title;

  /// No description provided for @ai_docs_unnamed_conversation.
  ///
  /// In zh, this message translates to:
  /// **'未命名会话'**
  String get ai_docs_unnamed_conversation;

  /// No description provided for @ai_docs_loading.
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get ai_docs_loading;

  /// No description provided for @ai_docs_match_button.
  ///
  /// In zh, this message translates to:
  /// **'匹配'**
  String get ai_docs_match_button;

  /// No description provided for @ai_docs_select_conversation_first.
  ///
  /// In zh, this message translates to:
  /// **'请先选择一个会话'**
  String get ai_docs_select_conversation_first;

  /// No description provided for @ai_docs_please_enter_message.
  ///
  /// In zh, this message translates to:
  /// **'请输入消息内容'**
  String get ai_docs_please_enter_message;

  /// No description provided for @ai_docs_recommended_services.
  ///
  /// In zh, this message translates to:
  /// **'推荐服务'**
  String get ai_docs_recommended_services;

  /// No description provided for @ai_docs_recommendations_error.
  ///
  /// In zh, this message translates to:
  /// **'加载推荐服务失败: {error}'**
  String ai_docs_recommendations_error(String error);

  /// No description provided for @ai_docs_no_recommendations.
  ///
  /// In zh, this message translates to:
  /// **'暂无推荐服务'**
  String get ai_docs_no_recommendations;

  /// No description provided for @ai_docs_dispatched.
  ///
  /// In zh, this message translates to:
  /// **'已分发'**
  String get ai_docs_dispatched;

  /// No description provided for @ai_docs_enter_chat.
  ///
  /// In zh, this message translates to:
  /// **'进入聊天'**
  String get ai_docs_enter_chat;

  /// No description provided for @ai_docs_let_them_see.
  ///
  /// In zh, this message translates to:
  /// **'让ta看看'**
  String get ai_docs_let_them_see;

  /// No description provided for @ai_docs_welcome_title.
  ///
  /// In zh, this message translates to:
  /// **'欢迎使用AI助手'**
  String get ai_docs_welcome_title;

  /// No description provided for @ai_docs_welcome_message.
  ///
  /// In zh, this message translates to:
  /// **'直接发送消息即可开始对话，系统会自动为您创建聊天室'**
  String get ai_docs_welcome_message;

  /// No description provided for @ai_docs_auto_create_text.
  ///
  /// In zh, this message translates to:
  /// **'没有选择对话，自动创建新对话并发送消息'**
  String get ai_docs_auto_create_text;

  /// No description provided for @ai_docs_auto_create_voice.
  ///
  /// In zh, this message translates to:
  /// **'没有选择对话，自动创建新对话并发送语音消息'**
  String get ai_docs_auto_create_voice;

  /// No description provided for @ai_docs_cancelling_generation.
  ///
  /// In zh, this message translates to:
  /// **'正在取消生成中...'**
  String get ai_docs_cancelling_generation;

  /// No description provided for @allocating_step1.
  ///
  /// In zh, this message translates to:
  /// **'分发中'**
  String get allocating_step1;

  /// No description provided for @allocating_step2.
  ///
  /// In zh, this message translates to:
  /// **'分发中.'**
  String get allocating_step2;

  /// No description provided for @allocating_step3.
  ///
  /// In zh, this message translates to:
  /// **'分发中..'**
  String get allocating_step3;

  /// No description provided for @allocating_step4.
  ///
  /// In zh, this message translates to:
  /// **'分发中...'**
  String get allocating_step4;

  /// No description provided for @ai_docs_add_image.
  ///
  /// In zh, this message translates to:
  /// **'添加图片'**
  String get ai_docs_add_image;

  /// No description provided for @ai_docs_stop_recording.
  ///
  /// In zh, this message translates to:
  /// **'停止录音'**
  String get ai_docs_stop_recording;

  /// No description provided for @ai_docs_start_recording.
  ///
  /// In zh, this message translates to:
  /// **'录制语音'**
  String get ai_docs_start_recording;

  /// No description provided for @ai_docs_recording.
  ///
  /// In zh, this message translates to:
  /// **'正在录音...点击停止发送'**
  String get ai_docs_recording;

  /// No description provided for @ai_docs_enter_message.
  ///
  /// In zh, this message translates to:
  /// **'输入消息...'**
  String get ai_docs_enter_message;

  /// No description provided for @ai_docs_stop_generation.
  ///
  /// In zh, this message translates to:
  /// **'停止生成'**
  String get ai_docs_stop_generation;

  /// No description provided for @ai_docs_send_message.
  ///
  /// In zh, this message translates to:
  /// **'发送消息'**
  String get ai_docs_send_message;

  /// No description provided for @ai_docs_uploading_images.
  ///
  /// In zh, this message translates to:
  /// **'图片正在上传中，请稍候...'**
  String get ai_docs_uploading_images;

  /// No description provided for @ai_docs_mic_permission_denied.
  ///
  /// In zh, this message translates to:
  /// **'麦克风权限被拒绝'**
  String get ai_docs_mic_permission_denied;

  /// No description provided for @ai_docs_recording_error.
  ///
  /// In zh, this message translates to:
  /// **'开始录音出错: {error}'**
  String ai_docs_recording_error(String error);

  /// No description provided for @ai_docs_recording_file_not_found.
  ///
  /// In zh, this message translates to:
  /// **'错误：未找到录音文件'**
  String get ai_docs_recording_file_not_found;

  /// No description provided for @ai_docs_stop_recording_error.
  ///
  /// In zh, this message translates to:
  /// **'停止录音出错'**
  String get ai_docs_stop_recording_error;

  /// No description provided for @ai_docs_stop_recording_error_with_reason.
  ///
  /// In zh, this message translates to:
  /// **'停止录音出错: {error}'**
  String ai_docs_stop_recording_error_with_reason(String error);

  /// No description provided for @ai_docs_image_picking_error.
  ///
  /// In zh, this message translates to:
  /// **'选择图片出错: {error}'**
  String ai_docs_image_picking_error(String error);

  /// No description provided for @ai_docs_conversation_list.
  ///
  /// In zh, this message translates to:
  /// **'会话列表'**
  String get ai_docs_conversation_list;

  /// No description provided for @ai_docs_no_messages.
  ///
  /// In zh, this message translates to:
  /// **'暂无消息，开始聊天吧！'**
  String get ai_docs_no_messages;

  /// No description provided for @ai_docs_new_chat.
  ///
  /// In zh, this message translates to:
  /// **'新建聊天'**
  String get ai_docs_new_chat;

  /// No description provided for @ai_docs_load_conversations_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载会话失败'**
  String get ai_docs_load_conversations_failed;

  /// No description provided for @ai_docs_retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get ai_docs_retry;

  /// No description provided for @ai_docs_no_conversations.
  ///
  /// In zh, this message translates to:
  /// **'暂无会话'**
  String get ai_docs_no_conversations;

  /// No description provided for @ai_docs_delete_conversation_tooltip.
  ///
  /// In zh, this message translates to:
  /// **'删除会话'**
  String get ai_docs_delete_conversation_tooltip;

  /// No description provided for @ai_docs_delete_conversation_title.
  ///
  /// In zh, this message translates to:
  /// **'删除会话？'**
  String get ai_docs_delete_conversation_title;

  /// No description provided for @ai_docs_delete_conversation_content.
  ///
  /// In zh, this message translates to:
  /// **'确定要永久删除此会话吗？'**
  String get ai_docs_delete_conversation_content;

  /// No description provided for @ai_docs_cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get ai_docs_cancel;

  /// No description provided for @ai_docs_delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get ai_docs_delete;

  /// No description provided for @ai_docs_please_select_conversation_to_delete.
  ///
  /// In zh, this message translates to:
  /// **'请先选择要删除的会话'**
  String get ai_docs_please_select_conversation_to_delete;

  /// No description provided for @ai_docs_generate_title.
  ///
  /// In zh, this message translates to:
  /// **'AI生成标题'**
  String get ai_docs_generate_title;

  /// No description provided for @ai_docs_generate_title_tooltip.
  ///
  /// In zh, this message translates to:
  /// **'让AI为这个会话生成一个标题'**
  String get ai_docs_generate_title_tooltip;

  /// No description provided for @ai_docs_generating_title.
  ///
  /// In zh, this message translates to:
  /// **'正在生成标题...'**
  String get ai_docs_generating_title;

  /// No description provided for @ai_docs_title_generated.
  ///
  /// In zh, this message translates to:
  /// **'标题已生成'**
  String get ai_docs_title_generated;

  /// No description provided for @ai_docs_title_generation_failed.
  ///
  /// In zh, this message translates to:
  /// **'标题生成失败: {error}'**
  String ai_docs_title_generation_failed(String error);

  /// No description provided for @ai_docs_edit_title.
  ///
  /// In zh, this message translates to:
  /// **'编辑标题'**
  String get ai_docs_edit_title;

  /// No description provided for @ai_docs_edit_title_hint.
  ///
  /// In zh, this message translates to:
  /// **'请输入新的标题'**
  String get ai_docs_edit_title_hint;

  /// No description provided for @ai_docs_title_updated.
  ///
  /// In zh, this message translates to:
  /// **'标题已更新'**
  String get ai_docs_title_updated;

  /// No description provided for @ai_docs_title_update_failed.
  ///
  /// In zh, this message translates to:
  /// **'标题更新失败: {error}'**
  String ai_docs_title_update_failed(String error);

  /// No description provided for @ai_docs_title_too_long.
  ///
  /// In zh, this message translates to:
  /// **'标题长度不能超过50个字符'**
  String get ai_docs_title_too_long;

  /// No description provided for @ai_docs_title_empty.
  ///
  /// In zh, this message translates to:
  /// **'标题不能为空'**
  String get ai_docs_title_empty;

  /// No description provided for @nav_ai_assistant.
  ///
  /// In zh, this message translates to:
  /// **'看看'**
  String get nav_ai_assistant;

  /// No description provided for @nav_home.
  ///
  /// In zh, this message translates to:
  /// **'逛逛'**
  String get nav_home;

  /// No description provided for @nav_messages.
  ///
  /// In zh, this message translates to:
  /// **'聊聊'**
  String get nav_messages;

  /// No description provided for @nav_profile.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get nav_profile;

  /// No description provided for @nav_dev.
  ///
  /// In zh, this message translates to:
  /// **'开发'**
  String get nav_dev;

  /// No description provided for @nav_seller_analytics.
  ///
  /// In zh, this message translates to:
  /// **'数据'**
  String get nav_seller_analytics;

  /// No description provided for @nav_seller_products.
  ///
  /// In zh, this message translates to:
  /// **'商品'**
  String get nav_seller_products;

  /// No description provided for @nav_seller_messages.
  ///
  /// In zh, this message translates to:
  /// **'消息'**
  String get nav_seller_messages;

  /// No description provided for @nav_seller_profile.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get nav_seller_profile;

  /// No description provided for @chat_list_title.
  ///
  /// In zh, this message translates to:
  /// **'聊天列表'**
  String get chat_list_title;

  /// No description provided for @chat_loading.
  ///
  /// In zh, this message translates to:
  /// **'正在加载...'**
  String get chat_loading;

  /// No description provided for @chat_error_loading.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String chat_error_loading(String error);

  /// No description provided for @chat_no_messages.
  ///
  /// In zh, this message translates to:
  /// **'暂无消息，开始聊天吧！'**
  String get chat_no_messages;

  /// No description provided for @chat_admin_title.
  ///
  /// In zh, this message translates to:
  /// **'系统管理员'**
  String get chat_admin_title;

  /// No description provided for @chat_notification_center.
  ///
  /// In zh, this message translates to:
  /// **'通知中心'**
  String get chat_notification_center;

  /// No description provided for @chat_notification_description.
  ///
  /// In zh, this message translates to:
  /// **'系统、订单、评价等重要通知'**
  String get chat_notification_description;

  /// No description provided for @chat_enter_message.
  ///
  /// In zh, this message translates to:
  /// **'输入消息...'**
  String get chat_enter_message;

  /// No description provided for @chat_yesterday.
  ///
  /// In zh, this message translates to:
  /// **'昨天'**
  String get chat_yesterday;

  /// No description provided for @chat_image_message.
  ///
  /// In zh, this message translates to:
  /// **'【图片】'**
  String get chat_image_message;

  /// No description provided for @chat_audio_message.
  ///
  /// In zh, this message translates to:
  /// **'【语音】'**
  String get chat_audio_message;

  /// No description provided for @chat_file_message.
  ///
  /// In zh, this message translates to:
  /// **'【文件】'**
  String get chat_file_message;

  /// No description provided for @chat_allocate_message.
  ///
  /// In zh, this message translates to:
  /// **'【多少看看】'**
  String get chat_allocate_message;

  /// No description provided for @chat_payment_prompt_message.
  ///
  /// In zh, this message translates to:
  /// **'【付费提示】'**
  String get chat_payment_prompt_message;

  /// No description provided for @chat_revoked_message.
  ///
  /// In zh, this message translates to:
  /// **'[消息已撤回]'**
  String get chat_revoked_message;

  /// No description provided for @chat_unknown_message.
  ///
  /// In zh, this message translates to:
  /// **'[未知消息]'**
  String get chat_unknown_message;

  /// No description provided for @chat_unknown_user.
  ///
  /// In zh, this message translates to:
  /// **'未知用户'**
  String get chat_unknown_user;

  /// No description provided for @chat_invalid_session.
  ///
  /// In zh, this message translates to:
  /// **'无效的会话'**
  String get chat_invalid_session;

  /// No description provided for @chat_opponent_not_found.
  ///
  /// In zh, this message translates to:
  /// **'无法找到对方信息'**
  String get chat_opponent_not_found;

  /// No description provided for @chat_message_recalled.
  ///
  /// In zh, this message translates to:
  /// **'消息已撤回'**
  String get chat_message_recalled;

  /// No description provided for @chat_copy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get chat_copy;

  /// No description provided for @chat_recall.
  ///
  /// In zh, this message translates to:
  /// **'撤回'**
  String get chat_recall;

  /// No description provided for @chat_copied_to_clipboard.
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板'**
  String get chat_copied_to_clipboard;

  /// No description provided for @chat_me.
  ///
  /// In zh, this message translates to:
  /// **'我'**
  String get chat_me;

  /// No description provided for @chat_buyer.
  ///
  /// In zh, this message translates to:
  /// **'买家'**
  String get chat_buyer;

  /// No description provided for @chat_i_want_seller_to_see.
  ///
  /// In zh, this message translates to:
  /// **'我想看看'**
  String get chat_i_want_seller_to_see;

  /// No description provided for @chat_wants_to_see.
  ///
  /// In zh, this message translates to:
  /// **'想看看'**
  String get chat_wants_to_see;

  /// No description provided for @chat_collapse.
  ///
  /// In zh, this message translates to:
  /// **'收起'**
  String get chat_collapse;

  /// No description provided for @chat_expand.
  ///
  /// In zh, this message translates to:
  /// **'展开'**
  String get chat_expand;

  /// No description provided for @chat_admin_connection_error.
  ///
  /// In zh, this message translates to:
  /// **'无法连接到系统管理员'**
  String get chat_admin_connection_error;

  /// No description provided for @chat_audio_pause.
  ///
  /// In zh, this message translates to:
  /// **'暂停'**
  String get chat_audio_pause;

  /// No description provided for @chat_audio_play.
  ///
  /// In zh, this message translates to:
  /// **'播放'**
  String get chat_audio_play;

  /// No description provided for @chat_markdown_example_title1.
  ///
  /// In zh, this message translates to:
  /// **'这是一级标题'**
  String get chat_markdown_example_title1;

  /// No description provided for @chat_markdown_example_title2.
  ///
  /// In zh, this message translates to:
  /// **'这是二级标题'**
  String get chat_markdown_example_title2;

  /// No description provided for @chat_markdown_example_bold_italic.
  ///
  /// In zh, this message translates to:
  /// **'这是**粗体**文本和*斜体*文本。'**
  String get chat_markdown_example_bold_italic;

  /// No description provided for @chat_markdown_example_list1.
  ///
  /// In zh, this message translates to:
  /// **'这是列表项1'**
  String get chat_markdown_example_list1;

  /// No description provided for @chat_markdown_example_list2.
  ///
  /// In zh, this message translates to:
  /// **'这是列表项2'**
  String get chat_markdown_example_list2;

  /// No description provided for @chat_markdown_example_list3.
  ///
  /// In zh, this message translates to:
  /// **'这是嵌套列表项'**
  String get chat_markdown_example_list3;

  /// No description provided for @chat_markdown_example_quote.
  ///
  /// In zh, this message translates to:
  /// **'这是引用文本，支持多行显示'**
  String get chat_markdown_example_quote;

  /// No description provided for @chat_markdown_example_table_col1.
  ///
  /// In zh, this message translates to:
  /// **'列1'**
  String get chat_markdown_example_table_col1;

  /// No description provided for @chat_markdown_example_table_col2.
  ///
  /// In zh, this message translates to:
  /// **'列2'**
  String get chat_markdown_example_table_col2;

  /// No description provided for @chat_markdown_example_table_content1.
  ///
  /// In zh, this message translates to:
  /// **'内容1'**
  String get chat_markdown_example_table_content1;

  /// No description provided for @chat_markdown_example_table_content2.
  ///
  /// In zh, this message translates to:
  /// **'内容2'**
  String get chat_markdown_example_table_content2;

  /// No description provided for @chat_markdown_example_table_content3.
  ///
  /// In zh, this message translates to:
  /// **'内容3'**
  String get chat_markdown_example_table_content3;

  /// No description provided for @chat_markdown_example_table_content4.
  ///
  /// In zh, this message translates to:
  /// **'内容4'**
  String get chat_markdown_example_table_content4;

  /// No description provided for @chat_pick_from_gallery.
  ///
  /// In zh, this message translates to:
  /// **'从相册选择'**
  String get chat_pick_from_gallery;

  /// No description provided for @chat_take_photo.
  ///
  /// In zh, this message translates to:
  /// **'拍照'**
  String get chat_take_photo;

  /// No description provided for @chat_send_markdown.
  ///
  /// In zh, this message translates to:
  /// **'发送Markdown示例'**
  String get chat_send_markdown;

  /// No description provided for @chat_switch_to_text.
  ///
  /// In zh, this message translates to:
  /// **'切换到文本输入'**
  String get chat_switch_to_text;

  /// No description provided for @chat_switch_to_voice.
  ///
  /// In zh, this message translates to:
  /// **'切换到语音输入'**
  String get chat_switch_to_voice;

  /// No description provided for @chat_send.
  ///
  /// In zh, this message translates to:
  /// **'发送'**
  String get chat_send;

  /// No description provided for @chat_attach.
  ///
  /// In zh, this message translates to:
  /// **'发送图片/文件'**
  String get chat_attach;

  /// No description provided for @chat_filter_all.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get chat_filter_all;

  /// No description provided for @chat_filter_buyer.
  ///
  /// In zh, this message translates to:
  /// **'我的购买'**
  String get chat_filter_buyer;

  /// No description provided for @chat_filter_seller.
  ///
  /// In zh, this message translates to:
  /// **'我的出售'**
  String get chat_filter_seller;

  /// No description provided for @chat_filter_mode_all.
  ///
  /// In zh, this message translates to:
  /// **'显示全部聊天'**
  String get chat_filter_mode_all;

  /// No description provided for @chat_filter_mode_buyer.
  ///
  /// In zh, this message translates to:
  /// **'只显示我的购买聊天'**
  String get chat_filter_mode_buyer;

  /// No description provided for @chat_filter_mode_seller.
  ///
  /// In zh, this message translates to:
  /// **'只显示我的出售聊天'**
  String get chat_filter_mode_seller;

  /// No description provided for @chat_press_to_talk.
  ///
  /// In zh, this message translates to:
  /// **'按住 说话'**
  String get chat_press_to_talk;

  /// No description provided for @chat_release_to_send.
  ///
  /// In zh, this message translates to:
  /// **'松开 发送 ({duration}s)'**
  String chat_release_to_send(int duration);

  /// No description provided for @chat_camera_permission_denied_title.
  ///
  /// In zh, this message translates to:
  /// **'相机权限已被禁用'**
  String get chat_camera_permission_denied_title;

  /// No description provided for @chat_camera_permission_denied_message.
  ///
  /// In zh, this message translates to:
  /// **'请在系统设置中手动开启相机权限才能使用拍照功能。'**
  String get chat_camera_permission_denied_message;

  /// No description provided for @chat_mic_permission_denied_title.
  ///
  /// In zh, this message translates to:
  /// **'麦克风权限已被禁用'**
  String get chat_mic_permission_denied_title;

  /// No description provided for @chat_mic_permission_denied_message.
  ///
  /// In zh, this message translates to:
  /// **'请在系统设置中手动开启麦克风权限才能使用录音功能。'**
  String get chat_mic_permission_denied_message;

  /// No description provided for @chat_permission_denied_cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get chat_permission_denied_cancel;

  /// No description provided for @chat_permission_denied_settings.
  ///
  /// In zh, this message translates to:
  /// **'去设置'**
  String get chat_permission_denied_settings;

  /// No description provided for @chat_mic_permission_denied.
  ///
  /// In zh, this message translates to:
  /// **'未获得麦克风权限，无法录音'**
  String get chat_mic_permission_denied;

  /// No description provided for @chat_camera_permission_denied.
  ///
  /// In zh, this message translates to:
  /// **'未获得相机权限，无法拍照'**
  String get chat_camera_permission_denied;

  /// No description provided for @chat_recording_error.
  ///
  /// In zh, this message translates to:
  /// **'无法开始录音: {error}'**
  String chat_recording_error(String error);

  /// No description provided for @chat_stop_recording_error.
  ///
  /// In zh, this message translates to:
  /// **'停止录音失败: {error}'**
  String chat_stop_recording_error(String error);

  /// No description provided for @chat_image_picking_error.
  ///
  /// In zh, this message translates to:
  /// **'选择图片出错: {error}'**
  String chat_image_picking_error(String error);

  /// No description provided for @chat_web_recording_not_supported.
  ///
  /// In zh, this message translates to:
  /// **'Web 平台暂不支持录音功能'**
  String get chat_web_recording_not_supported;

  /// No description provided for @profile_personal_center.
  ///
  /// In zh, this message translates to:
  /// **'个人中心'**
  String get profile_personal_center;

  /// No description provided for @profile_login_prompt.
  ///
  /// In zh, this message translates to:
  /// **'请登录以查看您的个人资料'**
  String get profile_login_prompt;

  /// No description provided for @profile_login_button.
  ///
  /// In zh, this message translates to:
  /// **'去登录'**
  String get profile_login_button;

  /// No description provided for @auth_phone_number.
  ///
  /// In zh, this message translates to:
  /// **'手机号'**
  String get auth_phone_number;

  /// No description provided for @auth_select_country_region.
  ///
  /// In zh, this message translates to:
  /// **'选择国家/地区'**
  String get auth_select_country_region;

  /// No description provided for @auth_phone_validation_empty.
  ///
  /// In zh, this message translates to:
  /// **'请输入手机号'**
  String get auth_phone_validation_empty;

  /// No description provided for @auth_phone_validation_invalid_cn.
  ///
  /// In zh, this message translates to:
  /// **'请输入11位手机号'**
  String get auth_phone_validation_invalid_cn;

  /// No description provided for @auth_phone_validation_invalid_cn_start.
  ///
  /// In zh, this message translates to:
  /// **'手机号必须以1开头'**
  String get auth_phone_validation_invalid_cn_start;

  /// No description provided for @auth_phone_validation_invalid_us.
  ///
  /// In zh, this message translates to:
  /// **'请输入10位电话号码'**
  String get auth_phone_validation_invalid_us;

  /// No description provided for @auth_phone_validation_invalid_jp_kr.
  ///
  /// In zh, this message translates to:
  /// **'请输入10或11位电话号码'**
  String get auth_phone_validation_invalid_jp_kr;

  /// No description provided for @auth_phone_validation_invalid_general.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的电话号码'**
  String get auth_phone_validation_invalid_general;

  /// No description provided for @profile_loading_error.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String profile_loading_error(String error);

  /// No description provided for @profile_my_dskk.
  ///
  /// In zh, this message translates to:
  /// **'我的多看'**
  String get profile_my_dskk;

  /// No description provided for @profile_favorites.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get profile_favorites;

  /// No description provided for @profile_my_wallet.
  ///
  /// In zh, this message translates to:
  /// **'我的钱包'**
  String get profile_my_wallet;

  /// No description provided for @profile_wallet.
  ///
  /// In zh, this message translates to:
  /// **'钱包'**
  String get profile_wallet;

  /// No description provided for @profile_settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get profile_settings;

  /// No description provided for @profile_account_security.
  ///
  /// In zh, this message translates to:
  /// **'账号与安全'**
  String get profile_account_security;

  /// No description provided for @profile_message_notifications.
  ///
  /// In zh, this message translates to:
  /// **'消息通知'**
  String get profile_message_notifications;

  /// No description provided for @profile_about_us.
  ///
  /// In zh, this message translates to:
  /// **'关于我们'**
  String get profile_about_us;

  /// No description provided for @profile_assistant_mission.
  ///
  /// In zh, this message translates to:
  /// **'小帮手的使命'**
  String get profile_assistant_mission;

  /// No description provided for @profile_switch_to_seller.
  ///
  /// In zh, this message translates to:
  /// **'切换到卖家模式'**
  String get profile_switch_to_seller;

  /// No description provided for @profile_switch_error.
  ///
  /// In zh, this message translates to:
  /// **'无法切换到卖家模式: {error}'**
  String profile_switch_error(String error);

  /// No description provided for @profile_edit_nickname.
  ///
  /// In zh, this message translates to:
  /// **'修改昵称'**
  String get profile_edit_nickname;

  /// No description provided for @profile_nickname_hint.
  ///
  /// In zh, this message translates to:
  /// **'请输入新昵称'**
  String get profile_nickname_hint;

  /// No description provided for @profile_nickname_empty_error.
  ///
  /// In zh, this message translates to:
  /// **'昵称不能为空'**
  String get profile_nickname_empty_error;

  /// No description provided for @profile_nickname_length_error.
  ///
  /// In zh, this message translates to:
  /// **'昵称长度不能超过20个字符'**
  String get profile_nickname_length_error;

  /// No description provided for @profile_cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get profile_cancel;

  /// No description provided for @profile_save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get profile_save;

  /// No description provided for @profile_default_name.
  ///
  /// In zh, this message translates to:
  /// **'用户'**
  String get profile_default_name;

  /// No description provided for @profile_online.
  ///
  /// In zh, this message translates to:
  /// **'在线'**
  String get profile_online;

  /// No description provided for @profile_offline.
  ///
  /// In zh, this message translates to:
  /// **'离线'**
  String get profile_offline;

  /// No description provided for @profile_avatar_upload_failed.
  ///
  /// In zh, this message translates to:
  /// **'头像上传失败，请重试'**
  String get profile_avatar_upload_failed;

  /// No description provided for @profile_orders.
  ///
  /// In zh, this message translates to:
  /// **'我的订单'**
  String get profile_orders;

  /// No description provided for @profile_pending_payment.
  ///
  /// In zh, this message translates to:
  /// **'待付款'**
  String get profile_pending_payment;

  /// No description provided for @profile_in_progress.
  ///
  /// In zh, this message translates to:
  /// **'咨询中'**
  String get profile_in_progress;

  /// No description provided for @profile_completed.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get profile_completed;

  /// No description provided for @profile_refund.
  ///
  /// In zh, this message translates to:
  /// **'售后'**
  String get profile_refund;

  /// No description provided for @profile_navigation_error.
  ///
  /// In zh, this message translates to:
  /// **'无法导航到订单列表: {error}'**
  String profile_navigation_error(String error);

  /// No description provided for @home_title.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get home_title;

  /// No description provided for @home_search_hint.
  ///
  /// In zh, this message translates to:
  /// **'搜索服务'**
  String get home_search_hint;

  /// No description provided for @home_loading.
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get home_loading;

  /// No description provided for @home_loading_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String home_loading_failed(String error);

  /// No description provided for @home_retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get home_retry;

  /// No description provided for @home_end_of_list.
  ///
  /// In zh, this message translates to:
  /// **'已经到底了'**
  String get home_end_of_list;

  /// No description provided for @home_no_content.
  ///
  /// In zh, this message translates to:
  /// **'暂无推荐内容'**
  String get home_no_content;

  /// No description provided for @home_pull_to_refresh.
  ///
  /// In zh, this message translates to:
  /// **'下拉刷新获取推荐内容'**
  String get home_pull_to_refresh;

  /// No description provided for @home_banner_clicked.
  ///
  /// In zh, this message translates to:
  /// **'点击了轮播图: {targetType} - {targetValue}'**
  String home_banner_clicked(String targetType, String targetValue);

  /// No description provided for @home_product_card_clicked.
  ///
  /// In zh, this message translates to:
  /// **'点击了服务卡片: {name}'**
  String home_product_card_clicked(String name);

  /// No description provided for @home_recommend_clicked.
  ///
  /// In zh, this message translates to:
  /// **'点击了\"让ta看看\"按钮: {name}'**
  String home_recommend_clicked(String name);

  /// No description provided for @product_recommend_button.
  ///
  /// In zh, this message translates to:
  /// **'让ta看看'**
  String get product_recommend_button;

  /// No description provided for @product_image_loading_failed.
  ///
  /// In zh, this message translates to:
  /// **'图片加载失败'**
  String get product_image_loading_failed;

  /// No description provided for @product_default_name.
  ///
  /// In zh, this message translates to:
  /// **'商品'**
  String get product_default_name;

  /// No description provided for @search_title.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get search_title;

  /// No description provided for @search_button.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get search_button;

  /// No description provided for @search_hot_keywords.
  ///
  /// In zh, this message translates to:
  /// **'热搜榜'**
  String get search_hot_keywords;

  /// No description provided for @search_history.
  ///
  /// In zh, this message translates to:
  /// **'搜索历史'**
  String get search_history;

  /// No description provided for @search_no_results.
  ///
  /// In zh, this message translates to:
  /// **'没有找到相关的服务'**
  String get search_no_results;

  /// No description provided for @search_failed.
  ///
  /// In zh, this message translates to:
  /// **'搜索失败: {error}'**
  String search_failed(String error);

  /// No description provided for @product_detail_loading_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String product_detail_loading_failed(String error);

  /// No description provided for @product_detail_retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get product_detail_retry;

  /// No description provided for @product_detail_please_wait.
  ///
  /// In zh, this message translates to:
  /// **'请稍等...'**
  String get product_detail_please_wait;

  /// No description provided for @product_detail_contact_seller.
  ///
  /// In zh, this message translates to:
  /// **'咨询卖家'**
  String get product_detail_contact_seller;

  /// No description provided for @product_detail_verified_label.
  ///
  /// In zh, this message translates to:
  /// **'已认证'**
  String get product_detail_verified_label;

  /// No description provided for @product_detail_published_status.
  ///
  /// In zh, this message translates to:
  /// **'已发布'**
  String get product_detail_published_status;

  /// No description provided for @product_detail_more.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get product_detail_more;

  /// No description provided for @product_detail_collapse.
  ///
  /// In zh, this message translates to:
  /// **'收起'**
  String get product_detail_collapse;

  /// No description provided for @product_detail_delivery_times.
  ///
  /// In zh, this message translates to:
  /// **'交付次数'**
  String get product_detail_delivery_times;

  /// No description provided for @product_detail_delivery_period.
  ///
  /// In zh, this message translates to:
  /// **'交付周期'**
  String get product_detail_delivery_period;

  /// No description provided for @product_detail_buy_now.
  ///
  /// In zh, this message translates to:
  /// **'一键购买(1)'**
  String get product_detail_buy_now;

  /// No description provided for @product_detail_buy_now_with_price.
  ///
  /// In zh, this message translates to:
  /// **'一键购买 ¥{price}'**
  String product_detail_buy_now_with_price(String price);

  /// No description provided for @product_detail_faq.
  ///
  /// In zh, this message translates to:
  /// **'常见问题'**
  String get product_detail_faq;

  /// No description provided for @product_detail_case_showcase.
  ///
  /// In zh, this message translates to:
  /// **'案例展示'**
  String get product_detail_case_showcase;

  /// No description provided for @product_detail_no_cases.
  ///
  /// In zh, this message translates to:
  /// **'暂无案例展示'**
  String get product_detail_no_cases;

  /// No description provided for @product_detail_reviews.
  ///
  /// In zh, this message translates to:
  /// **'评论({count})'**
  String product_detail_reviews(int count);

  /// No description provided for @product_detail_view_all.
  ///
  /// In zh, this message translates to:
  /// **'查看全部'**
  String get product_detail_view_all;

  /// No description provided for @product_detail_no_reviews.
  ///
  /// In zh, this message translates to:
  /// **'暂无评价'**
  String get product_detail_no_reviews;

  /// No description provided for @product_detail_basic_package.
  ///
  /// In zh, this message translates to:
  /// **'基础'**
  String get product_detail_basic_package;

  /// No description provided for @product_detail_standard_package.
  ///
  /// In zh, this message translates to:
  /// **'标准'**
  String get product_detail_standard_package;

  /// No description provided for @product_detail_premium_package.
  ///
  /// In zh, this message translates to:
  /// **'豪华'**
  String get product_detail_premium_package;

  /// No description provided for @product_detail_basic_tier.
  ///
  /// In zh, this message translates to:
  /// **'基础'**
  String get product_detail_basic_tier;

  /// No description provided for @product_detail_standard_tier.
  ///
  /// In zh, this message translates to:
  /// **'标准'**
  String get product_detail_standard_tier;

  /// No description provided for @product_detail_premium_tier.
  ///
  /// In zh, this message translates to:
  /// **'豪华'**
  String get product_detail_premium_tier;

  /// No description provided for @product_detail_sample_review.
  ///
  /// In zh, this message translates to:
  /// **'不错，很有耐心'**
  String get product_detail_sample_review;

  /// No description provided for @product_detail_sample_user.
  ///
  /// In zh, this message translates to:
  /// **'瑞123'**
  String get product_detail_sample_user;

  /// No description provided for @product_reviews_title.
  ///
  /// In zh, this message translates to:
  /// **'评论'**
  String get product_reviews_title;

  /// No description provided for @product_reviews_loading_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String product_reviews_loading_failed(String error);

  /// No description provided for @product_reviews_retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get product_reviews_retry;

  /// No description provided for @product_reviews_no_reviews.
  ///
  /// In zh, this message translates to:
  /// **'暂无评论'**
  String get product_reviews_no_reviews;

  /// No description provided for @product_reviews_sample_content.
  ///
  /// In zh, this message translates to:
  /// **'不错，很有耐心'**
  String get product_reviews_sample_content;

  /// No description provided for @product_reviews_years_ago.
  ///
  /// In zh, this message translates to:
  /// **'{count}年前'**
  String product_reviews_years_ago(int count);

  /// No description provided for @product_reviews_months_ago.
  ///
  /// In zh, this message translates to:
  /// **'{count}月前'**
  String product_reviews_months_ago(int count);

  /// No description provided for @product_reviews_days_ago.
  ///
  /// In zh, this message translates to:
  /// **'{count}天前'**
  String product_reviews_days_ago(int count);

  /// No description provided for @product_reviews_hours_ago.
  ///
  /// In zh, this message translates to:
  /// **'{count}小时前'**
  String product_reviews_hours_ago(int count);

  /// No description provided for @product_reviews_minutes_ago.
  ///
  /// In zh, this message translates to:
  /// **'{count}分钟前'**
  String product_reviews_minutes_ago(int count);

  /// No description provided for @product_reviews_just_now.
  ///
  /// In zh, this message translates to:
  /// **'刚刚'**
  String get product_reviews_just_now;

  /// No description provided for @product_reviews_seller_reply.
  ///
  /// In zh, this message translates to:
  /// **'卖家回复'**
  String get product_reviews_seller_reply;

  /// No description provided for @product_reviews_total_count.
  ///
  /// In zh, this message translates to:
  /// **'共{count}条评价'**
  String product_reviews_total_count(int count);

  /// No description provided for @product_reviews_filter_all.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get product_reviews_filter_all;

  /// No description provided for @product_reviews_filter_with_images.
  ///
  /// In zh, this message translates to:
  /// **'有图'**
  String get product_reviews_filter_with_images;

  /// No description provided for @product_reviews_filter_good.
  ///
  /// In zh, this message translates to:
  /// **'好评'**
  String get product_reviews_filter_good;

  /// No description provided for @product_reviews_filter_medium.
  ///
  /// In zh, this message translates to:
  /// **'中评'**
  String get product_reviews_filter_medium;

  /// No description provided for @product_reviews_filter_bad.
  ///
  /// In zh, this message translates to:
  /// **'差评'**
  String get product_reviews_filter_bad;

  /// No description provided for @seller_profile_default_title.
  ///
  /// In zh, this message translates to:
  /// **'卖家主页'**
  String get seller_profile_default_title;

  /// No description provided for @seller_profile_seller.
  ///
  /// In zh, this message translates to:
  /// **'卖家'**
  String get seller_profile_seller;

  /// No description provided for @seller_profile_no_description.
  ///
  /// In zh, this message translates to:
  /// **'暂无简介'**
  String get seller_profile_no_description;

  /// No description provided for @seller_profile_followers.
  ///
  /// In zh, this message translates to:
  /// **'{count}粉丝'**
  String seller_profile_followers(int count);

  /// No description provided for @seller_profile_followed.
  ///
  /// In zh, this message translates to:
  /// **'已关注'**
  String get seller_profile_followed;

  /// No description provided for @seller_profile_follow.
  ///
  /// In zh, this message translates to:
  /// **'关注'**
  String get seller_profile_follow;

  /// No description provided for @seller_profile_unfollow_success.
  ///
  /// In zh, this message translates to:
  /// **'取消关注成功'**
  String get seller_profile_unfollow_success;

  /// No description provided for @seller_profile_follow_success.
  ///
  /// In zh, this message translates to:
  /// **'关注成功'**
  String get seller_profile_follow_success;

  /// No description provided for @seller_profile_chat_failed.
  ///
  /// In zh, this message translates to:
  /// **'创建聊天失败: {error}'**
  String seller_profile_chat_failed(String error);

  /// No description provided for @seller_profile_error_occurred.
  ///
  /// In zh, this message translates to:
  /// **'发生错误: {error}'**
  String seller_profile_error_occurred(String error);

  /// No description provided for @seller_profile_about_merchant.
  ///
  /// In zh, this message translates to:
  /// **'关于商家'**
  String get seller_profile_about_merchant;

  /// No description provided for @seller_profile_my_services.
  ///
  /// In zh, this message translates to:
  /// **'我的服务'**
  String get seller_profile_my_services;

  /// No description provided for @seller_profile_no_merchant_info.
  ///
  /// In zh, this message translates to:
  /// **'暂无商家信息'**
  String get seller_profile_no_merchant_info;

  /// No description provided for @seller_profile_member_level.
  ///
  /// In zh, this message translates to:
  /// **'会员等级'**
  String get seller_profile_member_level;

  /// No description provided for @seller_profile_level_two.
  ///
  /// In zh, this message translates to:
  /// **'二级会员'**
  String get seller_profile_level_two;

  /// No description provided for @seller_profile_seller_rating.
  ///
  /// In zh, this message translates to:
  /// **'卖家评分'**
  String get seller_profile_seller_rating;

  /// No description provided for @seller_profile_response_time.
  ///
  /// In zh, this message translates to:
  /// **'回应时间'**
  String get seller_profile_response_time;

  /// No description provided for @seller_profile_response_hours.
  ///
  /// In zh, this message translates to:
  /// **'3小时'**
  String get seller_profile_response_hours;

  /// No description provided for @seller_profile_certification_status.
  ///
  /// In zh, this message translates to:
  /// **'认证状态'**
  String get seller_profile_certification_status;

  /// No description provided for @seller_profile_certified.
  ///
  /// In zh, this message translates to:
  /// **'已认证'**
  String get seller_profile_certified;

  /// No description provided for @seller_profile_not_certified.
  ///
  /// In zh, this message translates to:
  /// **'未认证'**
  String get seller_profile_not_certified;

  /// No description provided for @seller_profile_no_products.
  ///
  /// In zh, this message translates to:
  /// **'暂无商品'**
  String get seller_profile_no_products;

  /// No description provided for @seller_profile_image_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'图片加载失败'**
  String get seller_profile_image_load_failed;

  /// No description provided for @seller_profile_no_image.
  ///
  /// In zh, this message translates to:
  /// **'暂无图片'**
  String get seller_profile_no_image;

  /// No description provided for @seller_profile_title.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get seller_profile_title;

  /// No description provided for @seller_profile_auth_management.
  ///
  /// In zh, this message translates to:
  /// **'认证管理'**
  String get seller_profile_auth_management;

  /// No description provided for @seller_profile_my_wallet.
  ///
  /// In zh, this message translates to:
  /// **'我的钱包'**
  String get seller_profile_my_wallet;

  /// No description provided for @seller_profile_time_management.
  ///
  /// In zh, this message translates to:
  /// **'时间管理'**
  String get seller_profile_time_management;

  /// No description provided for @seller_profile_settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get seller_profile_settings;

  /// No description provided for @seller_profile_notifications.
  ///
  /// In zh, this message translates to:
  /// **'消息通知'**
  String get seller_profile_notifications;

  /// No description provided for @seller_profile_about_us.
  ///
  /// In zh, this message translates to:
  /// **'关于我们'**
  String get seller_profile_about_us;

  /// No description provided for @seller_profile_mission.
  ///
  /// In zh, this message translates to:
  /// **'小粽子的使命'**
  String get seller_profile_mission;

  /// No description provided for @seller_profile_user_name.
  ///
  /// In zh, this message translates to:
  /// **'瑞'**
  String get seller_profile_user_name;

  /// No description provided for @seller_profile_seller_mode_online.
  ///
  /// In zh, this message translates to:
  /// **'卖家模式：在线'**
  String get seller_profile_seller_mode_online;

  /// No description provided for @seller_profile_seller_mode.
  ///
  /// In zh, this message translates to:
  /// **'卖家模式'**
  String get seller_profile_seller_mode;

  /// No description provided for @seller_profile_buyer_mode.
  ///
  /// In zh, this message translates to:
  /// **'买家模式'**
  String get seller_profile_buyer_mode;

  /// No description provided for @seller_profile_my_orders.
  ///
  /// In zh, this message translates to:
  /// **'我的订单'**
  String get seller_profile_my_orders;

  /// No description provided for @seller_profile_order_pending.
  ///
  /// In zh, this message translates to:
  /// **'待确认'**
  String get seller_profile_order_pending;

  /// No description provided for @seller_profile_order_processing.
  ///
  /// In zh, this message translates to:
  /// **'进行中'**
  String get seller_profile_order_processing;

  /// No description provided for @seller_profile_order_delivered.
  ///
  /// In zh, this message translates to:
  /// **'已交付'**
  String get seller_profile_order_delivered;

  /// No description provided for @seller_profile_order_refund.
  ///
  /// In zh, this message translates to:
  /// **'退款/售后'**
  String get seller_profile_order_refund;

  /// No description provided for @seller_profile_feature_not_implemented.
  ///
  /// In zh, this message translates to:
  /// **'{feature}功能尚未实现'**
  String seller_profile_feature_not_implemented(String feature);

  /// No description provided for @seller_home_loading_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get seller_home_loading_failed;

  /// No description provided for @seller_home_no_data.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get seller_home_no_data;

  /// No description provided for @seller_home_no_store_info.
  ///
  /// In zh, this message translates to:
  /// **'暂无店铺信息'**
  String get seller_home_no_store_info;

  /// No description provided for @seller_home_online.
  ///
  /// In zh, this message translates to:
  /// **'在线'**
  String get seller_home_online;

  /// No description provided for @seller_home_offline.
  ///
  /// In zh, this message translates to:
  /// **'离线'**
  String get seller_home_offline;

  /// No description provided for @seller_home_completion_rate.
  ///
  /// In zh, this message translates to:
  /// **'完成率 {rate}%'**
  String seller_home_completion_rate(String rate);

  /// No description provided for @seller_home_switch_to_buyer.
  ///
  /// In zh, this message translates to:
  /// **'切换到买家模式'**
  String get seller_home_switch_to_buyer;

  /// No description provided for @seller_home_switch_failed.
  ///
  /// In zh, this message translates to:
  /// **'无法切换到买家模式: {error}'**
  String seller_home_switch_failed(String error);

  /// No description provided for @seller_home_income.
  ///
  /// In zh, this message translates to:
  /// **'收入'**
  String get seller_home_income;

  /// No description provided for @seller_home_view_details.
  ///
  /// In zh, this message translates to:
  /// **'查看明细'**
  String get seller_home_view_details;

  /// No description provided for @seller_home_total_income.
  ///
  /// In zh, this message translates to:
  /// **'总收入'**
  String get seller_home_total_income;

  /// No description provided for @seller_home_today_income.
  ///
  /// In zh, this message translates to:
  /// **'今日收入'**
  String get seller_home_today_income;

  /// No description provided for @seller_home_pending_settlement.
  ///
  /// In zh, this message translates to:
  /// **'待结算'**
  String get seller_home_pending_settlement;

  /// No description provided for @seller_home_orders.
  ///
  /// In zh, this message translates to:
  /// **'订单'**
  String get seller_home_orders;

  /// No description provided for @seller_home_view_all.
  ///
  /// In zh, this message translates to:
  /// **'查看全部'**
  String get seller_home_view_all;

  /// No description provided for @seller_home_orders_all.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get seller_home_orders_all;

  /// No description provided for @seller_home_orders_pending.
  ///
  /// In zh, this message translates to:
  /// **'待处理'**
  String get seller_home_orders_pending;

  /// No description provided for @seller_home_orders_processing.
  ///
  /// In zh, this message translates to:
  /// **'进行中'**
  String get seller_home_orders_processing;

  /// No description provided for @seller_home_orders_aftersales.
  ///
  /// In zh, this message translates to:
  /// **'售后中'**
  String get seller_home_orders_aftersales;

  /// No description provided for @seller_home_orders_awaiting_delivery.
  ///
  /// In zh, this message translates to:
  /// **'待发货'**
  String get seller_home_orders_awaiting_delivery;

  /// No description provided for @seller_home_orders_completed.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get seller_home_orders_completed;

  /// No description provided for @seller_home_orders_canceled.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get seller_home_orders_canceled;

  /// No description provided for @seller_home_functions.
  ///
  /// In zh, this message translates to:
  /// **'功能'**
  String get seller_home_functions;

  /// No description provided for @seller_home_wallet.
  ///
  /// In zh, this message translates to:
  /// **'钱包'**
  String get seller_home_wallet;

  /// No description provided for @seller_home_auth_management.
  ///
  /// In zh, this message translates to:
  /// **'认证管理'**
  String get seller_home_auth_management;

  /// No description provided for @seller_home_time_management.
  ///
  /// In zh, this message translates to:
  /// **'时间管理'**
  String get seller_home_time_management;

  /// No description provided for @seller_home_auto_reply.
  ///
  /// In zh, this message translates to:
  /// **'自动回复'**
  String get seller_home_auto_reply;

  /// No description provided for @seller_home_recent_income.
  ///
  /// In zh, this message translates to:
  /// **'近期收入'**
  String get seller_home_recent_income;

  /// No description provided for @seller_home_no_recent_income.
  ///
  /// In zh, this message translates to:
  /// **'暂无近期收入数据'**
  String get seller_home_no_recent_income;

  /// No description provided for @seller_home_no_income_data.
  ///
  /// In zh, this message translates to:
  /// **'暂无收入数据'**
  String get seller_home_no_income_data;

  /// No description provided for @seller_statistics_title.
  ///
  /// In zh, this message translates to:
  /// **'卖家数据'**
  String get seller_statistics_title;

  /// No description provided for @seller_statistics_seller_homepage.
  ///
  /// In zh, this message translates to:
  /// **'卖家主页'**
  String get seller_statistics_seller_homepage;

  /// No description provided for @seller_statistics_heat_value.
  ///
  /// In zh, this message translates to:
  /// **'热度值'**
  String get seller_statistics_heat_value;

  /// No description provided for @seller_statistics_reply_rate.
  ///
  /// In zh, this message translates to:
  /// **'回复率'**
  String get seller_statistics_reply_rate;

  /// No description provided for @seller_statistics_completion_rate.
  ///
  /// In zh, this message translates to:
  /// **'完成率'**
  String get seller_statistics_completion_rate;

  /// No description provided for @seller_statistics_positive_rate.
  ///
  /// In zh, this message translates to:
  /// **'好评率'**
  String get seller_statistics_positive_rate;

  /// No description provided for @seller_statistics_upgrade_to_next_level.
  ///
  /// In zh, this message translates to:
  /// **'升到下一级'**
  String get seller_statistics_upgrade_to_next_level;

  /// No description provided for @seller_statistics_become_level3_seller.
  ///
  /// In zh, this message translates to:
  /// **'成为三级会员卖家{days}天'**
  String seller_statistics_become_level3_seller(String days);

  /// No description provided for @seller_statistics_complete_orders.
  ///
  /// In zh, this message translates to:
  /// **'完成订单{orderNum}笔'**
  String seller_statistics_complete_orders(String orderNum);

  /// No description provided for @seller_statistics_profit_amount.
  ///
  /// In zh, this message translates to:
  /// **'盈利{amount}元'**
  String seller_statistics_profit_amount(String amount);

  /// No description provided for @seller_statistics_indicators.
  ///
  /// In zh, this message translates to:
  /// **'指标'**
  String get seller_statistics_indicators;

  /// No description provided for @seller_statistics_total_earnings.
  ///
  /// In zh, this message translates to:
  /// **'总盈利'**
  String get seller_statistics_total_earnings;

  /// No description provided for @seller_statistics_monthly_earnings.
  ///
  /// In zh, this message translates to:
  /// **'本月盈利'**
  String get seller_statistics_monthly_earnings;

  /// No description provided for @seller_statistics_total_orders.
  ///
  /// In zh, this message translates to:
  /// **'总订单数'**
  String get seller_statistics_total_orders;

  /// No description provided for @seller_statistics_active_orders.
  ///
  /// In zh, this message translates to:
  /// **'活跃订单数'**
  String get seller_statistics_active_orders;

  /// No description provided for @seller_statistics_pending.
  ///
  /// In zh, this message translates to:
  /// **'待处理'**
  String get seller_statistics_pending;

  /// No description provided for @seller_statistics_incomplete_orders.
  ///
  /// In zh, this message translates to:
  /// **'未完成订单数'**
  String get seller_statistics_incomplete_orders;

  /// No description provided for @seller_statistics_pending_completion.
  ///
  /// In zh, this message translates to:
  /// **'待完成'**
  String get seller_statistics_pending_completion;

  /// No description provided for @seller_statistics_receipt.
  ///
  /// In zh, this message translates to:
  /// **'回单'**
  String get seller_statistics_receipt;

  /// No description provided for @seller_statistics_next_delivery_date.
  ///
  /// In zh, this message translates to:
  /// **'距离下次邀交日'**
  String get seller_statistics_next_delivery_date;

  /// No description provided for @seller_statistics_earliest.
  ///
  /// In zh, this message translates to:
  /// **'最早'**
  String get seller_statistics_earliest;

  /// No description provided for @seller_statistics_loading_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String seller_statistics_loading_failed(String error);

  /// No description provided for @seller_statistics_retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get seller_statistics_retry;

  /// No description provided for @seller_auth_management_title.
  ///
  /// In zh, this message translates to:
  /// **'认证管理'**
  String get seller_auth_management_title;

  /// No description provided for @seller_auth_management_certified_items.
  ///
  /// In zh, this message translates to:
  /// **'已认证项目'**
  String get seller_auth_management_certified_items;

  /// No description provided for @seller_auth_management_open_certification.
  ///
  /// In zh, this message translates to:
  /// **'开放认证'**
  String get seller_auth_management_open_certification;

  /// No description provided for @seller_auth_management_no_items.
  ///
  /// In zh, this message translates to:
  /// **'暂无认证项目'**
  String get seller_auth_management_no_items;

  /// No description provided for @seller_auth_management_unknown_status.
  ///
  /// In zh, this message translates to:
  /// **'未知状态'**
  String get seller_auth_management_unknown_status;

  /// No description provided for @seller_auth_management_certified.
  ///
  /// In zh, this message translates to:
  /// **'已认证'**
  String get seller_auth_management_certified;

  /// No description provided for @seller_auth_management_pending.
  ///
  /// In zh, this message translates to:
  /// **'审核中'**
  String get seller_auth_management_pending;

  /// No description provided for @seller_auth_management_rejected.
  ///
  /// In zh, this message translates to:
  /// **'未通过'**
  String get seller_auth_management_rejected;

  /// No description provided for @seller_auth_management_not_submitted.
  ///
  /// In zh, this message translates to:
  /// **'未提交'**
  String get seller_auth_management_not_submitted;

  /// No description provided for @seller_auth_management_server_timeout.
  ///
  /// In zh, this message translates to:
  /// **'服务器响应超时'**
  String get seller_auth_management_server_timeout;

  /// No description provided for @seller_auth_management_server_timeout_desc.
  ///
  /// In zh, this message translates to:
  /// **'服务器处理请求时间过长，请稍后重试'**
  String get seller_auth_management_server_timeout_desc;

  /// No description provided for @seller_auth_management_network_error.
  ///
  /// In zh, this message translates to:
  /// **'网络连接异常'**
  String get seller_auth_management_network_error;

  /// No description provided for @seller_auth_management_network_error_desc.
  ///
  /// In zh, this message translates to:
  /// **'无法连接到服务器，请检查网络设置'**
  String get seller_auth_management_network_error_desc;

  /// No description provided for @seller_auth_management_loading_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get seller_auth_management_loading_failed;

  /// No description provided for @seller_auth_management_unknown_error.
  ///
  /// In zh, this message translates to:
  /// **'发生未知错误，请重试'**
  String get seller_auth_management_unknown_error;

  /// No description provided for @seller_auth_management_troubleshooting.
  ///
  /// In zh, this message translates to:
  /// **'故障排除建议：'**
  String get seller_auth_management_troubleshooting;

  /// No description provided for @seller_auth_management_check_network.
  ///
  /// In zh, this message translates to:
  /// **'• 检查网络连接是否稳定'**
  String get seller_auth_management_check_network;

  /// No description provided for @seller_auth_management_wait_retry.
  ///
  /// In zh, this message translates to:
  /// **'• 等待几分钟后重新尝试'**
  String get seller_auth_management_wait_retry;

  /// No description provided for @seller_auth_management_contact_support.
  ///
  /// In zh, this message translates to:
  /// **'• 如问题持续存在，请联系客服'**
  String get seller_auth_management_contact_support;

  /// No description provided for @seller_auth_management_check_wifi.
  ///
  /// In zh, this message translates to:
  /// **'• 检查WiFi或移动数据连接'**
  String get seller_auth_management_check_wifi;

  /// No description provided for @seller_auth_management_switch_network.
  ///
  /// In zh, this message translates to:
  /// **'• 尝试切换网络环境'**
  String get seller_auth_management_switch_network;

  /// No description provided for @seller_auth_management_restart_app.
  ///
  /// In zh, this message translates to:
  /// **'• 关闭并重新打开应用'**
  String get seller_auth_management_restart_app;

  /// No description provided for @seller_auth_management_check_connection.
  ///
  /// In zh, this message translates to:
  /// **'• 检查网络连接状态'**
  String get seller_auth_management_check_connection;

  /// No description provided for @seller_auth_management_try_later.
  ///
  /// In zh, this message translates to:
  /// **'• 稍后重新尝试'**
  String get seller_auth_management_try_later;

  /// No description provided for @seller_auth_management_contact_tech.
  ///
  /// In zh, this message translates to:
  /// **'• 如问题持续存在，请联系技术支持'**
  String get seller_auth_management_contact_tech;

  /// No description provided for @seller_auth_management_reload.
  ///
  /// In zh, this message translates to:
  /// **'重新加载'**
  String get seller_auth_management_reload;

  /// No description provided for @seller_auth_management_back.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get seller_auth_management_back;

  /// No description provided for @seller_auth_application_title.
  ///
  /// In zh, this message translates to:
  /// **'{type}认证'**
  String seller_auth_application_title(String type);

  /// No description provided for @seller_auth_application_desc.
  ///
  /// In zh, this message translates to:
  /// **'{type}认证说明'**
  String seller_auth_application_desc(String type);

  /// No description provided for @seller_auth_application_review_time.
  ///
  /// In zh, this message translates to:
  /// **'认证审核通常需要1-3个工作日，请耐心等待。'**
  String get seller_auth_application_review_time;

  /// No description provided for @seller_auth_application_basic_info.
  ///
  /// In zh, this message translates to:
  /// **'基本信息'**
  String get seller_auth_application_basic_info;

  /// No description provided for @seller_auth_application_company_name.
  ///
  /// In zh, this message translates to:
  /// **'公司名称'**
  String get seller_auth_application_company_name;

  /// No description provided for @seller_auth_application_company_name_hint.
  ///
  /// In zh, this message translates to:
  /// **'请输入公司全称'**
  String get seller_auth_application_company_name_hint;

  /// No description provided for @seller_auth_application_company_name_required.
  ///
  /// In zh, this message translates to:
  /// **'请输入公司名称'**
  String get seller_auth_application_company_name_required;

  /// No description provided for @seller_auth_application_credit_code.
  ///
  /// In zh, this message translates to:
  /// **'统一社会信用代码'**
  String get seller_auth_application_credit_code;

  /// No description provided for @seller_auth_application_credit_code_hint.
  ///
  /// In zh, this message translates to:
  /// **'请输入18位统一社会信用代码'**
  String get seller_auth_application_credit_code_hint;

  /// No description provided for @seller_auth_application_credit_code_required.
  ///
  /// In zh, this message translates to:
  /// **'请输入统一社会信用代码'**
  String get seller_auth_application_credit_code_required;

  /// No description provided for @seller_auth_application_credit_code_invalid.
  ///
  /// In zh, this message translates to:
  /// **'统一社会信用代码应为18位'**
  String get seller_auth_application_credit_code_invalid;

  /// No description provided for @seller_auth_application_company_intro.
  ///
  /// In zh, this message translates to:
  /// **'企业简介'**
  String get seller_auth_application_company_intro;

  /// No description provided for @seller_auth_application_company_intro_hint.
  ///
  /// In zh, this message translates to:
  /// **'请简要描述公司业务和情况'**
  String get seller_auth_application_company_intro_hint;

  /// No description provided for @seller_auth_application_real_name.
  ///
  /// In zh, this message translates to:
  /// **'姓名'**
  String get seller_auth_application_real_name;

  /// No description provided for @seller_auth_application_real_name_hint.
  ///
  /// In zh, this message translates to:
  /// **'请输入您的真实姓名'**
  String get seller_auth_application_real_name_hint;

  /// No description provided for @seller_auth_application_real_name_required.
  ///
  /// In zh, this message translates to:
  /// **'请输入姓名'**
  String get seller_auth_application_real_name_required;

  /// No description provided for @seller_auth_application_id_number.
  ///
  /// In zh, this message translates to:
  /// **'身份证号码'**
  String get seller_auth_application_id_number;

  /// No description provided for @seller_auth_application_id_number_hint.
  ///
  /// In zh, this message translates to:
  /// **'请输入18位身份证号码'**
  String get seller_auth_application_id_number_hint;

  /// No description provided for @seller_auth_application_id_number_required.
  ///
  /// In zh, this message translates to:
  /// **'请输入身份证号码'**
  String get seller_auth_application_id_number_required;

  /// No description provided for @seller_auth_application_id_number_invalid.
  ///
  /// In zh, this message translates to:
  /// **'身份证号码应为18位'**
  String get seller_auth_application_id_number_invalid;

  /// No description provided for @seller_auth_application_school_name.
  ///
  /// In zh, this message translates to:
  /// **'学校名称'**
  String get seller_auth_application_school_name;

  /// No description provided for @seller_auth_application_school_name_hint.
  ///
  /// In zh, this message translates to:
  /// **'请输入学校全称'**
  String get seller_auth_application_school_name_hint;

  /// No description provided for @seller_auth_application_school_name_required.
  ///
  /// In zh, this message translates to:
  /// **'请输入学校名称'**
  String get seller_auth_application_school_name_required;

  /// No description provided for @seller_auth_application_degree.
  ///
  /// In zh, this message translates to:
  /// **'学历/学位'**
  String get seller_auth_application_degree;

  /// No description provided for @seller_auth_application_degree_hint.
  ///
  /// In zh, this message translates to:
  /// **'如：本科、硕士等'**
  String get seller_auth_application_degree_hint;

  /// No description provided for @seller_auth_application_degree_required.
  ///
  /// In zh, this message translates to:
  /// **'请输入学历/学位'**
  String get seller_auth_application_degree_required;

  /// No description provided for @seller_auth_application_major.
  ///
  /// In zh, this message translates to:
  /// **'专业'**
  String get seller_auth_application_major;

  /// No description provided for @seller_auth_application_major_hint.
  ///
  /// In zh, this message translates to:
  /// **'请输入专业名称'**
  String get seller_auth_application_major_hint;

  /// No description provided for @seller_auth_application_profession.
  ///
  /// In zh, this message translates to:
  /// **'职业/职位'**
  String get seller_auth_application_profession;

  /// No description provided for @seller_auth_application_profession_hint.
  ///
  /// In zh, this message translates to:
  /// **'请输入您的职业或职位'**
  String get seller_auth_application_profession_hint;

  /// No description provided for @seller_auth_application_profession_required.
  ///
  /// In zh, this message translates to:
  /// **'请输入职业/职位'**
  String get seller_auth_application_profession_required;

  /// No description provided for @seller_auth_application_cert_number.
  ///
  /// In zh, this message translates to:
  /// **'证书编号'**
  String get seller_auth_application_cert_number;

  /// No description provided for @seller_auth_application_cert_number_hint.
  ///
  /// In zh, this message translates to:
  /// **'请输入职业资格证书编号'**
  String get seller_auth_application_cert_number_hint;

  /// No description provided for @seller_auth_application_work_experience.
  ///
  /// In zh, this message translates to:
  /// **'工作经验'**
  String get seller_auth_application_work_experience;

  /// No description provided for @seller_auth_application_work_experience_hint.
  ///
  /// In zh, this message translates to:
  /// **'请简要描述您的工作经验'**
  String get seller_auth_application_work_experience_hint;

  /// No description provided for @seller_auth_application_auth_name.
  ///
  /// In zh, this message translates to:
  /// **'认证名称'**
  String get seller_auth_application_auth_name;

  /// No description provided for @seller_auth_application_auth_name_hint.
  ///
  /// In zh, this message translates to:
  /// **'请输入认证名称'**
  String get seller_auth_application_auth_name_hint;

  /// No description provided for @seller_auth_application_auth_name_required.
  ///
  /// In zh, this message translates to:
  /// **'请输入认证名称'**
  String get seller_auth_application_auth_name_required;

  /// No description provided for @seller_auth_application_auth_identifier.
  ///
  /// In zh, this message translates to:
  /// **'认证标识'**
  String get seller_auth_application_auth_identifier;

  /// No description provided for @seller_auth_application_auth_identifier_hint.
  ///
  /// In zh, this message translates to:
  /// **'请输入认证标识或编号'**
  String get seller_auth_application_auth_identifier_hint;

  /// No description provided for @seller_auth_application_auth_description.
  ///
  /// In zh, this message translates to:
  /// **'认证描述'**
  String get seller_auth_application_auth_description;

  /// No description provided for @seller_auth_application_auth_description_hint.
  ///
  /// In zh, this message translates to:
  /// **'请描述认证内容'**
  String get seller_auth_application_auth_description_hint;

  /// No description provided for @seller_auth_application_upload_materials.
  ///
  /// In zh, this message translates to:
  /// **'上传证明材料'**
  String get seller_auth_application_upload_materials;

  /// No description provided for @seller_auth_application_upload_file.
  ///
  /// In zh, this message translates to:
  /// **'上传文件'**
  String get seller_auth_application_upload_file;

  /// No description provided for @seller_auth_application_selected_files.
  ///
  /// In zh, this message translates to:
  /// **'已选择 {count} 个文件'**
  String seller_auth_application_selected_files(int count);

  /// No description provided for @seller_auth_application_selected_images.
  ///
  /// In zh, this message translates to:
  /// **'已选择的图片：'**
  String get seller_auth_application_selected_images;

  /// No description provided for @seller_auth_application_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get seller_auth_application_load_failed;

  /// No description provided for @seller_auth_application_id_upload_hint.
  ///
  /// In zh, this message translates to:
  /// **'请上传清晰的身份证正反面照片，确保信息清晰可见，不得遮挡、涂改'**
  String get seller_auth_application_id_upload_hint;

  /// No description provided for @seller_auth_application_education_upload_hint.
  ///
  /// In zh, this message translates to:
  /// **'请上传学历证书、学位证书等证明材料，需包含完整信息'**
  String get seller_auth_application_education_upload_hint;

  /// No description provided for @seller_auth_application_profession_upload_hint.
  ///
  /// In zh, this message translates to:
  /// **'请上传职业资格证书、专业技能证书等证明材料'**
  String get seller_auth_application_profession_upload_hint;

  /// No description provided for @seller_auth_application_company_upload_hint.
  ///
  /// In zh, this message translates to:
  /// **'请上传营业执照、组织机构代码证等企业资质证明材料'**
  String get seller_auth_application_company_upload_hint;

  /// No description provided for @seller_auth_application_default_upload_hint.
  ///
  /// In zh, this message translates to:
  /// **'请上传相关证明材料，确保图片清晰、信息完整'**
  String get seller_auth_application_default_upload_hint;

  /// No description provided for @seller_auth_application_agreement_read.
  ///
  /// In zh, this message translates to:
  /// **'我已阅读并同意'**
  String get seller_auth_application_agreement_read;

  /// No description provided for @seller_auth_application_agreement_link.
  ///
  /// In zh, this message translates to:
  /// **'《认证服务协议》'**
  String get seller_auth_application_agreement_link;

  /// No description provided for @seller_auth_application_agreement_guarantee.
  ///
  /// In zh, this message translates to:
  /// **'，保证所提供的信息真实有效'**
  String get seller_auth_application_agreement_guarantee;

  /// No description provided for @seller_auth_application_agreement_title.
  ///
  /// In zh, this message translates to:
  /// **'认证服务协议'**
  String get seller_auth_application_agreement_title;

  /// No description provided for @seller_auth_application_agreement_content.
  ///
  /// In zh, this message translates to:
  /// **'本协议是您与DSKK平台之间关于认证服务的法律协议。请您仔细阅读以下条款，确保完全理解本协议中的所有权利和义务。\n\n一、服务内容\nDSKK平台提供认证服务，旨在验证您提供的身份、资质等信息的真实性，提高您在平台上的可信度。\n\n二、用户义务\n1. 您应当提供真实、准确、完整的认证信息和材料。\n2. 您应当确保提供的认证材料不侵犯任何第三方的合法权益。\n\n三、平台权利与义务\n1. 平台有权对您提供的认证信息和材料进行审核。\n2. 平台将在合理的时间内完成审核，并告知您审核结果。'**
  String get seller_auth_application_agreement_content;

  /// No description provided for @seller_auth_application_agreement_close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get seller_auth_application_agreement_close;

  /// No description provided for @seller_auth_application_agreement_agree.
  ///
  /// In zh, this message translates to:
  /// **'同意'**
  String get seller_auth_application_agreement_agree;

  /// No description provided for @seller_auth_application_submit.
  ///
  /// In zh, this message translates to:
  /// **'提交认证申请'**
  String get seller_auth_application_submit;

  /// No description provided for @seller_auth_application_check_form.
  ///
  /// In zh, this message translates to:
  /// **'请检查表单填写是否正确'**
  String get seller_auth_application_check_form;

  /// No description provided for @seller_auth_application_submit_success.
  ///
  /// In zh, this message translates to:
  /// **'提交成功'**
  String get seller_auth_application_submit_success;

  /// No description provided for @seller_auth_application_submit_success_desc.
  ///
  /// In zh, this message translates to:
  /// **'您的认证申请已提交，我们将在1-3个工作日内完成审核，请耐心等待。'**
  String get seller_auth_application_submit_success_desc;

  /// No description provided for @seller_auth_application_ok.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get seller_auth_application_ok;

  /// No description provided for @seller_auth_application_select_file_failed.
  ///
  /// In zh, this message translates to:
  /// **'选择文件失败: {error}'**
  String seller_auth_application_select_file_failed(String error);

  /// No description provided for @product_management_title.
  ///
  /// In zh, this message translates to:
  /// **'商品管理'**
  String get product_management_title;

  /// No description provided for @product_management_tab_on_sale.
  ///
  /// In zh, this message translates to:
  /// **'在售'**
  String get product_management_tab_on_sale;

  /// No description provided for @product_management_tab_draft.
  ///
  /// In zh, this message translates to:
  /// **'草稿箱'**
  String get product_management_tab_draft;

  /// No description provided for @product_management_tab_off_shelf.
  ///
  /// In zh, this message translates to:
  /// **'已下架'**
  String get product_management_tab_off_shelf;

  /// No description provided for @product_management_action_off_shelf.
  ///
  /// In zh, this message translates to:
  /// **'下架'**
  String get product_management_action_off_shelf;

  /// No description provided for @product_management_action_on_shelf.
  ///
  /// In zh, this message translates to:
  /// **'上架'**
  String get product_management_action_on_shelf;

  /// No description provided for @product_management_action_edit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get product_management_action_edit;

  /// No description provided for @product_management_action_delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get product_management_action_delete;

  /// No description provided for @product_management_action_publish.
  ///
  /// In zh, this message translates to:
  /// **'发布'**
  String get product_management_action_publish;

  /// No description provided for @product_management_action_resubmit.
  ///
  /// In zh, this message translates to:
  /// **'重新提交'**
  String get product_management_action_resubmit;

  /// No description provided for @product_management_status_reviewing.
  ///
  /// In zh, this message translates to:
  /// **'审核中'**
  String get product_management_status_reviewing;

  /// No description provided for @product_management_status_rejected.
  ///
  /// In zh, this message translates to:
  /// **'审核失败'**
  String get product_management_status_rejected;

  /// No description provided for @product_management_status_on_shelf.
  ///
  /// In zh, this message translates to:
  /// **'已上架'**
  String get product_management_status_on_shelf;

  /// No description provided for @product_management_status_off_shelf.
  ///
  /// In zh, this message translates to:
  /// **'已下架'**
  String get product_management_status_off_shelf;

  /// No description provided for @product_management_status_draft.
  ///
  /// In zh, this message translates to:
  /// **'草稿'**
  String get product_management_status_draft;

  /// No description provided for @product_management_status_waiting_review.
  ///
  /// In zh, this message translates to:
  /// **'等待审核'**
  String get product_management_status_waiting_review;

  /// No description provided for @product_management_status_unknown.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get product_management_status_unknown;

  /// No description provided for @product_management_stock_label.
  ///
  /// In zh, this message translates to:
  /// **'库存'**
  String get product_management_stock_label;

  /// No description provided for @product_management_sales_label.
  ///
  /// In zh, this message translates to:
  /// **'销量'**
  String get product_management_sales_label;

  /// No description provided for @product_management_create_product.
  ///
  /// In zh, this message translates to:
  /// **'创建商品'**
  String get product_management_create_product;

  /// No description provided for @product_management_no_more_products.
  ///
  /// In zh, this message translates to:
  /// **'没有更多商品了'**
  String get product_management_no_more_products;

  /// No description provided for @product_management_empty_on_sale.
  ///
  /// In zh, this message translates to:
  /// **'暂无在售商品'**
  String get product_management_empty_on_sale;

  /// No description provided for @product_management_empty_draft.
  ///
  /// In zh, this message translates to:
  /// **'暂无草稿商品'**
  String get product_management_empty_draft;

  /// No description provided for @product_management_empty_off_shelf.
  ///
  /// In zh, this message translates to:
  /// **'暂无已下架商品'**
  String get product_management_empty_off_shelf;

  /// No description provided for @product_management_empty_default.
  ///
  /// In zh, this message translates to:
  /// **'暂无商品数据'**
  String get product_management_empty_default;

  /// No description provided for @product_management_draft_preview_hint.
  ///
  /// In zh, this message translates to:
  /// **'草稿状态的商品需要先发布才能预览'**
  String get product_management_draft_preview_hint;

  /// No description provided for @product_management_confirm_off_shelf_title.
  ///
  /// In zh, this message translates to:
  /// **'确认下架'**
  String get product_management_confirm_off_shelf_title;

  /// No description provided for @product_management_confirm_off_shelf_message.
  ///
  /// In zh, this message translates to:
  /// **'确定要下架商品 \"{name}\" 吗？'**
  String product_management_confirm_off_shelf_message(String name);

  /// No description provided for @product_management_confirm_off_shelf_desc.
  ///
  /// In zh, this message translates to:
  /// **'下架后：'**
  String get product_management_confirm_off_shelf_desc;

  /// No description provided for @product_management_confirm_off_shelf_point1.
  ///
  /// In zh, this message translates to:
  /// **'• 买家将无法看到和购买此商品'**
  String get product_management_confirm_off_shelf_point1;

  /// No description provided for @product_management_confirm_off_shelf_point2.
  ///
  /// In zh, this message translates to:
  /// **'• 您可以随时重新上架'**
  String get product_management_confirm_off_shelf_point2;

  /// No description provided for @product_management_confirm_off_shelf_point3.
  ///
  /// In zh, this message translates to:
  /// **'• 商品数据会被保留'**
  String get product_management_confirm_off_shelf_point3;

  /// No description provided for @product_management_confirm_delete_title.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get product_management_confirm_delete_title;

  /// No description provided for @product_management_confirm_delete_message.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除这个商品吗？此操作不可撤销。'**
  String get product_management_confirm_delete_message;

  /// No description provided for @product_management_cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get product_management_cancel;

  /// No description provided for @product_management_confirm.
  ///
  /// In zh, this message translates to:
  /// **'确认下架'**
  String get product_management_confirm;

  /// No description provided for @product_management_delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get product_management_delete;

  /// No description provided for @product_edit_title_create.
  ///
  /// In zh, this message translates to:
  /// **'创建商品'**
  String get product_edit_title_create;

  /// No description provided for @product_edit_title_edit.
  ///
  /// In zh, this message translates to:
  /// **'编辑商品'**
  String get product_edit_title_edit;

  /// No description provided for @product_edit_basic_info.
  ///
  /// In zh, this message translates to:
  /// **'基础信息'**
  String get product_edit_basic_info;

  /// No description provided for @product_edit_product_name.
  ///
  /// In zh, this message translates to:
  /// **'商品名称'**
  String get product_edit_product_name;

  /// No description provided for @product_edit_product_name_hint.
  ///
  /// In zh, this message translates to:
  /// **'请输入商品名称'**
  String get product_edit_product_name_hint;

  /// No description provided for @product_edit_product_description.
  ///
  /// In zh, this message translates to:
  /// **'商品描述'**
  String get product_edit_product_description;

  /// No description provided for @product_edit_product_description_hint.
  ///
  /// In zh, this message translates to:
  /// **'请输入商品描述'**
  String get product_edit_product_description_hint;

  /// No description provided for @product_edit_product_price.
  ///
  /// In zh, this message translates to:
  /// **'商品价格'**
  String get product_edit_product_price;

  /// No description provided for @product_edit_product_images.
  ///
  /// In zh, this message translates to:
  /// **'商品图片'**
  String get product_edit_product_images;

  /// No description provided for @product_edit_add_image.
  ///
  /// In zh, this message translates to:
  /// **'添加图片'**
  String get product_edit_add_image;

  /// No description provided for @product_edit_uploading.
  ///
  /// In zh, this message translates to:
  /// **'上传中...'**
  String get product_edit_uploading;

  /// No description provided for @product_edit_service_tiers.
  ///
  /// In zh, this message translates to:
  /// **'服务档位设置'**
  String get product_edit_service_tiers;

  /// No description provided for @product_edit_detail_intro.
  ///
  /// In zh, this message translates to:
  /// **'详情介绍'**
  String get product_edit_detail_intro;

  /// No description provided for @product_edit_save_draft.
  ///
  /// In zh, this message translates to:
  /// **'保存草稿'**
  String get product_edit_save_draft;

  /// No description provided for @product_edit_publish_product.
  ///
  /// In zh, this message translates to:
  /// **'发布商品'**
  String get product_edit_publish_product;

  /// No description provided for @product_edit_preview_product.
  ///
  /// In zh, this message translates to:
  /// **'预览商品'**
  String get product_edit_preview_product;

  /// No description provided for @product_edit_at_least_one_image.
  ///
  /// In zh, this message translates to:
  /// **'请至少上传一张商品图片'**
  String get product_edit_at_least_one_image;

  /// No description provided for @product_edit_save_draft_dialog_title.
  ///
  /// In zh, this message translates to:
  /// **'保存草稿'**
  String get product_edit_save_draft_dialog_title;

  /// No description provided for @product_edit_save_draft_dialog_message.
  ///
  /// In zh, this message translates to:
  /// **'是否保存为草稿？'**
  String get product_edit_save_draft_dialog_message;

  /// No description provided for @product_edit_save_draft_dialog_confirm.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get product_edit_save_draft_dialog_confirm;

  /// No description provided for @product_edit_edit_attribute.
  ///
  /// In zh, this message translates to:
  /// **'编辑商品属性'**
  String get product_edit_edit_attribute;

  /// No description provided for @product_edit_validation_name_required.
  ///
  /// In zh, this message translates to:
  /// **'请输入商品名称'**
  String get product_edit_validation_name_required;

  /// No description provided for @product_edit_validation_description_required.
  ///
  /// In zh, this message translates to:
  /// **'请输入商品描述'**
  String get product_edit_validation_description_required;

  /// No description provided for @product_edit_validation_image_required.
  ///
  /// In zh, this message translates to:
  /// **'请至少上传一张商品图片'**
  String get product_edit_validation_image_required;

  /// No description provided for @product_preview_current_seller.
  ///
  /// In zh, this message translates to:
  /// **'当前卖家'**
  String get product_preview_current_seller;

  /// No description provided for @product_preview_seller_user.
  ///
  /// In zh, this message translates to:
  /// **'卖家用户'**
  String get product_preview_seller_user;

  /// No description provided for @product_edit_success_cases.
  ///
  /// In zh, this message translates to:
  /// **'成功案例'**
  String get product_edit_success_cases;

  /// No description provided for @product_edit_add_success_case.
  ///
  /// In zh, this message translates to:
  /// **'添加成功案例'**
  String get product_edit_add_success_case;

  /// No description provided for @product_edit_edit_success_case.
  ///
  /// In zh, this message translates to:
  /// **'编辑成功案例'**
  String get product_edit_edit_success_case;

  /// No description provided for @product_edit_uploading_progress.
  ///
  /// In zh, this message translates to:
  /// **'上传中 {uploaded}/{total}'**
  String product_edit_uploading_progress(int uploaded, int total);

  /// No description provided for @product_edit_please_enter_label.
  ///
  /// In zh, this message translates to:
  /// **'请输入信息标签'**
  String get product_edit_please_enter_label;

  /// No description provided for @product_edit_please_enter_attribute_name.
  ///
  /// In zh, this message translates to:
  /// **'请输入属性名称'**
  String get product_edit_please_enter_attribute_name;

  /// No description provided for @product_edit_attribute_name_hint.
  ///
  /// In zh, this message translates to:
  /// **'请输入属性名称'**
  String get product_edit_attribute_name_hint;

  /// No description provided for @product_edit_placeholder_hint.
  ///
  /// In zh, this message translates to:
  /// **'例如：请选择颜色、请输入型号'**
  String get product_edit_placeholder_hint;

  /// No description provided for @product_edit_placeholder_label.
  ///
  /// In zh, this message translates to:
  /// **'占位符文本'**
  String get product_edit_placeholder_label;

  /// No description provided for @product_edit_product_preview_title.
  ///
  /// In zh, this message translates to:
  /// **'商品预览'**
  String get product_edit_product_preview_title;

  /// No description provided for @product_edit_publish_service.
  ///
  /// In zh, this message translates to:
  /// **'发布服务'**
  String get product_edit_publish_service;

  /// No description provided for @product_edit_edit_service.
  ///
  /// In zh, this message translates to:
  /// **'编辑服务'**
  String get product_edit_edit_service;

  /// No description provided for @product_edit_max_characters.
  ///
  /// In zh, this message translates to:
  /// **'最多{max}个字符'**
  String product_edit_max_characters(int max);

  /// No description provided for @after_sales_review_title.
  ///
  /// In zh, this message translates to:
  /// **'售后审核'**
  String get after_sales_review_title;

  /// No description provided for @after_sales_detail_title.
  ///
  /// In zh, this message translates to:
  /// **'售后详情'**
  String get after_sales_detail_title;

  /// No description provided for @after_sales_refresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get after_sales_refresh;

  /// No description provided for @after_sales_no_pending.
  ///
  /// In zh, this message translates to:
  /// **'暂无待审核的售后申请'**
  String get after_sales_no_pending;

  /// No description provided for @after_sales_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败，请重试'**
  String get after_sales_load_failed;

  /// No description provided for @after_sales_not_found.
  ///
  /// In zh, this message translates to:
  /// **'找不到对应的售后申请'**
  String get after_sales_not_found;

  /// No description provided for @after_sales_order_number.
  ///
  /// In zh, this message translates to:
  /// **'订单编号'**
  String get after_sales_order_number;

  /// No description provided for @after_sales_apply_type.
  ///
  /// In zh, this message translates to:
  /// **'申请类型'**
  String get after_sales_apply_type;

  /// No description provided for @after_sales_apply_time.
  ///
  /// In zh, this message translates to:
  /// **'申请时间'**
  String get after_sales_apply_time;

  /// No description provided for @after_sales_refund_amount.
  ///
  /// In zh, this message translates to:
  /// **'退款金额'**
  String get after_sales_refund_amount;

  /// No description provided for @after_sales_refund_type.
  ///
  /// In zh, this message translates to:
  /// **'退款类型'**
  String get after_sales_refund_type;

  /// No description provided for @after_sales_apply_reason.
  ///
  /// In zh, this message translates to:
  /// **'申请原因'**
  String get after_sales_apply_reason;

  /// No description provided for @after_sales_image_evidence.
  ///
  /// In zh, this message translates to:
  /// **'图片证据'**
  String get after_sales_image_evidence;

  /// No description provided for @after_sales_image_view.
  ///
  /// In zh, this message translates to:
  /// **'图片查看'**
  String get after_sales_image_view;

  /// No description provided for @after_sales_image_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'图片加载失败'**
  String get after_sales_image_load_failed;

  /// No description provided for @after_sales_reject.
  ///
  /// In zh, this message translates to:
  /// **'拒绝'**
  String get after_sales_reject;

  /// No description provided for @after_sales_agree.
  ///
  /// In zh, this message translates to:
  /// **'同意'**
  String get after_sales_agree;

  /// No description provided for @after_sales_reject_application.
  ///
  /// In zh, this message translates to:
  /// **'拒绝申请'**
  String get after_sales_reject_application;

  /// No description provided for @after_sales_agree_application.
  ///
  /// In zh, this message translates to:
  /// **'同意申请'**
  String get after_sales_agree_application;

  /// No description provided for @after_sales_confirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get after_sales_confirm;

  /// No description provided for @after_sales_cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get after_sales_cancel;

  /// No description provided for @after_sales_confirm_title.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get after_sales_confirm_title;

  /// No description provided for @after_sales_confirm_message.
  ///
  /// In zh, this message translates to:
  /// **'确定同意此售后申请吗？'**
  String get after_sales_confirm_message;

  /// No description provided for @after_sales_reject_reason.
  ///
  /// In zh, this message translates to:
  /// **'拒绝原因'**
  String get after_sales_reject_reason;

  /// No description provided for @after_sales_reject_reason_hint.
  ///
  /// In zh, this message translates to:
  /// **'请输入拒绝原因'**
  String get after_sales_reject_reason_hint;

  /// No description provided for @after_sales_reject_reason_required.
  ///
  /// In zh, this message translates to:
  /// **'请输入拒绝原因'**
  String get after_sales_reject_reason_required;

  /// No description provided for @after_sales_type_refund_only.
  ///
  /// In zh, this message translates to:
  /// **'仅退款'**
  String get after_sales_type_refund_only;

  /// No description provided for @after_sales_type_refund_return.
  ///
  /// In zh, this message translates to:
  /// **'退货退款'**
  String get after_sales_type_refund_return;

  /// No description provided for @after_sales_type_unknown.
  ///
  /// In zh, this message translates to:
  /// **'未知类型'**
  String get after_sales_type_unknown;

  /// No description provided for @after_sales_status_wait_audit.
  ///
  /// In zh, this message translates to:
  /// **'待审核'**
  String get after_sales_status_wait_audit;

  /// No description provided for @after_sales_status_refused.
  ///
  /// In zh, this message translates to:
  /// **'已拒绝'**
  String get after_sales_status_refused;

  /// No description provided for @after_sales_status_audit_pass.
  ///
  /// In zh, this message translates to:
  /// **'审核通过'**
  String get after_sales_status_audit_pass;

  /// No description provided for @after_sales_status_buyer_shipped.
  ///
  /// In zh, this message translates to:
  /// **'买家已发货'**
  String get after_sales_status_buyer_shipped;

  /// No description provided for @after_sales_status_seller_received.
  ///
  /// In zh, this message translates to:
  /// **'卖家已收货'**
  String get after_sales_status_seller_received;

  /// No description provided for @after_sales_status_finished.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get after_sales_status_finished;

  /// No description provided for @after_sales_status_canceled.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get after_sales_status_canceled;

  /// No description provided for @after_sales_status_unknown.
  ///
  /// In zh, this message translates to:
  /// **'未知状态'**
  String get after_sales_status_unknown;

  /// No description provided for @time_management_title.
  ///
  /// In zh, this message translates to:
  /// **'时间管理'**
  String get time_management_title;

  /// No description provided for @time_management_current_status.
  ///
  /// In zh, this message translates to:
  /// **'当前状态'**
  String get time_management_current_status;

  /// No description provided for @time_management_online.
  ///
  /// In zh, this message translates to:
  /// **'在线'**
  String get time_management_online;

  /// No description provided for @time_management_offline.
  ///
  /// In zh, this message translates to:
  /// **'离线'**
  String get time_management_offline;

  /// No description provided for @time_management_online_status_description.
  ///
  /// In zh, this message translates to:
  /// **'在线状态说明'**
  String get time_management_online_status_description;

  /// No description provided for @time_management_offline_status_description.
  ///
  /// In zh, this message translates to:
  /// **'离线状态说明'**
  String get time_management_offline_status_description;

  /// No description provided for @time_management_online_description.
  ///
  /// In zh, this message translates to:
  /// **'您当前处于在线状态，买家可以向您发送消息，您将收到新消息的通知。请确保及时回复买家消息，保持良好的响应率有助于提高您的服务质量评分。'**
  String get time_management_online_description;

  /// No description provided for @time_management_offline_description.
  ///
  /// In zh, this message translates to:
  /// **'您当前处于离线状态，买家仍然可以向您发送消息，但系统会告知买家您暂时不在线。您仍然会收到新消息的通知，但可能无法立即回复。长时间保持离线状态可能会影响您的接单效率。'**
  String get time_management_offline_description;

  /// No description provided for @time_management_save_settings.
  ///
  /// In zh, this message translates to:
  /// **'保存设置'**
  String get time_management_save_settings;

  /// No description provided for @time_management_settings_saved.
  ///
  /// In zh, this message translates to:
  /// **'设置已保存'**
  String get time_management_settings_saved;

  /// No description provided for @time_management_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get time_management_load_failed;

  /// No description provided for @time_management_retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get time_management_retry;

  /// No description provided for @time_management_unknown_status.
  ///
  /// In zh, this message translates to:
  /// **'未知状态'**
  String get time_management_unknown_status;

  /// No description provided for @auto_reply_title.
  ///
  /// In zh, this message translates to:
  /// **'自动回复设置'**
  String get auto_reply_title;

  /// No description provided for @auto_reply_enable.
  ///
  /// In zh, this message translates to:
  /// **'自动回复'**
  String get auto_reply_enable;

  /// No description provided for @auto_reply_content.
  ///
  /// In zh, this message translates to:
  /// **'回复内容'**
  String get auto_reply_content;

  /// No description provided for @auto_reply_content_hint.
  ///
  /// In zh, this message translates to:
  /// **'请输入自动回复内容'**
  String get auto_reply_content_hint;

  /// No description provided for @auto_reply_content_description.
  ///
  /// In zh, this message translates to:
  /// **'当客户发送消息时，系统会自动回复此内容'**
  String get auto_reply_content_description;

  /// No description provided for @auto_reply_save_settings.
  ///
  /// In zh, this message translates to:
  /// **'保存设置'**
  String get auto_reply_save_settings;

  /// No description provided for @auto_reply_settings_saved.
  ///
  /// In zh, this message translates to:
  /// **'设置已保存'**
  String get auto_reply_settings_saved;

  /// No description provided for @auto_reply_content_required.
  ///
  /// In zh, this message translates to:
  /// **'回复内容不能为空'**
  String get auto_reply_content_required;

  /// No description provided for @auto_reply_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败，请重试'**
  String get auto_reply_load_failed;

  /// No description provided for @order_delivery_title.
  ///
  /// In zh, this message translates to:
  /// **'订单交付'**
  String get order_delivery_title;

  /// No description provided for @order_delivery_title_with_sn.
  ///
  /// In zh, this message translates to:
  /// **'订单交付: {orderSn}'**
  String order_delivery_title_with_sn(String orderSn);

  /// No description provided for @order_delivery_submitting.
  ///
  /// In zh, this message translates to:
  /// **'正在提交交付内容...'**
  String get order_delivery_submitting;

  /// No description provided for @order_delivery_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败，请重试'**
  String get order_delivery_load_failed;

  /// No description provided for @order_delivery_instruction_title.
  ///
  /// In zh, this message translates to:
  /// **'订单交付说明'**
  String get order_delivery_instruction_title;

  /// No description provided for @order_delivery_instruction_content.
  ///
  /// In zh, this message translates to:
  /// **'请提交您针对此订单的交付内容。您可以提供详细说明以及附加相关文件，确保买家能够清晰了解您提供的服务或产品。'**
  String get order_delivery_instruction_content;

  /// No description provided for @order_delivery_content_label.
  ///
  /// In zh, this message translates to:
  /// **'交付内容描述:'**
  String get order_delivery_content_label;

  /// No description provided for @order_delivery_content_hint.
  ///
  /// In zh, this message translates to:
  /// **'请描述您的交付内容...'**
  String get order_delivery_content_hint;

  /// No description provided for @order_delivery_attachments_label.
  ///
  /// In zh, this message translates to:
  /// **'附件文件:'**
  String get order_delivery_attachments_label;

  /// No description provided for @order_delivery_submit_button.
  ///
  /// In zh, this message translates to:
  /// **'提交交付'**
  String get order_delivery_submit_button;

  /// No description provided for @order_delivery_content_required.
  ///
  /// In zh, this message translates to:
  /// **'请输入交付内容描述'**
  String get order_delivery_content_required;

  /// No description provided for @order_delivery_submit_success.
  ///
  /// In zh, this message translates to:
  /// **'交付内容提交成功'**
  String get order_delivery_submit_success;

  /// No description provided for @order_delivery_logistics_company.
  ///
  /// In zh, this message translates to:
  /// **'物流公司'**
  String get order_delivery_logistics_company;

  /// No description provided for @order_delivery_tracking_number.
  ///
  /// In zh, this message translates to:
  /// **'物流单号'**
  String get order_delivery_tracking_number;

  /// No description provided for @order_delivery_shipping_address.
  ///
  /// In zh, this message translates to:
  /// **'发货地址'**
  String get order_delivery_shipping_address;

  /// No description provided for @order_delivery_receiving_address.
  ///
  /// In zh, this message translates to:
  /// **'收货地址'**
  String get order_delivery_receiving_address;

  /// No description provided for @order_delivery_status_pending.
  ///
  /// In zh, this message translates to:
  /// **'待发货'**
  String get order_delivery_status_pending;

  /// No description provided for @order_delivery_status_shipped.
  ///
  /// In zh, this message translates to:
  /// **'已发货'**
  String get order_delivery_status_shipped;

  /// No description provided for @order_delivery_status_received.
  ///
  /// In zh, this message translates to:
  /// **'已收货'**
  String get order_delivery_status_received;

  /// No description provided for @order_delivery_status_in_transit.
  ///
  /// In zh, this message translates to:
  /// **'配送中'**
  String get order_delivery_status_in_transit;

  /// No description provided for @order_delivery_confirm_shipment.
  ///
  /// In zh, this message translates to:
  /// **'确认发货'**
  String get order_delivery_confirm_shipment;

  /// No description provided for @order_delivery_view_details.
  ///
  /// In zh, this message translates to:
  /// **'查看详情'**
  String get order_delivery_view_details;

  /// No description provided for @order_delivery_no_pending_orders.
  ///
  /// In zh, this message translates to:
  /// **'暂无待发货订单'**
  String get order_delivery_no_pending_orders;

  /// No description provided for @notification_center_title.
  ///
  /// In zh, this message translates to:
  /// **'通知中心'**
  String get notification_center_title;

  /// No description provided for @notification_tab_all.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get notification_tab_all;

  /// No description provided for @notification_tab_order.
  ///
  /// In zh, this message translates to:
  /// **'订单'**
  String get notification_tab_order;

  /// No description provided for @notification_tab_system.
  ///
  /// In zh, this message translates to:
  /// **'系统'**
  String get notification_tab_system;

  /// No description provided for @notification_tab_refund.
  ///
  /// In zh, this message translates to:
  /// **'售后'**
  String get notification_tab_refund;

  /// No description provided for @notification_tab_message.
  ///
  /// In zh, this message translates to:
  /// **'消息'**
  String get notification_tab_message;

  /// No description provided for @notification_type_order.
  ///
  /// In zh, this message translates to:
  /// **'订单通知'**
  String get notification_type_order;

  /// No description provided for @notification_type_system.
  ///
  /// In zh, this message translates to:
  /// **'系统通知'**
  String get notification_type_system;

  /// No description provided for @notification_type_refund.
  ///
  /// In zh, this message translates to:
  /// **'售后通知'**
  String get notification_type_refund;

  /// No description provided for @notification_type_message.
  ///
  /// In zh, this message translates to:
  /// **'消息通知'**
  String get notification_type_message;

  /// No description provided for @notification_type_review.
  ///
  /// In zh, this message translates to:
  /// **'评价通知'**
  String get notification_type_review;

  /// No description provided for @notification_type_authentication.
  ///
  /// In zh, this message translates to:
  /// **'认证通知'**
  String get notification_type_authentication;

  /// No description provided for @notification_type_other.
  ///
  /// In zh, this message translates to:
  /// **'其他通知'**
  String get notification_type_other;

  /// No description provided for @notification_status_unread.
  ///
  /// In zh, this message translates to:
  /// **'未读'**
  String get notification_status_unread;

  /// No description provided for @notification_status_read.
  ///
  /// In zh, this message translates to:
  /// **'已读'**
  String get notification_status_read;

  /// No description provided for @notification_mark_all_read.
  ///
  /// In zh, this message translates to:
  /// **'全部标记已读'**
  String get notification_mark_all_read;

  /// No description provided for @notification_empty_all.
  ///
  /// In zh, this message translates to:
  /// **'暂无任何通知'**
  String get notification_empty_all;

  /// No description provided for @notification_empty_order.
  ///
  /// In zh, this message translates to:
  /// **'暂无订单通知'**
  String get notification_empty_order;

  /// No description provided for @notification_empty_system.
  ///
  /// In zh, this message translates to:
  /// **'暂无系统通知'**
  String get notification_empty_system;

  /// No description provided for @notification_empty_refund.
  ///
  /// In zh, this message translates to:
  /// **'暂无售后通知'**
  String get notification_empty_refund;

  /// No description provided for @notification_empty_message.
  ///
  /// In zh, this message translates to:
  /// **'暂无消息通知'**
  String get notification_empty_message;

  /// No description provided for @notification_empty_review.
  ///
  /// In zh, this message translates to:
  /// **'暂无评价通知'**
  String get notification_empty_review;

  /// No description provided for @notification_empty_authentication.
  ///
  /// In zh, this message translates to:
  /// **'暂无认证通知'**
  String get notification_empty_authentication;

  /// No description provided for @notification_empty_other.
  ///
  /// In zh, this message translates to:
  /// **'暂无其他通知'**
  String get notification_empty_other;

  /// No description provided for @notification_empty_generic.
  ///
  /// In zh, this message translates to:
  /// **'暂无通知'**
  String get notification_empty_generic;

  /// No description provided for @notification_refresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get notification_refresh;

  /// No description provided for @notification_retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get notification_retry;

  /// No description provided for @notification_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载通知中心失败: {error}'**
  String notification_load_failed(String error);

  /// No description provided for @notification_detail_title.
  ///
  /// In zh, this message translates to:
  /// **'通知详情'**
  String get notification_detail_title;

  /// No description provided for @notification_detail_view.
  ///
  /// In zh, this message translates to:
  /// **'查看详情'**
  String get notification_detail_view;

  /// No description provided for @notification_detail_close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get notification_detail_close;

  /// No description provided for @notification_click_to_view.
  ///
  /// In zh, this message translates to:
  /// **'点击查看详情'**
  String get notification_click_to_view;

  /// No description provided for @notification_default_title.
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get notification_default_title;

  /// No description provided for @notification_time_just_now.
  ///
  /// In zh, this message translates to:
  /// **'刚刚'**
  String get notification_time_just_now;

  /// No description provided for @notification_time_minutes_ago.
  ///
  /// In zh, this message translates to:
  /// **'{minutes}分钟前'**
  String notification_time_minutes_ago(int minutes);

  /// No description provided for @notification_time_hours_ago.
  ///
  /// In zh, this message translates to:
  /// **'{hours}小时前'**
  String notification_time_hours_ago(int hours);

  /// No description provided for @notification_time_days_ago.
  ///
  /// In zh, this message translates to:
  /// **'{days}天前'**
  String notification_time_days_ago(int days);

  /// No description provided for @notification_time_months_ago.
  ///
  /// In zh, this message translates to:
  /// **'{months}个月前'**
  String notification_time_months_ago(int months);

  /// No description provided for @materialsInfo.
  ///
  /// In zh, this message translates to:
  /// **'材料信息'**
  String get materialsInfo;

  /// No description provided for @buyerSubmittedMaterials.
  ///
  /// In zh, this message translates to:
  /// **'买家提交的材料'**
  String get buyerSubmittedMaterials;

  /// No description provided for @sellerDeliveryContent.
  ///
  /// In zh, this message translates to:
  /// **'卖家交付内容'**
  String get sellerDeliveryContent;

  /// No description provided for @noBuyerMaterials.
  ///
  /// In zh, this message translates to:
  /// **'暂无买家提交的材料'**
  String get noBuyerMaterials;

  /// No description provided for @noSellerDelivery.
  ///
  /// In zh, this message translates to:
  /// **'卖家暂未交付内容'**
  String get noSellerDelivery;

  /// No description provided for @attachments.
  ///
  /// In zh, this message translates to:
  /// **'附件:'**
  String get attachments;

  /// No description provided for @deliveryFiles.
  ///
  /// In zh, this message translates to:
  /// **'交付文件:'**
  String get deliveryFiles;

  /// No description provided for @deliveryDescription.
  ///
  /// In zh, this message translates to:
  /// **'交付说明'**
  String get deliveryDescription;

  /// No description provided for @tapToPreview.
  ///
  /// In zh, this message translates to:
  /// **'点击预览'**
  String get tapToPreview;

  /// No description provided for @tapToOpen.
  ///
  /// In zh, this message translates to:
  /// **'点击打开'**
  String get tapToOpen;

  /// No description provided for @downloadFile.
  ///
  /// In zh, this message translates to:
  /// **'下载文件'**
  String get downloadFile;

  /// No description provided for @storagePermissionDenied.
  ///
  /// In zh, this message translates to:
  /// **'存储权限被拒绝'**
  String get storagePermissionDenied;

  /// No description provided for @cancelDownload.
  ///
  /// In zh, this message translates to:
  /// **'取消下载'**
  String get cancelDownload;

  /// No description provided for @pageLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'页面加载失败'**
  String get pageLoadFailed;

  /// No description provided for @openFile.
  ///
  /// In zh, this message translates to:
  /// **'打开文件'**
  String get openFile;

  /// No description provided for @downloaded.
  ///
  /// In zh, this message translates to:
  /// **'已下载'**
  String get downloaded;

  /// No description provided for @downloadCompleted.
  ///
  /// In zh, this message translates to:
  /// **'下载完成'**
  String get downloadCompleted;

  /// No description provided for @downloadFailed.
  ///
  /// In zh, this message translates to:
  /// **'下载失败'**
  String get downloadFailed;

  /// No description provided for @openFileFailed.
  ///
  /// In zh, this message translates to:
  /// **'打开文件失败'**
  String get openFileFailed;

  /// No description provided for @storagePermissionRequired.
  ///
  /// In zh, this message translates to:
  /// **'需要存储权限才能下载文件'**
  String get storagePermissionRequired;

  /// No description provided for @pdfLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'PDF加载失败'**
  String get pdfLoadFailed;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// No description provided for @product_detail_translated_from.
  ///
  /// In zh, this message translates to:
  /// **'翻译自{language}'**
  String product_detail_translated_from(String language);

  /// No description provided for @product_detail_translation_auto.
  ///
  /// In zh, this message translates to:
  /// **'自动翻译'**
  String get product_detail_translation_auto;

  /// No description provided for @product_detail_show_original.
  ///
  /// In zh, this message translates to:
  /// **'显示原文'**
  String get product_detail_show_original;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'vi', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
