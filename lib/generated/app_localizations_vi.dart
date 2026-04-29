// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get language_settings => 'Cài đặt ngôn ngữ';

  @override
  String get system_language => 'Theo hệ thống';

  @override
  String get system_language_description =>
      'Tự động sử dụng ngôn ngữ của thiết bị';

  @override
  String get ai_docs_assistant_title => 'Trợ lý AI';

  @override
  String get ai_docs_unnamed_conversation => 'Cuộc hội thoại chưa đặt tên';

  @override
  String get ai_docs_loading => 'Đang tải...';

  @override
  String get ai_docs_match_button => 'Khớp';

  @override
  String get ai_docs_select_conversation_first =>
      'Vui lòng chọn cuộc hội thoại trước';

  @override
  String get ai_docs_please_enter_message => 'Vui lòng nhập nội dung tin nhắn';

  @override
  String get ai_docs_recommended_services => 'Dịch vụ đề xuất';

  @override
  String ai_docs_recommendations_error(String error) {
    return 'Tải dịch vụ đề xuất thất bại: $error';
  }

  @override
  String get ai_docs_no_recommendations => 'Chưa có dịch vụ đề xuất';

  @override
  String get ai_docs_dispatched => 'Đã phân phối';

  @override
  String get ai_docs_enter_chat => 'Vào chat';

  @override
  String get ai_docs_let_them_see => 'Cho họ xem';

  @override
  String get ai_docs_welcome_title => 'Chào mừng đến với Trợ lý AI';

  @override
  String get ai_docs_welcome_message =>
      'Gửi tin nhắn ngay để bắt đầu trò chuyện, hệ thống sẽ tự động tạo phòng chat cho bạn';

  @override
  String get ai_docs_auto_create_text =>
      'Chưa chọn cuộc hội thoại, tự động tạo cuộc hội thoại mới và gửi tin nhắn';

  @override
  String get ai_docs_auto_create_voice =>
      'Chưa chọn cuộc hội thoại, tự động tạo cuộc hội thoại mới và gửi tin nhắn thoại';

  @override
  String get ai_docs_cancelling_generation => 'Đang hủy tạo nội dung...';

  @override
  String get allocating_step1 => 'Đang phân phối';

  @override
  String get allocating_step2 => 'Đang phân phối.';

  @override
  String get allocating_step3 => 'Đang phân phối..';

  @override
  String get allocating_step4 => 'Đang phân phối...';

  @override
  String get ai_docs_add_image => 'Thêm ảnh';

  @override
  String get ai_docs_stop_recording => 'Dừng ghi âm';

  @override
  String get ai_docs_start_recording => 'Ghi âm giọng nói';

  @override
  String get ai_docs_recording => 'Đang ghi âm... nhấn để dừng gửi';

  @override
  String get ai_docs_enter_message => 'Nhập tin nhắn...';

  @override
  String get ai_docs_stop_generation => 'Dừng tạo';

  @override
  String get ai_docs_send_message => 'Gửi tin nhắn';

  @override
  String get ai_docs_uploading_images =>
      'Ảnh đang được tải lên, vui lòng chờ...';

  @override
  String get ai_docs_mic_permission_denied => 'Quyền truy cập micrô bị từ chối';

  @override
  String ai_docs_recording_error(String error) {
    return 'Lỗi khi bắt đầu ghi âm: $error';
  }

  @override
  String get ai_docs_recording_file_not_found =>
      'Lỗi: Không tìm thấy tệp ghi âm';

  @override
  String get ai_docs_stop_recording_error => 'Lỗi khi dừng ghi âm';

  @override
  String ai_docs_stop_recording_error_with_reason(String error) {
    return 'Lỗi khi dừng ghi âm: $error';
  }

  @override
  String ai_docs_image_picking_error(String error) {
    return 'Lỗi khi chọn ảnh: $error';
  }

  @override
  String get ai_docs_conversation_list => 'Danh sách hội thoại';

  @override
  String get ai_docs_no_messages => 'Chưa có tin nhắn, hãy bắt đầu trò chuyện!';

  @override
  String get ai_docs_new_chat => 'Chat mới';

  @override
  String get ai_docs_load_conversations_failed => 'Tải hội thoại thất bại';

  @override
  String get ai_docs_retry => 'Thử lại';

  @override
  String get ai_docs_no_conversations => 'Chưa có hội thoại';

  @override
  String get ai_docs_delete_conversation_tooltip => 'Xóa hội thoại';

  @override
  String get ai_docs_delete_conversation_title => 'Xóa hội thoại?';

  @override
  String get ai_docs_delete_conversation_content =>
      'Bạn có chắc muốn xóa vĩnh viễn hội thoại này không?';

  @override
  String get ai_docs_cancel => 'Hủy';

  @override
  String get ai_docs_delete => 'Xóa';

  @override
  String get ai_docs_please_select_conversation_to_delete =>
      'Vui lòng chọn hội thoại cần xóa trước';

  @override
  String get ai_docs_generate_title => 'AI tạo tiêu đề';

  @override
  String get ai_docs_generate_title_tooltip =>
      'Để AI tạo tiêu đề cho hội thoại này';

  @override
  String get ai_docs_generating_title => 'Đang tạo tiêu đề...';

  @override
  String get ai_docs_title_generated => 'Tiêu đề đã được tạo';

  @override
  String ai_docs_title_generation_failed(String error) {
    return 'Tạo tiêu đề thất bại: $error';
  }

  @override
  String get ai_docs_edit_title => 'Chỉnh sửa tiêu đề';

  @override
  String get ai_docs_edit_title_hint => 'Vui lòng nhập tiêu đề mới';

  @override
  String get ai_docs_title_updated => 'Tiêu đề đã được cập nhật';

  @override
  String ai_docs_title_update_failed(String error) {
    return 'Cập nhật tiêu đề thất bại: $error';
  }

  @override
  String get ai_docs_title_too_long => 'Tiêu đề không được vượt quá 50 ký tự';

  @override
  String get ai_docs_title_empty => 'Tiêu đề không được để trống';

  @override
  String get nav_ai_assistant => 'DSKK';

  @override
  String get nav_home => 'Trang chủ';

  @override
  String get nav_messages => 'Tin nhắn';

  @override
  String get nav_profile => 'Cá nhân';

  @override
  String get nav_dev => 'Dev';

  @override
  String get nav_seller_analytics => 'Thống kê';

  @override
  String get nav_seller_products => 'Sản phẩm';

  @override
  String get nav_seller_messages => 'Tin nhắn';

  @override
  String get nav_seller_profile => 'Cá nhân';

  @override
  String get chat_list_title => 'Danh sách chat';

  @override
  String get chat_loading => 'Đang tải...';

  @override
  String chat_error_loading(String error) {
    return 'Tải thất bại: $error';
  }

  @override
  String get chat_no_messages => 'Chưa có tin nhắn, hãy bắt đầu trò chuyện!';

  @override
  String get chat_admin_title => 'Quản trị viên hệ thống';

  @override
  String get chat_notification_center => 'Trung tâm thông báo';

  @override
  String get chat_notification_description =>
      'Thông báo quan trọng về hệ thống, đơn hàng, đánh giá, v.v.';

  @override
  String get chat_enter_message => 'Nhập tin nhắn...';

  @override
  String get chat_yesterday => 'Hôm qua';

  @override
  String get chat_image_message => '[Hình ảnh]';

  @override
  String get chat_audio_message => '[Giọng nói]';

  @override
  String get chat_file_message => '[Tệp]';

  @override
  String get chat_allocate_message => '[DSKK]';

  @override
  String get chat_payment_prompt_message => '[Yêu cầu thanh toán]';

  @override
  String get chat_revoked_message => '[Tin nhắn đã thu hồi]';

  @override
  String get chat_unknown_message => '[Tin nhắn không xác định]';

  @override
  String get chat_unknown_user => 'Người dùng không xác định';

  @override
  String get chat_invalid_session => 'Phiên không hợp lệ';

  @override
  String get chat_opponent_not_found => 'Không tìm thấy thông tin đối phương';

  @override
  String get chat_message_recalled => 'Tin nhắn đã được thu hồi';

  @override
  String get chat_copy => 'Sao chép';

  @override
  String get chat_recall => 'Thu hồi';

  @override
  String get chat_copied_to_clipboard => 'Đã sao chép vào clipboard';

  @override
  String get chat_me => 'Tôi';

  @override
  String get chat_buyer => 'Người mua';

  @override
  String get chat_i_want_seller_to_see => 'Tôi muốn người bán xem';

  @override
  String get chat_wants_to_see => 'muốn xem';

  @override
  String get chat_collapse => 'Thu gọn';

  @override
  String get chat_expand => 'Mở rộng';

  @override
  String get chat_admin_connection_error =>
      'Không thể kết nối đến quản trị viên hệ thống';

  @override
  String get chat_audio_pause => 'Tạm dừng';

  @override
  String get chat_audio_play => 'Phát';

  @override
  String get chat_markdown_example_title1 => 'Đây là tiêu đề cấp 1';

  @override
  String get chat_markdown_example_title2 => 'Đây là tiêu đề cấp 2';

  @override
  String get chat_markdown_example_bold_italic =>
      'Đây là văn bản **in đậm** và văn bản *in nghiêng*.';

  @override
  String get chat_markdown_example_list1 => 'Đây là mục danh sách 1';

  @override
  String get chat_markdown_example_list2 => 'Đây là mục danh sách 2';

  @override
  String get chat_markdown_example_list3 => 'Đây là mục danh sách lồng nhau';

  @override
  String get chat_markdown_example_quote =>
      'Đây là văn bản trích dẫn, hỗ trợ hiển thị nhiều dòng';

  @override
  String get chat_markdown_example_table_col1 => 'Cột 1';

  @override
  String get chat_markdown_example_table_col2 => 'Cột 2';

  @override
  String get chat_markdown_example_table_content1 => 'Nội dung 1';

  @override
  String get chat_markdown_example_table_content2 => 'Nội dung 2';

  @override
  String get chat_markdown_example_table_content3 => 'Nội dung 3';

  @override
  String get chat_markdown_example_table_content4 => 'Nội dung 4';

  @override
  String get chat_pick_from_gallery => 'Chọn từ thư viện ảnh';

  @override
  String get chat_take_photo => 'Chụp ảnh';

  @override
  String get chat_send_markdown => 'Gửi ví dụ Markdown';

  @override
  String get chat_switch_to_text => 'Chuyển sang nhập văn bản';

  @override
  String get chat_switch_to_voice => 'Chuyển sang nhập giọng nói';

  @override
  String get chat_send => 'Gửi';

  @override
  String get chat_attach => 'Gửi ảnh/tệp';

  @override
  String get chat_filter_all => 'Tất cả';

  @override
  String get chat_filter_buyer => 'Mua của tôi';

  @override
  String get chat_filter_seller => 'Bán của tôi';

  @override
  String get chat_filter_mode_all => 'Đang hiển thị tất cả chat';

  @override
  String get chat_filter_mode_buyer => 'Chỉ hiển thị chat mua hàng';

  @override
  String get chat_filter_mode_seller => 'Chỉ hiển thị chat bán hàng';

  @override
  String get chat_press_to_talk => 'Nhấn giữ để nói';

  @override
  String chat_release_to_send(int duration) {
    return 'Thả để gửi (${duration}s)';
  }

  @override
  String get chat_camera_permission_denied_title =>
      'Quyền truy cập camera bị tắt';

  @override
  String get chat_camera_permission_denied_message =>
      'Vui lòng bật quyền truy cập camera trong cài đặt hệ thống để sử dụng chức năng chụp ảnh.';

  @override
  String get chat_mic_permission_denied_title => 'Quyền truy cập micrô bị tắt';

  @override
  String get chat_mic_permission_denied_message =>
      'Vui lòng bật quyền truy cập micrô trong cài đặt hệ thống để sử dụng chức năng ghi âm.';

  @override
  String get chat_permission_denied_cancel => 'Hủy';

  @override
  String get chat_permission_denied_settings => 'Đến cài đặt';

  @override
  String get chat_mic_permission_denied =>
      'Không có quyền truy cập micrô, không thể ghi âm';

  @override
  String get chat_camera_permission_denied =>
      'Không có quyền truy cập camera, không thể chụp ảnh';

  @override
  String chat_recording_error(String error) {
    return 'Không thể bắt đầu ghi âm: $error';
  }

  @override
  String chat_stop_recording_error(String error) {
    return 'Dừng ghi âm thất bại: $error';
  }

  @override
  String chat_image_picking_error(String error) {
    return 'Lỗi khi chọn ảnh: $error';
  }

  @override
  String get chat_web_recording_not_supported =>
      'Nền tảng Web chưa hỗ trợ chức năng ghi âm';

  @override
  String get profile_personal_center => 'Trung tâm cá nhân';

  @override
  String get profile_login_prompt => 'Vui lòng đăng nhập để xem hồ sơ của bạn';

  @override
  String get profile_login_button => 'Đăng nhập';

  @override
  String get auth_phone_number => 'Số điện thoại';

  @override
  String get auth_select_country_region => 'Chọn quốc gia/vùng lãnh thổ';

  @override
  String get auth_phone_validation_empty => 'Vui lòng nhập số điện thoại';

  @override
  String get auth_phone_validation_invalid_cn =>
      'Vui lòng nhập số điện thoại 11 chữ số';

  @override
  String get auth_phone_validation_invalid_cn_start =>
      'Số điện thoại phải bắt đầu bằng số 1';

  @override
  String get auth_phone_validation_invalid_us =>
      'Vui lòng nhập số điện thoại 10 chữ số';

  @override
  String get auth_phone_validation_invalid_jp_kr =>
      'Vui lòng nhập số điện thoại 10 hoặc 11 chữ số';

  @override
  String get auth_phone_validation_invalid_general =>
      'Vui lòng nhập số điện thoại hợp lệ';

  @override
  String profile_loading_error(String error) {
    return 'Tải thất bại: $error';
  }

  @override
  String get profile_my_dskk => 'DSKK của tôi';

  @override
  String get profile_favorites => 'Yêu thích';

  @override
  String get profile_my_wallet => 'Ví của tôi';

  @override
  String get profile_wallet => 'Ví';

  @override
  String get profile_settings => 'Cài đặt';

  @override
  String get profile_account_security => 'Tài khoản & Bảo mật';

  @override
  String get profile_message_notifications => 'Thông báo tin nhắn';

  @override
  String get profile_about_us => 'Về chúng tôi';

  @override
  String get profile_assistant_mission => 'Sứ mệnh của trợ lý';

  @override
  String get profile_switch_to_seller => 'Chuyển sang chế độ người bán';

  @override
  String profile_switch_error(String error) {
    return 'Không thể chuyển sang chế độ người bán: $error';
  }

  @override
  String get profile_edit_nickname => 'Chỉnh sửa biệt danh';

  @override
  String get profile_nickname_hint => 'Vui lòng nhập biệt danh mới';

  @override
  String get profile_nickname_empty_error => 'Biệt danh không được để trống';

  @override
  String get profile_nickname_length_error =>
      'Biệt danh không được vượt quá 20 ký tự';

  @override
  String get profile_cancel => 'Hủy';

  @override
  String get profile_save => 'Lưu';

  @override
  String get profile_default_name => 'Người dùng';

  @override
  String get profile_online => 'Trực tuyến';

  @override
  String get profile_offline => 'Ngoại tuyến';

  @override
  String get profile_avatar_upload_failed =>
      'Tải ảnh đại diện thất bại, vui lòng thử lại';

  @override
  String get profile_orders => 'Đơn hàng của tôi';

  @override
  String get profile_pending_payment => 'Chờ thanh toán';

  @override
  String get profile_in_progress => 'Chờ nộp';

  @override
  String get profile_completed => 'Chờ nhận';

  @override
  String get profile_refund => 'Hậu mãi';

  @override
  String profile_navigation_error(String error) {
    return 'Không thể điều hướng đến danh sách đơn hàng: $error';
  }

  @override
  String get home_title => 'Trang chủ';

  @override
  String get home_search_hint => 'Tìm kiếm dịch vụ';

  @override
  String get home_loading => 'Đang tải...';

  @override
  String home_loading_failed(String error) {
    return 'Tải thất bại: $error';
  }

  @override
  String get home_retry => 'Thử lại';

  @override
  String get home_end_of_list => 'Đã đến cuối danh sách';

  @override
  String get home_no_content => 'Chưa có nội dung đề xuất';

  @override
  String get home_pull_to_refresh =>
      'Kéo xuống để làm mới và nhận nội dung đề xuất';

  @override
  String get home_refreshing_recommendations => 'Đang làm mới đề xuất...';

  @override
  String get home_loading_more => 'Đang tải thêm...';

  @override
  String get home_back_to_top_refresh => 'Lên đầu trang và làm mới';

  @override
  String home_banner_clicked(String targetType, String targetValue) {
    return 'Đã nhấn vào banner: $targetType - $targetValue';
  }

  @override
  String home_product_card_clicked(String name) {
    return 'Đã nhấn vào thẻ dịch vụ: $name';
  }

  @override
  String home_recommend_clicked(String name) {
    return 'Đã nhấn nút \"Cho họ xem\": $name';
  }

  @override
  String get product_recommend_button => 'Cho họ xem';

  @override
  String get product_image_loading_failed => 'Tải ảnh thất bại';

  @override
  String get product_default_name => 'Sản phẩm';

  @override
  String get search_title => 'Tìm kiếm';

  @override
  String get search_button => 'Tìm kiếm';

  @override
  String get search_hot_keywords => 'Từ khóa nổi bật';

  @override
  String get search_history => 'Lịch sử tìm kiếm';

  @override
  String get search_no_results => 'Không tìm thấy dịch vụ liên quan';

  @override
  String search_failed(String error) {
    return 'Tìm kiếm thất bại: $error';
  }

  @override
  String product_detail_loading_failed(String error) {
    return 'Tải thất bại: $error';
  }

  @override
  String get product_detail_retry => 'Thử lại';

  @override
  String get product_detail_please_wait => 'Vui lòng đợi...';

  @override
  String get product_detail_contact_seller => 'Liên hệ người bán';

  @override
  String get product_detail_verified_label => 'Đã xác minh';

  @override
  String get product_detail_published_status => 'Đã đăng';

  @override
  String get product_detail_more => 'Xem thêm';

  @override
  String get product_detail_collapse => 'Thu gọn';

  @override
  String get product_detail_delivery_times => 'Số lần giao hàng';

  @override
  String get product_detail_delivery_period => 'Thời gian giao hàng';

  @override
  String get product_detail_buy_now => 'Mua ngay (1)';

  @override
  String product_detail_buy_now_with_price(String price) {
    return 'Mua ngay ¥$price';
  }

  @override
  String get product_detail_faq => 'Câu hỏi thường gặp';

  @override
  String get product_detail_case_showcase => 'Trưng bày mẫu';

  @override
  String get product_detail_no_cases => 'Chưa có mẫu trưng bày';

  @override
  String product_detail_reviews(int count) {
    return 'Đánh giá ($count)';
  }

  @override
  String get product_detail_view_all => 'Xem tất cả';

  @override
  String get product_detail_no_reviews => 'Chưa có đánh giá';

  @override
  String get product_detail_basic_package => 'Cơ bản';

  @override
  String get product_detail_standard_package => 'Tiêu chuẩn';

  @override
  String get product_detail_premium_package => 'Cao cấp';

  @override
  String get product_detail_basic_tier => 'Cơ bản';

  @override
  String get product_detail_standard_tier => 'Tiêu chuẩn';

  @override
  String get product_detail_premium_tier => 'Cao cấp';

  @override
  String get product_detail_sample_review => 'Tốt, rất kiên nhẫn';

  @override
  String get product_detail_sample_user => 'Rui123';

  @override
  String get product_reviews_title => 'Đánh giá';

  @override
  String product_reviews_loading_failed(String error) {
    return 'Tải thất bại: $error';
  }

  @override
  String get product_reviews_retry => 'Thử lại';

  @override
  String get product_reviews_no_reviews => 'Chưa có đánh giá';

  @override
  String get product_reviews_sample_content => 'Tốt, rất kiên nhẫn';

  @override
  String product_reviews_years_ago(int count) {
    return '$count năm trước';
  }

  @override
  String product_reviews_months_ago(int count) {
    return '$count tháng trước';
  }

  @override
  String product_reviews_days_ago(int count) {
    return '$count ngày trước';
  }

  @override
  String product_reviews_hours_ago(int count) {
    return '$count giờ trước';
  }

  @override
  String product_reviews_minutes_ago(int count) {
    return '$count phút trước';
  }

  @override
  String get product_reviews_just_now => 'Vừa xong';

  @override
  String get product_reviews_seller_reply => 'Phản hồi của người bán';

  @override
  String product_reviews_total_count(int count) {
    return 'Tổng cộng $count đánh giá';
  }

  @override
  String get product_reviews_filter_all => 'Tất cả';

  @override
  String get product_reviews_filter_with_images => 'Có ảnh';

  @override
  String get product_reviews_filter_good => 'Tốt';

  @override
  String get product_reviews_filter_medium => 'Trung bình';

  @override
  String get product_reviews_filter_bad => 'Tệ';

  @override
  String get seller_profile_default_title => 'Trang người bán';

  @override
  String get seller_profile_seller => 'Người bán';

  @override
  String get seller_profile_no_description => 'Chưa có mô tả';

  @override
  String seller_profile_followers(int count) {
    return '$count người theo dõi';
  }

  @override
  String get seller_profile_followed => 'Đang theo dõi';

  @override
  String get seller_profile_follow => 'Theo dõi';

  @override
  String get seller_profile_unfollow_success => 'Hủy theo dõi thành công';

  @override
  String get seller_profile_follow_success => 'Theo dõi thành công';

  @override
  String seller_profile_chat_failed(String error) {
    return 'Tạo chat thất bại: $error';
  }

  @override
  String seller_profile_error_occurred(String error) {
    return 'Đã xảy ra lỗi: $error';
  }

  @override
  String get seller_profile_about_merchant => 'Về người bán';

  @override
  String get seller_profile_my_services => 'Dịch vụ của tôi';

  @override
  String get seller_profile_no_merchant_info => 'Chưa có thông tin người bán';

  @override
  String get seller_profile_member_level => 'Cấp độ thành viên';

  @override
  String get seller_profile_level_two => 'Thành viên cấp 2';

  @override
  String get seller_profile_seller_rating => 'Điểm người bán';

  @override
  String get seller_profile_response_time => 'Thời gian phản hồi';

  @override
  String get seller_profile_response_hours => '3 giờ';

  @override
  String get seller_profile_certification_status => 'Trạng thái xác minh';

  @override
  String get seller_profile_certified => 'Đã xác minh';

  @override
  String get seller_profile_not_certified => 'Chưa xác minh';

  @override
  String get seller_profile_no_products => 'Chưa có sản phẩm';

  @override
  String get seller_profile_image_load_failed => 'Tải ảnh thất bại';

  @override
  String get seller_profile_no_image => 'Chưa có ảnh';

  @override
  String get seller_profile_title => 'Cá nhân';

  @override
  String get seller_profile_auth_management => 'Quản lý xác minh';

  @override
  String get seller_profile_my_wallet => 'Ví của tôi';

  @override
  String get seller_profile_time_management => 'Quản lý thời gian';

  @override
  String get seller_profile_settings => 'Cài đặt';

  @override
  String get seller_profile_notifications => 'Thông báo tin nhắn';

  @override
  String get seller_profile_about_us => 'Về chúng tôi';

  @override
  String get seller_profile_mission => 'Sứ mệnh';

  @override
  String get seller_profile_user_name => 'Người dùng';

  @override
  String get seller_profile_seller_mode_online =>
      'Chế độ người bán: Trực tuyến';

  @override
  String get seller_profile_seller_mode => 'Chế độ người bán';

  @override
  String get seller_profile_buyer_mode => 'Chế độ người mua';

  @override
  String get seller_profile_my_orders => 'Đơn hàng của tôi';

  @override
  String get seller_profile_order_pending => 'Chờ xác nhận';

  @override
  String get seller_profile_order_processing => 'Đang xử lý';

  @override
  String get seller_profile_order_delivered => 'Đã giao';

  @override
  String get seller_profile_order_refund => 'Hoàn tiền/Hậu mãi';

  @override
  String seller_profile_feature_not_implemented(String feature) {
    return 'Chức năng $feature chưa được triển khai';
  }

  @override
  String get seller_home_loading_failed => 'Tải thất bại';

  @override
  String get seller_home_no_data => 'Chưa có dữ liệu';

  @override
  String get seller_home_no_store_info => 'Chưa có thông tin cửa hàng';

  @override
  String get seller_home_online => 'Trực tuyến';

  @override
  String get seller_home_offline => 'Ngoại tuyến';

  @override
  String seller_home_completion_rate(String rate) {
    return 'Tỷ lệ hoàn thành $rate%';
  }

  @override
  String get seller_home_switch_to_buyer => 'Chuyển sang chế độ người mua';

  @override
  String seller_home_switch_failed(String error) {
    return 'Không thể chuyển sang chế độ người mua: $error';
  }

  @override
  String get seller_home_income => 'Doanh thu';

  @override
  String get seller_home_view_details => 'Xem chi tiết';

  @override
  String get seller_home_total_income => 'Tổng doanh thu';

  @override
  String get seller_home_today_income => 'Doanh thu hôm nay';

  @override
  String get seller_home_pending_settlement => 'Chờ thanh toán';

  @override
  String get seller_home_orders => 'Đơn hàng';

  @override
  String get seller_home_view_all => 'Xem tất cả';

  @override
  String get seller_home_orders_all => 'Tất cả';

  @override
  String get seller_home_orders_pending => 'Chờ xử lý';

  @override
  String get seller_home_orders_processing => 'Đang xử lý';

  @override
  String get seller_home_orders_aftersales => 'Đang hậu mãi';

  @override
  String get seller_home_orders_awaiting_delivery => 'Chờ giao hàng';

  @override
  String get seller_home_orders_completed => 'Đã hoàn thành';

  @override
  String get seller_home_orders_canceled => 'Đã hủy';

  @override
  String get seller_home_functions => 'Chức năng';

  @override
  String get seller_home_wallet => 'Ví';

  @override
  String get seller_home_auth_management => 'Quản lý xác minh';

  @override
  String get seller_home_time_management => 'Quản lý thời gian';

  @override
  String get seller_home_auto_reply => 'Trả lời tự động';

  @override
  String get seller_home_recent_income => 'Doanh thu gần đây';

  @override
  String get seller_home_no_recent_income =>
      'Chưa có dữ liệu doanh thu gần đây';

  @override
  String get seller_home_no_income_data => 'Chưa có dữ liệu doanh thu';

  @override
  String get seller_statistics_title => 'Thống kê người bán';

  @override
  String get seller_statistics_seller_homepage => 'Trang người bán';

  @override
  String get seller_statistics_heat_value => 'Độ nổi bật';

  @override
  String get seller_statistics_reply_rate => 'Tỷ lệ phản hồi';

  @override
  String get seller_statistics_completion_rate => 'Tỷ lệ hoàn thành';

  @override
  String get seller_statistics_positive_rate => 'Tỷ lệ đánh giá tốt';

  @override
  String get seller_statistics_upgrade_to_next_level =>
      'Nâng lên cấp tiếp theo';

  @override
  String seller_statistics_become_level3_seller(String days) {
    return 'Trở thành người bán cấp 3 trong $days ngày';
  }

  @override
  String seller_statistics_complete_orders(String orderNum) {
    return 'Hoàn thành $orderNum đơn hàng';
  }

  @override
  String seller_statistics_profit_amount(String amount) {
    return 'Lợi nhuận $amount đồng';
  }

  @override
  String get seller_statistics_indicators => 'Chỉ số';

  @override
  String get seller_statistics_total_earnings => 'Tổng lợi nhuận';

  @override
  String get seller_statistics_monthly_earnings => 'Lợi nhuận tháng này';

  @override
  String get seller_statistics_total_orders => 'Tổng số đơn hàng';

  @override
  String get seller_statistics_active_orders => 'Số đơn hàng đang hoạt động';

  @override
  String get seller_statistics_pending => 'Chờ xử lý';

  @override
  String get seller_statistics_incomplete_orders =>
      'Số đơn hàng chưa hoàn thành';

  @override
  String get seller_statistics_pending_completion => 'Chờ hoàn thành';

  @override
  String get seller_statistics_receipt => 'Biên lai';

  @override
  String get seller_statistics_next_delivery_date => 'Ngày giao hàng tiếp theo';

  @override
  String get seller_statistics_earliest => 'Sớm nhất';

  @override
  String seller_statistics_loading_failed(String error) {
    return 'Tải thất bại: $error';
  }

  @override
  String get seller_statistics_retry => 'Thử lại';

  @override
  String get seller_auth_management_title => 'Quản lý xác minh';

  @override
  String get seller_auth_management_certified_items => 'Các mục đã xác minh';

  @override
  String get seller_auth_management_open_certification => 'Mở xác minh';

  @override
  String get seller_auth_management_no_items => 'Chưa có mục xác minh';

  @override
  String get seller_auth_management_unknown_status =>
      'Trạng thái không xác định';

  @override
  String get seller_auth_management_certified => 'Đã xác minh';

  @override
  String get seller_auth_management_pending => 'Đang xét duyệt';

  @override
  String get seller_auth_management_rejected => 'Không đạt';

  @override
  String get seller_auth_management_not_submitted => 'Chưa nộp';

  @override
  String get seller_auth_management_server_timeout =>
      'Máy chủ không phản hồi đúng hạn';

  @override
  String get seller_auth_management_server_timeout_desc =>
      'Máy chủ xử lý yêu cầu quá lâu, vui lòng thử lại sau';

  @override
  String get seller_auth_management_network_error => 'Lỗi kết nối mạng';

  @override
  String get seller_auth_management_network_error_desc =>
      'Không thể kết nối đến máy chủ, vui lòng kiểm tra cài đặt mạng';

  @override
  String get seller_auth_management_loading_failed => 'Tải thất bại';

  @override
  String get seller_auth_management_unknown_error =>
      'Đã xảy ra lỗi không xác định, vui lòng thử lại';

  @override
  String get seller_auth_management_troubleshooting => 'Gợi ý khắc phục sự cố:';

  @override
  String get seller_auth_management_check_network =>
      '• Kiểm tra kết nối mạng có ổn định không';

  @override
  String get seller_auth_management_wait_retry => '• Chờ vài phút rồi thử lại';

  @override
  String get seller_auth_management_contact_support =>
      '• Nếu vấn đề vẫn tiếp diễn, vui lòng liên hệ bộ phận hỗ trợ';

  @override
  String get seller_auth_management_check_wifi =>
      '• Kiểm tra kết nối WiFi hoặc dữ liệu di động';

  @override
  String get seller_auth_management_switch_network =>
      '• Thử chuyển đổi môi trường mạng';

  @override
  String get seller_auth_management_restart_app => '• Đóng và mở lại ứng dụng';

  @override
  String get seller_auth_management_check_connection =>
      '• Kiểm tra trạng thái kết nối mạng';

  @override
  String get seller_auth_management_try_later => '• Thử lại sau';

  @override
  String get seller_auth_management_contact_tech =>
      '• Nếu vấn đề vẫn tiếp diễn, vui lòng liên hệ bộ phận hỗ trợ kỹ thuật';

  @override
  String get seller_auth_management_reload => 'Tải lại';

  @override
  String get seller_auth_management_back => 'Quay lại';

  @override
  String seller_auth_application_title(String type) {
    return 'Xác minh $type';
  }

  @override
  String seller_auth_application_desc(String type) {
    return 'Mô tả xác minh $type';
  }

  @override
  String get seller_auth_application_review_time =>
      'Xét duyệt xác minh thường mất 1-3 ngày làm việc, vui lòng kiên nhẫn chờ đợi.';

  @override
  String get seller_auth_application_basic_info => 'Thông tin cơ bản';

  @override
  String get seller_auth_application_company_name => 'Tên công ty';

  @override
  String get seller_auth_application_company_name_hint =>
      'Vui lòng nhập tên đầy đủ của công ty';

  @override
  String get seller_auth_application_company_name_required =>
      'Vui lòng nhập tên công ty';

  @override
  String get seller_auth_application_credit_code => 'Mã số doanh nghiệp';

  @override
  String get seller_auth_application_credit_code_hint =>
      'Vui lòng nhập mã số doanh nghiệp 18 chữ số';

  @override
  String get seller_auth_application_credit_code_required =>
      'Vui lòng nhập mã số doanh nghiệp';

  @override
  String get seller_auth_application_credit_code_invalid =>
      'Mã số doanh nghiệp phải có 18 chữ số';

  @override
  String get seller_auth_application_company_intro => 'Giới thiệu công ty';

  @override
  String get seller_auth_application_company_intro_hint =>
      'Vui lòng mô tả ngắn gọn về hoạt động và tình hình của công ty';

  @override
  String get seller_auth_application_real_name => 'Họ và tên';

  @override
  String get seller_auth_application_real_name_hint =>
      'Vui lòng nhập tên thật của bạn';

  @override
  String get seller_auth_application_real_name_required =>
      'Vui lòng nhập họ và tên';

  @override
  String get seller_auth_application_id_number => 'Số CMND/CCCD';

  @override
  String get seller_auth_application_id_number_hint =>
      'Vui lòng nhập số CMND/CCCD 18 chữ số';

  @override
  String get seller_auth_application_id_number_required =>
      'Vui lòng nhập số CMND/CCCD';

  @override
  String get seller_auth_application_id_number_invalid =>
      'Số CMND/CCCD phải có 18 chữ số';

  @override
  String get seller_auth_application_school_name => 'Tên trường';

  @override
  String get seller_auth_application_school_name_hint =>
      'Vui lòng nhập tên đầy đủ của trường';

  @override
  String get seller_auth_application_school_name_required =>
      'Vui lòng nhập tên trường';

  @override
  String get seller_auth_application_degree => 'Trình độ học vấn/Bằng cấp';

  @override
  String get seller_auth_application_degree_hint =>
      'Ví dụ: Đại học, Thạc sĩ, v.v.';

  @override
  String get seller_auth_application_degree_required =>
      'Vui lòng nhập trình độ học vấn/bằng cấp';

  @override
  String get seller_auth_application_major => 'Chuyên ngành';

  @override
  String get seller_auth_application_major_hint =>
      'Vui lòng nhập tên chuyên ngành';

  @override
  String get seller_auth_application_profession => 'Nghề nghiệp/Chức vụ';

  @override
  String get seller_auth_application_profession_hint =>
      'Vui lòng nhập nghề nghiệp hoặc chức vụ của bạn';

  @override
  String get seller_auth_application_profession_required =>
      'Vui lòng nhập nghề nghiệp/chức vụ';

  @override
  String get seller_auth_application_cert_number => 'Số chứng chỉ';

  @override
  String get seller_auth_application_cert_number_hint =>
      'Vui lòng nhập số chứng chỉ nghề nghiệp';

  @override
  String get seller_auth_application_work_experience => 'Kinh nghiệm làm việc';

  @override
  String get seller_auth_application_work_experience_hint =>
      'Vui lòng mô tả ngắn gọn kinh nghiệm làm việc của bạn';

  @override
  String get seller_auth_application_auth_name => 'Tên xác minh';

  @override
  String get seller_auth_application_auth_name_hint =>
      'Vui lòng nhập tên xác minh';

  @override
  String get seller_auth_application_auth_name_required =>
      'Vui lòng nhập tên xác minh';

  @override
  String get seller_auth_application_auth_identifier => 'Mã xác minh';

  @override
  String get seller_auth_application_auth_identifier_hint =>
      'Vui lòng nhập mã hoặc số xác minh';

  @override
  String get seller_auth_application_auth_description => 'Mô tả xác minh';

  @override
  String get seller_auth_application_auth_description_hint =>
      'Vui lòng mô tả nội dung xác minh';

  @override
  String get seller_auth_application_upload_materials =>
      'Tải lên tài liệu chứng minh';

  @override
  String get seller_auth_application_upload_file => 'Tải lên tệp';

  @override
  String seller_auth_application_selected_files(int count) {
    return 'Đã chọn $count tệp';
  }

  @override
  String get seller_auth_application_selected_images => 'Ảnh đã chọn:';

  @override
  String get seller_auth_application_load_failed => 'Tải thất bại';

  @override
  String get seller_auth_application_id_upload_hint =>
      'Vui lòng tải lên ảnh rõ nét của cả hai mặt CMND/CCCD, đảm bảo thông tin hiển thị rõ ràng, không bị che khuất hay chỉnh sửa';

  @override
  String get seller_auth_application_education_upload_hint =>
      'Vui lòng tải lên bằng đại học, bằng thạc sĩ và các tài liệu chứng minh học vấn khác có đầy đủ thông tin';

  @override
  String get seller_auth_application_profession_upload_hint =>
      'Vui lòng tải lên chứng chỉ nghề nghiệp, chứng chỉ kỹ năng chuyên môn và các tài liệu chứng minh khác';

  @override
  String get seller_auth_application_company_upload_hint =>
      'Vui lòng tải lên giấy phép kinh doanh, giấy chứng nhận mã số tổ chức và các tài liệu chứng minh tư cách doanh nghiệp khác';

  @override
  String get seller_auth_application_default_upload_hint =>
      'Vui lòng tải lên tài liệu chứng minh liên quan, đảm bảo ảnh rõ nét và thông tin đầy đủ';

  @override
  String get seller_auth_application_agreement_read =>
      'Tôi đã đọc và đồng ý với';

  @override
  String get seller_auth_application_agreement_link =>
      '《Thỏa thuận Dịch vụ Xác minh》';

  @override
  String get seller_auth_application_agreement_guarantee =>
      ', và đảm bảo rằng thông tin cung cấp là trung thực và hợp lệ';

  @override
  String get seller_auth_application_agreement_title =>
      'Thỏa thuận Dịch vụ Xác minh';

  @override
  String get seller_auth_application_agreement_content =>
      'Thỏa thuận này là thỏa thuận pháp lý giữa bạn và nền tảng DSKK về dịch vụ xác minh. Vui lòng đọc kỹ các điều khoản sau để đảm bảo bạn hiểu đầy đủ tất cả các quyền và nghĩa vụ trong thỏa thuận này.\n\nI. Nội dung dịch vụ\nNền tảng DSKK cung cấp dịch vụ xác minh nhằm xác thực tính xác thực của danh tính, bằng cấp và các thông tin khác bạn cung cấp, nâng cao độ tin cậy của bạn trên nền tảng.\n\nII. Nghĩa vụ của người dùng\n1. Bạn phải cung cấp thông tin và tài liệu xác minh trung thực, chính xác và đầy đủ.\n2. Bạn phải đảm bảo rằng các tài liệu xác minh được cung cấp không vi phạm quyền và lợi ích hợp pháp của bất kỳ bên thứ ba nào.\n\nIII. Quyền và nghĩa vụ của nền tảng\n1. Nền tảng có quyền xem xét thông tin và tài liệu xác minh bạn cung cấp.\n2. Nền tảng sẽ hoàn thành xem xét trong thời gian hợp lý và thông báo kết quả xem xét cho bạn.';

  @override
  String get seller_auth_application_agreement_close => 'Đóng';

  @override
  String get seller_auth_application_agreement_agree => 'Đồng ý';

  @override
  String get seller_auth_application_submit => 'Nộp đơn xác minh';

  @override
  String get seller_auth_application_check_form =>
      'Vui lòng kiểm tra xem mẫu đơn đã điền đúng chưa';

  @override
  String get seller_auth_application_submit_success => 'Nộp thành công';

  @override
  String get seller_auth_application_submit_success_desc =>
      'Đơn xác minh của bạn đã được nộp, chúng tôi sẽ hoàn thành xét duyệt trong 1-3 ngày làm việc, vui lòng kiên nhẫn chờ đợi.';

  @override
  String get seller_auth_application_ok => 'Xác nhận';

  @override
  String seller_auth_application_select_file_failed(String error) {
    return 'Chọn tệp thất bại: $error';
  }

  @override
  String get product_management_title => 'Quản lý sản phẩm';

  @override
  String get product_management_tab_on_sale => 'Đang bán';

  @override
  String get product_management_tab_draft => 'Bản nháp';

  @override
  String get product_management_tab_off_shelf => 'Đã gỡ';

  @override
  String get product_management_action_off_shelf => 'Gỡ xuống';

  @override
  String get product_management_action_on_shelf => 'Đăng bán';

  @override
  String get product_management_action_edit => 'Chỉnh sửa';

  @override
  String get product_management_action_delete => 'Xóa';

  @override
  String get product_management_action_publish => 'Đăng';

  @override
  String get product_management_action_resubmit => 'Nộp lại';

  @override
  String get product_management_status_reviewing => 'Đang xét duyệt';

  @override
  String get product_management_status_rejected => 'Xét duyệt thất bại';

  @override
  String get product_management_status_on_shelf => 'Đang bán';

  @override
  String get product_management_status_off_shelf => 'Đã gỡ';

  @override
  String get product_management_status_draft => 'Bản nháp';

  @override
  String get product_management_status_waiting_review => 'Chờ xét duyệt';

  @override
  String get product_management_status_unknown => 'Không xác định';

  @override
  String get product_management_stock_label => 'Kho';

  @override
  String get product_management_sales_label => 'Doanh số';

  @override
  String get product_management_create_product => 'Tạo sản phẩm';

  @override
  String get product_management_no_more_products => 'Không còn sản phẩm nào';

  @override
  String get product_management_empty_on_sale => 'Chưa có sản phẩm đang bán';

  @override
  String get product_management_empty_draft => 'Chưa có bản nháp';

  @override
  String get product_management_empty_off_shelf => 'Chưa có sản phẩm đã gỡ';

  @override
  String get product_management_empty_default => 'Chưa có dữ liệu sản phẩm';

  @override
  String get product_management_draft_preview_hint =>
      'Sản phẩm ở trạng thái nháp cần được đăng trước khi xem trước';

  @override
  String get product_management_confirm_off_shelf_title => 'Xác nhận gỡ xuống';

  @override
  String product_management_confirm_off_shelf_message(String name) {
    return 'Bạn có chắc muốn gỡ sản phẩm \"$name\" không?';
  }

  @override
  String get product_management_confirm_off_shelf_desc => 'Sau khi gỡ xuống:';

  @override
  String get product_management_confirm_off_shelf_point1 =>
      '• Người mua sẽ không thể xem và mua sản phẩm này';

  @override
  String get product_management_confirm_off_shelf_point2 =>
      '• Bạn có thể đăng bán lại bất cứ lúc nào';

  @override
  String get product_management_confirm_off_shelf_point3 =>
      '• Dữ liệu sản phẩm sẽ được giữ lại';

  @override
  String get product_management_confirm_delete_title => 'Xác nhận xóa';

  @override
  String get product_management_confirm_delete_message =>
      'Bạn có chắc muốn xóa sản phẩm này không? Hành động này không thể hoàn tác.';

  @override
  String get product_management_cancel => 'Hủy';

  @override
  String get product_management_confirm => 'Xác nhận gỡ xuống';

  @override
  String get product_management_delete => 'Xóa';

  @override
  String get product_edit_title_create => 'Tạo sản phẩm';

  @override
  String get product_edit_title_edit => 'Chỉnh sửa sản phẩm';

  @override
  String get product_edit_basic_info => 'Thông tin cơ bản';

  @override
  String get product_edit_product_name => 'Tên sản phẩm';

  @override
  String get product_edit_product_name_hint => 'Vui lòng nhập tên sản phẩm';

  @override
  String get product_edit_product_description => 'Mô tả sản phẩm';

  @override
  String get product_edit_product_description_hint =>
      'Vui lòng nhập mô tả sản phẩm';

  @override
  String get product_edit_product_price => 'Giá sản phẩm';

  @override
  String get product_edit_product_images => 'Ảnh sản phẩm';

  @override
  String get product_edit_add_image => 'Thêm ảnh';

  @override
  String get product_edit_uploading => 'Đang tải lên...';

  @override
  String get product_edit_service_tiers => 'Cài đặt gói dịch vụ';

  @override
  String get product_edit_detail_intro => 'Giới thiệu chi tiết';

  @override
  String get product_edit_save_draft => 'Lưu bản nháp';

  @override
  String get product_edit_publish_product => 'Đăng sản phẩm';

  @override
  String get product_edit_preview_product => 'Xem trước sản phẩm';

  @override
  String get product_edit_at_least_one_image =>
      'Vui lòng tải lên ít nhất một ảnh sản phẩm';

  @override
  String get product_edit_save_draft_dialog_title => 'Lưu bản nháp';

  @override
  String get product_edit_save_draft_dialog_message =>
      'Bạn có muốn lưu làm bản nháp không?';

  @override
  String get product_edit_save_draft_dialog_confirm => 'Lưu';

  @override
  String get product_edit_edit_attribute => 'Chỉnh sửa thuộc tính sản phẩm';

  @override
  String get product_edit_validation_name_required =>
      'Vui lòng nhập tên sản phẩm';

  @override
  String get product_edit_validation_description_required =>
      'Vui lòng nhập mô tả sản phẩm';

  @override
  String get product_edit_validation_image_required =>
      'Vui lòng tải lên ít nhất một ảnh sản phẩm';

  @override
  String get product_preview_current_seller => 'Người bán hiện tại';

  @override
  String get product_preview_seller_user => 'Người bán';

  @override
  String get product_edit_success_cases => 'Các trường hợp thành công';

  @override
  String get product_edit_add_success_case => 'Thêm trường hợp thành công';

  @override
  String get product_edit_edit_success_case =>
      'Chỉnh sửa trường hợp thành công';

  @override
  String product_edit_uploading_progress(int uploaded, int total) {
    return 'Đang tải lên $uploaded/$total';
  }

  @override
  String get product_edit_please_enter_label => 'Vui lòng nhập nhãn thông tin';

  @override
  String get product_edit_please_enter_attribute_name =>
      'Vui lòng nhập tên thuộc tính';

  @override
  String get product_edit_attribute_name_hint => 'Vui lòng nhập tên thuộc tính';

  @override
  String get product_edit_placeholder_hint =>
      'Ví dụ: Vui lòng chọn màu, Vui lòng nhập kiểu dáng';

  @override
  String get product_edit_placeholder_label => 'Văn bản gợi ý';

  @override
  String get product_edit_product_preview_title => 'Xem trước sản phẩm';

  @override
  String get product_edit_publish_service => 'Đăng dịch vụ';

  @override
  String get product_edit_edit_service => 'Chỉnh sửa dịch vụ';

  @override
  String product_edit_max_characters(int max) {
    return 'Tối đa $max ký tự';
  }

  @override
  String get after_sales_review_title => 'Xét duyệt hậu mãi';

  @override
  String get after_sales_detail_title => 'Chi tiết hậu mãi';

  @override
  String get after_sales_refresh => 'Làm mới';

  @override
  String get after_sales_no_pending => 'Chưa có đơn hậu mãi chờ xét duyệt';

  @override
  String get after_sales_load_failed => 'Tải thất bại, vui lòng thử lại';

  @override
  String get after_sales_not_found => 'Không tìm thấy đơn hậu mãi';

  @override
  String get after_sales_order_number => 'Mã đơn hàng';

  @override
  String get after_sales_apply_type => 'Loại yêu cầu';

  @override
  String get after_sales_apply_time => 'Thời gian yêu cầu';

  @override
  String get after_sales_refund_amount => 'Số tiền hoàn';

  @override
  String get after_sales_refund_type => 'Loại hoàn tiền';

  @override
  String get after_sales_apply_reason => 'Lý do yêu cầu';

  @override
  String get after_sales_image_evidence => 'Bằng chứng hình ảnh';

  @override
  String get after_sales_image_view => 'Xem ảnh';

  @override
  String get after_sales_image_load_failed => 'Tải ảnh thất bại';

  @override
  String get after_sales_reject => 'Từ chối';

  @override
  String get after_sales_agree => 'Đồng ý';

  @override
  String get after_sales_reject_application => 'Từ chối yêu cầu';

  @override
  String get after_sales_agree_application => 'Đồng ý yêu cầu';

  @override
  String get after_sales_confirm => 'Xác nhận';

  @override
  String get after_sales_cancel => 'Hủy';

  @override
  String get after_sales_confirm_title => 'Xác nhận';

  @override
  String get after_sales_confirm_message =>
      'Bạn có chắc muốn đồng ý yêu cầu hậu mãi này không?';

  @override
  String get after_sales_reject_reason => 'Lý do từ chối';

  @override
  String get after_sales_reject_reason_hint => 'Vui lòng nhập lý do từ chối';

  @override
  String get after_sales_reject_reason_required =>
      'Vui lòng nhập lý do từ chối';

  @override
  String get after_sales_type_refund_only => 'Chỉ hoàn tiền';

  @override
  String get after_sales_type_refund_return => 'Trả hàng và hoàn tiền';

  @override
  String get after_sales_type_unknown => 'Loại không xác định';

  @override
  String get after_sales_status_wait_audit => 'Chờ xét duyệt';

  @override
  String get after_sales_status_refused => 'Đã từ chối';

  @override
  String get after_sales_status_audit_pass => 'Đã duyệt';

  @override
  String get after_sales_status_buyer_shipped => 'Người mua đã gửi hàng';

  @override
  String get after_sales_status_seller_received => 'Người bán đã nhận hàng';

  @override
  String get after_sales_status_finished => 'Đã hoàn thành';

  @override
  String get after_sales_status_canceled => 'Đã hủy';

  @override
  String get after_sales_status_unknown => 'Trạng thái không xác định';

  @override
  String get time_management_title => 'Quản lý thời gian';

  @override
  String get time_management_current_status => 'Trạng thái hiện tại';

  @override
  String get time_management_online => 'Trực tuyến';

  @override
  String get time_management_offline => 'Ngoại tuyến';

  @override
  String get time_management_online_status_description =>
      'Mô tả trạng thái trực tuyến';

  @override
  String get time_management_offline_status_description =>
      'Mô tả trạng thái ngoại tuyến';

  @override
  String get time_management_online_description =>
      'Bạn đang trực tuyến, người mua có thể gửi tin nhắn cho bạn và bạn sẽ nhận được thông báo khi có tin nhắn mới. Hãy đảm bảo phản hồi kịp thời tin nhắn của người mua, duy trì tỷ lệ phản hồi tốt sẽ giúp nâng cao điểm chất lượng dịch vụ của bạn.';

  @override
  String get time_management_offline_description =>
      'Bạn đang ngoại tuyến, người mua vẫn có thể gửi tin nhắn cho bạn nhưng hệ thống sẽ thông báo với người mua rằng bạn tạm thời không có mặt. Bạn vẫn sẽ nhận được thông báo khi có tin nhắn mới nhưng có thể không thể phản hồi ngay. Duy trì trạng thái ngoại tuyến quá lâu có thể ảnh hưởng đến hiệu quả nhận đơn của bạn.';

  @override
  String get time_management_save_settings => 'Lưu cài đặt';

  @override
  String get time_management_settings_saved => 'Đã lưu cài đặt';

  @override
  String get time_management_load_failed => 'Tải thất bại';

  @override
  String get time_management_retry => 'Thử lại';

  @override
  String get time_management_unknown_status => 'Trạng thái không xác định';

  @override
  String get auto_reply_title => 'Cài đặt trả lời tự động';

  @override
  String get auto_reply_enable => 'Trả lời tự động';

  @override
  String get auto_reply_content => 'Nội dung trả lời';

  @override
  String get auto_reply_content_hint =>
      'Vui lòng nhập nội dung trả lời tự động';

  @override
  String get auto_reply_content_description =>
      'Khi khách hàng gửi tin nhắn, hệ thống sẽ tự động trả lời bằng nội dung này';

  @override
  String get auto_reply_save_settings => 'Lưu cài đặt';

  @override
  String get auto_reply_settings_saved => 'Đã lưu cài đặt';

  @override
  String get auto_reply_content_required =>
      'Nội dung trả lời không được để trống';

  @override
  String get auto_reply_load_failed => 'Tải thất bại, vui lòng thử lại';

  @override
  String get order_delivery_title => 'Giao hàng đơn hàng';

  @override
  String order_delivery_title_with_sn(String orderSn) {
    return 'Giao hàng đơn hàng: $orderSn';
  }

  @override
  String get order_delivery_submitting => 'Đang nộp nội dung giao hàng...';

  @override
  String get order_delivery_load_failed => 'Tải thất bại, vui lòng thử lại';

  @override
  String get order_delivery_instruction_title => 'Hướng dẫn giao hàng';

  @override
  String get order_delivery_instruction_content =>
      'Vui lòng nộp nội dung giao hàng của bạn cho đơn hàng này. Bạn có thể cung cấp mô tả chi tiết và đính kèm các tệp liên quan để đảm bảo người mua hiểu rõ dịch vụ hoặc sản phẩm bạn cung cấp.';

  @override
  String get order_delivery_content_label => 'Mô tả nội dung giao hàng:';

  @override
  String get order_delivery_content_hint =>
      'Vui lòng mô tả nội dung giao hàng của bạn...';

  @override
  String get order_delivery_attachments_label => 'Tệp đính kèm:';

  @override
  String get order_delivery_submit_button => 'Nộp giao hàng';

  @override
  String get order_delivery_content_required =>
      'Vui lòng nhập mô tả nội dung giao hàng';

  @override
  String get order_delivery_submit_success =>
      'Nộp nội dung giao hàng thành công';

  @override
  String get order_delivery_logistics_company => 'Công ty vận chuyển';

  @override
  String get order_delivery_tracking_number => 'Mã vận đơn';

  @override
  String get order_delivery_shipping_address => 'Địa chỉ gửi hàng';

  @override
  String get order_delivery_receiving_address => 'Địa chỉ nhận hàng';

  @override
  String get order_delivery_status_pending => 'Chờ giao hàng';

  @override
  String get order_delivery_status_shipped => 'Đã giao';

  @override
  String get order_delivery_status_received => 'Đã nhận';

  @override
  String get order_delivery_status_in_transit => 'Đang vận chuyển';

  @override
  String get order_delivery_confirm_shipment => 'Xác nhận giao hàng';

  @override
  String get order_delivery_view_details => 'Xem chi tiết';

  @override
  String get order_delivery_no_pending_orders => 'Chưa có đơn hàng chờ giao';

  @override
  String get notification_center_title => 'Trung tâm thông báo';

  @override
  String get notification_tab_all => 'Tất cả';

  @override
  String get notification_tab_order => 'Đơn hàng';

  @override
  String get notification_tab_system => 'Hệ thống';

  @override
  String get notification_tab_refund => 'Hậu mãi';

  @override
  String get notification_tab_message => 'Tin nhắn';

  @override
  String get notification_type_order => 'Thông báo đơn hàng';

  @override
  String get notification_type_system => 'Thông báo hệ thống';

  @override
  String get notification_type_refund => 'Thông báo hậu mãi';

  @override
  String get notification_type_message => 'Thông báo tin nhắn';

  @override
  String get notification_type_review => 'Thông báo đánh giá';

  @override
  String get notification_type_authentication => 'Thông báo xác minh';

  @override
  String get notification_type_other => 'Thông báo khác';

  @override
  String get notification_status_unread => 'Chưa đọc';

  @override
  String get notification_status_read => 'Đã đọc';

  @override
  String get notification_mark_all_read => 'Đánh dấu tất cả đã đọc';

  @override
  String get notification_empty_all => 'Chưa có thông báo';

  @override
  String get notification_empty_order => 'Chưa có thông báo đơn hàng';

  @override
  String get notification_empty_system => 'Chưa có thông báo hệ thống';

  @override
  String get notification_empty_refund => 'Chưa có thông báo hậu mãi';

  @override
  String get notification_empty_message => 'Chưa có thông báo tin nhắn';

  @override
  String get notification_empty_review => 'Chưa có thông báo đánh giá';

  @override
  String get notification_empty_authentication => 'Chưa có thông báo xác minh';

  @override
  String get notification_empty_other => 'Chưa có thông báo khác';

  @override
  String get notification_empty_generic => 'Chưa có thông báo';

  @override
  String get notification_refresh => 'Làm mới';

  @override
  String get notification_retry => 'Thử lại';

  @override
  String notification_load_failed(String error) {
    return 'Tải trung tâm thông báo thất bại: $error';
  }

  @override
  String get notification_detail_title => 'Chi tiết thông báo';

  @override
  String get notification_detail_view => 'Xem chi tiết';

  @override
  String get notification_detail_close => 'Đóng';

  @override
  String get notification_click_to_view => 'Nhấn để xem chi tiết';

  @override
  String get notification_default_title => 'Thông báo';

  @override
  String get notification_time_just_now => 'Vừa xong';

  @override
  String notification_time_minutes_ago(int minutes) {
    return '$minutes phút trước';
  }

  @override
  String notification_time_hours_ago(int hours) {
    return '$hours giờ trước';
  }

  @override
  String notification_time_days_ago(int days) {
    return '$days ngày trước';
  }

  @override
  String notification_time_months_ago(int months) {
    return '$months tháng trước';
  }

  @override
  String get materialsInfo => 'Thông tin tài liệu';

  @override
  String get buyerSubmittedMaterials => 'Tài liệu người mua đã nộp';

  @override
  String get sellerDeliveryContent => 'Nội dung giao hàng của người bán';

  @override
  String get noBuyerMaterials => 'Chưa có tài liệu nào từ người mua';

  @override
  String get noSellerDelivery => 'Người bán chưa giao hàng';

  @override
  String get attachments => 'Tệp đính kèm:';

  @override
  String get deliveryFiles => 'Tệp giao hàng:';

  @override
  String get deliveryDescription => 'Mô tả giao hàng';

  @override
  String get tapToPreview => 'Nhấn để xem trước';

  @override
  String get tapToOpen => 'Nhấn để mở';

  @override
  String get downloadFile => 'Tải tệp xuống';

  @override
  String get storagePermissionDenied => 'Quyền truy cập bộ nhớ bị từ chối';

  @override
  String get cancelDownload => 'Hủy tải xuống';

  @override
  String get pageLoadFailed => 'Tải trang thất bại';

  @override
  String get openFile => 'Mở tệp';

  @override
  String get downloaded => 'Đã tải xuống';

  @override
  String get downloadCompleted => 'Tải xuống hoàn thành';

  @override
  String get downloadFailed => 'Tải xuống thất bại';

  @override
  String get openFileFailed => 'Mở tệp thất bại';

  @override
  String get storagePermissionRequired =>
      'Cần quyền truy cập bộ nhớ để tải tệp xuống';

  @override
  String get pdfLoadFailed => 'Tải PDF thất bại';

  @override
  String get retry => 'Thử lại';

  @override
  String product_detail_translated_from(String language) {
    return 'Dịch từ $language';
  }

  @override
  String get product_detail_translation_auto => 'Bản dịch tự động';

  @override
  String get product_detail_show_original => 'Hiện bản gốc';

  @override
  String get order_status_awaiting_payment => 'Chờ thanh toán';

  @override
  String get order_status_awaiting_submission => 'Chờ nộp';

  @override
  String get order_status_buy_awaiting_submission => 'Cần nộp lại';

  @override
  String get order_status_awaiting_start => 'Chờ tiếp nhận';

  @override
  String get order_status_awaiting_delivery => 'Chờ giao hàng';

  @override
  String get order_status_awaiting_confirmation => 'Chờ xác nhận';

  @override
  String get order_status_awaiting_evaluation => 'Chờ đánh giá';

  @override
  String get order_status_completed => 'Đã hoàn thành';

  @override
  String get order_status_canceled => 'Đã hủy';

  @override
  String get order_status_after_sale => 'Hậu mãi';

  @override
  String get order_status_unknown => 'Trạng thái không xác định';

  @override
  String get order_action_cancel => 'Hủy đơn hàng';

  @override
  String get order_action_go_pay => 'Thanh toán ngay';

  @override
  String get order_action_submit_materials => 'Nộp tài liệu';

  @override
  String get order_action_contact_support => 'Liên hệ hỗ trợ';

  @override
  String get order_action_view_feedback => 'Xem phản hồi';

  @override
  String get order_action_remind_delivery => 'Nhắc giao hàng';

  @override
  String get order_action_platform_intervention => 'Yêu cầu nền tảng can thiệp';

  @override
  String get order_action_view_delivery => 'Xem giao hàng';

  @override
  String get order_action_apply_after_sale => 'Yêu cầu hậu mãi';

  @override
  String get order_action_confirm_receipt => 'Xác nhận nhận hàng';

  @override
  String get order_action_view_logistics => 'Xem vận chuyển';

  @override
  String get order_action_go_evaluate => 'Viết đánh giá';

  @override
  String get order_action_apply_rework => 'Yêu cầu làm lại';

  @override
  String get order_action_delete_order => 'Xóa đơn hàng';

  @override
  String get order_action_view_order => 'Xem đơn hàng';

  @override
  String get order_action_view_details => 'Xem chi tiết';

  @override
  String get order_action_processing => 'Đang xử lý...';

  @override
  String get order_confirm_cancel_title => 'Hủy đơn hàng';

  @override
  String get order_confirm_cancel_content =>
      'Bạn có chắc muốn hủy đơn hàng này không?';

  @override
  String get order_confirm_receipt_title => 'Xác nhận nhận hàng';

  @override
  String get order_confirm_receipt_content =>
      'Bạn có chắc đã nhận được hàng và muốn xác nhận nhận hàng không?';

  @override
  String get order_confirm_delete_title => 'Xóa đơn hàng';

  @override
  String get order_confirm_delete_content =>
      'Bạn có chắc muốn xóa đơn hàng này không? Hành động này không thể hoàn tác.';

  @override
  String get order_dialog_cancel => 'Hủy';

  @override
  String get order_dialog_confirm => 'Xác nhận';

  @override
  String get order_dialog_close => 'Đóng';

  @override
  String get order_dialog_submit => 'Gửi yêu cầu';

  @override
  String get order_snackbar_connecting_support => 'Đang kết nối hỗ trợ...';

  @override
  String get order_snackbar_feedback_in_progress =>
      'Tính năng xem phản hồi người bán đang phát triển';

  @override
  String get order_snackbar_reminded_delivery => 'Đã nhắc người bán giao hàng';

  @override
  String order_snackbar_nav_failed(String error) {
    return 'Điều hướng thất bại: $error';
  }

  @override
  String get order_snackbar_no_items_after_sale =>
      'Lỗi: Không thể yêu cầu hậu mãi cho đơn hàng không có sản phẩm';

  @override
  String get order_snackbar_no_items_evaluate =>
      'Lỗi: Không thể đánh giá đơn hàng không có sản phẩm';

  @override
  String order_snackbar_operation_failed(String error) {
    return 'Thao tác thất bại: $error';
  }

  @override
  String get order_dialog_data_not_loaded =>
      'Dữ liệu chưa tải xong, vui lòng thử lại sau';

  @override
  String get order_dialog_view_delivery_title => 'Xem giao hàng';

  @override
  String get order_dialog_seller_delivery_content =>
      'Nội dung giao hàng của người bán:';

  @override
  String get order_dialog_buyer_materials => 'Tài liệu người mua đã nộp:';

  @override
  String get order_dialog_no_seller_delivery => 'Người bán chưa giao nội dung';

  @override
  String get order_dialog_no_buyer_materials =>
      'Người mua chưa nộp tài liệu nào';

  @override
  String order_dialog_delivery_note(String content) {
    return 'Ghi chú giao hàng: $content';
  }

  @override
  String get order_dialog_delivery_files => 'Tệp giao hàng:';

  @override
  String get order_intervention_title => 'Yêu cầu nền tảng can thiệp';

  @override
  String get order_intervention_desc =>
      'Có tranh chấp chưa giải quyết được? Hỗ trợ nền tảng sẽ can thiệp trong vòng 24 giờ.';

  @override
  String get order_intervention_problem_type => 'Loại vấn đề:';

  @override
  String get order_intervention_problem_desc => 'Mô tả vấn đề:';

  @override
  String get order_intervention_problem_hint =>
      'Vui lòng mô tả chi tiết vấn đề bạn gặp phải...';

  @override
  String get order_intervention_validation_empty =>
      'Vui lòng nhập mô tả vấn đề';

  @override
  String get order_intervention_validation_min =>
      'Mô tả vấn đề phải có ít nhất 10 ký tự';

  @override
  String get order_intervention_tip =>
      'Lưu ý: Sau khi gửi không thể thu hồi. Mỗi đơn hàng tối đa 2 lần yêu cầu.';

  @override
  String get order_intervention_reason_communication => 'Vấn đề giao tiếp';

  @override
  String get order_intervention_reason_quality => 'Tranh chấp chất lượng';

  @override
  String get order_intervention_reason_delivery => 'Vấn đề giao hàng';

  @override
  String get order_intervention_reason_refund => 'Tranh chấp hoàn tiền';

  @override
  String get order_intervention_reason_service => 'Thái độ dịch vụ';

  @override
  String get order_intervention_reason_other => 'Vấn đề khác';

  @override
  String get order_intervention_submitting => 'Đang gửi yêu cầu...';

  @override
  String order_intervention_failed(String error) {
    return 'Yêu cầu thất bại: $error';
  }

  @override
  String get order_demand_replenishment_title => 'Yêu cầu bổ sung tài liệu';

  @override
  String get order_demand_reform_title => 'Yêu cầu làm lại';

  @override
  String get order_demand_replenishment_desc =>
      'Nếu bạn cần người bán cung cấp thêm tài liệu hoặc giải thích, vui lòng mô tả chi tiết nhu cầu của bạn.';

  @override
  String get order_demand_reform_desc =>
      'Nếu không hài lòng với kết quả giao hàng, bạn có thể yêu cầu làm lại. Vui lòng mô tả vấn đề cụ thể.';

  @override
  String get order_demand_detail_label => 'Chi tiết:';

  @override
  String get order_demand_replenishment_hint =>
      'Vui lòng mô tả tài liệu hoặc thông tin cần bổ sung...';

  @override
  String get order_demand_reform_hint =>
      'Vui lòng mô tả chi tiết lý do và yêu cầu làm lại...';

  @override
  String get order_demand_validation_empty => 'Vui lòng nhập mô tả chi tiết';

  @override
  String get order_demand_validation_min => 'Mô tả phải có ít nhất 10 ký tự';

  @override
  String get order_demand_replenishment_tip =>
      'Lưu ý: Người bán sẽ phản hồi và cung cấp tài liệu bổ sung trong vòng 24 giờ.';

  @override
  String get order_demand_reform_tip =>
      'Lưu ý: Sau khi yêu cầu làm lại được gửi, người bán sẽ xử lý lại đơn hàng của bạn.';

  @override
  String get order_demand_reason_incomplete => 'Thông tin chưa đầy đủ';

  @override
  String get order_demand_reason_unclear => 'Yêu cầu chưa rõ ràng';

  @override
  String get order_demand_reason_additional => 'Cần bổ sung giải thích';

  @override
  String get order_demand_reason_reference => 'Cần tài liệu tham khảo';

  @override
  String get order_demand_reason_other => 'Lý do khác';

  @override
  String get order_demand_reason_quality => 'Chất lượng chưa đạt yêu cầu';

  @override
  String get order_demand_reason_requirement => 'Không đáp ứng yêu cầu';

  @override
  String get order_demand_reason_content_incomplete => 'Nội dung chưa đầy đủ';

  @override
  String get order_demand_reason_error => 'Có lỗi sai';

  @override
  String get order_demand_submitting_replenishment =>
      'Đang gửi yêu cầu bổ sung tài liệu...';

  @override
  String get order_demand_submitting_reform => 'Đang gửi yêu cầu làm lại...';

  @override
  String order_demand_failed(String error) {
    return 'Yêu cầu thất bại: $error';
  }

  @override
  String order_demand_edit_info_auto(int current, int remaining) {
    return 'Đã giao $current lần, còn $remaining lượt sửa miễn phí (tự động duyệt)';
  }

  @override
  String order_demand_edit_info_approval(int current) {
    return 'Đã giao $current lần, đã dùng hết lượt sửa miễn phí, cần người bán phê duyệt';
  }

  @override
  String get order_info_title => 'Thông tin đơn hàng';

  @override
  String get order_info_order_number => 'Mã đơn hàng: ';

  @override
  String get order_info_order_time => 'Thời gian đặt hàng: ';

  @override
  String get order_info_pay_time => 'Thời gian thanh toán: ';

  @override
  String get order_info_complete_time => 'Thời gian hoàn thành: ';

  @override
  String get order_info_remark => 'Ghi chú đơn hàng: ';

  @override
  String get order_items_title => 'Thông tin sản phẩm';

  @override
  String get order_items_empty => 'Chưa có thông tin sản phẩm';

  @override
  String order_items_count(int count) {
    return '$count sản phẩm';
  }

  @override
  String get order_price_title => 'Chi tiết giá';

  @override
  String get order_price_total => 'Tổng giá sản phẩm';

  @override
  String get order_price_shipping => 'Phí vận chuyển';

  @override
  String get order_price_discount => 'Giảm giá';

  @override
  String get order_price_paid => 'Số tiền đã thanh toán';

  @override
  String get order_price_total_amount => 'Tổng giá sản phẩm';

  @override
  String get order_price_actual_paid => 'Số tiền đã thanh toán';

  @override
  String get order_requirement_title => 'Gửi yêu cầu';

  @override
  String order_requirement_service_selected(String skuName, String price) {
    return 'Dịch vụ đã chọn: $skuName - ¥$price';
  }

  @override
  String get order_requirement_q1 =>
      '1. Vui lòng mô tả chi tiết yêu cầu của bạn';

  @override
  String get order_requirement_q1_hint =>
      'Vui lòng mô tả chi tiết yêu cầu của bạn, bao gồm nhu cầu cụ thể và kết quả mong đợi';

  @override
  String get order_requirement_q1_helper =>
      'Nếu cần cung cấp tài liệu tham khảo, tải lên trong phần đính kèm bên dưới';

  @override
  String get order_requirement_q2 => '2. Ghi chú bổ sung (tuỳ chọn)';

  @override
  String get order_requirement_q2_hint =>
      'Nếu có ghi chú khác hoặc yêu cầu đặc biệt, vui lòng điền vào đây';

  @override
  String get order_requirement_warning =>
      'Vui lòng điền kỹ yêu cầu. Sau khi gửi, người bán sẽ bắt đầu dịch vụ dựa trên yêu cầu của bạn';

  @override
  String get order_requirement_attachment_title => 'Tải lên tệp đính kèm';

  @override
  String order_requirement_attachment_limit(int maxCount, int maxSize) {
    return 'Tối đa $maxCount tệp, mỗi tệp không quá ${maxSize}MB';
  }

  @override
  String get order_requirement_add => 'Thêm';

  @override
  String get order_requirement_click_select_file => 'Nhấn tại đây để chọn tệp';

  @override
  String get order_requirement_confirm_submit => 'Xác nhận gửi';

  @override
  String get order_requirement_wait_upload =>
      'Vui lòng chờ tệp tải lên hoàn thành';

  @override
  String get order_requirement_upload_failed_title => 'Tải lên tệp thất bại';

  @override
  String order_requirement_upload_failed_count(int count) {
    return '$count tệp tải lên thất bại. Thử lại?';
  }

  @override
  String get order_requirement_remove_failed => 'Xóa tệp thất bại';

  @override
  String get order_requirement_retry_upload => 'Thử lại tải lên';

  @override
  String get order_requirement_error_product_id =>
      'Lỗi: Không thể lấy ID sản phẩm';

  @override
  String get order_requirement_load_draft_failed => 'Tải bản nháp thất bại';

  @override
  String get order_requirement_save_draft_failed => 'Lưu bản nháp thất bại';

  @override
  String order_requirement_max_files(int count) {
    return 'Chỉ được tải lên tối đa $count tệp đính kèm';
  }

  @override
  String order_requirement_pick_failed(String error) {
    return 'Chọn tệp thất bại: $error';
  }

  @override
  String get order_requirement_default_service => 'Dịch vụ cơ bản';

  @override
  String get order_evaluation_title => 'Đánh giá sản phẩm';

  @override
  String get order_evaluation_hint => 'Hãy chia sẻ trải nghiệm của bạn~';

  @override
  String get order_evaluation_add_images => 'Thêm ảnh (tối đa 9)';

  @override
  String get order_evaluation_anonymous => 'Đánh giá ẩn danh';

  @override
  String get order_evaluation_submit => 'Gửi đánh giá';

  @override
  String get order_evaluation_error_no_item =>
      'Lỗi: Không tìm thấy sản phẩm cần đánh giá';

  @override
  String get order_evaluation_max_images => 'Chỉ được tải lên tối đa 9 ảnh';

  @override
  String order_evaluation_success_count(int count, String ratio) {
    return 'Đã xử lý thành công $count ảnh, nén trung bình $ratio%';
  }

  @override
  String order_evaluation_failed_count(int count) {
    return '$count ảnh xử lý thất bại';
  }

  @override
  String order_evaluation_pick_failed(String error) {
    return 'Chọn ảnh thất bại: $error';
  }

  @override
  String get order_evaluation_processing => 'Đang xử lý...';

  @override
  String get order_evaluation_page_title => 'Viết đánh giá';

  @override
  String get order_delivery_not_satisfied => 'Không hài lòng với giao hàng?';

  @override
  String get order_delivery_communicate_tip =>
      'Khi số lần giao hàng không đủ, vui lòng trao đổi với người bán về việc giao thêm';

  @override
  String get order_delivery_supplement => 'Yêu cầu bổ sung';

  @override
  String get order_delivery_remake => 'Yêu cầu làm lại';

  @override
  String get order_delivery_refund => 'Yêu cầu hoàn tiền';

  @override
  String get order_delivery_unknown_file => 'Tệp không xác định';

  @override
  String order_item_delivery_days(int days) {
    return 'Giao hàng: $days ngày';
  }

  @override
  String order_item_edit_count(int count) {
    return 'Số lần sửa: $count lần';
  }

  @override
  String get order_countdown_expired => 'Đã hết hạn';

  @override
  String order_countdown_days_hours(int days, int hours) {
    return '${days}n ${hours}g';
  }

  @override
  String order_countdown_hours_minutes(int hours, int minutes) {
    return '${hours}g ${minutes}p';
  }

  @override
  String order_countdown_minutes(int minutes) {
    return '${minutes}p';
  }

  @override
  String order_countdown_seconds(int seconds) {
    return '${seconds}g';
  }

  @override
  String order_countdown_days(int days) {
    return '${days}n';
  }

  @override
  String order_countdown_minutes_seconds(int minutes, int seconds) {
    return '${minutes}p ${seconds}g';
  }

  @override
  String order_upload_progress(int percent) {
    return 'Đang tải lên $percent%';
  }

  @override
  String get order_upload_retry => 'Thử lại tải lên';

  @override
  String order_upload_failed(String error) {
    return 'Tải lên thất bại: $error';
  }

  @override
  String order_upload_size_limit(String size) {
    return 'Kích thước tệp vượt giới hạn (tối đa $size)';
  }

  @override
  String order_upload_max_retry(int count) {
    return 'Đã đạt số lần thử tối đa ($count lần)';
  }

  @override
  String get order_after_sale_processing => 'Đang xử lý hậu mãi';

  @override
  String get order_after_sale_processing_msg =>
      'Yêu cầu hậu mãi của bạn đang được xử lý, người bán sẽ xử lý trong xx giờ. Vui lòng kiên nhẫn chờ.';

  @override
  String get order_after_sale_mediation => 'Nền tảng đang can thiệp xử lý';

  @override
  String get order_after_sale_mediation_msg =>
      'Hỗ trợ nền tảng đã can thiệp, sẽ đưa ra kết quả xử lý trong xx ngày làm việc. Vui lòng chú ý thông báo.';

  @override
  String get order_after_sale_rejected => 'Yêu cầu hậu mãi đã bị từ chối';

  @override
  String get order_after_sale_rejected_msg =>
      'Xin lỗi, yêu cầu hậu mãi của bạn không được chấp thuận.';

  @override
  String get order_after_sale_default_title => 'Trạng thái hậu mãi';

  @override
  String get order_after_sale_default_msg =>
      'Đơn hàng hiện đang trong quy trình hậu mãi.';

  @override
  String get order_after_sale_contact_seller => 'Liên hệ người bán';

  @override
  String get order_after_sale_cancel_apply => 'Hủy yêu cầu';

  @override
  String get order_after_sale_contact_platform => 'Liên hệ hỗ trợ nền tảng';

  @override
  String get order_after_sale_add_evidence => 'Bổ sung bằng chứng';

  @override
  String get order_after_sale_add_evidence_tip =>
      'Bạn có thể bổ sung bằng chứng hoặc kiên nhẫn chờ kết quả xử lý từ nền tảng.';

  @override
  String get order_after_sale_apply_intervention =>
      'Yêu cầu nền tảng can thiệp';

  @override
  String get order_after_sale_refund_status => 'Trạng thái hoàn tiền:';

  @override
  String get order_after_sale_refund_amount => 'Số tiền hoàn:';

  @override
  String get order_after_sale_reject_reason => 'Lý do từ chối:';

  @override
  String get order_after_sale_reject_reason_detail =>
      'Lý do: Bằng chứng không đủ hoặc không đáp ứng điều kiện hoàn tiền.';

  @override
  String get order_platform_intervention_title => 'Nền tảng can thiệp';

  @override
  String get order_platform_intervention_desc =>
      'Nếu tranh chấp không thể giải quyết qua thương lượng, bạn có thể yêu cầu hỗ trợ nền tảng can thiệp';

  @override
  String get order_platform_intervention_apply => 'Yêu cầu nền tảng can thiệp';

  @override
  String get order_platform_intervention_in_progress =>
      'Nền tảng đang can thiệp';

  @override
  String get order_platform_intervention_processing => 'Đang xử lý';

  @override
  String get order_platform_intervention_processing_msg =>
      'Yêu cầu của bạn đã gửi, hỗ trợ nền tảng sẽ liên hệ trong vòng 24 giờ';

  @override
  String get order_platform_intervention_step1 => 'Yêu cầu đã gửi';

  @override
  String get order_platform_intervention_step1_desc =>
      'Chờ hỗ trợ nền tảng xử lý';

  @override
  String get order_platform_intervention_step2 => 'Hỗ trợ can thiệp';

  @override
  String get order_platform_intervention_step2_desc =>
      'Liên hệ hai bên trong vòng 24 giờ';

  @override
  String get order_platform_intervention_step3 => 'Vấn đề đã giải quyết';

  @override
  String get order_platform_intervention_step3_desc =>
      'Xử lý theo quyết định của nền tảng';

  @override
  String get order_card_product_unknown => 'Tên sản phẩm không xác định';

  @override
  String get order_card_deleting => 'Đang xóa đơn hàng...';

  @override
  String get order_card_deleted => 'Đơn hàng đã xóa';

  @override
  String order_card_delete_failed(String error) {
    return 'Xóa thất bại: $error';
  }

  @override
  String order_card_load_detail_failed(String error) {
    return 'Tải chi tiết đơn hàng thất bại: $error';
  }

  @override
  String get order_card_timeout_canceling => 'Đã quá hạn, sắp bị hủy';

  @override
  String order_card_pay_in_time(String time) {
    return 'Thanh toán trong vòng $time';
  }

  @override
  String get order_card_timeout_submit => 'Đã quá hạn, vui lòng nộp sớm';

  @override
  String order_card_submit_in_time(String time) {
    return 'Nộp tài liệu trong vòng $time';
  }

  @override
  String get order_card_seller_timeout => 'Người bán đã quá hạn tiếp nhận';

  @override
  String order_card_seller_accept_in_time(String time) {
    return 'Người bán sẽ tiếp nhận trong vòng $time';
  }

  @override
  String order_card_delivery_days(int days) {
    return 'Giao hàng: trong vòng $days ngày';
  }

  @override
  String get order_card_auto_confirm_soon => 'Sắp tự động xác nhận nhận hàng';

  @override
  String order_card_auto_confirm_in(String time) {
    return 'Tự động xác nhận sau $time';
  }

  @override
  String get order_card_evaluate_for_points =>
      'Chờ đánh giá, nhận điểm sau khi đánh giá';

  @override
  String order_card_duration_days_hours(int days, int hours) {
    return '$days ngày $hours giờ';
  }

  @override
  String order_card_duration_hours_minutes(int hours, int minutes) {
    return '$hours giờ $minutes phút';
  }

  @override
  String order_card_duration_minutes(int minutes) {
    return '$minutes phút';
  }

  @override
  String get order_card_duration_less_than_minute => 'Chưa đến 1 phút';

  @override
  String get order_detail_invalid_id => 'ID đơn hàng không hợp lệ';

  @override
  String get order_detail_error => 'Lỗi';

  @override
  String get order_detail_title => 'Chi tiết đơn hàng';

  @override
  String order_detail_title_with_id(int id) {
    return 'Chi tiết đơn hàng (ID: $id)';
  }

  @override
  String order_detail_load_failed(String error) {
    return 'Tải thất bại: $error';
  }

  @override
  String get order_detail_reload => 'Tải lại';

  @override
  String get order_detail_unavailable => 'Dữ liệu đơn hàng không khả dụng';

  @override
  String get order_list_title => 'Đơn hàng của tôi';

  @override
  String get order_list_search_hint => 'Tìm kiếm mã đơn hàng hoặc tên sản phẩm';

  @override
  String get order_list_empty => 'Không tìm thấy đơn hàng nào';

  @override
  String order_list_load_error(String error) {
    return 'Lỗi tải: $error';
  }

  @override
  String order_list_load_failed(String error) {
    return 'Tải thất bại: $error';
  }

  @override
  String get order_list_select_category =>
      'Vui lòng chọn danh mục để xem đơn hàng';

  @override
  String get order_list_tab_all => 'Tất cả';

  @override
  String get order_list_tab_awaiting_payment => 'Chờ thanh toán';

  @override
  String get order_list_tab_awaiting_submission => 'Chờ nộp';

  @override
  String get order_list_tab_awaiting_start => 'Chờ tiếp nhận';

  @override
  String get order_list_tab_awaiting_delivery => 'Chờ giao';

  @override
  String get order_list_tab_awaiting_confirmation => 'Chờ nhận';

  @override
  String get order_list_tab_awaiting_evaluation => 'Chờ đánh giá';

  @override
  String get order_list_tab_after_sale => 'Hậu mãi';

  @override
  String get order_route_error => 'Lỗi';

  @override
  String order_route_invalid_item_id(String id) {
    return 'ID sản phẩm không hợp lệ: $id';
  }

  @override
  String order_seller_detail_title(int id) {
    return 'Chi tiết đơn hàng (Người bán) - #$id';
  }

  @override
  String order_seller_load_failed(int id, String error) {
    return 'Tải đơn hàng #$id thất bại: $error';
  }

  @override
  String get order_seller_preparing => 'Đang chuẩn bị tải...';

  @override
  String get order_seller_order_number => 'Mã đơn hàng';

  @override
  String get order_seller_order_time => 'Thời gian đặt hàng';

  @override
  String get order_seller_pay_time => 'Thời gian thanh toán';

  @override
  String get order_seller_complete_time => 'Thời gian hoàn thành';

  @override
  String get order_seller_cancel_time => 'Thời gian hủy';

  @override
  String get order_seller_list_title => 'Đơn hàng của tôi (Người bán)';

  @override
  String get order_seller_tab_all => 'Tất cả';

  @override
  String get order_seller_tab_awaiting_start => 'Chờ tiếp nhận';

  @override
  String get order_seller_tab_awaiting_delivery => 'Cần giao';

  @override
  String get order_seller_tab_awaiting_confirmation => 'Chờ xác nhận';

  @override
  String get order_seller_tab_awaiting_evaluation => 'Chờ đánh giá';

  @override
  String get order_seller_tab_completed => 'Đã hoàn thành';

  @override
  String get order_seller_tab_after_sale => 'Hậu mãi';

  @override
  String get order_seller_tab_canceled => 'Đã hủy';

  @override
  String order_seller_load_failed_msg(String error) {
    return 'Tải thất bại: $error';
  }

  @override
  String get order_seller_empty => 'Không có đơn hàng nào ở trạng thái này';

  @override
  String order_seller_action_failed(String error) {
    return 'Thao tác thất bại: $error';
  }

  @override
  String order_seller_pending_count(int count) {
    return 'Bạn có $count đơn hàng cần xử lý';
  }

  @override
  String order_seller_pending_awaiting_start(int count) {
    return '$count chờ tiếp nhận';
  }

  @override
  String order_seller_pending_awaiting_delivery(int count) {
    return '$count cần giao';
  }

  @override
  String get order_seller_reject_order => 'Từ chối đơn hàng';

  @override
  String get order_seller_confirm_order => 'Tiếp nhận đơn hàng';

  @override
  String get order_seller_contact_buyer => 'Liên hệ người mua';

  @override
  String get order_seller_go_deliver => 'Giao hàng';

  @override
  String get order_seller_view_delivery_content => 'Xem giao hàng';

  @override
  String get order_seller_remind_buyer => 'Nhắc người mua xác nhận';

  @override
  String get order_seller_delete_record => 'Xóa bản ghi';

  @override
  String get order_seller_confirm_accept_title => 'Xác nhận tiếp nhận';

  @override
  String get order_seller_confirm_accept_content =>
      'Bạn có chắc muốn tiếp nhận đơn hàng này không?';

  @override
  String get order_seller_confirm_delete_title => 'Xác nhận xóa';

  @override
  String get order_seller_confirm_delete_content =>
      'Bạn có chắc muốn xóa bản ghi đơn hàng này không? Hành động này không thể hoàn tác.';

  @override
  String get order_seller_confirm_delete_canceled_content =>
      'Bạn có chắc muốn xóa bản ghi đơn hàng đã hủy này không? Hành động này không thể hoàn tác.';

  @override
  String get order_seller_confirm_btn => 'Xác nhận';

  @override
  String get order_seller_confirm_reject_title => 'Xác nhận từ chối';

  @override
  String get order_seller_confirm_reject_content =>
      'Bạn có chắc muốn từ chối đơn hàng này không?';

  @override
  String get order_seller_confirm_reject_btn => 'Xác nhận từ chối';

  @override
  String get order_seller_reject_dialog_title => 'Từ chối đơn hàng';

  @override
  String get order_seller_reject_reason_label => 'Lý do từ chối *';

  @override
  String get order_seller_reject_reason_hint => 'Vui lòng nhập lý do từ chối';

  @override
  String get order_seller_reject_reason_empty =>
      'Lý do từ chối không được để trống';

  @override
  String get order_seller_reject_reason_required =>
      'Vui lòng nhập lý do từ chối';

  @override
  String get order_seller_remarks_label => 'Ghi chú bổ sung (Tuỳ chọn)';

  @override
  String get order_seller_remarks_hint => 'Tuỳ chọn';

  @override
  String get order_seller_delivery_dialog_title => 'Nội dung giao hàng';

  @override
  String get order_seller_delivery_desc_label => 'Mô tả giao hàng *';

  @override
  String get order_seller_delivery_desc_hint =>
      'Vui lòng mô tả nội dung giao hàng của bạn';

  @override
  String get order_seller_delivery_desc_empty =>
      'Mô tả giao hàng không được để trống';

  @override
  String get order_seller_delivery_desc_required =>
      'Vui lòng nhập mô tả giao hàng';

  @override
  String get order_seller_delivery_attachment => 'Tệp đính kèm';

  @override
  String get order_seller_delivery_select_file =>
      'Nhấn nút bên dưới để chọn tệp';

  @override
  String get order_seller_delivery_add_attachment => 'Thêm tệp đính kèm';

  @override
  String get order_seller_delivery_file_select_soon =>
      'Tính năng chọn tệp sắp ra mắt';

  @override
  String get order_seller_delivery_confirm => 'Xác nhận giao hàng';

  @override
  String order_seller_delivery_chat_hint(String productName) {
    return 'Vui lòng chọn chat về sản phẩm \"$productName\"';
  }

  @override
  String get order_seller_dynamic_delivered => 'Dịch vụ đã giao';

  @override
  String get order_seller_dynamic_delivered_msg =>
      'Bạn đã hoàn thành giao dịch vụ, hãy chờ người mua xác nhận. Nếu có vấn đề, người mua có thể khởi tạo hậu mãi.';

  @override
  String get order_seller_dynamic_completed =>
      'Đơn hàng này đã hoàn thành thành công.';

  @override
  String get order_seller_dynamic_canceled => 'Đơn hàng này đã bị hủy.';

  @override
  String get order_seller_dynamic_refused => 'Đã gửi yêu cầu từ chối đơn hàng';

  @override
  String get order_seller_dynamic_refused_msg =>
      'Yêu cầu từ chối của bạn đã gửi và đang chờ xử lý.';

  @override
  String get order_seller_buyer_materials => 'Tài liệu người mua cung cấp';

  @override
  String get order_seller_attachment_label => 'Tệp đính kèm:';

  @override
  String order_seller_view_attachment(String fileName) {
    return 'Xem tệp đính kèm sắp ra mắt: $fileName';
  }

  @override
  String get order_evaluation_product_info => 'Thông tin sản phẩm';

  @override
  String get order_list_retry => 'Thử lại';

  @override
  String chat_get_user_info_failed(String error) {
    return 'Lấy thông tin người dùng thất bại: $error';
  }

  @override
  String get chat_user_refer_id_not_found =>
      'Không tìm thấy referId của người dùng';

  @override
  String get chat_no_chat_records => 'Chưa có lịch sử chat';

  @override
  String get chat_opponent_info_missing => 'Thông tin đối phương không tồn tại';

  @override
  String get chat_product_default => 'Sản phẩm';

  @override
  String get chat_view_details => 'Xem chi tiết';

  @override
  String get chat_product_info_incomplete =>
      'Thông tin sản phẩm không đầy đủ, không thể xem chi tiết';

  @override
  String get chat_uploading => 'Đang tải lên...';

  @override
  String get chat_upload_failed => 'Tải lên thất bại';

  @override
  String get chat_retry => 'Thử lại';

  @override
  String get chat_image_loading => 'Đang tải...';

  @override
  String get chat_image_load_failed => 'Tải thất bại';

  @override
  String get chat_revoke_time_missing =>
      'Thiếu thông tin thời gian tin nhắn, không thể thu hồi';

  @override
  String get chat_revoke_available => 'Có thể thu hồi';

  @override
  String chat_revoke_expired(int seconds) {
    return 'Tin nhắn gửi đã hơn 2 phút, không thể thu hồi (vượt ${seconds}s)';
  }

  @override
  String get chat_unknown_seller => 'Người bán không xác định';

  @override
  String get chat_product_conversation => 'Hội thoại sản phẩm';

  @override
  String chat_product_conversation_count(int count) {
    return '$count hội thoại sản phẩm';
  }

  @override
  String get chat_unknown_product => 'Sản phẩm không xác định';

  @override
  String chat_user_inquiry_count(int count) {
    return '$count người dùng tư vấn';
  }

  @override
  String get chat_weekday_mon => 'Thứ Hai';

  @override
  String get chat_weekday_tue => 'Thứ Ba';

  @override
  String get chat_weekday_wed => 'Thứ Tư';

  @override
  String get chat_weekday_thu => 'Thứ Năm';

  @override
  String get chat_weekday_fri => 'Thứ Sáu';

  @override
  String get chat_weekday_sat => 'Thứ Bảy';

  @override
  String get chat_weekday_sun => 'Chủ Nhật';

  @override
  String get chat_select_multiple_images => 'Chọn nhiều ảnh';

  @override
  String chat_image_compressed(String ratio) {
    return 'Ảnh đã nén $ratio%';
  }

  @override
  String chat_image_process_failed(String error) {
    return 'Xử lý ảnh thất bại: $error';
  }

  @override
  String chat_images_processed_success(int count, String ratio) {
    return 'Đã xử lý thành công $count ảnh, nén trung bình $ratio%';
  }

  @override
  String chat_images_process_failed_count(int count) {
    return '$count ảnh xử lý thất bại';
  }

  @override
  String get chat_tap_to_view_product => 'Nhấn để xem chi tiết sản phẩm';

  @override
  String chat_yesterday_time(String time) {
    return 'Hôm qua $time';
  }

  @override
  String get chat_no_messages_brief => 'Chưa có tin nhắn';

  @override
  String chat_select_image_error(String error) {
    return 'Lỗi khi chọn ảnh: $error';
  }

  @override
  String get after_sales_reason_none => 'Không có';

  @override
  String seller_auth_status_title(String type) {
    return 'Xác minh $type';
  }

  @override
  String get seller_auth_status_label => 'Trạng thái: ';

  @override
  String get seller_auth_status_name_label => 'Tên: ';

  @override
  String get seller_auth_status_materials => 'Tài liệu xác minh';

  @override
  String get seller_auth_status_no_materials => 'Chưa có tài liệu xác minh';

  @override
  String get seller_auth_status_info => 'Thông tin xác minh';

  @override
  String get seller_auth_status_history => 'Lịch sử xác minh';

  @override
  String get seller_auth_status_no_history => 'Chưa có lịch sử';

  @override
  String get seller_auth_status_reapply => 'Xác minh lại';

  @override
  String get seller_auth_status_approved_hint =>
      'Xác minh đã được phê duyệt, không cần nộp lại';

  @override
  String get seller_auth_status_pending_hint =>
      'Xác minh đang xét duyệt, vui lòng kiên nhẫn chờ';

  @override
  String get seller_auth_status_tag_approved => 'Đã xác minh';

  @override
  String get seller_auth_status_tag_pending => 'Đang xét duyệt';

  @override
  String get seller_auth_status_tag_rejected => 'Không đạt';

  @override
  String get seller_auth_status_tag_not_submitted => 'Chưa nộp';

  @override
  String get seller_auth_status_type_idcard => 'Danh tính';

  @override
  String get seller_auth_status_type_education => 'Học vấn';

  @override
  String get seller_auth_status_type_profession => 'Nghề nghiệp';

  @override
  String get seller_auth_status_type_company => 'Doanh nghiệp';

  @override
  String get seller_auth_status_type_other => 'Khác';

  @override
  String get seller_auth_status_field_auth_name => 'Tên xác minh';

  @override
  String get seller_auth_status_field_auth_type => 'Loại xác minh';

  @override
  String get seller_auth_status_field_company_name => 'Tên công ty';

  @override
  String get seller_auth_status_field_name => 'Họ và tên';

  @override
  String get seller_auth_status_field_school_name => 'Tên trường';

  @override
  String get seller_auth_status_field_profession => 'Nghề nghiệp/Chức vụ';

  @override
  String get seller_auth_status_field_name_or_title => 'Họ tên/Tên';

  @override
  String get seller_auth_status_field_remarks => 'Ghi chú';

  @override
  String get seller_auth_status_field_cert_number => 'Số chứng chỉ';

  @override
  String get seller_auth_status_field_work_experience => 'Kinh nghiệm làm việc';

  @override
  String get seller_auth_status_field_issuer => 'Cơ quan cấp';

  @override
  String get seller_auth_status_field_credit_code =>
      'Mã số doanh nghiệp thống nhất';

  @override
  String get seller_auth_status_field_legal_rep => 'Đại diện pháp lý';

  @override
  String get seller_auth_status_field_registered_capital => 'Vốn đăng ký';

  @override
  String get seller_auth_status_field_establishment_date => 'Ngày thành lập';

  @override
  String get seller_auth_status_field_degree => 'Trình độ học vấn';

  @override
  String get seller_auth_status_field_major => 'Chuyên ngành';

  @override
  String get seller_auth_status_field_graduation_year => 'Năm tốt nghiệp';

  @override
  String get seller_auth_status_field_id_number => 'Số CMND/CCCD';

  @override
  String get seller_auth_status_field_valid_period => 'Thời hạn hiệu lực';

  @override
  String get seller_auth_status_field_submit_time => 'Thời gian nộp';

  @override
  String get seller_auth_status_field_reject_reason => 'Lý do từ chối';

  @override
  String get seller_auth_status_history_approved_title =>
      'Xác minh được phê duyệt';

  @override
  String seller_auth_status_history_approved_desc(String type) {
    return 'Đơn xác minh $type của bạn đã được phê duyệt. Bạn có thể hưởng tất cả quyền lợi người bán được xác minh.';
  }

  @override
  String get seller_auth_status_history_submitted_title =>
      'Đã nộp đơn xác minh';

  @override
  String seller_auth_status_history_submitted_desc(String type) {
    return 'Đơn xác minh $type của bạn đã được nộp. Chúng tôi sẽ hoàn thành xét duyệt trong 1-3 ngày làm việc.';
  }

  @override
  String get seller_auth_status_history_rejected_title =>
      'Xác minh không được phê duyệt';

  @override
  String seller_auth_status_history_rejected_desc(String type, String reason) {
    return 'Đơn xác minh $type của bạn không được phê duyệt. Lý do: $reason';
  }

  @override
  String get seller_auth_status_history_rejected_default_reason =>
      'Tài liệu không đáp ứng yêu cầu';

  @override
  String get seller_product_preview_title => 'Xem trước sản phẩm';

  @override
  String get seller_product_preview_back_to_edit => 'Quay lại chỉnh sửa';

  @override
  String get seller_product_preview_loading => 'Đang tải thông tin sản phẩm...';

  @override
  String get seller_product_preview_load_failed =>
      'Tải thông tin sản phẩm thất bại';

  @override
  String get seller_product_preview_retry => 'Thử lại';

  @override
  String get seller_product_preview_fetching => 'Đang lấy dữ liệu sản phẩm...';

  @override
  String get seller_product_preview_hint =>
      'Đây là chế độ xem trước. Người mua sẽ thấy giao diện tương tự.';

  @override
  String get seller_product_edit_unsaved_changes_title =>
      'Phát hiện thay đổi chưa lưu';

  @override
  String get seller_product_edit_unsaved_changes_message =>
      'Bạn có nội dung chưa lưu. Lưu làm bản nháp?';

  @override
  String get seller_product_edit_cancel => 'Hủy';

  @override
  String get seller_product_edit_discard => 'Không lưu';

  @override
  String get seller_product_edit_operation_failed => 'Thao tác thất bại';

  @override
  String get seller_product_edit_draft_saved => 'Lưu bản nháp thành công';

  @override
  String get seller_product_edit_publish_success =>
      'Dịch vụ đã đăng! Đang xét duyệt. Kiểm tra danh sách \"Đang bán\".';

  @override
  String get seller_product_edit_update_success =>
      'Cập nhật dịch vụ thành công';

  @override
  String get seller_product_edit_max_images =>
      'Chỉ được tải lên tối đa 9 ảnh, đã chọn 9 ảnh đầu tiên.';

  @override
  String seller_product_edit_price_required(String tierName) {
    return 'Giá $tierName phải lớn hơn 0';
  }

  @override
  String get seller_product_edit_form_incomplete =>
      'Dữ liệu mẫu chưa đầy đủ. Vui lòng kiểm tra các trường được đánh dấu đỏ.';

  @override
  String get seller_product_edit_add_attribute => 'Thêm thuộc tính';

  @override
  String seller_product_edit_attribute_max_chars(int max) {
    return 'Tên thuộc tính tối đa $max ký tự';
  }

  @override
  String get seller_product_edit_confirm => 'Xác nhận';

  @override
  String get seller_product_edit_options_config => 'Cấu hình tuỳ chọn';

  @override
  String get seller_product_edit_new_option => 'Tuỳ chọn mới';

  @override
  String get seller_product_edit_option_hint => 'Nhập nội dung tuỳ chọn';

  @override
  String get seller_product_edit_service_name_hint => 'Tên dịch vụ';

  @override
  String get seller_product_edit_description_hint =>
      'Mô tả thông tin chi tiết về dịch vụ của bạn, như...';

  @override
  String get seller_product_edit_faq_title => 'Chỉnh sửa câu hỏi thường gặp';

  @override
  String seller_product_edit_faq_count(int count) {
    return '$count câu hỏi';
  }

  @override
  String get seller_product_edit_add_question => 'Thêm câu hỏi';

  @override
  String get seller_product_edit_question_label => 'Câu hỏi';

  @override
  String get seller_product_edit_question_hint =>
      'Nhập câu hỏi người mua có thể hỏi';

  @override
  String get seller_product_edit_delete_question => 'Xóa câu hỏi';

  @override
  String get seller_product_edit_answer_label => 'Câu trả lời';

  @override
  String get seller_product_edit_answer_hint => 'Nhập câu trả lời';

  @override
  String get seller_product_edit_buyer_info_title =>
      'Thông tin cần người mua cung cấp';

  @override
  String seller_product_edit_buyer_info_count(int count) {
    return '$count mục thông tin';
  }

  @override
  String get seller_product_edit_buyer_info_desc =>
      'Chọn loại thông tin cần người mua cung cấp (hiển thị trên trang chi tiết đơn hàng)';

  @override
  String get seller_product_edit_selected_items => 'Các mục đã chọn:';

  @override
  String get seller_product_edit_required => 'Bắt buộc';

  @override
  String get seller_product_edit_edit_tooltip => 'Chỉnh sửa';

  @override
  String get seller_product_edit_delete_tooltip => 'Xóa';

  @override
  String seller_product_edit_add_info_title(String type) {
    return 'Thêm thông tin $type';
  }

  @override
  String get seller_product_edit_info_label => 'Nhãn thông tin';

  @override
  String get seller_product_edit_info_label_hint =>
      'Ví dụ: Yêu cầu thiết kế logo công ty';

  @override
  String get seller_product_edit_info_description => 'Mô tả chi tiết';

  @override
  String get seller_product_edit_info_description_hint =>
      'Mô tả thông tin người mua cần cung cấp';

  @override
  String get seller_product_edit_required_field => 'Trường bắt buộc';

  @override
  String get seller_product_edit_add => 'Thêm';

  @override
  String seller_product_edit_edit_info_title(String type) {
    return 'Chỉnh sửa thông tin $type';
  }

  @override
  String get seller_product_edit_save => 'Lưu';

  @override
  String seller_product_edit_cases_count(int count) {
    return '$count trường hợp';
  }

  @override
  String get seller_product_edit_add_case => 'Thêm trường hợp';

  @override
  String get seller_product_edit_image_load_failed => 'Tải ảnh thất bại';

  @override
  String get seller_product_edit_click_select_image => 'Nhấn để chọn ảnh';

  @override
  String get seller_product_edit_upload_failed => 'Tải lên thất bại';

  @override
  String get seller_product_edit_upload_retry => 'Thử lại';

  @override
  String get seller_product_edit_case_title_label => 'Tiêu đề trường hợp';

  @override
  String get seller_product_edit_case_title_hint =>
      'Mô tả ngắn gọn trường hợp này';

  @override
  String get seller_product_edit_case_desc_label => 'Mô tả trường hợp';

  @override
  String get seller_product_edit_case_desc_hint =>
      'Mô tả bối cảnh, quá trình hoặc kết quả của trường hợp này';

  @override
  String get seller_product_edit_select_image_and_title =>
      'Vui lòng chọn ảnh và nhập tiêu đề';

  @override
  String get seller_product_edit_cover_image => 'Ảnh bìa dịch vụ';

  @override
  String get seller_product_edit_upload_success => 'Tải lên thành công';

  @override
  String seller_product_edit_upload_error(String error) {
    return 'Lỗi tải lên: $error';
  }

  @override
  String get seller_product_edit_image_format_hint =>
      'Hỗ trợ định dạng jpg, png, jpeg. Mỗi ảnh tối đa 5MB, tối đa 9 ảnh.';

  @override
  String get seller_product_edit_main_image => 'Ảnh chính';

  @override
  String seller_product_edit_tier_price_label(String tierName) {
    return 'Giá $tierName';
  }

  @override
  String seller_product_edit_max_price(String max) {
    return 'Tối đa: $max';
  }

  @override
  String seller_product_edit_price_exceed_max(String max) {
    return 'Giá không được vượt quá $max';
  }

  @override
  String get seller_product_edit_price_min => 'Giá tối thiểu là 0.01';

  @override
  String get seller_product_edit_delivery_period => 'Thời gian giao hàng';

  @override
  String get seller_product_edit_delivery_days_suffix => 'ngày';

  @override
  String seller_product_edit_max_days(int max) {
    return 'Tối đa $max ngày';
  }

  @override
  String get seller_product_edit_times => 'Số lần sửa';

  @override
  String get seller_product_edit_times_suffix => 'lần';

  @override
  String seller_product_edit_max_times(int max) {
    return 'Tối đa $max lần';
  }

  @override
  String get seller_product_edit_input => 'Nhập';

  @override
  String get seller_product_edit_radio => 'Một lựa chọn';

  @override
  String get seller_product_edit_draft_label => 'Bản nháp';

  @override
  String get seller_product_edit_draft_unsaved_label => 'Bản nháp*';

  @override
  String get seller_product_edit_publish => 'Đăng';

  @override
  String get seller_product_edit_yes => 'Có';

  @override
  String get seller_product_edit_no => 'Không';

  @override
  String get seller_product_edit_add_selection_attribute =>
      'Thêm thuộc tính lựa chọn';

  @override
  String get seller_product_edit_default_options_yes_no =>
      'Tuỳ chọn mặc định: Có/Không';

  @override
  String get seller_product_edit_attribute_name_label => 'Tên thuộc tính *';

  @override
  String get seller_product_edit_attribute_name_example =>
      'Ví dụ: Màu sắc, Kiểu dáng, Chất liệu, Độ tuổi phù hợp';

  @override
  String get seller_product_edit_attribute_type_label => 'Loại thuộc tính';

  @override
  String get seller_product_edit_required_item => 'Bắt buộc';

  @override
  String seller_product_card_sales(int count) {
    return 'Doanh số: $count';
  }

  @override
  String get seller_product_card_view => 'Xem';

  @override
  String get seller_image_preview_main_image => 'Ảnh chính';

  @override
  String get seller_image_preview_set_main => 'Đặt làm ảnh chính';

  @override
  String get seller_image_preview_load_failed => 'Tải ảnh thất bại';

  @override
  String get seller_image_preview_delete_title => 'Xóa ảnh';

  @override
  String seller_image_preview_delete_confirm(int index) {
    return 'Xóa ảnh thứ $index?';
  }

  @override
  String get seller_image_preview_delete => 'Xóa';

  @override
  String get seller_file_select => 'Chọn tệp';

  @override
  String get seller_file_selected => 'Tệp đã chọn:';

  @override
  String seller_file_size(String size) {
    return 'Kích thước: $size';
  }

  @override
  String get seller_file_size_unknown => 'Không thể lấy kích thước';

  @override
  String seller_file_preview_unsupported(String name) {
    return 'Không thể xem trước loại tệp này: $name';
  }

  @override
  String get seller_common_cancel => 'Hủy';

  @override
  String get profile_user_name_default => 'Tên người dùng';

  @override
  String get profile_buyer_mode => 'Chế độ người mua';

  @override
  String get profile_my_orders => 'Đơn hàng của tôi';

  @override
  String get profile_my_dskk_section => 'DSKK của tôi';

  @override
  String get profile_liked_stories => 'Câu chuyện đã thích';

  @override
  String get profile_logout => 'Đăng xuất';

  @override
  String get profile_avatar_updated_local =>
      'Ảnh đại diện đã cập nhật nhưng chưa lưu lên máy chủ';

  @override
  String profile_image_pick_error(String error) {
    return 'Lỗi khi chọn ảnh: $error';
  }

  @override
  String profile_feature_not_implemented(String feature) {
    return 'Tính năng $feature chưa được triển khai';
  }

  @override
  String get profile_pending_payment_order => 'Chờ thanh toán';

  @override
  String get profile_in_progress_order => 'Đang thực hiện';

  @override
  String get profile_completed_order => 'Đã hoàn thành';

  @override
  String get profile_refund_after_sales => 'Hoàn tiền/Hậu mãi';

  @override
  String get profile_account_deletion => 'Xóa tài khoản';

  @override
  String get profile_bound_phone => 'Số điện thoại đã liên kết';

  @override
  String get profile_not_bound => 'Chưa liên kết';

  @override
  String get profile_nickname => 'Biệt danh';

  @override
  String get profile_confirm_logout => 'Xác nhận đăng xuất';

  @override
  String get profile_confirm_logout_message =>
      'Bạn có chắc muốn đăng xuất không?';

  @override
  String get profile_confirm => 'Xác nhận';

  @override
  String get profile_update_avatar => 'Cập nhật ảnh đại diện';

  @override
  String get profile_update_avatar_confirm =>
      'Bạn có chắc muốn cập nhật ảnh đại diện không?';

  @override
  String get profile_info_updated => 'Cập nhật thông tin cá nhân thành công!';

  @override
  String get profile_avatar_upload_timeout =>
      'Tải ảnh đại diện hết thời gian, vui lòng kiểm tra mạng và thử lại';

  @override
  String get profile_network_failed =>
      'Kết nối mạng thất bại, vui lòng kiểm tra mạng và thử lại';

  @override
  String profile_avatar_optimized(String ratio) {
    return 'Ảnh đại diện đã tối ưu, nén $ratio%';
  }

  @override
  String profile_avatar_process_failed(String error) {
    return 'Xử lý ảnh đại diện thất bại: $error';
  }

  @override
  String profile_logout_error(String error) {
    return 'Lỗi khi đăng xuất: $error';
  }

  @override
  String get profile_nickname_empty => 'Vui lòng nhập biệt danh';

  @override
  String get profile_nickname_too_short => 'Biệt danh phải có ít nhất 2 ký tự';

  @override
  String get profile_nickname_too_long =>
      'Biệt danh không được vượt quá 20 ký tự';

  @override
  String get profile_nickname_no_spaces =>
      'Biệt danh không được chứa khoảng trắng';

  @override
  String get profile_nickname_invalid_chars =>
      'Biệt danh chỉ được chứa chữ Trung, chữ Anh, số và dấu gạch dưới';

  @override
  String get profile_nickname_only_underscores =>
      'Biệt danh không thể chỉ chứa dấu gạch dưới';

  @override
  String get profile_nickname_unchanged => 'Biệt danh không thay đổi';

  @override
  String get profile_edit_nickname_title => 'Chỉnh sửa biệt danh';

  @override
  String get profile_nickname_input_hint => 'Nhập biệt danh';

  @override
  String get profile_nickname_rules =>
      'Đặt 2-20 ký tự, chỉ chứa chữ Trung, chữ Anh, số và dấu gạch dưới';

  @override
  String get profile_nickname_updated => 'Cập nhật biệt danh thành công!';

  @override
  String profile_nickname_update_failed(String error) {
    return 'Cập nhật biệt danh thất bại: $error';
  }

  @override
  String get profile_submit_changes => 'Gửi thay đổi';

  @override
  String get profile_avatar_uploaded => 'Tải ảnh đại diện thành công';

  @override
  String get profile_updated => 'Cập nhật hồ sơ thành công';

  @override
  String get profile_reload => 'Tải lại';

  @override
  String get profile_account_balance => 'Số dư tài khoản';

  @override
  String get profile_pending_settlement => 'Chờ thanh toán';

  @override
  String get profile_total_income => 'Tổng thu nhập';

  @override
  String get profile_load_wallet => 'Nhấn để tải thông tin ví';

  @override
  String get profile_all_orders => 'Tất cả đơn hàng';

  @override
  String get profile_awaiting_payment => 'Chờ thanh toán';

  @override
  String get profile_awaiting_shipment => 'Chờ giao hàng';

  @override
  String get profile_awaiting_receipt => 'Chờ nhận hàng';

  @override
  String get profile_awaiting_review => 'Chờ đánh giá';

  @override
  String get profile_shipping_address => 'Địa chỉ giao hàng';

  @override
  String get profile_browsing_history => 'Lịch sử duyệt';

  @override
  String get profile_contact_support => 'Liên hệ hỗ trợ';

  @override
  String get profile_help_center => 'Trung tâm trợ giúp';

  @override
  String get profile_feedback => 'Góp ý';

  @override
  String get profile_switch_to_seller_mode => 'Chuyển sang chế độ người bán';

  @override
  String get profile_take_photo => 'Chụp ảnh';

  @override
  String get profile_choose_from_album => 'Chọn từ album ảnh';

  @override
  String profile_image_pick_failed(String error) {
    return 'Chọn ảnh thất bại: $error';
  }

  @override
  String get profile_edit_profile => 'Chỉnh sửa hồ sơ';

  @override
  String get profile_online_status => 'Trạng thái trực tuyến';

  @override
  String get profile_mission_title => 'Sứ mệnh của trợ lý';

  @override
  String get profile_mission_our_mission => 'Sứ mệnh của chúng tôi';

  @override
  String get profile_mission_our_mission_content =>
      'Kết nối sáng tạo và nhu cầu, biến mọi ý tưởng trở thành hiện thực. Trợ lý của chúng tôi cam kết mang lại trải nghiệm dịch vụ thông minh và tận tâm nhất, trở thành người bạn đồng hành đáng tin cậy nhất trong cuộc sống và công việc của bạn.';

  @override
  String get profile_mission_core_values => 'Giá trị cốt lõi';

  @override
  String get profile_mission_core_values_content =>
      '• Người dùng trên hết: Luôn xuất phát từ nhu cầu người dùng\n• Đổi mới sáng tạo: Liên tục khám phá công nghệ và phương pháp mới\n• Dịch vụ trung thực: Cung cấp trải nghiệm dịch vụ đáng tin cậy và minh bạch\n• Cùng nhau phát triển: Tiến bước cùng người dùng và đối tác';

  @override
  String get profile_mission_service_promise => 'Cam kết dịch vụ';

  @override
  String get profile_mission_service_promise_content =>
      'Chúng tôi cam kết cung cấp cho mỗi người dùng:\n\n✓ Hỗ trợ dịch vụ thông minh 24/7\n✓ Đề xuất giải pháp cá nhân hóa\n✓ Bảo vệ dữ liệu an toàn và đáng tin cậy\n✓ Trải nghiệm người dùng được tối ưu liên tục\n✓ Dịch vụ khách hàng phản hồi nhanh';

  @override
  String get profile_mission_future_vision => 'Tầm nhìn tương lai';

  @override
  String get profile_mission_future_vision_content =>
      'Trở thành nền tảng dịch vụ thông minh hàng đầu thế giới, được hỗ trợ bởi công nghệ AI, giúp mọi người tận hưởng trải nghiệm số hóa cá nhân hóa và hiệu quả. Chúng tôi tin rằng công nghệ nên làm cho cuộc sống tốt đẹp hơn và sáng tạo dễ thực hiện hơn.';

  @override
  String get profile_mission_questions_suggestions => 'Có câu hỏi hoặc góp ý?';

  @override
  String get profile_mission_listening =>
      'Chúng tôi luôn lắng nghe tiếng nói của bạn, mong được cùng nhau tạo ra tương lai tốt đẹp hơn.';

  @override
  String get profile_mission_contact_us => 'Liên hệ chúng tôi';

  @override
  String get profile_mission_contact_coming_soon =>
      'Tính năng liên hệ sắp ra mắt, hãy đón chờ!';

  @override
  String get profile_wallet_title => 'Ví của tôi';

  @override
  String profile_wallet_error(String error) {
    return 'Lỗi: $error';
  }

  @override
  String profile_wallet_occurred_error(String error) {
    return 'Đã xảy ra lỗi: $error';
  }

  @override
  String get profile_wallet_retry => 'Thử lại';

  @override
  String get profile_wallet_filter_all => 'Tất cả';

  @override
  String get profile_wallet_filter_income => 'Thu nhập';

  @override
  String get profile_wallet_filter_expense => 'Chi tiêu';

  @override
  String get profile_wallet_no_transactions => 'Chưa có giao dịch nào';

  @override
  String profile_wallet_load_failed(String error) {
    return 'Tải thất bại: $error';
  }

  @override
  String profile_wallet_load_more_failed(String error) {
    return 'Tải thêm thất bại: $error';
  }

  @override
  String get profile_wallet_account_balance => 'Số dư tài khoản';

  @override
  String get profile_wallet_pending_amount => 'Số tiền chờ thanh toán';

  @override
  String get profile_wallet_total_income => 'Tổng thu nhập';

  @override
  String get profile_wallet_withdraw => 'Rút tiền';

  @override
  String get profile_wallet_status_completed => 'Đã hoàn thành';

  @override
  String get profile_wallet_status_pending => 'Đang xử lý';

  @override
  String get profile_wallet_status_failed => 'Thất bại';

  @override
  String get profile_wallet_status_unknown => 'Không xác định';

  @override
  String get profile_wallet_transaction_details => 'Chi tiết giao dịch';

  @override
  String get profile_wallet_transaction_id => 'Mã giao dịch';

  @override
  String get profile_wallet_transaction_type => 'Loại';

  @override
  String get profile_wallet_transaction_type_income => 'Thu nhập';

  @override
  String get profile_wallet_transaction_type_expense => 'Chi tiêu';

  @override
  String get profile_wallet_transaction_amount => 'Số tiền';

  @override
  String get profile_wallet_transaction_description => 'Mô tả';

  @override
  String get profile_wallet_transaction_date => 'Ngày';

  @override
  String get profile_wallet_transaction_status => 'Trạng thái';

  @override
  String get profile_wallet_close => 'Đóng';

  @override
  String profile_wallet_available_balance(String symbol, String amount) {
    return 'Số dư có thể rút: $symbol$amount';
  }

  @override
  String get profile_wallet_withdraw_amount => 'Số tiền rút';

  @override
  String get profile_wallet_withdraw_hint => 'Nhập số tiền rút';

  @override
  String get profile_wallet_withdraw_time =>
      'Thời gian rút tiền về tài khoản: 1-3 ngày làm việc';

  @override
  String get profile_wallet_invalid_amount =>
      'Vui lòng nhập số tiền rút hợp lệ';

  @override
  String get profile_wallet_exceed_balance =>
      'Số tiền rút không được vượt quá số dư khả dụng';

  @override
  String get profile_wallet_confirm_withdraw => 'Xác nhận rút tiền';

  @override
  String profile_wallet_withdraw_submitted(String symbol, String amount) {
    return 'Yêu cầu rút tiền đã gửi: $symbol$amount';
  }

  @override
  String get profile_wallet_not_implemented =>
      'Tính năng này chưa được triển khai';

  @override
  String get auth_verification_expired => 'Mã xác minh đã hết hạn';

  @override
  String auth_login_failed(String error) {
    return 'Đăng nhập thất bại: $error';
  }

  @override
  String auth_code_send_failed(String error) {
    return 'Gửi mã xác minh thất bại: $error';
  }

  @override
  String get auth_login_success => 'Đăng nhập thành công!';

  @override
  String get auth_login => 'Đăng nhập';

  @override
  String get auth_privacy_policy => 'Chính sách bảo mật';

  @override
  String get auth_and => 'và';

  @override
  String get auth_user_agreement => 'Thỏa thuận người dùng';

  @override
  String get auth_invalid_phone =>
      'Vui lòng nhập số điện thoại 11 chữ số hợp lệ';

  @override
  String get auth_get_code => 'Lấy mã';

  @override
  String get payment_creating_order => 'Đang tạo đơn hàng...';

  @override
  String get payment_processing => 'Đang xử lý thanh toán...';

  @override
  String get payment_credit_card => 'Thanh toán thẻ tín dụng';

  @override
  String get payment_confirm_order => 'Xác nhận đơn hàng';

  @override
  String get payment_quantity_label => 'Số lượng:';

  @override
  String get payment_order_summary => 'Tóm tắt đơn hàng';

  @override
  String get payment_product_amount => 'Tổng sản phẩm';

  @override
  String get payment_quantity => 'Số lượng';

  @override
  String get payment_order_total => 'Tổng đơn hàng';

  @override
  String get payment_method => 'Phương thức thanh toán';

  @override
  String get payment_processing_ellipsis => 'Đang xử lý...';

  @override
  String get payment_confirm_pay => 'Xác nhận thanh toán';

  @override
  String get payment_success => 'Thanh toán thành công';

  @override
  String get payment_failed => 'Thanh toán thất bại';

  @override
  String get payment_view_order_detail => 'Xem chi tiết đơn hàng';

  @override
  String get payment_back_to_orders => 'Về danh sách đơn hàng';

  @override
  String get payment_success_tip =>
      'Cảm ơn bạn đã mua hàng! Bạn có thể xem chi tiết trong đơn hàng.';

  @override
  String get payment_failed_tip =>
      'Thanh toán không thành công. Vui lòng thử lại hoặc chọn phương thức thanh toán khác.';

  @override
  String get home_banner_image_load_failed => 'Tải ảnh thất bại';

  @override
  String home_banner_placeholder(int index) {
    return 'Banner $index';
  }

  @override
  String get home_no_data => 'Chưa có dữ liệu';

  @override
  String get product_detail_no_faq => 'Chưa có câu hỏi thường gặp';

  @override
  String product_detail_buy_button(String price) {
    return 'Mua ngay $price';
  }

  @override
  String get product_detail_buyer_requirements => 'Yêu cầu từ người mua';

  @override
  String get product_detail_no_buyer_requirements =>
      'Người bán chưa đặt yêu cầu từ người mua';

  @override
  String get after_sales_apply => 'Yêu cầu hậu mãi';

  @override
  String get after_sales_apply_remake => 'Yêu cầu làm lại';

  @override
  String get after_sales_apply_supplement => 'Yêu cầu bổ sung';

  @override
  String get after_sales_apply_refund => 'Yêu cầu hoàn tiền';

  @override
  String after_sales_max_images(int max) {
    return 'Chỉ được tải lên tối đa $max ảnh';
  }

  @override
  String after_sales_images_processed(int count, String ratio) {
    return 'Đã xử lý thành công $count ảnh, nén trung bình $ratio%';
  }

  @override
  String after_sales_images_failed(int count) {
    return '$count ảnh xử lý thất bại';
  }

  @override
  String after_sales_image_pick_failed(String error) {
    return 'Chọn ảnh thất bại: $error';
  }

  @override
  String get after_sales_select_reason => 'Vui lòng chọn lý do hậu mãi';

  @override
  String get after_sales_reason_label => 'Lý do hậu mãi';

  @override
  String get after_sales_reason_quality => 'Vấn đề chất lượng sản phẩm';

  @override
  String get after_sales_reason_mismatch => 'Sản phẩm không khớp mô tả';

  @override
  String get after_sales_reason_wrong_item => 'Người bán gửi nhầm hàng';

  @override
  String get after_sales_reason_unwanted => 'Không muốn nữa';

  @override
  String get after_sales_reason_other => 'Khác';

  @override
  String get after_sales_description_label => 'Mô tả vấn đề';

  @override
  String get after_sales_description_hint =>
      'Vui lòng mô tả chi tiết vấn đề bạn gặp phải...';

  @override
  String after_sales_refund_max_hint(String symbol, String amount) {
    return 'Tối đa có thể hoàn $symbol$amount';
  }

  @override
  String get after_sales_enter_refund_amount => 'Vui lòng nhập số tiền hoàn';

  @override
  String get after_sales_invalid_amount => 'Vui lòng nhập số tiền hợp lệ';

  @override
  String get after_sales_amount_must_positive => 'Số tiền hoàn phải lớn hơn 0';

  @override
  String after_sales_amount_exceed(String symbol, String amount) {
    return 'Số tiền hoàn không được vượt quá $symbol$amount';
  }

  @override
  String after_sales_upload_proof(int max) {
    return 'Tải lên bằng chứng (tối đa $max ảnh)';
  }

  @override
  String get after_sales_remove_image => 'Xóa ảnh';

  @override
  String get after_sales_submit => 'Gửi đơn yêu cầu';

  @override
  String after_sales_loading_failed(String error) {
    return 'Tải thất bại: $error';
  }

  @override
  String get after_sales_detail_retry => 'Thử lại';

  @override
  String get after_sales_initializing => 'Đang khởi tạo...';

  @override
  String get after_sales_status_audit_reject => 'Đơn hậu mãi đã bị từ chối';

  @override
  String get after_sales_status_refund_success => 'Hoàn tiền thành công';

  @override
  String get after_sales_status_processing => 'Đang xử lý hậu mãi';

  @override
  String get after_sales_subtitle_wait_audit =>
      'Người bán sẽ xử lý đơn của bạn trong vòng 48 giờ';

  @override
  String get after_sales_subtitle_audit_pass =>
      'Tiền hoàn sẽ về trong 1-3 ngày làm việc';

  @override
  String get after_sales_subtitle_audit_reject =>
      'Nếu không đồng ý, bạn có thể yêu cầu nền tảng can thiệp';

  @override
  String get after_sales_subtitle_refund_success =>
      'Hoàn tiền đã hoàn thành, vui lòng kiểm tra tài khoản';

  @override
  String get after_sales_subtitle_canceled => 'Bạn đã hủy đơn yêu cầu hậu mãi';

  @override
  String get after_sales_subtitle_default => 'Vui lòng chờ kết quả xử lý';

  @override
  String get after_sales_product_info => 'Thông tin sản phẩm';

  @override
  String get after_sales_product_unknown => 'Tên sản phẩm không xác định';

  @override
  String after_sales_spec(String spec) {
    return 'Thông số: $spec';
  }

  @override
  String after_sales_quantity(int count) {
    return 'Số lượng: $count';
  }

  @override
  String get after_sales_info => 'Thông tin hậu mãi';

  @override
  String get after_sales_application_number => 'Mã đơn yêu cầu';

  @override
  String get after_sales_application_time => 'Thời gian yêu cầu';

  @override
  String get after_sales_refund_amount_label => 'Số tiền hoàn';

  @override
  String get after_sales_application_reason => 'Lý do yêu cầu';

  @override
  String get after_sales_detailed_description => 'Mô tả chi tiết';

  @override
  String get after_sales_audit_remark => 'Ghi chú xét duyệt';

  @override
  String get after_sales_revoke => 'Hủy đơn yêu cầu';

  @override
  String get after_sales_modify => 'Sửa đơn yêu cầu';

  @override
  String get after_sales_platform_intervention => 'Yêu cầu nền tảng can thiệp';

  @override
  String get after_sales_list_title => 'Danh sách hậu mãi';

  @override
  String get after_sales_no_records => 'Chưa có đơn yêu cầu hậu mãi';

  @override
  String get after_sales_please_wait => 'Vui lòng chờ...';

  @override
  String get after_sales_unknown_product => 'Sản phẩm không xác định';

  @override
  String after_sales_status_label(String status) {
    return 'Trạng thái: $status';
  }

  @override
  String get after_sales_select_type => 'Chọn loại hậu mãi';

  @override
  String get after_sales_type_remake => 'Yêu cầu làm lại';

  @override
  String get after_sales_type_remake_desc =>
      'Không hài lòng với kết quả? Thương lượng làm lại với người tạo';

  @override
  String get after_sales_type_supplement => 'Yêu cầu bổ sung';

  @override
  String get after_sales_type_supplement_desc =>
      'Kết quả chưa hoàn chỉnh? Thương lượng bổ sung với người tạo';

  @override
  String get after_sales_type_refund => 'Yêu cầu hoàn tiền';

  @override
  String get after_sales_type_refund_desc => 'Thương lượng hoàn tiền';

  @override
  String get after_sales_no_record_for_order =>
      'Không tìm thấy đơn hậu mãi cho đơn hàng này';

  @override
  String after_sales_unknown_error(String error) {
    return 'Lỗi không xác định khi tải chi tiết hậu mãi: $error';
  }

  @override
  String get after_sales_server_error => 'Lỗi máy chủ';

  @override
  String get after_sales_cache_error => 'Lỗi bộ nhớ đệm';

  @override
  String get after_sales_network_error => 'Lỗi kết nối mạng';

  @override
  String get after_sales_general_unknown_error =>
      'Đã xảy ra lỗi không xác định';

  @override
  String get favorites_title => 'Yêu thích của tôi';

  @override
  String get favorites_tab_services => 'Dịch vụ';

  @override
  String get favorites_tab_sellers => 'Người bán';

  @override
  String get favorites_close => 'Đóng';

  @override
  String get favorites_empty_services => 'Chưa có dịch vụ nào được lưu';

  @override
  String get favorites_empty_sellers => 'Chưa có người bán nào đang theo dõi';

  @override
  String get favorites_empty_services_hint =>
      'Bạn có thể nhấn yêu thích khi xem dịch vụ';

  @override
  String get favorites_empty_sellers_hint =>
      'Bạn có thể nhấn theo dõi khi xem trang người bán';

  @override
  String get favorites_unfollow => 'Hủy theo dõi';

  @override
  String get favorites_remove => 'Bỏ yêu thích';

  @override
  String get favorites_seller_type_member => 'Người bán cá nhân';

  @override
  String get favorites_seller_type_enterprise => 'Người bán doanh nghiệp';

  @override
  String get favorites_seller_type_platform => 'Người bán nền tảng';

  @override
  String get favorites_seller_type_default => 'Người bán';

  @override
  String get favorites_status_active => 'Đang hoạt động';

  @override
  String get favorites_status_inactive => 'Không hoạt động';

  @override
  String get favorites_status_suspended => 'Đã tạm ngưng';

  @override
  String get favorites_status_banned => 'Đã bị cấm';

  @override
  String ai_docs_chat_create_failed(String error) {
    return 'Không thể tạo phiên chat: $error';
  }

  @override
  String get ai_docs_chat_room_empty =>
      'ID phòng chat trống, không thể vào chat';

  @override
  String ai_docs_chat_enter_error(String error) {
    return 'Lỗi khi vào chat: $error';
  }

  @override
  String get ai_docs_rate_limit_details => 'Chi tiết sử dụng';

  @override
  String ai_docs_rate_limit_remaining(int count) {
    return 'Còn lại $count lần';
  }

  @override
  String ai_docs_rate_limit_reset_in(String time) {
    return 'Đặt lại sau $time';
  }

  @override
  String get ai_docs_rate_limit_rules => 'Quy tắc sử dụng';

  @override
  String get ai_docs_rate_limit_burst => 'Giới hạn đột biến';

  @override
  String get ai_docs_rate_limit_hourly => 'Giới hạn mỗi giờ';

  @override
  String get ai_docs_rate_limit_upgrade => 'Nâng cấp để có thêm';

  @override
  String get ai_docs_rate_limit_upgrade_coming =>
      'Tính năng nâng cấp sắp ra mắt';

  @override
  String ai_docs_rate_limit_time_hours(int hours) {
    return '$hours giờ';
  }

  @override
  String ai_docs_rate_limit_time_minutes(int minutes) {
    return '$minutes phút';
  }

  @override
  String ai_docs_rate_limit_time_seconds(int seconds) {
    return '$seconds giây';
  }

  @override
  String get ai_docs_rate_limit_reset => 'Đã đặt lại';

  @override
  String get ai_docs_rate_limit_warning_title => 'Số lần sử dụng sắp hết';

  @override
  String get ai_docs_rate_limit_today_remaining => 'Còn lại hôm nay';

  @override
  String ai_docs_rate_limit_remaining_info(int count, String time) {
    return 'Còn $count lần sử dụng, đặt lại sau $time';
  }

  @override
  String get ai_docs_rate_limit_today_usage => 'Sử dụng hôm nay';

  @override
  String get auth_verification_code_expired => 'Mã xác minh đã hết hạn';

  @override
  String get auth_get_verification_code => 'Lấy mã';

  @override
  String get home_image_load_failed => 'Tải ảnh thất bại';

  @override
  String get home_reached_end => 'Đã đến cuối';

  @override
  String get home_reviews_title => 'Đánh giá';

  @override
  String home_reviews_load_failed(String error) {
    return 'Tải thất bại: $error';
  }

  @override
  String get home_reviews_no_reviews => 'Chưa có đánh giá';

  @override
  String get home_reviews_default_content => 'Tốt, rất kiên nhẫn';

  @override
  String get home_reviews_seller_reply => 'Phản hồi người bán';

  @override
  String home_reviews_years_ago(int count) {
    return '$count năm trước';
  }

  @override
  String home_reviews_months_ago(int count) {
    return '$count tháng trước';
  }

  @override
  String home_reviews_days_ago(int count) {
    return '$count ngày trước';
  }

  @override
  String home_reviews_hours_ago(int count) {
    return '$count giờ trước';
  }

  @override
  String home_reviews_minutes_ago(int count) {
    return '$count phút trước';
  }

  @override
  String get home_reviews_just_now => 'Vừa xong';

  @override
  String get after_sales_apply_title => 'Yêu cầu hậu mãi';

  @override
  String get after_sales_select_reason_hint => 'Vui lòng chọn lý do hậu mãi';

  @override
  String get after_sales_select_reason_validator =>
      'Vui lòng chọn lý do hậu mãi';

  @override
  String after_sales_refund_amount_hint(String symbol, String amount) {
    return 'Tối đa có thể hoàn $symbol$amount';
  }

  @override
  String get after_sales_refund_amount_required => 'Vui lòng nhập số tiền hoàn';

  @override
  String get after_sales_refund_amount_invalid =>
      'Vui lòng nhập số tiền hợp lệ';

  @override
  String get after_sales_refund_amount_positive =>
      'Số tiền hoàn phải lớn hơn 0';

  @override
  String after_sales_refund_amount_exceed(String symbol, String amount) {
    return 'Số tiền hoàn không được vượt quá $symbol$amount';
  }

  @override
  String after_sales_upload_evidence(int max) {
    return 'Tải lên bằng chứng (tối đa $max ảnh)';
  }

  @override
  String after_sales_image_process_success(int count, String ratio) {
    return 'Đã xử lý thành công $count ảnh, nén trung bình $ratio%';
  }

  @override
  String after_sales_image_process_failed(int count) {
    return '$count ảnh xử lý thất bại';
  }

  @override
  String after_sales_detail_load_failed(String error) {
    return 'Tải thất bại: $error';
  }

  @override
  String get after_sales_detail_initializing => 'Đang khởi tạo...';

  @override
  String get after_sales_info_title => 'Thông tin hậu mãi';

  @override
  String get after_sales_info_order_number => 'Mã đơn yêu cầu';

  @override
  String get after_sales_info_apply_time => 'Thời gian yêu cầu';

  @override
  String get after_sales_info_refund_amount => 'Số tiền hoàn';

  @override
  String get after_sales_info_reason => 'Lý do';

  @override
  String get after_sales_info_description => 'Mô tả chi tiết';

  @override
  String get after_sales_info_audit_remark => 'Ghi chú xét duyệt';

  @override
  String after_sales_list_load_failed(String error) {
    return 'Tải thất bại: $error';
  }

  @override
  String get after_sales_list_empty => 'Chưa có đơn yêu cầu hậu mãi';

  @override
  String get after_sales_list_loading => 'Vui lòng chờ...';

  @override
  String get after_sales_list_unknown_product => 'Sản phẩm không xác định';

  @override
  String after_sales_list_status(String status) {
    return 'Trạng thái: $status';
  }

  @override
  String after_sales_list_apply_time(String time) {
    return 'Thời gian yêu cầu: $time';
  }

  @override
  String get after_sales_select_type_title => 'Chọn loại hậu mãi';

  @override
  String get after_sales_type_remake_title => 'Tôi muốn làm lại';

  @override
  String get after_sales_type_remake_subtitle =>
      'Không hài lòng với kết quả, thương lượng làm lại với người tạo';

  @override
  String get after_sales_type_supplement_title => 'Tôi muốn bổ sung';

  @override
  String get after_sales_type_supplement_subtitle =>
      'Kết quả chưa hoàn chỉnh, thương lượng bổ sung với người tạo';

  @override
  String get after_sales_type_refund_title => 'Tôi muốn hoàn tiền';

  @override
  String get after_sales_type_refund_subtitle => 'Thương lượng hoàn tiền';

  @override
  String get favorites_seller_status_active => 'Đang hoạt động';

  @override
  String get favorites_seller_status_inactive => 'Không hoạt động';

  @override
  String get favorites_seller_status_suspended => 'Đã tạm ngưng';

  @override
  String get favorites_seller_status_banned => 'Đã bị cấm';

  @override
  String get app_store_settings => 'Cài đặt cửa hàng';

  @override
  String get app_wallet => 'Ví';

  @override
  String get app_wallet_init_failed => 'Khởi tạo trang ví thất bại';

  @override
  String get app_error_label => 'Lỗi';

  @override
  String get app_go_back => 'Quay lại';

  @override
  String get app_page_not_found => 'Không tìm thấy trang';

  @override
  String get app_path_error => 'Lỗi đường dẫn';

  @override
  String get app_error_generic => 'Lỗi';

  @override
  String get app_dev_menu_title => 'Menu gỡ lỗi nhà phát triển';

  @override
  String get app_dev_common_entries => 'Lối vào thường dùng';

  @override
  String get app_dev_dskk => 'DSKK';

  @override
  String get app_dev_order_module_buyer => 'Mô-đun đơn hàng (Người mua)';

  @override
  String get app_dev_order_list => 'Danh sách đơn hàng';

  @override
  String get app_dev_order_detail_example => 'Chi tiết đơn hàng (Ví dụ)';

  @override
  String get app_dev_order_module_seller => 'Mô-đun đơn hàng (Người bán)';

  @override
  String get app_dev_seller_order_list => 'Danh sách đơn hàng người bán';

  @override
  String get app_dev_seller_order_detail_example =>
      'Chi tiết đơn hàng người bán (Ví dụ)';

  @override
  String get app_dev_seller_module => 'Mô-đun người bán';

  @override
  String get app_dev_seller_center => 'Trung tâm người bán (Trang chủ)';

  @override
  String get app_dev_ai_docs_module => 'Mô-đun AI Docs';

  @override
  String get app_dev_ai_chat => 'AI Chat';

  @override
  String get app_dev_test_other => 'Kiểm thử/Khác';

  @override
  String get app_dev_current_credentials =>
      'Thông tin xác thực hiện tại (mã cứng): ';

  @override
  String get app_dev_temp_injection =>
      '(Tạm thời, sẽ được xóa sau khi hợp nhất mô-đun Auth)';

  @override
  String app_dev_navigation_failed(String path, String error) {
    return 'Điều hướng thất bại: $path - $error';
  }

  @override
  String get core_processing => 'Đang xử lý...';

  @override
  String get core_yesterday => 'Hôm qua';

  @override
  String get payment_test_title => 'Kiểm thử tính năng thanh toán';

  @override
  String get payment_check_availability =>
      'Kiểm tra khả năng sử dụng phương thức thanh toán';

  @override
  String get payment_test_params => 'Tham số kiểm thử';

  @override
  String get payment_order_number => 'Mã đơn hàng';

  @override
  String get payment_amount_yuan => 'Số tiền';

  @override
  String get payment_product_name => 'Tên sản phẩm';

  @override
  String get payment_select_method => 'Chọn phương thức thanh toán';

  @override
  String payment_test_button(String method, String amount) {
    return 'Kiểm thử $method ¥$amount';
  }

  @override
  String get payment_usage_instructions => 'Hướng dẫn sử dụng';

  @override
  String get payment_instruction_1 => '1. Chỉnh sửa tham số kiểm thử ở trên';

  @override
  String get payment_instruction_2 =>
      '2. Chọn phương thức thanh toán để kiểm thử';

  @override
  String get payment_instruction_3 =>
      '3. Nhấn nút kiểm thử để khởi tạo thanh toán';

  @override
  String get payment_instruction_4 =>
      '4. Nhấn nút thông tin góc trên phải để kiểm tra khả năng sử dụng';

  @override
  String get payment_test_warning =>
      'Lưu ý: Sử dụng 0.01 để kiểm thử trong môi trường kiểm thử';

  @override
  String get payment_test_product => 'Sản phẩm kiểm thử';

  @override
  String payment_initiated_success(String message) {
    return 'Đã khởi tạo thanh toán: $message';
  }

  @override
  String payment_failed_message(String message) {
    return 'Thanh toán thất bại: $message';
  }

  @override
  String payment_exception(String error) {
    return 'Lỗi thanh toán: $error';
  }

  @override
  String get payment_availability_title =>
      'Khả năng sử dụng phương thức thanh toán';

  @override
  String get payment_alipay => 'Alipay';

  @override
  String get payment_wechat => 'WeChat Pay';

  @override
  String get payment_wallet_balance => 'Số dư ví';

  @override
  String get payment_confirm => 'Xác nhận';

  @override
  String payment_check_failed(String error) {
    return 'Kiểm tra thất bại: $error';
  }

  @override
  String get payment_alipay_subtitle => 'Thanh toán nhanh & an toàn';

  @override
  String get payment_wechat_subtitle => 'Thanh toán an toàn qua WeChat';

  @override
  String get payment_amount_label => 'Số tiền: ';

  @override
  String get payment_terms_agreement =>
      'Nhấn \"Xác nhận thanh toán\" là bạn đồng ý với các điều khoản dịch vụ của chúng tôi';

  @override
  String get payment_create_order_failed => 'Tạo đơn thanh toán thất bại';

  @override
  String get payment_method_test_title => 'Kiểm thử phương thức thanh toán';

  @override
  String get payment_alipay_pay => 'Thanh toán Alipay';

  @override
  String get payment_test_functions => 'Chức năng kiểm thử';

  @override
  String get payment_test_alipay => 'Kiểm thử thanh toán Alipay';

  @override
  String get payment_test_wechat => 'Kiểm thử thanh toán WeChat';

  @override
  String get payment_test_credit_card => 'Kiểm thử thanh toán thẻ tín dụng';

  @override
  String get payment_recent_test_result => 'Kết quả kiểm thử gần đây';

  @override
  String get payment_no_test_result => 'Chưa có kết quả kiểm thử';

  @override
  String get payment_available => 'Khả dụng';

  @override
  String get payment_unavailable => 'Không khả dụng';

  @override
  String payment_method_label(String name) {
    return 'Phương thức thanh toán: $name';
  }

  @override
  String get payment_mock_mode => 'Chế độ Mock';

  @override
  String payment_error_label(String error) {
    return 'Lỗi: $error';
  }

  @override
  String get payment_nav_network_failed => 'Kết nối mạng thất bại';

  @override
  String get payment_nav_network_error_message =>
      'Lỗi mạng, vui lòng kiểm tra kết nối và thử lại';

  @override
  String get payment_nav_view_orders => 'Xem đơn hàng';

  @override
  String get payment_nav_retry_payment => 'Thử lại thanh toán';

  @override
  String get payment_nav_result_unknown_title =>
      'Kết quả thanh toán chưa xác định';

  @override
  String get payment_nav_result_unknown_message =>
      'Không thể xác nhận kết quả thanh toán. Vui lòng kiểm tra trạng thái đơn hàng sau hoặc liên hệ hỗ trợ';

  @override
  String get payment_nav_query_status => 'Kiểm tra trạng thái';

  @override
  String get payment_nav_cancel_continue =>
      'Đã hủy thanh toán. Bạn có thể tiếp tục hoàn tất thanh toán';

  @override
  String get payment_nav_processing =>
      'Thanh toán đang được xử lý. Vui lòng kiểm tra trạng thái đơn hàng sau';

  @override
  String get payment_nav_success => 'Thanh toán thành công';

  @override
  String get payment_nav_failed => 'Thanh toán thất bại';

  @override
  String get payment_nav_retrying => 'Đang thử lại thanh toán...';

  @override
  String get payment_nav_retry_failed =>
      'Không thể thử lại thanh toán, thông tin đơn hàng bị mất';

  @override
  String get payment_nav_querying => 'Đang kiểm tra trạng thái thanh toán...';

  @override
  String get payment_nav_query_failed =>
      'Không thể kiểm tra trạng thái, thông tin đơn hàng bị mất';

  @override
  String payment_test_description(String subject) {
    return '$subject - Kiểm thử thanh toán';
  }

  @override
  String get chat_translating => 'Đang dịch...';

  @override
  String get chat_translation_label => 'Bản dịch';
}
