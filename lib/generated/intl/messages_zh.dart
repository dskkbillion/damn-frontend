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

  static String m15(price) => "一键购买 ¥${price}";

  static String m16(error) => "加载失败: ${error}";

  static String m17(count) => "评论(${count})";

  static String m18(count) => "${count}天前";

  static String m19(count) => "${count}小时前";

  static String m20(error) => "加载失败: ${error}";

  static String m21(count) => "${count}分钟前";

  static String m22(count) => "${count}月前";

  static String m23(count) => "${count}年前";

  static String m24(error) => "加载失败: ${error}";

  static String m25(error) => "无法导航到订单列表: ${error}";

  static String m26(error) => "无法切换到卖家模式: ${error}";

  static String m27(error) => "搜索失败: ${error}";

  static String m28(rate) => "完成率 ${rate}%";

  static String m29(error) => "无法切换到买家模式: ${error}";

  static String m30(error) => "创建聊天失败: ${error}";

  static String m31(error) => "发生错误: ${error}";

  static String m32(feature) => "${feature}功能尚未实现";

  static String m33(count) => "${count}粉丝";

  static String m34(days) => "成为三级会员卖家${days}天";

  static String m35(orderNum) => "完成订单${orderNum}笔";

  static String m36(error) => "加载失败: ${error}";

  static String m37(amount) => "盈利${amount}元";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "ai_docs_add_image": MessageLookupByLibrary.simpleMessage("添加图片"),
    "ai_docs_assistant_title": MessageLookupByLibrary.simpleMessage("AI 助手"),
    "ai_docs_auto_create_text": MessageLookupByLibrary.simpleMessage(
      "没有选择对话，自动创建新对话并发送消息",
    ),
    "ai_docs_auto_create_voice": MessageLookupByLibrary.simpleMessage(
      "没有选择对话，自动创建新对话并发送语音消息",
    ),
    "ai_docs_cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "ai_docs_cancelling_generation": MessageLookupByLibrary.simpleMessage(
      "正在取消生成中...",
    ),
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
    "ai_docs_edit_title": MessageLookupByLibrary.simpleMessage("编辑标题"),
    "ai_docs_edit_title_hint": MessageLookupByLibrary.simpleMessage("请输入新的标题"),
    "ai_docs_enter_chat": MessageLookupByLibrary.simpleMessage("进入聊天"),
    "ai_docs_enter_message": MessageLookupByLibrary.simpleMessage("输入消息..."),
    "ai_docs_generate_title": MessageLookupByLibrary.simpleMessage("AI生成标题"),
    "ai_docs_generate_title_tooltip": MessageLookupByLibrary.simpleMessage(
      "让AI为这个会话生成一个标题",
    ),
    "ai_docs_generating_title": MessageLookupByLibrary.simpleMessage(
      "正在生成标题...",
    ),
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
    "ai_docs_title_empty": MessageLookupByLibrary.simpleMessage("标题不能为空"),
    "ai_docs_title_generated": MessageLookupByLibrary.simpleMessage("标题已生成"),
    "ai_docs_title_generation_failed": m4,
    "ai_docs_title_too_long": MessageLookupByLibrary.simpleMessage(
      "标题长度不能超过50个字符",
    ),
    "ai_docs_title_update_failed": m5,
    "ai_docs_title_updated": MessageLookupByLibrary.simpleMessage("标题已更新"),
    "ai_docs_unnamed_conversation": MessageLookupByLibrary.simpleMessage(
      "未命名会话",
    ),
    "ai_docs_uploading_images": MessageLookupByLibrary.simpleMessage(
      "图片正在上传中，请稍候...",
    ),
    "ai_docs_welcome_message": MessageLookupByLibrary.simpleMessage(
      "直接发送消息即可开始对话，系统会自动为您创建聊天室",
    ),
    "ai_docs_welcome_title": MessageLookupByLibrary.simpleMessage("欢迎使用AI助手"),
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
    "chat_error_loading": m6,
    "chat_expand": MessageLookupByLibrary.simpleMessage("展开"),
    "chat_i_want_seller_to_see": MessageLookupByLibrary.simpleMessage(
      "我想让商家看看",
    ),
    "chat_image_message": MessageLookupByLibrary.simpleMessage("[图片]"),
    "chat_image_picking_error": m7,
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
    "chat_recording_error": m8,
    "chat_release_to_send": m9,
    "chat_revoked_message": MessageLookupByLibrary.simpleMessage("[消息已撤回]"),
    "chat_send": MessageLookupByLibrary.simpleMessage("发送"),
    "chat_send_markdown": MessageLookupByLibrary.simpleMessage("发送Markdown示例"),
    "chat_stop_recording_error": m10,
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
    "home_banner_clicked": m11,
    "home_end_of_list": MessageLookupByLibrary.simpleMessage("已经到底了"),
    "home_loading": MessageLookupByLibrary.simpleMessage("加载中..."),
    "home_loading_failed": m12,
    "home_product_card_clicked": m13,
    "home_recommend_clicked": m14,
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
    "product_detail_basic_package": MessageLookupByLibrary.simpleMessage("基础"),
    "product_detail_basic_tier": MessageLookupByLibrary.simpleMessage("基础"),
    "product_detail_buy_now": MessageLookupByLibrary.simpleMessage("一键购买(1)"),
    "product_detail_buy_now_with_price": m15,
    "product_detail_case_showcase": MessageLookupByLibrary.simpleMessage(
      "案例展示",
    ),
    "product_detail_collapse": MessageLookupByLibrary.simpleMessage("收起"),
    "product_detail_contact_seller": MessageLookupByLibrary.simpleMessage(
      "咨询卖家",
    ),
    "product_detail_delivery_period": MessageLookupByLibrary.simpleMessage(
      "交付周期",
    ),
    "product_detail_delivery_times": MessageLookupByLibrary.simpleMessage(
      "交付次数",
    ),
    "product_detail_faq": MessageLookupByLibrary.simpleMessage("常见问题"),
    "product_detail_loading_failed": m16,
    "product_detail_more": MessageLookupByLibrary.simpleMessage("更多"),
    "product_detail_no_cases": MessageLookupByLibrary.simpleMessage("暂无案例展示"),
    "product_detail_no_reviews": MessageLookupByLibrary.simpleMessage("暂无评价"),
    "product_detail_please_wait": MessageLookupByLibrary.simpleMessage(
      "请稍等...",
    ),
    "product_detail_premium_package": MessageLookupByLibrary.simpleMessage(
      "豪华",
    ),
    "product_detail_premium_tier": MessageLookupByLibrary.simpleMessage("豪华"),
    "product_detail_published_status": MessageLookupByLibrary.simpleMessage(
      "已发布",
    ),
    "product_detail_retry": MessageLookupByLibrary.simpleMessage("重试"),
    "product_detail_reviews": m17,
    "product_detail_sample_review": MessageLookupByLibrary.simpleMessage(
      "不错，很有耐心",
    ),
    "product_detail_sample_user": MessageLookupByLibrary.simpleMessage("瑞123"),
    "product_detail_standard_package": MessageLookupByLibrary.simpleMessage(
      "标准",
    ),
    "product_detail_standard_tier": MessageLookupByLibrary.simpleMessage("标准"),
    "product_detail_verified_label": MessageLookupByLibrary.simpleMessage(
      "已认证",
    ),
    "product_detail_view_all": MessageLookupByLibrary.simpleMessage("查看全部"),
    "product_image_loading_failed": MessageLookupByLibrary.simpleMessage(
      "图片加载失败",
    ),
    "product_recommend_button": MessageLookupByLibrary.simpleMessage("让ta看看"),
    "product_reviews_days_ago": m18,
    "product_reviews_hours_ago": m19,
    "product_reviews_just_now": MessageLookupByLibrary.simpleMessage("刚刚"),
    "product_reviews_loading_failed": m20,
    "product_reviews_minutes_ago": m21,
    "product_reviews_months_ago": m22,
    "product_reviews_no_reviews": MessageLookupByLibrary.simpleMessage("暂无评论"),
    "product_reviews_retry": MessageLookupByLibrary.simpleMessage("重试"),
    "product_reviews_sample_content": MessageLookupByLibrary.simpleMessage(
      "不错，很有耐心",
    ),
    "product_reviews_title": MessageLookupByLibrary.simpleMessage("评论"),
    "product_reviews_years_ago": m23,
    "profile_about_us": MessageLookupByLibrary.simpleMessage("关于我们"),
    "profile_account_security": MessageLookupByLibrary.simpleMessage("账号与安全"),
    "profile_assistant_mission": MessageLookupByLibrary.simpleMessage("小帮手的使命"),
    "profile_avatar_upload_failed": MessageLookupByLibrary.simpleMessage(
      "头像上传失败，请重试",
    ),
    "profile_cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "profile_completed": MessageLookupByLibrary.simpleMessage("完成"),
    "profile_default_name": MessageLookupByLibrary.simpleMessage("用户"),
    "profile_edit_nickname": MessageLookupByLibrary.simpleMessage("修改昵称"),
    "profile_favorites": MessageLookupByLibrary.simpleMessage("收藏"),
    "profile_in_progress": MessageLookupByLibrary.simpleMessage("处理中"),
    "profile_loading_error": m24,
    "profile_login_button": MessageLookupByLibrary.simpleMessage("去登录"),
    "profile_login_prompt": MessageLookupByLibrary.simpleMessage(
      "请登录以查看您的个人资料",
    ),
    "profile_message_notifications": MessageLookupByLibrary.simpleMessage(
      "消息通知",
    ),
    "profile_my_dskk": MessageLookupByLibrary.simpleMessage("我的多看"),
    "profile_my_wallet": MessageLookupByLibrary.simpleMessage("我的钱包"),
    "profile_navigation_error": m25,
    "profile_nickname_hint": MessageLookupByLibrary.simpleMessage("请输入新昵称"),
    "profile_offline": MessageLookupByLibrary.simpleMessage("离线"),
    "profile_online": MessageLookupByLibrary.simpleMessage("在线"),
    "profile_orders": MessageLookupByLibrary.simpleMessage("我的订单"),
    "profile_pending_payment": MessageLookupByLibrary.simpleMessage("待付"),
    "profile_personal_center": MessageLookupByLibrary.simpleMessage("个人中心"),
    "profile_refund": MessageLookupByLibrary.simpleMessage("售后"),
    "profile_save": MessageLookupByLibrary.simpleMessage("保存"),
    "profile_settings": MessageLookupByLibrary.simpleMessage("设置"),
    "profile_switch_error": m26,
    "profile_switch_to_seller": MessageLookupByLibrary.simpleMessage("切换到卖家模式"),
    "profile_wallet": MessageLookupByLibrary.simpleMessage("钱包"),
    "search_button": MessageLookupByLibrary.simpleMessage("搜索"),
    "search_failed": m27,
    "search_history": MessageLookupByLibrary.simpleMessage("搜索历史"),
    "search_hot_keywords": MessageLookupByLibrary.simpleMessage("热搜榜"),
    "search_no_results": MessageLookupByLibrary.simpleMessage("没有找到相关的服务"),
    "search_title": MessageLookupByLibrary.simpleMessage("搜索"),
    "seller_home_auth_management": MessageLookupByLibrary.simpleMessage("认证管理"),
    "seller_home_auto_reply": MessageLookupByLibrary.simpleMessage("自动回复"),
    "seller_home_completion_rate": m28,
    "seller_home_functions": MessageLookupByLibrary.simpleMessage("功能"),
    "seller_home_income": MessageLookupByLibrary.simpleMessage("收入"),
    "seller_home_loading_failed": MessageLookupByLibrary.simpleMessage("加载失败"),
    "seller_home_no_data": MessageLookupByLibrary.simpleMessage("暂无数据"),
    "seller_home_no_income_data": MessageLookupByLibrary.simpleMessage(
      "暂无收入数据",
    ),
    "seller_home_no_recent_income": MessageLookupByLibrary.simpleMessage(
      "暂无近期收入数据",
    ),
    "seller_home_no_store_info": MessageLookupByLibrary.simpleMessage("暂无店铺信息"),
    "seller_home_offline": MessageLookupByLibrary.simpleMessage("离线"),
    "seller_home_online": MessageLookupByLibrary.simpleMessage("在线"),
    "seller_home_orders": MessageLookupByLibrary.simpleMessage("订单"),
    "seller_home_orders_aftersales": MessageLookupByLibrary.simpleMessage(
      "售后中",
    ),
    "seller_home_orders_all": MessageLookupByLibrary.simpleMessage("全部"),
    "seller_home_orders_awaiting_delivery":
        MessageLookupByLibrary.simpleMessage("待发货"),
    "seller_home_orders_canceled": MessageLookupByLibrary.simpleMessage("已取消"),
    "seller_home_orders_completed": MessageLookupByLibrary.simpleMessage("已完成"),
    "seller_home_orders_pending": MessageLookupByLibrary.simpleMessage("待处理"),
    "seller_home_orders_processing": MessageLookupByLibrary.simpleMessage(
      "进行中",
    ),
    "seller_home_pending_settlement": MessageLookupByLibrary.simpleMessage(
      "待结算",
    ),
    "seller_home_recent_income": MessageLookupByLibrary.simpleMessage("近期收入"),
    "seller_home_switch_failed": m29,
    "seller_home_switch_to_buyer": MessageLookupByLibrary.simpleMessage(
      "切换到买家模式",
    ),
    "seller_home_time_management": MessageLookupByLibrary.simpleMessage("时间管理"),
    "seller_home_today_income": MessageLookupByLibrary.simpleMessage("今日收入"),
    "seller_home_total_income": MessageLookupByLibrary.simpleMessage("总收入"),
    "seller_home_view_all": MessageLookupByLibrary.simpleMessage("查看全部"),
    "seller_home_view_details": MessageLookupByLibrary.simpleMessage("查看明细"),
    "seller_home_wallet": MessageLookupByLibrary.simpleMessage("钱包"),
    "seller_profile_about_merchant": MessageLookupByLibrary.simpleMessage(
      "关于商家",
    ),
    "seller_profile_about_us": MessageLookupByLibrary.simpleMessage("关于我们"),
    "seller_profile_auth_management": MessageLookupByLibrary.simpleMessage(
      "认证管理",
    ),
    "seller_profile_buyer_mode": MessageLookupByLibrary.simpleMessage("买家模式"),
    "seller_profile_certification_status": MessageLookupByLibrary.simpleMessage(
      "认证状态",
    ),
    "seller_profile_certified": MessageLookupByLibrary.simpleMessage("已认证"),
    "seller_profile_chat_failed": m30,
    "seller_profile_default_title": MessageLookupByLibrary.simpleMessage(
      "卖家主页",
    ),
    "seller_profile_error_occurred": m31,
    "seller_profile_feature_not_implemented": m32,
    "seller_profile_follow": MessageLookupByLibrary.simpleMessage("关注"),
    "seller_profile_follow_success": MessageLookupByLibrary.simpleMessage(
      "关注成功",
    ),
    "seller_profile_followed": MessageLookupByLibrary.simpleMessage("已关注"),
    "seller_profile_followers": m33,
    "seller_profile_image_load_failed": MessageLookupByLibrary.simpleMessage(
      "图片加载失败",
    ),
    "seller_profile_level_two": MessageLookupByLibrary.simpleMessage("二级会员"),
    "seller_profile_member_level": MessageLookupByLibrary.simpleMessage("会员等级"),
    "seller_profile_mission": MessageLookupByLibrary.simpleMessage("小粽子的使命"),
    "seller_profile_my_orders": MessageLookupByLibrary.simpleMessage("我的订单"),
    "seller_profile_my_services": MessageLookupByLibrary.simpleMessage("我的服务"),
    "seller_profile_my_wallet": MessageLookupByLibrary.simpleMessage("我的钱包"),
    "seller_profile_no_description": MessageLookupByLibrary.simpleMessage(
      "暂无简介",
    ),
    "seller_profile_no_image": MessageLookupByLibrary.simpleMessage("暂无图片"),
    "seller_profile_no_merchant_info": MessageLookupByLibrary.simpleMessage(
      "暂无商家信息",
    ),
    "seller_profile_no_products": MessageLookupByLibrary.simpleMessage("暂无商品"),
    "seller_profile_not_certified": MessageLookupByLibrary.simpleMessage("未认证"),
    "seller_profile_notifications": MessageLookupByLibrary.simpleMessage(
      "消息通知",
    ),
    "seller_profile_order_delivered": MessageLookupByLibrary.simpleMessage(
      "已交付",
    ),
    "seller_profile_order_pending": MessageLookupByLibrary.simpleMessage("待确认"),
    "seller_profile_order_processing": MessageLookupByLibrary.simpleMessage(
      "进行中",
    ),
    "seller_profile_order_refund": MessageLookupByLibrary.simpleMessage(
      "退款/售后",
    ),
    "seller_profile_response_hours": MessageLookupByLibrary.simpleMessage(
      "3小时",
    ),
    "seller_profile_response_time": MessageLookupByLibrary.simpleMessage(
      "回应时间",
    ),
    "seller_profile_seller": MessageLookupByLibrary.simpleMessage("卖家"),
    "seller_profile_seller_mode": MessageLookupByLibrary.simpleMessage("卖家模式"),
    "seller_profile_seller_mode_online": MessageLookupByLibrary.simpleMessage(
      "卖家模式：在线",
    ),
    "seller_profile_seller_rating": MessageLookupByLibrary.simpleMessage(
      "卖家评分",
    ),
    "seller_profile_settings": MessageLookupByLibrary.simpleMessage("设置"),
    "seller_profile_time_management": MessageLookupByLibrary.simpleMessage(
      "时间管理",
    ),
    "seller_profile_title": MessageLookupByLibrary.simpleMessage("我的"),
    "seller_profile_unfollow_success": MessageLookupByLibrary.simpleMessage(
      "取消关注成功",
    ),
    "seller_profile_user_name": MessageLookupByLibrary.simpleMessage("瑞"),
    "seller_statistics_active_orders": MessageLookupByLibrary.simpleMessage(
      "活跃订单数",
    ),
    "seller_statistics_become_level3_seller": m34,
    "seller_statistics_complete_orders": m35,
    "seller_statistics_completion_rate": MessageLookupByLibrary.simpleMessage(
      "完成率",
    ),
    "seller_statistics_earliest": MessageLookupByLibrary.simpleMessage("最早"),
    "seller_statistics_heat_value": MessageLookupByLibrary.simpleMessage("热度值"),
    "seller_statistics_incomplete_orders": MessageLookupByLibrary.simpleMessage(
      "未完成订单数",
    ),
    "seller_statistics_indicators": MessageLookupByLibrary.simpleMessage("指标"),
    "seller_statistics_loading_failed": m36,
    "seller_statistics_monthly_earnings": MessageLookupByLibrary.simpleMessage(
      "本月盈利",
    ),
    "seller_statistics_next_delivery_date":
        MessageLookupByLibrary.simpleMessage("距离下次邀交日"),
    "seller_statistics_pending": MessageLookupByLibrary.simpleMessage("待处理"),
    "seller_statistics_pending_completion":
        MessageLookupByLibrary.simpleMessage("待完成"),
    "seller_statistics_positive_rate": MessageLookupByLibrary.simpleMessage(
      "好评率",
    ),
    "seller_statistics_profit_amount": m37,
    "seller_statistics_receipt": MessageLookupByLibrary.simpleMessage("回单"),
    "seller_statistics_reply_rate": MessageLookupByLibrary.simpleMessage("回复率"),
    "seller_statistics_retry": MessageLookupByLibrary.simpleMessage("重试"),
    "seller_statistics_seller_homepage": MessageLookupByLibrary.simpleMessage(
      "卖家主页",
    ),
    "seller_statistics_title": MessageLookupByLibrary.simpleMessage("卖家数据"),
    "seller_statistics_total_earnings": MessageLookupByLibrary.simpleMessage(
      "总盈利",
    ),
    "seller_statistics_total_orders": MessageLookupByLibrary.simpleMessage(
      "总订单数",
    ),
    "seller_statistics_upgrade_to_next_level":
        MessageLookupByLibrary.simpleMessage("升到下一级"),
    "system_language": MessageLookupByLibrary.simpleMessage("跟随系统"),
    "system_language_description": MessageLookupByLibrary.simpleMessage(
      "自动使用设备的语言设置",
    ),
  };
}
