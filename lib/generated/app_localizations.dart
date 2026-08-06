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
  /// **'【DeepStream】'**
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

  /// No description provided for @chat_unsupported_message.
  ///
  /// In zh, this message translates to:
  /// **'该消息暂不支持查看'**
  String get chat_unsupported_message;

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

  /// No description provided for @chat_summary_hidden.
  ///
  /// In zh, this message translates to:
  /// **'该需求摘要生成异常，已隐藏'**
  String get chat_summary_hidden;

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
  /// **'买家消息'**
  String get chat_filter_buyer;

  /// No description provided for @chat_filter_seller.
  ///
  /// In zh, this message translates to:
  /// **'卖家消息'**
  String get chat_filter_seller;

  /// No description provided for @chat_filter_mode_all.
  ///
  /// In zh, this message translates to:
  /// **'显示全部聊天'**
  String get chat_filter_mode_all;

  /// No description provided for @chat_filter_mode_buyer.
  ///
  /// In zh, this message translates to:
  /// **'只显示买家消息'**
  String get chat_filter_mode_buyer;

  /// No description provided for @chat_filter_mode_seller.
  ///
  /// In zh, this message translates to:
  /// **'只显示卖家消息'**
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

  /// No description provided for @home_refreshing_recommendations.
  ///
  /// In zh, this message translates to:
  /// **'正在刷新推荐...'**
  String get home_refreshing_recommendations;

  /// No description provided for @home_loading_more.
  ///
  /// In zh, this message translates to:
  /// **'正在加载更多...'**
  String get home_loading_more;

  /// No description provided for @home_back_to_top_refresh.
  ///
  /// In zh, this message translates to:
  /// **'回到顶部并刷新'**
  String get home_back_to_top_refresh;

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

  /// No description provided for @seller_profile_seller_mode_offline.
  ///
  /// In zh, this message translates to:
  /// **'卖家模式：离线'**
  String get seller_profile_seller_mode_offline;

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

  /// No description provided for @seller_home_provider_task_center.
  ///
  /// In zh, this message translates to:
  /// **'接单任务'**
  String get seller_home_provider_task_center;

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

  /// No description provided for @order_status_awaiting_payment.
  ///
  /// In zh, this message translates to:
  /// **'待付款'**
  String get order_status_awaiting_payment;

  /// No description provided for @order_status_awaiting_submission.
  ///
  /// In zh, this message translates to:
  /// **'待提交'**
  String get order_status_awaiting_submission;

  /// No description provided for @order_status_buy_awaiting_submission.
  ///
  /// In zh, this message translates to:
  /// **'待重传'**
  String get order_status_buy_awaiting_submission;

  /// No description provided for @order_status_awaiting_start.
  ///
  /// In zh, this message translates to:
  /// **'待接单'**
  String get order_status_awaiting_start;

  /// No description provided for @order_status_awaiting_delivery.
  ///
  /// In zh, this message translates to:
  /// **'待发货'**
  String get order_status_awaiting_delivery;

  /// No description provided for @order_status_awaiting_confirmation.
  ///
  /// In zh, this message translates to:
  /// **'待收货'**
  String get order_status_awaiting_confirmation;

  /// No description provided for @order_status_awaiting_evaluation.
  ///
  /// In zh, this message translates to:
  /// **'待评价'**
  String get order_status_awaiting_evaluation;

  /// No description provided for @order_status_completed.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get order_status_completed;

  /// No description provided for @order_status_canceled.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get order_status_canceled;

  /// No description provided for @order_status_after_sale.
  ///
  /// In zh, this message translates to:
  /// **'售后中'**
  String get order_status_after_sale;

  /// No description provided for @order_status_unknown.
  ///
  /// In zh, this message translates to:
  /// **'未知状态'**
  String get order_status_unknown;

  /// No description provided for @order_action_cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消订单'**
  String get order_action_cancel;

  /// No description provided for @order_action_go_pay.
  ///
  /// In zh, this message translates to:
  /// **'去支付'**
  String get order_action_go_pay;

  /// No description provided for @order_action_submit_materials.
  ///
  /// In zh, this message translates to:
  /// **'提交材料'**
  String get order_action_submit_materials;

  /// No description provided for @order_action_contact_support.
  ///
  /// In zh, this message translates to:
  /// **'联系客服'**
  String get order_action_contact_support;

  /// No description provided for @order_action_view_feedback.
  ///
  /// In zh, this message translates to:
  /// **'查看反馈'**
  String get order_action_view_feedback;

  /// No description provided for @order_action_remind_delivery.
  ///
  /// In zh, this message translates to:
  /// **'提醒发货'**
  String get order_action_remind_delivery;

  /// No description provided for @order_action_platform_intervention.
  ///
  /// In zh, this message translates to:
  /// **'平台介入'**
  String get order_action_platform_intervention;

  /// No description provided for @order_action_view_delivery.
  ///
  /// In zh, this message translates to:
  /// **'查看交付'**
  String get order_action_view_delivery;

  /// No description provided for @order_action_apply_after_sale.
  ///
  /// In zh, this message translates to:
  /// **'申请售后'**
  String get order_action_apply_after_sale;

  /// No description provided for @order_action_confirm_receipt.
  ///
  /// In zh, this message translates to:
  /// **'确认收货'**
  String get order_action_confirm_receipt;

  /// No description provided for @order_action_view_logistics.
  ///
  /// In zh, this message translates to:
  /// **'查看物流'**
  String get order_action_view_logistics;

  /// No description provided for @order_action_go_evaluate.
  ///
  /// In zh, this message translates to:
  /// **'去评价'**
  String get order_action_go_evaluate;

  /// No description provided for @order_action_apply_rework.
  ///
  /// In zh, this message translates to:
  /// **'申请重做'**
  String get order_action_apply_rework;

  /// No description provided for @order_action_delete_order.
  ///
  /// In zh, this message translates to:
  /// **'删除订单'**
  String get order_action_delete_order;

  /// No description provided for @order_action_view_order.
  ///
  /// In zh, this message translates to:
  /// **'查看订单'**
  String get order_action_view_order;

  /// No description provided for @order_action_view_details.
  ///
  /// In zh, this message translates to:
  /// **'查看详情'**
  String get order_action_view_details;

  /// No description provided for @order_action_processing.
  ///
  /// In zh, this message translates to:
  /// **'处理中...'**
  String get order_action_processing;

  /// No description provided for @order_confirm_cancel_title.
  ///
  /// In zh, this message translates to:
  /// **'取消订单'**
  String get order_confirm_cancel_title;

  /// No description provided for @order_confirm_cancel_content.
  ///
  /// In zh, this message translates to:
  /// **'您确定要取消这个订单吗？'**
  String get order_confirm_cancel_content;

  /// No description provided for @order_confirm_receipt_title.
  ///
  /// In zh, this message translates to:
  /// **'确认收货'**
  String get order_confirm_receipt_title;

  /// No description provided for @order_confirm_receipt_content.
  ///
  /// In zh, this message translates to:
  /// **'您确定已经收到货品，并确认收货吗？'**
  String get order_confirm_receipt_content;

  /// No description provided for @order_confirm_delete_title.
  ///
  /// In zh, this message translates to:
  /// **'删除订单'**
  String get order_confirm_delete_title;

  /// No description provided for @order_confirm_delete_content.
  ///
  /// In zh, this message translates to:
  /// **'您确定要删除这个订单吗？删除后将无法恢复。'**
  String get order_confirm_delete_content;

  /// No description provided for @order_dialog_cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get order_dialog_cancel;

  /// No description provided for @order_dialog_confirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get order_dialog_confirm;

  /// No description provided for @order_dialog_close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get order_dialog_close;

  /// No description provided for @order_dialog_submit.
  ///
  /// In zh, this message translates to:
  /// **'提交申请'**
  String get order_dialog_submit;

  /// No description provided for @order_snackbar_connecting_support.
  ///
  /// In zh, this message translates to:
  /// **'正在连接客服...'**
  String get order_snackbar_connecting_support;

  /// No description provided for @order_snackbar_feedback_in_progress.
  ///
  /// In zh, this message translates to:
  /// **'查看卖家反馈功能开发中'**
  String get order_snackbar_feedback_in_progress;

  /// No description provided for @order_snackbar_reminded_delivery.
  ///
  /// In zh, this message translates to:
  /// **'已提醒卖家发货'**
  String get order_snackbar_reminded_delivery;

  /// No description provided for @order_snackbar_nav_failed.
  ///
  /// In zh, this message translates to:
  /// **'导航失败: {error}'**
  String order_snackbar_nav_failed(String error);

  /// No description provided for @order_snackbar_no_items_after_sale.
  ///
  /// In zh, this message translates to:
  /// **'错误：无法为没有商品的订单申请售后'**
  String get order_snackbar_no_items_after_sale;

  /// No description provided for @order_snackbar_no_items_evaluate.
  ///
  /// In zh, this message translates to:
  /// **'错误：无法为没有商品的订单进行评价'**
  String get order_snackbar_no_items_evaluate;

  /// No description provided for @order_snackbar_operation_failed.
  ///
  /// In zh, this message translates to:
  /// **'操作失败: {error}'**
  String order_snackbar_operation_failed(String error);

  /// No description provided for @order_dialog_data_not_loaded.
  ///
  /// In zh, this message translates to:
  /// **'数据未加载完成，请稍后再试'**
  String get order_dialog_data_not_loaded;

  /// No description provided for @order_dialog_view_delivery_title.
  ///
  /// In zh, this message translates to:
  /// **'查看交付'**
  String get order_dialog_view_delivery_title;

  /// No description provided for @order_dialog_seller_delivery_content.
  ///
  /// In zh, this message translates to:
  /// **'卖家交付内容：'**
  String get order_dialog_seller_delivery_content;

  /// No description provided for @order_dialog_buyer_materials.
  ///
  /// In zh, this message translates to:
  /// **'买家提交的材料：'**
  String get order_dialog_buyer_materials;

  /// No description provided for @order_dialog_no_seller_delivery.
  ///
  /// In zh, this message translates to:
  /// **'卖家暂未交付内容'**
  String get order_dialog_no_seller_delivery;

  /// No description provided for @order_dialog_no_buyer_materials.
  ///
  /// In zh, this message translates to:
  /// **'暂无买家提交的材料'**
  String get order_dialog_no_buyer_materials;

  /// No description provided for @order_dialog_delivery_note.
  ///
  /// In zh, this message translates to:
  /// **'交付说明: {content}'**
  String order_dialog_delivery_note(String content);

  /// No description provided for @order_dialog_delivery_files.
  ///
  /// In zh, this message translates to:
  /// **'交付文件:'**
  String get order_dialog_delivery_files;

  /// No description provided for @order_intervention_title.
  ///
  /// In zh, this message translates to:
  /// **'申请平台介入'**
  String get order_intervention_title;

  /// No description provided for @order_intervention_desc.
  ///
  /// In zh, this message translates to:
  /// **'遇到无法解决的争议？平台客服会在24小时内介入处理。'**
  String get order_intervention_desc;

  /// No description provided for @order_intervention_problem_type.
  ///
  /// In zh, this message translates to:
  /// **'问题类型:'**
  String get order_intervention_problem_type;

  /// No description provided for @order_intervention_problem_desc.
  ///
  /// In zh, this message translates to:
  /// **'问题描述:'**
  String get order_intervention_problem_desc;

  /// No description provided for @order_intervention_problem_hint.
  ///
  /// In zh, this message translates to:
  /// **'请详细描述遇到的问题...'**
  String get order_intervention_problem_hint;

  /// No description provided for @order_intervention_validation_empty.
  ///
  /// In zh, this message translates to:
  /// **'请输入问题描述'**
  String get order_intervention_validation_empty;

  /// No description provided for @order_intervention_validation_min.
  ///
  /// In zh, this message translates to:
  /// **'问题描述至少需要10个字符'**
  String get order_intervention_validation_min;

  /// No description provided for @order_intervention_tip.
  ///
  /// In zh, this message translates to:
  /// **'提示：申请提交后无法撤销，每个订单最多可申请2次。'**
  String get order_intervention_tip;

  /// No description provided for @order_intervention_reason_communication.
  ///
  /// In zh, this message translates to:
  /// **'沟通问题'**
  String get order_intervention_reason_communication;

  /// No description provided for @order_intervention_reason_quality.
  ///
  /// In zh, this message translates to:
  /// **'质量争议'**
  String get order_intervention_reason_quality;

  /// No description provided for @order_intervention_reason_delivery.
  ///
  /// In zh, this message translates to:
  /// **'交付问题'**
  String get order_intervention_reason_delivery;

  /// No description provided for @order_intervention_reason_refund.
  ///
  /// In zh, this message translates to:
  /// **'退款纠纷'**
  String get order_intervention_reason_refund;

  /// No description provided for @order_intervention_reason_service.
  ///
  /// In zh, this message translates to:
  /// **'服务态度'**
  String get order_intervention_reason_service;

  /// No description provided for @order_intervention_reason_other.
  ///
  /// In zh, this message translates to:
  /// **'其他问题'**
  String get order_intervention_reason_other;

  /// No description provided for @order_intervention_submitting.
  ///
  /// In zh, this message translates to:
  /// **'正在提交申请...'**
  String get order_intervention_submitting;

  /// No description provided for @order_intervention_failed.
  ///
  /// In zh, this message translates to:
  /// **'申请失败：{error}'**
  String order_intervention_failed(String error);

  /// No description provided for @order_demand_replenishment_title.
  ///
  /// In zh, this message translates to:
  /// **'申请补充材料'**
  String get order_demand_replenishment_title;

  /// No description provided for @order_demand_reform_title.
  ///
  /// In zh, this message translates to:
  /// **'申请重做'**
  String get order_demand_reform_title;

  /// No description provided for @order_demand_replenishment_desc.
  ///
  /// In zh, this message translates to:
  /// **'如果需要卖家补充更多材料或说明，请详细描述您的需求。'**
  String get order_demand_replenishment_desc;

  /// No description provided for @order_demand_reform_desc.
  ///
  /// In zh, this message translates to:
  /// **'如果对交付结果不满意，可以申请重做。请说明具体问题。'**
  String get order_demand_reform_desc;

  /// No description provided for @order_demand_detail_label.
  ///
  /// In zh, this message translates to:
  /// **'详细说明:'**
  String get order_demand_detail_label;

  /// No description provided for @order_demand_replenishment_hint.
  ///
  /// In zh, this message translates to:
  /// **'请详细说明需要补充的材料或信息...'**
  String get order_demand_replenishment_hint;

  /// No description provided for @order_demand_reform_hint.
  ///
  /// In zh, this message translates to:
  /// **'请详细说明需要重做的原因和要求...'**
  String get order_demand_reform_hint;

  /// No description provided for @order_demand_validation_empty.
  ///
  /// In zh, this message translates to:
  /// **'请输入详细说明'**
  String get order_demand_validation_empty;

  /// No description provided for @order_demand_validation_min.
  ///
  /// In zh, this message translates to:
  /// **'说明至少需要10个字符'**
  String get order_demand_validation_min;

  /// No description provided for @order_demand_replenishment_tip.
  ///
  /// In zh, this message translates to:
  /// **'提示：卖家会在收到申请后24小时内回复并补充相关材料。'**
  String get order_demand_replenishment_tip;

  /// No description provided for @order_demand_reform_tip.
  ///
  /// In zh, this message translates to:
  /// **'提示：重做申请提交后，卖家会重新处理您的订单。'**
  String get order_demand_reform_tip;

  /// No description provided for @order_demand_reason_incomplete.
  ///
  /// In zh, this message translates to:
  /// **'信息不完整'**
  String get order_demand_reason_incomplete;

  /// No description provided for @order_demand_reason_unclear.
  ///
  /// In zh, this message translates to:
  /// **'要求不明确'**
  String get order_demand_reason_unclear;

  /// No description provided for @order_demand_reason_additional.
  ///
  /// In zh, this message translates to:
  /// **'需要补充说明'**
  String get order_demand_reason_additional;

  /// No description provided for @order_demand_reason_reference.
  ///
  /// In zh, this message translates to:
  /// **'需要参考资料'**
  String get order_demand_reason_reference;

  /// No description provided for @order_demand_reason_other.
  ///
  /// In zh, this message translates to:
  /// **'其他原因'**
  String get order_demand_reason_other;

  /// No description provided for @order_demand_reason_quality.
  ///
  /// In zh, this message translates to:
  /// **'质量不满意'**
  String get order_demand_reason_quality;

  /// No description provided for @order_demand_reason_requirement.
  ///
  /// In zh, this message translates to:
  /// **'不符合要求'**
  String get order_demand_reason_requirement;

  /// No description provided for @order_demand_reason_content_incomplete.
  ///
  /// In zh, this message translates to:
  /// **'内容不完整'**
  String get order_demand_reason_content_incomplete;

  /// No description provided for @order_demand_reason_error.
  ///
  /// In zh, this message translates to:
  /// **'存在错误'**
  String get order_demand_reason_error;

  /// No description provided for @order_demand_submitting_replenishment.
  ///
  /// In zh, this message translates to:
  /// **'正在提交补充材料申请...'**
  String get order_demand_submitting_replenishment;

  /// No description provided for @order_demand_submitting_reform.
  ///
  /// In zh, this message translates to:
  /// **'正在提交重做申请...'**
  String get order_demand_submitting_reform;

  /// No description provided for @order_demand_failed.
  ///
  /// In zh, this message translates to:
  /// **'申请失败：{error}'**
  String order_demand_failed(String error);

  /// No description provided for @order_demand_edit_info_auto.
  ///
  /// In zh, this message translates to:
  /// **'当前已交付 {current} 次，剩余 {remaining} 次免费修改机会（自动通过）'**
  String order_demand_edit_info_auto(int current, int remaining);

  /// No description provided for @order_demand_edit_info_approval.
  ///
  /// In zh, this message translates to:
  /// **'当前已交付 {current} 次，已用完免费修改机会，需要卖家审批'**
  String order_demand_edit_info_approval(int current);

  /// No description provided for @order_info_title.
  ///
  /// In zh, this message translates to:
  /// **'订单信息'**
  String get order_info_title;

  /// No description provided for @order_info_order_number.
  ///
  /// In zh, this message translates to:
  /// **'订单编号：'**
  String get order_info_order_number;

  /// No description provided for @order_info_order_time.
  ///
  /// In zh, this message translates to:
  /// **'下单时间：'**
  String get order_info_order_time;

  /// No description provided for @order_info_pay_time.
  ///
  /// In zh, this message translates to:
  /// **'付款时间：'**
  String get order_info_pay_time;

  /// No description provided for @order_info_complete_time.
  ///
  /// In zh, this message translates to:
  /// **'完成时间：'**
  String get order_info_complete_time;

  /// No description provided for @order_info_remark.
  ///
  /// In zh, this message translates to:
  /// **'订单备注：'**
  String get order_info_remark;

  /// No description provided for @order_items_title.
  ///
  /// In zh, this message translates to:
  /// **'商品信息'**
  String get order_items_title;

  /// No description provided for @order_items_empty.
  ///
  /// In zh, this message translates to:
  /// **'暂无商品信息'**
  String get order_items_empty;

  /// No description provided for @order_items_count.
  ///
  /// In zh, this message translates to:
  /// **'{count}件'**
  String order_items_count(int count);

  /// No description provided for @order_price_title.
  ///
  /// In zh, this message translates to:
  /// **'价格明细'**
  String get order_price_title;

  /// No description provided for @order_price_total.
  ///
  /// In zh, this message translates to:
  /// **'商品总价'**
  String get order_price_total;

  /// No description provided for @order_price_shipping.
  ///
  /// In zh, this message translates to:
  /// **'运费'**
  String get order_price_shipping;

  /// No description provided for @order_price_discount.
  ///
  /// In zh, this message translates to:
  /// **'优惠金额'**
  String get order_price_discount;

  /// No description provided for @order_price_paid.
  ///
  /// In zh, this message translates to:
  /// **'实付金额'**
  String get order_price_paid;

  /// No description provided for @order_price_total_amount.
  ///
  /// In zh, this message translates to:
  /// **'商品总额'**
  String get order_price_total_amount;

  /// No description provided for @order_price_actual_paid.
  ///
  /// In zh, this message translates to:
  /// **'实付款'**
  String get order_price_actual_paid;

  /// No description provided for @order_requirement_title.
  ///
  /// In zh, this message translates to:
  /// **'要求提交'**
  String get order_requirement_title;

  /// No description provided for @order_requirement_service_selected.
  ///
  /// In zh, this message translates to:
  /// **'您选择的服务：{skuName} - ¥{price}'**
  String order_requirement_service_selected(String skuName, String price);

  /// No description provided for @order_requirement_q1.
  ///
  /// In zh, this message translates to:
  /// **'1. 请详细描述您的需求'**
  String get order_requirement_q1;

  /// No description provided for @order_requirement_q1_hint.
  ///
  /// In zh, this message translates to:
  /// **'请尽可能详细地描述您的需求，包括具体要求、期望效果等'**
  String get order_requirement_q1_hint;

  /// No description provided for @order_requirement_q1_helper.
  ///
  /// In zh, this message translates to:
  /// **'如需提供参考资料，可在下方附件区域上传'**
  String get order_requirement_q1_helper;

  /// No description provided for @order_requirement_q2.
  ///
  /// In zh, this message translates to:
  /// **'2. 补充说明（选填）'**
  String get order_requirement_q2;

  /// No description provided for @order_requirement_q2_hint.
  ///
  /// In zh, this message translates to:
  /// **'如有其他补充说明或特殊要求，请在此填写'**
  String get order_requirement_q2_hint;

  /// No description provided for @order_requirement_warning.
  ///
  /// In zh, this message translates to:
  /// **'请认真填写需求，提交后卖家将根据您的需求开始服务'**
  String get order_requirement_warning;

  /// No description provided for @order_requirement_attachment_title.
  ///
  /// In zh, this message translates to:
  /// **'附件上传'**
  String get order_requirement_attachment_title;

  /// No description provided for @order_requirement_attachment_limit.
  ///
  /// In zh, this message translates to:
  /// **'最多{maxCount}个文件，单个文件不超过{maxSize}MB'**
  String order_requirement_attachment_limit(int maxCount, int maxSize);

  /// No description provided for @order_requirement_add.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get order_requirement_add;

  /// No description provided for @order_requirement_click_select_file.
  ///
  /// In zh, this message translates to:
  /// **'点击此处选择文件'**
  String get order_requirement_click_select_file;

  /// No description provided for @order_requirement_confirm_submit.
  ///
  /// In zh, this message translates to:
  /// **'确认提交'**
  String get order_requirement_confirm_submit;

  /// No description provided for @order_requirement_wait_upload.
  ///
  /// In zh, this message translates to:
  /// **'请等待文件上传完成'**
  String get order_requirement_wait_upload;

  /// No description provided for @order_requirement_upload_failed_title.
  ///
  /// In zh, this message translates to:
  /// **'文件上传失败'**
  String get order_requirement_upload_failed_title;

  /// No description provided for @order_requirement_upload_failed_count.
  ///
  /// In zh, this message translates to:
  /// **'有{count}个文件上传失败，是否重试？'**
  String order_requirement_upload_failed_count(int count);

  /// No description provided for @order_requirement_remove_failed.
  ///
  /// In zh, this message translates to:
  /// **'移除失败文件'**
  String get order_requirement_remove_failed;

  /// No description provided for @order_requirement_retry_upload.
  ///
  /// In zh, this message translates to:
  /// **'重试上传'**
  String get order_requirement_retry_upload;

  /// No description provided for @order_requirement_error_product_id.
  ///
  /// In zh, this message translates to:
  /// **'错误：无法获取商品 ID'**
  String get order_requirement_error_product_id;

  /// No description provided for @order_requirement_load_draft_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载草稿失败'**
  String get order_requirement_load_draft_failed;

  /// No description provided for @order_requirement_save_draft_failed.
  ///
  /// In zh, this message translates to:
  /// **'保存草稿失败'**
  String get order_requirement_save_draft_failed;

  /// No description provided for @order_requirement_max_files.
  ///
  /// In zh, this message translates to:
  /// **'最多只能上传{count}个附件'**
  String order_requirement_max_files(int count);

  /// No description provided for @order_requirement_pick_failed.
  ///
  /// In zh, this message translates to:
  /// **'选择文件失败: {error}'**
  String order_requirement_pick_failed(String error);

  /// No description provided for @order_requirement_default_service.
  ///
  /// In zh, this message translates to:
  /// **'基础服务'**
  String get order_requirement_default_service;

  /// No description provided for @order_evaluation_title.
  ///
  /// In zh, this message translates to:
  /// **'评价商品'**
  String get order_evaluation_title;

  /// No description provided for @order_evaluation_hint.
  ///
  /// In zh, this message translates to:
  /// **'分享您的使用体验吧～'**
  String get order_evaluation_hint;

  /// No description provided for @order_evaluation_add_images.
  ///
  /// In zh, this message translates to:
  /// **'添加图片 (最多9张)'**
  String get order_evaluation_add_images;

  /// No description provided for @order_evaluation_anonymous.
  ///
  /// In zh, this message translates to:
  /// **'匿名评价'**
  String get order_evaluation_anonymous;

  /// No description provided for @order_evaluation_submit.
  ///
  /// In zh, this message translates to:
  /// **'提交评价'**
  String get order_evaluation_submit;

  /// No description provided for @order_evaluation_error_no_item.
  ///
  /// In zh, this message translates to:
  /// **'错误：无法找到要评价的商品项'**
  String get order_evaluation_error_no_item;

  /// No description provided for @order_evaluation_max_images.
  ///
  /// In zh, this message translates to:
  /// **'最多只能上传9张图片'**
  String get order_evaluation_max_images;

  /// No description provided for @order_evaluation_success_count.
  ///
  /// In zh, this message translates to:
  /// **'成功处理 {count} 张图片，平均压缩 {ratio}%'**
  String order_evaluation_success_count(int count, String ratio);

  /// No description provided for @order_evaluation_failed_count.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张图片处理失败'**
  String order_evaluation_failed_count(int count);

  /// No description provided for @order_evaluation_pick_failed.
  ///
  /// In zh, this message translates to:
  /// **'选择图片失败: {error}'**
  String order_evaluation_pick_failed(String error);

  /// No description provided for @order_evaluation_processing.
  ///
  /// In zh, this message translates to:
  /// **'处理中...'**
  String get order_evaluation_processing;

  /// No description provided for @order_evaluation_page_title.
  ///
  /// In zh, this message translates to:
  /// **'评价订单'**
  String get order_evaluation_page_title;

  /// No description provided for @order_delivery_not_satisfied.
  ///
  /// In zh, this message translates to:
  /// **'对交付不满意？'**
  String get order_delivery_not_satisfied;

  /// No description provided for @order_delivery_communicate_tip.
  ///
  /// In zh, this message translates to:
  /// **'当前交付次数不足时，请先与卖家沟通是否同意再次交付'**
  String get order_delivery_communicate_tip;

  /// No description provided for @order_delivery_supplement.
  ///
  /// In zh, this message translates to:
  /// **'我要补充'**
  String get order_delivery_supplement;

  /// No description provided for @order_delivery_remake.
  ///
  /// In zh, this message translates to:
  /// **'我要重新制作'**
  String get order_delivery_remake;

  /// No description provided for @order_delivery_refund.
  ///
  /// In zh, this message translates to:
  /// **'我要退款'**
  String get order_delivery_refund;

  /// No description provided for @order_delivery_unknown_file.
  ///
  /// In zh, this message translates to:
  /// **'未知文件'**
  String get order_delivery_unknown_file;

  /// No description provided for @order_item_delivery_days.
  ///
  /// In zh, this message translates to:
  /// **'交付天数: {days}天'**
  String order_item_delivery_days(int days);

  /// No description provided for @order_item_edit_count.
  ///
  /// In zh, this message translates to:
  /// **'可修改次数: {count}次'**
  String order_item_edit_count(int count);

  /// No description provided for @order_countdown_expired.
  ///
  /// In zh, this message translates to:
  /// **'已超时'**
  String get order_countdown_expired;

  /// No description provided for @order_countdown_days_hours.
  ///
  /// In zh, this message translates to:
  /// **'{days}天{hours}时'**
  String order_countdown_days_hours(int days, int hours);

  /// No description provided for @order_countdown_hours_minutes.
  ///
  /// In zh, this message translates to:
  /// **'{hours}时{minutes}分'**
  String order_countdown_hours_minutes(int hours, int minutes);

  /// No description provided for @order_countdown_minutes.
  ///
  /// In zh, this message translates to:
  /// **'{minutes}分'**
  String order_countdown_minutes(int minutes);

  /// No description provided for @order_countdown_seconds.
  ///
  /// In zh, this message translates to:
  /// **'{seconds}秒'**
  String order_countdown_seconds(int seconds);

  /// No description provided for @order_countdown_days.
  ///
  /// In zh, this message translates to:
  /// **'{days}天'**
  String order_countdown_days(int days);

  /// No description provided for @order_countdown_minutes_seconds.
  ///
  /// In zh, this message translates to:
  /// **'{minutes}分{seconds}秒'**
  String order_countdown_minutes_seconds(int minutes, int seconds);

  /// No description provided for @order_upload_progress.
  ///
  /// In zh, this message translates to:
  /// **'上传中 {percent}%'**
  String order_upload_progress(int percent);

  /// No description provided for @order_upload_retry.
  ///
  /// In zh, this message translates to:
  /// **'重试上传'**
  String get order_upload_retry;

  /// No description provided for @order_upload_failed.
  ///
  /// In zh, this message translates to:
  /// **'上传失败: {error}'**
  String order_upload_failed(String error);

  /// No description provided for @order_upload_size_limit.
  ///
  /// In zh, this message translates to:
  /// **'文件大小超过限制（最大{size}）'**
  String order_upload_size_limit(String size);

  /// No description provided for @order_upload_max_retry.
  ///
  /// In zh, this message translates to:
  /// **'已达到最大重试次数（{count}次）'**
  String order_upload_max_retry(int count);

  /// No description provided for @order_after_sale_processing.
  ///
  /// In zh, this message translates to:
  /// **'售后处理中'**
  String get order_after_sale_processing;

  /// No description provided for @order_after_sale_processing_msg.
  ///
  /// In zh, this message translates to:
  /// **'您的售后申请正在处理中，卖家将在xx小时内处理，请耐心等待。'**
  String get order_after_sale_processing_msg;

  /// No description provided for @order_after_sale_mediation.
  ///
  /// In zh, this message translates to:
  /// **'平台介入处理中'**
  String get order_after_sale_mediation;

  /// No description provided for @order_after_sale_mediation_msg.
  ///
  /// In zh, this message translates to:
  /// **'平台客服已介入处理，将在xx工作日内给出处理结果，请留意通知。'**
  String get order_after_sale_mediation_msg;

  /// No description provided for @order_after_sale_rejected.
  ///
  /// In zh, this message translates to:
  /// **'售后申请已驳回'**
  String get order_after_sale_rejected;

  /// No description provided for @order_after_sale_rejected_msg.
  ///
  /// In zh, this message translates to:
  /// **'抱歉，您的售后申请未通过审核。'**
  String get order_after_sale_rejected_msg;

  /// No description provided for @order_after_sale_default_title.
  ///
  /// In zh, this message translates to:
  /// **'售后状态'**
  String get order_after_sale_default_title;

  /// No description provided for @order_after_sale_default_msg.
  ///
  /// In zh, this message translates to:
  /// **'当前订单处于售后流程中。'**
  String get order_after_sale_default_msg;

  /// No description provided for @order_after_sale_contact_seller.
  ///
  /// In zh, this message translates to:
  /// **'联系卖家'**
  String get order_after_sale_contact_seller;

  /// No description provided for @order_after_sale_cancel_apply.
  ///
  /// In zh, this message translates to:
  /// **'取消申请'**
  String get order_after_sale_cancel_apply;

  /// No description provided for @order_after_sale_contact_platform.
  ///
  /// In zh, this message translates to:
  /// **'联系平台客服'**
  String get order_after_sale_contact_platform;

  /// No description provided for @order_after_sale_add_evidence.
  ///
  /// In zh, this message translates to:
  /// **'补充凭证'**
  String get order_after_sale_add_evidence;

  /// No description provided for @order_after_sale_add_evidence_tip.
  ///
  /// In zh, this message translates to:
  /// **'您可以补充凭证或耐心等待平台处理结果。'**
  String get order_after_sale_add_evidence_tip;

  /// No description provided for @order_after_sale_apply_intervention.
  ///
  /// In zh, this message translates to:
  /// **'申请平台介入'**
  String get order_after_sale_apply_intervention;

  /// No description provided for @order_after_sale_refund_status.
  ///
  /// In zh, this message translates to:
  /// **'退款状态:'**
  String get order_after_sale_refund_status;

  /// No description provided for @order_after_sale_refund_amount.
  ///
  /// In zh, this message translates to:
  /// **'退款金额:'**
  String get order_after_sale_refund_amount;

  /// No description provided for @order_after_sale_reject_reason.
  ///
  /// In zh, this message translates to:
  /// **'驳回原因:'**
  String get order_after_sale_reject_reason;

  /// No description provided for @order_after_sale_reject_reason_detail.
  ///
  /// In zh, this message translates to:
  /// **'原因：凭证不足或不符合退款条件。'**
  String get order_after_sale_reject_reason_detail;

  /// No description provided for @order_platform_intervention_title.
  ///
  /// In zh, this message translates to:
  /// **'平台介入'**
  String get order_platform_intervention_title;

  /// No description provided for @order_platform_intervention_desc.
  ///
  /// In zh, this message translates to:
  /// **'如遇到争议无法协商解决，可申请平台客服介入处理'**
  String get order_platform_intervention_desc;

  /// No description provided for @order_platform_intervention_apply.
  ///
  /// In zh, this message translates to:
  /// **'申请平台介入'**
  String get order_platform_intervention_apply;

  /// No description provided for @order_platform_intervention_in_progress.
  ///
  /// In zh, this message translates to:
  /// **'平台介入中'**
  String get order_platform_intervention_in_progress;

  /// No description provided for @order_platform_intervention_processing.
  ///
  /// In zh, this message translates to:
  /// **'处理中'**
  String get order_platform_intervention_processing;

  /// No description provided for @order_platform_intervention_processing_msg.
  ///
  /// In zh, this message translates to:
  /// **'您的申请已提交，平台客服会在24小时内联系您处理'**
  String get order_platform_intervention_processing_msg;

  /// No description provided for @order_platform_intervention_step1.
  ///
  /// In zh, this message translates to:
  /// **'申请已提交'**
  String get order_platform_intervention_step1;

  /// No description provided for @order_platform_intervention_step1_desc.
  ///
  /// In zh, this message translates to:
  /// **'等待平台客服处理'**
  String get order_platform_intervention_step1_desc;

  /// No description provided for @order_platform_intervention_step2.
  ///
  /// In zh, this message translates to:
  /// **'客服介入'**
  String get order_platform_intervention_step2;

  /// No description provided for @order_platform_intervention_step2_desc.
  ///
  /// In zh, this message translates to:
  /// **'24小时内联系双方'**
  String get order_platform_intervention_step2_desc;

  /// No description provided for @order_platform_intervention_step3.
  ///
  /// In zh, this message translates to:
  /// **'问题解决'**
  String get order_platform_intervention_step3;

  /// No description provided for @order_platform_intervention_step3_desc.
  ///
  /// In zh, this message translates to:
  /// **'根据平台判定处理'**
  String get order_platform_intervention_step3_desc;

  /// No description provided for @order_card_product_unknown.
  ///
  /// In zh, this message translates to:
  /// **'商品名称未知'**
  String get order_card_product_unknown;

  /// No description provided for @order_card_deleting.
  ///
  /// In zh, this message translates to:
  /// **'正在删除订单...'**
  String get order_card_deleting;

  /// No description provided for @order_card_deleted.
  ///
  /// In zh, this message translates to:
  /// **'订单已删除'**
  String get order_card_deleted;

  /// No description provided for @order_card_delete_failed.
  ///
  /// In zh, this message translates to:
  /// **'删除失败：{error}'**
  String order_card_delete_failed(String error);

  /// No description provided for @order_card_canceling.
  ///
  /// In zh, this message translates to:
  /// **'正在取消订单...'**
  String get order_card_canceling;

  /// No description provided for @order_card_canceled.
  ///
  /// In zh, this message translates to:
  /// **'订单已取消'**
  String get order_card_canceled;

  /// No description provided for @order_card_cancel_failed.
  ///
  /// In zh, this message translates to:
  /// **'取消失败：{error}'**
  String order_card_cancel_failed(String error);

  /// No description provided for @order_card_load_detail_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载订单详情失败：{error}'**
  String order_card_load_detail_failed(String error);

  /// No description provided for @order_card_timeout_canceling.
  ///
  /// In zh, this message translates to:
  /// **'已超时，即将取消'**
  String get order_card_timeout_canceling;

  /// No description provided for @order_card_pay_in_time.
  ///
  /// In zh, this message translates to:
  /// **'请在{time}内付款'**
  String order_card_pay_in_time(String time);

  /// No description provided for @order_card_timeout_submit.
  ///
  /// In zh, this message translates to:
  /// **'已超时，请尽快提交'**
  String get order_card_timeout_submit;

  /// No description provided for @order_card_submit_in_time.
  ///
  /// In zh, this message translates to:
  /// **'请在{time}内提交材料'**
  String order_card_submit_in_time(String time);

  /// No description provided for @order_card_seller_timeout.
  ///
  /// In zh, this message translates to:
  /// **'卖家超时未接单'**
  String get order_card_seller_timeout;

  /// No description provided for @order_card_seller_accept_in_time.
  ///
  /// In zh, this message translates to:
  /// **'卖家将在{time}内接单'**
  String order_card_seller_accept_in_time(String time);

  /// No description provided for @order_card_delivery_days.
  ///
  /// In zh, this message translates to:
  /// **'交付时间：{days}天内'**
  String order_card_delivery_days(int days);

  /// No description provided for @order_card_auto_confirm_soon.
  ///
  /// In zh, this message translates to:
  /// **'即将自动确认收货'**
  String get order_card_auto_confirm_soon;

  /// No description provided for @order_card_auto_confirm_in.
  ///
  /// In zh, this message translates to:
  /// **'{time}后自动确认'**
  String order_card_auto_confirm_in(String time);

  /// No description provided for @order_card_evaluate_for_points.
  ///
  /// In zh, this message translates to:
  /// **'待评价，评价后可获得积分'**
  String get order_card_evaluate_for_points;

  /// No description provided for @order_card_duration_days_hours.
  ///
  /// In zh, this message translates to:
  /// **'{days}天{hours}小时'**
  String order_card_duration_days_hours(int days, int hours);

  /// No description provided for @order_card_duration_hours_minutes.
  ///
  /// In zh, this message translates to:
  /// **'{hours}小时{minutes}分钟'**
  String order_card_duration_hours_minutes(int hours, int minutes);

  /// No description provided for @order_card_duration_minutes.
  ///
  /// In zh, this message translates to:
  /// **'{minutes}分钟'**
  String order_card_duration_minutes(int minutes);

  /// No description provided for @order_card_duration_less_than_minute.
  ///
  /// In zh, this message translates to:
  /// **'少于1分钟'**
  String get order_card_duration_less_than_minute;

  /// No description provided for @order_detail_invalid_id.
  ///
  /// In zh, this message translates to:
  /// **'无效的订单 ID'**
  String get order_detail_invalid_id;

  /// No description provided for @order_detail_error.
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get order_detail_error;

  /// No description provided for @order_detail_title.
  ///
  /// In zh, this message translates to:
  /// **'订单详情'**
  String get order_detail_title;

  /// No description provided for @order_detail_title_with_id.
  ///
  /// In zh, this message translates to:
  /// **'订单详情 (ID: {id})'**
  String order_detail_title_with_id(int id);

  /// No description provided for @order_detail_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String order_detail_load_failed(String error);

  /// No description provided for @order_detail_reload.
  ///
  /// In zh, this message translates to:
  /// **'重新加载'**
  String get order_detail_reload;

  /// No description provided for @order_detail_unavailable.
  ///
  /// In zh, this message translates to:
  /// **'订单数据不可用'**
  String get order_detail_unavailable;

  /// No description provided for @order_list_title.
  ///
  /// In zh, this message translates to:
  /// **'我的订单'**
  String get order_list_title;

  /// No description provided for @order_list_search_hint.
  ///
  /// In zh, this message translates to:
  /// **'搜索订单号或商品名称'**
  String get order_list_search_hint;

  /// No description provided for @order_list_empty.
  ///
  /// In zh, this message translates to:
  /// **'暂无相关订单'**
  String get order_list_empty;

  /// No description provided for @order_list_load_error.
  ///
  /// In zh, this message translates to:
  /// **'加载错误: {error}'**
  String order_list_load_error(String error);

  /// No description provided for @order_list_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String order_list_load_failed(String error);

  /// No description provided for @order_list_select_category.
  ///
  /// In zh, this message translates to:
  /// **'请选择分类查看订单'**
  String get order_list_select_category;

  /// No description provided for @order_list_tab_all.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get order_list_tab_all;

  /// No description provided for @order_list_tab_awaiting_payment.
  ///
  /// In zh, this message translates to:
  /// **'待付款'**
  String get order_list_tab_awaiting_payment;

  /// No description provided for @order_list_tab_awaiting_submission.
  ///
  /// In zh, this message translates to:
  /// **'待提交'**
  String get order_list_tab_awaiting_submission;

  /// No description provided for @order_list_tab_awaiting_start.
  ///
  /// In zh, this message translates to:
  /// **'待接单'**
  String get order_list_tab_awaiting_start;

  /// No description provided for @order_list_tab_awaiting_delivery.
  ///
  /// In zh, this message translates to:
  /// **'待交付'**
  String get order_list_tab_awaiting_delivery;

  /// No description provided for @order_list_tab_awaiting_confirmation.
  ///
  /// In zh, this message translates to:
  /// **'待收货'**
  String get order_list_tab_awaiting_confirmation;

  /// No description provided for @order_list_tab_awaiting_evaluation.
  ///
  /// In zh, this message translates to:
  /// **'待评价'**
  String get order_list_tab_awaiting_evaluation;

  /// No description provided for @order_list_tab_after_sale.
  ///
  /// In zh, this message translates to:
  /// **'售后中'**
  String get order_list_tab_after_sale;

  /// No description provided for @order_route_error.
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get order_route_error;

  /// No description provided for @order_route_invalid_item_id.
  ///
  /// In zh, this message translates to:
  /// **'无效的商品ID: {id}'**
  String order_route_invalid_item_id(String id);

  /// No description provided for @order_seller_detail_title.
  ///
  /// In zh, this message translates to:
  /// **'订单详情 (卖家) - #{id}'**
  String order_seller_detail_title(int id);

  /// No description provided for @order_seller_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载订单 #{id} 失败: {error}'**
  String order_seller_load_failed(int id, String error);

  /// No description provided for @order_seller_preparing.
  ///
  /// In zh, this message translates to:
  /// **'正在准备加载...'**
  String get order_seller_preparing;

  /// No description provided for @order_seller_order_number.
  ///
  /// In zh, this message translates to:
  /// **'订单编号'**
  String get order_seller_order_number;

  /// No description provided for @order_seller_order_time.
  ///
  /// In zh, this message translates to:
  /// **'下单时间'**
  String get order_seller_order_time;

  /// No description provided for @order_seller_pay_time.
  ///
  /// In zh, this message translates to:
  /// **'付款时间'**
  String get order_seller_pay_time;

  /// No description provided for @order_seller_complete_time.
  ///
  /// In zh, this message translates to:
  /// **'完成时间'**
  String get order_seller_complete_time;

  /// No description provided for @order_seller_cancel_time.
  ///
  /// In zh, this message translates to:
  /// **'取消时间'**
  String get order_seller_cancel_time;

  /// No description provided for @order_seller_list_title.
  ///
  /// In zh, this message translates to:
  /// **'我的订单 (卖家)'**
  String get order_seller_list_title;

  /// No description provided for @order_seller_tab_all.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get order_seller_tab_all;

  /// No description provided for @order_seller_tab_awaiting_start.
  ///
  /// In zh, this message translates to:
  /// **'待接单'**
  String get order_seller_tab_awaiting_start;

  /// No description provided for @order_seller_tab_awaiting_delivery.
  ///
  /// In zh, this message translates to:
  /// **'待发货'**
  String get order_seller_tab_awaiting_delivery;

  /// No description provided for @order_seller_tab_awaiting_confirmation.
  ///
  /// In zh, this message translates to:
  /// **'待确认收货'**
  String get order_seller_tab_awaiting_confirmation;

  /// No description provided for @order_seller_tab_awaiting_evaluation.
  ///
  /// In zh, this message translates to:
  /// **'待评价'**
  String get order_seller_tab_awaiting_evaluation;

  /// No description provided for @order_seller_tab_completed.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get order_seller_tab_completed;

  /// No description provided for @order_seller_tab_after_sale.
  ///
  /// In zh, this message translates to:
  /// **'售后中'**
  String get order_seller_tab_after_sale;

  /// No description provided for @order_seller_tab_canceled.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get order_seller_tab_canceled;

  /// No description provided for @order_seller_load_failed_msg.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String order_seller_load_failed_msg(String error);

  /// No description provided for @order_seller_empty.
  ///
  /// In zh, this message translates to:
  /// **'暂无此状态订单'**
  String get order_seller_empty;

  /// No description provided for @order_seller_action_failed.
  ///
  /// In zh, this message translates to:
  /// **'操作失败: {error}'**
  String order_seller_action_failed(String error);

  /// No description provided for @order_seller_pending_count.
  ///
  /// In zh, this message translates to:
  /// **'您有{count}个订单待处理'**
  String order_seller_pending_count(int count);

  /// No description provided for @order_seller_pending_awaiting_start.
  ///
  /// In zh, this message translates to:
  /// **'{count}个待接单'**
  String order_seller_pending_awaiting_start(int count);

  /// No description provided for @order_seller_pending_awaiting_delivery.
  ///
  /// In zh, this message translates to:
  /// **'{count}个待发货'**
  String order_seller_pending_awaiting_delivery(int count);

  /// No description provided for @order_seller_reject_order.
  ///
  /// In zh, this message translates to:
  /// **'拒绝接单'**
  String get order_seller_reject_order;

  /// No description provided for @order_seller_confirm_order.
  ///
  /// In zh, this message translates to:
  /// **'确认接单'**
  String get order_seller_confirm_order;

  /// No description provided for @order_seller_contact_buyer.
  ///
  /// In zh, this message translates to:
  /// **'联系买家'**
  String get order_seller_contact_buyer;

  /// No description provided for @order_seller_go_deliver.
  ///
  /// In zh, this message translates to:
  /// **'去交付'**
  String get order_seller_go_deliver;

  /// No description provided for @order_seller_view_delivery_content.
  ///
  /// In zh, this message translates to:
  /// **'查看交付内容'**
  String get order_seller_view_delivery_content;

  /// No description provided for @order_seller_remind_buyer.
  ///
  /// In zh, this message translates to:
  /// **'提醒买家确认'**
  String get order_seller_remind_buyer;

  /// No description provided for @order_seller_delete_record.
  ///
  /// In zh, this message translates to:
  /// **'删除记录'**
  String get order_seller_delete_record;

  /// No description provided for @order_seller_confirm_accept_title.
  ///
  /// In zh, this message translates to:
  /// **'确认接单'**
  String get order_seller_confirm_accept_title;

  /// No description provided for @order_seller_confirm_accept_content.
  ///
  /// In zh, this message translates to:
  /// **'您确定要接受此订单吗？'**
  String get order_seller_confirm_accept_content;

  /// No description provided for @order_seller_confirm_delete_title.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get order_seller_confirm_delete_title;

  /// No description provided for @order_seller_confirm_delete_content.
  ///
  /// In zh, this message translates to:
  /// **'您确定要删除这条订单记录吗？此操作无法撤销。'**
  String get order_seller_confirm_delete_content;

  /// No description provided for @order_seller_confirm_delete_canceled_content.
  ///
  /// In zh, this message translates to:
  /// **'您确定要删除这条已取消的订单记录吗？此操作无法撤销。'**
  String get order_seller_confirm_delete_canceled_content;

  /// No description provided for @order_seller_confirm_btn.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get order_seller_confirm_btn;

  /// No description provided for @order_seller_confirm_reject_title.
  ///
  /// In zh, this message translates to:
  /// **'确认拒绝'**
  String get order_seller_confirm_reject_title;

  /// No description provided for @order_seller_confirm_reject_content.
  ///
  /// In zh, this message translates to:
  /// **'您确定要拒绝接受此订单吗？'**
  String get order_seller_confirm_reject_content;

  /// No description provided for @order_seller_confirm_reject_btn.
  ///
  /// In zh, this message translates to:
  /// **'确认拒绝'**
  String get order_seller_confirm_reject_btn;

  /// No description provided for @order_seller_reject_dialog_title.
  ///
  /// In zh, this message translates to:
  /// **'拒绝订单'**
  String get order_seller_reject_dialog_title;

  /// No description provided for @order_seller_reject_reason_label.
  ///
  /// In zh, this message translates to:
  /// **'拒绝理由 *'**
  String get order_seller_reject_reason_label;

  /// No description provided for @order_seller_reject_reason_hint.
  ///
  /// In zh, this message translates to:
  /// **'请输入拒绝理由'**
  String get order_seller_reject_reason_hint;

  /// No description provided for @order_seller_reject_reason_empty.
  ///
  /// In zh, this message translates to:
  /// **'拒绝理由不能为空'**
  String get order_seller_reject_reason_empty;

  /// No description provided for @order_seller_reject_reason_required.
  ///
  /// In zh, this message translates to:
  /// **'请输入拒绝理由'**
  String get order_seller_reject_reason_required;

  /// No description provided for @order_seller_remarks_label.
  ///
  /// In zh, this message translates to:
  /// **'补充说明 (可选)'**
  String get order_seller_remarks_label;

  /// No description provided for @order_seller_remarks_hint.
  ///
  /// In zh, this message translates to:
  /// **'选填'**
  String get order_seller_remarks_hint;

  /// No description provided for @order_seller_delivery_dialog_title.
  ///
  /// In zh, this message translates to:
  /// **'交付内容'**
  String get order_seller_delivery_dialog_title;

  /// No description provided for @order_seller_delivery_desc_label.
  ///
  /// In zh, this message translates to:
  /// **'交付说明 *'**
  String get order_seller_delivery_desc_label;

  /// No description provided for @order_seller_delivery_desc_hint.
  ///
  /// In zh, this message translates to:
  /// **'请描述您的交付内容'**
  String get order_seller_delivery_desc_hint;

  /// No description provided for @order_seller_delivery_desc_empty.
  ///
  /// In zh, this message translates to:
  /// **'交付说明不能为空'**
  String get order_seller_delivery_desc_empty;

  /// No description provided for @order_seller_delivery_desc_required.
  ///
  /// In zh, this message translates to:
  /// **'请输入交付说明'**
  String get order_seller_delivery_desc_required;

  /// No description provided for @order_seller_delivery_attachment.
  ///
  /// In zh, this message translates to:
  /// **'附件'**
  String get order_seller_delivery_attachment;

  /// No description provided for @order_seller_delivery_select_file.
  ///
  /// In zh, this message translates to:
  /// **'点击下方按钮选择文件'**
  String get order_seller_delivery_select_file;

  /// No description provided for @order_seller_delivery_add_attachment.
  ///
  /// In zh, this message translates to:
  /// **'添加附件'**
  String get order_seller_delivery_add_attachment;

  /// No description provided for @order_seller_delivery_file_select_soon.
  ///
  /// In zh, this message translates to:
  /// **'文件选择功能即将实现'**
  String get order_seller_delivery_file_select_soon;

  /// No description provided for @order_seller_delivery_confirm.
  ///
  /// In zh, this message translates to:
  /// **'确认交付'**
  String get order_seller_delivery_confirm;

  /// No description provided for @order_seller_delivery_chat_hint.
  ///
  /// In zh, this message translates to:
  /// **'请选择关于商品\"{productName}\"的聊天'**
  String order_seller_delivery_chat_hint(String productName);

  /// No description provided for @order_seller_dynamic_delivered.
  ///
  /// In zh, this message translates to:
  /// **'服务已交付'**
  String get order_seller_dynamic_delivered;

  /// No description provided for @order_seller_dynamic_delivered_msg.
  ///
  /// In zh, this message translates to:
  /// **'您已完成服务交付，请等待买家确认。如有问题，买家可能会发起售后。'**
  String get order_seller_dynamic_delivered_msg;

  /// No description provided for @order_seller_dynamic_completed.
  ///
  /// In zh, this message translates to:
  /// **'此订单已顺利完成。'**
  String get order_seller_dynamic_completed;

  /// No description provided for @order_seller_dynamic_canceled.
  ///
  /// In zh, this message translates to:
  /// **'此订单已被取消。'**
  String get order_seller_dynamic_canceled;

  /// No description provided for @order_seller_dynamic_refused.
  ///
  /// In zh, this message translates to:
  /// **'已申请拒绝订单'**
  String get order_seller_dynamic_refused;

  /// No description provided for @order_seller_dynamic_refused_msg.
  ///
  /// In zh, this message translates to:
  /// **'您的拒绝申请已提交，正在等待处理。'**
  String get order_seller_dynamic_refused_msg;

  /// No description provided for @order_seller_buyer_materials.
  ///
  /// In zh, this message translates to:
  /// **'买家提供的材料'**
  String get order_seller_buyer_materials;

  /// No description provided for @order_seller_attachment_label.
  ///
  /// In zh, this message translates to:
  /// **'附件:'**
  String get order_seller_attachment_label;

  /// No description provided for @order_seller_view_attachment.
  ///
  /// In zh, this message translates to:
  /// **'查看附件功能待实现: {fileName}'**
  String order_seller_view_attachment(String fileName);

  /// No description provided for @order_evaluation_product_info.
  ///
  /// In zh, this message translates to:
  /// **'商品信息'**
  String get order_evaluation_product_info;

  /// No description provided for @order_list_retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get order_list_retry;

  /// No description provided for @chat_get_user_info_failed.
  ///
  /// In zh, this message translates to:
  /// **'获取用户信息失败: {error}'**
  String chat_get_user_info_failed(String error);

  /// No description provided for @chat_user_refer_id_not_found.
  ///
  /// In zh, this message translates to:
  /// **'用户referId未找到'**
  String get chat_user_refer_id_not_found;

  /// No description provided for @chat_no_chat_records.
  ///
  /// In zh, this message translates to:
  /// **'暂无聊天记录'**
  String get chat_no_chat_records;

  /// No description provided for @chat_opponent_info_missing.
  ///
  /// In zh, this message translates to:
  /// **'对方信息不存在'**
  String get chat_opponent_info_missing;

  /// No description provided for @chat_product_default.
  ///
  /// In zh, this message translates to:
  /// **'商品'**
  String get chat_product_default;

  /// No description provided for @chat_view_details.
  ///
  /// In zh, this message translates to:
  /// **'查看详情'**
  String get chat_view_details;

  /// No description provided for @chat_product_info_incomplete.
  ///
  /// In zh, this message translates to:
  /// **'商品信息不完整，无法查看详情'**
  String get chat_product_info_incomplete;

  /// No description provided for @chat_uploading.
  ///
  /// In zh, this message translates to:
  /// **'上传中...'**
  String get chat_uploading;

  /// No description provided for @chat_upload_failed.
  ///
  /// In zh, this message translates to:
  /// **'上传失败'**
  String get chat_upload_failed;

  /// No description provided for @chat_retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get chat_retry;

  /// No description provided for @chat_image_loading.
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get chat_image_loading;

  /// No description provided for @chat_image_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get chat_image_load_failed;

  /// No description provided for @chat_revoke_time_missing.
  ///
  /// In zh, this message translates to:
  /// **'消息时间信息缺失，无法撤回'**
  String get chat_revoke_time_missing;

  /// No description provided for @chat_revoke_available.
  ///
  /// In zh, this message translates to:
  /// **'可以撤回'**
  String get chat_revoke_available;

  /// No description provided for @chat_revoke_expired.
  ///
  /// In zh, this message translates to:
  /// **'消息发送已超过2分钟，无法撤回（超出{seconds}秒）'**
  String chat_revoke_expired(int seconds);

  /// No description provided for @chat_unknown_seller.
  ///
  /// In zh, this message translates to:
  /// **'未知卖家'**
  String get chat_unknown_seller;

  /// No description provided for @chat_product_conversation.
  ///
  /// In zh, this message translates to:
  /// **'商品对话'**
  String get chat_product_conversation;

  /// No description provided for @chat_product_conversation_count.
  ///
  /// In zh, this message translates to:
  /// **'{count}个商品对话'**
  String chat_product_conversation_count(int count);

  /// No description provided for @chat_unknown_product.
  ///
  /// In zh, this message translates to:
  /// **'未知商品'**
  String get chat_unknown_product;

  /// No description provided for @chat_user_inquiry_count.
  ///
  /// In zh, this message translates to:
  /// **'{count}个用户咨询'**
  String chat_user_inquiry_count(int count);

  /// No description provided for @chat_weekday_mon.
  ///
  /// In zh, this message translates to:
  /// **'周一'**
  String get chat_weekday_mon;

  /// No description provided for @chat_weekday_tue.
  ///
  /// In zh, this message translates to:
  /// **'周二'**
  String get chat_weekday_tue;

  /// No description provided for @chat_weekday_wed.
  ///
  /// In zh, this message translates to:
  /// **'周三'**
  String get chat_weekday_wed;

  /// No description provided for @chat_weekday_thu.
  ///
  /// In zh, this message translates to:
  /// **'周四'**
  String get chat_weekday_thu;

  /// No description provided for @chat_weekday_fri.
  ///
  /// In zh, this message translates to:
  /// **'周五'**
  String get chat_weekday_fri;

  /// No description provided for @chat_weekday_sat.
  ///
  /// In zh, this message translates to:
  /// **'周六'**
  String get chat_weekday_sat;

  /// No description provided for @chat_weekday_sun.
  ///
  /// In zh, this message translates to:
  /// **'周日'**
  String get chat_weekday_sun;

  /// No description provided for @chat_select_multiple_images.
  ///
  /// In zh, this message translates to:
  /// **'选择多张图片'**
  String get chat_select_multiple_images;

  /// No description provided for @chat_image_compressed.
  ///
  /// In zh, this message translates to:
  /// **'图片已压缩 {ratio}%'**
  String chat_image_compressed(String ratio);

  /// No description provided for @chat_image_process_failed.
  ///
  /// In zh, this message translates to:
  /// **'图片处理失败: {error}'**
  String chat_image_process_failed(String error);

  /// No description provided for @chat_images_processed_success.
  ///
  /// In zh, this message translates to:
  /// **'成功处理 {count} 张图片，平均压缩 {ratio}%'**
  String chat_images_processed_success(int count, String ratio);

  /// No description provided for @chat_images_process_failed_count.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张图片处理失败'**
  String chat_images_process_failed_count(int count);

  /// No description provided for @chat_tap_to_view_product.
  ///
  /// In zh, this message translates to:
  /// **'点击查看商品详情'**
  String get chat_tap_to_view_product;

  /// No description provided for @chat_yesterday_time.
  ///
  /// In zh, this message translates to:
  /// **'昨天 {time}'**
  String chat_yesterday_time(String time);

  /// No description provided for @chat_no_messages_brief.
  ///
  /// In zh, this message translates to:
  /// **'暂无消息'**
  String get chat_no_messages_brief;

  /// No description provided for @chat_select_image_error.
  ///
  /// In zh, this message translates to:
  /// **'选择图片出错: {error}'**
  String chat_select_image_error(String error);

  /// No description provided for @after_sales_reason_none.
  ///
  /// In zh, this message translates to:
  /// **'无'**
  String get after_sales_reason_none;

  /// No description provided for @seller_auth_status_title.
  ///
  /// In zh, this message translates to:
  /// **'{type}认证'**
  String seller_auth_status_title(String type);

  /// No description provided for @seller_auth_status_label.
  ///
  /// In zh, this message translates to:
  /// **'认证状态：'**
  String get seller_auth_status_label;

  /// No description provided for @seller_auth_status_name_label.
  ///
  /// In zh, this message translates to:
  /// **'认证名称：'**
  String get seller_auth_status_name_label;

  /// No description provided for @seller_auth_status_materials.
  ///
  /// In zh, this message translates to:
  /// **'认证材料'**
  String get seller_auth_status_materials;

  /// No description provided for @seller_auth_status_no_materials.
  ///
  /// In zh, this message translates to:
  /// **'暂无认证材料'**
  String get seller_auth_status_no_materials;

  /// No description provided for @seller_auth_status_info.
  ///
  /// In zh, this message translates to:
  /// **'认证信息'**
  String get seller_auth_status_info;

  /// No description provided for @seller_auth_status_history.
  ///
  /// In zh, this message translates to:
  /// **'认证历史'**
  String get seller_auth_status_history;

  /// No description provided for @seller_auth_status_no_history.
  ///
  /// In zh, this message translates to:
  /// **'暂无历史记录'**
  String get seller_auth_status_no_history;

  /// No description provided for @seller_auth_status_reapply.
  ///
  /// In zh, this message translates to:
  /// **'重新认证'**
  String get seller_auth_status_reapply;

  /// No description provided for @seller_auth_status_approved_hint.
  ///
  /// In zh, this message translates to:
  /// **'认证已通过，无需重复提交'**
  String get seller_auth_status_approved_hint;

  /// No description provided for @seller_auth_status_pending_hint.
  ///
  /// In zh, this message translates to:
  /// **'认证审核中，请耐心等待'**
  String get seller_auth_status_pending_hint;

  /// No description provided for @seller_auth_status_tag_approved.
  ///
  /// In zh, this message translates to:
  /// **'已认证'**
  String get seller_auth_status_tag_approved;

  /// No description provided for @seller_auth_status_tag_pending.
  ///
  /// In zh, this message translates to:
  /// **'审核中'**
  String get seller_auth_status_tag_pending;

  /// No description provided for @seller_auth_status_tag_rejected.
  ///
  /// In zh, this message translates to:
  /// **'未通过'**
  String get seller_auth_status_tag_rejected;

  /// No description provided for @seller_auth_status_tag_not_submitted.
  ///
  /// In zh, this message translates to:
  /// **'未提交'**
  String get seller_auth_status_tag_not_submitted;

  /// No description provided for @seller_auth_status_type_idcard.
  ///
  /// In zh, this message translates to:
  /// **'身份'**
  String get seller_auth_status_type_idcard;

  /// No description provided for @seller_auth_status_type_education.
  ///
  /// In zh, this message translates to:
  /// **'学历'**
  String get seller_auth_status_type_education;

  /// No description provided for @seller_auth_status_type_profession.
  ///
  /// In zh, this message translates to:
  /// **'职业'**
  String get seller_auth_status_type_profession;

  /// No description provided for @seller_auth_status_type_company.
  ///
  /// In zh, this message translates to:
  /// **'公司'**
  String get seller_auth_status_type_company;

  /// No description provided for @seller_auth_status_type_other.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get seller_auth_status_type_other;

  /// No description provided for @seller_auth_status_field_auth_name.
  ///
  /// In zh, this message translates to:
  /// **'认证名称'**
  String get seller_auth_status_field_auth_name;

  /// No description provided for @seller_auth_status_field_auth_type.
  ///
  /// In zh, this message translates to:
  /// **'认证类型'**
  String get seller_auth_status_field_auth_type;

  /// No description provided for @seller_auth_status_field_company_name.
  ///
  /// In zh, this message translates to:
  /// **'公司名称'**
  String get seller_auth_status_field_company_name;

  /// No description provided for @seller_auth_status_field_name.
  ///
  /// In zh, this message translates to:
  /// **'姓名'**
  String get seller_auth_status_field_name;

  /// No description provided for @seller_auth_status_field_school_name.
  ///
  /// In zh, this message translates to:
  /// **'学校名称'**
  String get seller_auth_status_field_school_name;

  /// No description provided for @seller_auth_status_field_profession.
  ///
  /// In zh, this message translates to:
  /// **'职业/职位'**
  String get seller_auth_status_field_profession;

  /// No description provided for @seller_auth_status_field_name_or_title.
  ///
  /// In zh, this message translates to:
  /// **'姓名/名称'**
  String get seller_auth_status_field_name_or_title;

  /// No description provided for @seller_auth_status_field_remarks.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get seller_auth_status_field_remarks;

  /// No description provided for @seller_auth_status_field_cert_number.
  ///
  /// In zh, this message translates to:
  /// **'证书编号'**
  String get seller_auth_status_field_cert_number;

  /// No description provided for @seller_auth_status_field_work_experience.
  ///
  /// In zh, this message translates to:
  /// **'工作经验'**
  String get seller_auth_status_field_work_experience;

  /// No description provided for @seller_auth_status_field_issuer.
  ///
  /// In zh, this message translates to:
  /// **'发证机构'**
  String get seller_auth_status_field_issuer;

  /// No description provided for @seller_auth_status_field_credit_code.
  ///
  /// In zh, this message translates to:
  /// **'统一社会信用代码'**
  String get seller_auth_status_field_credit_code;

  /// No description provided for @seller_auth_status_field_legal_rep.
  ///
  /// In zh, this message translates to:
  /// **'法人代表'**
  String get seller_auth_status_field_legal_rep;

  /// No description provided for @seller_auth_status_field_registered_capital.
  ///
  /// In zh, this message translates to:
  /// **'注册资本'**
  String get seller_auth_status_field_registered_capital;

  /// No description provided for @seller_auth_status_field_establishment_date.
  ///
  /// In zh, this message translates to:
  /// **'成立日期'**
  String get seller_auth_status_field_establishment_date;

  /// No description provided for @seller_auth_status_field_degree.
  ///
  /// In zh, this message translates to:
  /// **'学历'**
  String get seller_auth_status_field_degree;

  /// No description provided for @seller_auth_status_field_major.
  ///
  /// In zh, this message translates to:
  /// **'专业'**
  String get seller_auth_status_field_major;

  /// No description provided for @seller_auth_status_field_graduation_year.
  ///
  /// In zh, this message translates to:
  /// **'毕业年份'**
  String get seller_auth_status_field_graduation_year;

  /// No description provided for @seller_auth_status_field_id_number.
  ///
  /// In zh, this message translates to:
  /// **'身份证号'**
  String get seller_auth_status_field_id_number;

  /// No description provided for @seller_auth_status_field_valid_period.
  ///
  /// In zh, this message translates to:
  /// **'有效期'**
  String get seller_auth_status_field_valid_period;

  /// No description provided for @seller_auth_status_field_submit_time.
  ///
  /// In zh, this message translates to:
  /// **'提交时间'**
  String get seller_auth_status_field_submit_time;

  /// No description provided for @seller_auth_status_field_reject_reason.
  ///
  /// In zh, this message translates to:
  /// **'拒绝原因'**
  String get seller_auth_status_field_reject_reason;

  /// No description provided for @seller_auth_status_history_approved_title.
  ///
  /// In zh, this message translates to:
  /// **'认证申请通过'**
  String get seller_auth_status_history_approved_title;

  /// No description provided for @seller_auth_status_history_approved_desc.
  ///
  /// In zh, this message translates to:
  /// **'您的{type}认证申请已通过审核，现在您可以享受认证商家的所有权益。'**
  String seller_auth_status_history_approved_desc(String type);

  /// No description provided for @seller_auth_status_history_submitted_title.
  ///
  /// In zh, this message translates to:
  /// **'提交认证申请'**
  String get seller_auth_status_history_submitted_title;

  /// No description provided for @seller_auth_status_history_submitted_desc.
  ///
  /// In zh, this message translates to:
  /// **'您已成功提交{type}认证申请，我们将在1-3个工作日内完成审核。'**
  String seller_auth_status_history_submitted_desc(String type);

  /// No description provided for @seller_auth_status_history_rejected_title.
  ///
  /// In zh, this message translates to:
  /// **'认证申请未通过'**
  String get seller_auth_status_history_rejected_title;

  /// No description provided for @seller_auth_status_history_rejected_desc.
  ///
  /// In zh, this message translates to:
  /// **'您的{type}认证申请未通过审核。原因：{reason}'**
  String seller_auth_status_history_rejected_desc(String type, String reason);

  /// No description provided for @seller_auth_status_history_rejected_default_reason.
  ///
  /// In zh, this message translates to:
  /// **'资料不符合要求'**
  String get seller_auth_status_history_rejected_default_reason;

  /// No description provided for @seller_product_preview_title.
  ///
  /// In zh, this message translates to:
  /// **'商品预览'**
  String get seller_product_preview_title;

  /// No description provided for @seller_product_preview_back_to_edit.
  ///
  /// In zh, this message translates to:
  /// **'返回编辑'**
  String get seller_product_preview_back_to_edit;

  /// No description provided for @seller_product_preview_loading.
  ///
  /// In zh, this message translates to:
  /// **'正在加载商品信息...'**
  String get seller_product_preview_loading;

  /// No description provided for @seller_product_preview_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载商品信息失败'**
  String get seller_product_preview_load_failed;

  /// No description provided for @seller_product_preview_retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get seller_product_preview_retry;

  /// No description provided for @seller_product_preview_fetching.
  ///
  /// In zh, this message translates to:
  /// **'正在获取商品数据...'**
  String get seller_product_preview_fetching;

  /// No description provided for @seller_product_preview_hint.
  ///
  /// In zh, this message translates to:
  /// **'这是商品预览模式，买家将看到类似的界面'**
  String get seller_product_preview_hint;

  /// No description provided for @seller_product_edit_unsaved_changes_title.
  ///
  /// In zh, this message translates to:
  /// **'检测到未保存的更改'**
  String get seller_product_edit_unsaved_changes_title;

  /// No description provided for @seller_product_edit_unsaved_changes_message.
  ///
  /// In zh, this message translates to:
  /// **'您有未保存的内容，是否要保存为草稿？'**
  String get seller_product_edit_unsaved_changes_message;

  /// No description provided for @seller_product_edit_cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get seller_product_edit_cancel;

  /// No description provided for @seller_product_edit_discard.
  ///
  /// In zh, this message translates to:
  /// **'不保存'**
  String get seller_product_edit_discard;

  /// No description provided for @seller_product_edit_operation_failed.
  ///
  /// In zh, this message translates to:
  /// **'操作失败'**
  String get seller_product_edit_operation_failed;

  /// No description provided for @seller_product_edit_draft_saved.
  ///
  /// In zh, this message translates to:
  /// **'草稿保存成功'**
  String get seller_product_edit_draft_saved;

  /// No description provided for @seller_product_edit_publish_success.
  ///
  /// In zh, this message translates to:
  /// **'服务发布成功！正在审核中，请在\"在售\"列表中查看'**
  String get seller_product_edit_publish_success;

  /// No description provided for @seller_product_edit_update_success.
  ///
  /// In zh, this message translates to:
  /// **'服务更新成功'**
  String get seller_product_edit_update_success;

  /// No description provided for @seller_product_edit_max_images.
  ///
  /// In zh, this message translates to:
  /// **'最多只能上传9张图片，已选择前9张'**
  String get seller_product_edit_max_images;

  /// No description provided for @seller_product_edit_price_required.
  ///
  /// In zh, this message translates to:
  /// **'{tierName}价格必须大于0'**
  String seller_product_edit_price_required(String tierName);

  /// No description provided for @seller_product_edit_form_incomplete.
  ///
  /// In zh, this message translates to:
  /// **'表单数据不完整，请检查标红字段'**
  String get seller_product_edit_form_incomplete;

  /// No description provided for @seller_product_edit_add_attribute.
  ///
  /// In zh, this message translates to:
  /// **'添加属性'**
  String get seller_product_edit_add_attribute;

  /// No description provided for @seller_product_edit_attribute_max_chars.
  ///
  /// In zh, this message translates to:
  /// **'属性名称最多{max}个字符'**
  String seller_product_edit_attribute_max_chars(int max);

  /// No description provided for @seller_product_edit_confirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get seller_product_edit_confirm;

  /// No description provided for @seller_product_edit_options_config.
  ///
  /// In zh, this message translates to:
  /// **'选项配置'**
  String get seller_product_edit_options_config;

  /// No description provided for @seller_product_edit_new_option.
  ///
  /// In zh, this message translates to:
  /// **'新选项'**
  String get seller_product_edit_new_option;

  /// No description provided for @seller_product_edit_option_hint.
  ///
  /// In zh, this message translates to:
  /// **'输入选项内容'**
  String get seller_product_edit_option_hint;

  /// No description provided for @seller_product_edit_service_name_hint.
  ///
  /// In zh, this message translates to:
  /// **'服务名称'**
  String get seller_product_edit_service_name_hint;

  /// No description provided for @seller_product_edit_description_hint.
  ///
  /// In zh, this message translates to:
  /// **'描述一下您的服务的具体信息，如...'**
  String get seller_product_edit_description_hint;

  /// No description provided for @seller_product_edit_faq_title.
  ///
  /// In zh, this message translates to:
  /// **'常见问题编辑'**
  String get seller_product_edit_faq_title;

  /// No description provided for @seller_product_edit_faq_count.
  ///
  /// In zh, this message translates to:
  /// **'{count}个问题'**
  String seller_product_edit_faq_count(int count);

  /// No description provided for @seller_product_edit_add_question.
  ///
  /// In zh, this message translates to:
  /// **'添加问题'**
  String get seller_product_edit_add_question;

  /// No description provided for @seller_product_edit_question_label.
  ///
  /// In zh, this message translates to:
  /// **'问题'**
  String get seller_product_edit_question_label;

  /// No description provided for @seller_product_edit_question_hint.
  ///
  /// In zh, this message translates to:
  /// **'输入买家可能问的问题'**
  String get seller_product_edit_question_hint;

  /// No description provided for @seller_product_edit_delete_question.
  ///
  /// In zh, this message translates to:
  /// **'删除问题'**
  String get seller_product_edit_delete_question;

  /// No description provided for @seller_product_edit_answer_label.
  ///
  /// In zh, this message translates to:
  /// **'答案'**
  String get seller_product_edit_answer_label;

  /// No description provided for @seller_product_edit_answer_hint.
  ///
  /// In zh, this message translates to:
  /// **'输入对应的答案'**
  String get seller_product_edit_answer_hint;

  /// No description provided for @seller_product_edit_buyer_info_title.
  ///
  /// In zh, this message translates to:
  /// **'需要买家提供'**
  String get seller_product_edit_buyer_info_title;

  /// No description provided for @seller_product_edit_buyer_info_count.
  ///
  /// In zh, this message translates to:
  /// **'{count}项信息'**
  String seller_product_edit_buyer_info_count(int count);

  /// No description provided for @seller_product_edit_buyer_info_desc.
  ///
  /// In zh, this message translates to:
  /// **'选择你需要买家提供的信息类型（该信息将展示在订单详情页）'**
  String get seller_product_edit_buyer_info_desc;

  /// No description provided for @seller_product_edit_selected_items.
  ///
  /// In zh, this message translates to:
  /// **'已选择的信息项：'**
  String get seller_product_edit_selected_items;

  /// No description provided for @seller_product_edit_required.
  ///
  /// In zh, this message translates to:
  /// **'必填'**
  String get seller_product_edit_required;

  /// No description provided for @seller_product_edit_edit_tooltip.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get seller_product_edit_edit_tooltip;

  /// No description provided for @seller_product_edit_delete_tooltip.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get seller_product_edit_delete_tooltip;

  /// No description provided for @seller_product_edit_add_info_title.
  ///
  /// In zh, this message translates to:
  /// **'添加{type}信息'**
  String seller_product_edit_add_info_title(String type);

  /// No description provided for @seller_product_edit_info_label.
  ///
  /// In zh, this message translates to:
  /// **'信息标签'**
  String get seller_product_edit_info_label;

  /// No description provided for @seller_product_edit_info_label_hint.
  ///
  /// In zh, this message translates to:
  /// **'例如：公司Logo设计需求'**
  String get seller_product_edit_info_label_hint;

  /// No description provided for @seller_product_edit_info_description.
  ///
  /// In zh, this message translates to:
  /// **'详细说明'**
  String get seller_product_edit_info_description;

  /// No description provided for @seller_product_edit_info_description_hint.
  ///
  /// In zh, this message translates to:
  /// **'请详细说明需要买家提供的信息内容'**
  String get seller_product_edit_info_description_hint;

  /// No description provided for @seller_product_edit_required_field.
  ///
  /// In zh, this message translates to:
  /// **'必填项'**
  String get seller_product_edit_required_field;

  /// No description provided for @seller_product_edit_add.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get seller_product_edit_add;

  /// No description provided for @seller_product_edit_edit_info_title.
  ///
  /// In zh, this message translates to:
  /// **'编辑{type}信息'**
  String seller_product_edit_edit_info_title(String type);

  /// No description provided for @seller_product_edit_save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get seller_product_edit_save;

  /// No description provided for @seller_product_edit_cases_count.
  ///
  /// In zh, this message translates to:
  /// **'{count}个案例'**
  String seller_product_edit_cases_count(int count);

  /// No description provided for @seller_product_edit_add_case.
  ///
  /// In zh, this message translates to:
  /// **'添加案例'**
  String get seller_product_edit_add_case;

  /// No description provided for @seller_product_edit_image_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'图片加载失败'**
  String get seller_product_edit_image_load_failed;

  /// No description provided for @seller_product_edit_click_select_image.
  ///
  /// In zh, this message translates to:
  /// **'点击选择图片'**
  String get seller_product_edit_click_select_image;

  /// No description provided for @seller_product_edit_upload_failed.
  ///
  /// In zh, this message translates to:
  /// **'上传失败'**
  String get seller_product_edit_upload_failed;

  /// No description provided for @seller_product_edit_upload_retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get seller_product_edit_upload_retry;

  /// No description provided for @seller_product_edit_case_title_label.
  ///
  /// In zh, this message translates to:
  /// **'案例标题'**
  String get seller_product_edit_case_title_label;

  /// No description provided for @seller_product_edit_case_title_hint.
  ///
  /// In zh, this message translates to:
  /// **'简短描述这个案例'**
  String get seller_product_edit_case_title_hint;

  /// No description provided for @seller_product_edit_case_desc_label.
  ///
  /// In zh, this message translates to:
  /// **'案例描述'**
  String get seller_product_edit_case_desc_label;

  /// No description provided for @seller_product_edit_case_desc_hint.
  ///
  /// In zh, this message translates to:
  /// **'详细描述案例的背景、执行过程或效果'**
  String get seller_product_edit_case_desc_hint;

  /// No description provided for @seller_product_edit_select_image_and_title.
  ///
  /// In zh, this message translates to:
  /// **'请选择图片并输入标题'**
  String get seller_product_edit_select_image_and_title;

  /// No description provided for @seller_product_edit_cover_image.
  ///
  /// In zh, this message translates to:
  /// **'服务封面图'**
  String get seller_product_edit_cover_image;

  /// No description provided for @seller_product_edit_upload_success.
  ///
  /// In zh, this message translates to:
  /// **'上传成功'**
  String get seller_product_edit_upload_success;

  /// No description provided for @seller_product_edit_upload_error.
  ///
  /// In zh, this message translates to:
  /// **'上传错误: {error}'**
  String seller_product_edit_upload_error(String error);

  /// No description provided for @seller_product_edit_image_format_hint.
  ///
  /// In zh, this message translates to:
  /// **'支持jpg、png、jpeg格式，单张不超过5MB，最多可上传9张图片'**
  String get seller_product_edit_image_format_hint;

  /// No description provided for @seller_product_edit_main_image.
  ///
  /// In zh, this message translates to:
  /// **'主图'**
  String get seller_product_edit_main_image;

  /// No description provided for @seller_product_edit_tier_price_label.
  ///
  /// In zh, this message translates to:
  /// **'{tierName}价格'**
  String seller_product_edit_tier_price_label(String tierName);

  /// No description provided for @seller_product_edit_max_price.
  ///
  /// In zh, this message translates to:
  /// **'最大值：{max}'**
  String seller_product_edit_max_price(String max);

  /// No description provided for @seller_product_edit_price_exceed_max.
  ///
  /// In zh, this message translates to:
  /// **'价格不能超过{max}'**
  String seller_product_edit_price_exceed_max(String max);

  /// No description provided for @seller_product_edit_price_min.
  ///
  /// In zh, this message translates to:
  /// **'价格最小值为0.01'**
  String get seller_product_edit_price_min;

  /// No description provided for @seller_product_edit_delivery_period.
  ///
  /// In zh, this message translates to:
  /// **'交付期'**
  String get seller_product_edit_delivery_period;

  /// No description provided for @seller_product_edit_delivery_days_suffix.
  ///
  /// In zh, this message translates to:
  /// **'天'**
  String get seller_product_edit_delivery_days_suffix;

  /// No description provided for @seller_product_edit_max_days.
  ///
  /// In zh, this message translates to:
  /// **'最多{max}天'**
  String seller_product_edit_max_days(int max);

  /// No description provided for @seller_product_edit_times.
  ///
  /// In zh, this message translates to:
  /// **'次数'**
  String get seller_product_edit_times;

  /// No description provided for @seller_product_edit_times_suffix.
  ///
  /// In zh, this message translates to:
  /// **'次'**
  String get seller_product_edit_times_suffix;

  /// No description provided for @seller_product_edit_max_times.
  ///
  /// In zh, this message translates to:
  /// **'最多{max}次'**
  String seller_product_edit_max_times(int max);

  /// No description provided for @seller_product_edit_input.
  ///
  /// In zh, this message translates to:
  /// **'输入'**
  String get seller_product_edit_input;

  /// No description provided for @seller_product_edit_radio.
  ///
  /// In zh, this message translates to:
  /// **'单选'**
  String get seller_product_edit_radio;

  /// No description provided for @seller_product_edit_draft_label.
  ///
  /// In zh, this message translates to:
  /// **'草稿'**
  String get seller_product_edit_draft_label;

  /// No description provided for @seller_product_edit_draft_unsaved_label.
  ///
  /// In zh, this message translates to:
  /// **'草稿*'**
  String get seller_product_edit_draft_unsaved_label;

  /// No description provided for @seller_product_edit_publish.
  ///
  /// In zh, this message translates to:
  /// **'发布'**
  String get seller_product_edit_publish;

  /// No description provided for @seller_product_edit_yes.
  ///
  /// In zh, this message translates to:
  /// **'是'**
  String get seller_product_edit_yes;

  /// No description provided for @seller_product_edit_no.
  ///
  /// In zh, this message translates to:
  /// **'否'**
  String get seller_product_edit_no;

  /// No description provided for @seller_product_edit_add_selection_attribute.
  ///
  /// In zh, this message translates to:
  /// **'添加单选属性'**
  String get seller_product_edit_add_selection_attribute;

  /// No description provided for @seller_product_edit_default_options_yes_no.
  ///
  /// In zh, this message translates to:
  /// **'默认选项：是/否'**
  String get seller_product_edit_default_options_yes_no;

  /// No description provided for @seller_product_edit_attribute_name_label.
  ///
  /// In zh, this message translates to:
  /// **'属性名称 *'**
  String get seller_product_edit_attribute_name_label;

  /// No description provided for @seller_product_edit_attribute_name_example.
  ///
  /// In zh, this message translates to:
  /// **'例如：颜色、型号、材质、适用年龄'**
  String get seller_product_edit_attribute_name_example;

  /// No description provided for @seller_product_edit_attribute_type_label.
  ///
  /// In zh, this message translates to:
  /// **'属性类型'**
  String get seller_product_edit_attribute_type_label;

  /// No description provided for @seller_product_edit_required_item.
  ///
  /// In zh, this message translates to:
  /// **'必填项'**
  String get seller_product_edit_required_item;

  /// No description provided for @seller_product_card_sales.
  ///
  /// In zh, this message translates to:
  /// **'销量: {count}'**
  String seller_product_card_sales(int count);

  /// No description provided for @seller_product_card_view.
  ///
  /// In zh, this message translates to:
  /// **'查看'**
  String get seller_product_card_view;

  /// No description provided for @seller_image_preview_main_image.
  ///
  /// In zh, this message translates to:
  /// **'主图'**
  String get seller_image_preview_main_image;

  /// No description provided for @seller_image_preview_set_main.
  ///
  /// In zh, this message translates to:
  /// **'设为主图'**
  String get seller_image_preview_set_main;

  /// No description provided for @seller_image_preview_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'图片加载失败'**
  String get seller_image_preview_load_failed;

  /// No description provided for @seller_image_preview_delete_title.
  ///
  /// In zh, this message translates to:
  /// **'删除图片'**
  String get seller_image_preview_delete_title;

  /// No description provided for @seller_image_preview_delete_confirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除第 {index} 张图片吗？'**
  String seller_image_preview_delete_confirm(int index);

  /// No description provided for @seller_image_preview_delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get seller_image_preview_delete;

  /// No description provided for @seller_file_select.
  ///
  /// In zh, this message translates to:
  /// **'选择文件'**
  String get seller_file_select;

  /// No description provided for @seller_file_selected.
  ///
  /// In zh, this message translates to:
  /// **'已选择的文件:'**
  String get seller_file_selected;

  /// No description provided for @seller_file_size.
  ///
  /// In zh, this message translates to:
  /// **'大小: {size}'**
  String seller_file_size(String size);

  /// No description provided for @seller_file_size_unknown.
  ///
  /// In zh, this message translates to:
  /// **'无法获取大小'**
  String get seller_file_size_unknown;

  /// No description provided for @seller_file_preview_unsupported.
  ///
  /// In zh, this message translates to:
  /// **'无法预览该类型文件: {name}'**
  String seller_file_preview_unsupported(String name);

  /// No description provided for @seller_common_cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get seller_common_cancel;

  /// No description provided for @profile_user_name_default.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get profile_user_name_default;

  /// No description provided for @profile_buyer_mode.
  ///
  /// In zh, this message translates to:
  /// **'买家模式'**
  String get profile_buyer_mode;

  /// No description provided for @profile_my_orders.
  ///
  /// In zh, this message translates to:
  /// **'我的订单'**
  String get profile_my_orders;

  /// No description provided for @profile_my_dskk_section.
  ///
  /// In zh, this message translates to:
  /// **'我的关看'**
  String get profile_my_dskk_section;

  /// No description provided for @profile_liked_stories.
  ///
  /// In zh, this message translates to:
  /// **'点赞的故事'**
  String get profile_liked_stories;

  /// No description provided for @profile_logout.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get profile_logout;

  /// No description provided for @profile_avatar_updated_local.
  ///
  /// In zh, this message translates to:
  /// **'头像已更新，但尚未保存到服务器'**
  String get profile_avatar_updated_local;

  /// No description provided for @profile_image_pick_error.
  ///
  /// In zh, this message translates to:
  /// **'选择图片时出错: {error}'**
  String profile_image_pick_error(String error);

  /// No description provided for @profile_feature_not_implemented.
  ///
  /// In zh, this message translates to:
  /// **'{feature}功能尚未实现'**
  String profile_feature_not_implemented(String feature);

  /// No description provided for @profile_pending_payment_order.
  ///
  /// In zh, this message translates to:
  /// **'待付款'**
  String get profile_pending_payment_order;

  /// No description provided for @profile_in_progress_order.
  ///
  /// In zh, this message translates to:
  /// **'进行中'**
  String get profile_in_progress_order;

  /// No description provided for @profile_completed_order.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get profile_completed_order;

  /// No description provided for @profile_refund_after_sales.
  ///
  /// In zh, this message translates to:
  /// **'退款/售后'**
  String get profile_refund_after_sales;

  /// No description provided for @profile_account_deletion.
  ///
  /// In zh, this message translates to:
  /// **'账号注销'**
  String get profile_account_deletion;

  /// No description provided for @profile_bound_phone.
  ///
  /// In zh, this message translates to:
  /// **'已绑定手机号'**
  String get profile_bound_phone;

  /// No description provided for @profile_not_bound.
  ///
  /// In zh, this message translates to:
  /// **'未绑定'**
  String get profile_not_bound;

  /// No description provided for @profile_nickname.
  ///
  /// In zh, this message translates to:
  /// **'昵称'**
  String get profile_nickname;

  /// No description provided for @profile_confirm_logout.
  ///
  /// In zh, this message translates to:
  /// **'确认退出'**
  String get profile_confirm_logout;

  /// No description provided for @profile_confirm_logout_message.
  ///
  /// In zh, this message translates to:
  /// **'确定要退出登录吗？'**
  String get profile_confirm_logout_message;

  /// No description provided for @profile_confirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get profile_confirm;

  /// No description provided for @profile_update_avatar.
  ///
  /// In zh, this message translates to:
  /// **'更新头像'**
  String get profile_update_avatar;

  /// No description provided for @profile_update_avatar_confirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要更新头像吗？'**
  String get profile_update_avatar_confirm;

  /// No description provided for @profile_info_updated.
  ///
  /// In zh, this message translates to:
  /// **'个人信息更新成功！'**
  String get profile_info_updated;

  /// No description provided for @profile_avatar_upload_timeout.
  ///
  /// In zh, this message translates to:
  /// **'头像上传超时，请检查网络连接后重试'**
  String get profile_avatar_upload_timeout;

  /// No description provided for @profile_network_failed.
  ///
  /// In zh, this message translates to:
  /// **'网络连接失败，请检查网络后重试'**
  String get profile_network_failed;

  /// No description provided for @profile_avatar_optimized.
  ///
  /// In zh, this message translates to:
  /// **'头像已优化处理，压缩 {ratio}%'**
  String profile_avatar_optimized(String ratio);

  /// No description provided for @profile_avatar_process_failed.
  ///
  /// In zh, this message translates to:
  /// **'头像处理失败: {error}'**
  String profile_avatar_process_failed(String error);

  /// No description provided for @profile_logout_error.
  ///
  /// In zh, this message translates to:
  /// **'退出登录时发生错误: {error}'**
  String profile_logout_error(String error);

  /// No description provided for @profile_nickname_empty.
  ///
  /// In zh, this message translates to:
  /// **'请输入昵称'**
  String get profile_nickname_empty;

  /// No description provided for @profile_nickname_too_short.
  ///
  /// In zh, this message translates to:
  /// **'昵称至少需要2个字符'**
  String get profile_nickname_too_short;

  /// No description provided for @profile_nickname_too_long.
  ///
  /// In zh, this message translates to:
  /// **'昵称不能超过20个字符'**
  String get profile_nickname_too_long;

  /// No description provided for @profile_nickname_no_spaces.
  ///
  /// In zh, this message translates to:
  /// **'昵称不能包含空格'**
  String get profile_nickname_no_spaces;

  /// No description provided for @profile_nickname_invalid_chars.
  ///
  /// In zh, this message translates to:
  /// **'昵称只能包含中文、英文、数字和下划线'**
  String get profile_nickname_invalid_chars;

  /// No description provided for @profile_nickname_only_underscores.
  ///
  /// In zh, this message translates to:
  /// **'昵称不能只包含下划线'**
  String get profile_nickname_only_underscores;

  /// No description provided for @profile_nickname_unchanged.
  ///
  /// In zh, this message translates to:
  /// **'昵称没有变化'**
  String get profile_nickname_unchanged;

  /// No description provided for @profile_edit_nickname_title.
  ///
  /// In zh, this message translates to:
  /// **'编辑昵称'**
  String get profile_edit_nickname_title;

  /// No description provided for @profile_nickname_input_hint.
  ///
  /// In zh, this message translates to:
  /// **'请输入昵称'**
  String get profile_nickname_input_hint;

  /// No description provided for @profile_nickname_rules.
  ///
  /// In zh, this message translates to:
  /// **'请设置2-20个字符，只能包含中文、英文、数字和下划线'**
  String get profile_nickname_rules;

  /// No description provided for @profile_nickname_updated.
  ///
  /// In zh, this message translates to:
  /// **'昵称修改成功！'**
  String get profile_nickname_updated;

  /// No description provided for @profile_nickname_update_failed.
  ///
  /// In zh, this message translates to:
  /// **'昵称修改失败: {error}'**
  String profile_nickname_update_failed(String error);

  /// No description provided for @profile_submit_changes.
  ///
  /// In zh, this message translates to:
  /// **'提交修改'**
  String get profile_submit_changes;

  /// No description provided for @profile_avatar_uploaded.
  ///
  /// In zh, this message translates to:
  /// **'头像上传成功'**
  String get profile_avatar_uploaded;

  /// No description provided for @profile_updated.
  ///
  /// In zh, this message translates to:
  /// **'个人资料更新成功'**
  String get profile_updated;

  /// No description provided for @profile_reload.
  ///
  /// In zh, this message translates to:
  /// **'重新加载'**
  String get profile_reload;

  /// No description provided for @profile_account_balance.
  ///
  /// In zh, this message translates to:
  /// **'账户余额'**
  String get profile_account_balance;

  /// No description provided for @profile_pending_settlement.
  ///
  /// In zh, this message translates to:
  /// **'待结算'**
  String get profile_pending_settlement;

  /// No description provided for @profile_total_income.
  ///
  /// In zh, this message translates to:
  /// **'总收入'**
  String get profile_total_income;

  /// No description provided for @profile_load_wallet.
  ///
  /// In zh, this message translates to:
  /// **'点击加载钱包信息'**
  String get profile_load_wallet;

  /// No description provided for @profile_all_orders.
  ///
  /// In zh, this message translates to:
  /// **'全部订单'**
  String get profile_all_orders;

  /// No description provided for @profile_awaiting_payment.
  ///
  /// In zh, this message translates to:
  /// **'待付款'**
  String get profile_awaiting_payment;

  /// No description provided for @profile_awaiting_shipment.
  ///
  /// In zh, this message translates to:
  /// **'待发货'**
  String get profile_awaiting_shipment;

  /// No description provided for @profile_awaiting_receipt.
  ///
  /// In zh, this message translates to:
  /// **'待收货'**
  String get profile_awaiting_receipt;

  /// No description provided for @profile_awaiting_review.
  ///
  /// In zh, this message translates to:
  /// **'待评价'**
  String get profile_awaiting_review;

  /// No description provided for @profile_shipping_address.
  ///
  /// In zh, this message translates to:
  /// **'收货地址'**
  String get profile_shipping_address;

  /// No description provided for @profile_browsing_history.
  ///
  /// In zh, this message translates to:
  /// **'浏览历史'**
  String get profile_browsing_history;

  /// No description provided for @profile_contact_support.
  ///
  /// In zh, this message translates to:
  /// **'联系客服'**
  String get profile_contact_support;

  /// No description provided for @profile_help_center.
  ///
  /// In zh, this message translates to:
  /// **'帮助中心'**
  String get profile_help_center;

  /// No description provided for @profile_feedback.
  ///
  /// In zh, this message translates to:
  /// **'意见反馈'**
  String get profile_feedback;

  /// No description provided for @profile_switch_to_seller_mode.
  ///
  /// In zh, this message translates to:
  /// **'切换至卖家模式'**
  String get profile_switch_to_seller_mode;

  /// No description provided for @profile_take_photo.
  ///
  /// In zh, this message translates to:
  /// **'拍照'**
  String get profile_take_photo;

  /// No description provided for @profile_choose_from_album.
  ///
  /// In zh, this message translates to:
  /// **'从相册选择'**
  String get profile_choose_from_album;

  /// No description provided for @profile_image_pick_failed.
  ///
  /// In zh, this message translates to:
  /// **'选择图片失败: {error}'**
  String profile_image_pick_failed(String error);

  /// No description provided for @profile_edit_profile.
  ///
  /// In zh, this message translates to:
  /// **'编辑个人资料'**
  String get profile_edit_profile;

  /// No description provided for @profile_online_status.
  ///
  /// In zh, this message translates to:
  /// **'在线状态'**
  String get profile_online_status;

  /// No description provided for @profile_mission_title.
  ///
  /// In zh, this message translates to:
  /// **'小帮手的使命'**
  String get profile_mission_title;

  /// No description provided for @profile_mission_our_mission.
  ///
  /// In zh, this message translates to:
  /// **'我们的使命'**
  String get profile_mission_our_mission;

  /// No description provided for @profile_mission_our_mission_content.
  ///
  /// In zh, this message translates to:
  /// **'连接创意与需求，让每一个想法都能找到实现的可能。小帮手致力于为用户提供最贴心、最智能的服务体验，成为您生活和工作中最可靠的数字伙伴。'**
  String get profile_mission_our_mission_content;

  /// No description provided for @profile_mission_core_values.
  ///
  /// In zh, this message translates to:
  /// **'核心价值'**
  String get profile_mission_core_values;

  /// No description provided for @profile_mission_core_values_content.
  ///
  /// In zh, this message translates to:
  /// **'• 用户至上：始终以用户需求为出发点\n• 创新驱动：持续探索新技术和新方法\n• 诚信服务：提供可靠、透明的服务体验\n• 共同成长：与用户和合作伙伴携手前行'**
  String get profile_mission_core_values_content;

  /// No description provided for @profile_mission_service_promise.
  ///
  /// In zh, this message translates to:
  /// **'服务承诺'**
  String get profile_mission_service_promise;

  /// No description provided for @profile_mission_service_promise_content.
  ///
  /// In zh, this message translates to:
  /// **'我们承诺为每一位用户提供：\n\n✓ 7×24小时智能服务支持\n✓ 个性化的解决方案推荐\n✓ 安全可靠的数据保护\n✓ 持续优化的用户体验\n✓ 及时响应的客户服务'**
  String get profile_mission_service_promise_content;

  /// No description provided for @profile_mission_future_vision.
  ///
  /// In zh, this message translates to:
  /// **'未来愿景'**
  String get profile_mission_future_vision;

  /// No description provided for @profile_mission_future_vision_content.
  ///
  /// In zh, this message translates to:
  /// **'成为全球领先的智能服务平台，通过AI技术赋能，让每个人都能享受到个性化、高效率的数字化生活体验。我们相信，科技的力量应该让生活更美好，让创意更容易实现。'**
  String get profile_mission_future_vision_content;

  /// No description provided for @profile_mission_questions_suggestions.
  ///
  /// In zh, this message translates to:
  /// **'有问题或建议？'**
  String get profile_mission_questions_suggestions;

  /// No description provided for @profile_mission_listening.
  ///
  /// In zh, this message translates to:
  /// **'我们随时倾听您的声音，期待与您一起创造更美好的未来。'**
  String get profile_mission_listening;

  /// No description provided for @profile_mission_contact_us.
  ///
  /// In zh, this message translates to:
  /// **'联系我们'**
  String get profile_mission_contact_us;

  /// No description provided for @profile_mission_contact_coming_soon.
  ///
  /// In zh, this message translates to:
  /// **'联系功能即将上线，敬请期待！'**
  String get profile_mission_contact_coming_soon;

  /// No description provided for @profile_wallet_title.
  ///
  /// In zh, this message translates to:
  /// **'我的钱包'**
  String get profile_wallet_title;

  /// No description provided for @profile_wallet_error.
  ///
  /// In zh, this message translates to:
  /// **'错误: {error}'**
  String profile_wallet_error(String error);

  /// No description provided for @profile_wallet_occurred_error.
  ///
  /// In zh, this message translates to:
  /// **'发生错误: {error}'**
  String profile_wallet_occurred_error(String error);

  /// No description provided for @profile_wallet_retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get profile_wallet_retry;

  /// No description provided for @profile_wallet_filter_all.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get profile_wallet_filter_all;

  /// No description provided for @profile_wallet_filter_income.
  ///
  /// In zh, this message translates to:
  /// **'收入'**
  String get profile_wallet_filter_income;

  /// No description provided for @profile_wallet_filter_expense.
  ///
  /// In zh, this message translates to:
  /// **'支出'**
  String get profile_wallet_filter_expense;

  /// No description provided for @profile_wallet_no_transactions.
  ///
  /// In zh, this message translates to:
  /// **'暂无交易记录'**
  String get profile_wallet_no_transactions;

  /// No description provided for @profile_wallet_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String profile_wallet_load_failed(String error);

  /// No description provided for @profile_wallet_load_more_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载更多失败: {error}'**
  String profile_wallet_load_more_failed(String error);

  /// No description provided for @profile_wallet_account_balance.
  ///
  /// In zh, this message translates to:
  /// **'账户余额'**
  String get profile_wallet_account_balance;

  /// No description provided for @profile_wallet_pending_amount.
  ///
  /// In zh, this message translates to:
  /// **'待结算金额'**
  String get profile_wallet_pending_amount;

  /// No description provided for @profile_wallet_total_income.
  ///
  /// In zh, this message translates to:
  /// **'总收入'**
  String get profile_wallet_total_income;

  /// No description provided for @profile_wallet_withdraw.
  ///
  /// In zh, this message translates to:
  /// **'提现'**
  String get profile_wallet_withdraw;

  /// No description provided for @profile_wallet_status_completed.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get profile_wallet_status_completed;

  /// No description provided for @profile_wallet_status_pending.
  ///
  /// In zh, this message translates to:
  /// **'处理中'**
  String get profile_wallet_status_pending;

  /// No description provided for @profile_wallet_status_failed.
  ///
  /// In zh, this message translates to:
  /// **'失败'**
  String get profile_wallet_status_failed;

  /// No description provided for @profile_wallet_status_unknown.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get profile_wallet_status_unknown;

  /// No description provided for @profile_wallet_transaction_details.
  ///
  /// In zh, this message translates to:
  /// **'交易详情'**
  String get profile_wallet_transaction_details;

  /// No description provided for @profile_wallet_transaction_id.
  ///
  /// In zh, this message translates to:
  /// **'交易ID'**
  String get profile_wallet_transaction_id;

  /// No description provided for @profile_wallet_transaction_type.
  ///
  /// In zh, this message translates to:
  /// **'类型'**
  String get profile_wallet_transaction_type;

  /// No description provided for @profile_wallet_transaction_type_income.
  ///
  /// In zh, this message translates to:
  /// **'收入'**
  String get profile_wallet_transaction_type_income;

  /// No description provided for @profile_wallet_transaction_type_expense.
  ///
  /// In zh, this message translates to:
  /// **'支出'**
  String get profile_wallet_transaction_type_expense;

  /// No description provided for @profile_wallet_transaction_amount.
  ///
  /// In zh, this message translates to:
  /// **'金额'**
  String get profile_wallet_transaction_amount;

  /// No description provided for @profile_wallet_transaction_description.
  ///
  /// In zh, this message translates to:
  /// **'说明'**
  String get profile_wallet_transaction_description;

  /// No description provided for @profile_wallet_transaction_date.
  ///
  /// In zh, this message translates to:
  /// **'日期'**
  String get profile_wallet_transaction_date;

  /// No description provided for @profile_wallet_transaction_status.
  ///
  /// In zh, this message translates to:
  /// **'状态'**
  String get profile_wallet_transaction_status;

  /// No description provided for @profile_wallet_close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get profile_wallet_close;

  /// No description provided for @profile_wallet_available_balance.
  ///
  /// In zh, this message translates to:
  /// **'可提现余额: {symbol}{amount}'**
  String profile_wallet_available_balance(String symbol, String amount);

  /// No description provided for @profile_wallet_withdraw_amount.
  ///
  /// In zh, this message translates to:
  /// **'提现金额'**
  String get profile_wallet_withdraw_amount;

  /// No description provided for @profile_wallet_withdraw_hint.
  ///
  /// In zh, this message translates to:
  /// **'请输入提现金额'**
  String get profile_wallet_withdraw_hint;

  /// No description provided for @profile_wallet_withdraw_time.
  ///
  /// In zh, this message translates to:
  /// **'提现到账时间：1-3个工作日'**
  String get profile_wallet_withdraw_time;

  /// No description provided for @profile_wallet_invalid_amount.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的提现金额'**
  String get profile_wallet_invalid_amount;

  /// No description provided for @profile_wallet_exceed_balance.
  ///
  /// In zh, this message translates to:
  /// **'提现金额不能超过可用余额'**
  String get profile_wallet_exceed_balance;

  /// No description provided for @profile_wallet_confirm_withdraw.
  ///
  /// In zh, this message translates to:
  /// **'确认提现'**
  String get profile_wallet_confirm_withdraw;

  /// No description provided for @profile_wallet_withdraw_submitted.
  ///
  /// In zh, this message translates to:
  /// **'提现申请已提交：{symbol}{amount}'**
  String profile_wallet_withdraw_submitted(String symbol, String amount);

  /// No description provided for @profile_wallet_not_implemented.
  ///
  /// In zh, this message translates to:
  /// **'该功能暂未实现'**
  String get profile_wallet_not_implemented;

  /// No description provided for @auth_verification_expired.
  ///
  /// In zh, this message translates to:
  /// **'验证码已过期'**
  String get auth_verification_expired;

  /// No description provided for @auth_login_failed.
  ///
  /// In zh, this message translates to:
  /// **'登录失败: {error}'**
  String auth_login_failed(String error);

  /// No description provided for @auth_code_send_failed.
  ///
  /// In zh, this message translates to:
  /// **'验证码发送失败: {error}'**
  String auth_code_send_failed(String error);

  /// No description provided for @auth_login_success.
  ///
  /// In zh, this message translates to:
  /// **'登录成功!'**
  String get auth_login_success;

  /// No description provided for @auth_login.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get auth_login;

  /// No description provided for @auth_privacy_policy.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get auth_privacy_policy;

  /// No description provided for @auth_and.
  ///
  /// In zh, this message translates to:
  /// **'和'**
  String get auth_and;

  /// No description provided for @auth_user_agreement.
  ///
  /// In zh, this message translates to:
  /// **'用户协议'**
  String get auth_user_agreement;

  /// No description provided for @auth_invalid_phone.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的11位手机号'**
  String get auth_invalid_phone;

  /// No description provided for @auth_get_code.
  ///
  /// In zh, this message translates to:
  /// **'获取验证码'**
  String get auth_get_code;

  /// No description provided for @payment_creating_order.
  ///
  /// In zh, this message translates to:
  /// **'创建订单中...'**
  String get payment_creating_order;

  /// No description provided for @payment_processing.
  ///
  /// In zh, this message translates to:
  /// **'支付中...'**
  String get payment_processing;

  /// No description provided for @payment_credit_card.
  ///
  /// In zh, this message translates to:
  /// **'信用卡支付'**
  String get payment_credit_card;

  /// No description provided for @payment_confirm_order.
  ///
  /// In zh, this message translates to:
  /// **'确认订单'**
  String get payment_confirm_order;

  /// No description provided for @payment_quantity_label.
  ///
  /// In zh, this message translates to:
  /// **'数量:'**
  String get payment_quantity_label;

  /// No description provided for @payment_order_summary.
  ///
  /// In zh, this message translates to:
  /// **'订单摘要'**
  String get payment_order_summary;

  /// No description provided for @payment_product_amount.
  ///
  /// In zh, this message translates to:
  /// **'商品金额'**
  String get payment_product_amount;

  /// No description provided for @payment_quantity.
  ///
  /// In zh, this message translates to:
  /// **'数量'**
  String get payment_quantity;

  /// No description provided for @payment_order_total.
  ///
  /// In zh, this message translates to:
  /// **'订单总计'**
  String get payment_order_total;

  /// No description provided for @payment_method.
  ///
  /// In zh, this message translates to:
  /// **'支付方式'**
  String get payment_method;

  /// No description provided for @payment_processing_ellipsis.
  ///
  /// In zh, this message translates to:
  /// **'处理中...'**
  String get payment_processing_ellipsis;

  /// No description provided for @payment_confirm_pay.
  ///
  /// In zh, this message translates to:
  /// **'确认支付'**
  String get payment_confirm_pay;

  /// No description provided for @payment_success.
  ///
  /// In zh, this message translates to:
  /// **'支付成功'**
  String get payment_success;

  /// No description provided for @payment_failed.
  ///
  /// In zh, this message translates to:
  /// **'支付失败'**
  String get payment_failed;

  /// No description provided for @payment_view_order_detail.
  ///
  /// In zh, this message translates to:
  /// **'查看订单详情'**
  String get payment_view_order_detail;

  /// No description provided for @payment_back_to_orders.
  ///
  /// In zh, this message translates to:
  /// **'返回订单列表'**
  String get payment_back_to_orders;

  /// No description provided for @payment_success_tip.
  ///
  /// In zh, this message translates to:
  /// **'感谢您的购买！您可以在订单中查看详情。'**
  String get payment_success_tip;

  /// No description provided for @payment_failed_tip.
  ///
  /// In zh, this message translates to:
  /// **'支付未成功，请重试或选择其他支付方式。'**
  String get payment_failed_tip;

  /// No description provided for @home_banner_image_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'图片加载失败'**
  String get home_banner_image_load_failed;

  /// No description provided for @home_banner_placeholder.
  ///
  /// In zh, this message translates to:
  /// **'轮播图 {index}'**
  String home_banner_placeholder(int index);

  /// No description provided for @home_no_data.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get home_no_data;

  /// No description provided for @product_detail_no_faq.
  ///
  /// In zh, this message translates to:
  /// **'暂无常见问题'**
  String get product_detail_no_faq;

  /// No description provided for @product_detail_buy_button.
  ///
  /// In zh, this message translates to:
  /// **'一键购买 {price}'**
  String product_detail_buy_button(String price);

  /// No description provided for @product_detail_buyer_requirements.
  ///
  /// In zh, this message translates to:
  /// **'需要买家提供'**
  String get product_detail_buyer_requirements;

  /// No description provided for @product_detail_no_buyer_requirements.
  ///
  /// In zh, this message translates to:
  /// **'卖家暂未设置需要买家提供的信息'**
  String get product_detail_no_buyer_requirements;

  /// No description provided for @after_sales_apply.
  ///
  /// In zh, this message translates to:
  /// **'申请售后'**
  String get after_sales_apply;

  /// No description provided for @after_sales_apply_remake.
  ///
  /// In zh, this message translates to:
  /// **'申请重新制作'**
  String get after_sales_apply_remake;

  /// No description provided for @after_sales_apply_supplement.
  ///
  /// In zh, this message translates to:
  /// **'申请补充'**
  String get after_sales_apply_supplement;

  /// No description provided for @after_sales_apply_refund.
  ///
  /// In zh, this message translates to:
  /// **'申请退款'**
  String get after_sales_apply_refund;

  /// No description provided for @after_sales_max_images.
  ///
  /// In zh, this message translates to:
  /// **'最多只能上传 {max} 张图片'**
  String after_sales_max_images(int max);

  /// No description provided for @after_sales_images_processed.
  ///
  /// In zh, this message translates to:
  /// **'成功处理 {count} 张图片，平均压缩 {ratio}%'**
  String after_sales_images_processed(int count, String ratio);

  /// No description provided for @after_sales_images_failed.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张图片处理失败'**
  String after_sales_images_failed(int count);

  /// No description provided for @after_sales_image_pick_failed.
  ///
  /// In zh, this message translates to:
  /// **'选择图片失败: {error}'**
  String after_sales_image_pick_failed(String error);

  /// No description provided for @after_sales_select_reason.
  ///
  /// In zh, this message translates to:
  /// **'请选择售后原因'**
  String get after_sales_select_reason;

  /// No description provided for @after_sales_reason_label.
  ///
  /// In zh, this message translates to:
  /// **'售后原因'**
  String get after_sales_reason_label;

  /// No description provided for @after_sales_reason_quality.
  ///
  /// In zh, this message translates to:
  /// **'商品质量问题'**
  String get after_sales_reason_quality;

  /// No description provided for @after_sales_reason_mismatch.
  ///
  /// In zh, this message translates to:
  /// **'商品与描述不符'**
  String get after_sales_reason_mismatch;

  /// No description provided for @after_sales_reason_wrong_item.
  ///
  /// In zh, this message translates to:
  /// **'卖家发错货'**
  String get after_sales_reason_wrong_item;

  /// No description provided for @after_sales_reason_unwanted.
  ///
  /// In zh, this message translates to:
  /// **'不想要了'**
  String get after_sales_reason_unwanted;

  /// No description provided for @after_sales_reason_other.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get after_sales_reason_other;

  /// No description provided for @after_sales_description_label.
  ///
  /// In zh, this message translates to:
  /// **'问题描述'**
  String get after_sales_description_label;

  /// No description provided for @after_sales_description_hint.
  ///
  /// In zh, this message translates to:
  /// **'请详细描述您遇到的问题...'**
  String get after_sales_description_hint;

  /// No description provided for @after_sales_refund_max_hint.
  ///
  /// In zh, this message translates to:
  /// **'最多可退 {symbol}{amount}'**
  String after_sales_refund_max_hint(String symbol, String amount);

  /// No description provided for @after_sales_enter_refund_amount.
  ///
  /// In zh, this message translates to:
  /// **'请输入退款金额'**
  String get after_sales_enter_refund_amount;

  /// No description provided for @after_sales_invalid_amount.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的金额数字'**
  String get after_sales_invalid_amount;

  /// No description provided for @after_sales_amount_must_positive.
  ///
  /// In zh, this message translates to:
  /// **'退款金额必须大于0'**
  String get after_sales_amount_must_positive;

  /// No description provided for @after_sales_amount_exceed.
  ///
  /// In zh, this message translates to:
  /// **'退款金额不能超过 {symbol}{amount}'**
  String after_sales_amount_exceed(String symbol, String amount);

  /// No description provided for @after_sales_upload_proof.
  ///
  /// In zh, this message translates to:
  /// **'上传凭证 (最多 {max} 张)'**
  String after_sales_upload_proof(int max);

  /// No description provided for @after_sales_remove_image.
  ///
  /// In zh, this message translates to:
  /// **'移除图片'**
  String get after_sales_remove_image;

  /// No description provided for @after_sales_submit.
  ///
  /// In zh, this message translates to:
  /// **'提交申请'**
  String get after_sales_submit;

  /// No description provided for @after_sales_loading_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String after_sales_loading_failed(String error);

  /// No description provided for @after_sales_detail_retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get after_sales_detail_retry;

  /// No description provided for @after_sales_initializing.
  ///
  /// In zh, this message translates to:
  /// **'正在初始化...'**
  String get after_sales_initializing;

  /// No description provided for @after_sales_status_audit_reject.
  ///
  /// In zh, this message translates to:
  /// **'售后申请已拒绝'**
  String get after_sales_status_audit_reject;

  /// No description provided for @after_sales_status_refund_success.
  ///
  /// In zh, this message translates to:
  /// **'退款成功'**
  String get after_sales_status_refund_success;

  /// No description provided for @after_sales_status_processing.
  ///
  /// In zh, this message translates to:
  /// **'售后处理中'**
  String get after_sales_status_processing;

  /// No description provided for @after_sales_subtitle_wait_audit.
  ///
  /// In zh, this message translates to:
  /// **'卖家会在48小时内处理您的申请'**
  String get after_sales_subtitle_wait_audit;

  /// No description provided for @after_sales_subtitle_audit_pass.
  ///
  /// In zh, this message translates to:
  /// **'退款将在1-3个工作日内到账'**
  String get after_sales_subtitle_audit_pass;

  /// No description provided for @after_sales_subtitle_audit_reject.
  ///
  /// In zh, this message translates to:
  /// **'如有异议，可申请平台介入'**
  String get after_sales_subtitle_audit_reject;

  /// No description provided for @after_sales_subtitle_refund_success.
  ///
  /// In zh, this message translates to:
  /// **'退款已完成，请查收'**
  String get after_sales_subtitle_refund_success;

  /// No description provided for @after_sales_subtitle_canceled.
  ///
  /// In zh, this message translates to:
  /// **'您已取消售后申请'**
  String get after_sales_subtitle_canceled;

  /// No description provided for @after_sales_subtitle_default.
  ///
  /// In zh, this message translates to:
  /// **'请耐心等待处理结果'**
  String get after_sales_subtitle_default;

  /// No description provided for @after_sales_product_info.
  ///
  /// In zh, this message translates to:
  /// **'商品信息'**
  String get after_sales_product_info;

  /// No description provided for @after_sales_product_unknown.
  ///
  /// In zh, this message translates to:
  /// **'商品名称未知'**
  String get after_sales_product_unknown;

  /// No description provided for @after_sales_spec.
  ///
  /// In zh, this message translates to:
  /// **'规格：{spec}'**
  String after_sales_spec(String spec);

  /// No description provided for @after_sales_quantity.
  ///
  /// In zh, this message translates to:
  /// **'数量：{count}'**
  String after_sales_quantity(int count);

  /// No description provided for @after_sales_info.
  ///
  /// In zh, this message translates to:
  /// **'售后信息'**
  String get after_sales_info;

  /// No description provided for @after_sales_application_number.
  ///
  /// In zh, this message translates to:
  /// **'申请单号'**
  String get after_sales_application_number;

  /// No description provided for @after_sales_application_time.
  ///
  /// In zh, this message translates to:
  /// **'申请时间'**
  String get after_sales_application_time;

  /// No description provided for @after_sales_refund_amount_label.
  ///
  /// In zh, this message translates to:
  /// **'退款金额'**
  String get after_sales_refund_amount_label;

  /// No description provided for @after_sales_application_reason.
  ///
  /// In zh, this message translates to:
  /// **'申请原因'**
  String get after_sales_application_reason;

  /// No description provided for @after_sales_detailed_description.
  ///
  /// In zh, this message translates to:
  /// **'详细说明'**
  String get after_sales_detailed_description;

  /// No description provided for @after_sales_audit_remark.
  ///
  /// In zh, this message translates to:
  /// **'审核备注'**
  String get after_sales_audit_remark;

  /// No description provided for @after_sales_revoke.
  ///
  /// In zh, this message translates to:
  /// **'撤销申请'**
  String get after_sales_revoke;

  /// No description provided for @after_sales_modify.
  ///
  /// In zh, this message translates to:
  /// **'修改申请'**
  String get after_sales_modify;

  /// No description provided for @after_sales_platform_intervention.
  ///
  /// In zh, this message translates to:
  /// **'平台介入'**
  String get after_sales_platform_intervention;

  /// No description provided for @after_sales_list_title.
  ///
  /// In zh, this message translates to:
  /// **'售后列表'**
  String get after_sales_list_title;

  /// No description provided for @after_sales_no_records.
  ///
  /// In zh, this message translates to:
  /// **'暂无售后申请记录'**
  String get after_sales_no_records;

  /// No description provided for @after_sales_please_wait.
  ///
  /// In zh, this message translates to:
  /// **'请稍候...'**
  String get after_sales_please_wait;

  /// No description provided for @after_sales_unknown_product.
  ///
  /// In zh, this message translates to:
  /// **'未知商品'**
  String get after_sales_unknown_product;

  /// No description provided for @after_sales_status_label.
  ///
  /// In zh, this message translates to:
  /// **'状态: {status}'**
  String after_sales_status_label(String status);

  /// No description provided for @after_sales_select_type.
  ///
  /// In zh, this message translates to:
  /// **'选择售后类型'**
  String get after_sales_select_type;

  /// No description provided for @after_sales_type_remake.
  ///
  /// In zh, this message translates to:
  /// **'我要重新制作'**
  String get after_sales_type_remake;

  /// No description provided for @after_sales_type_remake_desc.
  ///
  /// In zh, this message translates to:
  /// **'对收到的制作不满意，可与作者协商重做'**
  String get after_sales_type_remake_desc;

  /// No description provided for @after_sales_type_supplement.
  ///
  /// In zh, this message translates to:
  /// **'我要补充'**
  String get after_sales_type_supplement;

  /// No description provided for @after_sales_type_supplement_desc.
  ///
  /// In zh, this message translates to:
  /// **'收到的制作不完善，可与作者协商补充'**
  String get after_sales_type_supplement_desc;

  /// No description provided for @after_sales_type_refund.
  ///
  /// In zh, this message translates to:
  /// **'我要退款'**
  String get after_sales_type_refund;

  /// No description provided for @after_sales_type_refund_desc.
  ///
  /// In zh, this message translates to:
  /// **'协商退款'**
  String get after_sales_type_refund_desc;

  /// No description provided for @after_sales_no_record_for_order.
  ///
  /// In zh, this message translates to:
  /// **'该订单没有对应的售后记录'**
  String get after_sales_no_record_for_order;

  /// No description provided for @after_sales_unknown_error.
  ///
  /// In zh, this message translates to:
  /// **'加载售后详情时发生未知错误: {error}'**
  String after_sales_unknown_error(String error);

  /// No description provided for @after_sales_server_error.
  ///
  /// In zh, this message translates to:
  /// **'服务器错误'**
  String get after_sales_server_error;

  /// No description provided for @after_sales_cache_error.
  ///
  /// In zh, this message translates to:
  /// **'缓存错误'**
  String get after_sales_cache_error;

  /// No description provided for @after_sales_network_error.
  ///
  /// In zh, this message translates to:
  /// **'网络连接错误'**
  String get after_sales_network_error;

  /// No description provided for @after_sales_general_unknown_error.
  ///
  /// In zh, this message translates to:
  /// **'发生未知错误'**
  String get after_sales_general_unknown_error;

  /// No description provided for @favorites_title.
  ///
  /// In zh, this message translates to:
  /// **'我的收藏'**
  String get favorites_title;

  /// No description provided for @favorites_tab_services.
  ///
  /// In zh, this message translates to:
  /// **'服务'**
  String get favorites_tab_services;

  /// No description provided for @favorites_tab_sellers.
  ///
  /// In zh, this message translates to:
  /// **'卖家'**
  String get favorites_tab_sellers;

  /// No description provided for @favorites_close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get favorites_close;

  /// No description provided for @favorites_empty_services.
  ///
  /// In zh, this message translates to:
  /// **'暂无收藏的服务'**
  String get favorites_empty_services;

  /// No description provided for @favorites_empty_sellers.
  ///
  /// In zh, this message translates to:
  /// **'暂无关注的卖家'**
  String get favorites_empty_sellers;

  /// No description provided for @favorites_empty_services_hint.
  ///
  /// In zh, this message translates to:
  /// **'您可以在浏览服务时点击收藏按钮'**
  String get favorites_empty_services_hint;

  /// No description provided for @favorites_empty_sellers_hint.
  ///
  /// In zh, this message translates to:
  /// **'您可以在浏览卖家时点击关注按钮'**
  String get favorites_empty_sellers_hint;

  /// No description provided for @favorites_unfollow.
  ///
  /// In zh, this message translates to:
  /// **'取消关注'**
  String get favorites_unfollow;

  /// No description provided for @favorites_remove.
  ///
  /// In zh, this message translates to:
  /// **'取消收藏'**
  String get favorites_remove;

  /// No description provided for @favorites_seller_type_member.
  ///
  /// In zh, this message translates to:
  /// **'个人卖家'**
  String get favorites_seller_type_member;

  /// No description provided for @favorites_seller_type_enterprise.
  ///
  /// In zh, this message translates to:
  /// **'企业卖家'**
  String get favorites_seller_type_enterprise;

  /// No description provided for @favorites_seller_type_platform.
  ///
  /// In zh, this message translates to:
  /// **'平台卖家'**
  String get favorites_seller_type_platform;

  /// No description provided for @favorites_seller_type_default.
  ///
  /// In zh, this message translates to:
  /// **'卖家'**
  String get favorites_seller_type_default;

  /// No description provided for @favorites_status_active.
  ///
  /// In zh, this message translates to:
  /// **'活跃'**
  String get favorites_status_active;

  /// No description provided for @favorites_status_inactive.
  ///
  /// In zh, this message translates to:
  /// **'不活跃'**
  String get favorites_status_inactive;

  /// No description provided for @favorites_status_suspended.
  ///
  /// In zh, this message translates to:
  /// **'已暂停'**
  String get favorites_status_suspended;

  /// No description provided for @favorites_status_banned.
  ///
  /// In zh, this message translates to:
  /// **'已封禁'**
  String get favorites_status_banned;

  /// No description provided for @ai_docs_chat_create_failed.
  ///
  /// In zh, this message translates to:
  /// **'无法创建聊天会话: {error}'**
  String ai_docs_chat_create_failed(String error);

  /// No description provided for @ai_docs_chat_room_empty.
  ///
  /// In zh, this message translates to:
  /// **'聊天室ID为空，无法进入聊天'**
  String get ai_docs_chat_room_empty;

  /// No description provided for @ai_docs_chat_enter_error.
  ///
  /// In zh, this message translates to:
  /// **'进入聊天时发生错误: {error}'**
  String ai_docs_chat_enter_error(String error);

  /// No description provided for @ai_docs_rate_limit_details.
  ///
  /// In zh, this message translates to:
  /// **'使用次数详情'**
  String get ai_docs_rate_limit_details;

  /// No description provided for @ai_docs_rate_limit_remaining.
  ///
  /// In zh, this message translates to:
  /// **'剩余 {count} 次'**
  String ai_docs_rate_limit_remaining(int count);

  /// No description provided for @ai_docs_rate_limit_reset_in.
  ///
  /// In zh, this message translates to:
  /// **'{time}后重置'**
  String ai_docs_rate_limit_reset_in(String time);

  /// No description provided for @ai_docs_rate_limit_rules.
  ///
  /// In zh, this message translates to:
  /// **'使用规则'**
  String get ai_docs_rate_limit_rules;

  /// No description provided for @ai_docs_rate_limit_burst.
  ///
  /// In zh, this message translates to:
  /// **'突发限制'**
  String get ai_docs_rate_limit_burst;

  /// No description provided for @ai_docs_rate_limit_hourly.
  ///
  /// In zh, this message translates to:
  /// **'小时限制'**
  String get ai_docs_rate_limit_hourly;

  /// No description provided for @ai_docs_rate_limit_upgrade.
  ///
  /// In zh, this message translates to:
  /// **'升级获取更多次数'**
  String get ai_docs_rate_limit_upgrade;

  /// No description provided for @ai_docs_rate_limit_upgrade_coming.
  ///
  /// In zh, this message translates to:
  /// **'升级功能即将推出'**
  String get ai_docs_rate_limit_upgrade_coming;

  /// No description provided for @ai_docs_rate_limit_time_hours.
  ///
  /// In zh, this message translates to:
  /// **'{hours}小时'**
  String ai_docs_rate_limit_time_hours(int hours);

  /// No description provided for @ai_docs_rate_limit_time_minutes.
  ///
  /// In zh, this message translates to:
  /// **'{minutes}分钟'**
  String ai_docs_rate_limit_time_minutes(int minutes);

  /// No description provided for @ai_docs_rate_limit_time_seconds.
  ///
  /// In zh, this message translates to:
  /// **'{seconds}秒'**
  String ai_docs_rate_limit_time_seconds(int seconds);

  /// No description provided for @ai_docs_rate_limit_reset.
  ///
  /// In zh, this message translates to:
  /// **'已重置'**
  String get ai_docs_rate_limit_reset;

  /// No description provided for @ai_docs_rate_limit_warning_title.
  ///
  /// In zh, this message translates to:
  /// **'使用次数即将耗尽'**
  String get ai_docs_rate_limit_warning_title;

  /// No description provided for @ai_docs_rate_limit_today_remaining.
  ///
  /// In zh, this message translates to:
  /// **'今日剩余次数'**
  String get ai_docs_rate_limit_today_remaining;

  /// No description provided for @ai_docs_rate_limit_remaining_info.
  ///
  /// In zh, this message translates to:
  /// **'还可使用 {count} 次，{time}后重置'**
  String ai_docs_rate_limit_remaining_info(int count, String time);

  /// No description provided for @ai_docs_rate_limit_today_usage.
  ///
  /// In zh, this message translates to:
  /// **'今日使用情况'**
  String get ai_docs_rate_limit_today_usage;

  /// No description provided for @auth_verification_code_expired.
  ///
  /// In zh, this message translates to:
  /// **'验证码已过期'**
  String get auth_verification_code_expired;

  /// No description provided for @auth_get_verification_code.
  ///
  /// In zh, this message translates to:
  /// **'获取验证码'**
  String get auth_get_verification_code;

  /// No description provided for @home_image_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'图片加载失败'**
  String get home_image_load_failed;

  /// No description provided for @home_reached_end.
  ///
  /// In zh, this message translates to:
  /// **'已经到底了'**
  String get home_reached_end;

  /// No description provided for @home_reviews_title.
  ///
  /// In zh, this message translates to:
  /// **'评论'**
  String get home_reviews_title;

  /// No description provided for @home_reviews_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String home_reviews_load_failed(String error);

  /// No description provided for @home_reviews_no_reviews.
  ///
  /// In zh, this message translates to:
  /// **'暂无评论'**
  String get home_reviews_no_reviews;

  /// No description provided for @home_reviews_default_content.
  ///
  /// In zh, this message translates to:
  /// **'不错，很有耐心'**
  String get home_reviews_default_content;

  /// No description provided for @home_reviews_seller_reply.
  ///
  /// In zh, this message translates to:
  /// **'卖家回复'**
  String get home_reviews_seller_reply;

  /// No description provided for @home_reviews_years_ago.
  ///
  /// In zh, this message translates to:
  /// **'{count}年前'**
  String home_reviews_years_ago(int count);

  /// No description provided for @home_reviews_months_ago.
  ///
  /// In zh, this message translates to:
  /// **'{count}月前'**
  String home_reviews_months_ago(int count);

  /// No description provided for @home_reviews_days_ago.
  ///
  /// In zh, this message translates to:
  /// **'{count}天前'**
  String home_reviews_days_ago(int count);

  /// No description provided for @home_reviews_hours_ago.
  ///
  /// In zh, this message translates to:
  /// **'{count}小时前'**
  String home_reviews_hours_ago(int count);

  /// No description provided for @home_reviews_minutes_ago.
  ///
  /// In zh, this message translates to:
  /// **'{count}分钟前'**
  String home_reviews_minutes_ago(int count);

  /// No description provided for @home_reviews_just_now.
  ///
  /// In zh, this message translates to:
  /// **'刚刚'**
  String get home_reviews_just_now;

  /// No description provided for @after_sales_apply_title.
  ///
  /// In zh, this message translates to:
  /// **'申请售后'**
  String get after_sales_apply_title;

  /// No description provided for @after_sales_select_reason_hint.
  ///
  /// In zh, this message translates to:
  /// **'请选择售后原因'**
  String get after_sales_select_reason_hint;

  /// No description provided for @after_sales_select_reason_validator.
  ///
  /// In zh, this message translates to:
  /// **'请选择售后原因'**
  String get after_sales_select_reason_validator;

  /// No description provided for @after_sales_refund_amount_hint.
  ///
  /// In zh, this message translates to:
  /// **'最多可退 {symbol}{amount}'**
  String after_sales_refund_amount_hint(String symbol, String amount);

  /// No description provided for @after_sales_refund_amount_required.
  ///
  /// In zh, this message translates to:
  /// **'请输入退款金额'**
  String get after_sales_refund_amount_required;

  /// No description provided for @after_sales_refund_amount_invalid.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的金额数字'**
  String get after_sales_refund_amount_invalid;

  /// No description provided for @after_sales_refund_amount_positive.
  ///
  /// In zh, this message translates to:
  /// **'退款金额必须大于0'**
  String get after_sales_refund_amount_positive;

  /// No description provided for @after_sales_refund_amount_exceed.
  ///
  /// In zh, this message translates to:
  /// **'退款金额不能超过 {symbol}{amount}'**
  String after_sales_refund_amount_exceed(String symbol, String amount);

  /// No description provided for @after_sales_upload_evidence.
  ///
  /// In zh, this message translates to:
  /// **'上传凭证 (最多 {max} 张)'**
  String after_sales_upload_evidence(int max);

  /// No description provided for @after_sales_image_process_success.
  ///
  /// In zh, this message translates to:
  /// **'成功处理 {count} 张图片，平均压缩 {ratio}%'**
  String after_sales_image_process_success(int count, String ratio);

  /// No description provided for @after_sales_image_process_failed.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张图片处理失败'**
  String after_sales_image_process_failed(int count);

  /// No description provided for @after_sales_detail_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String after_sales_detail_load_failed(String error);

  /// No description provided for @after_sales_detail_initializing.
  ///
  /// In zh, this message translates to:
  /// **'正在初始化...'**
  String get after_sales_detail_initializing;

  /// No description provided for @after_sales_info_title.
  ///
  /// In zh, this message translates to:
  /// **'售后信息'**
  String get after_sales_info_title;

  /// No description provided for @after_sales_info_order_number.
  ///
  /// In zh, this message translates to:
  /// **'申请单号'**
  String get after_sales_info_order_number;

  /// No description provided for @after_sales_info_apply_time.
  ///
  /// In zh, this message translates to:
  /// **'申请时间'**
  String get after_sales_info_apply_time;

  /// No description provided for @after_sales_info_refund_amount.
  ///
  /// In zh, this message translates to:
  /// **'退款金额'**
  String get after_sales_info_refund_amount;

  /// No description provided for @after_sales_info_reason.
  ///
  /// In zh, this message translates to:
  /// **'申请原因'**
  String get after_sales_info_reason;

  /// No description provided for @after_sales_info_description.
  ///
  /// In zh, this message translates to:
  /// **'详细说明'**
  String get after_sales_info_description;

  /// No description provided for @after_sales_info_audit_remark.
  ///
  /// In zh, this message translates to:
  /// **'审核备注'**
  String get after_sales_info_audit_remark;

  /// No description provided for @after_sales_list_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String after_sales_list_load_failed(String error);

  /// No description provided for @after_sales_list_empty.
  ///
  /// In zh, this message translates to:
  /// **'暂无售后申请记录'**
  String get after_sales_list_empty;

  /// No description provided for @after_sales_list_loading.
  ///
  /// In zh, this message translates to:
  /// **'请稍候...'**
  String get after_sales_list_loading;

  /// No description provided for @after_sales_list_unknown_product.
  ///
  /// In zh, this message translates to:
  /// **'未知商品'**
  String get after_sales_list_unknown_product;

  /// No description provided for @after_sales_list_status.
  ///
  /// In zh, this message translates to:
  /// **'状态: {status}'**
  String after_sales_list_status(String status);

  /// No description provided for @after_sales_list_apply_time.
  ///
  /// In zh, this message translates to:
  /// **'申请时间: {time}'**
  String after_sales_list_apply_time(String time);

  /// No description provided for @after_sales_select_type_title.
  ///
  /// In zh, this message translates to:
  /// **'选择售后类型'**
  String get after_sales_select_type_title;

  /// No description provided for @after_sales_type_remake_title.
  ///
  /// In zh, this message translates to:
  /// **'我要重新制作'**
  String get after_sales_type_remake_title;

  /// No description provided for @after_sales_type_remake_subtitle.
  ///
  /// In zh, this message translates to:
  /// **'对收到的制作不满意，可与作者协商重做'**
  String get after_sales_type_remake_subtitle;

  /// No description provided for @after_sales_type_supplement_title.
  ///
  /// In zh, this message translates to:
  /// **'我要补充'**
  String get after_sales_type_supplement_title;

  /// No description provided for @after_sales_type_supplement_subtitle.
  ///
  /// In zh, this message translates to:
  /// **'收到的制作不完善，可与作者协商补充'**
  String get after_sales_type_supplement_subtitle;

  /// No description provided for @after_sales_type_refund_title.
  ///
  /// In zh, this message translates to:
  /// **'我要退款'**
  String get after_sales_type_refund_title;

  /// No description provided for @after_sales_type_refund_subtitle.
  ///
  /// In zh, this message translates to:
  /// **'协商退款'**
  String get after_sales_type_refund_subtitle;

  /// No description provided for @favorites_seller_status_active.
  ///
  /// In zh, this message translates to:
  /// **'活跃'**
  String get favorites_seller_status_active;

  /// No description provided for @favorites_seller_status_inactive.
  ///
  /// In zh, this message translates to:
  /// **'不活跃'**
  String get favorites_seller_status_inactive;

  /// No description provided for @favorites_seller_status_suspended.
  ///
  /// In zh, this message translates to:
  /// **'已暂停'**
  String get favorites_seller_status_suspended;

  /// No description provided for @favorites_seller_status_banned.
  ///
  /// In zh, this message translates to:
  /// **'已封禁'**
  String get favorites_seller_status_banned;

  /// No description provided for @app_store_settings.
  ///
  /// In zh, this message translates to:
  /// **'店铺设置'**
  String get app_store_settings;

  /// No description provided for @app_wallet.
  ///
  /// In zh, this message translates to:
  /// **'钱包'**
  String get app_wallet;

  /// No description provided for @app_wallet_init_failed.
  ///
  /// In zh, this message translates to:
  /// **'初始化钱包页面失败'**
  String get app_wallet_init_failed;

  /// No description provided for @app_error_label.
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get app_error_label;

  /// No description provided for @app_go_back.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get app_go_back;

  /// No description provided for @app_page_not_found.
  ///
  /// In zh, this message translates to:
  /// **'页面未找到'**
  String get app_page_not_found;

  /// No description provided for @app_path_error.
  ///
  /// In zh, this message translates to:
  /// **'路径错误'**
  String get app_path_error;

  /// No description provided for @app_error_generic.
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get app_error_generic;

  /// No description provided for @app_dev_menu_title.
  ///
  /// In zh, this message translates to:
  /// **'开发调试菜单'**
  String get app_dev_menu_title;

  /// No description provided for @app_dev_common_entries.
  ///
  /// In zh, this message translates to:
  /// **'常用入口'**
  String get app_dev_common_entries;

  /// No description provided for @app_dev_dskk.
  ///
  /// In zh, this message translates to:
  /// **'DeepStream'**
  String get app_dev_dskk;

  /// No description provided for @app_dev_order_module_buyer.
  ///
  /// In zh, this message translates to:
  /// **'订单模块 (买家)'**
  String get app_dev_order_module_buyer;

  /// No description provided for @app_dev_order_list.
  ///
  /// In zh, this message translates to:
  /// **'订单列表'**
  String get app_dev_order_list;

  /// No description provided for @app_dev_order_detail_example.
  ///
  /// In zh, this message translates to:
  /// **'订单详情 (示例)'**
  String get app_dev_order_detail_example;

  /// No description provided for @app_dev_order_module_seller.
  ///
  /// In zh, this message translates to:
  /// **'订单模块 (卖家)'**
  String get app_dev_order_module_seller;

  /// No description provided for @app_dev_seller_order_list.
  ///
  /// In zh, this message translates to:
  /// **'卖家订单列表'**
  String get app_dev_seller_order_list;

  /// No description provided for @app_dev_seller_order_detail_example.
  ///
  /// In zh, this message translates to:
  /// **'卖家订单详情 (示例)'**
  String get app_dev_seller_order_detail_example;

  /// No description provided for @app_dev_seller_module.
  ///
  /// In zh, this message translates to:
  /// **'卖家模块 (Seller)'**
  String get app_dev_seller_module;

  /// No description provided for @app_dev_seller_center.
  ///
  /// In zh, this message translates to:
  /// **'卖家中心 (首页)'**
  String get app_dev_seller_center;

  /// No description provided for @app_dev_ai_docs_module.
  ///
  /// In zh, this message translates to:
  /// **'AI Docs 模块'**
  String get app_dev_ai_docs_module;

  /// No description provided for @app_dev_ai_chat.
  ///
  /// In zh, this message translates to:
  /// **'AI 聊天'**
  String get app_dev_ai_chat;

  /// No description provided for @app_dev_test_other.
  ///
  /// In zh, this message translates to:
  /// **'测试/其他'**
  String get app_dev_test_other;

  /// No description provided for @app_dev_current_credentials.
  ///
  /// In zh, this message translates to:
  /// **'当前测试凭证 (硬编码): '**
  String get app_dev_current_credentials;

  /// No description provided for @app_dev_temp_injection.
  ///
  /// In zh, this message translates to:
  /// **'(临时注入，将在 Auth 模块合并后移除)'**
  String get app_dev_temp_injection;

  /// No description provided for @app_dev_navigation_failed.
  ///
  /// In zh, this message translates to:
  /// **'跳转失败: {path} - {error}'**
  String app_dev_navigation_failed(String path, String error);

  /// No description provided for @core_processing.
  ///
  /// In zh, this message translates to:
  /// **'处理中...'**
  String get core_processing;

  /// No description provided for @core_yesterday.
  ///
  /// In zh, this message translates to:
  /// **'昨天'**
  String get core_yesterday;

  /// No description provided for @payment_test_title.
  ///
  /// In zh, this message translates to:
  /// **'支付功能测试'**
  String get payment_test_title;

  /// No description provided for @payment_check_availability.
  ///
  /// In zh, this message translates to:
  /// **'检查支付方式可用性'**
  String get payment_check_availability;

  /// No description provided for @payment_test_params.
  ///
  /// In zh, this message translates to:
  /// **'测试参数'**
  String get payment_test_params;

  /// No description provided for @payment_order_number.
  ///
  /// In zh, this message translates to:
  /// **'订单号'**
  String get payment_order_number;

  /// No description provided for @payment_amount_yuan.
  ///
  /// In zh, this message translates to:
  /// **'金额 (元)'**
  String get payment_amount_yuan;

  /// No description provided for @payment_product_name.
  ///
  /// In zh, this message translates to:
  /// **'商品名称'**
  String get payment_product_name;

  /// No description provided for @payment_select_method.
  ///
  /// In zh, this message translates to:
  /// **'选择支付方式'**
  String get payment_select_method;

  /// No description provided for @payment_test_button.
  ///
  /// In zh, this message translates to:
  /// **'测试{method} ¥{amount}'**
  String payment_test_button(String method, String amount);

  /// No description provided for @payment_usage_instructions.
  ///
  /// In zh, this message translates to:
  /// **'使用说明'**
  String get payment_usage_instructions;

  /// No description provided for @payment_instruction_1.
  ///
  /// In zh, this message translates to:
  /// **'1. 修改上方测试参数'**
  String get payment_instruction_1;

  /// No description provided for @payment_instruction_2.
  ///
  /// In zh, this message translates to:
  /// **'2. 选择要测试的支付方式'**
  String get payment_instruction_2;

  /// No description provided for @payment_instruction_3.
  ///
  /// In zh, this message translates to:
  /// **'3. 点击测试按钮发起支付'**
  String get payment_instruction_3;

  /// No description provided for @payment_instruction_4.
  ///
  /// In zh, this message translates to:
  /// **'4. 点击右上角信息按钮检查支付方式可用性'**
  String get payment_instruction_4;

  /// No description provided for @payment_test_warning.
  ///
  /// In zh, this message translates to:
  /// **'注意：测试环境建议使用0.01元进行测试'**
  String get payment_test_warning;

  /// No description provided for @payment_test_product.
  ///
  /// In zh, this message translates to:
  /// **'测试商品'**
  String get payment_test_product;

  /// No description provided for @payment_initiated_success.
  ///
  /// In zh, this message translates to:
  /// **'支付发起成功：{message}'**
  String payment_initiated_success(String message);

  /// No description provided for @payment_failed_message.
  ///
  /// In zh, this message translates to:
  /// **'支付失败：{message}'**
  String payment_failed_message(String message);

  /// No description provided for @payment_exception.
  ///
  /// In zh, this message translates to:
  /// **'支付异常: {error}'**
  String payment_exception(String error);

  /// No description provided for @payment_availability_title.
  ///
  /// In zh, this message translates to:
  /// **'支付方式可用性'**
  String get payment_availability_title;

  /// No description provided for @payment_alipay.
  ///
  /// In zh, this message translates to:
  /// **'支付宝'**
  String get payment_alipay;

  /// No description provided for @payment_wechat.
  ///
  /// In zh, this message translates to:
  /// **'微信支付'**
  String get payment_wechat;

  /// No description provided for @payment_wallet_balance.
  ///
  /// In zh, this message translates to:
  /// **'余额支付'**
  String get payment_wallet_balance;

  /// No description provided for @payment_confirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get payment_confirm;

  /// No description provided for @payment_check_failed.
  ///
  /// In zh, this message translates to:
  /// **'检查失败: {error}'**
  String payment_check_failed(String error);

  /// No description provided for @payment_alipay_subtitle.
  ///
  /// In zh, this message translates to:
  /// **'安全快捷支付'**
  String get payment_alipay_subtitle;

  /// No description provided for @payment_wechat_subtitle.
  ///
  /// In zh, this message translates to:
  /// **'微信安全支付'**
  String get payment_wechat_subtitle;

  /// No description provided for @payment_amount_label.
  ///
  /// In zh, this message translates to:
  /// **'支付金额：'**
  String get payment_amount_label;

  /// No description provided for @payment_terms_agreement.
  ///
  /// In zh, this message translates to:
  /// **'点击\"确认支付\"即表示您同意并接受相关服务条款'**
  String get payment_terms_agreement;

  /// No description provided for @payment_create_order_failed.
  ///
  /// In zh, this message translates to:
  /// **'创建支付订单失败'**
  String get payment_create_order_failed;

  /// No description provided for @payment_method_test_title.
  ///
  /// In zh, this message translates to:
  /// **'支付方式测试'**
  String get payment_method_test_title;

  /// No description provided for @payment_alipay_pay.
  ///
  /// In zh, this message translates to:
  /// **'支付宝支付'**
  String get payment_alipay_pay;

  /// No description provided for @payment_test_functions.
  ///
  /// In zh, this message translates to:
  /// **'测试功能'**
  String get payment_test_functions;

  /// No description provided for @payment_test_alipay.
  ///
  /// In zh, this message translates to:
  /// **'测试支付宝支付'**
  String get payment_test_alipay;

  /// No description provided for @payment_test_wechat.
  ///
  /// In zh, this message translates to:
  /// **'测试微信支付'**
  String get payment_test_wechat;

  /// No description provided for @payment_test_credit_card.
  ///
  /// In zh, this message translates to:
  /// **'测试信用卡支付'**
  String get payment_test_credit_card;

  /// No description provided for @payment_recent_test_result.
  ///
  /// In zh, this message translates to:
  /// **'最近测试结果'**
  String get payment_recent_test_result;

  /// No description provided for @payment_no_test_result.
  ///
  /// In zh, this message translates to:
  /// **'暂无测试结果'**
  String get payment_no_test_result;

  /// No description provided for @payment_available.
  ///
  /// In zh, this message translates to:
  /// **'可用'**
  String get payment_available;

  /// No description provided for @payment_unavailable.
  ///
  /// In zh, this message translates to:
  /// **'不可用'**
  String get payment_unavailable;

  /// No description provided for @payment_method_label.
  ///
  /// In zh, this message translates to:
  /// **'支付方式：{name}'**
  String payment_method_label(String name);

  /// No description provided for @payment_mock_mode.
  ///
  /// In zh, this message translates to:
  /// **'Mock模式'**
  String get payment_mock_mode;

  /// No description provided for @payment_error_label.
  ///
  /// In zh, this message translates to:
  /// **'错误: {error}'**
  String payment_error_label(String error);

  /// No description provided for @payment_nav_network_failed.
  ///
  /// In zh, this message translates to:
  /// **'网络连接失败'**
  String get payment_nav_network_failed;

  /// No description provided for @payment_nav_network_error_message.
  ///
  /// In zh, this message translates to:
  /// **'网络连接出错，请检查网络后重试'**
  String get payment_nav_network_error_message;

  /// No description provided for @payment_nav_view_orders.
  ///
  /// In zh, this message translates to:
  /// **'查看订单'**
  String get payment_nav_view_orders;

  /// No description provided for @payment_nav_retry_payment.
  ///
  /// In zh, this message translates to:
  /// **'重试支付'**
  String get payment_nav_retry_payment;

  /// No description provided for @payment_nav_result_unknown_title.
  ///
  /// In zh, this message translates to:
  /// **'支付结果未知'**
  String get payment_nav_result_unknown_title;

  /// No description provided for @payment_nav_result_unknown_message.
  ///
  /// In zh, this message translates to:
  /// **'支付结果暂时无法确认，请稍后查看订单状态或联系客服'**
  String get payment_nav_result_unknown_message;

  /// No description provided for @payment_nav_query_status.
  ///
  /// In zh, this message translates to:
  /// **'查询状态'**
  String get payment_nav_query_status;

  /// No description provided for @payment_nav_cancel_continue.
  ///
  /// In zh, this message translates to:
  /// **'您已取消支付，可以继续完成订单支付'**
  String get payment_nav_cancel_continue;

  /// No description provided for @payment_nav_processing.
  ///
  /// In zh, this message translates to:
  /// **'支付正在处理中，请稍后查看订单状态'**
  String get payment_nav_processing;

  /// No description provided for @payment_nav_success.
  ///
  /// In zh, this message translates to:
  /// **'支付成功'**
  String get payment_nav_success;

  /// No description provided for @payment_nav_failed.
  ///
  /// In zh, this message translates to:
  /// **'支付失败'**
  String get payment_nav_failed;

  /// No description provided for @payment_nav_retrying.
  ///
  /// In zh, this message translates to:
  /// **'正在重新发起支付...'**
  String get payment_nav_retrying;

  /// No description provided for @payment_nav_retry_failed.
  ///
  /// In zh, this message translates to:
  /// **'无法重试支付，订单信息丢失'**
  String get payment_nav_retry_failed;

  /// No description provided for @payment_nav_querying.
  ///
  /// In zh, this message translates to:
  /// **'正在查询支付状态...'**
  String get payment_nav_querying;

  /// No description provided for @payment_nav_query_failed.
  ///
  /// In zh, this message translates to:
  /// **'无法查询状态，订单信息丢失'**
  String get payment_nav_query_failed;

  /// No description provided for @payment_test_description.
  ///
  /// In zh, this message translates to:
  /// **'{subject} - 支付测试'**
  String payment_test_description(String subject);

  /// No description provided for @chat_translating.
  ///
  /// In zh, this message translates to:
  /// **'翻译中...'**
  String get chat_translating;

  /// No description provided for @chat_translation_label.
  ///
  /// In zh, this message translates to:
  /// **'译文'**
  String get chat_translation_label;

  /// No description provided for @after_sales_info_evidence.
  ///
  /// In zh, this message translates to:
  /// **'申请凭证'**
  String get after_sales_info_evidence;

  /// No description provided for @agentScopeServicesRead.
  ///
  /// In zh, this message translates to:
  /// **'搜索和查看服务'**
  String get agentScopeServicesRead;

  /// No description provided for @agentScopeRequestsRead.
  ///
  /// In zh, this message translates to:
  /// **'查看我的需求及状态'**
  String get agentScopeRequestsRead;

  /// No description provided for @agentScopeRequestsCreate.
  ///
  /// In zh, this message translates to:
  /// **'创建待 App 审核的需求草稿'**
  String get agentScopeRequestsCreate;

  /// No description provided for @agentStatusActive.
  ///
  /// In zh, this message translates to:
  /// **'已连接'**
  String get agentStatusActive;

  /// No description provided for @agentStatusRevoked.
  ///
  /// In zh, this message translates to:
  /// **'已撤销'**
  String get agentStatusRevoked;

  /// No description provided for @agentStatusExpired.
  ///
  /// In zh, this message translates to:
  /// **'已过期'**
  String get agentStatusExpired;

  /// No description provided for @agentStatusAwaitingReview.
  ///
  /// In zh, this message translates to:
  /// **'等待 App 审核'**
  String get agentStatusAwaitingReview;

  /// No description provided for @agentStatusApproved.
  ///
  /// In zh, this message translates to:
  /// **'已批准'**
  String get agentStatusApproved;

  /// No description provided for @agentStatusSubmitted.
  ///
  /// In zh, this message translates to:
  /// **'已提交给服务方'**
  String get agentStatusSubmitted;

  /// No description provided for @agentStatusProviderResponded.
  ///
  /// In zh, this message translates to:
  /// **'服务方已回复'**
  String get agentStatusProviderResponded;

  /// No description provided for @agentStatusAbandoned.
  ///
  /// In zh, this message translates to:
  /// **'已放弃'**
  String get agentStatusAbandoned;

  /// No description provided for @agentConnectTitle.
  ///
  /// In zh, this message translates to:
  /// **'连接 Agent'**
  String get agentConnectTitle;

  /// No description provided for @agentConnectDescription.
  ///
  /// In zh, this message translates to:
  /// **'确认正在连接的设备和权限。只有你在此允许后，CLI 才能访问 DeepStream。'**
  String get agentConnectDescription;

  /// No description provided for @agentInvalidCode.
  ///
  /// In zh, this message translates to:
  /// **'请输入 8 位用户码'**
  String get agentInvalidCode;

  /// No description provided for @agentUserCode.
  ///
  /// In zh, this message translates to:
  /// **'用户码'**
  String get agentUserCode;

  /// No description provided for @agentCheckRequest.
  ///
  /// In zh, this message translates to:
  /// **'查看连接申请'**
  String get agentCheckRequest;

  /// No description provided for @agentChoosePermission.
  ///
  /// In zh, this message translates to:
  /// **'请至少保留一项权限；若不信任该设备，请拒绝连接。'**
  String get agentChoosePermission;

  /// No description provided for @agentAuthorizationApproved.
  ///
  /// In zh, this message translates to:
  /// **'已允许连接，可以返回 CLI。'**
  String get agentAuthorizationApproved;

  /// No description provided for @agentAuthorizationDenied.
  ///
  /// In zh, this message translates to:
  /// **'已拒绝本次连接。'**
  String get agentAuthorizationDenied;

  /// No description provided for @agentUnknownPlatform.
  ///
  /// In zh, this message translates to:
  /// **'未知设备'**
  String get agentUnknownPlatform;

  /// No description provided for @agentRequestedPermissions.
  ///
  /// In zh, this message translates to:
  /// **'申请的权限'**
  String get agentRequestedPermissions;

  /// No description provided for @agentNeverIncludes.
  ///
  /// In zh, this message translates to:
  /// **'不包含：密码、验证码、付款、钱包、自动下单和无关本地文件。'**
  String get agentNeverIncludes;

  /// No description provided for @agentDeny.
  ///
  /// In zh, this message translates to:
  /// **'拒绝'**
  String get agentDeny;

  /// No description provided for @agentAllow.
  ///
  /// In zh, this message translates to:
  /// **'允许接入'**
  String get agentAllow;

  /// No description provided for @agentAndCliTitle.
  ///
  /// In zh, this message translates to:
  /// **'Agent 与 CLI'**
  String get agentAndCliTitle;

  /// No description provided for @agentConnectedAgents.
  ///
  /// In zh, this message translates to:
  /// **'已连接的 Agent'**
  String get agentConnectedAgents;

  /// No description provided for @agentRevokeAll.
  ///
  /// In zh, this message translates to:
  /// **'全部撤销'**
  String get agentRevokeAll;

  /// No description provided for @agentRevokeAllConfirmation.
  ///
  /// In zh, this message translates to:
  /// **'所有 Agent 将立即退出，需要重新授权才能使用。历史需求、聊天和订单不会删除。'**
  String get agentRevokeAllConfirmation;

  /// No description provided for @agentRevoke.
  ///
  /// In zh, this message translates to:
  /// **'撤销'**
  String get agentRevoke;

  /// No description provided for @agentNoConnectedAgents.
  ///
  /// In zh, this message translates to:
  /// **'暂无已连接的 Agent'**
  String get agentNoConnectedAgents;

  /// No description provided for @agentNoConnectedAgentsHint.
  ///
  /// In zh, this message translates to:
  /// **'在电脑上运行 ds auth login，即可发起安全连接。'**
  String get agentNoConnectedAgentsHint;

  /// No description provided for @agentRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get agentRetry;

  /// No description provided for @agentNoPaymentNotice.
  ///
  /// In zh, this message translates to:
  /// **'Agent 不能付款、操作钱包或自动下单。需求草稿仍需你在 App 中审核。'**
  String get agentNoPaymentNotice;

  /// No description provided for @agentLastUsed.
  ///
  /// In zh, this message translates to:
  /// **'最后使用：{time}'**
  String agentLastUsed(String time);

  /// No description provided for @agentDetails.
  ///
  /// In zh, this message translates to:
  /// **'Agent 详情'**
  String get agentDetails;

  /// No description provided for @agentSessionId.
  ///
  /// In zh, this message translates to:
  /// **'Session 标识'**
  String get agentSessionId;

  /// No description provided for @agentStatus.
  ///
  /// In zh, this message translates to:
  /// **'状态'**
  String get agentStatus;

  /// No description provided for @agentConnectedAt.
  ///
  /// In zh, this message translates to:
  /// **'接入时间'**
  String get agentConnectedAt;

  /// No description provided for @agentLastUsedLabel.
  ///
  /// In zh, this message translates to:
  /// **'最后使用'**
  String get agentLastUsedLabel;

  /// No description provided for @agentPermissions.
  ///
  /// In zh, this message translates to:
  /// **'权限'**
  String get agentPermissions;

  /// No description provided for @agentAtLeastOnePermission.
  ///
  /// In zh, this message translates to:
  /// **'至少保留一项权限；如需全部移除，请撤销此 Agent。'**
  String get agentAtLeastOnePermission;

  /// No description provided for @agentSavePermissions.
  ///
  /// In zh, this message translates to:
  /// **'保存权限'**
  String get agentSavePermissions;

  /// No description provided for @agentCannotAddPermissions.
  ///
  /// In zh, this message translates to:
  /// **'这里只能移除已有权限。增加权限需要重新授权。'**
  String get agentCannotAddPermissions;

  /// No description provided for @agentRecentSecurityEvents.
  ///
  /// In zh, this message translates to:
  /// **'最近安全操作'**
  String get agentRecentSecurityEvents;

  /// No description provided for @agentRevokeAgent.
  ///
  /// In zh, this message translates to:
  /// **'撤销此 Agent'**
  String get agentRevokeAgent;

  /// No description provided for @agentRevokeConfirmation.
  ///
  /// In zh, this message translates to:
  /// **'该设备将立即退出 DeepStream，但不会删除历史记录。重新使用需要再次授权。'**
  String get agentRevokeConfirmation;

  /// No description provided for @agentRequestDrafts.
  ///
  /// In zh, this message translates to:
  /// **'Agent 需求草稿'**
  String get agentRequestDrafts;

  /// No description provided for @agentOpenChat.
  ///
  /// In zh, this message translates to:
  /// **'进入咨询会话'**
  String get agentOpenChat;

  /// No description provided for @agentNoRequestDrafts.
  ///
  /// In zh, this message translates to:
  /// **'暂无 Agent 创建的需求草稿'**
  String get agentNoRequestDrafts;

  /// No description provided for @agentReviewRequest.
  ///
  /// In zh, this message translates to:
  /// **'审核需求草稿'**
  String get agentReviewRequest;

  /// No description provided for @agentRequestBrief.
  ///
  /// In zh, this message translates to:
  /// **'需求说明'**
  String get agentRequestBrief;

  /// No description provided for @agentServiceId.
  ///
  /// In zh, this message translates to:
  /// **'服务 ID'**
  String get agentServiceId;

  /// No description provided for @agentCreatedAt.
  ///
  /// In zh, this message translates to:
  /// **'创建时间'**
  String get agentCreatedAt;

  /// No description provided for @agentSubmittedAt.
  ///
  /// In zh, this message translates to:
  /// **'提交时间'**
  String get agentSubmittedAt;

  /// No description provided for @agentProviderRespondedAt.
  ///
  /// In zh, this message translates to:
  /// **'服务方回复时间'**
  String get agentProviderRespondedAt;

  /// No description provided for @agentChatId.
  ///
  /// In zh, this message translates to:
  /// **'咨询会话 ID'**
  String get agentChatId;

  /// No description provided for @agentReviewSafetyNotice.
  ///
  /// In zh, this message translates to:
  /// **'提交后会建立咨询会话并把需求发送给服务方；不会付款或自动生成订单。后续价格与交易仍需单独确认。'**
  String get agentReviewSafetyNotice;

  /// No description provided for @agentApproveRequest.
  ///
  /// In zh, this message translates to:
  /// **'提交给服务方'**
  String get agentApproveRequest;

  /// No description provided for @agentAbandonRequest.
  ///
  /// In zh, this message translates to:
  /// **'放弃草稿'**
  String get agentAbandonRequest;

  /// No description provided for @agentApproveRequestConfirmation.
  ///
  /// In zh, this message translates to:
  /// **'确认将这份需求发送给服务方并建立咨询会话？本操作不会付款或下单。'**
  String get agentApproveRequestConfirmation;

  /// No description provided for @agentAbandonRequestConfirmation.
  ///
  /// In zh, this message translates to:
  /// **'确认放弃这份需求草稿？'**
  String get agentAbandonRequestConfirmation;

  /// No description provided for @agentApprove.
  ///
  /// In zh, this message translates to:
  /// **'确认提交'**
  String get agentApprove;

  /// No description provided for @agentAbandon.
  ///
  /// In zh, this message translates to:
  /// **'放弃'**
  String get agentAbandon;

  /// No description provided for @agentManageConnectedAgents.
  ///
  /// In zh, this message translates to:
  /// **'管理已连接的 Agent'**
  String get agentManageConnectedAgents;

  /// No description provided for @agentErrorInvalidCode.
  ///
  /// In zh, this message translates to:
  /// **'连接码无效，请检查后重试。'**
  String get agentErrorInvalidCode;

  /// No description provided for @agentErrorExpired.
  ///
  /// In zh, this message translates to:
  /// **'连接申请已过期，请回到 CLI 重新发起登录。'**
  String get agentErrorExpired;

  /// No description provided for @agentErrorAlreadyUsed.
  ///
  /// In zh, this message translates to:
  /// **'连接申请已使用或已取消。'**
  String get agentErrorAlreadyUsed;

  /// No description provided for @agentErrorDenied.
  ///
  /// In zh, this message translates to:
  /// **'连接申请已被拒绝。'**
  String get agentErrorDenied;

  /// No description provided for @agentErrorRateLimited.
  ///
  /// In zh, this message translates to:
  /// **'尝试次数过多，请稍后再试。'**
  String get agentErrorRateLimited;

  /// No description provided for @agentErrorNotFound.
  ///
  /// In zh, this message translates to:
  /// **'这条 Agent 记录已不存在。'**
  String get agentErrorNotFound;

  /// No description provided for @agentErrorGeneric.
  ///
  /// In zh, this message translates to:
  /// **'暂时无法完成 Agent 操作，请检查网络后重试。'**
  String get agentErrorGeneric;

  /// No description provided for @agentAuthorizationAlreadyApproved.
  ///
  /// In zh, this message translates to:
  /// **'该连接已批准，请返回 CLI。'**
  String get agentAuthorizationAlreadyApproved;

  /// No description provided for @agentAuthorizationAlreadyDenied.
  ///
  /// In zh, this message translates to:
  /// **'该连接已被拒绝。'**
  String get agentAuthorizationAlreadyDenied;

  /// No description provided for @agentAuthorizationAlreadyUsed.
  ///
  /// In zh, this message translates to:
  /// **'该连接码已使用。'**
  String get agentAuthorizationAlreadyUsed;

  /// No description provided for @agentAuthorizationUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'该连接申请已不可用。'**
  String get agentAuthorizationUnavailable;

  /// No description provided for @agentAuditConnected.
  ///
  /// In zh, this message translates to:
  /// **'Agent 已连接'**
  String get agentAuditConnected;

  /// No description provided for @agentAuditRefreshed.
  ///
  /// In zh, this message translates to:
  /// **'会话已刷新'**
  String get agentAuditRefreshed;

  /// No description provided for @agentAuditReplayBlocked.
  ///
  /// In zh, this message translates to:
  /// **'已拦截可疑令牌重用'**
  String get agentAuditReplayBlocked;

  /// No description provided for @agentAuditPermissionsReduced.
  ///
  /// In zh, this message translates to:
  /// **'权限已收窄'**
  String get agentAuditPermissionsReduced;

  /// No description provided for @agentAuditRevoked.
  ///
  /// In zh, this message translates to:
  /// **'Agent 已撤销'**
  String get agentAuditRevoked;

  /// No description provided for @agentAuditSecurityEvent.
  ///
  /// In zh, this message translates to:
  /// **'安全事件'**
  String get agentAuditSecurityEvent;

  /// No description provided for @agentAuditSuccess.
  ///
  /// In zh, this message translates to:
  /// **'成功'**
  String get agentAuditSuccess;

  /// No description provided for @agentAuditRecorded.
  ///
  /// In zh, this message translates to:
  /// **'已记录'**
  String get agentAuditRecorded;

  /// No description provided for @agentClientType.
  ///
  /// In zh, this message translates to:
  /// **'客户端类型'**
  String get agentClientType;

  /// No description provided for @agentClientId.
  ///
  /// In zh, this message translates to:
  /// **'客户端标识'**
  String get agentClientId;

  /// No description provided for @agentAccessExpiresAt.
  ///
  /// In zh, this message translates to:
  /// **'访问权限到期'**
  String get agentAccessExpiresAt;

  /// No description provided for @agentAuthorizationExpiresAt.
  ///
  /// In zh, this message translates to:
  /// **'授权到期'**
  String get agentAuthorizationExpiresAt;

  /// No description provided for @agentAuthorizationRequestExpiresAt.
  ///
  /// In zh, this message translates to:
  /// **'连接申请到期'**
  String get agentAuthorizationRequestExpiresAt;

  /// No description provided for @agentClientMetadataNotice.
  ///
  /// In zh, this message translates to:
  /// **'以上客户端、设备、系统和版本信息由连接程序自行声明。请核对设备，并仅从 DeepStream 官方域名安装 CLI。'**
  String get agentClientMetadataNotice;

  /// No description provided for @agentAuditAuthorizationRequested.
  ///
  /// In zh, this message translates to:
  /// **'已发起连接申请'**
  String get agentAuditAuthorizationRequested;

  /// No description provided for @agentAuditAuthorizationApproved.
  ///
  /// In zh, this message translates to:
  /// **'已批准连接'**
  String get agentAuditAuthorizationApproved;

  /// No description provided for @agentAuditAuthorizationDenied.
  ///
  /// In zh, this message translates to:
  /// **'已拒绝连接'**
  String get agentAuditAuthorizationDenied;

  /// No description provided for @agentAuditAllRevoked.
  ///
  /// In zh, this message translates to:
  /// **'已撤销全部 Agent'**
  String get agentAuditAllRevoked;

  /// No description provided for @agentAuditRequestCreated.
  ///
  /// In zh, this message translates to:
  /// **'已创建需求草稿'**
  String get agentAuditRequestCreated;

  /// No description provided for @agentAuditRequestApproved.
  ///
  /// In zh, this message translates to:
  /// **'已批准需求草稿'**
  String get agentAuditRequestApproved;

  /// No description provided for @agentAuditRequestAbandoned.
  ///
  /// In zh, this message translates to:
  /// **'已放弃需求草稿'**
  String get agentAuditRequestAbandoned;

  /// No description provided for @agentViewTaskStatus.
  ///
  /// In zh, this message translates to:
  /// **'查看任务状态'**
  String get agentViewTaskStatus;

  /// No description provided for @dsnTaskStatusTitle.
  ///
  /// In zh, this message translates to:
  /// **'任务状态'**
  String get dsnTaskStatusTitle;

  /// No description provided for @dsnTaskIdentity.
  ///
  /// In zh, this message translates to:
  /// **'任务标识'**
  String get dsnTaskIdentity;

  /// No description provided for @dsnTaskTraceId.
  ///
  /// In zh, this message translates to:
  /// **'任务追踪 ID'**
  String get dsnTaskTraceId;

  /// No description provided for @dsnTaskOperationTraceId.
  ///
  /// In zh, this message translates to:
  /// **'操作追踪 ID'**
  String get dsnTaskOperationTraceId;

  /// No description provided for @dsnTaskAxes.
  ///
  /// In zh, this message translates to:
  /// **'交互状态'**
  String get dsnTaskAxes;

  /// No description provided for @dsnTaskLifecycle.
  ///
  /// In zh, this message translates to:
  /// **'任务生命周期'**
  String get dsnTaskLifecycle;

  /// No description provided for @dsnTaskResponsibility.
  ///
  /// In zh, this message translates to:
  /// **'责任动作'**
  String get dsnTaskResponsibility;

  /// No description provided for @dsnTaskSyncStatus.
  ///
  /// In zh, this message translates to:
  /// **'同步状态'**
  String get dsnTaskSyncStatus;

  /// No description provided for @dsnTaskWaitingOn.
  ///
  /// In zh, this message translates to:
  /// **'等待对象'**
  String get dsnTaskWaitingOn;

  /// No description provided for @dsnTaskPrimaryAction.
  ///
  /// In zh, this message translates to:
  /// **'主操作'**
  String get dsnTaskPrimaryAction;

  /// No description provided for @dsnTaskRefreshProjection.
  ///
  /// In zh, this message translates to:
  /// **'刷新状态'**
  String get dsnTaskRefreshProjection;

  /// No description provided for @dsnTaskReceipt.
  ///
  /// In zh, this message translates to:
  /// **'回执'**
  String get dsnTaskReceipt;

  /// No description provided for @dsnTaskNoReceipt.
  ///
  /// In zh, this message translates to:
  /// **'当前暂无回执。'**
  String get dsnTaskNoReceipt;

  /// No description provided for @dsnTaskLoadReceipt.
  ///
  /// In zh, this message translates to:
  /// **'加载回执'**
  String get dsnTaskLoadReceipt;

  /// No description provided for @dsnTaskRefreshReceipt.
  ///
  /// In zh, this message translates to:
  /// **'刷新回执'**
  String get dsnTaskRefreshReceipt;

  /// No description provided for @dsnTaskReceiptState.
  ///
  /// In zh, this message translates to:
  /// **'回执状态'**
  String get dsnTaskReceiptState;

  /// No description provided for @dsnTaskReceiptOrder.
  ///
  /// In zh, this message translates to:
  /// **'订单 ID'**
  String get dsnTaskReceiptOrder;

  /// No description provided for @dsnTaskReceiptDeliveries.
  ///
  /// In zh, this message translates to:
  /// **'交付数量'**
  String get dsnTaskReceiptDeliveries;

  /// No description provided for @dsnTaskReceiptGeneratedAt.
  ///
  /// In zh, this message translates to:
  /// **'生成时间'**
  String get dsnTaskReceiptGeneratedAt;

  /// No description provided for @dsnTaskReceiptSource.
  ///
  /// In zh, this message translates to:
  /// **'回执来源'**
  String get dsnTaskReceiptSource;

  /// No description provided for @dsnTaskLegacyFallback.
  ///
  /// In zh, this message translates to:
  /// **'当前使用旧版事实回退；追加式回执尚不可用。'**
  String get dsnTaskLegacyFallback;

  /// No description provided for @dsnTaskActionRecoverOperation.
  ///
  /// In zh, this message translates to:
  /// **'恢复原操作状态'**
  String get dsnTaskActionRecoverOperation;

  /// No description provided for @dsnTaskActionRecoverTask.
  ///
  /// In zh, this message translates to:
  /// **'恢复任务状态'**
  String get dsnTaskActionRecoverTask;

  /// No description provided for @dsnTaskActionReviewResponsibility.
  ///
  /// In zh, this message translates to:
  /// **'查看待确认责任'**
  String get dsnTaskActionReviewResponsibility;

  /// No description provided for @dsnTaskActionRecoveryInProgress.
  ///
  /// In zh, this message translates to:
  /// **'恢复处理中'**
  String get dsnTaskActionRecoveryInProgress;

  /// No description provided for @dsnTaskActionViewProgress.
  ///
  /// In zh, this message translates to:
  /// **'查看进度'**
  String get dsnTaskActionViewProgress;

  /// No description provided for @dsnTaskActionViewSystemStatus.
  ///
  /// In zh, this message translates to:
  /// **'查看系统状态'**
  String get dsnTaskActionViewSystemStatus;

  /// No description provided for @dsnTaskActionViewRecord.
  ///
  /// In zh, this message translates to:
  /// **'查看记录'**
  String get dsnTaskActionViewRecord;

  /// No description provided for @dsnTaskActionDomain.
  ///
  /// In zh, this message translates to:
  /// **'查看下一步'**
  String get dsnTaskActionDomain;

  /// No description provided for @dsnTaskActionUnknown.
  ///
  /// In zh, this message translates to:
  /// **'需要进一步确认'**
  String get dsnTaskActionUnknown;

  /// No description provided for @credit_wallet_available.
  ///
  /// In zh, this message translates to:
  /// **'可用积分'**
  String get credit_wallet_available;

  /// No description provided for @credit_wallet_usage_notice.
  ///
  /// In zh, this message translates to:
  /// **'积分可用于购买 DeepStream 内的商品和服务，目前不可提现或转赠。'**
  String get credit_wallet_usage_notice;

  /// No description provided for @credit_purchase_title.
  ///
  /// In zh, this message translates to:
  /// **'购买积分'**
  String get credit_purchase_title;

  /// No description provided for @credit_purchase_subtitle.
  ///
  /// In zh, this message translates to:
  /// **'选择积分包，付款由应用商店处理。'**
  String get credit_purchase_subtitle;

  /// No description provided for @credit_purchase_unavailable.
  ///
  /// In zh, this message translates to:
  /// **'暂时无法购买积分。'**
  String get credit_purchase_unavailable;

  /// No description provided for @credit_purchase_reload.
  ///
  /// In zh, this message translates to:
  /// **'重新加载'**
  String get credit_purchase_reload;

  /// No description provided for @credit_purchase_credits.
  ///
  /// In zh, this message translates to:
  /// **'{credits} 积分'**
  String credit_purchase_credits(int credits);

  /// No description provided for @credit_purchase_checking.
  ///
  /// In zh, this message translates to:
  /// **'核对中…'**
  String get credit_purchase_checking;

  /// No description provided for @credit_purchase_check.
  ///
  /// In zh, this message translates to:
  /// **'检查状态'**
  String get credit_purchase_check;

  /// No description provided for @credit_purchase_check_arrival.
  ///
  /// In zh, this message translates to:
  /// **'检查到账'**
  String get credit_purchase_check_arrival;

  /// No description provided for @credit_purchase_disclaimer.
  ///
  /// In zh, this message translates to:
  /// **'积分仅限在 DeepStream 内使用，不可提现、转赠或兑换现金；付款和退款由应用商店处理。'**
  String get credit_purchase_disclaimer;

  /// No description provided for @credit_amount_positive.
  ///
  /// In zh, this message translates to:
  /// **'+{credits} 积分'**
  String credit_amount_positive(int credits);

  /// No description provided for @credit_amount_negative.
  ///
  /// In zh, this message translates to:
  /// **'-{credits} 积分'**
  String credit_amount_negative(int credits);

  /// No description provided for @credit_purchase_status_pending_detected.
  ///
  /// In zh, this message translates to:
  /// **'发现一笔待核对的购买，正在检查到账状态。'**
  String get credit_purchase_status_pending_detected;

  /// No description provided for @credit_purchase_status_server_pending.
  ///
  /// In zh, this message translates to:
  /// **'服务器仍在处理上一笔购买，请稍后再检查。'**
  String get credit_purchase_status_server_pending;

  /// No description provided for @credit_purchase_status_no_products.
  ///
  /// In zh, this message translates to:
  /// **'当前没有可购买的积分包。'**
  String get credit_purchase_status_no_products;

  /// No description provided for @credit_purchase_status_load_failed.
  ///
  /// In zh, this message translates to:
  /// **'积分包加载失败，请稍后重试。'**
  String get credit_purchase_status_load_failed;

  /// No description provided for @credit_purchase_status_balance_preflight_failed.
  ///
  /// In zh, this message translates to:
  /// **'无法获取最新积分余额，本次购买未发起。'**
  String get credit_purchase_status_balance_preflight_failed;

  /// No description provided for @credit_purchase_status_cancelled.
  ///
  /// In zh, this message translates to:
  /// **'购买已取消。'**
  String get credit_purchase_status_cancelled;

  /// No description provided for @credit_purchase_status_store_pending.
  ///
  /// In zh, this message translates to:
  /// **'应用商店正在处理付款，请勿重复购买。'**
  String get credit_purchase_status_store_pending;

  /// No description provided for @credit_purchase_status_submitted.
  ///
  /// In zh, this message translates to:
  /// **'付款已提交，正在核对积分到账。'**
  String get credit_purchase_status_submitted;

  /// No description provided for @credit_purchase_status_network_ambiguous.
  ///
  /// In zh, this message translates to:
  /// **'网络中断，购买结果暂未确认，请勿重复购买。'**
  String get credit_purchase_status_network_ambiguous;

  /// No description provided for @credit_purchase_status_store_ambiguous.
  ///
  /// In zh, this message translates to:
  /// **'应用商店返回的结果不明确，正在核对，请勿重复购买。'**
  String get credit_purchase_status_store_ambiguous;

  /// No description provided for @credit_purchase_status_failed.
  ///
  /// In zh, this message translates to:
  /// **'购买未完成，请稍后重试。'**
  String get credit_purchase_status_failed;

  /// No description provided for @credit_purchase_status_unsafe_reconciliation.
  ///
  /// In zh, this message translates to:
  /// **'无法安全核对上一笔购买，请勿重复购买并联系客服处理。'**
  String get credit_purchase_status_unsafe_reconciliation;

  /// No description provided for @credit_purchase_status_checking_again.
  ///
  /// In zh, this message translates to:
  /// **'正在重新核对购买状态。'**
  String get credit_purchase_status_checking_again;

  /// No description provided for @credit_purchase_status_balance_updated_guarded.
  ///
  /// In zh, this message translates to:
  /// **'积分余额已更新，但设备上的购买核对记录尚未安全清除，请稍后再检查。'**
  String get credit_purchase_status_balance_updated_guarded;

  /// No description provided for @credit_purchase_status_confirmed.
  ///
  /// In zh, this message translates to:
  /// **'积分已到账。'**
  String get credit_purchase_status_confirmed;

  /// No description provided for @credit_purchase_status_reversed.
  ///
  /// In zh, this message translates to:
  /// **'该笔购买已撤销或退款，积分未到账。'**
  String get credit_purchase_status_reversed;

  /// No description provided for @credit_purchase_status_delayed.
  ///
  /// In zh, this message translates to:
  /// **'付款记录仍在核对中，请勿重复购买；若长期未到账或应用商店未扣款，请联系客服核对。'**
  String get credit_purchase_status_delayed;

  /// No description provided for @agentMandates.
  ///
  /// In zh, this message translates to:
  /// **'Agent 预授权'**
  String get agentMandates;

  /// No description provided for @agentMandatesHint.
  ///
  /// In zh, this message translates to:
  /// **'预授权是你在本 App 内审核的固定、有限授权；它不会共享你的登录凭证或 Agent 凭证。'**
  String get agentMandatesHint;

  /// No description provided for @agentCreateMandate.
  ///
  /// In zh, this message translates to:
  /// **'创建预授权'**
  String get agentCreateMandate;

  /// No description provided for @agentMandateNoItems.
  ///
  /// In zh, this message translates to:
  /// **'暂无预授权'**
  String get agentMandateNoItems;

  /// No description provided for @agentMandateNoAgents.
  ///
  /// In zh, this message translates to:
  /// **'请先连接一个活跃的 Agent，再创建预授权。'**
  String get agentMandateNoAgents;

  /// No description provided for @agentMandateTemplate.
  ///
  /// In zh, this message translates to:
  /// **'固定模板'**
  String get agentMandateTemplate;

  /// No description provided for @agentMandateAgent.
  ///
  /// In zh, this message translates to:
  /// **'已连接的 Agent'**
  String get agentMandateAgent;

  /// No description provided for @agentMandateResource.
  ///
  /// In zh, this message translates to:
  /// **'服务端资源引用'**
  String get agentMandateResource;

  /// No description provided for @agentMandateResourceHint.
  ///
  /// In zh, this message translates to:
  /// **'使用 DeepStream 提供的请求、已接受报价或 Commitment 引用。'**
  String get agentMandateResourceHint;

  /// No description provided for @agentMandateResourceVersion.
  ///
  /// In zh, this message translates to:
  /// **'预期资源版本（可选）'**
  String get agentMandateResourceVersion;

  /// No description provided for @agentMandateSpecHash.
  ///
  /// In zh, this message translates to:
  /// **'预期规格哈希（可选）'**
  String get agentMandateSpecHash;

  /// No description provided for @agentMandateQuoteHash.
  ///
  /// In zh, this message translates to:
  /// **'预期报价哈希（可选）'**
  String get agentMandateQuoteHash;

  /// No description provided for @agentMandatePreview.
  ///
  /// In zh, this message translates to:
  /// **'审核固定授权'**
  String get agentMandatePreview;

  /// No description provided for @agentMandateReviewTitle.
  ///
  /// In zh, this message translates to:
  /// **'审核预授权'**
  String get agentMandateReviewTitle;

  /// No description provided for @agentMandateConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认预授权'**
  String get agentMandateConfirm;

  /// No description provided for @agentMandateConfirmMessage.
  ///
  /// In zh, this message translates to:
  /// **'确认后将为展示的 Agent 和服务端资源创建有限授权。Agent 无法自行扩大该授权。'**
  String get agentMandateConfirmMessage;

  /// No description provided for @agentMandateExpiresAt.
  ///
  /// In zh, this message translates to:
  /// **'审核过期时间'**
  String get agentMandateExpiresAt;

  /// No description provided for @agentMandateAllowedActions.
  ///
  /// In zh, this message translates to:
  /// **'允许动作'**
  String get agentMandateAllowedActions;

  /// No description provided for @agentMandateStatus.
  ///
  /// In zh, this message translates to:
  /// **'状态'**
  String get agentMandateStatus;

  /// No description provided for @agentMandateVersion.
  ///
  /// In zh, this message translates to:
  /// **'预授权版本'**
  String get agentMandateVersion;

  /// No description provided for @agentMandateHash.
  ///
  /// In zh, this message translates to:
  /// **'预授权哈希'**
  String get agentMandateHash;

  /// No description provided for @agentMandateRevokedAt.
  ///
  /// In zh, this message translates to:
  /// **'撤销时间'**
  String get agentMandateRevokedAt;

  /// No description provided for @agentMandateRevoke.
  ///
  /// In zh, this message translates to:
  /// **'撤销预授权'**
  String get agentMandateRevoke;

  /// No description provided for @agentMandateRevokeConfirm.
  ///
  /// In zh, this message translates to:
  /// **'现在撤销此授权？新的 Agent 操作将被阻断，历史事实仍会保留。'**
  String get agentMandateRevokeConfirm;

  /// No description provided for @agentMandateBuyerTemplate.
  ///
  /// In zh, this message translates to:
  /// **'买方固定承诺'**
  String get agentMandateBuyerTemplate;

  /// No description provided for @agentMandateProviderTaskTemplate.
  ///
  /// In zh, this message translates to:
  /// **'服务方固定任务'**
  String get agentMandateProviderTaskTemplate;

  /// No description provided for @agentMandateActionBuyerCommitment.
  ///
  /// In zh, this message translates to:
  /// **'确认固定承诺'**
  String get agentMandateActionBuyerCommitment;

  /// No description provided for @agentMandateActionProviderOffer.
  ///
  /// In zh, this message translates to:
  /// **'提交固定报价'**
  String get agentMandateActionProviderOffer;

  /// No description provided for @agentMandateActionProviderAccept.
  ///
  /// In zh, this message translates to:
  /// **'接受固定请求'**
  String get agentMandateActionProviderAccept;

  /// No description provided for @agentMandateActionProviderDelivery.
  ///
  /// In zh, this message translates to:
  /// **'在 Commitment 存在后提交交付'**
  String get agentMandateActionProviderDelivery;
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
