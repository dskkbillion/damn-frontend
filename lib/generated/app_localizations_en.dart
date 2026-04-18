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
  String get nav_ai_assistant => 'Look';

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
  String get chat_filter_buyer => 'My Purchases';

  @override
  String get chat_filter_seller => 'My Sales';

  @override
  String get chat_filter_mode_all => 'Showing all chats';

  @override
  String get chat_filter_mode_buyer => 'Showing my purchase chats only';

  @override
  String get chat_filter_mode_seller => 'Showing my sales chats only';

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
}
