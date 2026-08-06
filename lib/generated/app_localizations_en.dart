// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language_settings => 'Language Settings';

  @override
  String get system_language => 'System Language';

  @override
  String get system_language_description =>
      'Automatically use device language settings';

  @override
  String get ai_docs_assistant_title => 'AI Assistant';

  @override
  String get ai_docs_unnamed_conversation => 'Unnamed Conversation';

  @override
  String get ai_docs_loading => 'Loading...';

  @override
  String get ai_docs_match_button => 'Match';

  @override
  String get ai_docs_select_conversation_first =>
      'Please select a conversation first';

  @override
  String get ai_docs_please_enter_message => 'Please enter a message';

  @override
  String get ai_docs_recommended_services => 'Recommended Services';

  @override
  String ai_docs_recommendations_error(String error) {
    return 'Failed to load recommendations: $error';
  }

  @override
  String get ai_docs_no_recommendations => 'No recommendations available';

  @override
  String get ai_docs_dispatched => 'Dispatched';

  @override
  String get ai_docs_enter_chat => 'Enter Chat';

  @override
  String get ai_docs_let_them_see => 'Let them see';

  @override
  String get ai_docs_welcome_title => 'Welcome to AI Assistant';

  @override
  String get ai_docs_welcome_message =>
      'Just send a message to start chatting, and the system will automatically create a chat room for you';

  @override
  String get ai_docs_auto_create_text =>
      'No conversation selected, automatically creating a new conversation and sending message';

  @override
  String get ai_docs_auto_create_voice =>
      'No conversation selected, automatically creating a new conversation and sending voice message';

  @override
  String get ai_docs_cancelling_generation => 'Cancelling generation...';

  @override
  String get allocating_step1 => 'Allocating';

  @override
  String get allocating_step2 => 'Allocating.';

  @override
  String get allocating_step3 => 'Allocating..';

  @override
  String get allocating_step4 => 'Allocating...';

  @override
  String get ai_docs_add_image => 'Add Image';

  @override
  String get ai_docs_stop_recording => 'Stop Recording';

  @override
  String get ai_docs_start_recording => 'Record Voice';

  @override
  String get ai_docs_recording => 'Recording... tap to stop';

  @override
  String get ai_docs_enter_message => 'Enter message...';

  @override
  String get ai_docs_stop_generation => 'Stop Generation';

  @override
  String get ai_docs_send_message => 'Send Message';

  @override
  String get ai_docs_uploading_images => 'Images uploading, please wait...';

  @override
  String get ai_docs_mic_permission_denied => 'Microphone permission denied';

  @override
  String ai_docs_recording_error(String error) {
    return 'Error starting recording: $error';
  }

  @override
  String get ai_docs_recording_file_not_found =>
      'Error: Recording file not found';

  @override
  String get ai_docs_stop_recording_error => 'Error stopping recording';

  @override
  String ai_docs_stop_recording_error_with_reason(String error) {
    return 'Error stopping recording: $error';
  }

  @override
  String ai_docs_image_picking_error(String error) {
    return 'Error selecting image: $error';
  }

  @override
  String get ai_docs_conversation_list => 'Conversation List';

  @override
  String get ai_docs_no_messages => 'No messages yet. Start chatting!';

  @override
  String get ai_docs_new_chat => 'New Chat';

  @override
  String get ai_docs_load_conversations_failed =>
      'Failed to load conversations';

  @override
  String get ai_docs_retry => 'Retry';

  @override
  String get ai_docs_no_conversations => 'No conversations yet';

  @override
  String get ai_docs_delete_conversation_tooltip => 'Delete conversation';

  @override
  String get ai_docs_delete_conversation_title => 'Delete conversation?';

  @override
  String get ai_docs_delete_conversation_content =>
      'Are you sure you want to permanently delete this conversation?';

  @override
  String get ai_docs_cancel => 'Cancel';

  @override
  String get ai_docs_delete => 'Delete';

  @override
  String get ai_docs_please_select_conversation_to_delete =>
      'Please select the conversation to delete first';

  @override
  String get ai_docs_generate_title => 'AI Generate Title';

  @override
  String get ai_docs_generate_title_tooltip =>
      'Let AI generate a title for this conversation';

  @override
  String get ai_docs_generating_title => 'Generating title...';

  @override
  String get ai_docs_title_generated => 'Title generated';

  @override
  String ai_docs_title_generation_failed(String error) {
    return 'Title generation failed: $error';
  }

  @override
  String get ai_docs_edit_title => 'Edit Title';

  @override
  String get ai_docs_edit_title_hint => 'Please enter a new title';

  @override
  String get ai_docs_title_updated => 'Title updated';

  @override
  String ai_docs_title_update_failed(String error) {
    return 'Title update failed: $error';
  }

  @override
  String get ai_docs_title_too_long => 'Title cannot exceed 50 characters';

  @override
  String get ai_docs_title_empty => 'Title cannot be empty';

  @override
  String get nav_ai_assistant => 'DeepStream';

  @override
  String get nav_home => 'Browse';

  @override
  String get nav_messages => 'Chat';

  @override
  String get nav_profile => 'Profile';

  @override
  String get nav_dev => 'Dev';

  @override
  String get nav_seller_analytics => 'Analytics';

  @override
  String get nav_seller_products => 'Products';

  @override
  String get nav_seller_messages => 'Messages';

  @override
  String get nav_seller_profile => 'Profile';

  @override
  String get chat_list_title => 'Chat List';

  @override
  String get chat_loading => 'Loading...';

  @override
  String chat_error_loading(String error) {
    return 'Loading failed: $error';
  }

  @override
  String get chat_no_messages => 'No messages yet. Start chatting!';

  @override
  String get chat_admin_title => 'System Admin';

  @override
  String get chat_notification_center => 'Notification Center';

  @override
  String get chat_notification_description =>
      'System, orders, reviews and important notifications';

  @override
  String get chat_enter_message => 'Enter message...';

  @override
  String get chat_yesterday => 'Yesterday';

  @override
  String get chat_image_message => '[Image]';

  @override
  String get chat_audio_message => '[Audio]';

  @override
  String get chat_file_message => '[File]';

  @override
  String get chat_allocate_message => '[DSKK]';

  @override
  String get chat_payment_prompt_message => '[Payment Request]';

  @override
  String get chat_revoked_message => '[Message withdrawn]';

  @override
  String get chat_unknown_message => '[Unknown message]';

  @override
  String get chat_unsupported_message => 'This message can\'t be viewed yet';

  @override
  String get chat_unknown_user => 'Unknown User';

  @override
  String get chat_invalid_session => 'Invalid session';

  @override
  String get chat_opponent_not_found =>
      'Cannot find the other party\'s information';

  @override
  String get chat_message_recalled => 'Message recalled';

  @override
  String get chat_copy => 'Copy';

  @override
  String get chat_recall => 'Recall';

  @override
  String get chat_copied_to_clipboard => 'Copied to clipboard';

  @override
  String get chat_me => 'Me';

  @override
  String get chat_buyer => 'Buyer';

  @override
  String get chat_i_want_seller_to_see => 'I want to see';

  @override
  String get chat_wants_to_see => 'wants to see';

  @override
  String get chat_collapse => 'Collapse';

  @override
  String get chat_expand => 'Expand';

  @override
  String get chat_summary_hidden =>
      'This summary could not be generated and has been hidden';

  @override
  String get chat_admin_connection_error => 'Unable to connect to system admin';

  @override
  String get chat_audio_pause => 'Pause';

  @override
  String get chat_audio_play => 'Play';

  @override
  String get chat_markdown_example_title1 => 'This is a level 1 heading';

  @override
  String get chat_markdown_example_title2 => 'This is a level 2 heading';

  @override
  String get chat_markdown_example_bold_italic =>
      'This is **bold** text and *italic* text.';

  @override
  String get chat_markdown_example_list1 => 'This is list item 1';

  @override
  String get chat_markdown_example_list2 => 'This is list item 2';

  @override
  String get chat_markdown_example_list3 => 'This is a nested list item';

  @override
  String get chat_markdown_example_quote =>
      'This is a quote text, supporting multiple lines';

  @override
  String get chat_markdown_example_table_col1 => 'Column 1';

  @override
  String get chat_markdown_example_table_col2 => 'Column 2';

  @override
  String get chat_markdown_example_table_content1 => 'Content 1';

  @override
  String get chat_markdown_example_table_content2 => 'Content 2';

  @override
  String get chat_markdown_example_table_content3 => 'Content 3';

  @override
  String get chat_markdown_example_table_content4 => 'Content 4';

  @override
  String get chat_pick_from_gallery => 'Pick from Gallery';

  @override
  String get chat_take_photo => 'Take Photo';

  @override
  String get chat_send_markdown => 'Send Markdown Example';

  @override
  String get chat_switch_to_text => 'Switch to Text Input';

  @override
  String get chat_switch_to_voice => 'Switch to Voice Input';

  @override
  String get chat_send => 'Send';

  @override
  String get chat_attach => 'Send Image/File';

  @override
  String get chat_filter_all => 'All';

  @override
  String get chat_filter_buyer => 'Buyer Chats';

  @override
  String get chat_filter_seller => 'Seller Chats';

  @override
  String get chat_filter_mode_all => 'Showing all chats';

  @override
  String get chat_filter_mode_buyer => 'Showing buyer chats only';

  @override
  String get chat_filter_mode_seller => 'Showing seller chats only';

  @override
  String get chat_press_to_talk => 'Press to Talk';

  @override
  String chat_release_to_send(int duration) {
    return 'Release to Send (${duration}s)';
  }

  @override
  String get chat_camera_permission_denied_title => 'Camera Permission Denied';

  @override
  String get chat_camera_permission_denied_message =>
      'Please enable camera permission in system settings to use the photo feature.';

  @override
  String get chat_mic_permission_denied_title => 'Microphone Permission Denied';

  @override
  String get chat_mic_permission_denied_message =>
      'Please enable microphone permission in system settings to use the recording feature.';

  @override
  String get chat_permission_denied_cancel => 'Cancel';

  @override
  String get chat_permission_denied_settings => 'Settings';

  @override
  String get chat_mic_permission_denied =>
      'Microphone permission denied, cannot record';

  @override
  String get chat_camera_permission_denied =>
      'Camera permission denied, cannot take photo';

  @override
  String chat_recording_error(String error) {
    return 'Error starting recording: $error';
  }

  @override
  String chat_stop_recording_error(String error) {
    return 'Error stopping recording: $error';
  }

  @override
  String chat_image_picking_error(String error) {
    return 'Error selecting image: $error';
  }

  @override
  String get chat_web_recording_not_supported =>
      'Recording is not supported on Web platform';

  @override
  String get profile_personal_center => 'Personal Center';

  @override
  String get profile_login_prompt => 'Please login to view your profile';

  @override
  String get profile_login_button => 'Login';

  @override
  String get auth_phone_number => 'Phone Number';

  @override
  String get auth_select_country_region => 'Select Country/Region';

  @override
  String get auth_phone_validation_empty => 'Please enter phone number';

  @override
  String get auth_phone_validation_invalid_cn =>
      'Please enter 11-digit phone number';

  @override
  String get auth_phone_validation_invalid_cn_start =>
      'Phone number must start with 1';

  @override
  String get auth_phone_validation_invalid_us =>
      'Please enter 10-digit phone number';

  @override
  String get auth_phone_validation_invalid_jp_kr =>
      'Please enter 10 or 11-digit phone number';

  @override
  String get auth_phone_validation_invalid_general =>
      'Please enter a valid phone number';

  @override
  String profile_loading_error(String error) {
    return 'Loading failed: $error';
  }

  @override
  String get profile_my_dskk => 'My DSKK';

  @override
  String get profile_favorites => 'Favorites';

  @override
  String get profile_my_wallet => 'My Wallet';

  @override
  String get profile_wallet => 'Wallet';

  @override
  String get profile_settings => 'Settings';

  @override
  String get profile_account_security => 'Account & Security';

  @override
  String get profile_message_notifications => 'Message Notifications';

  @override
  String get profile_about_us => 'About Us';

  @override
  String get profile_assistant_mission => 'Assistant\'s Mission';

  @override
  String get profile_switch_to_seller => 'Switch to Seller Mode';

  @override
  String profile_switch_error(String error) {
    return 'Unable to switch to seller mode: $error';
  }

  @override
  String get profile_edit_nickname => 'Edit Nickname';

  @override
  String get profile_nickname_hint => 'Please enter new nickname';

  @override
  String get profile_nickname_empty_error => 'Nickname cannot be empty';

  @override
  String get profile_nickname_length_error =>
      'Nickname length cannot exceed 20 characters';

  @override
  String get profile_cancel => 'Cancel';

  @override
  String get profile_save => 'Save';

  @override
  String get profile_default_name => 'User';

  @override
  String get profile_online => 'Online';

  @override
  String get profile_offline => 'Offline';

  @override
  String get profile_avatar_upload_failed =>
      'Avatar upload failed, please try again';

  @override
  String get profile_orders => 'My Orders';

  @override
  String get profile_pending_payment => 'Unpaid';

  @override
  String get profile_in_progress => 'In Chat';

  @override
  String get profile_completed => 'Completed';

  @override
  String get profile_refund => 'After-sale';

  @override
  String profile_navigation_error(String error) {
    return 'Unable to navigate to order list: $error';
  }

  @override
  String get home_title => 'Home';

  @override
  String get home_search_hint => 'Search services';

  @override
  String get home_loading => 'Loading...';

  @override
  String home_loading_failed(String error) {
    return 'Loading failed: $error';
  }

  @override
  String get home_retry => 'Retry';

  @override
  String get home_end_of_list => 'End of list';

  @override
  String get home_no_content => 'No recommended content';

  @override
  String get home_pull_to_refresh => 'Pull to refresh for recommendations';

  @override
  String get home_refreshing_recommendations => 'Refreshing recommendations...';

  @override
  String get home_loading_more => 'Loading more...';

  @override
  String get home_back_to_top_refresh => 'Back to top & refresh';

  @override
  String home_banner_clicked(String targetType, String targetValue) {
    return 'Banner clicked: $targetType - $targetValue';
  }

  @override
  String home_product_card_clicked(String name) {
    return 'Service card clicked: $name';
  }

  @override
  String home_recommend_clicked(String name) {
    return 'Let them see button clicked: $name';
  }

  @override
  String get product_recommend_button => 'Let them see';

  @override
  String get product_image_loading_failed => 'Image loading failed';

  @override
  String get product_default_name => 'Product';

  @override
  String get search_title => 'Search';

  @override
  String get search_button => 'Search';

  @override
  String get search_hot_keywords => 'Hot Keywords';

  @override
  String get search_history => 'Search History';

  @override
  String get search_no_results => 'No relevant services found';

  @override
  String search_failed(String error) {
    return 'Search failed: $error';
  }

  @override
  String product_detail_loading_failed(String error) {
    return 'Loading failed: $error';
  }

  @override
  String get product_detail_retry => 'Retry';

  @override
  String get product_detail_please_wait => 'Please wait...';

  @override
  String get product_detail_contact_seller => 'Contact Seller';

  @override
  String get product_detail_verified_label => 'Verified';

  @override
  String get product_detail_published_status => 'Published';

  @override
  String get product_detail_more => 'More';

  @override
  String get product_detail_collapse => 'Collapse';

  @override
  String get product_detail_delivery_times => 'Delivery Times';

  @override
  String get product_detail_delivery_period => 'Delivery Period';

  @override
  String get product_detail_buy_now => 'Buy Now (1)';

  @override
  String product_detail_buy_now_with_price(String price) {
    return 'Buy Now ¥$price';
  }

  @override
  String get product_detail_faq => 'FAQ';

  @override
  String get product_detail_case_showcase => 'Case Showcase';

  @override
  String get product_detail_no_cases => 'No cases available';

  @override
  String product_detail_reviews(int count) {
    return 'Reviews ($count)';
  }

  @override
  String get product_detail_view_all => 'View All';

  @override
  String get product_detail_no_reviews => 'No reviews yet';

  @override
  String get product_detail_basic_package => 'Basic';

  @override
  String get product_detail_standard_package => 'Standard';

  @override
  String get product_detail_premium_package => 'Premium';

  @override
  String get product_detail_basic_tier => 'Basic';

  @override
  String get product_detail_standard_tier => 'Standard';

  @override
  String get product_detail_premium_tier => 'Premium';

  @override
  String get product_detail_sample_review => 'Great service, very patient';

  @override
  String get product_detail_sample_user => 'Ray123';

  @override
  String get product_reviews_title => 'Reviews';

  @override
  String product_reviews_loading_failed(String error) {
    return 'Loading failed: $error';
  }

  @override
  String get product_reviews_retry => 'Retry';

  @override
  String get product_reviews_no_reviews => 'No reviews yet';

  @override
  String get product_reviews_sample_content => 'Great service, very patient';

  @override
  String product_reviews_years_ago(int count) {
    return '$count years ago';
  }

  @override
  String product_reviews_months_ago(int count) {
    return '$count months ago';
  }

  @override
  String product_reviews_days_ago(int count) {
    return '$count days ago';
  }

  @override
  String product_reviews_hours_ago(int count) {
    return '$count hours ago';
  }

  @override
  String product_reviews_minutes_ago(int count) {
    return '$count minutes ago';
  }

  @override
  String get product_reviews_just_now => 'Just now';

  @override
  String get product_reviews_seller_reply => 'Seller Reply';

  @override
  String product_reviews_total_count(int count) {
    return '$count reviews';
  }

  @override
  String get product_reviews_filter_all => 'All';

  @override
  String get product_reviews_filter_with_images => 'With Images';

  @override
  String get product_reviews_filter_good => 'Good';

  @override
  String get product_reviews_filter_medium => 'Medium';

  @override
  String get product_reviews_filter_bad => 'Bad';

  @override
  String get seller_profile_default_title => 'Seller Profile';

  @override
  String get seller_profile_seller => 'Seller';

  @override
  String get seller_profile_no_description => 'No description';

  @override
  String seller_profile_followers(int count) {
    return '$count followers';
  }

  @override
  String get seller_profile_followed => 'Following';

  @override
  String get seller_profile_follow => 'Follow';

  @override
  String get seller_profile_unfollow_success => 'Unfollowed successfully';

  @override
  String get seller_profile_follow_success => 'Followed successfully';

  @override
  String seller_profile_chat_failed(String error) {
    return 'Failed to create chat: $error';
  }

  @override
  String seller_profile_error_occurred(String error) {
    return 'Error occurred: $error';
  }

  @override
  String get seller_profile_about_merchant => 'About Merchant';

  @override
  String get seller_profile_my_services => 'My Services';

  @override
  String get seller_profile_no_merchant_info => 'No merchant information';

  @override
  String get seller_profile_member_level => 'Member Level';

  @override
  String get seller_profile_level_two => 'Level 2 Member';

  @override
  String get seller_profile_seller_rating => 'Seller Rating';

  @override
  String get seller_profile_response_time => 'Response Time';

  @override
  String get seller_profile_response_hours => '3 hours';

  @override
  String get seller_profile_certification_status => 'Certification Status';

  @override
  String get seller_profile_certified => 'Certified';

  @override
  String get seller_profile_not_certified => 'Not Certified';

  @override
  String get seller_profile_no_products => 'No products';

  @override
  String get seller_profile_image_load_failed => 'Image loading failed';

  @override
  String get seller_profile_no_image => 'No image';

  @override
  String get seller_profile_title => 'Profile';

  @override
  String get seller_profile_auth_management => 'Auth';

  @override
  String get seller_profile_my_wallet => 'Wallet';

  @override
  String get seller_profile_time_management => 'Schedule';

  @override
  String get seller_profile_settings => 'Settings';

  @override
  String get seller_profile_notifications => 'Notifications';

  @override
  String get seller_profile_about_us => 'About';

  @override
  String get seller_profile_mission => 'Mission';

  @override
  String get seller_profile_user_name => 'Ray';

  @override
  String get seller_profile_seller_mode_online => 'Seller Mode: Online';

  @override
  String get seller_profile_seller_mode_offline => 'Seller Mode: Offline';

  @override
  String get seller_profile_seller_mode => 'Seller Mode';

  @override
  String get seller_profile_buyer_mode => 'Buyer Mode';

  @override
  String get seller_profile_my_orders => 'My Orders';

  @override
  String get seller_profile_order_pending => 'Pending';

  @override
  String get seller_profile_order_processing => 'Processing';

  @override
  String get seller_profile_order_delivered => 'Delivered';

  @override
  String get seller_profile_order_refund => 'Refund/Support';

  @override
  String seller_profile_feature_not_implemented(String feature) {
    return '$feature feature not yet implemented';
  }

  @override
  String get seller_home_loading_failed => 'Loading failed';

  @override
  String get seller_home_no_data => 'No data';

  @override
  String get seller_home_no_store_info => 'No store information';

  @override
  String get seller_home_online => 'Online';

  @override
  String get seller_home_offline => 'Offline';

  @override
  String seller_home_completion_rate(String rate) {
    return 'Completion Rate $rate%';
  }

  @override
  String get seller_home_switch_to_buyer => 'Switch to Buyer Mode';

  @override
  String seller_home_switch_failed(String error) {
    return 'Unable to switch to buyer mode: $error';
  }

  @override
  String get seller_home_income => 'Revenue';

  @override
  String get seller_home_view_details => 'Details';

  @override
  String get seller_home_total_income => 'Total';

  @override
  String get seller_home_today_income => 'Today';

  @override
  String get seller_home_pending_settlement => 'Pending';

  @override
  String get seller_home_orders => 'Orders';

  @override
  String get seller_home_view_all => 'View All';

  @override
  String get seller_home_orders_all => 'All';

  @override
  String get seller_home_orders_pending => 'Pending';

  @override
  String get seller_home_orders_processing => 'Processing';

  @override
  String get seller_home_orders_aftersales => 'After Sales';

  @override
  String get seller_home_orders_awaiting_delivery => 'Awaiting Delivery';

  @override
  String get seller_home_orders_completed => 'Completed';

  @override
  String get seller_home_orders_canceled => 'Canceled';

  @override
  String get seller_home_functions => 'Functions';

  @override
  String get seller_home_wallet => 'Wallet';

  @override
  String get seller_home_auth_management => 'Auth';

  @override
  String get seller_home_time_management => 'Schedule';

  @override
  String get seller_home_auto_reply => 'Auto Reply';

  @override
  String get seller_home_provider_task_center => 'Provider Tasks';

  @override
  String get seller_home_recent_income => 'Recent Revenue';

  @override
  String get seller_home_no_recent_income => 'No recent revenue data';

  @override
  String get seller_home_no_income_data => 'No revenue data';

  @override
  String get seller_statistics_title => 'Analytics';

  @override
  String get seller_statistics_seller_homepage => 'Seller Profile';

  @override
  String get seller_statistics_heat_value => 'Heat';

  @override
  String get seller_statistics_reply_rate => 'Reply Rate';

  @override
  String get seller_statistics_completion_rate => 'Completion';

  @override
  String get seller_statistics_positive_rate => 'Rating';

  @override
  String get seller_statistics_upgrade_to_next_level => 'Upgrade to Next Level';

  @override
  String seller_statistics_become_level3_seller(String days) {
    return 'Level 3 Seller for $days days';
  }

  @override
  String seller_statistics_complete_orders(String orderNum) {
    return 'Complete $orderNum orders';
  }

  @override
  String seller_statistics_profit_amount(String amount) {
    return 'Earn \$$amount';
  }

  @override
  String get seller_statistics_indicators => 'Metrics';

  @override
  String get seller_statistics_total_earnings => 'Total Revenue';

  @override
  String get seller_statistics_monthly_earnings => 'Monthly Revenue';

  @override
  String get seller_statistics_total_orders => 'Total Orders';

  @override
  String get seller_statistics_active_orders => 'Active Orders';

  @override
  String get seller_statistics_pending => 'Pending';

  @override
  String get seller_statistics_incomplete_orders => 'Incomplete Orders';

  @override
  String get seller_statistics_pending_completion => 'Pending';

  @override
  String get seller_statistics_receipt => 'Receipt';

  @override
  String get seller_statistics_next_delivery_date => 'Next Delivery';

  @override
  String get seller_statistics_earliest => 'Earliest';

  @override
  String seller_statistics_loading_failed(String error) {
    return 'Loading failed: $error';
  }

  @override
  String get seller_statistics_retry => 'Retry';

  @override
  String get seller_auth_management_title => 'Authentication Management';

  @override
  String get seller_auth_management_certified_items => 'Certified Items';

  @override
  String get seller_auth_management_open_certification => 'Open Certification';

  @override
  String get seller_auth_management_no_items => 'No certification items';

  @override
  String get seller_auth_management_unknown_status => 'Unknown Status';

  @override
  String get seller_auth_management_certified => 'Certified';

  @override
  String get seller_auth_management_pending => 'Under Review';

  @override
  String get seller_auth_management_rejected => 'Not Approved';

  @override
  String get seller_auth_management_not_submitted => 'Not Submitted';

  @override
  String get seller_auth_management_server_timeout => 'Server Response Timeout';

  @override
  String get seller_auth_management_server_timeout_desc =>
      'Server took too long to process the request, please try again later';

  @override
  String get seller_auth_management_network_error => 'Network Connection Error';

  @override
  String get seller_auth_management_network_error_desc =>
      'Unable to connect to server, please check network settings';

  @override
  String get seller_auth_management_loading_failed => 'Loading Failed';

  @override
  String get seller_auth_management_unknown_error =>
      'An unknown error occurred, please retry';

  @override
  String get seller_auth_management_troubleshooting =>
      'Troubleshooting Suggestions:';

  @override
  String get seller_auth_management_check_network =>
      '• Check if network connection is stable';

  @override
  String get seller_auth_management_wait_retry =>
      '• Wait a few minutes and try again';

  @override
  String get seller_auth_management_contact_support =>
      '• If the problem persists, please contact customer service';

  @override
  String get seller_auth_management_check_wifi =>
      '• Check WiFi or mobile data connection';

  @override
  String get seller_auth_management_switch_network =>
      '• Try switching network environment';

  @override
  String get seller_auth_management_restart_app =>
      '• Close and reopen the application';

  @override
  String get seller_auth_management_check_connection =>
      '• Check network connection status';

  @override
  String get seller_auth_management_try_later => '• Try again later';

  @override
  String get seller_auth_management_contact_tech =>
      '• If the problem persists, please contact technical support';

  @override
  String get seller_auth_management_reload => 'Reload';

  @override
  String get seller_auth_management_back => 'Back';

  @override
  String seller_auth_application_title(String type) {
    return '$type Certification';
  }

  @override
  String seller_auth_application_desc(String type) {
    return '$type Certification Description';
  }

  @override
  String get seller_auth_application_review_time =>
      'Certification review usually takes 1-3 business days, please be patient.';

  @override
  String get seller_auth_application_basic_info => 'Basic Information';

  @override
  String get seller_auth_application_company_name => 'Company Name';

  @override
  String get seller_auth_application_company_name_hint =>
      'Please enter the full company name';

  @override
  String get seller_auth_application_company_name_required =>
      'Please enter company name';

  @override
  String get seller_auth_application_credit_code =>
      'Unified Social Credit Code';

  @override
  String get seller_auth_application_credit_code_hint =>
      'Please enter 18-digit unified social credit code';

  @override
  String get seller_auth_application_credit_code_required =>
      'Please enter unified social credit code';

  @override
  String get seller_auth_application_credit_code_invalid =>
      'Unified social credit code should be 18 digits';

  @override
  String get seller_auth_application_company_intro => 'Company Introduction';

  @override
  String get seller_auth_application_company_intro_hint =>
      'Please briefly describe the company\'s business and situation';

  @override
  String get seller_auth_application_real_name => 'Name';

  @override
  String get seller_auth_application_real_name_hint =>
      'Please enter your real name';

  @override
  String get seller_auth_application_real_name_required => 'Please enter name';

  @override
  String get seller_auth_application_id_number => 'ID Number';

  @override
  String get seller_auth_application_id_number_hint =>
      'Please enter 18-digit ID number';

  @override
  String get seller_auth_application_id_number_required =>
      'Please enter ID number';

  @override
  String get seller_auth_application_id_number_invalid =>
      'ID number should be 18 digits';

  @override
  String get seller_auth_application_school_name => 'School Name';

  @override
  String get seller_auth_application_school_name_hint =>
      'Please enter the full school name';

  @override
  String get seller_auth_application_school_name_required =>
      'Please enter school name';

  @override
  String get seller_auth_application_degree => 'Degree/Education';

  @override
  String get seller_auth_application_degree_hint =>
      'e.g., Bachelor\'s, Master\'s, etc.';

  @override
  String get seller_auth_application_degree_required =>
      'Please enter degree/education';

  @override
  String get seller_auth_application_major => 'Major';

  @override
  String get seller_auth_application_major_hint => 'Please enter major name';

  @override
  String get seller_auth_application_profession => 'Profession/Position';

  @override
  String get seller_auth_application_profession_hint =>
      'Please enter your profession or position';

  @override
  String get seller_auth_application_profession_required =>
      'Please enter profession/position';

  @override
  String get seller_auth_application_cert_number => 'Certificate Number';

  @override
  String get seller_auth_application_cert_number_hint =>
      'Please enter professional qualification certificate number';

  @override
  String get seller_auth_application_work_experience => 'Work Experience';

  @override
  String get seller_auth_application_work_experience_hint =>
      'Please briefly describe your work experience';

  @override
  String get seller_auth_application_auth_name => 'Certification Name';

  @override
  String get seller_auth_application_auth_name_hint =>
      'Please enter certification name';

  @override
  String get seller_auth_application_auth_name_required =>
      'Please enter certification name';

  @override
  String get seller_auth_application_auth_identifier =>
      'Certification Identifier';

  @override
  String get seller_auth_application_auth_identifier_hint =>
      'Please enter certification identifier or number';

  @override
  String get seller_auth_application_auth_description =>
      'Certification Description';

  @override
  String get seller_auth_application_auth_description_hint =>
      'Please describe the certification content';

  @override
  String get seller_auth_application_upload_materials =>
      'Upload Supporting Materials';

  @override
  String get seller_auth_application_upload_file => 'Upload File';

  @override
  String seller_auth_application_selected_files(int count) {
    return '$count file(s) selected';
  }

  @override
  String get seller_auth_application_selected_images => 'Selected Images:';

  @override
  String get seller_auth_application_load_failed => 'Load Failed';

  @override
  String get seller_auth_application_id_upload_hint =>
      'Please upload clear photos of both sides of your ID card, ensuring information is clearly visible without obstruction or alteration';

  @override
  String get seller_auth_application_education_upload_hint =>
      'Please upload educational certificates, degree certificates and other supporting materials with complete information';

  @override
  String get seller_auth_application_profession_upload_hint =>
      'Please upload professional qualification certificates, professional skill certificates and other supporting materials';

  @override
  String get seller_auth_application_company_upload_hint =>
      'Please upload business license, organization code certificate and other enterprise qualification certificates';

  @override
  String get seller_auth_application_default_upload_hint =>
      'Please upload relevant supporting materials, ensuring images are clear and information is complete';

  @override
  String get seller_auth_application_agreement_read =>
      'I have read and agree to';

  @override
  String get seller_auth_application_agreement_link =>
      'Certification Service Agreement';

  @override
  String get seller_auth_application_agreement_guarantee =>
      ', and guarantee that the information provided is true and valid';

  @override
  String get seller_auth_application_agreement_title =>
      'Certification Service Agreement';

  @override
  String get seller_auth_application_agreement_content =>
      'This agreement is a legal agreement between you and the DSKK platform regarding certification services. Please read the following terms carefully to ensure you fully understand all rights and obligations in this agreement.\n\n1. Service Content\nThe DSKK platform provides certification services aimed at verifying the authenticity of the identity, qualifications and other information you provide, and improving your credibility on the platform.\n\n2. User Obligations\n1. You shall provide true, accurate and complete certification information and materials.\n2. You shall ensure that the certification materials provided do not infringe on any third party\'s legitimate rights and interests.\n\n3. Platform Rights and Obligations\n1. The platform has the right to review the certification information and materials you provide.\n2. The platform will complete the review within a reasonable time and notify you of the review results.';

  @override
  String get seller_auth_application_agreement_close => 'Close';

  @override
  String get seller_auth_application_agreement_agree => 'Agree';

  @override
  String get seller_auth_application_submit =>
      'Submit Certification Application';

  @override
  String get seller_auth_application_check_form =>
      'Please check if the form is filled correctly';

  @override
  String get seller_auth_application_submit_success => 'Submission Successful';

  @override
  String get seller_auth_application_submit_success_desc =>
      'Your certification application has been submitted. We will complete the review within 1-3 business days. Please be patient.';

  @override
  String get seller_auth_application_ok => 'OK';

  @override
  String seller_auth_application_select_file_failed(String error) {
    return 'File selection failed: $error';
  }

  @override
  String get product_management_title => 'Product Management';

  @override
  String get product_management_tab_on_sale => 'On Sale';

  @override
  String get product_management_tab_draft => 'Drafts';

  @override
  String get product_management_tab_off_shelf => 'Off Shelf';

  @override
  String get product_management_action_off_shelf => 'Off Shelf';

  @override
  String get product_management_action_on_shelf => 'On Shelf';

  @override
  String get product_management_action_edit => 'Edit';

  @override
  String get product_management_action_delete => 'Delete';

  @override
  String get product_management_action_publish => 'Publish';

  @override
  String get product_management_action_resubmit => 'Resubmit';

  @override
  String get product_management_status_reviewing => 'Under Review';

  @override
  String get product_management_status_rejected => 'Review Failed';

  @override
  String get product_management_status_on_shelf => 'On Shelf';

  @override
  String get product_management_status_off_shelf => 'Off Shelf';

  @override
  String get product_management_status_draft => 'Draft';

  @override
  String get product_management_status_waiting_review => 'Waiting for Review';

  @override
  String get product_management_status_unknown => 'Unknown';

  @override
  String get product_management_stock_label => 'Stock';

  @override
  String get product_management_sales_label => 'Sales';

  @override
  String get product_management_create_product => 'Create Product';

  @override
  String get product_management_no_more_products => 'No more products';

  @override
  String get product_management_empty_on_sale => 'No products on sale';

  @override
  String get product_management_empty_draft => 'No draft products';

  @override
  String get product_management_empty_off_shelf => 'No off-shelf products';

  @override
  String get product_management_empty_default => 'No product data';

  @override
  String get product_management_draft_preview_hint =>
      'Draft products need to be published before preview';

  @override
  String get product_management_confirm_off_shelf_title => 'Confirm Off Shelf';

  @override
  String product_management_confirm_off_shelf_message(String name) {
    return 'Are you sure you want to take the product \"$name\" off shelf?';
  }

  @override
  String get product_management_confirm_off_shelf_desc => 'After off shelf:';

  @override
  String get product_management_confirm_off_shelf_point1 =>
      '• Buyers will not be able to see or purchase this product';

  @override
  String get product_management_confirm_off_shelf_point2 =>
      '• You can put it back on shelf at any time';

  @override
  String get product_management_confirm_off_shelf_point3 =>
      '• Product data will be retained';

  @override
  String get product_management_confirm_delete_title => 'Confirm Delete';

  @override
  String get product_management_confirm_delete_message =>
      'Are you sure you want to delete this product? This action cannot be undone.';

  @override
  String get product_management_cancel => 'Cancel';

  @override
  String get product_management_confirm => 'Confirm Off Shelf';

  @override
  String get product_management_delete => 'Delete';

  @override
  String get product_edit_title_create => 'Create Product';

  @override
  String get product_edit_title_edit => 'Edit Product';

  @override
  String get product_edit_basic_info => 'Basic Information';

  @override
  String get product_edit_product_name => 'Product Name';

  @override
  String get product_edit_product_name_hint => 'Please enter product name';

  @override
  String get product_edit_product_description => 'Product Description';

  @override
  String get product_edit_product_description_hint =>
      'Please enter product description';

  @override
  String get product_edit_product_price => 'Product Price';

  @override
  String get product_edit_product_images => 'Product Images';

  @override
  String get product_edit_add_image => 'Add Image';

  @override
  String get product_edit_uploading => 'Uploading...';

  @override
  String get product_edit_service_tiers => 'Service Tier Settings';

  @override
  String get product_edit_detail_intro => 'Detail Introduction';

  @override
  String get product_edit_save_draft => 'Save Draft';

  @override
  String get product_edit_publish_product => 'Publish Product';

  @override
  String get product_edit_preview_product => 'Preview Product';

  @override
  String get product_edit_at_least_one_image =>
      'Please upload at least one product image';

  @override
  String get product_edit_save_draft_dialog_title => 'Save Draft';

  @override
  String get product_edit_save_draft_dialog_message =>
      'Do you want to save as draft?';

  @override
  String get product_edit_save_draft_dialog_confirm => 'Save';

  @override
  String get product_edit_edit_attribute => 'Edit Product Attributes';

  @override
  String get product_edit_validation_name_required =>
      'Please enter product name';

  @override
  String get product_edit_validation_description_required =>
      'Please enter product description';

  @override
  String get product_edit_validation_image_required =>
      'Please upload at least one product image';

  @override
  String get product_preview_current_seller => 'Current Seller';

  @override
  String get product_preview_seller_user => 'Seller User';

  @override
  String get product_edit_success_cases => 'Success Cases';

  @override
  String get product_edit_add_success_case => 'Add Success Case';

  @override
  String get product_edit_edit_success_case => 'Edit Success Case';

  @override
  String product_edit_uploading_progress(int uploaded, int total) {
    return 'Uploading $uploaded/$total';
  }

  @override
  String get product_edit_please_enter_label =>
      'Please enter information label';

  @override
  String get product_edit_please_enter_attribute_name =>
      'Please enter attribute name';

  @override
  String get product_edit_attribute_name_hint => 'Please enter attribute name';

  @override
  String get product_edit_placeholder_hint =>
      'e.g., Please select color, Please enter model';

  @override
  String get product_edit_placeholder_label => 'Placeholder Text';

  @override
  String get product_edit_product_preview_title => 'Product Preview';

  @override
  String get product_edit_publish_service => 'Publish Service';

  @override
  String get product_edit_edit_service => 'Edit Service';

  @override
  String product_edit_max_characters(int max) {
    return 'Max $max characters';
  }

  @override
  String get after_sales_review_title => 'After-sales Review';

  @override
  String get after_sales_detail_title => 'After-sales Details';

  @override
  String get after_sales_refresh => 'Refresh';

  @override
  String get after_sales_no_pending => 'No pending after-sales requests';

  @override
  String get after_sales_load_failed => 'Load failed, please try again';

  @override
  String get after_sales_not_found => 'After-sales request not found';

  @override
  String get after_sales_order_number => 'Order Number';

  @override
  String get after_sales_apply_type => 'Request Type';

  @override
  String get after_sales_apply_time => 'Request Time';

  @override
  String get after_sales_refund_amount => 'Refund Amount';

  @override
  String get after_sales_refund_type => 'Refund Type';

  @override
  String get after_sales_apply_reason => 'Request Reason';

  @override
  String get after_sales_image_evidence => 'Image Evidence';

  @override
  String get after_sales_image_view => 'Image View';

  @override
  String get after_sales_image_load_failed => 'Image load failed';

  @override
  String get after_sales_reject => 'Reject';

  @override
  String get after_sales_agree => 'Approve';

  @override
  String get after_sales_reject_application => 'Reject Request';

  @override
  String get after_sales_agree_application => 'Approve Request';

  @override
  String get after_sales_confirm => 'Confirm';

  @override
  String get after_sales_cancel => 'Cancel';

  @override
  String get after_sales_confirm_title => 'Confirm';

  @override
  String get after_sales_confirm_message =>
      'Are you sure you want to approve this after-sales request?';

  @override
  String get after_sales_reject_reason => 'Rejection Reason';

  @override
  String get after_sales_reject_reason_hint => 'Please enter rejection reason';

  @override
  String get after_sales_reject_reason_required =>
      'Please enter rejection reason';

  @override
  String get after_sales_type_refund_only => 'Refund Only';

  @override
  String get after_sales_type_refund_return => 'Return & Refund';

  @override
  String get after_sales_type_unknown => 'Unknown Type';

  @override
  String get after_sales_status_wait_audit => 'Pending Review';

  @override
  String get after_sales_status_refused => 'Rejected';

  @override
  String get after_sales_status_audit_pass => 'Approved';

  @override
  String get after_sales_status_buyer_shipped => 'Buyer Shipped';

  @override
  String get after_sales_status_seller_received => 'Seller Received';

  @override
  String get after_sales_status_finished => 'Completed';

  @override
  String get after_sales_status_canceled => 'Canceled';

  @override
  String get after_sales_status_unknown => 'Unknown Status';

  @override
  String get time_management_title => 'Time Management';

  @override
  String get time_management_current_status => 'Current Status';

  @override
  String get time_management_online => 'Online';

  @override
  String get time_management_offline => 'Offline';

  @override
  String get time_management_online_status_description =>
      'Online Status Description';

  @override
  String get time_management_offline_status_description =>
      'Offline Status Description';

  @override
  String get time_management_online_description =>
      'You are currently online. Buyers can send you messages and you will receive notifications for new messages. Please ensure timely responses to buyer messages as maintaining a good response rate helps improve your service quality rating.';

  @override
  String get time_management_offline_description =>
      'You are currently offline. Buyers can still send you messages but the system will inform them that you are temporarily unavailable. You will still receive notifications for new messages but may not be able to respond immediately. Staying offline for extended periods may affect your order efficiency.';

  @override
  String get time_management_save_settings => 'Save Settings';

  @override
  String get time_management_settings_saved => 'Settings Saved';

  @override
  String get time_management_load_failed => 'Load Failed';

  @override
  String get time_management_retry => 'Retry';

  @override
  String get time_management_unknown_status => 'Unknown Status';

  @override
  String get auto_reply_title => 'Auto Reply Settings';

  @override
  String get auto_reply_enable => 'Auto Reply';

  @override
  String get auto_reply_content => 'Reply Content';

  @override
  String get auto_reply_content_hint => 'Please enter auto reply content';

  @override
  String get auto_reply_content_description =>
      'When customers send messages, the system will automatically reply with this content';

  @override
  String get auto_reply_save_settings => 'Save Settings';

  @override
  String get auto_reply_settings_saved => 'Settings Saved';

  @override
  String get auto_reply_content_required => 'Reply content cannot be empty';

  @override
  String get auto_reply_load_failed => 'Load failed, please try again';

  @override
  String get order_delivery_title => 'Order Delivery';

  @override
  String order_delivery_title_with_sn(String orderSn) {
    return 'Order Delivery: $orderSn';
  }

  @override
  String get order_delivery_submitting => 'Submitting delivery content...';

  @override
  String get order_delivery_load_failed => 'Load failed, please try again';

  @override
  String get order_delivery_instruction_title => 'Delivery Instructions';

  @override
  String get order_delivery_instruction_content =>
      'Please submit your delivery content for this order. You can provide detailed instructions and attach relevant files to ensure the buyer clearly understands the services or products you provide.';

  @override
  String get order_delivery_content_label => 'Delivery Content Description:';

  @override
  String get order_delivery_content_hint =>
      'Please describe your delivery content...';

  @override
  String get order_delivery_attachments_label => 'Attachment Files:';

  @override
  String get order_delivery_submit_button => 'Submit Delivery';

  @override
  String get order_delivery_content_required =>
      'Please enter delivery content description';

  @override
  String get order_delivery_submit_success =>
      'Delivery content submitted successfully';

  @override
  String get order_delivery_logistics_company => 'Logistics Company';

  @override
  String get order_delivery_tracking_number => 'Tracking Number';

  @override
  String get order_delivery_shipping_address => 'Shipping Address';

  @override
  String get order_delivery_receiving_address => 'Receiving Address';

  @override
  String get order_delivery_status_pending => 'Pending Shipment';

  @override
  String get order_delivery_status_shipped => 'Shipped';

  @override
  String get order_delivery_status_received => 'Received';

  @override
  String get order_delivery_status_in_transit => 'In Transit';

  @override
  String get order_delivery_confirm_shipment => 'Confirm Shipment';

  @override
  String get order_delivery_view_details => 'View Details';

  @override
  String get order_delivery_no_pending_orders => 'No pending orders';

  @override
  String get notification_center_title => 'Notification Center';

  @override
  String get notification_tab_all => 'All';

  @override
  String get notification_tab_order => 'Orders';

  @override
  String get notification_tab_system => 'System';

  @override
  String get notification_tab_refund => 'After-sales';

  @override
  String get notification_tab_message => 'Messages';

  @override
  String get notification_type_order => 'Order Notification';

  @override
  String get notification_type_system => 'System Notification';

  @override
  String get notification_type_refund => 'After-sales Notification';

  @override
  String get notification_type_message => 'Message Notification';

  @override
  String get notification_type_review => 'Review Notification';

  @override
  String get notification_type_authentication => 'Authentication Notification';

  @override
  String get notification_type_other => 'Other Notification';

  @override
  String get notification_status_unread => 'Unread';

  @override
  String get notification_status_read => 'Read';

  @override
  String get notification_mark_all_read => 'Mark All as Read';

  @override
  String get notification_empty_all => 'No notifications';

  @override
  String get notification_empty_order => 'No order notifications';

  @override
  String get notification_empty_system => 'No system notifications';

  @override
  String get notification_empty_refund => 'No after-sales notifications';

  @override
  String get notification_empty_message => 'No message notifications';

  @override
  String get notification_empty_review => 'No review notifications';

  @override
  String get notification_empty_authentication =>
      'No authentication notifications';

  @override
  String get notification_empty_other => 'No other notifications';

  @override
  String get notification_empty_generic => 'No notifications';

  @override
  String get notification_refresh => 'Refresh';

  @override
  String get notification_retry => 'Retry';

  @override
  String notification_load_failed(String error) {
    return 'Failed to load notification center: $error';
  }

  @override
  String get notification_detail_title => 'Notification Details';

  @override
  String get notification_detail_view => 'View Details';

  @override
  String get notification_detail_close => 'Close';

  @override
  String get notification_click_to_view => 'Click to view details';

  @override
  String get notification_default_title => 'Notification';

  @override
  String get notification_time_just_now => 'Just now';

  @override
  String notification_time_minutes_ago(int minutes) {
    return '$minutes minutes ago';
  }

  @override
  String notification_time_hours_ago(int hours) {
    return '$hours hours ago';
  }

  @override
  String notification_time_days_ago(int days) {
    return '$days days ago';
  }

  @override
  String notification_time_months_ago(int months) {
    return '$months months ago';
  }

  @override
  String get materialsInfo => 'Materials Info';

  @override
  String get buyerSubmittedMaterials => 'Buyer Submitted Materials';

  @override
  String get sellerDeliveryContent => 'Seller Delivery Content';

  @override
  String get noBuyerMaterials => 'No buyer submitted materials';

  @override
  String get noSellerDelivery => 'No delivery from seller yet';

  @override
  String get attachments => 'Attachments:';

  @override
  String get deliveryFiles => 'Delivery Files:';

  @override
  String get deliveryDescription => 'Delivery Description';

  @override
  String get tapToPreview => 'Tap to preview';

  @override
  String get tapToOpen => 'Tap to open';

  @override
  String get downloadFile => 'Download file';

  @override
  String get storagePermissionDenied => 'Storage permission denied';

  @override
  String get cancelDownload => 'Cancel download';

  @override
  String get pageLoadFailed => 'Failed to load page';

  @override
  String get openFile => 'Open file';

  @override
  String get downloaded => 'Downloaded';

  @override
  String get downloadCompleted => 'Download completed';

  @override
  String get downloadFailed => 'Download failed';

  @override
  String get openFileFailed => 'Failed to open file';

  @override
  String get storagePermissionRequired =>
      'Storage permission required to download files';

  @override
  String get pdfLoadFailed => 'Failed to load PDF';

  @override
  String get retry => 'Retry';

  @override
  String product_detail_translated_from(String language) {
    return 'Translated from $language';
  }

  @override
  String get product_detail_translation_auto => 'Auto-translated';

  @override
  String get product_detail_show_original => 'Show original';

  @override
  String get order_status_awaiting_payment => 'Awaiting Payment';

  @override
  String get order_status_awaiting_submission => 'Awaiting Submission';

  @override
  String get order_status_buy_awaiting_submission => 'Resubmission Required';

  @override
  String get order_status_awaiting_start => 'Awaiting Acceptance';

  @override
  String get order_status_awaiting_delivery => 'Awaiting Delivery';

  @override
  String get order_status_awaiting_confirmation => 'Awaiting Confirmation';

  @override
  String get order_status_awaiting_evaluation => 'Awaiting Review';

  @override
  String get order_status_completed => 'Completed';

  @override
  String get order_status_canceled => 'Canceled';

  @override
  String get order_status_after_sale => 'After-Sales';

  @override
  String get order_status_unknown => 'Unknown Status';

  @override
  String get order_action_cancel => 'Cancel Order';

  @override
  String get order_action_go_pay => 'Pay Now';

  @override
  String get order_action_submit_materials => 'Submit Materials';

  @override
  String get order_action_contact_support => 'Contact Support';

  @override
  String get order_action_view_feedback => 'View Feedback';

  @override
  String get order_action_remind_delivery => 'Remind Delivery';

  @override
  String get order_action_platform_intervention => 'Platform Intervention';

  @override
  String get order_action_view_delivery => 'View Delivery';

  @override
  String get order_action_apply_after_sale => 'Apply After-Sales';

  @override
  String get order_action_confirm_receipt => 'Confirm Receipt';

  @override
  String get order_action_view_logistics => 'View Logistics';

  @override
  String get order_action_go_evaluate => 'Write Review';

  @override
  String get order_action_apply_rework => 'Request Rework';

  @override
  String get order_action_delete_order => 'Delete Order';

  @override
  String get order_action_view_order => 'View Order';

  @override
  String get order_action_view_details => 'View Details';

  @override
  String get order_action_processing => 'Processing...';

  @override
  String get order_confirm_cancel_title => 'Cancel Order';

  @override
  String get order_confirm_cancel_content =>
      'Are you sure you want to cancel this order?';

  @override
  String get order_confirm_receipt_title => 'Confirm Receipt';

  @override
  String get order_confirm_receipt_content =>
      'Are you sure you have received the goods and want to confirm receipt?';

  @override
  String get order_confirm_delete_title => 'Delete Order';

  @override
  String get order_confirm_delete_content =>
      'Are you sure you want to delete this order? This action cannot be undone.';

  @override
  String get order_dialog_cancel => 'Cancel';

  @override
  String get order_dialog_confirm => 'Confirm';

  @override
  String get order_dialog_close => 'Close';

  @override
  String get order_dialog_submit => 'Submit';

  @override
  String get order_snackbar_connecting_support => 'Connecting to support...';

  @override
  String get order_snackbar_feedback_in_progress =>
      'View seller feedback feature is under development';

  @override
  String get order_snackbar_reminded_delivery =>
      'Seller has been reminded to deliver';

  @override
  String order_snackbar_nav_failed(String error) {
    return 'Navigation failed: $error';
  }

  @override
  String get order_snackbar_no_items_after_sale =>
      'Error: Cannot apply after-sales for an order with no items';

  @override
  String get order_snackbar_no_items_evaluate =>
      'Error: Cannot evaluate an order with no items';

  @override
  String order_snackbar_operation_failed(String error) {
    return 'Operation failed: $error';
  }

  @override
  String get order_dialog_data_not_loaded =>
      'Data not loaded yet, please try again later';

  @override
  String get order_dialog_view_delivery_title => 'View Delivery';

  @override
  String get order_dialog_seller_delivery_content => 'Seller Delivery Content:';

  @override
  String get order_dialog_buyer_materials => 'Buyer Submitted Materials:';

  @override
  String get order_dialog_no_seller_delivery =>
      'No delivery content from seller yet';

  @override
  String get order_dialog_no_buyer_materials =>
      'No materials submitted by buyer';

  @override
  String order_dialog_delivery_note(String content) {
    return 'Delivery Note: $content';
  }

  @override
  String get order_dialog_delivery_files => 'Delivery Files:';

  @override
  String get order_intervention_title => 'Apply for Platform Intervention';

  @override
  String get order_intervention_desc =>
      'Having unresolved disputes? Platform support will intervene within 24 hours.';

  @override
  String get order_intervention_problem_type => 'Problem Type:';

  @override
  String get order_intervention_problem_desc => 'Problem Description:';

  @override
  String get order_intervention_problem_hint =>
      'Please describe the problem in detail...';

  @override
  String get order_intervention_validation_empty =>
      'Please enter a problem description';

  @override
  String get order_intervention_validation_min =>
      'Problem description must be at least 10 characters';

  @override
  String get order_intervention_tip =>
      'Note: Once submitted, it cannot be revoked. Each order can apply up to 2 times.';

  @override
  String get order_intervention_reason_communication => 'Communication Issue';

  @override
  String get order_intervention_reason_quality => 'Quality Dispute';

  @override
  String get order_intervention_reason_delivery => 'Delivery Issue';

  @override
  String get order_intervention_reason_refund => 'Refund Dispute';

  @override
  String get order_intervention_reason_service => 'Service Attitude';

  @override
  String get order_intervention_reason_other => 'Other Issues';

  @override
  String get order_intervention_submitting => 'Submitting application...';

  @override
  String order_intervention_failed(String error) {
    return 'Application failed: $error';
  }

  @override
  String get order_demand_replenishment_title =>
      'Request Supplementary Materials';

  @override
  String get order_demand_reform_title => 'Request Rework';

  @override
  String get order_demand_replenishment_desc =>
      'If you need the seller to provide more materials or explanations, please describe your needs in detail.';

  @override
  String get order_demand_reform_desc =>
      'If you are not satisfied with the delivery, you can request a rework. Please describe the specific issue.';

  @override
  String get order_demand_detail_label => 'Details:';

  @override
  String get order_demand_replenishment_hint =>
      'Please describe the materials or information needed...';

  @override
  String get order_demand_reform_hint =>
      'Please describe the reasons and requirements for rework...';

  @override
  String get order_demand_validation_empty => 'Please enter details';

  @override
  String get order_demand_validation_min =>
      'Details must be at least 10 characters';

  @override
  String get order_demand_replenishment_tip =>
      'Note: The seller will respond and provide supplementary materials within 24 hours.';

  @override
  String get order_demand_reform_tip =>
      'Note: After the rework request is submitted, the seller will reprocess your order.';

  @override
  String get order_demand_reason_incomplete => 'Incomplete Information';

  @override
  String get order_demand_reason_unclear => 'Unclear Requirements';

  @override
  String get order_demand_reason_additional => 'Additional Explanation Needed';

  @override
  String get order_demand_reason_reference => 'Reference Materials Needed';

  @override
  String get order_demand_reason_other => 'Other Reasons';

  @override
  String get order_demand_reason_quality => 'Quality Not Satisfactory';

  @override
  String get order_demand_reason_requirement => 'Does Not Meet Requirements';

  @override
  String get order_demand_reason_content_incomplete => 'Incomplete Content';

  @override
  String get order_demand_reason_error => 'Contains Errors';

  @override
  String get order_demand_submitting_replenishment =>
      'Submitting supplementary materials request...';

  @override
  String get order_demand_submitting_reform => 'Submitting rework request...';

  @override
  String order_demand_failed(String error) {
    return 'Application failed: $error';
  }

  @override
  String order_demand_edit_info_auto(int current, int remaining) {
    return 'Delivered $current times, $remaining free revision(s) remaining (auto-approved)';
  }

  @override
  String order_demand_edit_info_approval(int current) {
    return 'Delivered $current times, free revisions used up, seller approval required';
  }

  @override
  String get order_info_title => 'Order Info';

  @override
  String get order_info_order_number => 'Order No.: ';

  @override
  String get order_info_order_time => 'Order Time: ';

  @override
  String get order_info_pay_time => 'Payment Time: ';

  @override
  String get order_info_complete_time => 'Completion Time: ';

  @override
  String get order_info_remark => 'Order Remark: ';

  @override
  String get order_items_title => 'Product Info';

  @override
  String get order_items_empty => 'No product information';

  @override
  String order_items_count(int count) {
    return '$count items';
  }

  @override
  String get order_price_title => 'Price Details';

  @override
  String get order_price_total => 'Product Total';

  @override
  String get order_price_shipping => 'Shipping';

  @override
  String get order_price_discount => 'Discount';

  @override
  String get order_price_paid => 'Amount Paid';

  @override
  String get order_price_total_amount => 'Product Total';

  @override
  String get order_price_actual_paid => 'Amount Paid';

  @override
  String get order_requirement_title => 'Submit Requirements';

  @override
  String order_requirement_service_selected(String skuName, String price) {
    return 'Selected service: $skuName - ¥$price';
  }

  @override
  String get order_requirement_q1 =>
      '1. Please describe your requirements in detail';

  @override
  String get order_requirement_q1_hint =>
      'Please describe your requirements in as much detail as possible, including specific needs and expected results';

  @override
  String get order_requirement_q1_helper =>
      'If you need to provide reference materials, upload them in the attachment section below';

  @override
  String get order_requirement_q2 => '2. Additional notes (optional)';

  @override
  String get order_requirement_q2_hint =>
      'If you have any other notes or special requirements, please fill in here';

  @override
  String get order_requirement_warning =>
      'Please fill in your requirements carefully. After submission, the seller will start service based on your requirements';

  @override
  String get order_requirement_attachment_title => 'Attachments';

  @override
  String order_requirement_attachment_limit(int maxCount, int maxSize) {
    return 'Max $maxCount files, each up to ${maxSize}MB';
  }

  @override
  String get order_requirement_add => 'Add';

  @override
  String get order_requirement_click_select_file =>
      'Click here to select files';

  @override
  String get order_requirement_confirm_submit => 'Confirm Submit';

  @override
  String get order_requirement_wait_upload =>
      'Please wait for file upload to complete';

  @override
  String get order_requirement_upload_failed_title => 'File Upload Failed';

  @override
  String order_requirement_upload_failed_count(int count) {
    return '$count file(s) failed to upload. Retry?';
  }

  @override
  String get order_requirement_remove_failed => 'Remove Failed Files';

  @override
  String get order_requirement_retry_upload => 'Retry Upload';

  @override
  String get order_requirement_error_product_id =>
      'Error: Cannot get product ID';

  @override
  String get order_requirement_load_draft_failed => 'Failed to load draft';

  @override
  String get order_requirement_save_draft_failed => 'Failed to save draft';

  @override
  String order_requirement_max_files(int count) {
    return 'Maximum $count attachments allowed';
  }

  @override
  String order_requirement_pick_failed(String error) {
    return 'Failed to select file: $error';
  }

  @override
  String get order_requirement_default_service => 'Basic Service';

  @override
  String get order_evaluation_title => 'Review Product';

  @override
  String get order_evaluation_hint => 'Share your experience~';

  @override
  String get order_evaluation_add_images => 'Add Images (max 9)';

  @override
  String get order_evaluation_anonymous => 'Anonymous Review';

  @override
  String get order_evaluation_submit => 'Submit Review';

  @override
  String get order_evaluation_error_no_item =>
      'Error: Cannot find the product item to review';

  @override
  String get order_evaluation_max_images => 'Maximum 9 images allowed';

  @override
  String order_evaluation_success_count(int count, String ratio) {
    return 'Successfully processed $count images, average compression $ratio%';
  }

  @override
  String order_evaluation_failed_count(int count) {
    return '$count image(s) failed to process';
  }

  @override
  String order_evaluation_pick_failed(String error) {
    return 'Failed to select image: $error';
  }

  @override
  String get order_evaluation_processing => 'Processing...';

  @override
  String get order_evaluation_page_title => 'Write Review';

  @override
  String get order_delivery_not_satisfied => 'Not satisfied with delivery?';

  @override
  String get order_delivery_communicate_tip =>
      'When delivery count is insufficient, please communicate with the seller about additional deliveries';

  @override
  String get order_delivery_supplement => 'Request Supplement';

  @override
  String get order_delivery_remake => 'Request Remake';

  @override
  String get order_delivery_refund => 'Request Refund';

  @override
  String get order_delivery_unknown_file => 'Unknown File';

  @override
  String order_item_delivery_days(int days) {
    return 'Delivery: $days days';
  }

  @override
  String order_item_edit_count(int count) {
    return 'Revisions: $count times';
  }

  @override
  String get order_countdown_expired => 'Expired';

  @override
  String order_countdown_days_hours(int days, int hours) {
    return '${days}d ${hours}h';
  }

  @override
  String order_countdown_hours_minutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String order_countdown_minutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String order_countdown_seconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String order_countdown_days(int days) {
    return '${days}d';
  }

  @override
  String order_countdown_minutes_seconds(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String order_upload_progress(int percent) {
    return 'Uploading $percent%';
  }

  @override
  String get order_upload_retry => 'Retry Upload';

  @override
  String order_upload_failed(String error) {
    return 'Upload failed: $error';
  }

  @override
  String order_upload_size_limit(String size) {
    return 'File size exceeds limit (max $size)';
  }

  @override
  String order_upload_max_retry(int count) {
    return 'Maximum retry count reached ($count times)';
  }

  @override
  String get order_after_sale_processing => 'After-Sales Processing';

  @override
  String get order_after_sale_processing_msg =>
      'Your after-sales request is being processed. The seller will handle it within xx hours. Please be patient.';

  @override
  String get order_after_sale_mediation => 'Platform Mediation in Progress';

  @override
  String get order_after_sale_mediation_msg =>
      'Platform support has intervened. A resolution will be provided within xx business days. Please watch for notifications.';

  @override
  String get order_after_sale_rejected => 'After-Sales Request Rejected';

  @override
  String get order_after_sale_rejected_msg =>
      'Sorry, your after-sales request was not approved.';

  @override
  String get order_after_sale_default_title => 'After-Sales Status';

  @override
  String get order_after_sale_default_msg =>
      'This order is currently in the after-sales process.';

  @override
  String get order_after_sale_contact_seller => 'Contact Seller';

  @override
  String get order_after_sale_cancel_apply => 'Cancel Request';

  @override
  String get order_after_sale_contact_platform => 'Contact Platform Support';

  @override
  String get order_after_sale_add_evidence => 'Add Evidence';

  @override
  String get order_after_sale_add_evidence_tip =>
      'You can add evidence or wait patiently for the platform\'s resolution.';

  @override
  String get order_after_sale_apply_intervention =>
      'Apply for Platform Intervention';

  @override
  String get order_after_sale_refund_status => 'Refund Status:';

  @override
  String get order_after_sale_refund_amount => 'Refund Amount:';

  @override
  String get order_after_sale_reject_reason => 'Rejection Reason:';

  @override
  String get order_after_sale_reject_reason_detail =>
      'Reason: Insufficient evidence or does not meet refund conditions.';

  @override
  String get order_platform_intervention_title => 'Platform Intervention';

  @override
  String get order_platform_intervention_desc =>
      'If disputes cannot be resolved through negotiation, you can apply for platform support intervention';

  @override
  String get order_platform_intervention_apply =>
      'Apply for Platform Intervention';

  @override
  String get order_platform_intervention_in_progress =>
      'Platform Intervention in Progress';

  @override
  String get order_platform_intervention_processing => 'Processing';

  @override
  String get order_platform_intervention_processing_msg =>
      'Your application has been submitted. Platform support will contact you within 24 hours';

  @override
  String get order_platform_intervention_step1 => 'Application Submitted';

  @override
  String get order_platform_intervention_step1_desc =>
      'Waiting for platform support';

  @override
  String get order_platform_intervention_step2 => 'Support Intervention';

  @override
  String get order_platform_intervention_step2_desc =>
      'Contact both parties within 24 hours';

  @override
  String get order_platform_intervention_step3 => 'Issue Resolved';

  @override
  String get order_platform_intervention_step3_desc =>
      'Handled based on platform decision';

  @override
  String get order_card_product_unknown => 'Product name unknown';

  @override
  String get order_card_deleting => 'Deleting order...';

  @override
  String get order_card_deleted => 'Order deleted';

  @override
  String order_card_delete_failed(String error) {
    return 'Delete failed: $error';
  }

  @override
  String get order_card_canceling => 'Canceling order...';

  @override
  String get order_card_canceled => 'Order canceled';

  @override
  String order_card_cancel_failed(String error) {
    return 'Cancel failed: $error';
  }

  @override
  String order_card_load_detail_failed(String error) {
    return 'Failed to load order details: $error';
  }

  @override
  String get order_card_timeout_canceling => 'Timed out, will be canceled soon';

  @override
  String order_card_pay_in_time(String time) {
    return 'Pay within $time';
  }

  @override
  String get order_card_timeout_submit => 'Timed out, please submit soon';

  @override
  String order_card_submit_in_time(String time) {
    return 'Submit materials within $time';
  }

  @override
  String get order_card_seller_timeout => 'Seller timed out';

  @override
  String order_card_seller_accept_in_time(String time) {
    return 'Seller will accept within $time';
  }

  @override
  String order_card_delivery_days(int days) {
    return 'Delivery: within $days days';
  }

  @override
  String get order_card_auto_confirm_soon => 'Auto-confirmation soon';

  @override
  String order_card_auto_confirm_in(String time) {
    return 'Auto-confirm in $time';
  }

  @override
  String get order_card_evaluate_for_points =>
      'Awaiting review, earn points after review';

  @override
  String order_card_duration_days_hours(int days, int hours) {
    return '$days days $hours hours';
  }

  @override
  String order_card_duration_hours_minutes(int hours, int minutes) {
    return '$hours hours $minutes minutes';
  }

  @override
  String order_card_duration_minutes(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get order_card_duration_less_than_minute => 'Less than 1 minute';

  @override
  String get order_detail_invalid_id => 'Invalid Order ID';

  @override
  String get order_detail_error => 'Error';

  @override
  String get order_detail_title => 'Order Details';

  @override
  String order_detail_title_with_id(int id) {
    return 'Order Details (ID: $id)';
  }

  @override
  String order_detail_load_failed(String error) {
    return 'Load failed: $error';
  }

  @override
  String get order_detail_reload => 'Reload';

  @override
  String get order_detail_unavailable => 'Order data unavailable';

  @override
  String get order_list_title => 'My Orders';

  @override
  String get order_list_search_hint => 'Search order number or product name';

  @override
  String get order_list_empty => 'No orders found';

  @override
  String order_list_load_error(String error) {
    return 'Load error: $error';
  }

  @override
  String order_list_load_failed(String error) {
    return 'Load failed: $error';
  }

  @override
  String get order_list_select_category => 'Select a category to view orders';

  @override
  String get order_list_tab_all => 'All';

  @override
  String get order_list_tab_awaiting_payment => 'Payment';

  @override
  String get order_list_tab_awaiting_submission => 'Submission';

  @override
  String get order_list_tab_awaiting_start => 'Acceptance';

  @override
  String get order_list_tab_awaiting_delivery => 'Delivery';

  @override
  String get order_list_tab_awaiting_confirmation => 'Receipt';

  @override
  String get order_list_tab_awaiting_evaluation => 'Review';

  @override
  String get order_list_tab_after_sale => 'After-Sales';

  @override
  String get order_route_error => 'Error';

  @override
  String order_route_invalid_item_id(String id) {
    return 'Invalid product ID: $id';
  }

  @override
  String order_seller_detail_title(int id) {
    return 'Order Details (Seller) - #$id';
  }

  @override
  String order_seller_load_failed(int id, String error) {
    return 'Failed to load order #$id: $error';
  }

  @override
  String get order_seller_preparing => 'Preparing to load...';

  @override
  String get order_seller_order_number => 'Order No.';

  @override
  String get order_seller_order_time => 'Order Time';

  @override
  String get order_seller_pay_time => 'Payment Time';

  @override
  String get order_seller_complete_time => 'Completion Time';

  @override
  String get order_seller_cancel_time => 'Cancellation Time';

  @override
  String get order_seller_list_title => 'My Orders (Seller)';

  @override
  String get order_seller_tab_all => 'All';

  @override
  String get order_seller_tab_awaiting_start => 'Pending';

  @override
  String get order_seller_tab_awaiting_delivery => 'To Deliver';

  @override
  String get order_seller_tab_awaiting_confirmation => 'Awaiting Receipt';

  @override
  String get order_seller_tab_awaiting_evaluation => 'Awaiting Review';

  @override
  String get order_seller_tab_completed => 'Completed';

  @override
  String get order_seller_tab_after_sale => 'After-Sales';

  @override
  String get order_seller_tab_canceled => 'Canceled';

  @override
  String order_seller_load_failed_msg(String error) {
    return 'Load failed: $error';
  }

  @override
  String get order_seller_empty => 'No orders in this status';

  @override
  String order_seller_action_failed(String error) {
    return 'Action failed: $error';
  }

  @override
  String order_seller_pending_count(int count) {
    return 'You have $count orders to process';
  }

  @override
  String order_seller_pending_awaiting_start(int count) {
    return '$count pending acceptance';
  }

  @override
  String order_seller_pending_awaiting_delivery(int count) {
    return '$count to deliver';
  }

  @override
  String get order_seller_reject_order => 'Reject Order';

  @override
  String get order_seller_confirm_order => 'Accept Order';

  @override
  String get order_seller_contact_buyer => 'Contact Buyer';

  @override
  String get order_seller_go_deliver => 'Deliver';

  @override
  String get order_seller_view_delivery_content => 'View Delivery';

  @override
  String get order_seller_remind_buyer => 'Remind Buyer';

  @override
  String get order_seller_delete_record => 'Delete Record';

  @override
  String get order_seller_confirm_accept_title => 'Confirm Acceptance';

  @override
  String get order_seller_confirm_accept_content =>
      'Are you sure you want to accept this order?';

  @override
  String get order_seller_confirm_delete_title => 'Confirm Delete';

  @override
  String get order_seller_confirm_delete_content =>
      'Are you sure you want to delete this order record? This action cannot be undone.';

  @override
  String get order_seller_confirm_delete_canceled_content =>
      'Are you sure you want to delete this canceled order record? This action cannot be undone.';

  @override
  String get order_seller_confirm_btn => 'Confirm';

  @override
  String get order_seller_confirm_reject_title => 'Confirm Rejection';

  @override
  String get order_seller_confirm_reject_content =>
      'Are you sure you want to reject this order?';

  @override
  String get order_seller_confirm_reject_btn => 'Confirm Rejection';

  @override
  String get order_seller_reject_dialog_title => 'Reject Order';

  @override
  String get order_seller_reject_reason_label => 'Rejection Reason *';

  @override
  String get order_seller_reject_reason_hint =>
      'Please enter the rejection reason';

  @override
  String get order_seller_reject_reason_empty =>
      'Rejection reason cannot be empty';

  @override
  String get order_seller_reject_reason_required =>
      'Please enter the rejection reason';

  @override
  String get order_seller_remarks_label => 'Additional Notes (Optional)';

  @override
  String get order_seller_remarks_hint => 'Optional';

  @override
  String get order_seller_delivery_dialog_title => 'Delivery Content';

  @override
  String get order_seller_delivery_desc_label => 'Delivery Description *';

  @override
  String get order_seller_delivery_desc_hint =>
      'Please describe your delivery content';

  @override
  String get order_seller_delivery_desc_empty =>
      'Delivery description cannot be empty';

  @override
  String get order_seller_delivery_desc_required =>
      'Please enter delivery description';

  @override
  String get order_seller_delivery_attachment => 'Attachments';

  @override
  String get order_seller_delivery_select_file =>
      'Click the button below to select files';

  @override
  String get order_seller_delivery_add_attachment => 'Add Attachment';

  @override
  String get order_seller_delivery_file_select_soon =>
      'File selection feature coming soon';

  @override
  String get order_seller_delivery_confirm => 'Confirm Delivery';

  @override
  String order_seller_delivery_chat_hint(String productName) {
    return 'Please select the chat about product \"$productName\"';
  }

  @override
  String get order_seller_dynamic_delivered => 'Service Delivered';

  @override
  String get order_seller_dynamic_delivered_msg =>
      'You have completed the service delivery. Please wait for the buyer to confirm. If there are issues, the buyer may initiate after-sales.';

  @override
  String get order_seller_dynamic_completed =>
      'This order has been completed successfully.';

  @override
  String get order_seller_dynamic_canceled => 'This order has been canceled.';

  @override
  String get order_seller_dynamic_refused => 'Order Rejection Submitted';

  @override
  String get order_seller_dynamic_refused_msg =>
      'Your rejection request has been submitted and is awaiting processing.';

  @override
  String get order_seller_buyer_materials => 'Buyer Provided Materials';

  @override
  String get order_seller_attachment_label => 'Attachments:';

  @override
  String order_seller_view_attachment(String fileName) {
    return 'View attachment coming soon: $fileName';
  }

  @override
  String get order_evaluation_product_info => 'Product Information';

  @override
  String get order_list_retry => 'Retry';

  @override
  String chat_get_user_info_failed(String error) {
    return 'Failed to get user info: $error';
  }

  @override
  String get chat_user_refer_id_not_found => 'User referId not found';

  @override
  String get chat_no_chat_records => 'No chat records';

  @override
  String get chat_opponent_info_missing => 'Opponent info not available';

  @override
  String get chat_product_default => 'Product';

  @override
  String get chat_view_details => 'View Details';

  @override
  String get chat_product_info_incomplete =>
      'Product info incomplete, cannot view details';

  @override
  String get chat_uploading => 'Uploading...';

  @override
  String get chat_upload_failed => 'Upload failed';

  @override
  String get chat_retry => 'Retry';

  @override
  String get chat_image_loading => 'Loading...';

  @override
  String get chat_image_load_failed => 'Load failed';

  @override
  String get chat_revoke_time_missing =>
      'Message time info missing, cannot recall';

  @override
  String get chat_revoke_available => 'Can recall';

  @override
  String chat_revoke_expired(int seconds) {
    return 'Message sent over 2 minutes ago, cannot recall (exceeded by ${seconds}s)';
  }

  @override
  String get chat_unknown_seller => 'Unknown Seller';

  @override
  String get chat_product_conversation => 'Product conversation';

  @override
  String chat_product_conversation_count(int count) {
    return '$count product conversations';
  }

  @override
  String get chat_unknown_product => 'Unknown Product';

  @override
  String chat_user_inquiry_count(int count) {
    return '$count user inquiries';
  }

  @override
  String get chat_weekday_mon => 'Mon';

  @override
  String get chat_weekday_tue => 'Tue';

  @override
  String get chat_weekday_wed => 'Wed';

  @override
  String get chat_weekday_thu => 'Thu';

  @override
  String get chat_weekday_fri => 'Fri';

  @override
  String get chat_weekday_sat => 'Sat';

  @override
  String get chat_weekday_sun => 'Sun';

  @override
  String get chat_select_multiple_images => 'Select multiple images';

  @override
  String chat_image_compressed(String ratio) {
    return 'Image compressed $ratio%';
  }

  @override
  String chat_image_process_failed(String error) {
    return 'Image processing failed: $error';
  }

  @override
  String chat_images_processed_success(int count, String ratio) {
    return 'Successfully processed $count images, avg compression $ratio%';
  }

  @override
  String chat_images_process_failed_count(int count) {
    return '$count images failed to process';
  }

  @override
  String get chat_tap_to_view_product => 'Tap to view product details';

  @override
  String chat_yesterday_time(String time) {
    return 'Yesterday $time';
  }

  @override
  String get chat_no_messages_brief => 'No messages';

  @override
  String chat_select_image_error(String error) {
    return 'Error selecting images: $error';
  }

  @override
  String get after_sales_reason_none => 'None';

  @override
  String seller_auth_status_title(String type) {
    return '$type Certification';
  }

  @override
  String get seller_auth_status_label => 'Status: ';

  @override
  String get seller_auth_status_name_label => 'Name: ';

  @override
  String get seller_auth_status_materials => 'Certification Materials';

  @override
  String get seller_auth_status_no_materials => 'No certification materials';

  @override
  String get seller_auth_status_info => 'Certification Info';

  @override
  String get seller_auth_status_history => 'Certification History';

  @override
  String get seller_auth_status_no_history => 'No history records';

  @override
  String get seller_auth_status_reapply => 'Reapply';

  @override
  String get seller_auth_status_approved_hint =>
      'Certification approved, no need to resubmit';

  @override
  String get seller_auth_status_pending_hint =>
      'Certification under review, please wait';

  @override
  String get seller_auth_status_tag_approved => 'Certified';

  @override
  String get seller_auth_status_tag_pending => 'Under Review';

  @override
  String get seller_auth_status_tag_rejected => 'Rejected';

  @override
  String get seller_auth_status_tag_not_submitted => 'Not Submitted';

  @override
  String get seller_auth_status_type_idcard => 'Identity';

  @override
  String get seller_auth_status_type_education => 'Education';

  @override
  String get seller_auth_status_type_profession => 'Profession';

  @override
  String get seller_auth_status_type_company => 'Company';

  @override
  String get seller_auth_status_type_other => 'Other';

  @override
  String get seller_auth_status_field_auth_name => 'Certification Name';

  @override
  String get seller_auth_status_field_auth_type => 'Certification Type';

  @override
  String get seller_auth_status_field_company_name => 'Company Name';

  @override
  String get seller_auth_status_field_name => 'Name';

  @override
  String get seller_auth_status_field_school_name => 'School Name';

  @override
  String get seller_auth_status_field_profession => 'Profession/Position';

  @override
  String get seller_auth_status_field_name_or_title => 'Name/Title';

  @override
  String get seller_auth_status_field_remarks => 'Remarks';

  @override
  String get seller_auth_status_field_cert_number => 'Certificate Number';

  @override
  String get seller_auth_status_field_work_experience => 'Work Experience';

  @override
  String get seller_auth_status_field_issuer => 'Issuing Authority';

  @override
  String get seller_auth_status_field_credit_code =>
      'Unified Social Credit Code';

  @override
  String get seller_auth_status_field_legal_rep => 'Legal Representative';

  @override
  String get seller_auth_status_field_registered_capital =>
      'Registered Capital';

  @override
  String get seller_auth_status_field_establishment_date =>
      'Establishment Date';

  @override
  String get seller_auth_status_field_degree => 'Degree';

  @override
  String get seller_auth_status_field_major => 'Major';

  @override
  String get seller_auth_status_field_graduation_year => 'Graduation Year';

  @override
  String get seller_auth_status_field_id_number => 'ID Number';

  @override
  String get seller_auth_status_field_valid_period => 'Valid Period';

  @override
  String get seller_auth_status_field_submit_time => 'Submission Time';

  @override
  String get seller_auth_status_field_reject_reason => 'Rejection Reason';

  @override
  String get seller_auth_status_history_approved_title =>
      'Certification Approved';

  @override
  String seller_auth_status_history_approved_desc(String type) {
    return 'Your $type certification has been approved. You can now enjoy all certified seller benefits.';
  }

  @override
  String get seller_auth_status_history_submitted_title =>
      'Certification Submitted';

  @override
  String seller_auth_status_history_submitted_desc(String type) {
    return 'Your $type certification has been submitted. Review will be completed within 1-3 business days.';
  }

  @override
  String get seller_auth_status_history_rejected_title =>
      'Certification Rejected';

  @override
  String seller_auth_status_history_rejected_desc(String type, String reason) {
    return 'Your $type certification was rejected. Reason: $reason';
  }

  @override
  String get seller_auth_status_history_rejected_default_reason =>
      'Materials do not meet requirements';

  @override
  String get seller_product_preview_title => 'Product Preview';

  @override
  String get seller_product_preview_back_to_edit => 'Back to Edit';

  @override
  String get seller_product_preview_loading => 'Loading product info...';

  @override
  String get seller_product_preview_load_failed =>
      'Failed to load product info';

  @override
  String get seller_product_preview_retry => 'Retry';

  @override
  String get seller_product_preview_fetching => 'Fetching product data...';

  @override
  String get seller_product_preview_hint =>
      'This is preview mode. Buyers will see a similar interface.';

  @override
  String get seller_product_edit_unsaved_changes_title =>
      'Unsaved Changes Detected';

  @override
  String get seller_product_edit_unsaved_changes_message =>
      'You have unsaved content. Save as draft?';

  @override
  String get seller_product_edit_cancel => 'Cancel';

  @override
  String get seller_product_edit_discard => 'Discard';

  @override
  String get seller_product_edit_operation_failed => 'Operation failed';

  @override
  String get seller_product_edit_draft_saved => 'Draft saved successfully';

  @override
  String get seller_product_edit_publish_success =>
      'Service published! Under review. Check the \"On Sale\" list.';

  @override
  String get seller_product_edit_update_success =>
      'Service updated successfully';

  @override
  String get seller_product_edit_max_images =>
      'Maximum 9 images allowed. First 9 selected.';

  @override
  String seller_product_edit_price_required(String tierName) {
    return '$tierName price must be greater than 0';
  }

  @override
  String get seller_product_edit_form_incomplete =>
      'Form data incomplete. Please check highlighted fields.';

  @override
  String get seller_product_edit_add_attribute => 'Add Attribute';

  @override
  String seller_product_edit_attribute_max_chars(int max) {
    return 'Attribute name max $max characters';
  }

  @override
  String get seller_product_edit_confirm => 'Confirm';

  @override
  String get seller_product_edit_options_config => 'Options Configuration';

  @override
  String get seller_product_edit_new_option => 'New Option';

  @override
  String get seller_product_edit_option_hint => 'Enter option content';

  @override
  String get seller_product_edit_service_name_hint => 'Service Name';

  @override
  String get seller_product_edit_description_hint =>
      'Describe your service details, such as...';

  @override
  String get seller_product_edit_faq_title => 'FAQ Editor';

  @override
  String seller_product_edit_faq_count(int count) {
    return '$count questions';
  }

  @override
  String get seller_product_edit_add_question => 'Add Question';

  @override
  String get seller_product_edit_question_label => 'Question';

  @override
  String get seller_product_edit_question_hint =>
      'Enter a question buyers may ask';

  @override
  String get seller_product_edit_delete_question => 'Delete Question';

  @override
  String get seller_product_edit_answer_label => 'Answer';

  @override
  String get seller_product_edit_answer_hint => 'Enter the answer';

  @override
  String get seller_product_edit_buyer_info_title =>
      'Buyer Information Required';

  @override
  String seller_product_edit_buyer_info_count(int count) {
    return '$count items';
  }

  @override
  String get seller_product_edit_buyer_info_desc =>
      'Select the information types buyers need to provide (shown on order details page)';

  @override
  String get seller_product_edit_selected_items => 'Selected items:';

  @override
  String get seller_product_edit_required => 'Required';

  @override
  String get seller_product_edit_edit_tooltip => 'Edit';

  @override
  String get seller_product_edit_delete_tooltip => 'Delete';

  @override
  String seller_product_edit_add_info_title(String type) {
    return 'Add $type Info';
  }

  @override
  String get seller_product_edit_info_label => 'Info Label';

  @override
  String get seller_product_edit_info_label_hint =>
      'e.g., Company Logo Design Requirements';

  @override
  String get seller_product_edit_info_description => 'Detailed Description';

  @override
  String get seller_product_edit_info_description_hint =>
      'Describe the information buyers need to provide';

  @override
  String get seller_product_edit_required_field => 'Required Field';

  @override
  String get seller_product_edit_add => 'Add';

  @override
  String seller_product_edit_edit_info_title(String type) {
    return 'Edit $type Info';
  }

  @override
  String get seller_product_edit_save => 'Save';

  @override
  String seller_product_edit_cases_count(int count) {
    return '$count cases';
  }

  @override
  String get seller_product_edit_add_case => 'Add Case';

  @override
  String get seller_product_edit_image_load_failed => 'Image load failed';

  @override
  String get seller_product_edit_click_select_image => 'Click to select image';

  @override
  String get seller_product_edit_upload_failed => 'Upload Failed';

  @override
  String get seller_product_edit_upload_retry => 'Retry';

  @override
  String get seller_product_edit_case_title_label => 'Case Title';

  @override
  String get seller_product_edit_case_title_hint =>
      'Brief description of this case';

  @override
  String get seller_product_edit_case_desc_label => 'Case Description';

  @override
  String get seller_product_edit_case_desc_hint =>
      'Describe the background, process, or results';

  @override
  String get seller_product_edit_select_image_and_title =>
      'Please select an image and enter a title';

  @override
  String get seller_product_edit_cover_image => 'Service Cover Image';

  @override
  String get seller_product_edit_upload_success => 'Upload Successful';

  @override
  String seller_product_edit_upload_error(String error) {
    return 'Upload error: $error';
  }

  @override
  String get seller_product_edit_image_format_hint =>
      'Supports jpg, png, jpeg formats. Max 5MB per image, up to 9 images.';

  @override
  String get seller_product_edit_main_image => 'Main';

  @override
  String seller_product_edit_tier_price_label(String tierName) {
    return '$tierName Price';
  }

  @override
  String seller_product_edit_max_price(String max) {
    return 'Maximum: $max';
  }

  @override
  String seller_product_edit_price_exceed_max(String max) {
    return 'Price cannot exceed $max';
  }

  @override
  String get seller_product_edit_price_min => 'Minimum price is 0.01';

  @override
  String get seller_product_edit_delivery_period => 'Delivery Period';

  @override
  String get seller_product_edit_delivery_days_suffix => 'days';

  @override
  String seller_product_edit_max_days(int max) {
    return 'Max $max days';
  }

  @override
  String get seller_product_edit_times => 'Revisions';

  @override
  String get seller_product_edit_times_suffix => 'times';

  @override
  String seller_product_edit_max_times(int max) {
    return 'Max $max times';
  }

  @override
  String get seller_product_edit_input => 'Input';

  @override
  String get seller_product_edit_radio => 'Radio';

  @override
  String get seller_product_edit_draft_label => 'Draft';

  @override
  String get seller_product_edit_draft_unsaved_label => 'Draft*';

  @override
  String get seller_product_edit_publish => 'Publish';

  @override
  String get seller_product_edit_yes => 'Yes';

  @override
  String get seller_product_edit_no => 'No';

  @override
  String get seller_product_edit_add_selection_attribute =>
      'Add Selection Attribute';

  @override
  String get seller_product_edit_default_options_yes_no =>
      'Default options: Yes/No';

  @override
  String get seller_product_edit_attribute_name_label => 'Attribute Name *';

  @override
  String get seller_product_edit_attribute_name_example =>
      'e.g.: Color, Model, Material, Suitable Age';

  @override
  String get seller_product_edit_attribute_type_label => 'Attribute Type';

  @override
  String get seller_product_edit_required_item => 'Required';

  @override
  String seller_product_card_sales(int count) {
    return 'Sales: $count';
  }

  @override
  String get seller_product_card_view => 'View';

  @override
  String get seller_image_preview_main_image => 'Main';

  @override
  String get seller_image_preview_set_main => 'Set as Main';

  @override
  String get seller_image_preview_load_failed => 'Image load failed';

  @override
  String get seller_image_preview_delete_title => 'Delete Image';

  @override
  String seller_image_preview_delete_confirm(int index) {
    return 'Delete image $index?';
  }

  @override
  String get seller_image_preview_delete => 'Delete';

  @override
  String get seller_file_select => 'Select File';

  @override
  String get seller_file_selected => 'Selected files:';

  @override
  String seller_file_size(String size) {
    return 'Size: $size';
  }

  @override
  String get seller_file_size_unknown => 'Unable to get size';

  @override
  String seller_file_preview_unsupported(String name) {
    return 'Cannot preview this file type: $name';
  }

  @override
  String get seller_common_cancel => 'Cancel';

  @override
  String get profile_user_name_default => 'Username';

  @override
  String get profile_buyer_mode => 'Buyer Mode';

  @override
  String get profile_my_orders => 'My Orders';

  @override
  String get profile_my_dskk_section => 'My DSKK';

  @override
  String get profile_liked_stories => 'Liked Stories';

  @override
  String get profile_logout => 'Log Out';

  @override
  String get profile_avatar_updated_local =>
      'Avatar updated, but not saved to server yet';

  @override
  String profile_image_pick_error(String error) {
    return 'Error selecting image: $error';
  }

  @override
  String profile_feature_not_implemented(String feature) {
    return '$feature feature is not yet available';
  }

  @override
  String get profile_pending_payment_order => 'Pending Payment';

  @override
  String get profile_in_progress_order => 'In Progress';

  @override
  String get profile_completed_order => 'Completed';

  @override
  String get profile_refund_after_sales => 'Refund/After-sales';

  @override
  String get profile_account_deletion => 'Delete Account';

  @override
  String get profile_bound_phone => 'Bound Phone';

  @override
  String get profile_not_bound => 'Not Bound';

  @override
  String get profile_nickname => 'Nickname';

  @override
  String get profile_confirm_logout => 'Confirm Logout';

  @override
  String get profile_confirm_logout_message =>
      'Are you sure you want to log out?';

  @override
  String get profile_confirm => 'Confirm';

  @override
  String get profile_update_avatar => 'Update Avatar';

  @override
  String get profile_update_avatar_confirm =>
      'Are you sure you want to update your avatar?';

  @override
  String get profile_info_updated => 'Profile updated successfully!';

  @override
  String get profile_avatar_upload_timeout =>
      'Avatar upload timed out, please check your network and try again';

  @override
  String get profile_network_failed =>
      'Network connection failed, please check your network and try again';

  @override
  String profile_avatar_optimized(String ratio) {
    return 'Avatar optimized, compressed $ratio%';
  }

  @override
  String profile_avatar_process_failed(String error) {
    return 'Avatar processing failed: $error';
  }

  @override
  String profile_logout_error(String error) {
    return 'Error logging out: $error';
  }

  @override
  String get profile_nickname_empty => 'Please enter a nickname';

  @override
  String get profile_nickname_too_short =>
      'Nickname must be at least 2 characters';

  @override
  String get profile_nickname_too_long =>
      'Nickname cannot exceed 20 characters';

  @override
  String get profile_nickname_no_spaces => 'Nickname cannot contain spaces';

  @override
  String get profile_nickname_invalid_chars =>
      'Nickname can only contain Chinese, English, numbers, and underscores';

  @override
  String get profile_nickname_only_underscores =>
      'Nickname cannot contain only underscores';

  @override
  String get profile_nickname_unchanged => 'Nickname has not changed';

  @override
  String get profile_edit_nickname_title => 'Edit Nickname';

  @override
  String get profile_nickname_input_hint => 'Enter nickname';

  @override
  String get profile_nickname_rules =>
      'Set 2-20 characters, only Chinese, English, numbers, and underscores allowed';

  @override
  String get profile_nickname_updated => 'Nickname updated successfully!';

  @override
  String profile_nickname_update_failed(String error) {
    return 'Nickname update failed: $error';
  }

  @override
  String get profile_submit_changes => 'Submit Changes';

  @override
  String get profile_avatar_uploaded => 'Avatar uploaded successfully';

  @override
  String get profile_updated => 'Profile updated successfully';

  @override
  String get profile_reload => 'Reload';

  @override
  String get profile_account_balance => 'Account Balance';

  @override
  String get profile_pending_settlement => 'Pending Settlement';

  @override
  String get profile_total_income => 'Total Income';

  @override
  String get profile_load_wallet => 'Tap to load wallet info';

  @override
  String get profile_all_orders => 'All Orders';

  @override
  String get profile_awaiting_payment => 'Pending Payment';

  @override
  String get profile_awaiting_shipment => 'Pending Shipment';

  @override
  String get profile_awaiting_receipt => 'Pending Receipt';

  @override
  String get profile_awaiting_review => 'Pending Review';

  @override
  String get profile_shipping_address => 'Shipping Address';

  @override
  String get profile_browsing_history => 'Browsing History';

  @override
  String get profile_contact_support => 'Contact Support';

  @override
  String get profile_help_center => 'Help Center';

  @override
  String get profile_feedback => 'Feedback';

  @override
  String get profile_switch_to_seller_mode => 'Switch to Seller Mode';

  @override
  String get profile_take_photo => 'Take Photo';

  @override
  String get profile_choose_from_album => 'Choose from Album';

  @override
  String profile_image_pick_failed(String error) {
    return 'Failed to select image: $error';
  }

  @override
  String get profile_edit_profile => 'Edit Profile';

  @override
  String get profile_online_status => 'Online Status';

  @override
  String get profile_mission_title => 'Assistant\'s Mission';

  @override
  String get profile_mission_our_mission => 'Our Mission';

  @override
  String get profile_mission_our_mission_content =>
      'Connecting creativity with demand, making every idea possible. Our assistant is dedicated to providing the most thoughtful and intelligent service experience, becoming your most reliable digital partner in life and work.';

  @override
  String get profile_mission_core_values => 'Core Values';

  @override
  String get profile_mission_core_values_content =>
      '• User First: Always starting from user needs\n• Innovation Driven: Continuously exploring new technologies and methods\n• Integrity Service: Providing reliable and transparent service experiences\n• Growing Together: Moving forward with users and partners';

  @override
  String get profile_mission_service_promise => 'Service Promise';

  @override
  String get profile_mission_service_promise_content =>
      'We promise to provide every user with:\n\n✓ 24/7 intelligent service support\n✓ Personalized solution recommendations\n✓ Secure and reliable data protection\n✓ Continuously optimized user experience\n✓ Responsive customer service';

  @override
  String get profile_mission_future_vision => 'Future Vision';

  @override
  String get profile_mission_future_vision_content =>
      'To become a globally leading intelligent service platform, empowered by AI technology, enabling everyone to enjoy personalized and efficient digital life experiences. We believe technology should make life better and creativity easier to realize.';

  @override
  String get profile_mission_questions_suggestions =>
      'Questions or Suggestions?';

  @override
  String get profile_mission_listening =>
      'We are always listening to your voice, looking forward to creating a better future together.';

  @override
  String get profile_mission_contact_us => 'Contact Us';

  @override
  String get profile_mission_contact_coming_soon =>
      'Contact feature coming soon, stay tuned!';

  @override
  String get profile_wallet_title => 'My Wallet';

  @override
  String profile_wallet_error(String error) {
    return 'Error: $error';
  }

  @override
  String profile_wallet_occurred_error(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get profile_wallet_retry => 'Retry';

  @override
  String get profile_wallet_filter_all => 'All';

  @override
  String get profile_wallet_filter_income => 'Income';

  @override
  String get profile_wallet_filter_expense => 'Expense';

  @override
  String get profile_wallet_no_transactions => 'No transaction records';

  @override
  String profile_wallet_load_failed(String error) {
    return 'Loading failed: $error';
  }

  @override
  String profile_wallet_load_more_failed(String error) {
    return 'Failed to load more: $error';
  }

  @override
  String get profile_wallet_account_balance => 'Account Balance';

  @override
  String get profile_wallet_pending_amount => 'Pending Amount';

  @override
  String get profile_wallet_total_income => 'Total Income';

  @override
  String get profile_wallet_withdraw => 'Withdraw';

  @override
  String get profile_wallet_status_completed => 'Completed';

  @override
  String get profile_wallet_status_pending => 'Processing';

  @override
  String get profile_wallet_status_failed => 'Failed';

  @override
  String get profile_wallet_status_unknown => 'Unknown';

  @override
  String get profile_wallet_transaction_details => 'Transaction Details';

  @override
  String get profile_wallet_transaction_id => 'Transaction ID';

  @override
  String get profile_wallet_transaction_type => 'Type';

  @override
  String get profile_wallet_transaction_type_income => 'Income';

  @override
  String get profile_wallet_transaction_type_expense => 'Expense';

  @override
  String get profile_wallet_transaction_amount => 'Amount';

  @override
  String get profile_wallet_transaction_description => 'Description';

  @override
  String get profile_wallet_transaction_date => 'Date';

  @override
  String get profile_wallet_transaction_status => 'Status';

  @override
  String get profile_wallet_close => 'Close';

  @override
  String profile_wallet_available_balance(String symbol, String amount) {
    return 'Available balance: $symbol$amount';
  }

  @override
  String get profile_wallet_withdraw_amount => 'Withdrawal Amount';

  @override
  String get profile_wallet_withdraw_hint => 'Enter withdrawal amount';

  @override
  String get profile_wallet_withdraw_time =>
      'Withdrawal arrival time: 1-3 business days';

  @override
  String get profile_wallet_invalid_amount =>
      'Please enter a valid withdrawal amount';

  @override
  String get profile_wallet_exceed_balance =>
      'Withdrawal amount cannot exceed available balance';

  @override
  String get profile_wallet_confirm_withdraw => 'Confirm Withdrawal';

  @override
  String profile_wallet_withdraw_submitted(String symbol, String amount) {
    return 'Withdrawal request submitted: $symbol$amount';
  }

  @override
  String get profile_wallet_not_implemented =>
      'This feature is not yet available';

  @override
  String get auth_verification_expired => 'Verification code has expired';

  @override
  String auth_login_failed(String error) {
    return 'Login failed: $error';
  }

  @override
  String auth_code_send_failed(String error) {
    return 'Failed to send verification code: $error';
  }

  @override
  String get auth_login_success => 'Login successful!';

  @override
  String get auth_login => 'Login';

  @override
  String get auth_privacy_policy => 'Privacy Policy';

  @override
  String get auth_and => 'and';

  @override
  String get auth_user_agreement => 'User Agreement';

  @override
  String get auth_invalid_phone => 'Please enter a valid 11-digit phone number';

  @override
  String get auth_get_code => 'Get Code';

  @override
  String get payment_creating_order => 'Creating order...';

  @override
  String get payment_processing => 'Processing payment...';

  @override
  String get payment_credit_card => 'Credit Card Payment';

  @override
  String get payment_confirm_order => 'Confirm Order';

  @override
  String get payment_quantity_label => 'Quantity:';

  @override
  String get payment_order_summary => 'Order Summary';

  @override
  String get payment_product_amount => 'Product Amount';

  @override
  String get payment_quantity => 'Quantity';

  @override
  String get payment_order_total => 'Order Total';

  @override
  String get payment_method => 'Payment Method';

  @override
  String get payment_processing_ellipsis => 'Processing...';

  @override
  String get payment_confirm_pay => 'Confirm Payment';

  @override
  String get payment_success => 'Payment Successful';

  @override
  String get payment_failed => 'Payment Failed';

  @override
  String get payment_view_order_detail => 'View Order Details';

  @override
  String get payment_back_to_orders => 'Back to Orders';

  @override
  String get payment_success_tip =>
      'Thank you for your purchase! You can view details in your orders.';

  @override
  String get payment_failed_tip =>
      'Payment was not successful. Please try again or choose another payment method.';

  @override
  String get home_banner_image_load_failed => 'Image failed to load';

  @override
  String home_banner_placeholder(int index) {
    return 'Banner $index';
  }

  @override
  String get home_no_data => 'No data available';

  @override
  String get product_detail_no_faq => 'No FAQs available';

  @override
  String product_detail_buy_button(String price) {
    return 'Buy Now $price';
  }

  @override
  String get product_detail_buyer_requirements => 'Buyer Requirements';

  @override
  String get product_detail_no_buyer_requirements =>
      'Seller has not set buyer requirements yet';

  @override
  String get after_sales_apply => 'Apply for After-sales';

  @override
  String get after_sales_apply_remake => 'Apply for Remake';

  @override
  String get after_sales_apply_supplement => 'Apply for Supplement';

  @override
  String get after_sales_apply_refund => 'Apply for Refund';

  @override
  String after_sales_max_images(int max) {
    return 'Maximum $max images allowed';
  }

  @override
  String after_sales_images_processed(int count, String ratio) {
    return 'Successfully processed $count images, average compression $ratio%';
  }

  @override
  String after_sales_images_failed(int count) {
    return '$count images failed to process';
  }

  @override
  String after_sales_image_pick_failed(String error) {
    return 'Failed to select images: $error';
  }

  @override
  String get after_sales_select_reason => 'Please select a reason';

  @override
  String get after_sales_reason_label => 'Reason';

  @override
  String get after_sales_reason_quality => 'Product quality issue';

  @override
  String get after_sales_reason_mismatch =>
      'Product doesn\'t match description';

  @override
  String get after_sales_reason_wrong_item => 'Seller sent wrong item';

  @override
  String get after_sales_reason_unwanted => 'No longer wanted';

  @override
  String get after_sales_reason_other => 'Other';

  @override
  String get after_sales_description_label => 'Description';

  @override
  String get after_sales_description_hint =>
      'Please describe the issue in detail...';

  @override
  String after_sales_refund_max_hint(String symbol, String amount) {
    return 'Maximum refund $symbol$amount';
  }

  @override
  String get after_sales_enter_refund_amount =>
      'Please enter the refund amount';

  @override
  String get after_sales_invalid_amount => 'Please enter a valid amount';

  @override
  String get after_sales_amount_must_positive =>
      'Refund amount must be greater than 0';

  @override
  String after_sales_amount_exceed(String symbol, String amount) {
    return 'Refund amount cannot exceed $symbol$amount';
  }

  @override
  String after_sales_upload_proof(int max) {
    return 'Upload proof (max $max images)';
  }

  @override
  String get after_sales_remove_image => 'Remove image';

  @override
  String get after_sales_submit => 'Submit Application';

  @override
  String after_sales_loading_failed(String error) {
    return 'Loading failed: $error';
  }

  @override
  String get after_sales_detail_retry => 'Retry';

  @override
  String get after_sales_initializing => 'Initializing...';

  @override
  String get after_sales_status_audit_reject =>
      'After-Sales Application Rejected';

  @override
  String get after_sales_status_refund_success => 'Refund Successful';

  @override
  String get after_sales_status_processing => 'After-Sales Processing';

  @override
  String get after_sales_subtitle_wait_audit =>
      'Seller will process your application within 48 hours';

  @override
  String get after_sales_subtitle_audit_pass =>
      'Refund will arrive within 1-3 business days';

  @override
  String get after_sales_subtitle_audit_reject =>
      'If you disagree, you can request platform intervention';

  @override
  String get after_sales_subtitle_refund_success =>
      'Refund completed, please check your account';

  @override
  String get after_sales_subtitle_canceled =>
      'You have canceled the after-sales application';

  @override
  String get after_sales_subtitle_default =>
      'Please wait patiently for the result';

  @override
  String get after_sales_product_info => 'Product Information';

  @override
  String get after_sales_product_unknown => 'Unknown Product';

  @override
  String after_sales_spec(String spec) {
    return 'Spec: $spec';
  }

  @override
  String after_sales_quantity(int count) {
    return 'Quantity: $count';
  }

  @override
  String get after_sales_info => 'After-sales Information';

  @override
  String get after_sales_application_number => 'Application Number';

  @override
  String get after_sales_application_time => 'Application Time';

  @override
  String get after_sales_refund_amount_label => 'Refund Amount';

  @override
  String get after_sales_application_reason => 'Application Reason';

  @override
  String get after_sales_detailed_description => 'Detailed Description';

  @override
  String get after_sales_audit_remark => 'Audit Remark';

  @override
  String get after_sales_revoke => 'Revoke Application';

  @override
  String get after_sales_modify => 'Modify Application';

  @override
  String get after_sales_platform_intervention => 'Platform Intervention';

  @override
  String get after_sales_list_title => 'After-Sales List';

  @override
  String get after_sales_no_records => 'No after-sales records';

  @override
  String get after_sales_please_wait => 'Please wait...';

  @override
  String get after_sales_unknown_product => 'Unknown Product';

  @override
  String after_sales_status_label(String status) {
    return 'Status: $status';
  }

  @override
  String get after_sales_select_type => 'Select After-sales Type';

  @override
  String get after_sales_type_remake => 'Request Remake';

  @override
  String get after_sales_type_remake_desc =>
      'Not satisfied with the result? Negotiate a remake with the creator';

  @override
  String get after_sales_type_supplement => 'Request Supplement';

  @override
  String get after_sales_type_supplement_desc =>
      'Result incomplete? Negotiate a supplement with the creator';

  @override
  String get after_sales_type_refund => 'Request Refund';

  @override
  String get after_sales_type_refund_desc => 'Negotiate a refund';

  @override
  String get after_sales_no_record_for_order =>
      'No after-sales record found for this order';

  @override
  String after_sales_unknown_error(String error) {
    return 'Unknown error loading after-sales details: $error';
  }

  @override
  String get after_sales_server_error => 'Server error';

  @override
  String get after_sales_cache_error => 'Cache error';

  @override
  String get after_sales_network_error => 'Network connection error';

  @override
  String get after_sales_general_unknown_error => 'An unknown error occurred';

  @override
  String get favorites_title => 'My Favorites';

  @override
  String get favorites_tab_services => 'Services';

  @override
  String get favorites_tab_sellers => 'Sellers';

  @override
  String get favorites_close => 'Close';

  @override
  String get favorites_empty_services => 'No saved services yet';

  @override
  String get favorites_empty_sellers => 'No followed sellers yet';

  @override
  String get favorites_empty_services_hint =>
      'Tap the favorite button when browsing services';

  @override
  String get favorites_empty_sellers_hint =>
      'Tap the follow button when browsing sellers';

  @override
  String get favorites_unfollow => 'Unfollow';

  @override
  String get favorites_remove => 'Remove from favorites';

  @override
  String get favorites_seller_type_member => 'Individual Seller';

  @override
  String get favorites_seller_type_enterprise => 'Enterprise Seller';

  @override
  String get favorites_seller_type_platform => 'Platform Seller';

  @override
  String get favorites_seller_type_default => 'Seller';

  @override
  String get favorites_status_active => 'Active';

  @override
  String get favorites_status_inactive => 'Inactive';

  @override
  String get favorites_status_suspended => 'Suspended';

  @override
  String get favorites_status_banned => 'Banned';

  @override
  String ai_docs_chat_create_failed(String error) {
    return 'Unable to create chat session: $error';
  }

  @override
  String get ai_docs_chat_room_empty =>
      'Chat room ID is empty, cannot enter chat';

  @override
  String ai_docs_chat_enter_error(String error) {
    return 'Error entering chat: $error';
  }

  @override
  String get ai_docs_rate_limit_details => 'Usage Details';

  @override
  String ai_docs_rate_limit_remaining(int count) {
    return '$count remaining';
  }

  @override
  String ai_docs_rate_limit_reset_in(String time) {
    return 'Resets in $time';
  }

  @override
  String get ai_docs_rate_limit_rules => 'Usage Rules';

  @override
  String get ai_docs_rate_limit_burst => 'Burst Limit';

  @override
  String get ai_docs_rate_limit_hourly => 'Hourly Limit';

  @override
  String get ai_docs_rate_limit_upgrade => 'Upgrade for More';

  @override
  String get ai_docs_rate_limit_upgrade_coming => 'Upgrade feature coming soon';

  @override
  String ai_docs_rate_limit_time_hours(int hours) {
    return '$hours hours';
  }

  @override
  String ai_docs_rate_limit_time_minutes(int minutes) {
    return '$minutes minutes';
  }

  @override
  String ai_docs_rate_limit_time_seconds(int seconds) {
    return '$seconds seconds';
  }

  @override
  String get ai_docs_rate_limit_reset => 'Reset';

  @override
  String get ai_docs_rate_limit_warning_title => 'Running Low on Usage';

  @override
  String get ai_docs_rate_limit_today_remaining => 'Today\'s Remaining';

  @override
  String ai_docs_rate_limit_remaining_info(int count, String time) {
    return '$count uses remaining, resets in $time';
  }

  @override
  String get ai_docs_rate_limit_today_usage => 'Today\'s Usage';

  @override
  String get auth_verification_code_expired => 'Verification code has expired';

  @override
  String get auth_get_verification_code => 'Get Code';

  @override
  String get home_image_load_failed => 'Image load failed';

  @override
  String get home_reached_end => 'You\'ve reached the end';

  @override
  String get home_reviews_title => 'Reviews';

  @override
  String home_reviews_load_failed(String error) {
    return 'Load failed: $error';
  }

  @override
  String get home_reviews_no_reviews => 'No reviews yet';

  @override
  String get home_reviews_default_content => 'Great, very patient';

  @override
  String get home_reviews_seller_reply => 'Seller Reply';

  @override
  String home_reviews_years_ago(int count) {
    return '$count year(s) ago';
  }

  @override
  String home_reviews_months_ago(int count) {
    return '$count month(s) ago';
  }

  @override
  String home_reviews_days_ago(int count) {
    return '$count day(s) ago';
  }

  @override
  String home_reviews_hours_ago(int count) {
    return '$count hour(s) ago';
  }

  @override
  String home_reviews_minutes_ago(int count) {
    return '$count minute(s) ago';
  }

  @override
  String get home_reviews_just_now => 'Just now';

  @override
  String get after_sales_apply_title => 'Apply for After-Sales';

  @override
  String get after_sales_select_reason_hint => 'Please select a reason';

  @override
  String get after_sales_select_reason_validator => 'Please select a reason';

  @override
  String after_sales_refund_amount_hint(String symbol, String amount) {
    return 'Maximum refund $symbol$amount';
  }

  @override
  String get after_sales_refund_amount_required => 'Please enter refund amount';

  @override
  String get after_sales_refund_amount_invalid => 'Please enter a valid amount';

  @override
  String get after_sales_refund_amount_positive =>
      'Refund amount must be greater than 0';

  @override
  String after_sales_refund_amount_exceed(String symbol, String amount) {
    return 'Refund amount cannot exceed $symbol$amount';
  }

  @override
  String after_sales_upload_evidence(int max) {
    return 'Upload evidence (max $max images)';
  }

  @override
  String after_sales_image_process_success(int count, String ratio) {
    return 'Successfully processed $count images, avg compression $ratio%';
  }

  @override
  String after_sales_image_process_failed(int count) {
    return '$count image(s) failed to process';
  }

  @override
  String after_sales_detail_load_failed(String error) {
    return 'Load failed: $error';
  }

  @override
  String get after_sales_detail_initializing => 'Initializing...';

  @override
  String get after_sales_info_title => 'After-Sales Information';

  @override
  String get after_sales_info_order_number => 'Application No.';

  @override
  String get after_sales_info_apply_time => 'Application Time';

  @override
  String get after_sales_info_refund_amount => 'Refund Amount';

  @override
  String get after_sales_info_reason => 'Reason';

  @override
  String get after_sales_info_description => 'Description';

  @override
  String get after_sales_info_audit_remark => 'Review Remark';

  @override
  String after_sales_list_load_failed(String error) {
    return 'Load failed: $error';
  }

  @override
  String get after_sales_list_empty => 'No after-sales applications';

  @override
  String get after_sales_list_loading => 'Please wait...';

  @override
  String get after_sales_list_unknown_product => 'Unknown Product';

  @override
  String after_sales_list_status(String status) {
    return 'Status: $status';
  }

  @override
  String after_sales_list_apply_time(String time) {
    return 'Applied: $time';
  }

  @override
  String get after_sales_select_type_title => 'Select After-Sales Type';

  @override
  String get after_sales_type_remake_title => 'I want a remake';

  @override
  String get after_sales_type_remake_subtitle =>
      'Not satisfied with the result, negotiate a redo with the creator';

  @override
  String get after_sales_type_supplement_title => 'I want a supplement';

  @override
  String get after_sales_type_supplement_subtitle =>
      'Result is incomplete, negotiate supplementation with the creator';

  @override
  String get after_sales_type_refund_title => 'I want a refund';

  @override
  String get after_sales_type_refund_subtitle => 'Negotiate refund';

  @override
  String get favorites_seller_status_active => 'Active';

  @override
  String get favorites_seller_status_inactive => 'Inactive';

  @override
  String get favorites_seller_status_suspended => 'Suspended';

  @override
  String get favorites_seller_status_banned => 'Banned';

  @override
  String get app_store_settings => 'Store Settings';

  @override
  String get app_wallet => 'Wallet';

  @override
  String get app_wallet_init_failed => 'Failed to initialize wallet page';

  @override
  String get app_error_label => 'Error';

  @override
  String get app_go_back => 'Go Back';

  @override
  String get app_page_not_found => 'Page Not Found';

  @override
  String get app_path_error => 'Path error';

  @override
  String get app_error_generic => 'Error';

  @override
  String get app_dev_menu_title => 'Developer Debug Menu';

  @override
  String get app_dev_common_entries => 'Common Entries';

  @override
  String get app_dev_dskk => 'DSKK';

  @override
  String get app_dev_order_module_buyer => 'Order Module (Buyer)';

  @override
  String get app_dev_order_list => 'Order List';

  @override
  String get app_dev_order_detail_example => 'Order Detail (Example)';

  @override
  String get app_dev_order_module_seller => 'Order Module (Seller)';

  @override
  String get app_dev_seller_order_list => 'Seller Order List';

  @override
  String get app_dev_seller_order_detail_example =>
      'Seller Order Detail (Example)';

  @override
  String get app_dev_seller_module => 'Seller Module';

  @override
  String get app_dev_seller_center => 'Seller Center (Home)';

  @override
  String get app_dev_ai_docs_module => 'AI Docs Module';

  @override
  String get app_dev_ai_chat => 'AI Chat';

  @override
  String get app_dev_test_other => 'Test/Other';

  @override
  String get app_dev_current_credentials =>
      'Current Test Credentials (Hardcoded): ';

  @override
  String get app_dev_temp_injection =>
      '(Temporary injection, will be removed after Auth module merge)';

  @override
  String app_dev_navigation_failed(String path, String error) {
    return 'Navigation failed: $path - $error';
  }

  @override
  String get core_processing => 'Processing...';

  @override
  String get core_yesterday => 'Yesterday';

  @override
  String get payment_test_title => 'Payment Test';

  @override
  String get payment_check_availability => 'Check payment method availability';

  @override
  String get payment_test_params => 'Test Parameters';

  @override
  String get payment_order_number => 'Order Number';

  @override
  String get payment_amount_yuan => 'Amount';

  @override
  String get payment_product_name => 'Product Name';

  @override
  String get payment_select_method => 'Select Payment Method';

  @override
  String payment_test_button(String method, String amount) {
    return 'Test $method ¥$amount';
  }

  @override
  String get payment_usage_instructions => 'Instructions';

  @override
  String get payment_instruction_1 => '1. Modify test parameters above';

  @override
  String get payment_instruction_2 => '2. Select payment method to test';

  @override
  String get payment_instruction_3 =>
      '3. Click test button to initiate payment';

  @override
  String get payment_instruction_4 =>
      '4. Click info button to check payment method availability';

  @override
  String get payment_test_warning =>
      'Note: Use 0.01 for testing in test environment';

  @override
  String get payment_test_product => 'Test Product';

  @override
  String payment_initiated_success(String message) {
    return 'Payment initiated: $message';
  }

  @override
  String payment_failed_message(String message) {
    return 'Payment failed: $message';
  }

  @override
  String payment_exception(String error) {
    return 'Payment error: $error';
  }

  @override
  String get payment_availability_title => 'Payment Method Availability';

  @override
  String get payment_alipay => 'Alipay';

  @override
  String get payment_wechat => 'WeChat Pay';

  @override
  String get payment_wallet_balance => 'Wallet Balance';

  @override
  String get payment_confirm => 'OK';

  @override
  String payment_check_failed(String error) {
    return 'Check failed: $error';
  }

  @override
  String get payment_alipay_subtitle => 'Fast & secure payment';

  @override
  String get payment_wechat_subtitle => 'WeChat secure payment';

  @override
  String get payment_amount_label => 'Amount: ';

  @override
  String get payment_terms_agreement =>
      'By clicking \"Pay Now\" you agree to our terms of service';

  @override
  String get payment_create_order_failed => 'Failed to create payment order';

  @override
  String get payment_method_test_title => 'Payment Method Test';

  @override
  String get payment_alipay_pay => 'Alipay Payment';

  @override
  String get payment_test_functions => 'Test Functions';

  @override
  String get payment_test_alipay => 'Test Alipay Payment';

  @override
  String get payment_test_wechat => 'Test WeChat Payment';

  @override
  String get payment_test_credit_card => 'Test Credit Card Payment';

  @override
  String get payment_recent_test_result => 'Recent Test Results';

  @override
  String get payment_no_test_result => 'No test results yet';

  @override
  String get payment_available => 'Available';

  @override
  String get payment_unavailable => 'Unavailable';

  @override
  String payment_method_label(String name) {
    return 'Payment method: $name';
  }

  @override
  String get payment_mock_mode => 'Mock Mode';

  @override
  String payment_error_label(String error) {
    return 'Error: $error';
  }

  @override
  String get payment_nav_network_failed => 'Network Connection Failed';

  @override
  String get payment_nav_network_error_message =>
      'Network error, please check your connection and try again';

  @override
  String get payment_nav_view_orders => 'View Orders';

  @override
  String get payment_nav_retry_payment => 'Retry Payment';

  @override
  String get payment_nav_result_unknown_title => 'Payment Result Unknown';

  @override
  String get payment_nav_result_unknown_message =>
      'Payment result cannot be confirmed. Please check order status later or contact support';

  @override
  String get payment_nav_query_status => 'Check Status';

  @override
  String get payment_nav_cancel_continue =>
      'Payment cancelled. You can continue to complete the payment';

  @override
  String get payment_nav_processing =>
      'Payment is being processed. Please check order status later';

  @override
  String get payment_nav_success => 'Payment successful';

  @override
  String get payment_nav_failed => 'Payment failed';

  @override
  String get payment_nav_retrying => 'Retrying payment...';

  @override
  String get payment_nav_retry_failed =>
      'Cannot retry payment, order information lost';

  @override
  String get payment_nav_querying => 'Checking payment status...';

  @override
  String get payment_nav_query_failed =>
      'Cannot check status, order information lost';

  @override
  String payment_test_description(String subject) {
    return '$subject - Payment Test';
  }

  @override
  String get chat_translating => 'Translating...';

  @override
  String get chat_translation_label => 'Translation';

  @override
  String get after_sales_info_evidence => 'Evidence';

  @override
  String get agentScopeServicesRead => 'Search and view services';

  @override
  String get agentScopeRequestsRead => 'View my requests and status';

  @override
  String get agentScopeRequestsCreate => 'Create App-reviewed request drafts';

  @override
  String get agentStatusActive => 'Connected';

  @override
  String get agentStatusRevoked => 'Revoked';

  @override
  String get agentStatusExpired => 'Expired';

  @override
  String get agentStatusAwaitingReview => 'Awaiting App review';

  @override
  String get agentStatusApproved => 'Approved';

  @override
  String get agentStatusSubmitted => 'Submitted to provider';

  @override
  String get agentStatusProviderResponded => 'Provider responded';

  @override
  String get agentStatusAbandoned => 'Abandoned';

  @override
  String get agentConnectTitle => 'Connect Agent';

  @override
  String get agentConnectDescription =>
      'Confirm the device and permissions. The CLI can access DeepStream only after you allow it here.';

  @override
  String get agentInvalidCode => 'Enter the 8-character user code';

  @override
  String get agentUserCode => 'User code';

  @override
  String get agentCheckRequest => 'Check connection request';

  @override
  String get agentChoosePermission =>
      'Keep at least one permission, or deny an untrusted device.';

  @override
  String get agentAuthorizationApproved =>
      'Connection allowed. You can return to the CLI.';

  @override
  String get agentAuthorizationDenied => 'Connection denied.';

  @override
  String get agentUnknownPlatform => 'Unknown device';

  @override
  String get agentRequestedPermissions => 'Requested permissions';

  @override
  String get agentNeverIncludes =>
      'Never includes passwords, verification codes, payment, wallet, automatic orders, or unrelated local files.';

  @override
  String get agentDeny => 'Deny';

  @override
  String get agentAllow => 'Allow connection';

  @override
  String get agentAndCliTitle => 'Agent & CLI';

  @override
  String get agentConnectedAgents => 'Connected Agents';

  @override
  String get agentRevokeAll => 'Revoke all';

  @override
  String get agentRevokeAllConfirmation =>
      'All Agents will be signed out immediately and must be authorized again. History will not be deleted.';

  @override
  String get agentRevoke => 'Revoke';

  @override
  String get agentNoConnectedAgents => 'No connected Agents';

  @override
  String get agentNoConnectedAgentsHint =>
      'Run ds auth login on your computer to start a secure connection.';

  @override
  String get agentRetry => 'Retry';

  @override
  String get agentNoPaymentNotice =>
      'Agents cannot pay, use your wallet, or place orders automatically. Request drafts still require App review.';

  @override
  String agentLastUsed(String time) {
    return 'Last used: $time';
  }

  @override
  String get agentDetails => 'Agent details';

  @override
  String get agentSessionId => 'Session identifier';

  @override
  String get agentStatus => 'Status';

  @override
  String get agentConnectedAt => 'Connected at';

  @override
  String get agentLastUsedLabel => 'Last used';

  @override
  String get agentPermissions => 'Permissions';

  @override
  String get agentAtLeastOnePermission =>
      'Keep at least one permission, or revoke this Agent.';

  @override
  String get agentSavePermissions => 'Save permissions';

  @override
  String get agentCannotAddPermissions =>
      'You can only remove permissions here. Adding permissions requires authorization again.';

  @override
  String get agentRecentSecurityEvents => 'Recent security events';

  @override
  String get agentRevokeAgent => 'Revoke this Agent';

  @override
  String get agentRevokeConfirmation =>
      'This device will be signed out immediately. History remains, and reconnecting requires authorization.';

  @override
  String get agentRequestDrafts => 'Agent request drafts';

  @override
  String get agentOpenChat => 'Open consultation chat';

  @override
  String get agentNoRequestDrafts => 'No Agent-created request drafts';

  @override
  String get agentReviewRequest => 'Review request draft';

  @override
  String get agentRequestBrief => 'Request brief';

  @override
  String get agentServiceId => 'Service ID';

  @override
  String get agentCreatedAt => 'Created at';

  @override
  String get agentSubmittedAt => 'Submitted at';

  @override
  String get agentProviderRespondedAt => 'Provider responded at';

  @override
  String get agentChatId => 'Consultation chat ID';

  @override
  String get agentReviewSafetyNotice =>
      'Submitting creates a consultation and sends this brief to the provider. It does not pay or create an order.';

  @override
  String get agentApproveRequest => 'Submit to provider';

  @override
  String get agentAbandonRequest => 'Abandon draft';

  @override
  String get agentApproveRequestConfirmation =>
      'Send this request to the provider and create a consultation? This will not pay or place an order.';

  @override
  String get agentAbandonRequestConfirmation => 'Abandon this request draft?';

  @override
  String get agentApprove => 'Confirm submission';

  @override
  String get agentAbandon => 'Abandon';

  @override
  String get agentManageConnectedAgents => 'Manage connected Agents';

  @override
  String get agentErrorInvalidCode => 'This connection code is invalid.';

  @override
  String get agentErrorExpired =>
      'This connection request has expired. Start login again from the CLI.';

  @override
  String get agentErrorAlreadyUsed =>
      'This connection request has already been used or canceled.';

  @override
  String get agentErrorDenied => 'This connection request was denied.';

  @override
  String get agentErrorRateLimited =>
      'Too many attempts. Wait a moment and try again.';

  @override
  String get agentErrorNotFound => 'This Agent record no longer exists.';

  @override
  String get agentErrorGeneric =>
      'DeepStream could not complete this Agent operation. Check your connection and try again.';

  @override
  String get agentAuthorizationAlreadyApproved =>
      'This connection has already been approved. Return to the CLI.';

  @override
  String get agentAuthorizationAlreadyDenied =>
      'This connection has already been denied.';

  @override
  String get agentAuthorizationAlreadyUsed =>
      'This connection code has already been used.';

  @override
  String get agentAuthorizationUnavailable =>
      'This connection request is no longer available.';

  @override
  String get agentAuditConnected => 'Agent connected';

  @override
  String get agentAuditRefreshed => 'Session refreshed';

  @override
  String get agentAuditReplayBlocked => 'Suspicious token reuse blocked';

  @override
  String get agentAuditPermissionsReduced => 'Permissions reduced';

  @override
  String get agentAuditRevoked => 'Agent revoked';

  @override
  String get agentAuditSecurityEvent => 'Security event';

  @override
  String get agentAuditSuccess => 'Succeeded';

  @override
  String get agentAuditRecorded => 'Recorded';

  @override
  String get agentClientType => 'Client type';

  @override
  String get agentClientId => 'Client identifier';

  @override
  String get agentAccessExpiresAt => 'Access expires';

  @override
  String get agentAuthorizationExpiresAt => 'Authorization expires';

  @override
  String get agentAuthorizationRequestExpiresAt => 'Connection request expires';

  @override
  String get agentClientMetadataNotice =>
      'The client, device, system, and version above are declared by the connecting program. Verify the device and only install the CLI from a DeepStream official domain.';

  @override
  String get agentAuditAuthorizationRequested => 'Connection requested';

  @override
  String get agentAuditAuthorizationApproved => 'Connection approved';

  @override
  String get agentAuditAuthorizationDenied => 'Connection denied';

  @override
  String get agentAuditAllRevoked => 'All Agents revoked';

  @override
  String get agentAuditRequestCreated => 'Request draft created';

  @override
  String get agentAuditRequestApproved => 'Request draft approved';

  @override
  String get agentAuditRequestAbandoned => 'Request draft abandoned';

  @override
  String get agentViewTaskStatus => 'View task status';

  @override
  String get dsnTaskStatusTitle => 'Task status';

  @override
  String get dsnTaskIdentity => 'Task identity';

  @override
  String get dsnTaskTraceId => 'Task trace ID';

  @override
  String get dsnTaskOperationTraceId => 'Operation trace ID';

  @override
  String get dsnTaskAxes => 'Interaction state';

  @override
  String get dsnTaskLifecycle => 'Task lifecycle';

  @override
  String get dsnTaskResponsibility => 'Responsibility action';

  @override
  String get dsnTaskSyncStatus => 'Sync status';

  @override
  String get dsnTaskWaitingOn => 'Waiting on';

  @override
  String get dsnTaskPrimaryAction => 'Primary action';

  @override
  String get dsnTaskRefreshProjection => 'Refresh status';

  @override
  String get dsnTaskReceipt => 'Receipt';

  @override
  String get dsnTaskNoReceipt => 'No receipt is available yet.';

  @override
  String get dsnTaskLoadReceipt => 'Load receipt';

  @override
  String get dsnTaskRefreshReceipt => 'Refresh receipt';

  @override
  String get dsnTaskReceiptState => 'Receipt state';

  @override
  String get dsnTaskReceiptOrder => 'Order ID';

  @override
  String get dsnTaskReceiptDeliveries => 'Deliveries';

  @override
  String get dsnTaskReceiptGeneratedAt => 'Generated at';

  @override
  String get dsnTaskReceiptSource => 'Receipt source';

  @override
  String get dsnTaskLegacyFallback =>
      'The legacy facts view is being used; the append-only receipt is not available yet.';

  @override
  String get dsnTaskActionRecoverOperation => 'Recover original operation';

  @override
  String get dsnTaskActionRecoverTask => 'Recover task state';

  @override
  String get dsnTaskActionReviewResponsibility =>
      'Review pending responsibility';

  @override
  String get dsnTaskActionRecoveryInProgress => 'Recovery in progress';

  @override
  String get dsnTaskActionViewProgress => 'View progress';

  @override
  String get dsnTaskActionViewSystemStatus => 'View system status';

  @override
  String get dsnTaskActionViewRecord => 'View record';

  @override
  String get dsnTaskActionDomain => 'View next step';

  @override
  String get dsnTaskActionUnknown => 'Further confirmation required';

  @override
  String get credit_wallet_available => 'Available credits';

  @override
  String get credit_wallet_usage_notice =>
      'Credits can be used for goods and services in DeepStream. They cannot currently be withdrawn or transferred.';

  @override
  String get credit_purchase_title => 'Buy credits';

  @override
  String get credit_purchase_subtitle =>
      'Choose a credit pack. Payment is processed by your app store.';

  @override
  String get credit_purchase_unavailable =>
      'Credit purchases are currently unavailable.';

  @override
  String get credit_purchase_reload => 'Reload';

  @override
  String credit_purchase_credits(int credits) {
    return '$credits credits';
  }

  @override
  String get credit_purchase_checking => 'Checking…';

  @override
  String get credit_purchase_check => 'Check status';

  @override
  String get credit_purchase_check_arrival => 'Check status';

  @override
  String get credit_purchase_disclaimer =>
      'Credits are for use within DeepStream and cannot be withdrawn, transferred, or redeemed for cash. Payments and refunds are handled by your app store.';

  @override
  String credit_amount_positive(int credits) {
    return '+$credits credits';
  }

  @override
  String credit_amount_negative(int credits) {
    return '-$credits credits';
  }

  @override
  String get credit_purchase_status_pending_detected =>
      'A purchase awaiting verification was found. Checking whether the credits have arrived.';

  @override
  String get credit_purchase_status_server_pending =>
      'The server is still processing your previous purchase. Check again shortly.';

  @override
  String get credit_purchase_status_no_products =>
      'No credit packs are currently available.';

  @override
  String get credit_purchase_status_load_failed =>
      'Could not load credit packs. Try again later.';

  @override
  String get credit_purchase_status_balance_preflight_failed =>
      'Could not retrieve your latest credit balance, so the purchase was not started.';

  @override
  String get credit_purchase_status_cancelled => 'Purchase canceled.';

  @override
  String get credit_purchase_status_store_pending =>
      'Your app store is processing the payment. Do not purchase again.';

  @override
  String get credit_purchase_status_submitted =>
      'Payment submitted. Checking whether the credits have arrived.';

  @override
  String get credit_purchase_status_network_ambiguous =>
      'The connection was interrupted, so the purchase result is not yet confirmed. Do not purchase again.';

  @override
  String get credit_purchase_status_store_ambiguous =>
      'Your app store returned an inconclusive result. Verification is in progress; do not purchase again.';

  @override
  String get credit_purchase_status_failed =>
      'The purchase was not completed. Try again later.';

  @override
  String get credit_purchase_status_unsafe_reconciliation =>
      'Your previous purchase cannot be verified safely. Do not purchase again; contact support.';

  @override
  String get credit_purchase_status_checking_again =>
      'Checking the purchase status again.';

  @override
  String get credit_purchase_status_balance_updated_guarded =>
      'Your credit balance was updated, but the on-device verification record could not be cleared safely. Check again later.';

  @override
  String get credit_purchase_status_confirmed => 'Credits added.';

  @override
  String get credit_purchase_status_reversed =>
      'This purchase was reversed or refunded, so no credits were added.';

  @override
  String get credit_purchase_status_delayed =>
      'Payment verification is still in progress. Do not purchase again. If the credits do not arrive or the app store has not charged you after an extended period, contact support.';

  @override
  String get agentMandates => 'Agent mandates';

  @override
  String get agentMandatesHint =>
      'A mandate is a fixed, limited authorization you review in this app. It never shares your login or Agent credentials.';

  @override
  String get agentCreateMandate => 'Create mandate';

  @override
  String get agentMandateNoItems => 'No mandates yet';

  @override
  String get agentMandateNoAgents =>
      'Connect an active Agent before creating a mandate.';

  @override
  String get agentMandateTemplate => 'Fixed template';

  @override
  String get agentMandateAgent => 'Connected Agent';

  @override
  String get agentMandateResource => 'Server resource reference';

  @override
  String get agentMandateResourceHint =>
      'Use the request, accepted offer, or commitment reference supplied by DeepStream.';

  @override
  String get agentMandateResourceVersion =>
      'Expected resource version (optional)';

  @override
  String get agentMandateSpecHash => 'Expected specification hash (optional)';

  @override
  String get agentMandateQuoteHash => 'Expected quote hash (optional)';

  @override
  String get agentMandatePreview => 'Review fixed authorization';

  @override
  String get agentMandateReviewTitle => 'Review mandate';

  @override
  String get agentMandateConfirm => 'Confirm mandate';

  @override
  String get agentMandateConfirmMessage =>
      'Confirming creates a limited authorization for the shown Agent and server resource. It cannot be expanded from the Agent.';

  @override
  String get agentMandateExpiresAt => 'Review expires at';

  @override
  String get agentMandateAllowedActions => 'Allowed actions';

  @override
  String get agentMandateStatus => 'Status';

  @override
  String get agentMandateVersion => 'Mandate version';

  @override
  String get agentMandateHash => 'Mandate hash';

  @override
  String get agentMandateRevokedAt => 'Revoked at';

  @override
  String get agentMandateRevoke => 'Revoke mandate';

  @override
  String get agentMandateRevokeConfirm =>
      'Revoke this authorization now? New Agent operations will be blocked; historical facts remain intact.';
}
