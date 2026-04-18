// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get language_settings => '语言设置';

  @override
  String get system_language => '跟随系统';

  @override
  String get system_language_description => '自动使用设备的语言设置';

  @override
  String get ai_docs_assistant_title => 'AI 助手';

  @override
  String get ai_docs_unnamed_conversation => '未命名会话';

  @override
  String get ai_docs_loading => '加载中...';

  @override
  String get ai_docs_match_button => '匹配';

  @override
  String get ai_docs_select_conversation_first => '请先选择一个会话';

  @override
  String get ai_docs_please_enter_message => '请输入消息内容';

  @override
  String get ai_docs_recommended_services => '推荐服务';

  @override
  String ai_docs_recommendations_error(String error) {
    return '加载推荐服务失败: $error';
  }

  @override
  String get ai_docs_no_recommendations => '暂无推荐服务';

  @override
  String get ai_docs_dispatched => '已分发';

  @override
  String get ai_docs_enter_chat => '进入聊天';

  @override
  String get ai_docs_let_them_see => '让ta看看';

  @override
  String get ai_docs_welcome_title => '欢迎使用AI助手';

  @override
  String get ai_docs_welcome_message => '直接发送消息即可开始对话，系统会自动为您创建聊天室';

  @override
  String get ai_docs_auto_create_text => '没有选择对话，自动创建新对话并发送消息';

  @override
  String get ai_docs_auto_create_voice => '没有选择对话，自动创建新对话并发送语音消息';

  @override
  String get ai_docs_cancelling_generation => '正在取消生成中...';

  @override
  String get allocating_step1 => '分发中';

  @override
  String get allocating_step2 => '分发中.';

  @override
  String get allocating_step3 => '分发中..';

  @override
  String get allocating_step4 => '分发中...';

  @override
  String get ai_docs_add_image => '添加图片';

  @override
  String get ai_docs_stop_recording => '停止录音';

  @override
  String get ai_docs_start_recording => '录制语音';

  @override
  String get ai_docs_recording => '正在录音...点击停止发送';

  @override
  String get ai_docs_enter_message => '输入消息...';

  @override
  String get ai_docs_stop_generation => '停止生成';

  @override
  String get ai_docs_send_message => '发送消息';

  @override
  String get ai_docs_uploading_images => '图片正在上传中，请稍候...';

  @override
  String get ai_docs_mic_permission_denied => '麦克风权限被拒绝';

  @override
  String ai_docs_recording_error(String error) {
    return '开始录音出错: $error';
  }

  @override
  String get ai_docs_recording_file_not_found => '错误：未找到录音文件';

  @override
  String get ai_docs_stop_recording_error => '停止录音出错';

  @override
  String ai_docs_stop_recording_error_with_reason(String error) {
    return '停止录音出错: $error';
  }

  @override
  String ai_docs_image_picking_error(String error) {
    return '选择图片出错: $error';
  }

  @override
  String get ai_docs_conversation_list => '会话列表';

  @override
  String get ai_docs_no_messages => '暂无消息，开始聊天吧！';

  @override
  String get ai_docs_new_chat => '新建聊天';

  @override
  String get ai_docs_load_conversations_failed => '加载会话失败';

  @override
  String get ai_docs_retry => '重试';

  @override
  String get ai_docs_no_conversations => '暂无会话';

  @override
  String get ai_docs_delete_conversation_tooltip => '删除会话';

  @override
  String get ai_docs_delete_conversation_title => '删除会话？';

  @override
  String get ai_docs_delete_conversation_content => '确定要永久删除此会话吗？';

  @override
  String get ai_docs_cancel => '取消';

  @override
  String get ai_docs_delete => '删除';

  @override
  String get ai_docs_please_select_conversation_to_delete => '请先选择要删除的会话';

  @override
  String get ai_docs_generate_title => 'AI生成标题';

  @override
  String get ai_docs_generate_title_tooltip => '让AI为这个会话生成一个标题';

  @override
  String get ai_docs_generating_title => '正在生成标题...';

  @override
  String get ai_docs_title_generated => '标题已生成';

  @override
  String ai_docs_title_generation_failed(String error) {
    return '标题生成失败: $error';
  }

  @override
  String get ai_docs_edit_title => '编辑标题';

  @override
  String get ai_docs_edit_title_hint => '请输入新的标题';

  @override
  String get ai_docs_title_updated => '标题已更新';

  @override
  String ai_docs_title_update_failed(String error) {
    return '标题更新失败: $error';
  }

  @override
  String get ai_docs_title_too_long => '标题长度不能超过50个字符';

  @override
  String get ai_docs_title_empty => '标题不能为空';

  @override
  String get nav_ai_assistant => '看看';

  @override
  String get nav_home => '逛逛';

  @override
  String get nav_messages => '聊聊';

  @override
  String get nav_profile => '我的';

  @override
  String get nav_dev => '开发';

  @override
  String get nav_seller_analytics => '数据';

  @override
  String get nav_seller_products => '商品';

  @override
  String get nav_seller_messages => '消息';

  @override
  String get nav_seller_profile => '我的';

  @override
  String get chat_list_title => '聊天列表';

  @override
  String get chat_loading => '正在加载...';

  @override
  String chat_error_loading(String error) {
    return '加载失败: $error';
  }

  @override
  String get chat_no_messages => '暂无消息，开始聊天吧！';

  @override
  String get chat_admin_title => '系统管理员';

  @override
  String get chat_notification_center => '通知中心';

  @override
  String get chat_notification_description => '系统、订单、评价等重要通知';

  @override
  String get chat_enter_message => '输入消息...';

  @override
  String get chat_yesterday => '昨天';

  @override
  String get chat_image_message => '【图片】';

  @override
  String get chat_audio_message => '【语音】';

  @override
  String get chat_file_message => '【文件】';

  @override
  String get chat_allocate_message => '【多少看看】';

  @override
  String get chat_payment_prompt_message => '【付费提示】';

  @override
  String get chat_revoked_message => '[消息已撤回]';

  @override
  String get chat_unknown_message => '[未知消息]';

  @override
  String get chat_unknown_user => '未知用户';

  @override
  String get chat_invalid_session => '无效的会话';

  @override
  String get chat_opponent_not_found => '无法找到对方信息';

  @override
  String get chat_message_recalled => '消息已撤回';

  @override
  String get chat_copy => '复制';

  @override
  String get chat_recall => '撤回';

  @override
  String get chat_copied_to_clipboard => '已复制到剪贴板';

  @override
  String get chat_me => '我';

  @override
  String get chat_buyer => '买家';

  @override
  String get chat_i_want_seller_to_see => '我想看看';

  @override
  String get chat_wants_to_see => '想看看';

  @override
  String get chat_collapse => '收起';

  @override
  String get chat_expand => '展开';

  @override
  String get chat_admin_connection_error => '无法连接到系统管理员';

  @override
  String get chat_audio_pause => '暂停';

  @override
  String get chat_audio_play => '播放';

  @override
  String get chat_markdown_example_title1 => '这是一级标题';

  @override
  String get chat_markdown_example_title2 => '这是二级标题';

  @override
  String get chat_markdown_example_bold_italic => '这是**粗体**文本和*斜体*文本。';

  @override
  String get chat_markdown_example_list1 => '这是列表项1';

  @override
  String get chat_markdown_example_list2 => '这是列表项2';

  @override
  String get chat_markdown_example_list3 => '这是嵌套列表项';

  @override
  String get chat_markdown_example_quote => '这是引用文本，支持多行显示';

  @override
  String get chat_markdown_example_table_col1 => '列1';

  @override
  String get chat_markdown_example_table_col2 => '列2';

  @override
  String get chat_markdown_example_table_content1 => '内容1';

  @override
  String get chat_markdown_example_table_content2 => '内容2';

  @override
  String get chat_markdown_example_table_content3 => '内容3';

  @override
  String get chat_markdown_example_table_content4 => '内容4';

  @override
  String get chat_pick_from_gallery => '从相册选择';

  @override
  String get chat_take_photo => '拍照';

  @override
  String get chat_send_markdown => '发送Markdown示例';

  @override
  String get chat_switch_to_text => '切换到文本输入';

  @override
  String get chat_switch_to_voice => '切换到语音输入';

  @override
  String get chat_send => '发送';

  @override
  String get chat_attach => '发送图片/文件';

  @override
  String get chat_filter_all => '全部';

  @override
  String get chat_filter_buyer => '我的购买';

  @override
  String get chat_filter_seller => '我的出售';

  @override
  String get chat_filter_mode_all => '显示全部聊天';

  @override
  String get chat_filter_mode_buyer => '只显示我的购买聊天';

  @override
  String get chat_filter_mode_seller => '只显示我的出售聊天';

  @override
  String get chat_press_to_talk => '按住 说话';

  @override
  String chat_release_to_send(int duration) {
    return '松开 发送 (${duration}s)';
  }

  @override
  String get chat_camera_permission_denied_title => '相机权限已被禁用';

  @override
  String get chat_camera_permission_denied_message =>
      '请在系统设置中手动开启相机权限才能使用拍照功能。';

  @override
  String get chat_mic_permission_denied_title => '麦克风权限已被禁用';

  @override
  String get chat_mic_permission_denied_message => '请在系统设置中手动开启麦克风权限才能使用录音功能。';

  @override
  String get chat_permission_denied_cancel => '取消';

  @override
  String get chat_permission_denied_settings => '去设置';

  @override
  String get chat_mic_permission_denied => '未获得麦克风权限，无法录音';

  @override
  String get chat_camera_permission_denied => '未获得相机权限，无法拍照';

  @override
  String chat_recording_error(String error) {
    return '无法开始录音: $error';
  }

  @override
  String chat_stop_recording_error(String error) {
    return '停止录音失败: $error';
  }

  @override
  String chat_image_picking_error(String error) {
    return '选择图片出错: $error';
  }

  @override
  String get chat_web_recording_not_supported => 'Web 平台暂不支持录音功能';

  @override
  String get profile_personal_center => '个人中心';

  @override
  String get profile_login_prompt => '请登录以查看您的个人资料';

  @override
  String get profile_login_button => '去登录';

  @override
  String get auth_phone_number => '手机号';

  @override
  String get auth_select_country_region => '选择国家/地区';

  @override
  String get auth_phone_validation_empty => '请输入手机号';

  @override
  String get auth_phone_validation_invalid_cn => '请输入11位手机号';

  @override
  String get auth_phone_validation_invalid_cn_start => '手机号必须以1开头';

  @override
  String get auth_phone_validation_invalid_us => '请输入10位电话号码';

  @override
  String get auth_phone_validation_invalid_jp_kr => '请输入10或11位电话号码';

  @override
  String get auth_phone_validation_invalid_general => '请输入有效的电话号码';

  @override
  String profile_loading_error(String error) {
    return '加载失败: $error';
  }

  @override
  String get profile_my_dskk => '我的多看';

  @override
  String get profile_favorites => '收藏';

  @override
  String get profile_my_wallet => '我的钱包';

  @override
  String get profile_wallet => '钱包';

  @override
  String get profile_settings => '设置';

  @override
  String get profile_account_security => '账号与安全';

  @override
  String get profile_message_notifications => '消息通知';

  @override
  String get profile_about_us => '关于我们';

  @override
  String get profile_assistant_mission => '小帮手的使命';

  @override
  String get profile_switch_to_seller => '切换到卖家模式';

  @override
  String profile_switch_error(String error) {
    return '无法切换到卖家模式: $error';
  }

  @override
  String get profile_edit_nickname => '修改昵称';

  @override
  String get profile_nickname_hint => '请输入新昵称';

  @override
  String get profile_nickname_empty_error => '昵称不能为空';

  @override
  String get profile_nickname_length_error => '昵称长度不能超过20个字符';

  @override
  String get profile_cancel => '取消';

  @override
  String get profile_save => '保存';

  @override
  String get profile_default_name => '用户';

  @override
  String get profile_online => '在线';

  @override
  String get profile_offline => '离线';

  @override
  String get profile_avatar_upload_failed => '头像上传失败，请重试';

  @override
  String get profile_orders => '我的订单';

  @override
  String get profile_pending_payment => '待付款';

  @override
  String get profile_in_progress => '咨询中';

  @override
  String get profile_completed => '已完成';

  @override
  String get profile_refund => '售后';

  @override
  String profile_navigation_error(String error) {
    return '无法导航到订单列表: $error';
  }

  @override
  String get home_title => '首页';

  @override
  String get home_search_hint => '搜索服务';

  @override
  String get home_loading => '加载中...';

  @override
  String home_loading_failed(String error) {
    return '加载失败: $error';
  }

  @override
  String get home_retry => '重试';

  @override
  String get home_end_of_list => '已经到底了';

  @override
  String get home_no_content => '暂无推荐内容';

  @override
  String get home_pull_to_refresh => '下拉刷新获取推荐内容';

  @override
  String home_banner_clicked(String targetType, String targetValue) {
    return '点击了轮播图: $targetType - $targetValue';
  }

  @override
  String home_product_card_clicked(String name) {
    return '点击了服务卡片: $name';
  }

  @override
  String home_recommend_clicked(String name) {
    return '点击了\"让ta看看\"按钮: $name';
  }

  @override
  String get product_recommend_button => '让ta看看';

  @override
  String get product_image_loading_failed => '图片加载失败';

  @override
  String get product_default_name => '商品';

  @override
  String get search_title => '搜索';

  @override
  String get search_button => '搜索';

  @override
  String get search_hot_keywords => '热搜榜';

  @override
  String get search_history => '搜索历史';

  @override
  String get search_no_results => '没有找到相关的服务';

  @override
  String search_failed(String error) {
    return '搜索失败: $error';
  }

  @override
  String product_detail_loading_failed(String error) {
    return '加载失败: $error';
  }

  @override
  String get product_detail_retry => '重试';

  @override
  String get product_detail_please_wait => '请稍等...';

  @override
  String get product_detail_contact_seller => '咨询卖家';

  @override
  String get product_detail_verified_label => '已认证';

  @override
  String get product_detail_published_status => '已发布';

  @override
  String get product_detail_more => '更多';

  @override
  String get product_detail_collapse => '收起';

  @override
  String get product_detail_delivery_times => '交付次数';

  @override
  String get product_detail_delivery_period => '交付周期';

  @override
  String get product_detail_buy_now => '一键购买(1)';

  @override
  String product_detail_buy_now_with_price(String price) {
    return '一键购买 ¥$price';
  }

  @override
  String get product_detail_faq => '常见问题';

  @override
  String get product_detail_case_showcase => '案例展示';

  @override
  String get product_detail_no_cases => '暂无案例展示';

  @override
  String product_detail_reviews(int count) {
    return '评论($count)';
  }

  @override
  String get product_detail_view_all => '查看全部';

  @override
  String get product_detail_no_reviews => '暂无评价';

  @override
  String get product_detail_basic_package => '基础';

  @override
  String get product_detail_standard_package => '标准';

  @override
  String get product_detail_premium_package => '豪华';

  @override
  String get product_detail_basic_tier => '基础';

  @override
  String get product_detail_standard_tier => '标准';

  @override
  String get product_detail_premium_tier => '豪华';

  @override
  String get product_detail_sample_review => '不错，很有耐心';

  @override
  String get product_detail_sample_user => '瑞123';

  @override
  String get product_reviews_title => '评论';

  @override
  String product_reviews_loading_failed(String error) {
    return '加载失败: $error';
  }

  @override
  String get product_reviews_retry => '重试';

  @override
  String get product_reviews_no_reviews => '暂无评论';

  @override
  String get product_reviews_sample_content => '不错，很有耐心';

  @override
  String product_reviews_years_ago(int count) {
    return '$count年前';
  }

  @override
  String product_reviews_months_ago(int count) {
    return '$count月前';
  }

  @override
  String product_reviews_days_ago(int count) {
    return '$count天前';
  }

  @override
  String product_reviews_hours_ago(int count) {
    return '$count小时前';
  }

  @override
  String product_reviews_minutes_ago(int count) {
    return '$count分钟前';
  }

  @override
  String get product_reviews_just_now => '刚刚';

  @override
  String get product_reviews_seller_reply => '卖家回复';

  @override
  String product_reviews_total_count(int count) {
    return '共$count条评价';
  }

  @override
  String get product_reviews_filter_all => '全部';

  @override
  String get product_reviews_filter_with_images => '有图';

  @override
  String get product_reviews_filter_good => '好评';

  @override
  String get product_reviews_filter_medium => '中评';

  @override
  String get product_reviews_filter_bad => '差评';

  @override
  String get seller_profile_default_title => '卖家主页';

  @override
  String get seller_profile_seller => '卖家';

  @override
  String get seller_profile_no_description => '暂无简介';

  @override
  String seller_profile_followers(int count) {
    return '$count粉丝';
  }

  @override
  String get seller_profile_followed => '已关注';

  @override
  String get seller_profile_follow => '关注';

  @override
  String get seller_profile_unfollow_success => '取消关注成功';

  @override
  String get seller_profile_follow_success => '关注成功';

  @override
  String seller_profile_chat_failed(String error) {
    return '创建聊天失败: $error';
  }

  @override
  String seller_profile_error_occurred(String error) {
    return '发生错误: $error';
  }

  @override
  String get seller_profile_about_merchant => '关于商家';

  @override
  String get seller_profile_my_services => '我的服务';

  @override
  String get seller_profile_no_merchant_info => '暂无商家信息';

  @override
  String get seller_profile_member_level => '会员等级';

  @override
  String get seller_profile_level_two => '二级会员';

  @override
  String get seller_profile_seller_rating => '卖家评分';

  @override
  String get seller_profile_response_time => '回应时间';

  @override
  String get seller_profile_response_hours => '3小时';

  @override
  String get seller_profile_certification_status => '认证状态';

  @override
  String get seller_profile_certified => '已认证';

  @override
  String get seller_profile_not_certified => '未认证';

  @override
  String get seller_profile_no_products => '暂无商品';

  @override
  String get seller_profile_image_load_failed => '图片加载失败';

  @override
  String get seller_profile_no_image => '暂无图片';

  @override
  String get seller_profile_title => '我的';

  @override
  String get seller_profile_auth_management => '认证管理';

  @override
  String get seller_profile_my_wallet => '我的钱包';

  @override
  String get seller_profile_time_management => '时间管理';

  @override
  String get seller_profile_settings => '设置';

  @override
  String get seller_profile_notifications => '消息通知';

  @override
  String get seller_profile_about_us => '关于我们';

  @override
  String get seller_profile_mission => '小粽子的使命';

  @override
  String get seller_profile_user_name => '瑞';

  @override
  String get seller_profile_seller_mode_online => '卖家模式：在线';

  @override
  String get seller_profile_seller_mode => '卖家模式';

  @override
  String get seller_profile_buyer_mode => '买家模式';

  @override
  String get seller_profile_my_orders => '我的订单';

  @override
  String get seller_profile_order_pending => '待确认';

  @override
  String get seller_profile_order_processing => '进行中';

  @override
  String get seller_profile_order_delivered => '已交付';

  @override
  String get seller_profile_order_refund => '退款/售后';

  @override
  String seller_profile_feature_not_implemented(String feature) {
    return '$feature功能尚未实现';
  }

  @override
  String get seller_home_loading_failed => '加载失败';

  @override
  String get seller_home_no_data => '暂无数据';

  @override
  String get seller_home_no_store_info => '暂无店铺信息';

  @override
  String get seller_home_online => '在线';

  @override
  String get seller_home_offline => '离线';

  @override
  String seller_home_completion_rate(String rate) {
    return '完成率 $rate%';
  }

  @override
  String get seller_home_switch_to_buyer => '切换到买家模式';

  @override
  String seller_home_switch_failed(String error) {
    return '无法切换到买家模式: $error';
  }

  @override
  String get seller_home_income => '收入';

  @override
  String get seller_home_view_details => '查看明细';

  @override
  String get seller_home_total_income => '总收入';

  @override
  String get seller_home_today_income => '今日收入';

  @override
  String get seller_home_pending_settlement => '待结算';

  @override
  String get seller_home_orders => '订单';

  @override
  String get seller_home_view_all => '查看全部';

  @override
  String get seller_home_orders_all => '全部';

  @override
  String get seller_home_orders_pending => '待处理';

  @override
  String get seller_home_orders_processing => '进行中';

  @override
  String get seller_home_orders_aftersales => '售后中';

  @override
  String get seller_home_orders_awaiting_delivery => '待发货';

  @override
  String get seller_home_orders_completed => '已完成';

  @override
  String get seller_home_orders_canceled => '已取消';

  @override
  String get seller_home_functions => '功能';

  @override
  String get seller_home_wallet => '钱包';

  @override
  String get seller_home_auth_management => '认证管理';

  @override
  String get seller_home_time_management => '时间管理';

  @override
  String get seller_home_auto_reply => '自动回复';

  @override
  String get seller_home_recent_income => '近期收入';

  @override
  String get seller_home_no_recent_income => '暂无近期收入数据';

  @override
  String get seller_home_no_income_data => '暂无收入数据';

  @override
  String get seller_statistics_title => '卖家数据';

  @override
  String get seller_statistics_seller_homepage => '卖家主页';

  @override
  String get seller_statistics_heat_value => '热度值';

  @override
  String get seller_statistics_reply_rate => '回复率';

  @override
  String get seller_statistics_completion_rate => '完成率';

  @override
  String get seller_statistics_positive_rate => '好评率';

  @override
  String get seller_statistics_upgrade_to_next_level => '升到下一级';

  @override
  String seller_statistics_become_level3_seller(String days) {
    return '成为三级会员卖家$days天';
  }

  @override
  String seller_statistics_complete_orders(String orderNum) {
    return '完成订单$orderNum笔';
  }

  @override
  String seller_statistics_profit_amount(String amount) {
    return '盈利$amount元';
  }

  @override
  String get seller_statistics_indicators => '指标';

  @override
  String get seller_statistics_total_earnings => '总盈利';

  @override
  String get seller_statistics_monthly_earnings => '本月盈利';

  @override
  String get seller_statistics_total_orders => '总订单数';

  @override
  String get seller_statistics_active_orders => '活跃订单数';

  @override
  String get seller_statistics_pending => '待处理';

  @override
  String get seller_statistics_incomplete_orders => '未完成订单数';

  @override
  String get seller_statistics_pending_completion => '待完成';

  @override
  String get seller_statistics_receipt => '回单';

  @override
  String get seller_statistics_next_delivery_date => '距离下次邀交日';

  @override
  String get seller_statistics_earliest => '最早';

  @override
  String seller_statistics_loading_failed(String error) {
    return '加载失败: $error';
  }

  @override
  String get seller_statistics_retry => '重试';

  @override
  String get seller_auth_management_title => '认证管理';

  @override
  String get seller_auth_management_certified_items => '已认证项目';

  @override
  String get seller_auth_management_open_certification => '开放认证';

  @override
  String get seller_auth_management_no_items => '暂无认证项目';

  @override
  String get seller_auth_management_unknown_status => '未知状态';

  @override
  String get seller_auth_management_certified => '已认证';

  @override
  String get seller_auth_management_pending => '审核中';

  @override
  String get seller_auth_management_rejected => '未通过';

  @override
  String get seller_auth_management_not_submitted => '未提交';

  @override
  String get seller_auth_management_server_timeout => '服务器响应超时';

  @override
  String get seller_auth_management_server_timeout_desc => '服务器处理请求时间过长，请稍后重试';

  @override
  String get seller_auth_management_network_error => '网络连接异常';

  @override
  String get seller_auth_management_network_error_desc => '无法连接到服务器，请检查网络设置';

  @override
  String get seller_auth_management_loading_failed => '加载失败';

  @override
  String get seller_auth_management_unknown_error => '发生未知错误，请重试';

  @override
  String get seller_auth_management_troubleshooting => '故障排除建议：';

  @override
  String get seller_auth_management_check_network => '• 检查网络连接是否稳定';

  @override
  String get seller_auth_management_wait_retry => '• 等待几分钟后重新尝试';

  @override
  String get seller_auth_management_contact_support => '• 如问题持续存在，请联系客服';

  @override
  String get seller_auth_management_check_wifi => '• 检查WiFi或移动数据连接';

  @override
  String get seller_auth_management_switch_network => '• 尝试切换网络环境';

  @override
  String get seller_auth_management_restart_app => '• 关闭并重新打开应用';

  @override
  String get seller_auth_management_check_connection => '• 检查网络连接状态';

  @override
  String get seller_auth_management_try_later => '• 稍后重新尝试';

  @override
  String get seller_auth_management_contact_tech => '• 如问题持续存在，请联系技术支持';

  @override
  String get seller_auth_management_reload => '重新加载';

  @override
  String get seller_auth_management_back => '返回';

  @override
  String seller_auth_application_title(String type) {
    return '$type认证';
  }

  @override
  String seller_auth_application_desc(String type) {
    return '$type认证说明';
  }

  @override
  String get seller_auth_application_review_time => '认证审核通常需要1-3个工作日，请耐心等待。';

  @override
  String get seller_auth_application_basic_info => '基本信息';

  @override
  String get seller_auth_application_company_name => '公司名称';

  @override
  String get seller_auth_application_company_name_hint => '请输入公司全称';

  @override
  String get seller_auth_application_company_name_required => '请输入公司名称';

  @override
  String get seller_auth_application_credit_code => '统一社会信用代码';

  @override
  String get seller_auth_application_credit_code_hint => '请输入18位统一社会信用代码';

  @override
  String get seller_auth_application_credit_code_required => '请输入统一社会信用代码';

  @override
  String get seller_auth_application_credit_code_invalid => '统一社会信用代码应为18位';

  @override
  String get seller_auth_application_company_intro => '企业简介';

  @override
  String get seller_auth_application_company_intro_hint => '请简要描述公司业务和情况';

  @override
  String get seller_auth_application_real_name => '姓名';

  @override
  String get seller_auth_application_real_name_hint => '请输入您的真实姓名';

  @override
  String get seller_auth_application_real_name_required => '请输入姓名';

  @override
  String get seller_auth_application_id_number => '身份证号码';

  @override
  String get seller_auth_application_id_number_hint => '请输入18位身份证号码';

  @override
  String get seller_auth_application_id_number_required => '请输入身份证号码';

  @override
  String get seller_auth_application_id_number_invalid => '身份证号码应为18位';

  @override
  String get seller_auth_application_school_name => '学校名称';

  @override
  String get seller_auth_application_school_name_hint => '请输入学校全称';

  @override
  String get seller_auth_application_school_name_required => '请输入学校名称';

  @override
  String get seller_auth_application_degree => '学历/学位';

  @override
  String get seller_auth_application_degree_hint => '如：本科、硕士等';

  @override
  String get seller_auth_application_degree_required => '请输入学历/学位';

  @override
  String get seller_auth_application_major => '专业';

  @override
  String get seller_auth_application_major_hint => '请输入专业名称';

  @override
  String get seller_auth_application_profession => '职业/职位';

  @override
  String get seller_auth_application_profession_hint => '请输入您的职业或职位';

  @override
  String get seller_auth_application_profession_required => '请输入职业/职位';

  @override
  String get seller_auth_application_cert_number => '证书编号';

  @override
  String get seller_auth_application_cert_number_hint => '请输入职业资格证书编号';

  @override
  String get seller_auth_application_work_experience => '工作经验';

  @override
  String get seller_auth_application_work_experience_hint => '请简要描述您的工作经验';

  @override
  String get seller_auth_application_auth_name => '认证名称';

  @override
  String get seller_auth_application_auth_name_hint => '请输入认证名称';

  @override
  String get seller_auth_application_auth_name_required => '请输入认证名称';

  @override
  String get seller_auth_application_auth_identifier => '认证标识';

  @override
  String get seller_auth_application_auth_identifier_hint => '请输入认证标识或编号';

  @override
  String get seller_auth_application_auth_description => '认证描述';

  @override
  String get seller_auth_application_auth_description_hint => '请描述认证内容';

  @override
  String get seller_auth_application_upload_materials => '上传证明材料';

  @override
  String get seller_auth_application_upload_file => '上传文件';

  @override
  String seller_auth_application_selected_files(int count) {
    return '已选择 $count 个文件';
  }

  @override
  String get seller_auth_application_selected_images => '已选择的图片：';

  @override
  String get seller_auth_application_load_failed => '加载失败';

  @override
  String get seller_auth_application_id_upload_hint =>
      '请上传清晰的身份证正反面照片，确保信息清晰可见，不得遮挡、涂改';

  @override
  String get seller_auth_application_education_upload_hint =>
      '请上传学历证书、学位证书等证明材料，需包含完整信息';

  @override
  String get seller_auth_application_profession_upload_hint =>
      '请上传职业资格证书、专业技能证书等证明材料';

  @override
  String get seller_auth_application_company_upload_hint =>
      '请上传营业执照、组织机构代码证等企业资质证明材料';

  @override
  String get seller_auth_application_default_upload_hint =>
      '请上传相关证明材料，确保图片清晰、信息完整';

  @override
  String get seller_auth_application_agreement_read => '我已阅读并同意';

  @override
  String get seller_auth_application_agreement_link => '《认证服务协议》';

  @override
  String get seller_auth_application_agreement_guarantee => '，保证所提供的信息真实有效';

  @override
  String get seller_auth_application_agreement_title => '认证服务协议';

  @override
  String get seller_auth_application_agreement_content =>
      '本协议是您与DSKK平台之间关于认证服务的法律协议。请您仔细阅读以下条款，确保完全理解本协议中的所有权利和义务。\n\n一、服务内容\nDSKK平台提供认证服务，旨在验证您提供的身份、资质等信息的真实性，提高您在平台上的可信度。\n\n二、用户义务\n1. 您应当提供真实、准确、完整的认证信息和材料。\n2. 您应当确保提供的认证材料不侵犯任何第三方的合法权益。\n\n三、平台权利与义务\n1. 平台有权对您提供的认证信息和材料进行审核。\n2. 平台将在合理的时间内完成审核，并告知您审核结果。';

  @override
  String get seller_auth_application_agreement_close => '关闭';

  @override
  String get seller_auth_application_agreement_agree => '同意';

  @override
  String get seller_auth_application_submit => '提交认证申请';

  @override
  String get seller_auth_application_check_form => '请检查表单填写是否正确';

  @override
  String get seller_auth_application_submit_success => '提交成功';

  @override
  String get seller_auth_application_submit_success_desc =>
      '您的认证申请已提交，我们将在1-3个工作日内完成审核，请耐心等待。';

  @override
  String get seller_auth_application_ok => '确定';

  @override
  String seller_auth_application_select_file_failed(String error) {
    return '选择文件失败: $error';
  }

  @override
  String get product_management_title => '商品管理';

  @override
  String get product_management_tab_on_sale => '在售';

  @override
  String get product_management_tab_draft => '草稿箱';

  @override
  String get product_management_tab_off_shelf => '已下架';

  @override
  String get product_management_action_off_shelf => '下架';

  @override
  String get product_management_action_on_shelf => '上架';

  @override
  String get product_management_action_edit => '编辑';

  @override
  String get product_management_action_delete => '删除';

  @override
  String get product_management_action_publish => '发布';

  @override
  String get product_management_action_resubmit => '重新提交';

  @override
  String get product_management_status_reviewing => '审核中';

  @override
  String get product_management_status_rejected => '审核失败';

  @override
  String get product_management_status_on_shelf => '已上架';

  @override
  String get product_management_status_off_shelf => '已下架';

  @override
  String get product_management_status_draft => '草稿';

  @override
  String get product_management_status_waiting_review => '等待审核';

  @override
  String get product_management_status_unknown => '未知';

  @override
  String get product_management_stock_label => '库存';

  @override
  String get product_management_sales_label => '销量';

  @override
  String get product_management_create_product => '创建商品';

  @override
  String get product_management_no_more_products => '没有更多商品了';

  @override
  String get product_management_empty_on_sale => '暂无在售商品';

  @override
  String get product_management_empty_draft => '暂无草稿商品';

  @override
  String get product_management_empty_off_shelf => '暂无已下架商品';

  @override
  String get product_management_empty_default => '暂无商品数据';

  @override
  String get product_management_draft_preview_hint => '草稿状态的商品需要先发布才能预览';

  @override
  String get product_management_confirm_off_shelf_title => '确认下架';

  @override
  String product_management_confirm_off_shelf_message(String name) {
    return '确定要下架商品 \"$name\" 吗？';
  }

  @override
  String get product_management_confirm_off_shelf_desc => '下架后：';

  @override
  String get product_management_confirm_off_shelf_point1 => '• 买家将无法看到和购买此商品';

  @override
  String get product_management_confirm_off_shelf_point2 => '• 您可以随时重新上架';

  @override
  String get product_management_confirm_off_shelf_point3 => '• 商品数据会被保留';

  @override
  String get product_management_confirm_delete_title => '确认删除';

  @override
  String get product_management_confirm_delete_message => '确定要删除这个商品吗？此操作不可撤销。';

  @override
  String get product_management_cancel => '取消';

  @override
  String get product_management_confirm => '确认下架';

  @override
  String get product_management_delete => '删除';

  @override
  String get product_edit_title_create => '创建商品';

  @override
  String get product_edit_title_edit => '编辑商品';

  @override
  String get product_edit_basic_info => '基础信息';

  @override
  String get product_edit_product_name => '商品名称';

  @override
  String get product_edit_product_name_hint => '请输入商品名称';

  @override
  String get product_edit_product_description => '商品描述';

  @override
  String get product_edit_product_description_hint => '请输入商品描述';

  @override
  String get product_edit_product_price => '商品价格';

  @override
  String get product_edit_product_images => '商品图片';

  @override
  String get product_edit_add_image => '添加图片';

  @override
  String get product_edit_uploading => '上传中...';

  @override
  String get product_edit_service_tiers => '服务档位设置';

  @override
  String get product_edit_detail_intro => '详情介绍';

  @override
  String get product_edit_save_draft => '保存草稿';

  @override
  String get product_edit_publish_product => '发布商品';

  @override
  String get product_edit_preview_product => '预览商品';

  @override
  String get product_edit_at_least_one_image => '请至少上传一张商品图片';

  @override
  String get product_edit_save_draft_dialog_title => '保存草稿';

  @override
  String get product_edit_save_draft_dialog_message => '是否保存为草稿？';

  @override
  String get product_edit_save_draft_dialog_confirm => '保存';

  @override
  String get product_edit_edit_attribute => '编辑商品属性';

  @override
  String get product_edit_validation_name_required => '请输入商品名称';

  @override
  String get product_edit_validation_description_required => '请输入商品描述';

  @override
  String get product_edit_validation_image_required => '请至少上传一张商品图片';

  @override
  String get product_preview_current_seller => '当前卖家';

  @override
  String get product_preview_seller_user => '卖家用户';

  @override
  String get product_edit_success_cases => '成功案例';

  @override
  String get product_edit_add_success_case => '添加成功案例';

  @override
  String get product_edit_edit_success_case => '编辑成功案例';

  @override
  String product_edit_uploading_progress(int uploaded, int total) {
    return '上传中 $uploaded/$total';
  }

  @override
  String get product_edit_please_enter_label => '请输入信息标签';

  @override
  String get product_edit_please_enter_attribute_name => '请输入属性名称';

  @override
  String get product_edit_attribute_name_hint => '请输入属性名称';

  @override
  String get product_edit_placeholder_hint => '例如：请选择颜色、请输入型号';

  @override
  String get product_edit_placeholder_label => '占位符文本';

  @override
  String get product_edit_product_preview_title => '商品预览';

  @override
  String get product_edit_publish_service => '发布服务';

  @override
  String get product_edit_edit_service => '编辑服务';

  @override
  String product_edit_max_characters(int max) {
    return '最多$max个字符';
  }

  @override
  String get after_sales_review_title => '售后审核';

  @override
  String get after_sales_detail_title => '售后详情';

  @override
  String get after_sales_refresh => '刷新';

  @override
  String get after_sales_no_pending => '暂无待审核的售后申请';

  @override
  String get after_sales_load_failed => '加载失败，请重试';

  @override
  String get after_sales_not_found => '找不到对应的售后申请';

  @override
  String get after_sales_order_number => '订单编号';

  @override
  String get after_sales_apply_type => '申请类型';

  @override
  String get after_sales_apply_time => '申请时间';

  @override
  String get after_sales_refund_amount => '退款金额';

  @override
  String get after_sales_refund_type => '退款类型';

  @override
  String get after_sales_apply_reason => '申请原因';

  @override
  String get after_sales_image_evidence => '图片证据';

  @override
  String get after_sales_image_view => '图片查看';

  @override
  String get after_sales_image_load_failed => '图片加载失败';

  @override
  String get after_sales_reject => '拒绝';

  @override
  String get after_sales_agree => '同意';

  @override
  String get after_sales_reject_application => '拒绝申请';

  @override
  String get after_sales_agree_application => '同意申请';

  @override
  String get after_sales_confirm => '确认';

  @override
  String get after_sales_cancel => '取消';

  @override
  String get after_sales_confirm_title => '确认';

  @override
  String get after_sales_confirm_message => '确定同意此售后申请吗？';

  @override
  String get after_sales_reject_reason => '拒绝原因';

  @override
  String get after_sales_reject_reason_hint => '请输入拒绝原因';

  @override
  String get after_sales_reject_reason_required => '请输入拒绝原因';

  @override
  String get after_sales_type_refund_only => '仅退款';

  @override
  String get after_sales_type_refund_return => '退货退款';

  @override
  String get after_sales_type_unknown => '未知类型';

  @override
  String get after_sales_status_wait_audit => '待审核';

  @override
  String get after_sales_status_refused => '已拒绝';

  @override
  String get after_sales_status_audit_pass => '审核通过';

  @override
  String get after_sales_status_buyer_shipped => '买家已发货';

  @override
  String get after_sales_status_seller_received => '卖家已收货';

  @override
  String get after_sales_status_finished => '已完成';

  @override
  String get after_sales_status_canceled => '已取消';

  @override
  String get after_sales_status_unknown => '未知状态';

  @override
  String get time_management_title => '时间管理';

  @override
  String get time_management_current_status => '当前状态';

  @override
  String get time_management_online => '在线';

  @override
  String get time_management_offline => '离线';

  @override
  String get time_management_online_status_description => '在线状态说明';

  @override
  String get time_management_offline_status_description => '离线状态说明';

  @override
  String get time_management_online_description =>
      '您当前处于在线状态，买家可以向您发送消息，您将收到新消息的通知。请确保及时回复买家消息，保持良好的响应率有助于提高您的服务质量评分。';

  @override
  String get time_management_offline_description =>
      '您当前处于离线状态，买家仍然可以向您发送消息，但系统会告知买家您暂时不在线。您仍然会收到新消息的通知，但可能无法立即回复。长时间保持离线状态可能会影响您的接单效率。';

  @override
  String get time_management_save_settings => '保存设置';

  @override
  String get time_management_settings_saved => '设置已保存';

  @override
  String get time_management_load_failed => '加载失败';

  @override
  String get time_management_retry => '重试';

  @override
  String get time_management_unknown_status => '未知状态';

  @override
  String get auto_reply_title => '自动回复设置';

  @override
  String get auto_reply_enable => '自动回复';

  @override
  String get auto_reply_content => '回复内容';

  @override
  String get auto_reply_content_hint => '请输入自动回复内容';

  @override
  String get auto_reply_content_description => '当客户发送消息时，系统会自动回复此内容';

  @override
  String get auto_reply_save_settings => '保存设置';

  @override
  String get auto_reply_settings_saved => '设置已保存';

  @override
  String get auto_reply_content_required => '回复内容不能为空';

  @override
  String get auto_reply_load_failed => '加载失败，请重试';

  @override
  String get order_delivery_title => '订单交付';

  @override
  String order_delivery_title_with_sn(String orderSn) {
    return '订单交付: $orderSn';
  }

  @override
  String get order_delivery_submitting => '正在提交交付内容...';

  @override
  String get order_delivery_load_failed => '加载失败，请重试';

  @override
  String get order_delivery_instruction_title => '订单交付说明';

  @override
  String get order_delivery_instruction_content =>
      '请提交您针对此订单的交付内容。您可以提供详细说明以及附加相关文件，确保买家能够清晰了解您提供的服务或产品。';

  @override
  String get order_delivery_content_label => '交付内容描述:';

  @override
  String get order_delivery_content_hint => '请描述您的交付内容...';

  @override
  String get order_delivery_attachments_label => '附件文件:';

  @override
  String get order_delivery_submit_button => '提交交付';

  @override
  String get order_delivery_content_required => '请输入交付内容描述';

  @override
  String get order_delivery_submit_success => '交付内容提交成功';

  @override
  String get order_delivery_logistics_company => '物流公司';

  @override
  String get order_delivery_tracking_number => '物流单号';

  @override
  String get order_delivery_shipping_address => '发货地址';

  @override
  String get order_delivery_receiving_address => '收货地址';

  @override
  String get order_delivery_status_pending => '待发货';

  @override
  String get order_delivery_status_shipped => '已发货';

  @override
  String get order_delivery_status_received => '已收货';

  @override
  String get order_delivery_status_in_transit => '配送中';

  @override
  String get order_delivery_confirm_shipment => '确认发货';

  @override
  String get order_delivery_view_details => '查看详情';

  @override
  String get order_delivery_no_pending_orders => '暂无待发货订单';

  @override
  String get notification_center_title => '通知中心';

  @override
  String get notification_tab_all => '全部';

  @override
  String get notification_tab_order => '订单';

  @override
  String get notification_tab_system => '系统';

  @override
  String get notification_tab_refund => '售后';

  @override
  String get notification_tab_message => '消息';

  @override
  String get notification_type_order => '订单通知';

  @override
  String get notification_type_system => '系统通知';

  @override
  String get notification_type_refund => '售后通知';

  @override
  String get notification_type_message => '消息通知';

  @override
  String get notification_type_review => '评价通知';

  @override
  String get notification_type_authentication => '认证通知';

  @override
  String get notification_type_other => '其他通知';

  @override
  String get notification_status_unread => '未读';

  @override
  String get notification_status_read => '已读';

  @override
  String get notification_mark_all_read => '全部标记已读';

  @override
  String get notification_empty_all => '暂无任何通知';

  @override
  String get notification_empty_order => '暂无订单通知';

  @override
  String get notification_empty_system => '暂无系统通知';

  @override
  String get notification_empty_refund => '暂无售后通知';

  @override
  String get notification_empty_message => '暂无消息通知';

  @override
  String get notification_empty_review => '暂无评价通知';

  @override
  String get notification_empty_authentication => '暂无认证通知';

  @override
  String get notification_empty_other => '暂无其他通知';

  @override
  String get notification_empty_generic => '暂无通知';

  @override
  String get notification_refresh => '刷新';

  @override
  String get notification_retry => '重试';

  @override
  String notification_load_failed(String error) {
    return '加载通知中心失败: $error';
  }

  @override
  String get notification_detail_title => '通知详情';

  @override
  String get notification_detail_view => '查看详情';

  @override
  String get notification_detail_close => '关闭';

  @override
  String get notification_click_to_view => '点击查看详情';

  @override
  String get notification_default_title => '通知';

  @override
  String get notification_time_just_now => '刚刚';

  @override
  String notification_time_minutes_ago(int minutes) {
    return '$minutes分钟前';
  }

  @override
  String notification_time_hours_ago(int hours) {
    return '$hours小时前';
  }

  @override
  String notification_time_days_ago(int days) {
    return '$days天前';
  }

  @override
  String notification_time_months_ago(int months) {
    return '$months个月前';
  }

  @override
  String get materialsInfo => '材料信息';

  @override
  String get buyerSubmittedMaterials => '买家提交的材料';

  @override
  String get sellerDeliveryContent => '卖家交付内容';

  @override
  String get noBuyerMaterials => '暂无买家提交的材料';

  @override
  String get noSellerDelivery => '卖家暂未交付内容';

  @override
  String get attachments => '附件:';

  @override
  String get deliveryFiles => '交付文件:';

  @override
  String get deliveryDescription => '交付说明';

  @override
  String get tapToPreview => '点击预览';

  @override
  String get tapToOpen => '点击打开';

  @override
  String get downloadFile => '下载文件';

  @override
  String get storagePermissionDenied => '存储权限被拒绝';

  @override
  String get cancelDownload => '取消下载';

  @override
  String get pageLoadFailed => '页面加载失败';

  @override
  String get openFile => '打开文件';

  @override
  String get downloaded => '已下载';

  @override
  String get downloadCompleted => '下载完成';

  @override
  String get downloadFailed => '下载失败';

  @override
  String get openFileFailed => '打开文件失败';

  @override
  String get storagePermissionRequired => '需要存储权限才能下载文件';

  @override
  String get pdfLoadFailed => 'PDF加载失败';

  @override
  String get retry => '重试';
}
