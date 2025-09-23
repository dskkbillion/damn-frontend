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

  static String m4(error) => "标题生成失败: ${error}";

  static String m5(error) => "标题更新失败: ${error}";

  static String m6(error) => "加载失败: ${error}";

  static String m7(error) => "选择图片出错: ${error}";

  static String m8(error) => "无法开始录音: ${error}";

  static String m9(duration) => "松开 发送 (${duration}s)";

  static String m10(error) => "停止录音失败: ${error}";

  static String m11(targetType, targetValue) =>
      "点击了轮播图: ${targetType} - ${targetValue}";

  static String m12(error) => "加载失败: ${error}";

  static String m13(name) => "点击了服务卡片: ${name}";

  static String m14(name) => "点击了\"让ta看看\"按钮: ${name}";

  static String m15(error) => "加载通知中心失败: ${error}";

  static String m16(days) => "${days}天前";

  static String m17(hours) => "${hours}小时前";

  static String m18(minutes) => "${minutes}分钟前";

  static String m19(months) => "${months}个月前";

  static String m20(orderSn) => "订单交付: ${orderSn}";

  static String m21(price) => "一键购买 ¥${price}";

  static String m22(error) => "加载失败: ${error}";

  static String m23(count) => "评论(${count})";

  static String m24(max) => "最多${max}个字符";

  static String m25(uploaded, total) => "上传中 ${uploaded}/${total}";

  static String m26(name) => "确定要下架商品 \"${name}\" 吗？";

  static String m27(count) => "${count}天前";

  static String m28(count) => "${count}小时前";

  static String m29(error) => "加载失败: ${error}";

  static String m30(count) => "${count}分钟前";

  static String m31(count) => "${count}月前";

  static String m32(count) => "共${count}条评价";

  static String m33(count) => "${count}年前";

  static String m34(error) => "加载失败: ${error}";

  static String m35(error) => "无法导航到订单列表: ${error}";

  static String m36(error) => "无法切换到卖家模式: ${error}";

  static String m37(error) => "搜索失败: ${error}";

  static String m38(type) => "${type}认证说明";

  static String m39(error) => "选择文件失败: ${error}";

  static String m40(count) => "已选择 ${count} 个文件";

  static String m41(type) => "${type}认证";

  static String m42(rate) => "完成率 ${rate}%";

  static String m43(error) => "无法切换到买家模式: ${error}";

  static String m44(error) => "创建聊天失败: ${error}";

  static String m45(error) => "发生错误: ${error}";

  static String m46(feature) => "${feature}功能尚未实现";

  static String m47(count) => "${count}粉丝";

  static String m48(days) => "成为三级会员卖家${days}天";

  static String m49(orderNum) => "完成订单${orderNum}笔";

  static String m50(error) => "加载失败: ${error}";

  static String m51(amount) => "盈利${amount}元";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "after_sales_agree": MessageLookupByLibrary.simpleMessage("同意"),
        "after_sales_agree_application":
            MessageLookupByLibrary.simpleMessage("同意申请"),
        "after_sales_apply_reason":
            MessageLookupByLibrary.simpleMessage("申请原因"),
        "after_sales_apply_time": MessageLookupByLibrary.simpleMessage("申请时间"),
        "after_sales_apply_type": MessageLookupByLibrary.simpleMessage("申请类型"),
        "after_sales_cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "after_sales_confirm": MessageLookupByLibrary.simpleMessage("确认"),
        "after_sales_confirm_message":
            MessageLookupByLibrary.simpleMessage("确定同意此售后申请吗？"),
        "after_sales_confirm_title": MessageLookupByLibrary.simpleMessage("确认"),
        "after_sales_detail_title":
            MessageLookupByLibrary.simpleMessage("售后详情"),
        "after_sales_image_evidence":
            MessageLookupByLibrary.simpleMessage("图片证据"),
        "after_sales_image_load_failed":
            MessageLookupByLibrary.simpleMessage("图片加载失败"),
        "after_sales_image_view": MessageLookupByLibrary.simpleMessage("图片查看"),
        "after_sales_load_failed":
            MessageLookupByLibrary.simpleMessage("加载失败，请重试"),
        "after_sales_no_pending":
            MessageLookupByLibrary.simpleMessage("暂无待审核的售后申请"),
        "after_sales_not_found":
            MessageLookupByLibrary.simpleMessage("找不到对应的售后申请"),
        "after_sales_order_number":
            MessageLookupByLibrary.simpleMessage("订单编号"),
        "after_sales_refresh": MessageLookupByLibrary.simpleMessage("刷新"),
        "after_sales_refund_amount":
            MessageLookupByLibrary.simpleMessage("退款金额"),
        "after_sales_refund_type": MessageLookupByLibrary.simpleMessage("退款类型"),
        "after_sales_reject": MessageLookupByLibrary.simpleMessage("拒绝"),
        "after_sales_reject_application":
            MessageLookupByLibrary.simpleMessage("拒绝申请"),
        "after_sales_reject_reason":
            MessageLookupByLibrary.simpleMessage("拒绝原因"),
        "after_sales_reject_reason_hint":
            MessageLookupByLibrary.simpleMessage("请输入拒绝原因"),
        "after_sales_reject_reason_required":
            MessageLookupByLibrary.simpleMessage("请输入拒绝原因"),
        "after_sales_review_title":
            MessageLookupByLibrary.simpleMessage("售后审核"),
        "after_sales_status_audit_pass":
            MessageLookupByLibrary.simpleMessage("审核通过"),
        "after_sales_status_buyer_shipped":
            MessageLookupByLibrary.simpleMessage("买家已发货"),
        "after_sales_status_canceled":
            MessageLookupByLibrary.simpleMessage("已取消"),
        "after_sales_status_finished":
            MessageLookupByLibrary.simpleMessage("已完成"),
        "after_sales_status_refused":
            MessageLookupByLibrary.simpleMessage("已拒绝"),
        "after_sales_status_seller_received":
            MessageLookupByLibrary.simpleMessage("卖家已收货"),
        "after_sales_status_unknown":
            MessageLookupByLibrary.simpleMessage("未知状态"),
        "after_sales_status_wait_audit":
            MessageLookupByLibrary.simpleMessage("待审核"),
        "after_sales_type_refund_only":
            MessageLookupByLibrary.simpleMessage("仅退款"),
        "after_sales_type_refund_return":
            MessageLookupByLibrary.simpleMessage("退货退款"),
        "after_sales_type_unknown":
            MessageLookupByLibrary.simpleMessage("未知类型"),
        "ai_docs_add_image": MessageLookupByLibrary.simpleMessage("添加图片"),
        "ai_docs_assistant_title":
            MessageLookupByLibrary.simpleMessage("AI 助手"),
        "ai_docs_auto_create_text":
            MessageLookupByLibrary.simpleMessage("没有选择对话，自动创建新对话并发送消息"),
        "ai_docs_auto_create_voice":
            MessageLookupByLibrary.simpleMessage("没有选择对话，自动创建新对话并发送语音消息"),
        "ai_docs_cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "ai_docs_cancelling_generation":
            MessageLookupByLibrary.simpleMessage("正在取消生成中..."),
        "ai_docs_conversation_list":
            MessageLookupByLibrary.simpleMessage("会话列表"),
        "ai_docs_delete": MessageLookupByLibrary.simpleMessage("删除"),
        "ai_docs_delete_conversation_content":
            MessageLookupByLibrary.simpleMessage("确定要永久删除此会话吗？"),
        "ai_docs_delete_conversation_title":
            MessageLookupByLibrary.simpleMessage("删除会话？"),
        "ai_docs_delete_conversation_tooltip":
            MessageLookupByLibrary.simpleMessage("删除会话"),
        "ai_docs_dispatched": MessageLookupByLibrary.simpleMessage("已分发"),
        "ai_docs_edit_title": MessageLookupByLibrary.simpleMessage("编辑标题"),
        "ai_docs_edit_title_hint":
            MessageLookupByLibrary.simpleMessage("请输入新的标题"),
        "ai_docs_enter_chat": MessageLookupByLibrary.simpleMessage("进入聊天"),
        "ai_docs_enter_message":
            MessageLookupByLibrary.simpleMessage("输入消息..."),
        "ai_docs_generate_title":
            MessageLookupByLibrary.simpleMessage("AI生成标题"),
        "ai_docs_generate_title_tooltip":
            MessageLookupByLibrary.simpleMessage("让AI为这个会话生成一个标题"),
        "ai_docs_generating_title":
            MessageLookupByLibrary.simpleMessage("正在生成标题..."),
        "ai_docs_image_picking_error": m0,
        "ai_docs_let_them_see": MessageLookupByLibrary.simpleMessage("让ta看看"),
        "ai_docs_load_conversations_failed":
            MessageLookupByLibrary.simpleMessage("加载会话失败"),
        "ai_docs_loading": MessageLookupByLibrary.simpleMessage("加载中..."),
        "ai_docs_match_button": MessageLookupByLibrary.simpleMessage("匹配"),
        "ai_docs_mic_permission_denied":
            MessageLookupByLibrary.simpleMessage("麦克风权限被拒绝"),
        "ai_docs_new_chat": MessageLookupByLibrary.simpleMessage("新建聊天"),
        "ai_docs_no_conversations":
            MessageLookupByLibrary.simpleMessage("暂无会话"),
        "ai_docs_no_messages":
            MessageLookupByLibrary.simpleMessage("暂无消息，开始聊天吧！"),
        "ai_docs_no_recommendations":
            MessageLookupByLibrary.simpleMessage("暂无推荐服务"),
        "ai_docs_please_enter_message":
            MessageLookupByLibrary.simpleMessage("请输入消息内容"),
        "ai_docs_please_select_conversation_to_delete":
            MessageLookupByLibrary.simpleMessage("请先选择要删除的会话"),
        "ai_docs_recommendations_error": m1,
        "ai_docs_recommended_services":
            MessageLookupByLibrary.simpleMessage("推荐服务"),
        "ai_docs_recording":
            MessageLookupByLibrary.simpleMessage("正在录音...点击停止发送"),
        "ai_docs_recording_error": m2,
        "ai_docs_recording_file_not_found":
            MessageLookupByLibrary.simpleMessage("错误：未找到录音文件"),
        "ai_docs_retry": MessageLookupByLibrary.simpleMessage("重试"),
        "ai_docs_select_conversation_first":
            MessageLookupByLibrary.simpleMessage("请先选择一个会话"),
        "ai_docs_send_message": MessageLookupByLibrary.simpleMessage("发送消息"),
        "ai_docs_start_recording": MessageLookupByLibrary.simpleMessage("录制语音"),
        "ai_docs_stop_generation": MessageLookupByLibrary.simpleMessage("停止生成"),
        "ai_docs_stop_recording": MessageLookupByLibrary.simpleMessage("停止录音"),
        "ai_docs_stop_recording_error":
            MessageLookupByLibrary.simpleMessage("停止录音出错"),
        "ai_docs_stop_recording_error_with_reason": m3,
        "ai_docs_title_empty": MessageLookupByLibrary.simpleMessage("标题不能为空"),
        "ai_docs_title_generated":
            MessageLookupByLibrary.simpleMessage("标题已生成"),
        "ai_docs_title_generation_failed": m4,
        "ai_docs_title_too_long":
            MessageLookupByLibrary.simpleMessage("标题长度不能超过50个字符"),
        "ai_docs_title_update_failed": m5,
        "ai_docs_title_updated": MessageLookupByLibrary.simpleMessage("标题已更新"),
        "ai_docs_unnamed_conversation":
            MessageLookupByLibrary.simpleMessage("未命名会话"),
        "ai_docs_uploading_images":
            MessageLookupByLibrary.simpleMessage("图片正在上传中，请稍候..."),
        "ai_docs_welcome_message":
            MessageLookupByLibrary.simpleMessage("直接发送消息即可开始对话，系统会自动为您创建聊天室"),
        "ai_docs_welcome_title":
            MessageLookupByLibrary.simpleMessage("欢迎使用AI助手"),
        "allocating_step1": MessageLookupByLibrary.simpleMessage("分发中"),
        "allocating_step2": MessageLookupByLibrary.simpleMessage("分发中."),
        "allocating_step3": MessageLookupByLibrary.simpleMessage("分发中.."),
        "allocating_step4": MessageLookupByLibrary.simpleMessage("分发中..."),
        "attachments": MessageLookupByLibrary.simpleMessage("附件:"),
        "auth_phone_number": MessageLookupByLibrary.simpleMessage("手机号"),
        "auth_phone_validation_empty":
            MessageLookupByLibrary.simpleMessage("请输入手机号"),
        "auth_phone_validation_invalid_cn":
            MessageLookupByLibrary.simpleMessage("请输入11位手机号"),
        "auth_phone_validation_invalid_cn_start":
            MessageLookupByLibrary.simpleMessage("手机号必须以1开头"),
        "auth_phone_validation_invalid_general":
            MessageLookupByLibrary.simpleMessage("请输入有效的电话号码"),
        "auth_phone_validation_invalid_jp_kr":
            MessageLookupByLibrary.simpleMessage("请输入10或11位电话号码"),
        "auth_phone_validation_invalid_us":
            MessageLookupByLibrary.simpleMessage("请输入10位电话号码"),
        "auth_select_country_region":
            MessageLookupByLibrary.simpleMessage("选择国家/地区"),
        "auto_reply_content": MessageLookupByLibrary.simpleMessage("回复内容"),
        "auto_reply_content_description":
            MessageLookupByLibrary.simpleMessage("当客户发送消息时，系统会自动回复此内容"),
        "auto_reply_content_hint":
            MessageLookupByLibrary.simpleMessage("请输入自动回复内容"),
        "auto_reply_content_required":
            MessageLookupByLibrary.simpleMessage("回复内容不能为空"),
        "auto_reply_enable": MessageLookupByLibrary.simpleMessage("自动回复"),
        "auto_reply_load_failed":
            MessageLookupByLibrary.simpleMessage("加载失败，请重试"),
        "auto_reply_save_settings":
            MessageLookupByLibrary.simpleMessage("保存设置"),
        "auto_reply_settings_saved":
            MessageLookupByLibrary.simpleMessage("设置已保存"),
        "auto_reply_title": MessageLookupByLibrary.simpleMessage("自动回复设置"),
        "buyerSubmittedMaterials":
            MessageLookupByLibrary.simpleMessage("买家提交的材料"),
        "cancelDownload": MessageLookupByLibrary.simpleMessage("取消下载"),
        "chat_admin_connection_error":
            MessageLookupByLibrary.simpleMessage("无法连接到系统管理员"),
        "chat_admin_title": MessageLookupByLibrary.simpleMessage("系统管理员"),
        "chat_attach": MessageLookupByLibrary.simpleMessage("发送图片/文件"),
        "chat_audio_message": MessageLookupByLibrary.simpleMessage("[语音]"),
        "chat_audio_pause": MessageLookupByLibrary.simpleMessage("暂停"),
        "chat_audio_play": MessageLookupByLibrary.simpleMessage("播放"),
        "chat_buyer": MessageLookupByLibrary.simpleMessage("买家"),
        "chat_camera_permission_denied":
            MessageLookupByLibrary.simpleMessage("未获得相机权限，无法拍照"),
        "chat_camera_permission_denied_message":
            MessageLookupByLibrary.simpleMessage("请在系统设置中手动开启相机权限才能使用拍照功能。"),
        "chat_camera_permission_denied_title":
            MessageLookupByLibrary.simpleMessage("相机权限已被禁用"),
        "chat_collapse": MessageLookupByLibrary.simpleMessage("收起"),
        "chat_copied_to_clipboard":
            MessageLookupByLibrary.simpleMessage("已复制到剪贴板"),
        "chat_copy": MessageLookupByLibrary.simpleMessage("复制"),
        "chat_enter_message": MessageLookupByLibrary.simpleMessage("输入消息..."),
        "chat_error_loading": m6,
        "chat_expand": MessageLookupByLibrary.simpleMessage("展开"),
        "chat_filter_all": MessageLookupByLibrary.simpleMessage("全部"),
        "chat_filter_buyer": MessageLookupByLibrary.simpleMessage("我的购买"),
        "chat_filter_mode_all": MessageLookupByLibrary.simpleMessage("显示全部聊天"),
        "chat_filter_mode_buyer":
            MessageLookupByLibrary.simpleMessage("只显示我的购买聊天"),
        "chat_filter_mode_seller":
            MessageLookupByLibrary.simpleMessage("只显示我的出售聊天"),
        "chat_filter_seller": MessageLookupByLibrary.simpleMessage("我的出售"),
        "chat_i_want_seller_to_see":
            MessageLookupByLibrary.simpleMessage("我想让商家看看"),
        "chat_image_message": MessageLookupByLibrary.simpleMessage("[图片]"),
        "chat_image_picking_error": m7,
        "chat_invalid_session": MessageLookupByLibrary.simpleMessage("无效的会话"),
        "chat_list_title": MessageLookupByLibrary.simpleMessage("聊天列表"),
        "chat_loading": MessageLookupByLibrary.simpleMessage("正在加载..."),
        "chat_markdown_example_bold_italic":
            MessageLookupByLibrary.simpleMessage("这是**粗体**文本和*斜体*文本。"),
        "chat_markdown_example_list1":
            MessageLookupByLibrary.simpleMessage("这是列表项1"),
        "chat_markdown_example_list2":
            MessageLookupByLibrary.simpleMessage("这是列表项2"),
        "chat_markdown_example_list3":
            MessageLookupByLibrary.simpleMessage("这是嵌套列表项"),
        "chat_markdown_example_quote":
            MessageLookupByLibrary.simpleMessage("这是引用文本，支持多行显示"),
        "chat_markdown_example_table_col1":
            MessageLookupByLibrary.simpleMessage("列1"),
        "chat_markdown_example_table_col2":
            MessageLookupByLibrary.simpleMessage("列2"),
        "chat_markdown_example_table_content1":
            MessageLookupByLibrary.simpleMessage("内容1"),
        "chat_markdown_example_table_content2":
            MessageLookupByLibrary.simpleMessage("内容2"),
        "chat_markdown_example_table_content3":
            MessageLookupByLibrary.simpleMessage("内容3"),
        "chat_markdown_example_table_content4":
            MessageLookupByLibrary.simpleMessage("内容4"),
        "chat_markdown_example_title1":
            MessageLookupByLibrary.simpleMessage("这是一级标题"),
        "chat_markdown_example_title2":
            MessageLookupByLibrary.simpleMessage("这是二级标题"),
        "chat_me": MessageLookupByLibrary.simpleMessage("我"),
        "chat_message_recalled": MessageLookupByLibrary.simpleMessage("消息已撤回"),
        "chat_mic_permission_denied":
            MessageLookupByLibrary.simpleMessage("未获得麦克风权限，无法录音"),
        "chat_mic_permission_denied_message":
            MessageLookupByLibrary.simpleMessage("请在系统设置中手动开启麦克风权限才能使用录音功能。"),
        "chat_mic_permission_denied_title":
            MessageLookupByLibrary.simpleMessage("麦克风权限已被禁用"),
        "chat_no_messages": MessageLookupByLibrary.simpleMessage("暂无消息，开始聊天吧！"),
        "chat_notification_center":
            MessageLookupByLibrary.simpleMessage("通知中心"),
        "chat_notification_description":
            MessageLookupByLibrary.simpleMessage("系统、订单、评价等重要通知"),
        "chat_opponent_not_found":
            MessageLookupByLibrary.simpleMessage("无法找到对方信息"),
        "chat_permission_denied_cancel":
            MessageLookupByLibrary.simpleMessage("取消"),
        "chat_permission_denied_settings":
            MessageLookupByLibrary.simpleMessage("去设置"),
        "chat_pick_from_gallery": MessageLookupByLibrary.simpleMessage("从相册选择"),
        "chat_press_to_talk": MessageLookupByLibrary.simpleMessage("按住 说话"),
        "chat_recall": MessageLookupByLibrary.simpleMessage("撤回"),
        "chat_recording_error": m8,
        "chat_release_to_send": m9,
        "chat_revoked_message": MessageLookupByLibrary.simpleMessage("[消息已撤回]"),
        "chat_send": MessageLookupByLibrary.simpleMessage("发送"),
        "chat_send_markdown":
            MessageLookupByLibrary.simpleMessage("发送Markdown示例"),
        "chat_stop_recording_error": m10,
        "chat_switch_to_text": MessageLookupByLibrary.simpleMessage("切换到文本输入"),
        "chat_switch_to_voice": MessageLookupByLibrary.simpleMessage("切换到语音输入"),
        "chat_take_photo": MessageLookupByLibrary.simpleMessage("拍照"),
        "chat_unknown_message": MessageLookupByLibrary.simpleMessage("[未知消息]"),
        "chat_unknown_user": MessageLookupByLibrary.simpleMessage("未知用户"),
        "chat_wants_to_see": MessageLookupByLibrary.simpleMessage("想看看"),
        "chat_web_recording_not_supported":
            MessageLookupByLibrary.simpleMessage("Web 平台暂不支持录音功能"),
        "chat_yesterday": MessageLookupByLibrary.simpleMessage("昨天"),
        "deliveryDescription": MessageLookupByLibrary.simpleMessage("交付说明"),
        "deliveryFiles": MessageLookupByLibrary.simpleMessage("交付文件:"),
        "downloadCompleted": MessageLookupByLibrary.simpleMessage("下载完成"),
        "downloadFailed": MessageLookupByLibrary.simpleMessage("下载失败"),
        "downloadFile": MessageLookupByLibrary.simpleMessage("下载文件"),
        "downloaded": MessageLookupByLibrary.simpleMessage("已下载"),
        "home_banner_clicked": m11,
        "home_end_of_list": MessageLookupByLibrary.simpleMessage("已经到底了"),
        "home_loading": MessageLookupByLibrary.simpleMessage("加载中..."),
        "home_loading_failed": m12,
        "home_no_content": MessageLookupByLibrary.simpleMessage("暂无推荐内容"),
        "home_product_card_clicked": m13,
        "home_pull_to_refresh":
            MessageLookupByLibrary.simpleMessage("下拉刷新获取推荐内容"),
        "home_recommend_clicked": m14,
        "home_retry": MessageLookupByLibrary.simpleMessage("重试"),
        "home_search_hint": MessageLookupByLibrary.simpleMessage("搜索服务"),
        "home_title": MessageLookupByLibrary.simpleMessage("首页"),
        "language_settings": MessageLookupByLibrary.simpleMessage("语言设置"),
        "materialsInfo": MessageLookupByLibrary.simpleMessage("材料信息"),
        "nav_ai_assistant": MessageLookupByLibrary.simpleMessage("多少看看"),
        "nav_dev": MessageLookupByLibrary.simpleMessage("开发"),
        "nav_home": MessageLookupByLibrary.simpleMessage("主页"),
        "nav_messages": MessageLookupByLibrary.simpleMessage("消息"),
        "nav_profile": MessageLookupByLibrary.simpleMessage("我的"),
        "nav_seller_analytics": MessageLookupByLibrary.simpleMessage("数据"),
        "nav_seller_messages": MessageLookupByLibrary.simpleMessage("消息"),
        "nav_seller_products": MessageLookupByLibrary.simpleMessage("商品"),
        "nav_seller_profile": MessageLookupByLibrary.simpleMessage("我的"),
        "noBuyerMaterials": MessageLookupByLibrary.simpleMessage("暂无买家提交的材料"),
        "noSellerDelivery": MessageLookupByLibrary.simpleMessage("卖家暂未交付内容"),
        "notification_center_title":
            MessageLookupByLibrary.simpleMessage("通知中心"),
        "notification_click_to_view":
            MessageLookupByLibrary.simpleMessage("点击查看详情"),
        "notification_default_title":
            MessageLookupByLibrary.simpleMessage("通知"),
        "notification_detail_close": MessageLookupByLibrary.simpleMessage("关闭"),
        "notification_detail_title":
            MessageLookupByLibrary.simpleMessage("通知详情"),
        "notification_detail_view":
            MessageLookupByLibrary.simpleMessage("查看详情"),
        "notification_empty_all":
            MessageLookupByLibrary.simpleMessage("暂无任何通知"),
        "notification_empty_authentication":
            MessageLookupByLibrary.simpleMessage("暂无认证通知"),
        "notification_empty_generic":
            MessageLookupByLibrary.simpleMessage("暂无通知"),
        "notification_empty_message":
            MessageLookupByLibrary.simpleMessage("暂无消息通知"),
        "notification_empty_order":
            MessageLookupByLibrary.simpleMessage("暂无订单通知"),
        "notification_empty_other":
            MessageLookupByLibrary.simpleMessage("暂无其他通知"),
        "notification_empty_refund":
            MessageLookupByLibrary.simpleMessage("暂无售后通知"),
        "notification_empty_review":
            MessageLookupByLibrary.simpleMessage("暂无评价通知"),
        "notification_empty_system":
            MessageLookupByLibrary.simpleMessage("暂无系统通知"),
        "notification_load_failed": m15,
        "notification_mark_all_read":
            MessageLookupByLibrary.simpleMessage("全部标记已读"),
        "notification_refresh": MessageLookupByLibrary.simpleMessage("刷新"),
        "notification_retry": MessageLookupByLibrary.simpleMessage("重试"),
        "notification_status_read": MessageLookupByLibrary.simpleMessage("已读"),
        "notification_status_unread":
            MessageLookupByLibrary.simpleMessage("未读"),
        "notification_tab_all": MessageLookupByLibrary.simpleMessage("全部"),
        "notification_tab_message": MessageLookupByLibrary.simpleMessage("消息"),
        "notification_tab_order": MessageLookupByLibrary.simpleMessage("订单"),
        "notification_tab_refund": MessageLookupByLibrary.simpleMessage("售后"),
        "notification_tab_system": MessageLookupByLibrary.simpleMessage("系统"),
        "notification_time_days_ago": m16,
        "notification_time_hours_ago": m17,
        "notification_time_just_now":
            MessageLookupByLibrary.simpleMessage("刚刚"),
        "notification_time_minutes_ago": m18,
        "notification_time_months_ago": m19,
        "notification_type_authentication":
            MessageLookupByLibrary.simpleMessage("认证通知"),
        "notification_type_message":
            MessageLookupByLibrary.simpleMessage("消息通知"),
        "notification_type_order": MessageLookupByLibrary.simpleMessage("订单通知"),
        "notification_type_other": MessageLookupByLibrary.simpleMessage("其他通知"),
        "notification_type_refund":
            MessageLookupByLibrary.simpleMessage("售后通知"),
        "notification_type_review":
            MessageLookupByLibrary.simpleMessage("评价通知"),
        "notification_type_system":
            MessageLookupByLibrary.simpleMessage("系统通知"),
        "openFile": MessageLookupByLibrary.simpleMessage("打开文件"),
        "openFileFailed": MessageLookupByLibrary.simpleMessage("打开文件失败"),
        "order_delivery_attachments_label":
            MessageLookupByLibrary.simpleMessage("附件文件:"),
        "order_delivery_confirm_shipment":
            MessageLookupByLibrary.simpleMessage("确认发货"),
        "order_delivery_content_hint":
            MessageLookupByLibrary.simpleMessage("请描述您的交付内容..."),
        "order_delivery_content_label":
            MessageLookupByLibrary.simpleMessage("交付内容描述:"),
        "order_delivery_content_required":
            MessageLookupByLibrary.simpleMessage("请输入交付内容描述"),
        "order_delivery_instruction_content":
            MessageLookupByLibrary.simpleMessage(
                "请提交您针对此订单的交付内容。您可以提供详细说明以及附加相关文件，确保买家能够清晰了解您提供的服务或产品。"),
        "order_delivery_instruction_title":
            MessageLookupByLibrary.simpleMessage("订单交付说明"),
        "order_delivery_load_failed":
            MessageLookupByLibrary.simpleMessage("加载失败，请重试"),
        "order_delivery_logistics_company":
            MessageLookupByLibrary.simpleMessage("物流公司"),
        "order_delivery_no_pending_orders":
            MessageLookupByLibrary.simpleMessage("暂无待发货订单"),
        "order_delivery_receiving_address":
            MessageLookupByLibrary.simpleMessage("收货地址"),
        "order_delivery_shipping_address":
            MessageLookupByLibrary.simpleMessage("发货地址"),
        "order_delivery_status_in_transit":
            MessageLookupByLibrary.simpleMessage("配送中"),
        "order_delivery_status_pending":
            MessageLookupByLibrary.simpleMessage("待发货"),
        "order_delivery_status_received":
            MessageLookupByLibrary.simpleMessage("已收货"),
        "order_delivery_status_shipped":
            MessageLookupByLibrary.simpleMessage("已发货"),
        "order_delivery_submit_button":
            MessageLookupByLibrary.simpleMessage("提交交付"),
        "order_delivery_submit_success":
            MessageLookupByLibrary.simpleMessage("交付内容提交成功"),
        "order_delivery_submitting":
            MessageLookupByLibrary.simpleMessage("正在提交交付内容..."),
        "order_delivery_title": MessageLookupByLibrary.simpleMessage("订单交付"),
        "order_delivery_title_with_sn": m20,
        "order_delivery_tracking_number":
            MessageLookupByLibrary.simpleMessage("物流单号"),
        "order_delivery_view_details":
            MessageLookupByLibrary.simpleMessage("查看详情"),
        "pageLoadFailed": MessageLookupByLibrary.simpleMessage("页面加载失败"),
        "pdfLoadFailed": MessageLookupByLibrary.simpleMessage("PDF加载失败"),
        "product_default_name": MessageLookupByLibrary.simpleMessage("商品"),
        "product_detail_basic_package":
            MessageLookupByLibrary.simpleMessage("基础"),
        "product_detail_basic_tier": MessageLookupByLibrary.simpleMessage("基础"),
        "product_detail_buy_now":
            MessageLookupByLibrary.simpleMessage("一键购买(1)"),
        "product_detail_buy_now_with_price": m21,
        "product_detail_case_showcase":
            MessageLookupByLibrary.simpleMessage("案例展示"),
        "product_detail_collapse": MessageLookupByLibrary.simpleMessage("收起"),
        "product_detail_contact_seller":
            MessageLookupByLibrary.simpleMessage("咨询卖家"),
        "product_detail_delivery_period":
            MessageLookupByLibrary.simpleMessage("交付周期"),
        "product_detail_delivery_times":
            MessageLookupByLibrary.simpleMessage("交付次数"),
        "product_detail_faq": MessageLookupByLibrary.simpleMessage("常见问题"),
        "product_detail_loading_failed": m22,
        "product_detail_more": MessageLookupByLibrary.simpleMessage("更多"),
        "product_detail_no_cases":
            MessageLookupByLibrary.simpleMessage("暂无案例展示"),
        "product_detail_no_reviews":
            MessageLookupByLibrary.simpleMessage("暂无评价"),
        "product_detail_please_wait":
            MessageLookupByLibrary.simpleMessage("请稍等..."),
        "product_detail_premium_package":
            MessageLookupByLibrary.simpleMessage("豪华"),
        "product_detail_premium_tier":
            MessageLookupByLibrary.simpleMessage("豪华"),
        "product_detail_published_status":
            MessageLookupByLibrary.simpleMessage("已发布"),
        "product_detail_retry": MessageLookupByLibrary.simpleMessage("重试"),
        "product_detail_reviews": m23,
        "product_detail_sample_review":
            MessageLookupByLibrary.simpleMessage("不错，很有耐心"),
        "product_detail_sample_user":
            MessageLookupByLibrary.simpleMessage("瑞123"),
        "product_detail_standard_package":
            MessageLookupByLibrary.simpleMessage("标准"),
        "product_detail_standard_tier":
            MessageLookupByLibrary.simpleMessage("标准"),
        "product_detail_verified_label":
            MessageLookupByLibrary.simpleMessage("已认证"),
        "product_detail_view_all": MessageLookupByLibrary.simpleMessage("查看全部"),
        "product_edit_add_image": MessageLookupByLibrary.simpleMessage("添加图片"),
        "product_edit_add_success_case":
            MessageLookupByLibrary.simpleMessage("添加成功案例"),
        "product_edit_at_least_one_image":
            MessageLookupByLibrary.simpleMessage("请至少上传一张商品图片"),
        "product_edit_attribute_name_hint":
            MessageLookupByLibrary.simpleMessage("请输入属性名称"),
        "product_edit_basic_info": MessageLookupByLibrary.simpleMessage("基础信息"),
        "product_edit_detail_intro":
            MessageLookupByLibrary.simpleMessage("详情介绍"),
        "product_edit_edit_attribute":
            MessageLookupByLibrary.simpleMessage("编辑商品属性"),
        "product_edit_edit_service":
            MessageLookupByLibrary.simpleMessage("编辑服务"),
        "product_edit_edit_success_case":
            MessageLookupByLibrary.simpleMessage("编辑成功案例"),
        "product_edit_max_characters": m24,
        "product_edit_placeholder_hint":
            MessageLookupByLibrary.simpleMessage("例如：请选择颜色、请输入型号"),
        "product_edit_placeholder_label":
            MessageLookupByLibrary.simpleMessage("占位符文本"),
        "product_edit_please_enter_attribute_name":
            MessageLookupByLibrary.simpleMessage("请输入属性名称"),
        "product_edit_please_enter_label":
            MessageLookupByLibrary.simpleMessage("请输入信息标签"),
        "product_edit_preview_product":
            MessageLookupByLibrary.simpleMessage("预览商品"),
        "product_edit_product_description":
            MessageLookupByLibrary.simpleMessage("商品描述"),
        "product_edit_product_description_hint":
            MessageLookupByLibrary.simpleMessage("请输入商品描述"),
        "product_edit_product_images":
            MessageLookupByLibrary.simpleMessage("商品图片"),
        "product_edit_product_name":
            MessageLookupByLibrary.simpleMessage("商品名称"),
        "product_edit_product_name_hint":
            MessageLookupByLibrary.simpleMessage("请输入商品名称"),
        "product_edit_product_preview_title":
            MessageLookupByLibrary.simpleMessage("商品预览"),
        "product_edit_product_price":
            MessageLookupByLibrary.simpleMessage("商品价格"),
        "product_edit_publish_product":
            MessageLookupByLibrary.simpleMessage("发布商品"),
        "product_edit_publish_service":
            MessageLookupByLibrary.simpleMessage("发布服务"),
        "product_edit_save_draft": MessageLookupByLibrary.simpleMessage("保存草稿"),
        "product_edit_save_draft_dialog_confirm":
            MessageLookupByLibrary.simpleMessage("保存"),
        "product_edit_save_draft_dialog_message":
            MessageLookupByLibrary.simpleMessage("是否保存为草稿？"),
        "product_edit_save_draft_dialog_title":
            MessageLookupByLibrary.simpleMessage("保存草稿"),
        "product_edit_service_tiers":
            MessageLookupByLibrary.simpleMessage("服务档位设置"),
        "product_edit_success_cases":
            MessageLookupByLibrary.simpleMessage("成功案例"),
        "product_edit_title_create":
            MessageLookupByLibrary.simpleMessage("创建商品"),
        "product_edit_title_edit": MessageLookupByLibrary.simpleMessage("编辑商品"),
        "product_edit_uploading":
            MessageLookupByLibrary.simpleMessage("上传中..."),
        "product_edit_uploading_progress": m25,
        "product_edit_validation_description_required":
            MessageLookupByLibrary.simpleMessage("请输入商品描述"),
        "product_edit_validation_image_required":
            MessageLookupByLibrary.simpleMessage("请至少上传一张商品图片"),
        "product_edit_validation_name_required":
            MessageLookupByLibrary.simpleMessage("请输入商品名称"),
        "product_image_loading_failed":
            MessageLookupByLibrary.simpleMessage("图片加载失败"),
        "product_management_action_delete":
            MessageLookupByLibrary.simpleMessage("删除"),
        "product_management_action_edit":
            MessageLookupByLibrary.simpleMessage("编辑"),
        "product_management_action_off_shelf":
            MessageLookupByLibrary.simpleMessage("下架"),
        "product_management_action_on_shelf":
            MessageLookupByLibrary.simpleMessage("上架"),
        "product_management_action_publish":
            MessageLookupByLibrary.simpleMessage("发布"),
        "product_management_action_resubmit":
            MessageLookupByLibrary.simpleMessage("重新提交"),
        "product_management_cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "product_management_confirm":
            MessageLookupByLibrary.simpleMessage("确认下架"),
        "product_management_confirm_delete_message":
            MessageLookupByLibrary.simpleMessage("确定要删除这个商品吗？此操作不可撤销。"),
        "product_management_confirm_delete_title":
            MessageLookupByLibrary.simpleMessage("确认删除"),
        "product_management_confirm_off_shelf_desc":
            MessageLookupByLibrary.simpleMessage("下架后："),
        "product_management_confirm_off_shelf_message": m26,
        "product_management_confirm_off_shelf_point1":
            MessageLookupByLibrary.simpleMessage("• 买家将无法看到和购买此商品"),
        "product_management_confirm_off_shelf_point2":
            MessageLookupByLibrary.simpleMessage("• 您可以随时重新上架"),
        "product_management_confirm_off_shelf_point3":
            MessageLookupByLibrary.simpleMessage("• 商品数据会被保留"),
        "product_management_confirm_off_shelf_title":
            MessageLookupByLibrary.simpleMessage("确认下架"),
        "product_management_create_product":
            MessageLookupByLibrary.simpleMessage("创建商品"),
        "product_management_delete": MessageLookupByLibrary.simpleMessage("删除"),
        "product_management_draft_preview_hint":
            MessageLookupByLibrary.simpleMessage("草稿状态的商品需要先发布才能预览"),
        "product_management_empty_default":
            MessageLookupByLibrary.simpleMessage("暂无商品数据"),
        "product_management_empty_draft":
            MessageLookupByLibrary.simpleMessage("暂无草稿商品"),
        "product_management_empty_off_shelf":
            MessageLookupByLibrary.simpleMessage("暂无已下架商品"),
        "product_management_empty_on_sale":
            MessageLookupByLibrary.simpleMessage("暂无在售商品"),
        "product_management_no_more_products":
            MessageLookupByLibrary.simpleMessage("没有更多商品了"),
        "product_management_sales_label":
            MessageLookupByLibrary.simpleMessage("销量"),
        "product_management_status_draft":
            MessageLookupByLibrary.simpleMessage("草稿"),
        "product_management_status_off_shelf":
            MessageLookupByLibrary.simpleMessage("已下架"),
        "product_management_status_on_shelf":
            MessageLookupByLibrary.simpleMessage("已上架"),
        "product_management_status_rejected":
            MessageLookupByLibrary.simpleMessage("审核失败"),
        "product_management_status_reviewing":
            MessageLookupByLibrary.simpleMessage("审核中"),
        "product_management_status_unknown":
            MessageLookupByLibrary.simpleMessage("未知"),
        "product_management_status_waiting_review":
            MessageLookupByLibrary.simpleMessage("等待审核"),
        "product_management_stock_label":
            MessageLookupByLibrary.simpleMessage("库存"),
        "product_management_tab_draft":
            MessageLookupByLibrary.simpleMessage("草稿箱"),
        "product_management_tab_off_shelf":
            MessageLookupByLibrary.simpleMessage("已下架"),
        "product_management_tab_on_sale":
            MessageLookupByLibrary.simpleMessage("在售"),
        "product_management_title":
            MessageLookupByLibrary.simpleMessage("商品管理"),
        "product_preview_current_seller":
            MessageLookupByLibrary.simpleMessage("当前卖家"),
        "product_preview_seller_user":
            MessageLookupByLibrary.simpleMessage("卖家用户"),
        "product_recommend_button":
            MessageLookupByLibrary.simpleMessage("让ta看看"),
        "product_reviews_days_ago": m27,
        "product_reviews_filter_all":
            MessageLookupByLibrary.simpleMessage("全部"),
        "product_reviews_filter_bad":
            MessageLookupByLibrary.simpleMessage("差评"),
        "product_reviews_filter_good":
            MessageLookupByLibrary.simpleMessage("好评"),
        "product_reviews_filter_medium":
            MessageLookupByLibrary.simpleMessage("中评"),
        "product_reviews_filter_with_images":
            MessageLookupByLibrary.simpleMessage("有图"),
        "product_reviews_hours_ago": m28,
        "product_reviews_just_now": MessageLookupByLibrary.simpleMessage("刚刚"),
        "product_reviews_loading_failed": m29,
        "product_reviews_minutes_ago": m30,
        "product_reviews_months_ago": m31,
        "product_reviews_no_reviews":
            MessageLookupByLibrary.simpleMessage("暂无评论"),
        "product_reviews_retry": MessageLookupByLibrary.simpleMessage("重试"),
        "product_reviews_sample_content":
            MessageLookupByLibrary.simpleMessage("不错，很有耐心"),
        "product_reviews_seller_reply":
            MessageLookupByLibrary.simpleMessage("卖家回复"),
        "product_reviews_title": MessageLookupByLibrary.simpleMessage("评论"),
        "product_reviews_total_count": m32,
        "product_reviews_years_ago": m33,
        "profile_about_us": MessageLookupByLibrary.simpleMessage("关于我们"),
        "profile_account_security":
            MessageLookupByLibrary.simpleMessage("账号与安全"),
        "profile_assistant_mission":
            MessageLookupByLibrary.simpleMessage("小帮手的使命"),
        "profile_avatar_upload_failed":
            MessageLookupByLibrary.simpleMessage("头像上传失败，请重试"),
        "profile_cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "profile_completed": MessageLookupByLibrary.simpleMessage("待收货"),
        "profile_default_name": MessageLookupByLibrary.simpleMessage("用户"),
        "profile_edit_nickname": MessageLookupByLibrary.simpleMessage("修改昵称"),
        "profile_favorites": MessageLookupByLibrary.simpleMessage("收藏"),
        "profile_in_progress": MessageLookupByLibrary.simpleMessage("待提交"),
        "profile_loading_error": m34,
        "profile_login_button": MessageLookupByLibrary.simpleMessage("去登录"),
        "profile_login_prompt":
            MessageLookupByLibrary.simpleMessage("请登录以查看您的个人资料"),
        "profile_message_notifications":
            MessageLookupByLibrary.simpleMessage("消息通知"),
        "profile_my_dskk": MessageLookupByLibrary.simpleMessage("我的多看"),
        "profile_my_wallet": MessageLookupByLibrary.simpleMessage("我的钱包"),
        "profile_navigation_error": m35,
        "profile_nickname_hint": MessageLookupByLibrary.simpleMessage("请输入新昵称"),
        "profile_offline": MessageLookupByLibrary.simpleMessage("离线"),
        "profile_online": MessageLookupByLibrary.simpleMessage("在线"),
        "profile_orders": MessageLookupByLibrary.simpleMessage("我的订单"),
        "profile_pending_payment": MessageLookupByLibrary.simpleMessage("待付"),
        "profile_personal_center": MessageLookupByLibrary.simpleMessage("个人中心"),
        "profile_refund": MessageLookupByLibrary.simpleMessage("售后"),
        "profile_save": MessageLookupByLibrary.simpleMessage("保存"),
        "profile_settings": MessageLookupByLibrary.simpleMessage("设置"),
        "profile_switch_error": m36,
        "profile_switch_to_seller":
            MessageLookupByLibrary.simpleMessage("切换到卖家模式"),
        "profile_wallet": MessageLookupByLibrary.simpleMessage("钱包"),
        "retry": MessageLookupByLibrary.simpleMessage("重试"),
        "search_button": MessageLookupByLibrary.simpleMessage("搜索"),
        "search_failed": m37,
        "search_history": MessageLookupByLibrary.simpleMessage("搜索历史"),
        "search_hot_keywords": MessageLookupByLibrary.simpleMessage("热搜榜"),
        "search_no_results": MessageLookupByLibrary.simpleMessage("没有找到相关的服务"),
        "search_title": MessageLookupByLibrary.simpleMessage("搜索"),
        "sellerDeliveryContent": MessageLookupByLibrary.simpleMessage("卖家交付内容"),
        "seller_auth_application_agreement_agree":
            MessageLookupByLibrary.simpleMessage("同意"),
        "seller_auth_application_agreement_close":
            MessageLookupByLibrary.simpleMessage("关闭"),
        "seller_auth_application_agreement_content":
            MessageLookupByLibrary.simpleMessage(
                "本协议是您与DSKK平台之间关于认证服务的法律协议。请您仔细阅读以下条款，确保完全理解本协议中的所有权利和义务。\n\n一、服务内容\nDSKK平台提供认证服务，旨在验证您提供的身份、资质等信息的真实性，提高您在平台上的可信度。\n\n二、用户义务\n1. 您应当提供真实、准确、完整的认证信息和材料。\n2. 您应当确保提供的认证材料不侵犯任何第三方的合法权益。\n\n三、平台权利与义务\n1. 平台有权对您提供的认证信息和材料进行审核。\n2. 平台将在合理的时间内完成审核，并告知您审核结果。"),
        "seller_auth_application_agreement_guarantee":
            MessageLookupByLibrary.simpleMessage("，保证所提供的信息真实有效"),
        "seller_auth_application_agreement_link":
            MessageLookupByLibrary.simpleMessage("《认证服务协议》"),
        "seller_auth_application_agreement_read":
            MessageLookupByLibrary.simpleMessage("我已阅读并同意"),
        "seller_auth_application_agreement_title":
            MessageLookupByLibrary.simpleMessage("认证服务协议"),
        "seller_auth_application_auth_description":
            MessageLookupByLibrary.simpleMessage("认证描述"),
        "seller_auth_application_auth_description_hint":
            MessageLookupByLibrary.simpleMessage("请描述认证内容"),
        "seller_auth_application_auth_identifier":
            MessageLookupByLibrary.simpleMessage("认证标识"),
        "seller_auth_application_auth_identifier_hint":
            MessageLookupByLibrary.simpleMessage("请输入认证标识或编号"),
        "seller_auth_application_auth_name":
            MessageLookupByLibrary.simpleMessage("认证名称"),
        "seller_auth_application_auth_name_hint":
            MessageLookupByLibrary.simpleMessage("请输入认证名称"),
        "seller_auth_application_auth_name_required":
            MessageLookupByLibrary.simpleMessage("请输入认证名称"),
        "seller_auth_application_basic_info":
            MessageLookupByLibrary.simpleMessage("基本信息"),
        "seller_auth_application_cert_number":
            MessageLookupByLibrary.simpleMessage("证书编号"),
        "seller_auth_application_cert_number_hint":
            MessageLookupByLibrary.simpleMessage("请输入职业资格证书编号"),
        "seller_auth_application_check_form":
            MessageLookupByLibrary.simpleMessage("请检查表单填写是否正确"),
        "seller_auth_application_company_intro":
            MessageLookupByLibrary.simpleMessage("企业简介"),
        "seller_auth_application_company_intro_hint":
            MessageLookupByLibrary.simpleMessage("请简要描述公司业务和情况"),
        "seller_auth_application_company_name":
            MessageLookupByLibrary.simpleMessage("公司名称"),
        "seller_auth_application_company_name_hint":
            MessageLookupByLibrary.simpleMessage("请输入公司全称"),
        "seller_auth_application_company_name_required":
            MessageLookupByLibrary.simpleMessage("请输入公司名称"),
        "seller_auth_application_company_upload_hint":
            MessageLookupByLibrary.simpleMessage("请上传营业执照、组织机构代码证等企业资质证明材料"),
        "seller_auth_application_credit_code":
            MessageLookupByLibrary.simpleMessage("统一社会信用代码"),
        "seller_auth_application_credit_code_hint":
            MessageLookupByLibrary.simpleMessage("请输入18位统一社会信用代码"),
        "seller_auth_application_credit_code_invalid":
            MessageLookupByLibrary.simpleMessage("统一社会信用代码应为18位"),
        "seller_auth_application_credit_code_required":
            MessageLookupByLibrary.simpleMessage("请输入统一社会信用代码"),
        "seller_auth_application_default_upload_hint":
            MessageLookupByLibrary.simpleMessage("请上传相关证明材料，确保图片清晰、信息完整"),
        "seller_auth_application_degree":
            MessageLookupByLibrary.simpleMessage("学历/学位"),
        "seller_auth_application_degree_hint":
            MessageLookupByLibrary.simpleMessage("如：本科、硕士等"),
        "seller_auth_application_degree_required":
            MessageLookupByLibrary.simpleMessage("请输入学历/学位"),
        "seller_auth_application_desc": m38,
        "seller_auth_application_education_upload_hint":
            MessageLookupByLibrary.simpleMessage("请上传学历证书、学位证书等证明材料，需包含完整信息"),
        "seller_auth_application_id_number":
            MessageLookupByLibrary.simpleMessage("身份证号码"),
        "seller_auth_application_id_number_hint":
            MessageLookupByLibrary.simpleMessage("请输入18位身份证号码"),
        "seller_auth_application_id_number_invalid":
            MessageLookupByLibrary.simpleMessage("身份证号码应为18位"),
        "seller_auth_application_id_number_required":
            MessageLookupByLibrary.simpleMessage("请输入身份证号码"),
        "seller_auth_application_id_upload_hint":
            MessageLookupByLibrary.simpleMessage(
                "请上传清晰的身份证正反面照片，确保信息清晰可见，不得遮挡、涂改"),
        "seller_auth_application_load_failed":
            MessageLookupByLibrary.simpleMessage("加载失败"),
        "seller_auth_application_major":
            MessageLookupByLibrary.simpleMessage("专业"),
        "seller_auth_application_major_hint":
            MessageLookupByLibrary.simpleMessage("请输入专业名称"),
        "seller_auth_application_ok":
            MessageLookupByLibrary.simpleMessage("确定"),
        "seller_auth_application_profession":
            MessageLookupByLibrary.simpleMessage("职业/职位"),
        "seller_auth_application_profession_hint":
            MessageLookupByLibrary.simpleMessage("请输入您的职业或职位"),
        "seller_auth_application_profession_required":
            MessageLookupByLibrary.simpleMessage("请输入职业/职位"),
        "seller_auth_application_profession_upload_hint":
            MessageLookupByLibrary.simpleMessage("请上传职业资格证书、专业技能证书等证明材料"),
        "seller_auth_application_real_name":
            MessageLookupByLibrary.simpleMessage("姓名"),
        "seller_auth_application_real_name_hint":
            MessageLookupByLibrary.simpleMessage("请输入您的真实姓名"),
        "seller_auth_application_real_name_required":
            MessageLookupByLibrary.simpleMessage("请输入姓名"),
        "seller_auth_application_review_time":
            MessageLookupByLibrary.simpleMessage("认证审核通常需要1-3个工作日，请耐心等待。"),
        "seller_auth_application_school_name":
            MessageLookupByLibrary.simpleMessage("学校名称"),
        "seller_auth_application_school_name_hint":
            MessageLookupByLibrary.simpleMessage("请输入学校全称"),
        "seller_auth_application_school_name_required":
            MessageLookupByLibrary.simpleMessage("请输入学校名称"),
        "seller_auth_application_select_file_failed": m39,
        "seller_auth_application_selected_files": m40,
        "seller_auth_application_selected_images":
            MessageLookupByLibrary.simpleMessage("已选择的图片："),
        "seller_auth_application_submit":
            MessageLookupByLibrary.simpleMessage("提交认证申请"),
        "seller_auth_application_submit_success":
            MessageLookupByLibrary.simpleMessage("提交成功"),
        "seller_auth_application_submit_success_desc":
            MessageLookupByLibrary.simpleMessage(
                "您的认证申请已提交，我们将在1-3个工作日内完成审核，请耐心等待。"),
        "seller_auth_application_title": m41,
        "seller_auth_application_upload_file":
            MessageLookupByLibrary.simpleMessage("上传文件"),
        "seller_auth_application_upload_materials":
            MessageLookupByLibrary.simpleMessage("上传证明材料"),
        "seller_auth_application_work_experience":
            MessageLookupByLibrary.simpleMessage("工作经验"),
        "seller_auth_application_work_experience_hint":
            MessageLookupByLibrary.simpleMessage("请简要描述您的工作经验"),
        "seller_auth_management_back":
            MessageLookupByLibrary.simpleMessage("返回"),
        "seller_auth_management_certified":
            MessageLookupByLibrary.simpleMessage("已认证"),
        "seller_auth_management_certified_items":
            MessageLookupByLibrary.simpleMessage("已认证项目"),
        "seller_auth_management_check_connection":
            MessageLookupByLibrary.simpleMessage("• 检查网络连接状态"),
        "seller_auth_management_check_network":
            MessageLookupByLibrary.simpleMessage("• 检查网络连接是否稳定"),
        "seller_auth_management_check_wifi":
            MessageLookupByLibrary.simpleMessage("• 检查WiFi或移动数据连接"),
        "seller_auth_management_contact_support":
            MessageLookupByLibrary.simpleMessage("• 如问题持续存在，请联系客服"),
        "seller_auth_management_contact_tech":
            MessageLookupByLibrary.simpleMessage("• 如问题持续存在，请联系技术支持"),
        "seller_auth_management_loading_failed":
            MessageLookupByLibrary.simpleMessage("加载失败"),
        "seller_auth_management_network_error":
            MessageLookupByLibrary.simpleMessage("网络连接异常"),
        "seller_auth_management_network_error_desc":
            MessageLookupByLibrary.simpleMessage("无法连接到服务器，请检查网络设置"),
        "seller_auth_management_no_items":
            MessageLookupByLibrary.simpleMessage("暂无认证项目"),
        "seller_auth_management_not_submitted":
            MessageLookupByLibrary.simpleMessage("未提交"),
        "seller_auth_management_open_certification":
            MessageLookupByLibrary.simpleMessage("开放认证"),
        "seller_auth_management_pending":
            MessageLookupByLibrary.simpleMessage("审核中"),
        "seller_auth_management_rejected":
            MessageLookupByLibrary.simpleMessage("未通过"),
        "seller_auth_management_reload":
            MessageLookupByLibrary.simpleMessage("重新加载"),
        "seller_auth_management_restart_app":
            MessageLookupByLibrary.simpleMessage("• 关闭并重新打开应用"),
        "seller_auth_management_server_timeout":
            MessageLookupByLibrary.simpleMessage("服务器响应超时"),
        "seller_auth_management_server_timeout_desc":
            MessageLookupByLibrary.simpleMessage("服务器处理请求时间过长，请稍后重试"),
        "seller_auth_management_switch_network":
            MessageLookupByLibrary.simpleMessage("• 尝试切换网络环境"),
        "seller_auth_management_title":
            MessageLookupByLibrary.simpleMessage("认证管理"),
        "seller_auth_management_troubleshooting":
            MessageLookupByLibrary.simpleMessage("故障排除建议："),
        "seller_auth_management_try_later":
            MessageLookupByLibrary.simpleMessage("• 稍后重新尝试"),
        "seller_auth_management_unknown_error":
            MessageLookupByLibrary.simpleMessage("发生未知错误，请重试"),
        "seller_auth_management_unknown_status":
            MessageLookupByLibrary.simpleMessage("未知状态"),
        "seller_auth_management_wait_retry":
            MessageLookupByLibrary.simpleMessage("• 等待几分钟后重新尝试"),
        "seller_home_auth_management":
            MessageLookupByLibrary.simpleMessage("认证管理"),
        "seller_home_auto_reply": MessageLookupByLibrary.simpleMessage("自动回复"),
        "seller_home_completion_rate": m42,
        "seller_home_functions": MessageLookupByLibrary.simpleMessage("功能"),
        "seller_home_income": MessageLookupByLibrary.simpleMessage("收入"),
        "seller_home_loading_failed":
            MessageLookupByLibrary.simpleMessage("加载失败"),
        "seller_home_no_data": MessageLookupByLibrary.simpleMessage("暂无数据"),
        "seller_home_no_income_data":
            MessageLookupByLibrary.simpleMessage("暂无收入数据"),
        "seller_home_no_recent_income":
            MessageLookupByLibrary.simpleMessage("暂无近期收入数据"),
        "seller_home_no_store_info":
            MessageLookupByLibrary.simpleMessage("暂无店铺信息"),
        "seller_home_offline": MessageLookupByLibrary.simpleMessage("离线"),
        "seller_home_online": MessageLookupByLibrary.simpleMessage("在线"),
        "seller_home_orders": MessageLookupByLibrary.simpleMessage("订单"),
        "seller_home_orders_aftersales":
            MessageLookupByLibrary.simpleMessage("售后中"),
        "seller_home_orders_all": MessageLookupByLibrary.simpleMessage("全部"),
        "seller_home_orders_awaiting_delivery":
            MessageLookupByLibrary.simpleMessage("待发货"),
        "seller_home_orders_canceled":
            MessageLookupByLibrary.simpleMessage("已取消"),
        "seller_home_orders_completed":
            MessageLookupByLibrary.simpleMessage("已完成"),
        "seller_home_orders_pending":
            MessageLookupByLibrary.simpleMessage("待处理"),
        "seller_home_orders_processing":
            MessageLookupByLibrary.simpleMessage("进行中"),
        "seller_home_pending_settlement":
            MessageLookupByLibrary.simpleMessage("待结算"),
        "seller_home_recent_income":
            MessageLookupByLibrary.simpleMessage("近期收入"),
        "seller_home_switch_failed": m43,
        "seller_home_switch_to_buyer":
            MessageLookupByLibrary.simpleMessage("切换到买家模式"),
        "seller_home_time_management":
            MessageLookupByLibrary.simpleMessage("时间管理"),
        "seller_home_today_income":
            MessageLookupByLibrary.simpleMessage("今日收入"),
        "seller_home_total_income": MessageLookupByLibrary.simpleMessage("总收入"),
        "seller_home_view_all": MessageLookupByLibrary.simpleMessage("查看全部"),
        "seller_home_view_details":
            MessageLookupByLibrary.simpleMessage("查看明细"),
        "seller_home_wallet": MessageLookupByLibrary.simpleMessage("钱包"),
        "seller_profile_about_merchant":
            MessageLookupByLibrary.simpleMessage("关于商家"),
        "seller_profile_about_us": MessageLookupByLibrary.simpleMessage("关于我们"),
        "seller_profile_auth_management":
            MessageLookupByLibrary.simpleMessage("认证管理"),
        "seller_profile_buyer_mode":
            MessageLookupByLibrary.simpleMessage("买家模式"),
        "seller_profile_certification_status":
            MessageLookupByLibrary.simpleMessage("认证状态"),
        "seller_profile_certified": MessageLookupByLibrary.simpleMessage("已认证"),
        "seller_profile_chat_failed": m44,
        "seller_profile_default_title":
            MessageLookupByLibrary.simpleMessage("卖家主页"),
        "seller_profile_error_occurred": m45,
        "seller_profile_feature_not_implemented": m46,
        "seller_profile_follow": MessageLookupByLibrary.simpleMessage("关注"),
        "seller_profile_follow_success":
            MessageLookupByLibrary.simpleMessage("关注成功"),
        "seller_profile_followed": MessageLookupByLibrary.simpleMessage("已关注"),
        "seller_profile_followers": m47,
        "seller_profile_image_load_failed":
            MessageLookupByLibrary.simpleMessage("图片加载失败"),
        "seller_profile_level_two":
            MessageLookupByLibrary.simpleMessage("二级会员"),
        "seller_profile_member_level":
            MessageLookupByLibrary.simpleMessage("会员等级"),
        "seller_profile_mission":
            MessageLookupByLibrary.simpleMessage("小粽子的使命"),
        "seller_profile_my_orders":
            MessageLookupByLibrary.simpleMessage("我的订单"),
        "seller_profile_my_services":
            MessageLookupByLibrary.simpleMessage("我的服务"),
        "seller_profile_my_wallet":
            MessageLookupByLibrary.simpleMessage("我的钱包"),
        "seller_profile_no_description":
            MessageLookupByLibrary.simpleMessage("暂无简介"),
        "seller_profile_no_image": MessageLookupByLibrary.simpleMessage("暂无图片"),
        "seller_profile_no_merchant_info":
            MessageLookupByLibrary.simpleMessage("暂无商家信息"),
        "seller_profile_no_products":
            MessageLookupByLibrary.simpleMessage("暂无商品"),
        "seller_profile_not_certified":
            MessageLookupByLibrary.simpleMessage("未认证"),
        "seller_profile_notifications":
            MessageLookupByLibrary.simpleMessage("消息通知"),
        "seller_profile_order_delivered":
            MessageLookupByLibrary.simpleMessage("已交付"),
        "seller_profile_order_pending":
            MessageLookupByLibrary.simpleMessage("待确认"),
        "seller_profile_order_processing":
            MessageLookupByLibrary.simpleMessage("进行中"),
        "seller_profile_order_refund":
            MessageLookupByLibrary.simpleMessage("退款/售后"),
        "seller_profile_response_hours":
            MessageLookupByLibrary.simpleMessage("3小时"),
        "seller_profile_response_time":
            MessageLookupByLibrary.simpleMessage("回应时间"),
        "seller_profile_seller": MessageLookupByLibrary.simpleMessage("卖家"),
        "seller_profile_seller_mode":
            MessageLookupByLibrary.simpleMessage("卖家模式"),
        "seller_profile_seller_mode_online":
            MessageLookupByLibrary.simpleMessage("卖家模式：在线"),
        "seller_profile_seller_rating":
            MessageLookupByLibrary.simpleMessage("卖家评分"),
        "seller_profile_settings": MessageLookupByLibrary.simpleMessage("设置"),
        "seller_profile_time_management":
            MessageLookupByLibrary.simpleMessage("时间管理"),
        "seller_profile_title": MessageLookupByLibrary.simpleMessage("我的"),
        "seller_profile_unfollow_success":
            MessageLookupByLibrary.simpleMessage("取消关注成功"),
        "seller_profile_user_name": MessageLookupByLibrary.simpleMessage("瑞"),
        "seller_statistics_active_orders":
            MessageLookupByLibrary.simpleMessage("活跃订单数"),
        "seller_statistics_become_level3_seller": m48,
        "seller_statistics_complete_orders": m49,
        "seller_statistics_completion_rate":
            MessageLookupByLibrary.simpleMessage("完成率"),
        "seller_statistics_earliest":
            MessageLookupByLibrary.simpleMessage("最早"),
        "seller_statistics_heat_value":
            MessageLookupByLibrary.simpleMessage("热度值"),
        "seller_statistics_incomplete_orders":
            MessageLookupByLibrary.simpleMessage("未完成订单数"),
        "seller_statistics_indicators":
            MessageLookupByLibrary.simpleMessage("指标"),
        "seller_statistics_loading_failed": m50,
        "seller_statistics_monthly_earnings":
            MessageLookupByLibrary.simpleMessage("本月盈利"),
        "seller_statistics_next_delivery_date":
            MessageLookupByLibrary.simpleMessage("距离下次邀交日"),
        "seller_statistics_pending":
            MessageLookupByLibrary.simpleMessage("待处理"),
        "seller_statistics_pending_completion":
            MessageLookupByLibrary.simpleMessage("待完成"),
        "seller_statistics_positive_rate":
            MessageLookupByLibrary.simpleMessage("好评率"),
        "seller_statistics_profit_amount": m51,
        "seller_statistics_receipt": MessageLookupByLibrary.simpleMessage("回单"),
        "seller_statistics_reply_rate":
            MessageLookupByLibrary.simpleMessage("回复率"),
        "seller_statistics_retry": MessageLookupByLibrary.simpleMessage("重试"),
        "seller_statistics_seller_homepage":
            MessageLookupByLibrary.simpleMessage("卖家主页"),
        "seller_statistics_title": MessageLookupByLibrary.simpleMessage("卖家数据"),
        "seller_statistics_total_earnings":
            MessageLookupByLibrary.simpleMessage("总盈利"),
        "seller_statistics_total_orders":
            MessageLookupByLibrary.simpleMessage("总订单数"),
        "seller_statistics_upgrade_to_next_level":
            MessageLookupByLibrary.simpleMessage("升到下一级"),
        "storagePermissionDenied":
            MessageLookupByLibrary.simpleMessage("存储权限被拒绝"),
        "storagePermissionRequired":
            MessageLookupByLibrary.simpleMessage("需要存储权限才能下载文件"),
        "system_language": MessageLookupByLibrary.simpleMessage("跟随系统"),
        "system_language_description":
            MessageLookupByLibrary.simpleMessage("自动使用设备的语言设置"),
        "tapToOpen": MessageLookupByLibrary.simpleMessage("点击打开"),
        "tapToPreview": MessageLookupByLibrary.simpleMessage("点击预览"),
        "time_management_current_status":
            MessageLookupByLibrary.simpleMessage("当前状态"),
        "time_management_load_failed":
            MessageLookupByLibrary.simpleMessage("加载失败"),
        "time_management_offline": MessageLookupByLibrary.simpleMessage("离线"),
        "time_management_offline_description": MessageLookupByLibrary.simpleMessage(
            "您当前处于离线状态，买家仍然可以向您发送消息，但系统会告知买家您暂时不在线。您仍然会收到新消息的通知，但可能无法立即回复。长时间保持离线状态可能会影响您的接单效率。"),
        "time_management_offline_status_description":
            MessageLookupByLibrary.simpleMessage("离线状态说明"),
        "time_management_online": MessageLookupByLibrary.simpleMessage("在线"),
        "time_management_online_description": MessageLookupByLibrary.simpleMessage(
            "您当前处于在线状态，买家可以向您发送消息，您将收到新消息的通知。请确保及时回复买家消息，保持良好的响应率有助于提高您的服务质量评分。"),
        "time_management_online_status_description":
            MessageLookupByLibrary.simpleMessage("在线状态说明"),
        "time_management_retry": MessageLookupByLibrary.simpleMessage("重试"),
        "time_management_save_settings":
            MessageLookupByLibrary.simpleMessage("保存设置"),
        "time_management_settings_saved":
            MessageLookupByLibrary.simpleMessage("设置已保存"),
        "time_management_title": MessageLookupByLibrary.simpleMessage("时间管理"),
        "time_management_unknown_status":
            MessageLookupByLibrary.simpleMessage("未知状态")
      };
}
