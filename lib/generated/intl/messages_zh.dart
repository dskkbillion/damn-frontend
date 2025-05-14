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

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "ai_docs_add_image": MessageLookupByLibrary.simpleMessage("添加图片"),
    "ai_docs_assistant_title": MessageLookupByLibrary.simpleMessage("AI 助手"),
    "ai_docs_conversation_list": MessageLookupByLibrary.simpleMessage("会话列表"),
    "ai_docs_dispatched": MessageLookupByLibrary.simpleMessage("已分发"),
    "ai_docs_enter_message": MessageLookupByLibrary.simpleMessage("输入消息..."),
    "ai_docs_image_picking_error": m0,
    "ai_docs_let_them_see": MessageLookupByLibrary.simpleMessage("让ta看看"),
    "ai_docs_loading": MessageLookupByLibrary.simpleMessage("加载中..."),
    "ai_docs_match_button": MessageLookupByLibrary.simpleMessage("匹配"),
    "ai_docs_mic_permission_denied": MessageLookupByLibrary.simpleMessage(
      "麦克风权限被拒绝",
    ),
    "ai_docs_no_messages": MessageLookupByLibrary.simpleMessage("暂无消息，开始聊天吧！"),
    "ai_docs_no_recommendations": MessageLookupByLibrary.simpleMessage(
      "暂无推荐服务",
    ),
    "ai_docs_please_enter_message": MessageLookupByLibrary.simpleMessage(
      "请输入消息内容",
    ),
    "ai_docs_recommendations_error": m1,
    "ai_docs_recommended_services": MessageLookupByLibrary.simpleMessage(
      "推荐服务",
    ),
    "ai_docs_recording": MessageLookupByLibrary.simpleMessage("正在录音...点击停止发送"),
    "ai_docs_recording_error": m2,
    "ai_docs_recording_file_not_found": MessageLookupByLibrary.simpleMessage(
      "错误：未找到录音文件",
    ),
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
    "language_settings": MessageLookupByLibrary.simpleMessage("语言设置"),
    "system_language": MessageLookupByLibrary.simpleMessage("跟随系统"),
    "system_language_description": MessageLookupByLibrary.simpleMessage(
      "自动使用设备的语言设置",
    ),
  };
}
