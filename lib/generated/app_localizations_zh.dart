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
  String get chat_unsupported_message => '该消息暂不支持查看';

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
  String get chat_summary_hidden => '该需求摘要生成异常，已隐藏';

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
  String get chat_filter_buyer => '买家消息';

  @override
  String get chat_filter_seller => '卖家消息';

  @override
  String get chat_filter_mode_all => '显示全部聊天';

  @override
  String get chat_filter_mode_buyer => '只显示买家消息';

  @override
  String get chat_filter_mode_seller => '只显示卖家消息';

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
  String get home_refreshing_recommendations => '正在刷新推荐...';

  @override
  String get home_loading_more => '正在加载更多...';

  @override
  String get home_back_to_top_refresh => '回到顶部并刷新';

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
  String get seller_profile_seller_mode_offline => '卖家模式：离线';

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

  @override
  String product_detail_translated_from(String language) {
    return '翻译自$language';
  }

  @override
  String get product_detail_translation_auto => '自动翻译';

  @override
  String get product_detail_show_original => '显示原文';

  @override
  String get order_status_awaiting_payment => '待付款';

  @override
  String get order_status_awaiting_submission => '待提交';

  @override
  String get order_status_buy_awaiting_submission => '待重传';

  @override
  String get order_status_awaiting_start => '待接单';

  @override
  String get order_status_awaiting_delivery => '待发货';

  @override
  String get order_status_awaiting_confirmation => '待收货';

  @override
  String get order_status_awaiting_evaluation => '待评价';

  @override
  String get order_status_completed => '已完成';

  @override
  String get order_status_canceled => '已取消';

  @override
  String get order_status_after_sale => '售后中';

  @override
  String get order_status_unknown => '未知状态';

  @override
  String get order_action_cancel => '取消订单';

  @override
  String get order_action_go_pay => '去支付';

  @override
  String get order_action_submit_materials => '提交材料';

  @override
  String get order_action_contact_support => '联系客服';

  @override
  String get order_action_view_feedback => '查看反馈';

  @override
  String get order_action_remind_delivery => '提醒发货';

  @override
  String get order_action_platform_intervention => '平台介入';

  @override
  String get order_action_view_delivery => '查看交付';

  @override
  String get order_action_apply_after_sale => '申请售后';

  @override
  String get order_action_confirm_receipt => '确认收货';

  @override
  String get order_action_view_logistics => '查看物流';

  @override
  String get order_action_go_evaluate => '去评价';

  @override
  String get order_action_apply_rework => '申请重做';

  @override
  String get order_action_delete_order => '删除订单';

  @override
  String get order_action_view_order => '查看订单';

  @override
  String get order_action_view_details => '查看详情';

  @override
  String get order_action_processing => '处理中...';

  @override
  String get order_confirm_cancel_title => '取消订单';

  @override
  String get order_confirm_cancel_content => '您确定要取消这个订单吗？';

  @override
  String get order_confirm_receipt_title => '确认收货';

  @override
  String get order_confirm_receipt_content => '您确定已经收到货品，并确认收货吗？';

  @override
  String get order_confirm_delete_title => '删除订单';

  @override
  String get order_confirm_delete_content => '您确定要删除这个订单吗？删除后将无法恢复。';

  @override
  String get order_dialog_cancel => '取消';

  @override
  String get order_dialog_confirm => '确定';

  @override
  String get order_dialog_close => '关闭';

  @override
  String get order_dialog_submit => '提交申请';

  @override
  String get order_snackbar_connecting_support => '正在连接客服...';

  @override
  String get order_snackbar_feedback_in_progress => '查看卖家反馈功能开发中';

  @override
  String get order_snackbar_reminded_delivery => '已提醒卖家发货';

  @override
  String order_snackbar_nav_failed(String error) {
    return '导航失败: $error';
  }

  @override
  String get order_snackbar_no_items_after_sale => '错误：无法为没有商品的订单申请售后';

  @override
  String get order_snackbar_no_items_evaluate => '错误：无法为没有商品的订单进行评价';

  @override
  String order_snackbar_operation_failed(String error) {
    return '操作失败: $error';
  }

  @override
  String get order_dialog_data_not_loaded => '数据未加载完成，请稍后再试';

  @override
  String get order_dialog_view_delivery_title => '查看交付';

  @override
  String get order_dialog_seller_delivery_content => '卖家交付内容：';

  @override
  String get order_dialog_buyer_materials => '买家提交的材料：';

  @override
  String get order_dialog_no_seller_delivery => '卖家暂未交付内容';

  @override
  String get order_dialog_no_buyer_materials => '暂无买家提交的材料';

  @override
  String order_dialog_delivery_note(String content) {
    return '交付说明: $content';
  }

  @override
  String get order_dialog_delivery_files => '交付文件:';

  @override
  String get order_intervention_title => '申请平台介入';

  @override
  String get order_intervention_desc => '遇到无法解决的争议？平台客服会在24小时内介入处理。';

  @override
  String get order_intervention_problem_type => '问题类型:';

  @override
  String get order_intervention_problem_desc => '问题描述:';

  @override
  String get order_intervention_problem_hint => '请详细描述遇到的问题...';

  @override
  String get order_intervention_validation_empty => '请输入问题描述';

  @override
  String get order_intervention_validation_min => '问题描述至少需要10个字符';

  @override
  String get order_intervention_tip => '提示：申请提交后无法撤销，每个订单最多可申请2次。';

  @override
  String get order_intervention_reason_communication => '沟通问题';

  @override
  String get order_intervention_reason_quality => '质量争议';

  @override
  String get order_intervention_reason_delivery => '交付问题';

  @override
  String get order_intervention_reason_refund => '退款纠纷';

  @override
  String get order_intervention_reason_service => '服务态度';

  @override
  String get order_intervention_reason_other => '其他问题';

  @override
  String get order_intervention_submitting => '正在提交申请...';

  @override
  String order_intervention_failed(String error) {
    return '申请失败：$error';
  }

  @override
  String get order_demand_replenishment_title => '申请补充材料';

  @override
  String get order_demand_reform_title => '申请重做';

  @override
  String get order_demand_replenishment_desc => '如果需要卖家补充更多材料或说明，请详细描述您的需求。';

  @override
  String get order_demand_reform_desc => '如果对交付结果不满意，可以申请重做。请说明具体问题。';

  @override
  String get order_demand_detail_label => '详细说明:';

  @override
  String get order_demand_replenishment_hint => '请详细说明需要补充的材料或信息...';

  @override
  String get order_demand_reform_hint => '请详细说明需要重做的原因和要求...';

  @override
  String get order_demand_validation_empty => '请输入详细说明';

  @override
  String get order_demand_validation_min => '说明至少需要10个字符';

  @override
  String get order_demand_replenishment_tip => '提示：卖家会在收到申请后24小时内回复并补充相关材料。';

  @override
  String get order_demand_reform_tip => '提示：重做申请提交后，卖家会重新处理您的订单。';

  @override
  String get order_demand_reason_incomplete => '信息不完整';

  @override
  String get order_demand_reason_unclear => '要求不明确';

  @override
  String get order_demand_reason_additional => '需要补充说明';

  @override
  String get order_demand_reason_reference => '需要参考资料';

  @override
  String get order_demand_reason_other => '其他原因';

  @override
  String get order_demand_reason_quality => '质量不满意';

  @override
  String get order_demand_reason_requirement => '不符合要求';

  @override
  String get order_demand_reason_content_incomplete => '内容不完整';

  @override
  String get order_demand_reason_error => '存在错误';

  @override
  String get order_demand_submitting_replenishment => '正在提交补充材料申请...';

  @override
  String get order_demand_submitting_reform => '正在提交重做申请...';

  @override
  String order_demand_failed(String error) {
    return '申请失败：$error';
  }

  @override
  String order_demand_edit_info_auto(int current, int remaining) {
    return '当前已交付 $current 次，剩余 $remaining 次免费修改机会（自动通过）';
  }

  @override
  String order_demand_edit_info_approval(int current) {
    return '当前已交付 $current 次，已用完免费修改机会，需要卖家审批';
  }

  @override
  String get order_info_title => '订单信息';

  @override
  String get order_info_order_number => '订单编号：';

  @override
  String get order_info_order_time => '下单时间：';

  @override
  String get order_info_pay_time => '付款时间：';

  @override
  String get order_info_complete_time => '完成时间：';

  @override
  String get order_info_remark => '订单备注：';

  @override
  String get order_items_title => '商品信息';

  @override
  String get order_items_empty => '暂无商品信息';

  @override
  String order_items_count(int count) {
    return '$count件';
  }

  @override
  String get order_price_title => '价格明细';

  @override
  String get order_price_total => '商品总价';

  @override
  String get order_price_shipping => '运费';

  @override
  String get order_price_discount => '优惠金额';

  @override
  String get order_price_paid => '实付金额';

  @override
  String get order_price_total_amount => '商品总额';

  @override
  String get order_price_actual_paid => '实付款';

  @override
  String get order_requirement_title => '要求提交';

  @override
  String order_requirement_service_selected(String skuName, String price) {
    return '您选择的服务：$skuName - ¥$price';
  }

  @override
  String get order_requirement_q1 => '1. 请详细描述您的需求';

  @override
  String get order_requirement_q1_hint => '请尽可能详细地描述您的需求，包括具体要求、期望效果等';

  @override
  String get order_requirement_q1_helper => '如需提供参考资料，可在下方附件区域上传';

  @override
  String get order_requirement_q2 => '2. 补充说明（选填）';

  @override
  String get order_requirement_q2_hint => '如有其他补充说明或特殊要求，请在此填写';

  @override
  String get order_requirement_warning => '请认真填写需求，提交后卖家将根据您的需求开始服务';

  @override
  String get order_requirement_attachment_title => '附件上传';

  @override
  String order_requirement_attachment_limit(int maxCount, int maxSize) {
    return '最多$maxCount个文件，单个文件不超过${maxSize}MB';
  }

  @override
  String get order_requirement_add => '添加';

  @override
  String get order_requirement_click_select_file => '点击此处选择文件';

  @override
  String get order_requirement_confirm_submit => '确认提交';

  @override
  String get order_requirement_wait_upload => '请等待文件上传完成';

  @override
  String get order_requirement_upload_failed_title => '文件上传失败';

  @override
  String order_requirement_upload_failed_count(int count) {
    return '有$count个文件上传失败，是否重试？';
  }

  @override
  String get order_requirement_remove_failed => '移除失败文件';

  @override
  String get order_requirement_retry_upload => '重试上传';

  @override
  String get order_requirement_error_product_id => '错误：无法获取商品 ID';

  @override
  String get order_requirement_load_draft_failed => '加载草稿失败';

  @override
  String get order_requirement_save_draft_failed => '保存草稿失败';

  @override
  String order_requirement_max_files(int count) {
    return '最多只能上传$count个附件';
  }

  @override
  String order_requirement_pick_failed(String error) {
    return '选择文件失败: $error';
  }

  @override
  String get order_requirement_default_service => '基础服务';

  @override
  String get order_evaluation_title => '评价商品';

  @override
  String get order_evaluation_hint => '分享您的使用体验吧～';

  @override
  String get order_evaluation_add_images => '添加图片 (最多9张)';

  @override
  String get order_evaluation_anonymous => '匿名评价';

  @override
  String get order_evaluation_submit => '提交评价';

  @override
  String get order_evaluation_error_no_item => '错误：无法找到要评价的商品项';

  @override
  String get order_evaluation_max_images => '最多只能上传9张图片';

  @override
  String order_evaluation_success_count(int count, String ratio) {
    return '成功处理 $count 张图片，平均压缩 $ratio%';
  }

  @override
  String order_evaluation_failed_count(int count) {
    return '$count 张图片处理失败';
  }

  @override
  String order_evaluation_pick_failed(String error) {
    return '选择图片失败: $error';
  }

  @override
  String get order_evaluation_processing => '处理中...';

  @override
  String get order_evaluation_page_title => '评价订单';

  @override
  String get order_delivery_not_satisfied => '对交付不满意？';

  @override
  String get order_delivery_communicate_tip => '当前交付次数不足时，请先与卖家沟通是否同意再次交付';

  @override
  String get order_delivery_supplement => '我要补充';

  @override
  String get order_delivery_remake => '我要重新制作';

  @override
  String get order_delivery_refund => '我要退款';

  @override
  String get order_delivery_unknown_file => '未知文件';

  @override
  String order_item_delivery_days(int days) {
    return '交付天数: $days天';
  }

  @override
  String order_item_edit_count(int count) {
    return '可修改次数: $count次';
  }

  @override
  String get order_countdown_expired => '已超时';

  @override
  String order_countdown_days_hours(int days, int hours) {
    return '$days天$hours时';
  }

  @override
  String order_countdown_hours_minutes(int hours, int minutes) {
    return '$hours时$minutes分';
  }

  @override
  String order_countdown_minutes(int minutes) {
    return '$minutes分';
  }

  @override
  String order_countdown_seconds(int seconds) {
    return '$seconds秒';
  }

  @override
  String order_countdown_days(int days) {
    return '$days天';
  }

  @override
  String order_countdown_minutes_seconds(int minutes, int seconds) {
    return '$minutes分$seconds秒';
  }

  @override
  String order_upload_progress(int percent) {
    return '上传中 $percent%';
  }

  @override
  String get order_upload_retry => '重试上传';

  @override
  String order_upload_failed(String error) {
    return '上传失败: $error';
  }

  @override
  String order_upload_size_limit(String size) {
    return '文件大小超过限制（最大$size）';
  }

  @override
  String order_upload_max_retry(int count) {
    return '已达到最大重试次数（$count次）';
  }

  @override
  String get order_after_sale_processing => '售后处理中';

  @override
  String get order_after_sale_processing_msg =>
      '您的售后申请正在处理中，卖家将在xx小时内处理，请耐心等待。';

  @override
  String get order_after_sale_mediation => '平台介入处理中';

  @override
  String get order_after_sale_mediation_msg =>
      '平台客服已介入处理，将在xx工作日内给出处理结果，请留意通知。';

  @override
  String get order_after_sale_rejected => '售后申请已驳回';

  @override
  String get order_after_sale_rejected_msg => '抱歉，您的售后申请未通过审核。';

  @override
  String get order_after_sale_default_title => '售后状态';

  @override
  String get order_after_sale_default_msg => '当前订单处于售后流程中。';

  @override
  String get order_after_sale_contact_seller => '联系卖家';

  @override
  String get order_after_sale_cancel_apply => '取消申请';

  @override
  String get order_after_sale_contact_platform => '联系平台客服';

  @override
  String get order_after_sale_add_evidence => '补充凭证';

  @override
  String get order_after_sale_add_evidence_tip => '您可以补充凭证或耐心等待平台处理结果。';

  @override
  String get order_after_sale_apply_intervention => '申请平台介入';

  @override
  String get order_after_sale_refund_status => '退款状态:';

  @override
  String get order_after_sale_refund_amount => '退款金额:';

  @override
  String get order_after_sale_reject_reason => '驳回原因:';

  @override
  String get order_after_sale_reject_reason_detail => '原因：凭证不足或不符合退款条件。';

  @override
  String get order_platform_intervention_title => '平台介入';

  @override
  String get order_platform_intervention_desc => '如遇到争议无法协商解决，可申请平台客服介入处理';

  @override
  String get order_platform_intervention_apply => '申请平台介入';

  @override
  String get order_platform_intervention_in_progress => '平台介入中';

  @override
  String get order_platform_intervention_processing => '处理中';

  @override
  String get order_platform_intervention_processing_msg =>
      '您的申请已提交，平台客服会在24小时内联系您处理';

  @override
  String get order_platform_intervention_step1 => '申请已提交';

  @override
  String get order_platform_intervention_step1_desc => '等待平台客服处理';

  @override
  String get order_platform_intervention_step2 => '客服介入';

  @override
  String get order_platform_intervention_step2_desc => '24小时内联系双方';

  @override
  String get order_platform_intervention_step3 => '问题解决';

  @override
  String get order_platform_intervention_step3_desc => '根据平台判定处理';

  @override
  String get order_card_product_unknown => '商品名称未知';

  @override
  String get order_card_deleting => '正在删除订单...';

  @override
  String get order_card_deleted => '订单已删除';

  @override
  String order_card_delete_failed(String error) {
    return '删除失败：$error';
  }

  @override
  String get order_card_canceling => '正在取消订单...';

  @override
  String get order_card_canceled => '订单已取消';

  @override
  String order_card_cancel_failed(String error) {
    return '取消失败：$error';
  }

  @override
  String order_card_load_detail_failed(String error) {
    return '加载订单详情失败：$error';
  }

  @override
  String get order_card_timeout_canceling => '已超时，即将取消';

  @override
  String order_card_pay_in_time(String time) {
    return '请在$time内付款';
  }

  @override
  String get order_card_timeout_submit => '已超时，请尽快提交';

  @override
  String order_card_submit_in_time(String time) {
    return '请在$time内提交材料';
  }

  @override
  String get order_card_seller_timeout => '卖家超时未接单';

  @override
  String order_card_seller_accept_in_time(String time) {
    return '卖家将在$time内接单';
  }

  @override
  String order_card_delivery_days(int days) {
    return '交付时间：$days天内';
  }

  @override
  String get order_card_auto_confirm_soon => '即将自动确认收货';

  @override
  String order_card_auto_confirm_in(String time) {
    return '$time后自动确认';
  }

  @override
  String get order_card_evaluate_for_points => '待评价，评价后可获得积分';

  @override
  String order_card_duration_days_hours(int days, int hours) {
    return '$days天$hours小时';
  }

  @override
  String order_card_duration_hours_minutes(int hours, int minutes) {
    return '$hours小时$minutes分钟';
  }

  @override
  String order_card_duration_minutes(int minutes) {
    return '$minutes分钟';
  }

  @override
  String get order_card_duration_less_than_minute => '少于1分钟';

  @override
  String get order_detail_invalid_id => '无效的订单 ID';

  @override
  String get order_detail_error => '错误';

  @override
  String get order_detail_title => '订单详情';

  @override
  String order_detail_title_with_id(int id) {
    return '订单详情 (ID: $id)';
  }

  @override
  String order_detail_load_failed(String error) {
    return '加载失败: $error';
  }

  @override
  String get order_detail_reload => '重新加载';

  @override
  String get order_detail_unavailable => '订单数据不可用';

  @override
  String get order_list_title => '我的订单';

  @override
  String get order_list_search_hint => '搜索订单号或商品名称';

  @override
  String get order_list_empty => '暂无相关订单';

  @override
  String order_list_load_error(String error) {
    return '加载错误: $error';
  }

  @override
  String order_list_load_failed(String error) {
    return '加载失败: $error';
  }

  @override
  String get order_list_select_category => '请选择分类查看订单';

  @override
  String get order_list_tab_all => '全部';

  @override
  String get order_list_tab_awaiting_payment => '待付款';

  @override
  String get order_list_tab_awaiting_submission => '待提交';

  @override
  String get order_list_tab_awaiting_start => '待接单';

  @override
  String get order_list_tab_awaiting_delivery => '待交付';

  @override
  String get order_list_tab_awaiting_confirmation => '待收货';

  @override
  String get order_list_tab_awaiting_evaluation => '待评价';

  @override
  String get order_list_tab_after_sale => '售后中';

  @override
  String get order_route_error => '错误';

  @override
  String order_route_invalid_item_id(String id) {
    return '无效的商品ID: $id';
  }

  @override
  String order_seller_detail_title(int id) {
    return '订单详情 (卖家) - #$id';
  }

  @override
  String order_seller_load_failed(int id, String error) {
    return '加载订单 #$id 失败: $error';
  }

  @override
  String get order_seller_preparing => '正在准备加载...';

  @override
  String get order_seller_order_number => '订单编号';

  @override
  String get order_seller_order_time => '下单时间';

  @override
  String get order_seller_pay_time => '付款时间';

  @override
  String get order_seller_complete_time => '完成时间';

  @override
  String get order_seller_cancel_time => '取消时间';

  @override
  String get order_seller_list_title => '我的订单 (卖家)';

  @override
  String get order_seller_tab_all => '全部';

  @override
  String get order_seller_tab_awaiting_start => '待接单';

  @override
  String get order_seller_tab_awaiting_delivery => '待发货';

  @override
  String get order_seller_tab_awaiting_confirmation => '待确认收货';

  @override
  String get order_seller_tab_awaiting_evaluation => '待评价';

  @override
  String get order_seller_tab_completed => '已完成';

  @override
  String get order_seller_tab_after_sale => '售后中';

  @override
  String get order_seller_tab_canceled => '已取消';

  @override
  String order_seller_load_failed_msg(String error) {
    return '加载失败: $error';
  }

  @override
  String get order_seller_empty => '暂无此状态订单';

  @override
  String order_seller_action_failed(String error) {
    return '操作失败: $error';
  }

  @override
  String order_seller_pending_count(int count) {
    return '您有$count个订单待处理';
  }

  @override
  String order_seller_pending_awaiting_start(int count) {
    return '$count个待接单';
  }

  @override
  String order_seller_pending_awaiting_delivery(int count) {
    return '$count个待发货';
  }

  @override
  String get order_seller_reject_order => '拒绝接单';

  @override
  String get order_seller_confirm_order => '确认接单';

  @override
  String get order_seller_contact_buyer => '联系买家';

  @override
  String get order_seller_go_deliver => '去交付';

  @override
  String get order_seller_view_delivery_content => '查看交付内容';

  @override
  String get order_seller_remind_buyer => '提醒买家确认';

  @override
  String get order_seller_delete_record => '删除记录';

  @override
  String get order_seller_confirm_accept_title => '确认接单';

  @override
  String get order_seller_confirm_accept_content => '您确定要接受此订单吗？';

  @override
  String get order_seller_confirm_delete_title => '确认删除';

  @override
  String get order_seller_confirm_delete_content => '您确定要删除这条订单记录吗？此操作无法撤销。';

  @override
  String get order_seller_confirm_delete_canceled_content =>
      '您确定要删除这条已取消的订单记录吗？此操作无法撤销。';

  @override
  String get order_seller_confirm_btn => '确认';

  @override
  String get order_seller_confirm_reject_title => '确认拒绝';

  @override
  String get order_seller_confirm_reject_content => '您确定要拒绝接受此订单吗？';

  @override
  String get order_seller_confirm_reject_btn => '确认拒绝';

  @override
  String get order_seller_reject_dialog_title => '拒绝订单';

  @override
  String get order_seller_reject_reason_label => '拒绝理由 *';

  @override
  String get order_seller_reject_reason_hint => '请输入拒绝理由';

  @override
  String get order_seller_reject_reason_empty => '拒绝理由不能为空';

  @override
  String get order_seller_reject_reason_required => '请输入拒绝理由';

  @override
  String get order_seller_remarks_label => '补充说明 (可选)';

  @override
  String get order_seller_remarks_hint => '选填';

  @override
  String get order_seller_delivery_dialog_title => '交付内容';

  @override
  String get order_seller_delivery_desc_label => '交付说明 *';

  @override
  String get order_seller_delivery_desc_hint => '请描述您的交付内容';

  @override
  String get order_seller_delivery_desc_empty => '交付说明不能为空';

  @override
  String get order_seller_delivery_desc_required => '请输入交付说明';

  @override
  String get order_seller_delivery_attachment => '附件';

  @override
  String get order_seller_delivery_select_file => '点击下方按钮选择文件';

  @override
  String get order_seller_delivery_add_attachment => '添加附件';

  @override
  String get order_seller_delivery_file_select_soon => '文件选择功能即将实现';

  @override
  String get order_seller_delivery_confirm => '确认交付';

  @override
  String order_seller_delivery_chat_hint(String productName) {
    return '请选择关于商品\"$productName\"的聊天';
  }

  @override
  String get order_seller_dynamic_delivered => '服务已交付';

  @override
  String get order_seller_dynamic_delivered_msg =>
      '您已完成服务交付，请等待买家确认。如有问题，买家可能会发起售后。';

  @override
  String get order_seller_dynamic_completed => '此订单已顺利完成。';

  @override
  String get order_seller_dynamic_canceled => '此订单已被取消。';

  @override
  String get order_seller_dynamic_refused => '已申请拒绝订单';

  @override
  String get order_seller_dynamic_refused_msg => '您的拒绝申请已提交，正在等待处理。';

  @override
  String get order_seller_buyer_materials => '买家提供的材料';

  @override
  String get order_seller_attachment_label => '附件:';

  @override
  String order_seller_view_attachment(String fileName) {
    return '查看附件功能待实现: $fileName';
  }

  @override
  String get order_evaluation_product_info => '商品信息';

  @override
  String get order_list_retry => '重试';

  @override
  String chat_get_user_info_failed(String error) {
    return '获取用户信息失败: $error';
  }

  @override
  String get chat_user_refer_id_not_found => '用户referId未找到';

  @override
  String get chat_no_chat_records => '暂无聊天记录';

  @override
  String get chat_opponent_info_missing => '对方信息不存在';

  @override
  String get chat_product_default => '商品';

  @override
  String get chat_view_details => '查看详情';

  @override
  String get chat_product_info_incomplete => '商品信息不完整，无法查看详情';

  @override
  String get chat_uploading => '上传中...';

  @override
  String get chat_upload_failed => '上传失败';

  @override
  String get chat_retry => '重试';

  @override
  String get chat_image_loading => '加载中...';

  @override
  String get chat_image_load_failed => '加载失败';

  @override
  String get chat_revoke_time_missing => '消息时间信息缺失，无法撤回';

  @override
  String get chat_revoke_available => '可以撤回';

  @override
  String chat_revoke_expired(int seconds) {
    return '消息发送已超过2分钟，无法撤回（超出$seconds秒）';
  }

  @override
  String get chat_unknown_seller => '未知卖家';

  @override
  String get chat_product_conversation => '商品对话';

  @override
  String chat_product_conversation_count(int count) {
    return '$count个商品对话';
  }

  @override
  String get chat_unknown_product => '未知商品';

  @override
  String chat_user_inquiry_count(int count) {
    return '$count个用户咨询';
  }

  @override
  String get chat_weekday_mon => '周一';

  @override
  String get chat_weekday_tue => '周二';

  @override
  String get chat_weekday_wed => '周三';

  @override
  String get chat_weekday_thu => '周四';

  @override
  String get chat_weekday_fri => '周五';

  @override
  String get chat_weekday_sat => '周六';

  @override
  String get chat_weekday_sun => '周日';

  @override
  String get chat_select_multiple_images => '选择多张图片';

  @override
  String chat_image_compressed(String ratio) {
    return '图片已压缩 $ratio%';
  }

  @override
  String chat_image_process_failed(String error) {
    return '图片处理失败: $error';
  }

  @override
  String chat_images_processed_success(int count, String ratio) {
    return '成功处理 $count 张图片，平均压缩 $ratio%';
  }

  @override
  String chat_images_process_failed_count(int count) {
    return '$count 张图片处理失败';
  }

  @override
  String get chat_tap_to_view_product => '点击查看商品详情';

  @override
  String chat_yesterday_time(String time) {
    return '昨天 $time';
  }

  @override
  String get chat_no_messages_brief => '暂无消息';

  @override
  String chat_select_image_error(String error) {
    return '选择图片出错: $error';
  }

  @override
  String get after_sales_reason_none => '无';

  @override
  String seller_auth_status_title(String type) {
    return '$type认证';
  }

  @override
  String get seller_auth_status_label => '认证状态：';

  @override
  String get seller_auth_status_name_label => '认证名称：';

  @override
  String get seller_auth_status_materials => '认证材料';

  @override
  String get seller_auth_status_no_materials => '暂无认证材料';

  @override
  String get seller_auth_status_info => '认证信息';

  @override
  String get seller_auth_status_history => '认证历史';

  @override
  String get seller_auth_status_no_history => '暂无历史记录';

  @override
  String get seller_auth_status_reapply => '重新认证';

  @override
  String get seller_auth_status_approved_hint => '认证已通过，无需重复提交';

  @override
  String get seller_auth_status_pending_hint => '认证审核中，请耐心等待';

  @override
  String get seller_auth_status_tag_approved => '已认证';

  @override
  String get seller_auth_status_tag_pending => '审核中';

  @override
  String get seller_auth_status_tag_rejected => '未通过';

  @override
  String get seller_auth_status_tag_not_submitted => '未提交';

  @override
  String get seller_auth_status_type_idcard => '身份';

  @override
  String get seller_auth_status_type_education => '学历';

  @override
  String get seller_auth_status_type_profession => '职业';

  @override
  String get seller_auth_status_type_company => '公司';

  @override
  String get seller_auth_status_type_other => '其他';

  @override
  String get seller_auth_status_field_auth_name => '认证名称';

  @override
  String get seller_auth_status_field_auth_type => '认证类型';

  @override
  String get seller_auth_status_field_company_name => '公司名称';

  @override
  String get seller_auth_status_field_name => '姓名';

  @override
  String get seller_auth_status_field_school_name => '学校名称';

  @override
  String get seller_auth_status_field_profession => '职业/职位';

  @override
  String get seller_auth_status_field_name_or_title => '姓名/名称';

  @override
  String get seller_auth_status_field_remarks => '备注';

  @override
  String get seller_auth_status_field_cert_number => '证书编号';

  @override
  String get seller_auth_status_field_work_experience => '工作经验';

  @override
  String get seller_auth_status_field_issuer => '发证机构';

  @override
  String get seller_auth_status_field_credit_code => '统一社会信用代码';

  @override
  String get seller_auth_status_field_legal_rep => '法人代表';

  @override
  String get seller_auth_status_field_registered_capital => '注册资本';

  @override
  String get seller_auth_status_field_establishment_date => '成立日期';

  @override
  String get seller_auth_status_field_degree => '学历';

  @override
  String get seller_auth_status_field_major => '专业';

  @override
  String get seller_auth_status_field_graduation_year => '毕业年份';

  @override
  String get seller_auth_status_field_id_number => '身份证号';

  @override
  String get seller_auth_status_field_valid_period => '有效期';

  @override
  String get seller_auth_status_field_submit_time => '提交时间';

  @override
  String get seller_auth_status_field_reject_reason => '拒绝原因';

  @override
  String get seller_auth_status_history_approved_title => '认证申请通过';

  @override
  String seller_auth_status_history_approved_desc(String type) {
    return '您的$type认证申请已通过审核，现在您可以享受认证商家的所有权益。';
  }

  @override
  String get seller_auth_status_history_submitted_title => '提交认证申请';

  @override
  String seller_auth_status_history_submitted_desc(String type) {
    return '您已成功提交$type认证申请，我们将在1-3个工作日内完成审核。';
  }

  @override
  String get seller_auth_status_history_rejected_title => '认证申请未通过';

  @override
  String seller_auth_status_history_rejected_desc(String type, String reason) {
    return '您的$type认证申请未通过审核。原因：$reason';
  }

  @override
  String get seller_auth_status_history_rejected_default_reason => '资料不符合要求';

  @override
  String get seller_product_preview_title => '商品预览';

  @override
  String get seller_product_preview_back_to_edit => '返回编辑';

  @override
  String get seller_product_preview_loading => '正在加载商品信息...';

  @override
  String get seller_product_preview_load_failed => '加载商品信息失败';

  @override
  String get seller_product_preview_retry => '重试';

  @override
  String get seller_product_preview_fetching => '正在获取商品数据...';

  @override
  String get seller_product_preview_hint => '这是商品预览模式，买家将看到类似的界面';

  @override
  String get seller_product_edit_unsaved_changes_title => '检测到未保存的更改';

  @override
  String get seller_product_edit_unsaved_changes_message =>
      '您有未保存的内容，是否要保存为草稿？';

  @override
  String get seller_product_edit_cancel => '取消';

  @override
  String get seller_product_edit_discard => '不保存';

  @override
  String get seller_product_edit_operation_failed => '操作失败';

  @override
  String get seller_product_edit_draft_saved => '草稿保存成功';

  @override
  String get seller_product_edit_publish_success =>
      '服务发布成功！正在审核中，请在\"在售\"列表中查看';

  @override
  String get seller_product_edit_update_success => '服务更新成功';

  @override
  String get seller_product_edit_max_images => '最多只能上传9张图片，已选择前9张';

  @override
  String seller_product_edit_price_required(String tierName) {
    return '$tierName价格必须大于0';
  }

  @override
  String get seller_product_edit_form_incomplete => '表单数据不完整，请检查标红字段';

  @override
  String get seller_product_edit_add_attribute => '添加属性';

  @override
  String seller_product_edit_attribute_max_chars(int max) {
    return '属性名称最多$max个字符';
  }

  @override
  String get seller_product_edit_confirm => '确定';

  @override
  String get seller_product_edit_options_config => '选项配置';

  @override
  String get seller_product_edit_new_option => '新选项';

  @override
  String get seller_product_edit_option_hint => '输入选项内容';

  @override
  String get seller_product_edit_service_name_hint => '服务名称';

  @override
  String get seller_product_edit_description_hint => '描述一下您的服务的具体信息，如...';

  @override
  String get seller_product_edit_faq_title => '常见问题编辑';

  @override
  String seller_product_edit_faq_count(int count) {
    return '$count个问题';
  }

  @override
  String get seller_product_edit_add_question => '添加问题';

  @override
  String get seller_product_edit_question_label => '问题';

  @override
  String get seller_product_edit_question_hint => '输入买家可能问的问题';

  @override
  String get seller_product_edit_delete_question => '删除问题';

  @override
  String get seller_product_edit_answer_label => '答案';

  @override
  String get seller_product_edit_answer_hint => '输入对应的答案';

  @override
  String get seller_product_edit_buyer_info_title => '需要买家提供';

  @override
  String seller_product_edit_buyer_info_count(int count) {
    return '$count项信息';
  }

  @override
  String get seller_product_edit_buyer_info_desc =>
      '选择你需要买家提供的信息类型（该信息将展示在订单详情页）';

  @override
  String get seller_product_edit_selected_items => '已选择的信息项：';

  @override
  String get seller_product_edit_required => '必填';

  @override
  String get seller_product_edit_edit_tooltip => '编辑';

  @override
  String get seller_product_edit_delete_tooltip => '删除';

  @override
  String seller_product_edit_add_info_title(String type) {
    return '添加$type信息';
  }

  @override
  String get seller_product_edit_info_label => '信息标签';

  @override
  String get seller_product_edit_info_label_hint => '例如：公司Logo设计需求';

  @override
  String get seller_product_edit_info_description => '详细说明';

  @override
  String get seller_product_edit_info_description_hint => '请详细说明需要买家提供的信息内容';

  @override
  String get seller_product_edit_required_field => '必填项';

  @override
  String get seller_product_edit_add => '添加';

  @override
  String seller_product_edit_edit_info_title(String type) {
    return '编辑$type信息';
  }

  @override
  String get seller_product_edit_save => '保存';

  @override
  String seller_product_edit_cases_count(int count) {
    return '$count个案例';
  }

  @override
  String get seller_product_edit_add_case => '添加案例';

  @override
  String get seller_product_edit_image_load_failed => '图片加载失败';

  @override
  String get seller_product_edit_click_select_image => '点击选择图片';

  @override
  String get seller_product_edit_upload_failed => '上传失败';

  @override
  String get seller_product_edit_upload_retry => '重试';

  @override
  String get seller_product_edit_case_title_label => '案例标题';

  @override
  String get seller_product_edit_case_title_hint => '简短描述这个案例';

  @override
  String get seller_product_edit_case_desc_label => '案例描述';

  @override
  String get seller_product_edit_case_desc_hint => '详细描述案例的背景、执行过程或效果';

  @override
  String get seller_product_edit_select_image_and_title => '请选择图片并输入标题';

  @override
  String get seller_product_edit_cover_image => '服务封面图';

  @override
  String get seller_product_edit_upload_success => '上传成功';

  @override
  String seller_product_edit_upload_error(String error) {
    return '上传错误: $error';
  }

  @override
  String get seller_product_edit_image_format_hint =>
      '支持jpg、png、jpeg格式，单张不超过5MB，最多可上传9张图片';

  @override
  String get seller_product_edit_main_image => '主图';

  @override
  String seller_product_edit_tier_price_label(String tierName) {
    return '$tierName价格';
  }

  @override
  String seller_product_edit_max_price(String max) {
    return '最大值：$max';
  }

  @override
  String seller_product_edit_price_exceed_max(String max) {
    return '价格不能超过$max';
  }

  @override
  String get seller_product_edit_price_min => '价格最小值为0.01';

  @override
  String get seller_product_edit_delivery_period => '交付期';

  @override
  String get seller_product_edit_delivery_days_suffix => '天';

  @override
  String seller_product_edit_max_days(int max) {
    return '最多$max天';
  }

  @override
  String get seller_product_edit_times => '次数';

  @override
  String get seller_product_edit_times_suffix => '次';

  @override
  String seller_product_edit_max_times(int max) {
    return '最多$max次';
  }

  @override
  String get seller_product_edit_input => '输入';

  @override
  String get seller_product_edit_radio => '单选';

  @override
  String get seller_product_edit_draft_label => '草稿';

  @override
  String get seller_product_edit_draft_unsaved_label => '草稿*';

  @override
  String get seller_product_edit_publish => '发布';

  @override
  String get seller_product_edit_yes => '是';

  @override
  String get seller_product_edit_no => '否';

  @override
  String get seller_product_edit_add_selection_attribute => '添加单选属性';

  @override
  String get seller_product_edit_default_options_yes_no => '默认选项：是/否';

  @override
  String get seller_product_edit_attribute_name_label => '属性名称 *';

  @override
  String get seller_product_edit_attribute_name_example => '例如：颜色、型号、材质、适用年龄';

  @override
  String get seller_product_edit_attribute_type_label => '属性类型';

  @override
  String get seller_product_edit_required_item => '必填项';

  @override
  String seller_product_card_sales(int count) {
    return '销量: $count';
  }

  @override
  String get seller_product_card_view => '查看';

  @override
  String get seller_image_preview_main_image => '主图';

  @override
  String get seller_image_preview_set_main => '设为主图';

  @override
  String get seller_image_preview_load_failed => '图片加载失败';

  @override
  String get seller_image_preview_delete_title => '删除图片';

  @override
  String seller_image_preview_delete_confirm(int index) {
    return '确定要删除第 $index 张图片吗？';
  }

  @override
  String get seller_image_preview_delete => '删除';

  @override
  String get seller_file_select => '选择文件';

  @override
  String get seller_file_selected => '已选择的文件:';

  @override
  String seller_file_size(String size) {
    return '大小: $size';
  }

  @override
  String get seller_file_size_unknown => '无法获取大小';

  @override
  String seller_file_preview_unsupported(String name) {
    return '无法预览该类型文件: $name';
  }

  @override
  String get seller_common_cancel => '取消';

  @override
  String get profile_user_name_default => '用户名';

  @override
  String get profile_buyer_mode => '买家模式';

  @override
  String get profile_my_orders => '我的订单';

  @override
  String get profile_my_dskk_section => '我的关看';

  @override
  String get profile_liked_stories => '点赞的故事';

  @override
  String get profile_logout => '退出登录';

  @override
  String get profile_avatar_updated_local => '头像已更新，但尚未保存到服务器';

  @override
  String profile_image_pick_error(String error) {
    return '选择图片时出错: $error';
  }

  @override
  String profile_feature_not_implemented(String feature) {
    return '$feature功能尚未实现';
  }

  @override
  String get profile_pending_payment_order => '待付款';

  @override
  String get profile_in_progress_order => '进行中';

  @override
  String get profile_completed_order => '已完成';

  @override
  String get profile_refund_after_sales => '退款/售后';

  @override
  String get profile_account_deletion => '账号注销';

  @override
  String get profile_bound_phone => '已绑定手机号';

  @override
  String get profile_not_bound => '未绑定';

  @override
  String get profile_nickname => '昵称';

  @override
  String get profile_confirm_logout => '确认退出';

  @override
  String get profile_confirm_logout_message => '确定要退出登录吗？';

  @override
  String get profile_confirm => '确定';

  @override
  String get profile_update_avatar => '更新头像';

  @override
  String get profile_update_avatar_confirm => '确定要更新头像吗？';

  @override
  String get profile_info_updated => '个人信息更新成功！';

  @override
  String get profile_avatar_upload_timeout => '头像上传超时，请检查网络连接后重试';

  @override
  String get profile_network_failed => '网络连接失败，请检查网络后重试';

  @override
  String profile_avatar_optimized(String ratio) {
    return '头像已优化处理，压缩 $ratio%';
  }

  @override
  String profile_avatar_process_failed(String error) {
    return '头像处理失败: $error';
  }

  @override
  String profile_logout_error(String error) {
    return '退出登录时发生错误: $error';
  }

  @override
  String get profile_nickname_empty => '请输入昵称';

  @override
  String get profile_nickname_too_short => '昵称至少需要2个字符';

  @override
  String get profile_nickname_too_long => '昵称不能超过20个字符';

  @override
  String get profile_nickname_no_spaces => '昵称不能包含空格';

  @override
  String get profile_nickname_invalid_chars => '昵称只能包含中文、英文、数字和下划线';

  @override
  String get profile_nickname_only_underscores => '昵称不能只包含下划线';

  @override
  String get profile_nickname_unchanged => '昵称没有变化';

  @override
  String get profile_edit_nickname_title => '编辑昵称';

  @override
  String get profile_nickname_input_hint => '请输入昵称';

  @override
  String get profile_nickname_rules => '请设置2-20个字符，只能包含中文、英文、数字和下划线';

  @override
  String get profile_nickname_updated => '昵称修改成功！';

  @override
  String profile_nickname_update_failed(String error) {
    return '昵称修改失败: $error';
  }

  @override
  String get profile_submit_changes => '提交修改';

  @override
  String get profile_avatar_uploaded => '头像上传成功';

  @override
  String get profile_updated => '个人资料更新成功';

  @override
  String get profile_reload => '重新加载';

  @override
  String get profile_account_balance => '账户余额';

  @override
  String get profile_pending_settlement => '待结算';

  @override
  String get profile_total_income => '总收入';

  @override
  String get profile_load_wallet => '点击加载钱包信息';

  @override
  String get profile_all_orders => '全部订单';

  @override
  String get profile_awaiting_payment => '待付款';

  @override
  String get profile_awaiting_shipment => '待发货';

  @override
  String get profile_awaiting_receipt => '待收货';

  @override
  String get profile_awaiting_review => '待评价';

  @override
  String get profile_shipping_address => '收货地址';

  @override
  String get profile_browsing_history => '浏览历史';

  @override
  String get profile_contact_support => '联系客服';

  @override
  String get profile_help_center => '帮助中心';

  @override
  String get profile_feedback => '意见反馈';

  @override
  String get profile_switch_to_seller_mode => '切换至卖家模式';

  @override
  String get profile_take_photo => '拍照';

  @override
  String get profile_choose_from_album => '从相册选择';

  @override
  String profile_image_pick_failed(String error) {
    return '选择图片失败: $error';
  }

  @override
  String get profile_edit_profile => '编辑个人资料';

  @override
  String get profile_online_status => '在线状态';

  @override
  String get profile_mission_title => '小帮手的使命';

  @override
  String get profile_mission_our_mission => '我们的使命';

  @override
  String get profile_mission_our_mission_content =>
      '连接创意与需求，让每一个想法都能找到实现的可能。小帮手致力于为用户提供最贴心、最智能的服务体验，成为您生活和工作中最可靠的数字伙伴。';

  @override
  String get profile_mission_core_values => '核心价值';

  @override
  String get profile_mission_core_values_content =>
      '• 用户至上：始终以用户需求为出发点\n• 创新驱动：持续探索新技术和新方法\n• 诚信服务：提供可靠、透明的服务体验\n• 共同成长：与用户和合作伙伴携手前行';

  @override
  String get profile_mission_service_promise => '服务承诺';

  @override
  String get profile_mission_service_promise_content =>
      '我们承诺为每一位用户提供：\n\n✓ 7×24小时智能服务支持\n✓ 个性化的解决方案推荐\n✓ 安全可靠的数据保护\n✓ 持续优化的用户体验\n✓ 及时响应的客户服务';

  @override
  String get profile_mission_future_vision => '未来愿景';

  @override
  String get profile_mission_future_vision_content =>
      '成为全球领先的智能服务平台，通过AI技术赋能，让每个人都能享受到个性化、高效率的数字化生活体验。我们相信，科技的力量应该让生活更美好，让创意更容易实现。';

  @override
  String get profile_mission_questions_suggestions => '有问题或建议？';

  @override
  String get profile_mission_listening => '我们随时倾听您的声音，期待与您一起创造更美好的未来。';

  @override
  String get profile_mission_contact_us => '联系我们';

  @override
  String get profile_mission_contact_coming_soon => '联系功能即将上线，敬请期待！';

  @override
  String get profile_wallet_title => '我的钱包';

  @override
  String profile_wallet_error(String error) {
    return '错误: $error';
  }

  @override
  String profile_wallet_occurred_error(String error) {
    return '发生错误: $error';
  }

  @override
  String get profile_wallet_retry => '重试';

  @override
  String get profile_wallet_filter_all => '全部';

  @override
  String get profile_wallet_filter_income => '收入';

  @override
  String get profile_wallet_filter_expense => '支出';

  @override
  String get profile_wallet_no_transactions => '暂无交易记录';

  @override
  String profile_wallet_load_failed(String error) {
    return '加载失败: $error';
  }

  @override
  String profile_wallet_load_more_failed(String error) {
    return '加载更多失败: $error';
  }

  @override
  String get profile_wallet_account_balance => '账户余额';

  @override
  String get profile_wallet_pending_amount => '待结算金额';

  @override
  String get profile_wallet_total_income => '总收入';

  @override
  String get profile_wallet_withdraw => '提现';

  @override
  String get profile_wallet_status_completed => '已完成';

  @override
  String get profile_wallet_status_pending => '处理中';

  @override
  String get profile_wallet_status_failed => '失败';

  @override
  String get profile_wallet_status_unknown => '未知';

  @override
  String get profile_wallet_transaction_details => '交易详情';

  @override
  String get profile_wallet_transaction_id => '交易ID';

  @override
  String get profile_wallet_transaction_type => '类型';

  @override
  String get profile_wallet_transaction_type_income => '收入';

  @override
  String get profile_wallet_transaction_type_expense => '支出';

  @override
  String get profile_wallet_transaction_amount => '金额';

  @override
  String get profile_wallet_transaction_description => '说明';

  @override
  String get profile_wallet_transaction_date => '日期';

  @override
  String get profile_wallet_transaction_status => '状态';

  @override
  String get profile_wallet_close => '关闭';

  @override
  String profile_wallet_available_balance(String symbol, String amount) {
    return '可提现余额: $symbol$amount';
  }

  @override
  String get profile_wallet_withdraw_amount => '提现金额';

  @override
  String get profile_wallet_withdraw_hint => '请输入提现金额';

  @override
  String get profile_wallet_withdraw_time => '提现到账时间：1-3个工作日';

  @override
  String get profile_wallet_invalid_amount => '请输入有效的提现金额';

  @override
  String get profile_wallet_exceed_balance => '提现金额不能超过可用余额';

  @override
  String get profile_wallet_confirm_withdraw => '确认提现';

  @override
  String profile_wallet_withdraw_submitted(String symbol, String amount) {
    return '提现申请已提交：$symbol$amount';
  }

  @override
  String get profile_wallet_not_implemented => '该功能暂未实现';

  @override
  String get auth_verification_expired => '验证码已过期';

  @override
  String auth_login_failed(String error) {
    return '登录失败: $error';
  }

  @override
  String auth_code_send_failed(String error) {
    return '验证码发送失败: $error';
  }

  @override
  String get auth_login_success => '登录成功!';

  @override
  String get auth_login => '登录';

  @override
  String get auth_privacy_policy => '隐私政策';

  @override
  String get auth_and => '和';

  @override
  String get auth_user_agreement => '用户协议';

  @override
  String get auth_invalid_phone => '请输入有效的11位手机号';

  @override
  String get auth_get_code => '获取验证码';

  @override
  String get payment_creating_order => '创建订单中...';

  @override
  String get payment_processing => '支付中...';

  @override
  String get payment_credit_card => '信用卡支付';

  @override
  String get payment_confirm_order => '确认订单';

  @override
  String get payment_quantity_label => '数量:';

  @override
  String get payment_order_summary => '订单摘要';

  @override
  String get payment_product_amount => '商品金额';

  @override
  String get payment_quantity => '数量';

  @override
  String get payment_order_total => '订单总计';

  @override
  String get payment_method => '支付方式';

  @override
  String get payment_processing_ellipsis => '处理中...';

  @override
  String get payment_confirm_pay => '确认支付';

  @override
  String get payment_success => '支付成功';

  @override
  String get payment_failed => '支付失败';

  @override
  String get payment_view_order_detail => '查看订单详情';

  @override
  String get payment_back_to_orders => '返回订单列表';

  @override
  String get payment_success_tip => '感谢您的购买！您可以在订单中查看详情。';

  @override
  String get payment_failed_tip => '支付未成功，请重试或选择其他支付方式。';

  @override
  String get home_banner_image_load_failed => '图片加载失败';

  @override
  String home_banner_placeholder(int index) {
    return '轮播图 $index';
  }

  @override
  String get home_no_data => '暂无数据';

  @override
  String get product_detail_no_faq => '暂无常见问题';

  @override
  String product_detail_buy_button(String price) {
    return '一键购买 $price';
  }

  @override
  String get product_detail_buyer_requirements => '需要买家提供';

  @override
  String get product_detail_no_buyer_requirements => '卖家暂未设置需要买家提供的信息';

  @override
  String get after_sales_apply => '申请售后';

  @override
  String get after_sales_apply_remake => '申请重新制作';

  @override
  String get after_sales_apply_supplement => '申请补充';

  @override
  String get after_sales_apply_refund => '申请退款';

  @override
  String after_sales_max_images(int max) {
    return '最多只能上传 $max 张图片';
  }

  @override
  String after_sales_images_processed(int count, String ratio) {
    return '成功处理 $count 张图片，平均压缩 $ratio%';
  }

  @override
  String after_sales_images_failed(int count) {
    return '$count 张图片处理失败';
  }

  @override
  String after_sales_image_pick_failed(String error) {
    return '选择图片失败: $error';
  }

  @override
  String get after_sales_select_reason => '请选择售后原因';

  @override
  String get after_sales_reason_label => '售后原因';

  @override
  String get after_sales_reason_quality => '商品质量问题';

  @override
  String get after_sales_reason_mismatch => '商品与描述不符';

  @override
  String get after_sales_reason_wrong_item => '卖家发错货';

  @override
  String get after_sales_reason_unwanted => '不想要了';

  @override
  String get after_sales_reason_other => '其他';

  @override
  String get after_sales_description_label => '问题描述';

  @override
  String get after_sales_description_hint => '请详细描述您遇到的问题...';

  @override
  String after_sales_refund_max_hint(String symbol, String amount) {
    return '最多可退 $symbol$amount';
  }

  @override
  String get after_sales_enter_refund_amount => '请输入退款金额';

  @override
  String get after_sales_invalid_amount => '请输入有效的金额数字';

  @override
  String get after_sales_amount_must_positive => '退款金额必须大于0';

  @override
  String after_sales_amount_exceed(String symbol, String amount) {
    return '退款金额不能超过 $symbol$amount';
  }

  @override
  String after_sales_upload_proof(int max) {
    return '上传凭证 (最多 $max 张)';
  }

  @override
  String get after_sales_remove_image => '移除图片';

  @override
  String get after_sales_submit => '提交申请';

  @override
  String after_sales_loading_failed(String error) {
    return '加载失败: $error';
  }

  @override
  String get after_sales_detail_retry => '重试';

  @override
  String get after_sales_initializing => '正在初始化...';

  @override
  String get after_sales_status_audit_reject => '售后申请已拒绝';

  @override
  String get after_sales_status_refund_success => '退款成功';

  @override
  String get after_sales_status_processing => '售后处理中';

  @override
  String get after_sales_subtitle_wait_audit => '卖家会在48小时内处理您的申请';

  @override
  String get after_sales_subtitle_audit_pass => '退款将在1-3个工作日内到账';

  @override
  String get after_sales_subtitle_audit_reject => '如有异议，可申请平台介入';

  @override
  String get after_sales_subtitle_refund_success => '退款已完成，请查收';

  @override
  String get after_sales_subtitle_canceled => '您已取消售后申请';

  @override
  String get after_sales_subtitle_default => '请耐心等待处理结果';

  @override
  String get after_sales_product_info => '商品信息';

  @override
  String get after_sales_product_unknown => '商品名称未知';

  @override
  String after_sales_spec(String spec) {
    return '规格：$spec';
  }

  @override
  String after_sales_quantity(int count) {
    return '数量：$count';
  }

  @override
  String get after_sales_info => '售后信息';

  @override
  String get after_sales_application_number => '申请单号';

  @override
  String get after_sales_application_time => '申请时间';

  @override
  String get after_sales_refund_amount_label => '退款金额';

  @override
  String get after_sales_application_reason => '申请原因';

  @override
  String get after_sales_detailed_description => '详细说明';

  @override
  String get after_sales_audit_remark => '审核备注';

  @override
  String get after_sales_revoke => '撤销申请';

  @override
  String get after_sales_modify => '修改申请';

  @override
  String get after_sales_platform_intervention => '平台介入';

  @override
  String get after_sales_list_title => '售后列表';

  @override
  String get after_sales_no_records => '暂无售后申请记录';

  @override
  String get after_sales_please_wait => '请稍候...';

  @override
  String get after_sales_unknown_product => '未知商品';

  @override
  String after_sales_status_label(String status) {
    return '状态: $status';
  }

  @override
  String get after_sales_select_type => '选择售后类型';

  @override
  String get after_sales_type_remake => '我要重新制作';

  @override
  String get after_sales_type_remake_desc => '对收到的制作不满意，可与作者协商重做';

  @override
  String get after_sales_type_supplement => '我要补充';

  @override
  String get after_sales_type_supplement_desc => '收到的制作不完善，可与作者协商补充';

  @override
  String get after_sales_type_refund => '我要退款';

  @override
  String get after_sales_type_refund_desc => '协商退款';

  @override
  String get after_sales_no_record_for_order => '该订单没有对应的售后记录';

  @override
  String after_sales_unknown_error(String error) {
    return '加载售后详情时发生未知错误: $error';
  }

  @override
  String get after_sales_server_error => '服务器错误';

  @override
  String get after_sales_cache_error => '缓存错误';

  @override
  String get after_sales_network_error => '网络连接错误';

  @override
  String get after_sales_general_unknown_error => '发生未知错误';

  @override
  String get favorites_title => '我的收藏';

  @override
  String get favorites_tab_services => '服务';

  @override
  String get favorites_tab_sellers => '卖家';

  @override
  String get favorites_close => '关闭';

  @override
  String get favorites_empty_services => '暂无收藏的服务';

  @override
  String get favorites_empty_sellers => '暂无关注的卖家';

  @override
  String get favorites_empty_services_hint => '您可以在浏览服务时点击收藏按钮';

  @override
  String get favorites_empty_sellers_hint => '您可以在浏览卖家时点击关注按钮';

  @override
  String get favorites_unfollow => '取消关注';

  @override
  String get favorites_remove => '取消收藏';

  @override
  String get favorites_seller_type_member => '个人卖家';

  @override
  String get favorites_seller_type_enterprise => '企业卖家';

  @override
  String get favorites_seller_type_platform => '平台卖家';

  @override
  String get favorites_seller_type_default => '卖家';

  @override
  String get favorites_status_active => '活跃';

  @override
  String get favorites_status_inactive => '不活跃';

  @override
  String get favorites_status_suspended => '已暂停';

  @override
  String get favorites_status_banned => '已封禁';

  @override
  String ai_docs_chat_create_failed(String error) {
    return '无法创建聊天会话: $error';
  }

  @override
  String get ai_docs_chat_room_empty => '聊天室ID为空，无法进入聊天';

  @override
  String ai_docs_chat_enter_error(String error) {
    return '进入聊天时发生错误: $error';
  }

  @override
  String get ai_docs_rate_limit_details => '使用次数详情';

  @override
  String ai_docs_rate_limit_remaining(int count) {
    return '剩余 $count 次';
  }

  @override
  String ai_docs_rate_limit_reset_in(String time) {
    return '$time后重置';
  }

  @override
  String get ai_docs_rate_limit_rules => '使用规则';

  @override
  String get ai_docs_rate_limit_burst => '突发限制';

  @override
  String get ai_docs_rate_limit_hourly => '小时限制';

  @override
  String get ai_docs_rate_limit_upgrade => '升级获取更多次数';

  @override
  String get ai_docs_rate_limit_upgrade_coming => '升级功能即将推出';

  @override
  String ai_docs_rate_limit_time_hours(int hours) {
    return '$hours小时';
  }

  @override
  String ai_docs_rate_limit_time_minutes(int minutes) {
    return '$minutes分钟';
  }

  @override
  String ai_docs_rate_limit_time_seconds(int seconds) {
    return '$seconds秒';
  }

  @override
  String get ai_docs_rate_limit_reset => '已重置';

  @override
  String get ai_docs_rate_limit_warning_title => '使用次数即将耗尽';

  @override
  String get ai_docs_rate_limit_today_remaining => '今日剩余次数';

  @override
  String ai_docs_rate_limit_remaining_info(int count, String time) {
    return '还可使用 $count 次，$time后重置';
  }

  @override
  String get ai_docs_rate_limit_today_usage => '今日使用情况';

  @override
  String get auth_verification_code_expired => '验证码已过期';

  @override
  String get auth_get_verification_code => '获取验证码';

  @override
  String get home_image_load_failed => '图片加载失败';

  @override
  String get home_reached_end => '已经到底了';

  @override
  String get home_reviews_title => '评论';

  @override
  String home_reviews_load_failed(String error) {
    return '加载失败: $error';
  }

  @override
  String get home_reviews_no_reviews => '暂无评论';

  @override
  String get home_reviews_default_content => '不错，很有耐心';

  @override
  String get home_reviews_seller_reply => '卖家回复';

  @override
  String home_reviews_years_ago(int count) {
    return '$count年前';
  }

  @override
  String home_reviews_months_ago(int count) {
    return '$count月前';
  }

  @override
  String home_reviews_days_ago(int count) {
    return '$count天前';
  }

  @override
  String home_reviews_hours_ago(int count) {
    return '$count小时前';
  }

  @override
  String home_reviews_minutes_ago(int count) {
    return '$count分钟前';
  }

  @override
  String get home_reviews_just_now => '刚刚';

  @override
  String get after_sales_apply_title => '申请售后';

  @override
  String get after_sales_select_reason_hint => '请选择售后原因';

  @override
  String get after_sales_select_reason_validator => '请选择售后原因';

  @override
  String after_sales_refund_amount_hint(String symbol, String amount) {
    return '最多可退 $symbol$amount';
  }

  @override
  String get after_sales_refund_amount_required => '请输入退款金额';

  @override
  String get after_sales_refund_amount_invalid => '请输入有效的金额数字';

  @override
  String get after_sales_refund_amount_positive => '退款金额必须大于0';

  @override
  String after_sales_refund_amount_exceed(String symbol, String amount) {
    return '退款金额不能超过 $symbol$amount';
  }

  @override
  String after_sales_upload_evidence(int max) {
    return '上传凭证 (最多 $max 张)';
  }

  @override
  String after_sales_image_process_success(int count, String ratio) {
    return '成功处理 $count 张图片，平均压缩 $ratio%';
  }

  @override
  String after_sales_image_process_failed(int count) {
    return '$count 张图片处理失败';
  }

  @override
  String after_sales_detail_load_failed(String error) {
    return '加载失败: $error';
  }

  @override
  String get after_sales_detail_initializing => '正在初始化...';

  @override
  String get after_sales_info_title => '售后信息';

  @override
  String get after_sales_info_order_number => '申请单号';

  @override
  String get after_sales_info_apply_time => '申请时间';

  @override
  String get after_sales_info_refund_amount => '退款金额';

  @override
  String get after_sales_info_reason => '申请原因';

  @override
  String get after_sales_info_description => '详细说明';

  @override
  String get after_sales_info_audit_remark => '审核备注';

  @override
  String after_sales_list_load_failed(String error) {
    return '加载失败: $error';
  }

  @override
  String get after_sales_list_empty => '暂无售后申请记录';

  @override
  String get after_sales_list_loading => '请稍候...';

  @override
  String get after_sales_list_unknown_product => '未知商品';

  @override
  String after_sales_list_status(String status) {
    return '状态: $status';
  }

  @override
  String after_sales_list_apply_time(String time) {
    return '申请时间: $time';
  }

  @override
  String get after_sales_select_type_title => '选择售后类型';

  @override
  String get after_sales_type_remake_title => '我要重新制作';

  @override
  String get after_sales_type_remake_subtitle => '对收到的制作不满意，可与作者协商重做';

  @override
  String get after_sales_type_supplement_title => '我要补充';

  @override
  String get after_sales_type_supplement_subtitle => '收到的制作不完善，可与作者协商补充';

  @override
  String get after_sales_type_refund_title => '我要退款';

  @override
  String get after_sales_type_refund_subtitle => '协商退款';

  @override
  String get favorites_seller_status_active => '活跃';

  @override
  String get favorites_seller_status_inactive => '不活跃';

  @override
  String get favorites_seller_status_suspended => '已暂停';

  @override
  String get favorites_seller_status_banned => '已封禁';

  @override
  String get app_store_settings => '店铺设置';

  @override
  String get app_wallet => '钱包';

  @override
  String get app_wallet_init_failed => '初始化钱包页面失败';

  @override
  String get app_error_label => '错误';

  @override
  String get app_go_back => '返回';

  @override
  String get app_page_not_found => '页面未找到';

  @override
  String get app_path_error => '路径错误';

  @override
  String get app_error_generic => '错误';

  @override
  String get app_dev_menu_title => '开发调试菜单';

  @override
  String get app_dev_common_entries => '常用入口';

  @override
  String get app_dev_dskk => '多少看看';

  @override
  String get app_dev_order_module_buyer => '订单模块 (买家)';

  @override
  String get app_dev_order_list => '订单列表';

  @override
  String get app_dev_order_detail_example => '订单详情 (示例)';

  @override
  String get app_dev_order_module_seller => '订单模块 (卖家)';

  @override
  String get app_dev_seller_order_list => '卖家订单列表';

  @override
  String get app_dev_seller_order_detail_example => '卖家订单详情 (示例)';

  @override
  String get app_dev_seller_module => '卖家模块 (Seller)';

  @override
  String get app_dev_seller_center => '卖家中心 (首页)';

  @override
  String get app_dev_ai_docs_module => 'AI Docs 模块';

  @override
  String get app_dev_ai_chat => 'AI 聊天';

  @override
  String get app_dev_test_other => '测试/其他';

  @override
  String get app_dev_current_credentials => '当前测试凭证 (硬编码): ';

  @override
  String get app_dev_temp_injection => '(临时注入，将在 Auth 模块合并后移除)';

  @override
  String app_dev_navigation_failed(String path, String error) {
    return '跳转失败: $path - $error';
  }

  @override
  String get core_processing => '处理中...';

  @override
  String get core_yesterday => '昨天';

  @override
  String get payment_test_title => '支付功能测试';

  @override
  String get payment_check_availability => '检查支付方式可用性';

  @override
  String get payment_test_params => '测试参数';

  @override
  String get payment_order_number => '订单号';

  @override
  String get payment_amount_yuan => '金额 (元)';

  @override
  String get payment_product_name => '商品名称';

  @override
  String get payment_select_method => '选择支付方式';

  @override
  String payment_test_button(String method, String amount) {
    return '测试$method ¥$amount';
  }

  @override
  String get payment_usage_instructions => '使用说明';

  @override
  String get payment_instruction_1 => '1. 修改上方测试参数';

  @override
  String get payment_instruction_2 => '2. 选择要测试的支付方式';

  @override
  String get payment_instruction_3 => '3. 点击测试按钮发起支付';

  @override
  String get payment_instruction_4 => '4. 点击右上角信息按钮检查支付方式可用性';

  @override
  String get payment_test_warning => '注意：测试环境建议使用0.01元进行测试';

  @override
  String get payment_test_product => '测试商品';

  @override
  String payment_initiated_success(String message) {
    return '支付发起成功：$message';
  }

  @override
  String payment_failed_message(String message) {
    return '支付失败：$message';
  }

  @override
  String payment_exception(String error) {
    return '支付异常: $error';
  }

  @override
  String get payment_availability_title => '支付方式可用性';

  @override
  String get payment_alipay => '支付宝';

  @override
  String get payment_wechat => '微信支付';

  @override
  String get payment_wallet_balance => '余额支付';

  @override
  String get payment_confirm => '确定';

  @override
  String payment_check_failed(String error) {
    return '检查失败: $error';
  }

  @override
  String get payment_alipay_subtitle => '安全快捷支付';

  @override
  String get payment_wechat_subtitle => '微信安全支付';

  @override
  String get payment_amount_label => '支付金额：';

  @override
  String get payment_terms_agreement => '点击\"确认支付\"即表示您同意并接受相关服务条款';

  @override
  String get payment_create_order_failed => '创建支付订单失败';

  @override
  String get payment_method_test_title => '支付方式测试';

  @override
  String get payment_alipay_pay => '支付宝支付';

  @override
  String get payment_test_functions => '测试功能';

  @override
  String get payment_test_alipay => '测试支付宝支付';

  @override
  String get payment_test_wechat => '测试微信支付';

  @override
  String get payment_test_credit_card => '测试信用卡支付';

  @override
  String get payment_recent_test_result => '最近测试结果';

  @override
  String get payment_no_test_result => '暂无测试结果';

  @override
  String get payment_available => '可用';

  @override
  String get payment_unavailable => '不可用';

  @override
  String payment_method_label(String name) {
    return '支付方式：$name';
  }

  @override
  String get payment_mock_mode => 'Mock模式';

  @override
  String payment_error_label(String error) {
    return '错误: $error';
  }

  @override
  String get payment_nav_network_failed => '网络连接失败';

  @override
  String get payment_nav_network_error_message => '网络连接出错，请检查网络后重试';

  @override
  String get payment_nav_view_orders => '查看订单';

  @override
  String get payment_nav_retry_payment => '重试支付';

  @override
  String get payment_nav_result_unknown_title => '支付结果未知';

  @override
  String get payment_nav_result_unknown_message => '支付结果暂时无法确认，请稍后查看订单状态或联系客服';

  @override
  String get payment_nav_query_status => '查询状态';

  @override
  String get payment_nav_cancel_continue => '您已取消支付，可以继续完成订单支付';

  @override
  String get payment_nav_processing => '支付正在处理中，请稍后查看订单状态';

  @override
  String get payment_nav_success => '支付成功';

  @override
  String get payment_nav_failed => '支付失败';

  @override
  String get payment_nav_retrying => '正在重新发起支付...';

  @override
  String get payment_nav_retry_failed => '无法重试支付，订单信息丢失';

  @override
  String get payment_nav_querying => '正在查询支付状态...';

  @override
  String get payment_nav_query_failed => '无法查询状态，订单信息丢失';

  @override
  String payment_test_description(String subject) {
    return '$subject - 支付测试';
  }

  @override
  String get chat_translating => '翻译中...';

  @override
  String get chat_translation_label => '译文';

  @override
  String get after_sales_info_evidence => '申请凭证';
}
