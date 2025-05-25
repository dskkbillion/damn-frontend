// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
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
  String get localeName => 'zh';

  static String m0(error) => "选择图片出错: ${error}";

  static String m1(error) => "加载推荐服务失败: ${error}";

  static String m2(error) => "开始录音出错: ${error}";

  static String m3(error) => "停止录音出错: ${error}";

  static String m4(error) => "加载失败: ${error}";

  static String m5(error) => "选择图片出错: ${error}";

  static String m6(error) => "无法开始录音: ${error}";

  static String m7(duration) => "松开 发送 (${duration}s)";

  static String m8(error) => "停止录音失败: ${error}";

  static String m9(targetType, targetValue) =>
      "点击了轮播图: ${targetType} - ${targetValue}";

  static String m10(error) => "加载失败: ${error}";

  static String m11(name) => "点击了服务卡片: ${name}";

  static String m12(name) => "点击了\"让ta看看\"按钮: ${name}";

  static String m13(error) => "加载失败: ${error}";

  static String m14(error) => "无法导航到订单列表: ${error}";

  static String m15(error) => "无法切换到卖家模式: ${error}";

  static String m16(error) => "搜索失败: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "ai_docs_add_image": MessageLookupByLibrary.simpleMessage("添加图片"),
    "ai_docs_assistant_title": MessageLookupByLibrary.simpleMessage("AI 助手"),
    "ai_docs_cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "ai_docs_conversation_list": MessageLookupByLibrary.simpleMessage("会话列表"),
    "ai_docs_delete": MessageLookupByLibrary.simpleMessage("删除"),
    "ai_docs_delete_conversation_content": MessageLookupByLibrary.simpleMessage(
      "确定要永久删除此会话吗？",
    ),
    "ai_docs_delete_conversation_title": MessageLookupByLibrary.simpleMessage(
      "删除会话？",
    ),
    "ai_docs_delete_conversation_tooltip": MessageLookupByLibrary.simpleMessage(
      "删除会话",
    ),
    "ai_docs_dispatched": MessageLookupByLibrary.simpleMessage("已分发"),
    "ai_docs_enter_message": MessageLookupByLibrary.simpleMessage("输入消息..."),
    "ai_docs_image_picking_error": m0,
    "ai_docs_let_them_see": MessageLookupByLibrary.simpleMessage("让ta看看"),
    "ai_docs_load_conversations_failed": MessageLookupByLibrary.simpleMessage(
      "加载会话失败",
    ),
    "ai_docs_loading": MessageLookupByLibrary.simpleMessage("加载中..."),
    "ai_docs_match_button": MessageLookupByLibrary.simpleMessage("匹配"),
    "ai_docs_mic_permission_denied": MessageLookupByLibrary.simpleMessage(
      "麦克风权限被拒绝",
    ),
    "ai_docs_new_chat": MessageLookupByLibrary.simpleMessage("新建聊天"),
    "ai_docs_no_conversations": MessageLookupByLibrary.simpleMessage("暂无会话"),
    "ai_docs_no_messages": MessageLookupByLibrary.simpleMessage("暂无消息，开始聊天吧！"),
    "ai_docs_no_recommendations": MessageLookupByLibrary.simpleMessage(
      "暂无推荐服务",
    ),
    "ai_docs_please_enter_message": MessageLookupByLibrary.simpleMessage(
      "请输入消息内容",
    ),
    "ai_docs_please_select_conversation_to_delete":
        MessageLookupByLibrary.simpleMessage("请先选择要删除的会话"),
    "ai_docs_recommendations_error": m1,
    "ai_docs_recommended_services": MessageLookupByLibrary.simpleMessage(
      "推荐服务",
    ),
    "ai_docs_recording": MessageLookupByLibrary.simpleMessage("正在录音...点击停止发送"),
    "ai_docs_recording_error": m2,
    "ai_docs_recording_file_not_found": MessageLookupByLibrary.simpleMessage(
      "错误：未找到录音文件",
    ),
    "ai_docs_retry": MessageLookupByLibrary.simpleMessage("重试"),
    "ai_docs_select_conversation_first": MessageLookupByLibrary.simpleMessage(
      "请先选择一个会话",
    ),
    "ai_docs_send_message": MessageLookupByLibrary.simpleMessage("发送消息"),
    "ai_docs_start_recording": MessageLookupByLibrary.simpleMessage("录制语音"),
    "ai_docs_stop_generation": MessageLookupByLibrary.simpleMessage("停止生成"),
    "ai_docs_stop_recording": MessageLookupByLibrary.simpleMessage("停止录音"),
    "ai_docs_stop_recording_error": MessageLookupByLibrary.simpleMessage(
      "停止录音出错",
    ),
    "ai_docs_stop_recording_error_with_reason": m3,
    "ai_docs_unnamed_conversation": MessageLookupByLibrary.simpleMessage(
      "未命名会话",
    ),
    "ai_docs_uploading_images": MessageLookupByLibrary.simpleMessage(
      "图片正在上传中，请稍候...",
    ),
    "allocating_step1": MessageLookupByLibrary.simpleMessage("分发中"),
    "allocating_step2": MessageLookupByLibrary.simpleMessage("分发中."),
    "allocating_step3": MessageLookupByLibrary.simpleMessage("分发中.."),
    "allocating_step4": MessageLookupByLibrary.simpleMessage("分发中..."),
    "chat_admin_connection_error": MessageLookupByLibrary.simpleMessage(
      "无法连接到系统管理员",
    ),
    "chat_admin_title": MessageLookupByLibrary.simpleMessage("系统管理员"),
    "chat_attach": MessageLookupByLibrary.simpleMessage("发送图片/文件"),
    "chat_audio_message": MessageLookupByLibrary.simpleMessage("[语音]"),
    "chat_audio_pause": MessageLookupByLibrary.simpleMessage("暂停"),
    "chat_audio_play": MessageLookupByLibrary.simpleMessage("播放"),
    "chat_buyer": MessageLookupByLibrary.simpleMessage("买家"),
    "chat_camera_permission_denied": MessageLookupByLibrary.simpleMessage(
      "未获得相机权限，无法拍照",
    ),
    "chat_camera_permission_denied_message":
        MessageLookupByLibrary.simpleMessage("请在系统设置中手动开启相机权限才能使用拍照功能。"),
    "chat_camera_permission_denied_title": MessageLookupByLibrary.simpleMessage(
      "相机权限已被禁用",
    ),
    "chat_collapse": MessageLookupByLibrary.simpleMessage("收起"),
    "chat_copied_to_clipboard": MessageLookupByLibrary.simpleMessage("已复制到剪贴板"),
    "chat_copy": MessageLookupByLibrary.simpleMessage("复制"),
    "chat_enter_message": MessageLookupByLibrary.simpleMessage("输入消息..."),
    "chat_error_loading": m4,
    "chat_expand": MessageLookupByLibrary.simpleMessage("展开"),
    "chat_i_want_seller_to_see": MessageLookupByLibrary.simpleMessage(
      "我想让商家看看",
    ),
    "chat_image_message": MessageLookupByLibrary.simpleMessage("[图片]"),
    "chat_image_picking_error": m5,
    "chat_invalid_session": MessageLookupByLibrary.simpleMessage("无效的会话"),
    "chat_list_title": MessageLookupByLibrary.simpleMessage("聊天列表"),
    "chat_loading": MessageLookupByLibrary.simpleMessage("正在加载..."),
    "chat_markdown_example_bold_italic": MessageLookupByLibrary.simpleMessage(
      "这是**粗体**文本和*斜体*文本。",
    ),
    "chat_markdown_example_list1": MessageLookupByLibrary.simpleMessage(
      "这是列表项1",
    ),
    "chat_markdown_example_list2": MessageLookupByLibrary.simpleMessage(
      "这是列表项2",
    ),
    "chat_markdown_example_list3": MessageLookupByLibrary.simpleMessage(
      "这是嵌套列表项",
    ),
    "chat_markdown_example_quote": MessageLookupByLibrary.simpleMessage(
      "这是引用文本，支持多行显示",
    ),
    "chat_markdown_example_table_col1": MessageLookupByLibrary.simpleMessage(
      "列1",
    ),
    "chat_markdown_example_table_col2": MessageLookupByLibrary.simpleMessage(
      "列2",
    ),
    "chat_markdown_example_table_content1":
        MessageLookupByLibrary.simpleMessage("内容1"),
    "chat_markdown_example_table_content2":
        MessageLookupByLibrary.simpleMessage("内容2"),
    "chat_markdown_example_table_content3":
        MessageLookupByLibrary.simpleMessage("内容3"),
    "chat_markdown_example_table_content4":
        MessageLookupByLibrary.simpleMessage("内容4"),
    "chat_markdown_example_title1": MessageLookupByLibrary.simpleMessage(
      "这是一级标题",
    ),
    "chat_markdown_example_title2": MessageLookupByLibrary.simpleMessage(
      "这是二级标题",
    ),
    "chat_me": MessageLookupByLibrary.simpleMessage("我"),
    "chat_message_recalled": MessageLookupByLibrary.simpleMessage("消息已撤回"),
    "chat_mic_permission_denied": MessageLookupByLibrary.simpleMessage(
      "未获得麦克风权限，无法录音",
    ),
    "chat_mic_permission_denied_message": MessageLookupByLibrary.simpleMessage(
      "请在系统设置中手动开启麦克风权限才能使用录音功能。",
    ),
    "chat_mic_permission_denied_title": MessageLookupByLibrary.simpleMessage(
      "麦克风权限已被禁用",
    ),
    "chat_no_messages": MessageLookupByLibrary.simpleMessage("暂无消息，开始聊天吧！"),
    "chat_notification_center": MessageLookupByLibrary.simpleMessage("通知中心"),
    "chat_notification_description": MessageLookupByLibrary.simpleMessage(
      "系统、订单、评价等重要通知",
    ),
    "chat_opponent_not_found": MessageLookupByLibrary.simpleMessage("无法找到对方信息"),
    "chat_permission_denied_cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "chat_permission_denied_settings": MessageLookupByLibrary.simpleMessage(
      "去设置",
    ),
    "chat_pick_from_gallery": MessageLookupByLibrary.simpleMessage("从相册选择"),
    "chat_press_to_talk": MessageLookupByLibrary.simpleMessage("按住 说话"),
    "chat_recall": MessageLookupByLibrary.simpleMessage("撤回"),
    "chat_recording_error": m6,
    "chat_release_to_send": m7,
    "chat_revoked_message": MessageLookupByLibrary.simpleMessage("[消息已撤回]"),
    "chat_send": MessageLookupByLibrary.simpleMessage("发送"),
    "chat_send_markdown": MessageLookupByLibrary.simpleMessage("发送Markdown示例"),
    "chat_stop_recording_error": m8,
    "chat_switch_to_text": MessageLookupByLibrary.simpleMessage("切换到文本输入"),
    "chat_switch_to_voice": MessageLookupByLibrary.simpleMessage("切换到语音输入"),
    "chat_take_photo": MessageLookupByLibrary.simpleMessage("拍照"),
    "chat_unknown_message": MessageLookupByLibrary.simpleMessage("[未知消息]"),
    "chat_unknown_user": MessageLookupByLibrary.simpleMessage("未知用户"),
    "chat_wants_to_see": MessageLookupByLibrary.simpleMessage("想看看"),
    "chat_web_recording_not_supported": MessageLookupByLibrary.simpleMessage(
      "Web 平台暂不支持录音功能",
    ),
    "chat_yesterday": MessageLookupByLibrary.simpleMessage("昨天"),
    "home_banner_clicked": m9,
    "home_end_of_list": MessageLookupByLibrary.simpleMessage("已经到底了"),
    "home_loading": MessageLookupByLibrary.simpleMessage("加载中..."),
    "home_loading_failed": m10,
    "home_product_card_clicked": m11,
    "home_recommend_clicked": m12,
    "home_retry": MessageLookupByLibrary.simpleMessage("重试"),
    "home_search_hint": MessageLookupByLibrary.simpleMessage("搜索服务"),
    "home_title": MessageLookupByLibrary.simpleMessage("首页"),
    "language_settings": MessageLookupByLibrary.simpleMessage("语言设置"),
    "nav_ai_assistant": MessageLookupByLibrary.simpleMessage("多少看看"),
    "nav_dev": MessageLookupByLibrary.simpleMessage("开发"),
    "nav_home": MessageLookupByLibrary.simpleMessage("主页"),
    "nav_messages": MessageLookupByLibrary.simpleMessage("消息"),
    "nav_profile": MessageLookupByLibrary.simpleMessage("我的"),
    "nav_seller_analytics": MessageLookupByLibrary.simpleMessage("数据"),
    "nav_seller_messages": MessageLookupByLibrary.simpleMessage("消息"),
    "nav_seller_products": MessageLookupByLibrary.simpleMessage("商品"),
    "nav_seller_profile": MessageLookupByLibrary.simpleMessage("我的"),
    "product_default_name": MessageLookupByLibrary.simpleMessage("商品"),
    "product_image_loading_failed": MessageLookupByLibrary.simpleMessage(
      "图片加载失败",
    ),
    "product_recommend_button": MessageLookupByLibrary.simpleMessage("让ta看看"),
    "profile_about_us": MessageLookupByLibrary.simpleMessage("关于我们"),
    "profile_account_security": MessageLookupByLibrary.simpleMessage("账号与安全"),
    "profile_assistant_mission": MessageLookupByLibrary.simpleMessage("小帮手的使命"),
    "profile_cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "profile_completed": MessageLookupByLibrary.simpleMessage("完成"),
    "profile_default_name": MessageLookupByLibrary.simpleMessage("用户"),
    "profile_edit_nickname": MessageLookupByLibrary.simpleMessage("修改昵称"),
    "profile_favorites": MessageLookupByLibrary.simpleMessage("收藏"),
    "profile_in_progress": MessageLookupByLibrary.simpleMessage("处理中"),
    "profile_loading_error": m13,
    "profile_login_button": MessageLookupByLibrary.simpleMessage("去登录"),
    "profile_login_prompt": MessageLookupByLibrary.simpleMessage(
      "请登录以查看您的个人资料",
    ),
    "profile_message_notifications": MessageLookupByLibrary.simpleMessage(
      "消息通知",
    ),
    "profile_my_dskk": MessageLookupByLibrary.simpleMessage("我的多看"),
    "profile_my_wallet": MessageLookupByLibrary.simpleMessage("我的钱包"),
    "profile_navigation_error": m14,
    "profile_nickname_hint": MessageLookupByLibrary.simpleMessage("请输入新昵称"),
    "profile_offline": MessageLookupByLibrary.simpleMessage("离线"),
    "profile_online": MessageLookupByLibrary.simpleMessage("在线"),
    "profile_orders": MessageLookupByLibrary.simpleMessage("我的订单"),
    "profile_pending_payment": MessageLookupByLibrary.simpleMessage("待付"),
    "profile_personal_center": MessageLookupByLibrary.simpleMessage("个人中心"),
    "profile_refund": MessageLookupByLibrary.simpleMessage("售后"),
    "profile_save": MessageLookupByLibrary.simpleMessage("保存"),
    "profile_settings": MessageLookupByLibrary.simpleMessage("设置"),
    "profile_switch_error": m15,
    "profile_switch_to_seller": MessageLookupByLibrary.simpleMessage("切换到卖家模式"),
    "profile_wallet": MessageLookupByLibrary.simpleMessage("钱包"),
    "search_button": MessageLookupByLibrary.simpleMessage("搜索"),
    "search_failed": m16,
    "search_history": MessageLookupByLibrary.simpleMessage("搜索历史"),
    "search_hot_keywords": MessageLookupByLibrary.simpleMessage("热搜榜"),
    "search_no_results": MessageLookupByLibrary.simpleMessage("没有找到相关的服务"),
    "search_title": MessageLookupByLibrary.simpleMessage("搜索"),
    "system_language": MessageLookupByLibrary.simpleMessage("跟随系统"),
    "system_language_description": MessageLookupByLibrary.simpleMessage(
      "自动使用设备的语言设置",
    ),
  };
}
