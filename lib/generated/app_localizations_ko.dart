// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get language_settings => '언어 설정';

  @override
  String get system_language => '시스템 언어';

  @override
  String get system_language_description => '기기의 언어 설정을 자동으로 사용합니다';

  @override
  String get ai_docs_assistant_title => 'AI 어시스턴트';

  @override
  String get ai_docs_unnamed_conversation => '이름 없는 대화';

  @override
  String get ai_docs_loading => '로딩 중...';

  @override
  String get ai_docs_match_button => '매칭';

  @override
  String get ai_docs_select_conversation_first => '먼저 대화를 선택해 주세요';

  @override
  String get ai_docs_please_enter_message => '메시지를 입력해 주세요';

  @override
  String get ai_docs_recommended_services => '추천 서비스';

  @override
  String ai_docs_recommendations_error(String error) {
    return '추천 서비스를 불러오지 못했습니다: $error';
  }

  @override
  String get ai_docs_no_recommendations => '추천 서비스가 없습니다';

  @override
  String get ai_docs_dispatched => '전달됨';

  @override
  String get ai_docs_enter_chat => '채팅 입장';

  @override
  String get ai_docs_let_them_see => '판매자에게 보여주기';

  @override
  String get ai_docs_welcome_title => 'AI 어시스턴트에 오신 것을 환영합니다';

  @override
  String get ai_docs_welcome_message => '메시지를 보내면 대화가 시작되며, 채팅방이 자동으로 생성됩니다';

  @override
  String get ai_docs_auto_create_text =>
      '선택된 대화가 없어 새 대화를 자동으로 생성하고 메시지를 전송합니다';

  @override
  String get ai_docs_auto_create_voice =>
      '선택된 대화가 없어 새 대화를 자동으로 생성하고 음성 메시지를 전송합니다';

  @override
  String get ai_docs_cancelling_generation => '생성 취소 중...';

  @override
  String get allocating_step1 => '배정 중';

  @override
  String get allocating_step2 => '배정 중.';

  @override
  String get allocating_step3 => '배정 중..';

  @override
  String get allocating_step4 => '배정 중...';

  @override
  String get ai_docs_add_image => '이미지 추가';

  @override
  String get ai_docs_stop_recording => '녹음 중지';

  @override
  String get ai_docs_start_recording => '음성 녹음';

  @override
  String get ai_docs_recording => '녹음 중... 탭하여 전송';

  @override
  String get ai_docs_enter_message => '메시지 입력...';

  @override
  String get ai_docs_stop_generation => '생성 중지';

  @override
  String get ai_docs_send_message => '메시지 전송';

  @override
  String get ai_docs_uploading_images => '이미지 업로드 중, 잠시 기다려 주세요...';

  @override
  String get ai_docs_mic_permission_denied => '마이크 권한이 거부되었습니다';

  @override
  String ai_docs_recording_error(String error) {
    return '녹음 시작 오류: $error';
  }

  @override
  String get ai_docs_recording_file_not_found => '오류: 녹음 파일을 찾을 수 없습니다';

  @override
  String get ai_docs_stop_recording_error => '녹음 중지 오류';

  @override
  String ai_docs_stop_recording_error_with_reason(String error) {
    return '녹음 중지 오류: $error';
  }

  @override
  String ai_docs_image_picking_error(String error) {
    return '이미지 선택 오류: $error';
  }

  @override
  String get ai_docs_conversation_list => '대화 목록';

  @override
  String get ai_docs_no_messages => '메시지가 없습니다. 대화를 시작해 보세요!';

  @override
  String get ai_docs_new_chat => '새 채팅';

  @override
  String get ai_docs_load_conversations_failed => '대화를 불러오지 못했습니다';

  @override
  String get ai_docs_retry => '다시 시도';

  @override
  String get ai_docs_no_conversations => '대화가 없습니다';

  @override
  String get ai_docs_delete_conversation_tooltip => '대화 삭제';

  @override
  String get ai_docs_delete_conversation_title => '대화를 삭제하시겠습니까?';

  @override
  String get ai_docs_delete_conversation_content => '이 대화를 영구적으로 삭제하시겠습니까?';

  @override
  String get ai_docs_cancel => '취소';

  @override
  String get ai_docs_delete => '삭제';

  @override
  String get ai_docs_please_select_conversation_to_delete =>
      '먼저 삭제할 대화를 선택해 주세요';

  @override
  String get ai_docs_generate_title => 'AI 제목 생성';

  @override
  String get ai_docs_generate_title_tooltip => 'AI로 이 대화의 제목을 생성합니다';

  @override
  String get ai_docs_generating_title => '제목 생성 중...';

  @override
  String get ai_docs_title_generated => '제목이 생성되었습니다';

  @override
  String ai_docs_title_generation_failed(String error) {
    return '제목 생성 실패: $error';
  }

  @override
  String get ai_docs_edit_title => '제목 편집';

  @override
  String get ai_docs_edit_title_hint => '새 제목을 입력해 주세요';

  @override
  String get ai_docs_title_updated => '제목이 업데이트되었습니다';

  @override
  String ai_docs_title_update_failed(String error) {
    return '제목 업데이트 실패: $error';
  }

  @override
  String get ai_docs_title_too_long => '제목은 50자를 초과할 수 없습니다';

  @override
  String get ai_docs_title_empty => '제목을 입력해 주세요';

  @override
  String get nav_ai_assistant => '다소칸칸';

  @override
  String get nav_home => '홈';

  @override
  String get nav_messages => '메시지';

  @override
  String get nav_profile => '내 정보';

  @override
  String get nav_dev => '개발';

  @override
  String get nav_seller_analytics => '통계';

  @override
  String get nav_seller_products => '상품';

  @override
  String get nav_seller_messages => '메시지';

  @override
  String get nav_seller_profile => '내 정보';

  @override
  String get chat_list_title => '채팅 목록';

  @override
  String get chat_loading => '로딩 중...';

  @override
  String chat_error_loading(String error) {
    return '로딩 실패: $error';
  }

  @override
  String get chat_no_messages => '메시지가 없습니다. 대화를 시작해 보세요!';

  @override
  String get chat_admin_title => '시스템 관리자';

  @override
  String get chat_notification_center => '알림 센터';

  @override
  String get chat_notification_description => '시스템, 주문, 리뷰 등 중요 알림';

  @override
  String get chat_enter_message => '메시지 입력...';

  @override
  String get chat_yesterday => '어제';

  @override
  String get chat_image_message => '[이미지]';

  @override
  String get chat_audio_message => '[음성]';

  @override
  String get chat_file_message => '【파일】';

  @override
  String get chat_allocate_message => '【다수칸칸】';

  @override
  String get chat_payment_prompt_message => '【결제 요청】';

  @override
  String get chat_revoked_message => '[메시지가 취소되었습니다]';

  @override
  String get chat_unknown_message => '[알 수 없는 메시지]';

  @override
  String get chat_unknown_user => '알 수 없는 사용자';

  @override
  String get chat_invalid_session => '유효하지 않은 세션';

  @override
  String get chat_opponent_not_found => '상대방 정보를 찾을 수 없습니다';

  @override
  String get chat_message_recalled => '메시지를 취소했습니다';

  @override
  String get chat_copy => '복사';

  @override
  String get chat_recall => '취소';

  @override
  String get chat_copied_to_clipboard => '클립보드에 복사되었습니다';

  @override
  String get chat_me => '나';

  @override
  String get chat_buyer => '구매자';

  @override
  String get chat_i_want_seller_to_see => '판매자에게 보여주고 싶습니다';

  @override
  String get chat_wants_to_see => '보고 싶어합니다';

  @override
  String get chat_collapse => '접기';

  @override
  String get chat_expand => '펼치기';

  @override
  String get chat_admin_connection_error => '시스템 관리자에 연결할 수 없습니다';

  @override
  String get chat_audio_pause => '일시정지';

  @override
  String get chat_audio_play => '재생';

  @override
  String get chat_markdown_example_title1 => '1단계 제목입니다';

  @override
  String get chat_markdown_example_title2 => '2단계 제목입니다';

  @override
  String get chat_markdown_example_bold_italic =>
      '이것은 **굵은** 텍스트와 *기울임* 텍스트입니다.';

  @override
  String get chat_markdown_example_list1 => '목록 항목 1입니다';

  @override
  String get chat_markdown_example_list2 => '목록 항목 2입니다';

  @override
  String get chat_markdown_example_list3 => '중첩 목록 항목입니다';

  @override
  String get chat_markdown_example_quote => '인용 텍스트입니다. 여러 줄을 지원합니다';

  @override
  String get chat_markdown_example_table_col1 => '열 1';

  @override
  String get chat_markdown_example_table_col2 => '열 2';

  @override
  String get chat_markdown_example_table_content1 => '내용 1';

  @override
  String get chat_markdown_example_table_content2 => '내용 2';

  @override
  String get chat_markdown_example_table_content3 => '내용 3';

  @override
  String get chat_markdown_example_table_content4 => '내용 4';

  @override
  String get chat_pick_from_gallery => '갤러리에서 선택';

  @override
  String get chat_take_photo => '사진 촬영';

  @override
  String get chat_send_markdown => 'Markdown 예시 전송';

  @override
  String get chat_switch_to_text => '텍스트 입력으로 전환';

  @override
  String get chat_switch_to_voice => '음성 입력으로 전환';

  @override
  String get chat_send => '전송';

  @override
  String get chat_attach => '이미지/파일 전송';

  @override
  String get chat_filter_all => '전체';

  @override
  String get chat_filter_buyer => '구매자 채팅';

  @override
  String get chat_filter_seller => '판매자 채팅';

  @override
  String get chat_filter_mode_all => '전체 채팅 표시';

  @override
  String get chat_filter_mode_buyer => '구매자 채팅만 표시';

  @override
  String get chat_filter_mode_seller => '판매자 채팅만 표시';

  @override
  String get chat_press_to_talk => '누르고 말하기';

  @override
  String chat_release_to_send(int duration) {
    return '놓으면 전송 ($duration초)';
  }

  @override
  String get chat_camera_permission_denied_title => '카메라 권한이 거부되었습니다';

  @override
  String get chat_camera_permission_denied_message =>
      '사진 촬영 기능을 사용하려면 시스템 설정에서 카메라 권한을 허용해 주세요.';

  @override
  String get chat_mic_permission_denied_title => '마이크 권한이 거부되었습니다';

  @override
  String get chat_mic_permission_denied_message =>
      '녹음 기능을 사용하려면 시스템 설정에서 마이크 권한을 허용해 주세요.';

  @override
  String get chat_permission_denied_cancel => '취소';

  @override
  String get chat_permission_denied_settings => '설정으로 이동';

  @override
  String get chat_mic_permission_denied => '마이크 권한이 없어 녹음할 수 없습니다';

  @override
  String get chat_camera_permission_denied => '카메라 권한이 없어 촬영할 수 없습니다';

  @override
  String chat_recording_error(String error) {
    return '녹음 시작 오류: $error';
  }

  @override
  String chat_stop_recording_error(String error) {
    return '녹음 중지 실패: $error';
  }

  @override
  String chat_image_picking_error(String error) {
    return '이미지 선택 오류: $error';
  }

  @override
  String get chat_web_recording_not_supported => '웹 플랫폼에서는 녹음을 지원하지 않습니다';

  @override
  String get profile_personal_center => '개인 센터';

  @override
  String get profile_login_prompt => '프로필을 보려면 로그인해 주세요';

  @override
  String get profile_login_button => '로그인';

  @override
  String get auth_phone_number => '휴대폰 번호';

  @override
  String get auth_select_country_region => '국가/지역 선택';

  @override
  String get auth_phone_validation_empty => '휴대폰 번호를 입력해 주세요';

  @override
  String get auth_phone_validation_invalid_cn => '11자리 휴대폰 번호를 입력해 주세요';

  @override
  String get auth_phone_validation_invalid_cn_start => '휴대폰 번호는 1로 시작해야 합니다';

  @override
  String get auth_phone_validation_invalid_us => '10자리 전화번호를 입력해 주세요';

  @override
  String get auth_phone_validation_invalid_jp_kr =>
      '10자리 또는 11자리 전화번호를 입력해 주세요';

  @override
  String get auth_phone_validation_invalid_general => '올바른 전화번호를 입력해 주세요';

  @override
  String profile_loading_error(String error) {
    return '로딩 실패: $error';
  }

  @override
  String get profile_my_dskk => '내 DSKK';

  @override
  String get profile_favorites => '즐겨찾기';

  @override
  String get profile_my_wallet => '내 지갑';

  @override
  String get profile_wallet => '지갑';

  @override
  String get profile_settings => '설정';

  @override
  String get profile_account_security => '계정 및 보안';

  @override
  String get profile_message_notifications => '메시지 알림';

  @override
  String get profile_about_us => '앱 정보';

  @override
  String get profile_assistant_mission => '어시스턴트의 사명';

  @override
  String get profile_switch_to_seller => '판매자 모드로 전환';

  @override
  String profile_switch_error(String error) {
    return '판매자 모드로 전환할 수 없습니다: $error';
  }

  @override
  String get profile_edit_nickname => '닉네임 변경';

  @override
  String get profile_nickname_hint => '새 닉네임을 입력해 주세요';

  @override
  String get profile_nickname_empty_error => '닉네임을 입력해 주세요';

  @override
  String get profile_nickname_length_error => '닉네임은 최대 20자까지 가능합니다';

  @override
  String get profile_cancel => '취소';

  @override
  String get profile_save => '저장';

  @override
  String get profile_default_name => '사용자';

  @override
  String get profile_online => '온라인';

  @override
  String get profile_offline => '오프라인';

  @override
  String get profile_avatar_upload_failed => '프로필 사진 업로드에 실패했습니다. 다시 시도해 주세요';

  @override
  String get profile_orders => '내 주문';

  @override
  String get profile_pending_payment => '결제 대기';

  @override
  String get profile_in_progress => '제출 대기';

  @override
  String get profile_completed => '수령 대기';

  @override
  String get profile_refund => '애프터서비스';

  @override
  String profile_navigation_error(String error) {
    return '주문 목록으로 이동할 수 없습니다: $error';
  }

  @override
  String get home_title => '홈';

  @override
  String get home_search_hint => '서비스 검색';

  @override
  String get home_loading => '로딩 중...';

  @override
  String home_loading_failed(String error) {
    return '로딩 실패: $error';
  }

  @override
  String get home_retry => '다시 시도';

  @override
  String get home_end_of_list => '더 이상 항목이 없습니다';

  @override
  String get home_no_content => '추천 콘텐츠가 없습니다';

  @override
  String get home_pull_to_refresh => '당겨서 추천 콘텐츠를 새로고침하세요';

  @override
  String get home_refreshing_recommendations => '추천 새로고침 중...';

  @override
  String get home_loading_more => '더 불러오는 중...';

  @override
  String get home_back_to_top_refresh => '맨 위로 이동 및 새로고침';

  @override
  String home_banner_clicked(String targetType, String targetValue) {
    return '배너 클릭: $targetType - $targetValue';
  }

  @override
  String home_product_card_clicked(String name) {
    return '서비스 카드 클릭: $name';
  }

  @override
  String home_recommend_clicked(String name) {
    return '\"판매자에게 보여주기\" 클릭: $name';
  }

  @override
  String get product_recommend_button => '판매자에게 보여주기';

  @override
  String get product_image_loading_failed => '이미지 로딩 실패';

  @override
  String get product_default_name => '상품';

  @override
  String get search_title => '검색';

  @override
  String get search_button => '검색';

  @override
  String get search_hot_keywords => '인기 검색어';

  @override
  String get search_history => '검색 기록';

  @override
  String get search_no_results => '관련 서비스를 찾을 수 없습니다';

  @override
  String search_failed(String error) {
    return '검색 실패: $error';
  }

  @override
  String product_detail_loading_failed(String error) {
    return '로딩 실패: $error';
  }

  @override
  String get product_detail_retry => '다시 시도';

  @override
  String get product_detail_please_wait => '잠시 기다려 주세요...';

  @override
  String get product_detail_contact_seller => '판매자 문의';

  @override
  String get product_detail_verified_label => '인증됨';

  @override
  String get product_detail_published_status => '게시됨';

  @override
  String get product_detail_more => '더보기';

  @override
  String get product_detail_collapse => '접기';

  @override
  String get product_detail_delivery_times => '납품 횟수';

  @override
  String get product_detail_delivery_period => '납품 기간';

  @override
  String get product_detail_buy_now => '바로 구매(1)';

  @override
  String product_detail_buy_now_with_price(String price) {
    return '바로 구매 ¥$price';
  }

  @override
  String get product_detail_faq => '자주 묻는 질문';

  @override
  String get product_detail_case_showcase => '사례 쇼케이스';

  @override
  String get product_detail_no_cases => '사례가 없습니다';

  @override
  String product_detail_reviews(int count) {
    return '리뷰($count)';
  }

  @override
  String get product_detail_view_all => '전체 보기';

  @override
  String get product_detail_no_reviews => '리뷰가 없습니다';

  @override
  String get product_detail_basic_package => '기본';

  @override
  String get product_detail_standard_package => '스탠다드';

  @override
  String get product_detail_premium_package => '프리미엄';

  @override
  String get product_detail_basic_tier => '기본';

  @override
  String get product_detail_standard_tier => '스탠다드';

  @override
  String get product_detail_premium_tier => '프리미엄';

  @override
  String get product_detail_sample_review => '좋은 서비스, 매우 친절합니다';

  @override
  String get product_detail_sample_user => 'Ray123';

  @override
  String get product_reviews_title => '리뷰';

  @override
  String product_reviews_loading_failed(String error) {
    return '로딩 실패: $error';
  }

  @override
  String get product_reviews_retry => '다시 시도';

  @override
  String get product_reviews_no_reviews => '리뷰가 없습니다';

  @override
  String get product_reviews_sample_content => '좋은 서비스, 매우 친절합니다';

  @override
  String product_reviews_years_ago(int count) {
    return '$count년 전';
  }

  @override
  String product_reviews_months_ago(int count) {
    return '$count개월 전';
  }

  @override
  String product_reviews_days_ago(int count) {
    return '$count일 전';
  }

  @override
  String product_reviews_hours_ago(int count) {
    return '$count시간 전';
  }

  @override
  String product_reviews_minutes_ago(int count) {
    return '$count분 전';
  }

  @override
  String get product_reviews_just_now => '방금';

  @override
  String get product_reviews_seller_reply => '판매자 답글';

  @override
  String product_reviews_total_count(int count) {
    return '총 $count개의 리뷰';
  }

  @override
  String get product_reviews_filter_all => '전체';

  @override
  String get product_reviews_filter_with_images => '사진 포함';

  @override
  String get product_reviews_filter_good => '좋은 평가';

  @override
  String get product_reviews_filter_medium => '보통 평가';

  @override
  String get product_reviews_filter_bad => '나쁜 평가';

  @override
  String get seller_profile_default_title => '판매자 프로필';

  @override
  String get seller_profile_seller => '판매자';

  @override
  String get seller_profile_no_description => '소개가 없습니다';

  @override
  String seller_profile_followers(int count) {
    return '$count명의 팔로워';
  }

  @override
  String get seller_profile_followed => '팔로잉';

  @override
  String get seller_profile_follow => '팔로우';

  @override
  String get seller_profile_unfollow_success => '팔로우 취소되었습니다';

  @override
  String get seller_profile_follow_success => '팔로우되었습니다';

  @override
  String seller_profile_chat_failed(String error) {
    return '채팅 생성 실패: $error';
  }

  @override
  String seller_profile_error_occurred(String error) {
    return '오류가 발생했습니다: $error';
  }

  @override
  String get seller_profile_about_merchant => '판매자 정보';

  @override
  String get seller_profile_my_services => '내 서비스';

  @override
  String get seller_profile_no_merchant_info => '판매자 정보가 없습니다';

  @override
  String get seller_profile_member_level => '회원 등급';

  @override
  String get seller_profile_level_two => '2등급 회원';

  @override
  String get seller_profile_seller_rating => '판매자 평점';

  @override
  String get seller_profile_response_time => '응답 시간';

  @override
  String get seller_profile_response_hours => '3시간';

  @override
  String get seller_profile_certification_status => '인증 상태';

  @override
  String get seller_profile_certified => '인증됨';

  @override
  String get seller_profile_not_certified => '미인증';

  @override
  String get seller_profile_no_products => '상품이 없습니다';

  @override
  String get seller_profile_image_load_failed => '이미지 로딩 실패';

  @override
  String get seller_profile_no_image => '이미지가 없습니다';

  @override
  String get seller_profile_title => '내 정보';

  @override
  String get seller_profile_auth_management => '인증 관리';

  @override
  String get seller_profile_my_wallet => '내 지갑';

  @override
  String get seller_profile_time_management => '시간 관리';

  @override
  String get seller_profile_settings => '설정';

  @override
  String get seller_profile_notifications => '알림';

  @override
  String get seller_profile_about_us => '앱 정보';

  @override
  String get seller_profile_mission => '우리의 사명';

  @override
  String get seller_profile_user_name => 'Ray';

  @override
  String get seller_profile_seller_mode_online => '판매자 모드: 온라인';

  @override
  String get seller_profile_seller_mode_offline => '판매자 모드: 오프라인';

  @override
  String get seller_profile_seller_mode => '판매자 모드';

  @override
  String get seller_profile_buyer_mode => '구매자 모드';

  @override
  String get seller_profile_my_orders => '내 주문';

  @override
  String get seller_profile_order_pending => '확인 대기';

  @override
  String get seller_profile_order_processing => '진행 중';

  @override
  String get seller_profile_order_delivered => '배송 완료';

  @override
  String get seller_profile_order_refund => '환불/애프터서비스';

  @override
  String seller_profile_feature_not_implemented(String feature) {
    return '$feature 기능은 아직 구현되지 않았습니다';
  }

  @override
  String get seller_home_loading_failed => '로딩 실패';

  @override
  String get seller_home_no_data => '데이터가 없습니다';

  @override
  String get seller_home_no_store_info => '스토어 정보가 없습니다';

  @override
  String get seller_home_online => '온라인';

  @override
  String get seller_home_offline => '오프라인';

  @override
  String seller_home_completion_rate(String rate) {
    return '완료율 $rate%';
  }

  @override
  String get seller_home_switch_to_buyer => '구매자 모드로 전환';

  @override
  String seller_home_switch_failed(String error) {
    return '구매자 모드로 전환할 수 없습니다: $error';
  }

  @override
  String get seller_home_income => '수익';

  @override
  String get seller_home_view_details => '상세 보기';

  @override
  String get seller_home_total_income => '총 수익';

  @override
  String get seller_home_today_income => '오늘 수익';

  @override
  String get seller_home_pending_settlement => '정산 대기';

  @override
  String get seller_home_orders => '주문';

  @override
  String get seller_home_view_all => '전체 보기';

  @override
  String get seller_home_orders_all => '전체';

  @override
  String get seller_home_orders_pending => '대기 중';

  @override
  String get seller_home_orders_processing => '진행 중';

  @override
  String get seller_home_orders_aftersales => '애프터서비스';

  @override
  String get seller_home_orders_awaiting_delivery => '배송 대기';

  @override
  String get seller_home_orders_completed => '완료';

  @override
  String get seller_home_orders_canceled => '취소됨';

  @override
  String get seller_home_functions => '기능';

  @override
  String get seller_home_wallet => '지갑';

  @override
  String get seller_home_auth_management => '인증 관리';

  @override
  String get seller_home_time_management => '시간 관리';

  @override
  String get seller_home_auto_reply => '자동 응답';

  @override
  String get seller_home_recent_income => '최근 수익';

  @override
  String get seller_home_no_recent_income => '최근 수익 데이터가 없습니다';

  @override
  String get seller_home_no_income_data => '수익 데이터가 없습니다';

  @override
  String get seller_statistics_title => '판매자 통계';

  @override
  String get seller_statistics_seller_homepage => '판매자 홈페이지';

  @override
  String get seller_statistics_heat_value => '인기도';

  @override
  String get seller_statistics_reply_rate => '응답률';

  @override
  String get seller_statistics_completion_rate => '완료율';

  @override
  String get seller_statistics_positive_rate => '긍정 평가율';

  @override
  String get seller_statistics_upgrade_to_next_level => '다음 등급으로 업그레이드';

  @override
  String seller_statistics_become_level3_seller(String days) {
    return '3등급 판매자 $days일';
  }

  @override
  String seller_statistics_complete_orders(String orderNum) {
    return '$orderNum건의 주문 완료';
  }

  @override
  String seller_statistics_profit_amount(String amount) {
    return '$amount원 수익';
  }

  @override
  String get seller_statistics_indicators => '지표';

  @override
  String get seller_statistics_total_earnings => '총 수익';

  @override
  String get seller_statistics_monthly_earnings => '이번 달 수익';

  @override
  String get seller_statistics_total_orders => '총 주문 수';

  @override
  String get seller_statistics_active_orders => '활성 주문 수';

  @override
  String get seller_statistics_pending => '대기 중';

  @override
  String get seller_statistics_incomplete_orders => '미완료 주문 수';

  @override
  String get seller_statistics_pending_completion => '완료 대기';

  @override
  String get seller_statistics_receipt => '영수증';

  @override
  String get seller_statistics_next_delivery_date => '다음 납품일까지';

  @override
  String get seller_statistics_earliest => '가장 빠른';

  @override
  String seller_statistics_loading_failed(String error) {
    return '로딩 실패: $error';
  }

  @override
  String get seller_statistics_retry => '다시 시도';

  @override
  String get seller_auth_management_title => '인증 관리';

  @override
  String get seller_auth_management_certified_items => '인증된 항목';

  @override
  String get seller_auth_management_open_certification => '인증 신청';

  @override
  String get seller_auth_management_no_items => '인증 항목이 없습니다';

  @override
  String get seller_auth_management_unknown_status => '알 수 없는 상태';

  @override
  String get seller_auth_management_certified => '인증됨';

  @override
  String get seller_auth_management_pending => '심사 중';

  @override
  String get seller_auth_management_rejected => '미승인';

  @override
  String get seller_auth_management_not_submitted => '미제출';

  @override
  String get seller_auth_management_server_timeout => '서버 응답 시간 초과';

  @override
  String get seller_auth_management_server_timeout_desc =>
      '서버가 요청을 처리하는 데 너무 오래 걸립니다. 잠시 후 다시 시도해 주세요';

  @override
  String get seller_auth_management_network_error => '네트워크 연결 오류';

  @override
  String get seller_auth_management_network_error_desc =>
      '서버에 연결할 수 없습니다. 네트워크 설정을 확인해 주세요';

  @override
  String get seller_auth_management_loading_failed => '로딩 실패';

  @override
  String get seller_auth_management_unknown_error =>
      '알 수 없는 오류가 발생했습니다. 다시 시도해 주세요';

  @override
  String get seller_auth_management_troubleshooting => '문제 해결 제안:';

  @override
  String get seller_auth_management_check_network => '• 네트워크 연결이 안정적인지 확인하세요';

  @override
  String get seller_auth_management_wait_retry => '• 잠시 후 다시 시도해 주세요';

  @override
  String get seller_auth_management_contact_support =>
      '• 문제가 지속되면 고객센터에 문의해 주세요';

  @override
  String get seller_auth_management_check_wifi =>
      '• Wi-Fi 또는 모바일 데이터 연결을 확인하세요';

  @override
  String get seller_auth_management_switch_network => '• 다른 네트워크로 전환해 보세요';

  @override
  String get seller_auth_management_restart_app => '• 앱을 종료하고 다시 실행해 주세요';

  @override
  String get seller_auth_management_check_connection => '• 네트워크 연결 상태를 확인하세요';

  @override
  String get seller_auth_management_try_later => '• 잠시 후 다시 시도해 주세요';

  @override
  String get seller_auth_management_contact_tech => '• 문제가 지속되면 기술 지원에 문의해 주세요';

  @override
  String get seller_auth_management_reload => '다시 로드';

  @override
  String get seller_auth_management_back => '뒤로';

  @override
  String seller_auth_application_title(String type) {
    return '$type 인증';
  }

  @override
  String seller_auth_application_desc(String type) {
    return '$type 인증 설명';
  }

  @override
  String get seller_auth_application_review_time =>
      '인증 심사는 일반적으로 영업일 기준 1~3일이 소요됩니다. 기다려 주세요.';

  @override
  String get seller_auth_application_basic_info => '기본 정보';

  @override
  String get seller_auth_application_company_name => '회사명';

  @override
  String get seller_auth_application_company_name_hint => '회사 정식 명칭을 입력해 주세요';

  @override
  String get seller_auth_application_company_name_required => '회사명을 입력해 주세요';

  @override
  String get seller_auth_application_credit_code => '사업자등록번호';

  @override
  String get seller_auth_application_credit_code_hint =>
      '18자리 사업자등록번호를 입력해 주세요';

  @override
  String get seller_auth_application_credit_code_required => '사업자등록번호를 입력해 주세요';

  @override
  String get seller_auth_application_credit_code_invalid =>
      '사업자등록번호는 18자리여야 합니다';

  @override
  String get seller_auth_application_company_intro => '회사 소개';

  @override
  String get seller_auth_application_company_intro_hint =>
      '회사의 사업 내용과 현황을 간략히 설명해 주세요';

  @override
  String get seller_auth_application_real_name => '이름';

  @override
  String get seller_auth_application_real_name_hint => '실명을 입력해 주세요';

  @override
  String get seller_auth_application_real_name_required => '이름을 입력해 주세요';

  @override
  String get seller_auth_application_id_number => '신분증 번호';

  @override
  String get seller_auth_application_id_number_hint => '18자리 신분증 번호를 입력해 주세요';

  @override
  String get seller_auth_application_id_number_required => '신분증 번호를 입력해 주세요';

  @override
  String get seller_auth_application_id_number_invalid => '신분증 번호는 18자리여야 합니다';

  @override
  String get seller_auth_application_school_name => '학교명';

  @override
  String get seller_auth_application_school_name_hint => '학교 정식 명칭을 입력해 주세요';

  @override
  String get seller_auth_application_school_name_required => '학교명을 입력해 주세요';

  @override
  String get seller_auth_application_degree => '학력/학위';

  @override
  String get seller_auth_application_degree_hint => '예: 학사, 석사 등';

  @override
  String get seller_auth_application_degree_required => '학력/학위를 입력해 주세요';

  @override
  String get seller_auth_application_major => '전공';

  @override
  String get seller_auth_application_major_hint => '전공명을 입력해 주세요';

  @override
  String get seller_auth_application_profession => '직업/직위';

  @override
  String get seller_auth_application_profession_hint => '직업 또는 직위를 입력해 주세요';

  @override
  String get seller_auth_application_profession_required => '직업/직위를 입력해 주세요';

  @override
  String get seller_auth_application_cert_number => '자격증 번호';

  @override
  String get seller_auth_application_cert_number_hint => '전문 자격증 번호를 입력해 주세요';

  @override
  String get seller_auth_application_work_experience => '업무 경험';

  @override
  String get seller_auth_application_work_experience_hint =>
      '업무 경험을 간략히 설명해 주세요';

  @override
  String get seller_auth_application_auth_name => '인증명';

  @override
  String get seller_auth_application_auth_name_hint => '인증명을 입력해 주세요';

  @override
  String get seller_auth_application_auth_name_required => '인증명을 입력해 주세요';

  @override
  String get seller_auth_application_auth_identifier => '인증 식별자';

  @override
  String get seller_auth_application_auth_identifier_hint =>
      '인증 식별자 또는 번호를 입력해 주세요';

  @override
  String get seller_auth_application_auth_description => '인증 설명';

  @override
  String get seller_auth_application_auth_description_hint => '인증 내용을 설명해 주세요';

  @override
  String get seller_auth_application_upload_materials => '증빙 서류 업로드';

  @override
  String get seller_auth_application_upload_file => '파일 업로드';

  @override
  String seller_auth_application_selected_files(int count) {
    return '$count개 파일 선택됨';
  }

  @override
  String get seller_auth_application_selected_images => '선택된 이미지:';

  @override
  String get seller_auth_application_load_failed => '로딩 실패';

  @override
  String get seller_auth_application_id_upload_hint =>
      '신분증 앞뒤 사진을 선명하게 업로드해 주세요. 정보가 명확히 보여야 하며 가리거나 수정해서는 안 됩니다';

  @override
  String get seller_auth_application_education_upload_hint =>
      '학력증명서, 학위증명서 등 완전한 정보가 포함된 증빙 서류를 업로드해 주세요';

  @override
  String get seller_auth_application_profession_upload_hint =>
      '전문 자격증, 기술 자격증 등 증빙 서류를 업로드해 주세요';

  @override
  String get seller_auth_application_company_upload_hint =>
      '사업자등록증, 법인인감증명서 등 기업 자격 증빙 서류를 업로드해 주세요';

  @override
  String get seller_auth_application_default_upload_hint =>
      '관련 증빙 서류를 업로드해 주세요. 이미지가 선명하고 정보가 완전해야 합니다';

  @override
  String get seller_auth_application_agreement_read => '읽고 동의합니다';

  @override
  String get seller_auth_application_agreement_link => '《인증 서비스 이용약관》';

  @override
  String get seller_auth_application_agreement_guarantee =>
      ', 제공한 정보가 사실임을 보증합니다';

  @override
  String get seller_auth_application_agreement_title => '인증 서비스 이용약관';

  @override
  String get seller_auth_application_agreement_content =>
      '본 약관은 귀하와 DSKK 플랫폼 간의 인증 서비스에 관한 법적 계약입니다. 아래 조항을 주의 깊게 읽어 본 약관의 모든 권리와 의무를 충분히 이해하시기 바랍니다.\n\n1. 서비스 내용\nDSKK 플랫폼은 귀하가 제공하는 신원, 자격 등의 정보의 진실성을 검증하고 플랫폼에서의 신뢰도를 높이기 위한 인증 서비스를 제공합니다.\n\n2. 이용자 의무\n1. 귀하는 진실하고 정확하며 완전한 인증 정보와 자료를 제공해야 합니다.\n2. 귀하는 제공하는 인증 자료가 제3자의 합법적인 권리와 이익을 침해하지 않도록 해야 합니다.\n\n3. 플랫폼 권리 및 의무\n1. 플랫폼은 귀하가 제공한 인증 정보와 자료를 심사할 권리가 있습니다.\n2. 플랫폼은 합리적인 시간 내에 심사를 완료하고 귀하에게 결과를 알립니다.';

  @override
  String get seller_auth_application_agreement_close => '닫기';

  @override
  String get seller_auth_application_agreement_agree => '동의';

  @override
  String get seller_auth_application_submit => '인증 신청 제출';

  @override
  String get seller_auth_application_check_form => '양식이 올바르게 작성되었는지 확인해 주세요';

  @override
  String get seller_auth_application_submit_success => '제출 성공';

  @override
  String get seller_auth_application_submit_success_desc =>
      '인증 신청이 제출되었습니다. 영업일 기준 1~3일 내에 심사를 완료해 드리겠습니다. 기다려 주세요.';

  @override
  String get seller_auth_application_ok => '확인';

  @override
  String seller_auth_application_select_file_failed(String error) {
    return '파일 선택 실패: $error';
  }

  @override
  String get product_management_title => '상품 관리';

  @override
  String get product_management_tab_on_sale => '판매 중';

  @override
  String get product_management_tab_draft => '임시저장';

  @override
  String get product_management_tab_off_shelf => '판매 중단';

  @override
  String get product_management_action_off_shelf => '판매 중단';

  @override
  String get product_management_action_on_shelf => '판매 시작';

  @override
  String get product_management_action_edit => '수정';

  @override
  String get product_management_action_delete => '삭제';

  @override
  String get product_management_action_publish => '게시';

  @override
  String get product_management_action_resubmit => '재제출';

  @override
  String get product_management_status_reviewing => '심사 중';

  @override
  String get product_management_status_rejected => '심사 실패';

  @override
  String get product_management_status_on_shelf => '판매 중';

  @override
  String get product_management_status_off_shelf => '판매 중단';

  @override
  String get product_management_status_draft => '임시저장';

  @override
  String get product_management_status_waiting_review => '심사 대기';

  @override
  String get product_management_status_unknown => '알 수 없음';

  @override
  String get product_management_stock_label => '재고';

  @override
  String get product_management_sales_label => '판매량';

  @override
  String get product_management_create_product => '상품 등록';

  @override
  String get product_management_no_more_products => '더 이상 상품이 없습니다';

  @override
  String get product_management_empty_on_sale => '판매 중인 상품이 없습니다';

  @override
  String get product_management_empty_draft => '임시저장된 상품이 없습니다';

  @override
  String get product_management_empty_off_shelf => '판매 중단된 상품이 없습니다';

  @override
  String get product_management_empty_default => '상품 데이터가 없습니다';

  @override
  String get product_management_draft_preview_hint =>
      '임시저장된 상품은 게시 후에 미리보기가 가능합니다';

  @override
  String get product_management_confirm_off_shelf_title => '판매 중단 확인';

  @override
  String product_management_confirm_off_shelf_message(String name) {
    return '상품 \"$name\"을(를) 판매 중단하시겠습니까?';
  }

  @override
  String get product_management_confirm_off_shelf_desc => '판매 중단 후:';

  @override
  String get product_management_confirm_off_shelf_point1 =>
      '• 구매자가 이 상품을 보거나 구매할 수 없습니다';

  @override
  String get product_management_confirm_off_shelf_point2 =>
      '• 언제든지 다시 판매를 시작할 수 있습니다';

  @override
  String get product_management_confirm_off_shelf_point3 => '• 상품 데이터는 보존됩니다';

  @override
  String get product_management_confirm_delete_title => '삭제 확인';

  @override
  String get product_management_confirm_delete_message =>
      '이 상품을 삭제하시겠습니까? 이 작업은 취소할 수 없습니다.';

  @override
  String get product_management_cancel => '취소';

  @override
  String get product_management_confirm => '판매 중단 확인';

  @override
  String get product_management_delete => '삭제';

  @override
  String get product_edit_title_create => '상품 등록';

  @override
  String get product_edit_title_edit => '상품 수정';

  @override
  String get product_edit_basic_info => '기본 정보';

  @override
  String get product_edit_product_name => '상품명';

  @override
  String get product_edit_product_name_hint => '상품명을 입력해 주세요';

  @override
  String get product_edit_product_description => '상품 설명';

  @override
  String get product_edit_product_description_hint => '상품 설명을 입력해 주세요';

  @override
  String get product_edit_product_price => '상품 가격';

  @override
  String get product_edit_product_images => '상품 이미지';

  @override
  String get product_edit_add_image => '이미지 추가';

  @override
  String get product_edit_uploading => '업로드 중...';

  @override
  String get product_edit_service_tiers => '서비스 등급 설정';

  @override
  String get product_edit_detail_intro => '상세 소개';

  @override
  String get product_edit_save_draft => '임시저장';

  @override
  String get product_edit_publish_product => '상품 게시';

  @override
  String get product_edit_preview_product => '상품 미리보기';

  @override
  String get product_edit_at_least_one_image => '상품 이미지를 최소 한 장 업로드해 주세요';

  @override
  String get product_edit_save_draft_dialog_title => '임시저장';

  @override
  String get product_edit_save_draft_dialog_message => '임시저장으로 저장하시겠습니까?';

  @override
  String get product_edit_save_draft_dialog_confirm => '저장';

  @override
  String get product_edit_edit_attribute => '상품 속성 편집';

  @override
  String get product_edit_validation_name_required => '상품명을 입력해 주세요';

  @override
  String get product_edit_validation_description_required => '상품 설명을 입력해 주세요';

  @override
  String get product_edit_validation_image_required =>
      '상품 이미지를 최소 한 장 업로드해 주세요';

  @override
  String get product_preview_current_seller => '현재 판매자';

  @override
  String get product_preview_seller_user => '판매자 사용자';

  @override
  String get product_edit_success_cases => '성공 사례';

  @override
  String get product_edit_add_success_case => '성공 사례 추가';

  @override
  String get product_edit_edit_success_case => '성공 사례 편집';

  @override
  String product_edit_uploading_progress(int uploaded, int total) {
    return '업로드 중 $uploaded/$total';
  }

  @override
  String get product_edit_please_enter_label => '정보 레이블을 입력해 주세요';

  @override
  String get product_edit_please_enter_attribute_name => '속성명을 입력해 주세요';

  @override
  String get product_edit_attribute_name_hint => '속성명을 입력해 주세요';

  @override
  String get product_edit_placeholder_hint => '예: 색상 선택, 모델 번호 입력';

  @override
  String get product_edit_placeholder_label => '플레이스홀더 텍스트';

  @override
  String get product_edit_product_preview_title => '상품 미리보기';

  @override
  String get product_edit_publish_service => '서비스 게시';

  @override
  String get product_edit_edit_service => '서비스 수정';

  @override
  String product_edit_max_characters(int max) {
    return '최대 $max자';
  }

  @override
  String get after_sales_review_title => '애프터서비스 심사';

  @override
  String get after_sales_detail_title => '애프터서비스 상세';

  @override
  String get after_sales_refresh => '새로고침';

  @override
  String get after_sales_no_pending => '대기 중인 애프터서비스 신청이 없습니다';

  @override
  String get after_sales_load_failed => '로딩 실패. 다시 시도해 주세요';

  @override
  String get after_sales_not_found => '해당 애프터서비스 신청을 찾을 수 없습니다';

  @override
  String get after_sales_order_number => '주문 번호';

  @override
  String get after_sales_apply_type => '신청 유형';

  @override
  String get after_sales_apply_time => '신청 시간';

  @override
  String get after_sales_refund_amount => '환불 금액';

  @override
  String get after_sales_refund_type => '환불 유형';

  @override
  String get after_sales_apply_reason => '신청 사유';

  @override
  String get after_sales_image_evidence => '이미지 증거';

  @override
  String get after_sales_image_view => '이미지 보기';

  @override
  String get after_sales_image_load_failed => '이미지 로딩 실패';

  @override
  String get after_sales_reject => '거부';

  @override
  String get after_sales_agree => '승인';

  @override
  String get after_sales_reject_application => '신청 거부';

  @override
  String get after_sales_agree_application => '신청 승인';

  @override
  String get after_sales_confirm => '확인';

  @override
  String get after_sales_cancel => '취소';

  @override
  String get after_sales_confirm_title => '확인';

  @override
  String get after_sales_confirm_message => '이 애프터서비스 신청을 승인하시겠습니까?';

  @override
  String get after_sales_reject_reason => '거부 사유';

  @override
  String get after_sales_reject_reason_hint => '거부 사유를 입력해 주세요';

  @override
  String get after_sales_reject_reason_required => '거부 사유를 입력해 주세요';

  @override
  String get after_sales_type_refund_only => '환불만';

  @override
  String get after_sales_type_refund_return => '반품 및 환불';

  @override
  String get after_sales_type_unknown => '알 수 없는 유형';

  @override
  String get after_sales_status_wait_audit => '심사 대기';

  @override
  String get after_sales_status_refused => '거부됨';

  @override
  String get after_sales_status_audit_pass => '승인됨';

  @override
  String get after_sales_status_buyer_shipped => '구매자 배송 완료';

  @override
  String get after_sales_status_seller_received => '판매자 수령 완료';

  @override
  String get after_sales_status_finished => '완료';

  @override
  String get after_sales_status_canceled => '취소됨';

  @override
  String get after_sales_status_unknown => '알 수 없는 상태';

  @override
  String get time_management_title => '시간 관리';

  @override
  String get time_management_current_status => '현재 상태';

  @override
  String get time_management_online => '온라인';

  @override
  String get time_management_offline => '오프라인';

  @override
  String get time_management_online_status_description => '온라인 상태 설명';

  @override
  String get time_management_offline_status_description => '오프라인 상태 설명';

  @override
  String get time_management_online_description =>
      '현재 온라인 상태입니다. 구매자가 메시지를 보낼 수 있으며 새 메시지 알림을 받게 됩니다. 구매자 메시지에 신속히 응답해 주세요. 좋은 응답률은 서비스 품질 점수 향상에 도움이 됩니다.';

  @override
  String get time_management_offline_description =>
      '현재 오프라인 상태입니다. 구매자는 여전히 메시지를 보낼 수 있지만 시스템이 일시적으로 자리를 비웠음을 알립니다. 새 메시지 알림은 계속 받을 수 있지만 즉시 응답하지 못할 수 있습니다. 장시간 오프라인 상태를 유지하면 주문 처리 효율에 영향을 줄 수 있습니다.';

  @override
  String get time_management_save_settings => '설정 저장';

  @override
  String get time_management_settings_saved => '설정이 저장되었습니다';

  @override
  String get time_management_load_failed => '로딩 실패';

  @override
  String get time_management_retry => '다시 시도';

  @override
  String get time_management_unknown_status => '알 수 없는 상태';

  @override
  String get auto_reply_title => '자동 응답 설정';

  @override
  String get auto_reply_enable => '자동 응답';

  @override
  String get auto_reply_content => '응답 내용';

  @override
  String get auto_reply_content_hint => '자동 응답 내용을 입력해 주세요';

  @override
  String get auto_reply_content_description =>
      '고객이 메시지를 보내면 시스템이 이 내용으로 자동으로 응답합니다';

  @override
  String get auto_reply_save_settings => '설정 저장';

  @override
  String get auto_reply_settings_saved => '설정이 저장되었습니다';

  @override
  String get auto_reply_content_required => '응답 내용을 입력해 주세요';

  @override
  String get auto_reply_load_failed => '로딩 실패. 다시 시도해 주세요';

  @override
  String get order_delivery_title => '주문 납품';

  @override
  String order_delivery_title_with_sn(String orderSn) {
    return '주문 납품: $orderSn';
  }

  @override
  String get order_delivery_submitting => '납품 내용 제출 중...';

  @override
  String get order_delivery_load_failed => '로딩 실패. 다시 시도해 주세요';

  @override
  String get order_delivery_instruction_title => '주문 납품 안내';

  @override
  String get order_delivery_instruction_content =>
      '이 주문에 대한 납품 내용을 제출해 주세요. 구매자가 제공하는 서비스나 상품을 명확히 이해할 수 있도록 상세한 설명과 관련 파일을 첨부할 수 있습니다.';

  @override
  String get order_delivery_content_label => '납품 내용 설명:';

  @override
  String get order_delivery_content_hint => '납품 내용을 설명해 주세요...';

  @override
  String get order_delivery_attachments_label => '첨부 파일:';

  @override
  String get order_delivery_submit_button => '납품 제출';

  @override
  String get order_delivery_content_required => '납품 내용 설명을 입력해 주세요';

  @override
  String get order_delivery_submit_success => '납품 내용이 성공적으로 제출되었습니다';

  @override
  String get order_delivery_logistics_company => '물류 업체';

  @override
  String get order_delivery_tracking_number => '운송장 번호';

  @override
  String get order_delivery_shipping_address => '발송 주소';

  @override
  String get order_delivery_receiving_address => '수령 주소';

  @override
  String get order_delivery_status_pending => '배송 대기';

  @override
  String get order_delivery_status_shipped => '배송 완료';

  @override
  String get order_delivery_status_received => '수령 완료';

  @override
  String get order_delivery_status_in_transit => '배송 중';

  @override
  String get order_delivery_confirm_shipment => '발송 확인';

  @override
  String get order_delivery_view_details => '상세 보기';

  @override
  String get order_delivery_no_pending_orders => '배송 대기 주문이 없습니다';

  @override
  String get notification_center_title => '알림 센터';

  @override
  String get notification_tab_all => '전체';

  @override
  String get notification_tab_order => '주문';

  @override
  String get notification_tab_system => '시스템';

  @override
  String get notification_tab_refund => '애프터서비스';

  @override
  String get notification_tab_message => '메시지';

  @override
  String get notification_type_order => '주문 알림';

  @override
  String get notification_type_system => '시스템 알림';

  @override
  String get notification_type_refund => '애프터서비스 알림';

  @override
  String get notification_type_message => '메시지 알림';

  @override
  String get notification_type_review => '리뷰 알림';

  @override
  String get notification_type_authentication => '인증 알림';

  @override
  String get notification_type_other => '기타 알림';

  @override
  String get notification_status_unread => '읽지 않음';

  @override
  String get notification_status_read => '읽음';

  @override
  String get notification_mark_all_read => '전체 읽음으로 표시';

  @override
  String get notification_empty_all => '알림이 없습니다';

  @override
  String get notification_empty_order => '주문 알림이 없습니다';

  @override
  String get notification_empty_system => '시스템 알림이 없습니다';

  @override
  String get notification_empty_refund => '애프터서비스 알림이 없습니다';

  @override
  String get notification_empty_message => '메시지 알림이 없습니다';

  @override
  String get notification_empty_review => '리뷰 알림이 없습니다';

  @override
  String get notification_empty_authentication => '인증 알림이 없습니다';

  @override
  String get notification_empty_other => '기타 알림이 없습니다';

  @override
  String get notification_empty_generic => '알림이 없습니다';

  @override
  String get notification_refresh => '새로고침';

  @override
  String get notification_retry => '다시 시도';

  @override
  String notification_load_failed(String error) {
    return '알림 센터를 불러오지 못했습니다: $error';
  }

  @override
  String get notification_detail_title => '알림 상세';

  @override
  String get notification_detail_view => '상세 보기';

  @override
  String get notification_detail_close => '닫기';

  @override
  String get notification_click_to_view => '탭하여 상세 보기';

  @override
  String get notification_default_title => '알림';

  @override
  String get notification_time_just_now => '방금';

  @override
  String notification_time_minutes_ago(int minutes) {
    return '$minutes분 전';
  }

  @override
  String notification_time_hours_ago(int hours) {
    return '$hours시간 전';
  }

  @override
  String notification_time_days_ago(int days) {
    return '$days일 전';
  }

  @override
  String notification_time_months_ago(int months) {
    return '$months개월 전';
  }

  @override
  String get materialsInfo => '자료 정보';

  @override
  String get buyerSubmittedMaterials => '구매자 제출 자료';

  @override
  String get sellerDeliveryContent => '판매자 납품 내용';

  @override
  String get noBuyerMaterials => '구매자가 제출한 자료가 없습니다';

  @override
  String get noSellerDelivery => '판매자가 아직 납품하지 않았습니다';

  @override
  String get attachments => '첨부:';

  @override
  String get deliveryFiles => '납품 파일:';

  @override
  String get deliveryDescription => '납품 설명';

  @override
  String get tapToPreview => '탭하여 미리보기';

  @override
  String get tapToOpen => '탭하여 열기';

  @override
  String get downloadFile => '파일 다운로드';

  @override
  String get storagePermissionDenied => '저장소 권한이 거부되었습니다';

  @override
  String get cancelDownload => '다운로드 취소';

  @override
  String get pageLoadFailed => '페이지를 불러오지 못했습니다';

  @override
  String get openFile => '파일 열기';

  @override
  String get downloaded => '다운로드됨';

  @override
  String get downloadCompleted => '다운로드 완료';

  @override
  String get downloadFailed => '다운로드 실패';

  @override
  String get openFileFailed => '파일을 열지 못했습니다';

  @override
  String get storagePermissionRequired => '파일을 다운로드하려면 저장소 권한이 필요합니다';

  @override
  String get pdfLoadFailed => 'PDF를 불러오지 못했습니다';

  @override
  String get retry => '다시 시도';

  @override
  String product_detail_translated_from(String language) {
    return '$language에서 번역됨';
  }

  @override
  String get product_detail_translation_auto => '자동 번역';

  @override
  String get product_detail_show_original => '원문 보기';

  @override
  String get order_status_awaiting_payment => '결제 대기';

  @override
  String get order_status_awaiting_submission => '요건 제출 대기';

  @override
  String get order_status_buy_awaiting_submission => '자료 재업로드 대기';

  @override
  String get order_status_awaiting_start => '시작 대기';

  @override
  String get order_status_awaiting_delivery => '배송 대기';

  @override
  String get order_status_awaiting_confirmation => '수령 확인 대기';

  @override
  String get order_status_awaiting_evaluation => '리뷰 대기';

  @override
  String get order_status_completed => '완료됨';

  @override
  String get order_status_canceled => '취소됨';

  @override
  String get order_status_after_sale => '애프터서비스 중';

  @override
  String get order_status_unknown => '알 수 없는 상태';

  @override
  String get order_action_cancel => '주문 취소';

  @override
  String get order_action_go_pay => '결제하기';

  @override
  String get order_action_submit_materials => '자료 제출';

  @override
  String get order_action_contact_support => '고객 서비스 문의';

  @override
  String get order_action_view_feedback => '피드백 보기';

  @override
  String get order_action_remind_delivery => '발송 독촉';

  @override
  String get order_action_platform_intervention => '플랫폼 조정';

  @override
  String get order_action_view_delivery => '교부 내용 보기';

  @override
  String get order_action_apply_after_sale => '애프터서비스 신청';

  @override
  String get order_action_confirm_receipt => '수령 확인';

  @override
  String get order_action_view_logistics => '물류 조회';

  @override
  String get order_action_go_evaluate => '리뷰 작성';

  @override
  String get order_action_apply_rework => '재작업 신청';

  @override
  String get order_action_delete_order => '주문 삭제';

  @override
  String get order_action_view_order => '주문 보기';

  @override
  String get order_action_view_details => '상세 보기';

  @override
  String get order_action_processing => '처리 중...';

  @override
  String get order_confirm_cancel_title => '주문 취소';

  @override
  String get order_confirm_cancel_content => '이 주문을 취소하시겠습니까?';

  @override
  String get order_confirm_receipt_title => '수령 확인';

  @override
  String get order_confirm_receipt_content => '상품을 수령하셨습니까?';

  @override
  String get order_confirm_delete_title => '주문 삭제';

  @override
  String get order_confirm_delete_content =>
      '이 주문을 삭제하시겠습니까? 삭제 후에는 복구할 수 없습니다.';

  @override
  String get order_dialog_cancel => '취소';

  @override
  String get order_dialog_confirm => '확인';

  @override
  String get order_dialog_close => '닫기';

  @override
  String get order_dialog_submit => '신청 제출';

  @override
  String get order_snackbar_connecting_support => '고객센터 연결 중...';

  @override
  String get order_snackbar_feedback_in_progress => '판매자 피드백 보기 기능 개발 중';

  @override
  String get order_snackbar_reminded_delivery => '판매자에게 발송을 독촉했습니다';

  @override
  String order_snackbar_nav_failed(String error) {
    return '이동 실패: $error';
  }

  @override
  String get order_snackbar_no_items_after_sale =>
      '오류: 상품이 없는 주문에 애프터서비스를 신청할 수 없습니다';

  @override
  String get order_snackbar_no_items_evaluate =>
      '오류: 상품이 없는 주문에 리뷰를 작성할 수 없습니다';

  @override
  String order_snackbar_operation_failed(String error) {
    return '작업 실패: $error';
  }

  @override
  String get order_dialog_data_not_loaded =>
      '데이터 로딩이 완료되지 않았습니다. 잠시 후 다시 시도해 주세요';

  @override
  String get order_dialog_view_delivery_title => '교부 내용 보기';

  @override
  String get order_dialog_seller_delivery_content => '판매자 교부 내용:';

  @override
  String get order_dialog_buyer_materials => '구매자 제출 자료:';

  @override
  String get order_dialog_no_seller_delivery => '판매자가 아직 내용을 교부하지 않았습니다';

  @override
  String get order_dialog_no_buyer_materials => '구매자가 제출한 자료가 없습니다';

  @override
  String order_dialog_delivery_note(String content) {
    return '교부 안내: $content';
  }

  @override
  String get order_dialog_delivery_files => '교부 파일:';

  @override
  String get order_intervention_title => '플랫폼 조정 신청';

  @override
  String get order_intervention_desc =>
      '해결되지 않는 분쟁이 있으신가요? 플랫폼 고객센터가 24시간 내에 개입합니다.';

  @override
  String get order_intervention_problem_type => '문제 유형:';

  @override
  String get order_intervention_problem_desc => '문제 설명:';

  @override
  String get order_intervention_problem_hint => '문제를 자세히 설명해 주세요...';

  @override
  String get order_intervention_validation_empty => '문제 설명을 입력해 주세요';

  @override
  String get order_intervention_validation_min => '문제 설명은 최소 10자 이상이어야 합니다';

  @override
  String get order_intervention_tip =>
      '알림: 제출 후 취소할 수 없습니다. 각 주문당 최대 2회 신청 가능합니다.';

  @override
  String get order_intervention_reason_communication => '소통 문제';

  @override
  String get order_intervention_reason_quality => '품질 분쟁';

  @override
  String get order_intervention_reason_delivery => '교부 문제';

  @override
  String get order_intervention_reason_refund => '환불 분쟁';

  @override
  String get order_intervention_reason_service => '서비스 태도';

  @override
  String get order_intervention_reason_other => '기타 문제';

  @override
  String get order_intervention_submitting => '신청 제출 중...';

  @override
  String order_intervention_failed(String error) {
    return '신청 실패: $error';
  }

  @override
  String get order_demand_replenishment_title => '보충 자료 신청';

  @override
  String get order_demand_reform_title => '재작업 신청';

  @override
  String get order_demand_replenishment_desc =>
      '판매자에게 추가 자료나 설명이 필요하다면 자세히 설명해 주세요.';

  @override
  String get order_demand_reform_desc =>
      '교부 결과가 만족스럽지 않으면 재작업을 신청할 수 있습니다. 구체적인 문제를 설명해 주세요.';

  @override
  String get order_demand_detail_label => '상세 내용:';

  @override
  String get order_demand_replenishment_hint => '필요한 자료나 정보를 자세히 설명해 주세요...';

  @override
  String get order_demand_reform_hint => '재작업이 필요한 사유와 요건을 자세히 설명해 주세요...';

  @override
  String get order_demand_validation_empty => '상세 내용을 입력해 주세요';

  @override
  String get order_demand_validation_min => '설명은 최소 10자 이상이어야 합니다';

  @override
  String get order_demand_replenishment_tip =>
      '알림: 판매자가 신청 접수 후 24시간 내에 관련 자료를 보충합니다.';

  @override
  String get order_demand_reform_tip => '알림: 재작업 신청 제출 후 판매자가 주문을 다시 처리합니다.';

  @override
  String get order_demand_reason_incomplete => '정보 불완전';

  @override
  String get order_demand_reason_unclear => '요건 불명확';

  @override
  String get order_demand_reason_additional => '추가 설명 필요';

  @override
  String get order_demand_reason_reference => '참고 자료 필요';

  @override
  String get order_demand_reason_other => '기타 사유';

  @override
  String get order_demand_reason_quality => '품질 불만족';

  @override
  String get order_demand_reason_requirement => '요건 미충족';

  @override
  String get order_demand_reason_content_incomplete => '내용 불완전';

  @override
  String get order_demand_reason_error => '오류 포함';

  @override
  String get order_demand_submitting_replenishment => '보충 자료 신청 제출 중...';

  @override
  String get order_demand_submitting_reform => '재작업 신청 제출 중...';

  @override
  String order_demand_failed(String error) {
    return '신청 실패: $error';
  }

  @override
  String order_demand_edit_info_auto(int current, int remaining) {
    return '현재 $current회 교부 완료, 무료 수정 $remaining회 남음 (자동 승인)';
  }

  @override
  String order_demand_edit_info_approval(int current) {
    return '현재 $current회 교부 완료, 무료 수정 횟수 소진, 판매자 승인 필요';
  }

  @override
  String get order_info_title => '주문 정보';

  @override
  String get order_info_order_number => '주문 번호: ';

  @override
  String get order_info_order_time => '주문 시간: ';

  @override
  String get order_info_pay_time => '결제 시간: ';

  @override
  String get order_info_complete_time => '완료 시간: ';

  @override
  String get order_info_remark => '주문 메모: ';

  @override
  String get order_items_title => '상품 정보';

  @override
  String get order_items_empty => '상품 정보가 없습니다';

  @override
  String order_items_count(int count) {
    return '$count개';
  }

  @override
  String get order_price_title => '가격 상세';

  @override
  String get order_price_total => '상품 합계';

  @override
  String get order_price_shipping => '배송비';

  @override
  String get order_price_discount => '할인 금액';

  @override
  String get order_price_paid => '실제 결제 금액';

  @override
  String get order_price_total_amount => '상품 총액';

  @override
  String get order_price_actual_paid => '실제 결제 금액';

  @override
  String get order_requirement_title => '요건 제출';

  @override
  String order_requirement_service_selected(String skuName, String price) {
    return '선택한 서비스: $skuName - ¥$price';
  }

  @override
  String get order_requirement_q1 => '1. 요건을 자세히 설명해 주세요';

  @override
  String get order_requirement_q1_hint => '구체적인 요건, 기대 결과 등을 최대한 자세히 설명해 주세요';

  @override
  String get order_requirement_q1_helper => '참고 자료가 있으면 아래 첨부파일 영역에 업로드해 주세요';

  @override
  String get order_requirement_q2 => '2. 추가 설명 (선택 사항)';

  @override
  String get order_requirement_q2_hint => '기타 추가 사항이나 특별 요건이 있으면 여기에 입력해 주세요';

  @override
  String get order_requirement_warning =>
      '요건을 꼼꼼히 작성해 주세요. 제출 후 판매자가 요건에 따라 서비스를 시작합니다';

  @override
  String get order_requirement_attachment_title => '첨부파일 업로드';

  @override
  String order_requirement_attachment_limit(int maxCount, int maxSize) {
    return '최대 $maxCount개 파일, 각 파일 최대 ${maxSize}MB';
  }

  @override
  String get order_requirement_add => '추가';

  @override
  String get order_requirement_click_select_file => '여기를 탭하여 파일 선택';

  @override
  String get order_requirement_confirm_submit => '제출 확인';

  @override
  String get order_requirement_wait_upload => '파일 업로드 완료까지 기다려 주세요';

  @override
  String get order_requirement_upload_failed_title => '파일 업로드 실패';

  @override
  String order_requirement_upload_failed_count(int count) {
    return '$count개 파일 업로드 실패. 재시도하시겠습니까?';
  }

  @override
  String get order_requirement_remove_failed => '실패한 파일 제거';

  @override
  String get order_requirement_retry_upload => '업로드 재시도';

  @override
  String get order_requirement_error_product_id => '오류: 상품 ID를 가져올 수 없습니다';

  @override
  String get order_requirement_load_draft_failed => '초안 불러오기 실패';

  @override
  String get order_requirement_save_draft_failed => '초안 저장 실패';

  @override
  String order_requirement_max_files(int count) {
    return '첨부파일은 최대 $count개까지 가능합니다';
  }

  @override
  String order_requirement_pick_failed(String error) {
    return '파일 선택 실패: $error';
  }

  @override
  String get order_requirement_default_service => '기본 서비스';

  @override
  String get order_evaluation_title => '상품 리뷰';

  @override
  String get order_evaluation_hint => '이용 경험을 공유해 주세요~';

  @override
  String get order_evaluation_add_images => '이미지 추가 (최대 9장)';

  @override
  String get order_evaluation_anonymous => '익명 리뷰';

  @override
  String get order_evaluation_submit => '리뷰 제출';

  @override
  String get order_evaluation_error_no_item => '오류: 리뷰할 상품 항목을 찾을 수 없습니다';

  @override
  String get order_evaluation_max_images => '최대 9장까지 업로드 가능합니다';

  @override
  String order_evaluation_success_count(int count, String ratio) {
    return '$count장 이미지 처리 완료, 평균 $ratio% 압축';
  }

  @override
  String order_evaluation_failed_count(int count) {
    return '$count장의 이미지 처리 실패';
  }

  @override
  String order_evaluation_pick_failed(String error) {
    return '이미지 선택 실패: $error';
  }

  @override
  String get order_evaluation_processing => '처리 중...';

  @override
  String get order_evaluation_page_title => '주문 리뷰 작성';

  @override
  String get order_delivery_not_satisfied => '교부 내용이 만족스럽지 않으신가요?';

  @override
  String get order_delivery_communicate_tip =>
      '교부 횟수가 부족한 경우 먼저 판매자와 추가 교부 여부를 협의하세요';

  @override
  String get order_delivery_supplement => '보충 요청';

  @override
  String get order_delivery_remake => '재제작 요청';

  @override
  String get order_delivery_refund => '환불 요청';

  @override
  String get order_delivery_unknown_file => '알 수 없는 파일';

  @override
  String order_item_delivery_days(int days) {
    return '교부 기간: $days일';
  }

  @override
  String order_item_edit_count(int count) {
    return '수정 횟수: $count회';
  }

  @override
  String get order_countdown_expired => '시간 초과';

  @override
  String order_countdown_days_hours(int days, int hours) {
    return '$days일 $hours시간';
  }

  @override
  String order_countdown_hours_minutes(int hours, int minutes) {
    return '$hours시간 $minutes분';
  }

  @override
  String order_countdown_minutes(int minutes) {
    return '$minutes분';
  }

  @override
  String order_countdown_seconds(int seconds) {
    return '$seconds초';
  }

  @override
  String order_countdown_days(int days) {
    return '$days일';
  }

  @override
  String order_countdown_minutes_seconds(int minutes, int seconds) {
    return '$minutes분 $seconds초';
  }

  @override
  String order_upload_progress(int percent) {
    return '$percent% 업로드 중';
  }

  @override
  String get order_upload_retry => '업로드 재시도';

  @override
  String order_upload_failed(String error) {
    return '업로드 실패: $error';
  }

  @override
  String order_upload_size_limit(String size) {
    return '파일 크기가 한도를 초과합니다 (최대 $size)';
  }

  @override
  String order_upload_max_retry(int count) {
    return '최대 재시도 횟수 ($count회)에 도달했습니다';
  }

  @override
  String get order_after_sale_processing => '애프터서비스 처리 중';

  @override
  String get order_after_sale_processing_msg =>
      '애프터서비스 신청을 처리 중입니다. 판매자가 처리할 예정이니 기다려 주세요.';

  @override
  String get order_after_sale_mediation => '플랫폼 조정 진행 중';

  @override
  String get order_after_sale_mediation_msg =>
      '플랫폼 고객센터가 개입하였습니다. 영업일 기준 처리 결과를 알려드리니 알림을 확인해 주세요.';

  @override
  String get order_after_sale_rejected => '애프터서비스 신청 거절됨';

  @override
  String get order_after_sale_rejected_msg => '죄송합니다. 애프터서비스 신청이 승인되지 않았습니다.';

  @override
  String get order_after_sale_default_title => '애프터서비스 상태';

  @override
  String get order_after_sale_default_msg => '현재 주문은 애프터서비스 진행 중입니다.';

  @override
  String get order_after_sale_contact_seller => '판매자 문의';

  @override
  String get order_after_sale_cancel_apply => '신청 취소';

  @override
  String get order_after_sale_contact_platform => '플랫폼 고객센터 문의';

  @override
  String get order_after_sale_add_evidence => '증거 추가';

  @override
  String get order_after_sale_add_evidence_tip =>
      '증거를 추가하거나 플랫폼의 처리 결과를 기다리세요.';

  @override
  String get order_after_sale_apply_intervention => '플랫폼 조정 신청';

  @override
  String get order_after_sale_refund_status => '환불 상태:';

  @override
  String get order_after_sale_refund_amount => '환불 금액:';

  @override
  String get order_after_sale_reject_reason => '거절 사유:';

  @override
  String get order_after_sale_reject_reason_detail =>
      '사유: 증거 불충분 또는 환불 조건 미충족.';

  @override
  String get order_platform_intervention_title => '플랫폼 조정';

  @override
  String get order_platform_intervention_desc =>
      '협의로 해결되지 않는 분쟁이 있을 경우 플랫폼 고객센터 개입을 신청할 수 있습니다';

  @override
  String get order_platform_intervention_apply => '플랫폼 조정 신청';

  @override
  String get order_platform_intervention_in_progress => '플랫폼 조정 진행 중';

  @override
  String get order_platform_intervention_processing => '처리 중';

  @override
  String get order_platform_intervention_processing_msg =>
      '신청이 제출되었습니다. 플랫폼 고객센터가 24시간 내에 연락드립니다';

  @override
  String get order_platform_intervention_step1 => '신청 제출됨';

  @override
  String get order_platform_intervention_step1_desc => '플랫폼 고객센터 처리 대기';

  @override
  String get order_platform_intervention_step2 => '고객센터 개입';

  @override
  String get order_platform_intervention_step2_desc => '24시간 내 양측에 연락';

  @override
  String get order_platform_intervention_step3 => '문제 해결';

  @override
  String get order_platform_intervention_step3_desc => '플랫폼 결정에 따라 처리';

  @override
  String get order_card_product_unknown => '상품명 알 수 없음';

  @override
  String get order_card_deleting => '주문 삭제 중...';

  @override
  String get order_card_deleted => '주문이 삭제되었습니다';

  @override
  String order_card_delete_failed(String error) {
    return '삭제 실패: $error';
  }

  @override
  String order_card_load_detail_failed(String error) {
    return '주문 상세 불러오기 실패: $error';
  }

  @override
  String get order_card_timeout_canceling => '시간 초과, 곧 취소됩니다';

  @override
  String order_card_pay_in_time(String time) {
    return '$time 내에 결제해 주세요';
  }

  @override
  String get order_card_timeout_submit => '시간 초과, 빨리 제출해 주세요';

  @override
  String order_card_submit_in_time(String time) {
    return '$time 내에 자료를 제출해 주세요';
  }

  @override
  String get order_card_seller_timeout => '판매자 접수 시간 초과';

  @override
  String order_card_seller_accept_in_time(String time) {
    return '판매자가 $time 내에 접수할 예정입니다';
  }

  @override
  String order_card_delivery_days(int days) {
    return '교부 기간: $days일 이내';
  }

  @override
  String get order_card_auto_confirm_soon => '곧 자동으로 수령이 확인됩니다';

  @override
  String order_card_auto_confirm_in(String time) {
    return '$time 후 자동 확인';
  }

  @override
  String get order_card_evaluate_for_points => '리뷰 대기 중, 리뷰 작성 시 포인트 획득';

  @override
  String order_card_duration_days_hours(int days, int hours) {
    return '$days일 $hours시간';
  }

  @override
  String order_card_duration_hours_minutes(int hours, int minutes) {
    return '$hours시간 $minutes분';
  }

  @override
  String order_card_duration_minutes(int minutes) {
    return '$minutes분';
  }

  @override
  String get order_card_duration_less_than_minute => '1분 미만';

  @override
  String get order_detail_invalid_id => '유효하지 않은 주문 ID';

  @override
  String get order_detail_error => '오류';

  @override
  String get order_detail_title => '주문 상세';

  @override
  String order_detail_title_with_id(int id) {
    return '주문 상세 (ID: $id)';
  }

  @override
  String order_detail_load_failed(String error) {
    return '불러오기 실패: $error';
  }

  @override
  String get order_detail_reload => '다시 불러오기';

  @override
  String get order_detail_unavailable => '주문 데이터를 사용할 수 없습니다';

  @override
  String get order_list_title => '주문 목록';

  @override
  String get order_list_search_hint => '주문 번호 또는 상품명 검색';

  @override
  String get order_list_empty => '해당 주문이 없습니다';

  @override
  String order_list_load_error(String error) {
    return '불러오기 오류: $error';
  }

  @override
  String order_list_load_failed(String error) {
    return '불러오기 실패: $error';
  }

  @override
  String get order_list_select_category => '카테고리를 선택하여 주문을 확인하세요';

  @override
  String get order_list_tab_all => '전체';

  @override
  String get order_list_tab_awaiting_payment => '결제 대기';

  @override
  String get order_list_tab_awaiting_submission => '제출 대기';

  @override
  String get order_list_tab_awaiting_start => '접수 대기';

  @override
  String get order_list_tab_awaiting_delivery => '교부 대기';

  @override
  String get order_list_tab_awaiting_confirmation => '수령 대기';

  @override
  String get order_list_tab_awaiting_evaluation => '리뷰 대기';

  @override
  String get order_list_tab_after_sale => '애프터서비스';

  @override
  String get order_route_error => '오류';

  @override
  String order_route_invalid_item_id(String id) {
    return '유효하지 않은 상품 ID: $id';
  }

  @override
  String order_seller_detail_title(int id) {
    return '주문 상세 (판매자) - #$id';
  }

  @override
  String order_seller_load_failed(int id, String error) {
    return '주문 #$id 불러오기 실패: $error';
  }

  @override
  String get order_seller_preparing => '준비 중...';

  @override
  String get order_seller_order_number => '주문 번호';

  @override
  String get order_seller_order_time => '주문 시간';

  @override
  String get order_seller_pay_time => '결제 시간';

  @override
  String get order_seller_complete_time => '완료 시간';

  @override
  String get order_seller_cancel_time => '취소 시간';

  @override
  String get order_seller_list_title => '내 주문 (판매자)';

  @override
  String get order_seller_tab_all => '전체';

  @override
  String get order_seller_tab_awaiting_start => '접수 대기';

  @override
  String get order_seller_tab_awaiting_delivery => '교부 대기';

  @override
  String get order_seller_tab_awaiting_confirmation => '수령 확인 대기';

  @override
  String get order_seller_tab_awaiting_evaluation => '리뷰 대기';

  @override
  String get order_seller_tab_completed => '완료됨';

  @override
  String get order_seller_tab_after_sale => '애프터서비스';

  @override
  String get order_seller_tab_canceled => '취소됨';

  @override
  String order_seller_load_failed_msg(String error) {
    return '불러오기 실패: $error';
  }

  @override
  String get order_seller_empty => '해당 상태의 주문이 없습니다';

  @override
  String order_seller_action_failed(String error) {
    return '작업 실패: $error';
  }

  @override
  String order_seller_pending_count(int count) {
    return '처리할 주문이 $count건 있습니다';
  }

  @override
  String order_seller_pending_awaiting_start(int count) {
    return '$count건 접수 대기';
  }

  @override
  String order_seller_pending_awaiting_delivery(int count) {
    return '$count건 교부 대기';
  }

  @override
  String get order_seller_reject_order => '주문 거절';

  @override
  String get order_seller_confirm_order => '주문 접수';

  @override
  String get order_seller_contact_buyer => '구매자 문의';

  @override
  String get order_seller_go_deliver => '교부하기';

  @override
  String get order_seller_view_delivery_content => '교부 내용 보기';

  @override
  String get order_seller_remind_buyer => '구매자에게 확인 요청';

  @override
  String get order_seller_delete_record => '기록 삭제';

  @override
  String get order_seller_confirm_accept_title => '접수 확인';

  @override
  String get order_seller_confirm_accept_content => '이 주문을 접수하시겠습니까?';

  @override
  String get order_seller_confirm_delete_title => '삭제 확인';

  @override
  String get order_seller_confirm_delete_content =>
      '이 주문 기록을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get order_seller_confirm_delete_canceled_content =>
      '이 취소된 주문 기록을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get order_seller_confirm_btn => '확인';

  @override
  String get order_seller_confirm_reject_title => '거절 확인';

  @override
  String get order_seller_confirm_reject_content => '이 주문을 거절하시겠습니까?';

  @override
  String get order_seller_confirm_reject_btn => '거절 확인';

  @override
  String get order_seller_reject_dialog_title => '주문 거절';

  @override
  String get order_seller_reject_reason_label => '거절 사유 *';

  @override
  String get order_seller_reject_reason_hint => '거절 사유를 입력해 주세요';

  @override
  String get order_seller_reject_reason_empty => '거절 사유를 입력해 주세요';

  @override
  String get order_seller_reject_reason_required => '거절 사유를 입력해 주세요';

  @override
  String get order_seller_remarks_label => '추가 설명 (선택 사항)';

  @override
  String get order_seller_remarks_hint => '선택 사항';

  @override
  String get order_seller_delivery_dialog_title => '교부 내용';

  @override
  String get order_seller_delivery_desc_label => '교부 설명 *';

  @override
  String get order_seller_delivery_desc_hint => '교부 내용을 설명해 주세요';

  @override
  String get order_seller_delivery_desc_empty => '교부 설명을 입력해 주세요';

  @override
  String get order_seller_delivery_desc_required => '교부 설명을 입력해 주세요';

  @override
  String get order_seller_delivery_attachment => '첨부파일';

  @override
  String get order_seller_delivery_select_file => '아래 버튼을 탭하여 파일 선택';

  @override
  String get order_seller_delivery_add_attachment => '첨부파일 추가';

  @override
  String get order_seller_delivery_file_select_soon => '파일 선택 기능 출시 예정';

  @override
  String get order_seller_delivery_confirm => '교부 확인';

  @override
  String order_seller_delivery_chat_hint(String productName) {
    return '상품 \"$productName\"에 대한 채팅을 선택해 주세요';
  }

  @override
  String get order_seller_dynamic_delivered => '서비스 교부 완료';

  @override
  String get order_seller_dynamic_delivered_msg =>
      '서비스 교부가 완료되었습니다. 구매자 확인을 기다려 주세요. 문제가 있을 경우 구매자가 애프터서비스를 신청할 수 있습니다.';

  @override
  String get order_seller_dynamic_completed => '이 주문이 성공적으로 완료되었습니다.';

  @override
  String get order_seller_dynamic_canceled => '이 주문이 취소되었습니다.';

  @override
  String get order_seller_dynamic_refused => '주문 거절 신청됨';

  @override
  String get order_seller_dynamic_refused_msg => '거절 신청이 제출되었으며 처리를 기다리고 있습니다.';

  @override
  String get order_seller_buyer_materials => '구매자 제공 자료';

  @override
  String get order_seller_attachment_label => '첨부파일:';

  @override
  String order_seller_view_attachment(String fileName) {
    return '첨부파일 보기 기능 구현 예정: $fileName';
  }

  @override
  String get order_evaluation_product_info => '상품 정보';

  @override
  String get order_list_retry => '다시 시도';

  @override
  String chat_get_user_info_failed(String error) {
    return '사용자 정보 가져오기 실패: $error';
  }

  @override
  String get chat_user_refer_id_not_found => '사용자 referId를 찾을 수 없습니다';

  @override
  String get chat_no_chat_records => '채팅 기록이 없습니다';

  @override
  String get chat_opponent_info_missing => '상대방 정보가 없습니다';

  @override
  String get chat_product_default => '상품';

  @override
  String get chat_view_details => '상세 보기';

  @override
  String get chat_product_info_incomplete => '상품 정보가 불완전하여 상세 내용을 볼 수 없습니다';

  @override
  String get chat_uploading => '업로드 중...';

  @override
  String get chat_upload_failed => '업로드 실패';

  @override
  String get chat_retry => '다시 시도';

  @override
  String get chat_image_loading => '불러오는 중...';

  @override
  String get chat_image_load_failed => '불러오기 실패';

  @override
  String get chat_revoke_time_missing => '메시지 시간 정보가 없어 취소할 수 없습니다';

  @override
  String get chat_revoke_available => '취소 가능';

  @override
  String chat_revoke_expired(int seconds) {
    return '메시지 전송 후 2분이 지나 취소할 수 없습니다 ($seconds초 초과)';
  }

  @override
  String get chat_unknown_seller => '알 수 없는 판매자';

  @override
  String get chat_product_conversation => '상품 대화';

  @override
  String chat_product_conversation_count(int count) {
    return '$count개 상품 대화';
  }

  @override
  String get chat_unknown_product => '알 수 없는 상품';

  @override
  String chat_user_inquiry_count(int count) {
    return '$count개 사용자 문의';
  }

  @override
  String get chat_weekday_mon => '월';

  @override
  String get chat_weekday_tue => '화';

  @override
  String get chat_weekday_wed => '수';

  @override
  String get chat_weekday_thu => '목';

  @override
  String get chat_weekday_fri => '금';

  @override
  String get chat_weekday_sat => '토';

  @override
  String get chat_weekday_sun => '일';

  @override
  String get chat_select_multiple_images => '여러 장 선택';

  @override
  String chat_image_compressed(String ratio) {
    return '이미지 $ratio% 압축됨';
  }

  @override
  String chat_image_process_failed(String error) {
    return '이미지 처리 실패: $error';
  }

  @override
  String chat_images_processed_success(int count, String ratio) {
    return '$count장 이미지 처리 완료, 평균 $ratio% 압축';
  }

  @override
  String chat_images_process_failed_count(int count) {
    return '$count장의 이미지 처리 실패';
  }

  @override
  String get chat_tap_to_view_product => '탭하여 상품 상세 보기';

  @override
  String chat_yesterday_time(String time) {
    return '어제 $time';
  }

  @override
  String get chat_no_messages_brief => '메시지 없음';

  @override
  String chat_select_image_error(String error) {
    return '이미지 선택 오류: $error';
  }

  @override
  String get after_sales_reason_none => '없음';

  @override
  String seller_auth_status_title(String type) {
    return '$type 인증';
  }

  @override
  String get seller_auth_status_label => '인증 상태: ';

  @override
  String get seller_auth_status_name_label => '인증 이름: ';

  @override
  String get seller_auth_status_materials => '인증 자료';

  @override
  String get seller_auth_status_no_materials => '인증 자료가 없습니다';

  @override
  String get seller_auth_status_info => '인증 정보';

  @override
  String get seller_auth_status_history => '인증 이력';

  @override
  String get seller_auth_status_no_history => '이력이 없습니다';

  @override
  String get seller_auth_status_reapply => '재인증';

  @override
  String get seller_auth_status_approved_hint => '인증이 승인되었습니다. 재제출하지 않아도 됩니다';

  @override
  String get seller_auth_status_pending_hint => '인증 심사 중입니다. 기다려 주세요';

  @override
  String get seller_auth_status_tag_approved => '인증됨';

  @override
  String get seller_auth_status_tag_pending => '심사 중';

  @override
  String get seller_auth_status_tag_rejected => '미승인';

  @override
  String get seller_auth_status_tag_not_submitted => '미제출';

  @override
  String get seller_auth_status_type_idcard => '신분';

  @override
  String get seller_auth_status_type_education => '학력';

  @override
  String get seller_auth_status_type_profession => '직업';

  @override
  String get seller_auth_status_type_company => '회사';

  @override
  String get seller_auth_status_type_other => '기타';

  @override
  String get seller_auth_status_field_auth_name => '인증 이름';

  @override
  String get seller_auth_status_field_auth_type => '인증 유형';

  @override
  String get seller_auth_status_field_company_name => '회사명';

  @override
  String get seller_auth_status_field_name => '이름';

  @override
  String get seller_auth_status_field_school_name => '학교명';

  @override
  String get seller_auth_status_field_profession => '직업/직위';

  @override
  String get seller_auth_status_field_name_or_title => '이름/명칭';

  @override
  String get seller_auth_status_field_remarks => '비고';

  @override
  String get seller_auth_status_field_cert_number => '인증서 번호';

  @override
  String get seller_auth_status_field_work_experience => '업무 경력';

  @override
  String get seller_auth_status_field_issuer => '발급 기관';

  @override
  String get seller_auth_status_field_credit_code => '통합 사회 신용 코드';

  @override
  String get seller_auth_status_field_legal_rep => '법인 대표';

  @override
  String get seller_auth_status_field_registered_capital => '등록 자본금';

  @override
  String get seller_auth_status_field_establishment_date => '설립일';

  @override
  String get seller_auth_status_field_degree => '학위';

  @override
  String get seller_auth_status_field_major => '전공';

  @override
  String get seller_auth_status_field_graduation_year => '졸업 연도';

  @override
  String get seller_auth_status_field_id_number => '주민등록번호';

  @override
  String get seller_auth_status_field_valid_period => '유효 기간';

  @override
  String get seller_auth_status_field_submit_time => '제출 시간';

  @override
  String get seller_auth_status_field_reject_reason => '거절 사유';

  @override
  String get seller_auth_status_history_approved_title => '인증 신청 승인';

  @override
  String seller_auth_status_history_approved_desc(String type) {
    return '$type 인증 신청이 승인되었습니다. 이제 인증된 판매자의 모든 혜택을 누릴 수 있습니다.';
  }

  @override
  String get seller_auth_status_history_submitted_title => '인증 신청 제출';

  @override
  String seller_auth_status_history_submitted_desc(String type) {
    return '$type 인증 신청이 제출되었습니다. 1~3 영업일 내에 심사가 완료됩니다.';
  }

  @override
  String get seller_auth_status_history_rejected_title => '인증 신청 거절';

  @override
  String seller_auth_status_history_rejected_desc(String type, String reason) {
    return '$type 인증 신청이 거절되었습니다. 사유: $reason';
  }

  @override
  String get seller_auth_status_history_rejected_default_reason =>
      '자료가 요건을 충족하지 않습니다';

  @override
  String get seller_product_preview_title => '상품 미리보기';

  @override
  String get seller_product_preview_back_to_edit => '편집으로 돌아가기';

  @override
  String get seller_product_preview_loading => '상품 정보 불러오는 중...';

  @override
  String get seller_product_preview_load_failed => '상품 정보 불러오기 실패';

  @override
  String get seller_product_preview_retry => '다시 시도';

  @override
  String get seller_product_preview_fetching => '상품 데이터 가져오는 중...';

  @override
  String get seller_product_preview_hint =>
      '이것은 미리보기 모드입니다. 구매자에게는 비슷한 화면이 표시됩니다';

  @override
  String get seller_product_edit_unsaved_changes_title => '저장되지 않은 변경사항 감지됨';

  @override
  String get seller_product_edit_unsaved_changes_message =>
      '저장되지 않은 내용이 있습니다. 초안으로 저장하시겠습니까?';

  @override
  String get seller_product_edit_cancel => '취소';

  @override
  String get seller_product_edit_discard => '저장 안 함';

  @override
  String get seller_product_edit_operation_failed => '작업 실패';

  @override
  String get seller_product_edit_draft_saved => '초안이 저장되었습니다';

  @override
  String get seller_product_edit_publish_success =>
      '서비스가 게시되었습니다! 심사 중입니다. \'판매 중\' 목록에서 확인하세요';

  @override
  String get seller_product_edit_update_success => '서비스가 업데이트되었습니다';

  @override
  String get seller_product_edit_max_images =>
      '최대 9장까지 업로드 가능합니다. 처음 9장이 선택되었습니다';

  @override
  String seller_product_edit_price_required(String tierName) {
    return '$tierName 가격은 0보다 커야 합니다';
  }

  @override
  String get seller_product_edit_form_incomplete =>
      '양식 데이터가 불완전합니다. 표시된 필드를 확인해 주세요';

  @override
  String get seller_product_edit_add_attribute => '속성 추가';

  @override
  String seller_product_edit_attribute_max_chars(int max) {
    return '속성 이름은 최대 $max자까지 가능합니다';
  }

  @override
  String get seller_product_edit_confirm => '확인';

  @override
  String get seller_product_edit_options_config => '옵션 설정';

  @override
  String get seller_product_edit_new_option => '새 옵션';

  @override
  String get seller_product_edit_option_hint => '옵션 내용을 입력해 주세요';

  @override
  String get seller_product_edit_service_name_hint => '서비스명';

  @override
  String get seller_product_edit_description_hint =>
      '서비스에 대한 구체적인 정보를 설명해 주세요...';

  @override
  String get seller_product_edit_faq_title => '자주 묻는 질문 편집';

  @override
  String seller_product_edit_faq_count(int count) {
    return '$count개 질문';
  }

  @override
  String get seller_product_edit_add_question => '질문 추가';

  @override
  String get seller_product_edit_question_label => '질문';

  @override
  String get seller_product_edit_question_hint => '구매자가 물어볼 만한 질문을 입력해 주세요';

  @override
  String get seller_product_edit_delete_question => '질문 삭제';

  @override
  String get seller_product_edit_answer_label => '답변';

  @override
  String get seller_product_edit_answer_hint => '답변을 입력해 주세요';

  @override
  String get seller_product_edit_buyer_info_title => '구매자 제공 필요 정보';

  @override
  String seller_product_edit_buyer_info_count(int count) {
    return '$count개 정보';
  }

  @override
  String get seller_product_edit_buyer_info_desc =>
      '구매자가 제공해야 할 정보 유형을 선택하세요 (주문 상세 페이지에 표시됩니다)';

  @override
  String get seller_product_edit_selected_items => '선택된 정보 항목:';

  @override
  String get seller_product_edit_required => '필수';

  @override
  String get seller_product_edit_edit_tooltip => '수정';

  @override
  String get seller_product_edit_delete_tooltip => '삭제';

  @override
  String seller_product_edit_add_info_title(String type) {
    return '$type 정보 추가';
  }

  @override
  String get seller_product_edit_info_label => '정보 레이블';

  @override
  String get seller_product_edit_info_label_hint => '예: 회사 로고 디자인 요건';

  @override
  String get seller_product_edit_info_description => '상세 설명';

  @override
  String get seller_product_edit_info_description_hint =>
      '구매자가 제공해야 할 정보를 자세히 설명해 주세요';

  @override
  String get seller_product_edit_required_field => '필수 항목';

  @override
  String get seller_product_edit_add => '추가';

  @override
  String seller_product_edit_edit_info_title(String type) {
    return '$type 정보 수정';
  }

  @override
  String get seller_product_edit_save => '저장';

  @override
  String seller_product_edit_cases_count(int count) {
    return '$count개 사례';
  }

  @override
  String get seller_product_edit_add_case => '사례 추가';

  @override
  String get seller_product_edit_image_load_failed => '이미지 불러오기 실패';

  @override
  String get seller_product_edit_click_select_image => '탭하여 이미지 선택';

  @override
  String get seller_product_edit_upload_failed => '업로드 실패';

  @override
  String get seller_product_edit_upload_retry => '다시 시도';

  @override
  String get seller_product_edit_case_title_label => '사례 제목';

  @override
  String get seller_product_edit_case_title_hint => '이 사례를 간단히 설명해 주세요';

  @override
  String get seller_product_edit_case_desc_label => '사례 설명';

  @override
  String get seller_product_edit_case_desc_hint =>
      '사례의 배경, 진행 과정 또는 결과를 설명해 주세요';

  @override
  String get seller_product_edit_select_image_and_title =>
      '이미지를 선택하고 제목을 입력해 주세요';

  @override
  String get seller_product_edit_cover_image => '서비스 대표 이미지';

  @override
  String get seller_product_edit_upload_success => '업로드 완료';

  @override
  String seller_product_edit_upload_error(String error) {
    return '업로드 오류: $error';
  }

  @override
  String get seller_product_edit_image_format_hint =>
      'jpg, png, jpeg 형식 지원. 장당 최대 5MB, 최대 9장';

  @override
  String get seller_product_edit_main_image => '대표';

  @override
  String seller_product_edit_tier_price_label(String tierName) {
    return '$tierName 가격';
  }

  @override
  String seller_product_edit_max_price(String max) {
    return '최대값: $max';
  }

  @override
  String seller_product_edit_price_exceed_max(String max) {
    return '가격은 $max를 초과할 수 없습니다';
  }

  @override
  String get seller_product_edit_price_min => '최소 가격은 0.01입니다';

  @override
  String get seller_product_edit_delivery_period => '교부 기간';

  @override
  String get seller_product_edit_delivery_days_suffix => '일';

  @override
  String seller_product_edit_max_days(int max) {
    return '최대 $max일';
  }

  @override
  String get seller_product_edit_times => '수정 횟수';

  @override
  String get seller_product_edit_times_suffix => '회';

  @override
  String seller_product_edit_max_times(int max) {
    return '최대 $max회';
  }

  @override
  String get seller_product_edit_input => '입력';

  @override
  String get seller_product_edit_radio => '단일 선택';

  @override
  String get seller_product_edit_draft_label => '초안';

  @override
  String get seller_product_edit_draft_unsaved_label => '초안*';

  @override
  String get seller_product_edit_publish => '게시';

  @override
  String get seller_product_edit_yes => '예';

  @override
  String get seller_product_edit_no => '아니요';

  @override
  String get seller_product_edit_add_selection_attribute => '단일 선택 속성 추가';

  @override
  String get seller_product_edit_default_options_yes_no => '기본 옵션: 예/아니요';

  @override
  String get seller_product_edit_attribute_name_label => '속성 이름 *';

  @override
  String get seller_product_edit_attribute_name_example =>
      '예: 색상, 모델, 소재, 적용 연령';

  @override
  String get seller_product_edit_attribute_type_label => '속성 유형';

  @override
  String get seller_product_edit_required_item => '필수';

  @override
  String seller_product_card_sales(int count) {
    return '판매량: $count';
  }

  @override
  String get seller_product_card_view => '보기';

  @override
  String get seller_image_preview_main_image => '대표 이미지';

  @override
  String get seller_image_preview_set_main => '대표 이미지로 설정';

  @override
  String get seller_image_preview_load_failed => '이미지 불러오기 실패';

  @override
  String get seller_image_preview_delete_title => '이미지 삭제';

  @override
  String seller_image_preview_delete_confirm(int index) {
    return '$index번째 이미지를 삭제하시겠습니까?';
  }

  @override
  String get seller_image_preview_delete => '삭제';

  @override
  String get seller_file_select => '파일 선택';

  @override
  String get seller_file_selected => '선택된 파일:';

  @override
  String seller_file_size(String size) {
    return '크기: $size';
  }

  @override
  String get seller_file_size_unknown => '크기를 가져올 수 없습니다';

  @override
  String seller_file_preview_unsupported(String name) {
    return '이 파일 유형을 미리볼 수 없습니다: $name';
  }

  @override
  String get seller_common_cancel => '취소';

  @override
  String get profile_user_name_default => '사용자 이름';

  @override
  String get profile_buyer_mode => '구매자 모드';

  @override
  String get profile_my_orders => '내 주문';

  @override
  String get profile_my_dskk_section => '내 DSKK';

  @override
  String get profile_liked_stories => '좋아요한 스토리';

  @override
  String get profile_logout => '로그아웃';

  @override
  String get profile_avatar_updated_local =>
      '프로필 사진이 업데이트되었으나 서버에 아직 저장되지 않았습니다';

  @override
  String profile_image_pick_error(String error) {
    return '이미지 선택 오류: $error';
  }

  @override
  String profile_feature_not_implemented(String feature) {
    return '$feature 기능은 아직 사용할 수 없습니다';
  }

  @override
  String get profile_pending_payment_order => '결제 대기';

  @override
  String get profile_in_progress_order => '진행 중';

  @override
  String get profile_completed_order => '완료됨';

  @override
  String get profile_refund_after_sales => '환불/애프터서비스';

  @override
  String get profile_account_deletion => '계정 삭제';

  @override
  String get profile_bound_phone => '연결된 휴대폰';

  @override
  String get profile_not_bound => '연결되지 않음';

  @override
  String get profile_nickname => '닉네임';

  @override
  String get profile_confirm_logout => '로그아웃 확인';

  @override
  String get profile_confirm_logout_message => '로그아웃하시겠습니까?';

  @override
  String get profile_confirm => '확인';

  @override
  String get profile_update_avatar => '프로필 사진 업데이트';

  @override
  String get profile_update_avatar_confirm => '프로필 사진을 업데이트하시겠습니까?';

  @override
  String get profile_info_updated => '프로필이 성공적으로 업데이트되었습니다!';

  @override
  String get profile_avatar_upload_timeout =>
      '프로필 사진 업로드 시간 초과. 네트워크를 확인 후 다시 시도해 주세요';

  @override
  String get profile_network_failed => '네트워크 연결 실패. 네트워크를 확인 후 다시 시도해 주세요';

  @override
  String profile_avatar_optimized(String ratio) {
    return '프로필 사진이 최적화되었습니다, $ratio% 압축';
  }

  @override
  String profile_avatar_process_failed(String error) {
    return '프로필 사진 처리 실패: $error';
  }

  @override
  String profile_logout_error(String error) {
    return '로그아웃 중 오류 발생: $error';
  }

  @override
  String get profile_nickname_empty => '닉네임을 입력해 주세요';

  @override
  String get profile_nickname_too_short => '닉네임은 최소 2자 이상이어야 합니다';

  @override
  String get profile_nickname_too_long => '닉네임은 최대 20자까지 가능합니다';

  @override
  String get profile_nickname_no_spaces => '닉네임에 공백을 포함할 수 없습니다';

  @override
  String get profile_nickname_invalid_chars =>
      '닉네임은 한국어, 영문, 숫자, 밑줄만 사용할 수 있습니다';

  @override
  String get profile_nickname_only_underscores => '닉네임은 밑줄만으로 구성할 수 없습니다';

  @override
  String get profile_nickname_unchanged => '닉네임이 변경되지 않았습니다';

  @override
  String get profile_edit_nickname_title => '닉네임 수정';

  @override
  String get profile_nickname_input_hint => '닉네임 입력';

  @override
  String get profile_nickname_rules =>
      '2~20자로 설정하세요. 한국어, 영문, 숫자, 밑줄만 사용 가능합니다';

  @override
  String get profile_nickname_updated => '닉네임이 성공적으로 수정되었습니다!';

  @override
  String profile_nickname_update_failed(String error) {
    return '닉네임 수정 실패: $error';
  }

  @override
  String get profile_submit_changes => '변경사항 제출';

  @override
  String get profile_avatar_uploaded => '프로필 사진이 업로드되었습니다';

  @override
  String get profile_updated => '프로필이 업데이트되었습니다';

  @override
  String get profile_reload => '다시 불러오기';

  @override
  String get profile_account_balance => '계정 잔액';

  @override
  String get profile_pending_settlement => '정산 대기';

  @override
  String get profile_total_income => '총 수익';

  @override
  String get profile_load_wallet => '탭하여 지갑 정보 불러오기';

  @override
  String get profile_all_orders => '전체 주문';

  @override
  String get profile_awaiting_payment => '결제 대기';

  @override
  String get profile_awaiting_shipment => '발송 대기';

  @override
  String get profile_awaiting_receipt => '수령 대기';

  @override
  String get profile_awaiting_review => '리뷰 대기';

  @override
  String get profile_shipping_address => '배송 주소';

  @override
  String get profile_browsing_history => '열람 기록';

  @override
  String get profile_contact_support => '고객센터 문의';

  @override
  String get profile_help_center => '도움말 센터';

  @override
  String get profile_feedback => '의견 보내기';

  @override
  String get profile_switch_to_seller_mode => '판매자 모드로 전환';

  @override
  String get profile_take_photo => '사진 촬영';

  @override
  String get profile_choose_from_album => '앨범에서 선택';

  @override
  String profile_image_pick_failed(String error) {
    return '이미지 선택 실패: $error';
  }

  @override
  String get profile_edit_profile => '프로필 수정';

  @override
  String get profile_online_status => '온라인 상태';

  @override
  String get profile_mission_title => '어시스턴트의 사명';

  @override
  String get profile_mission_our_mission => '우리의 사명';

  @override
  String get profile_mission_our_mission_content =>
      '창의성과 수요를 연결하여 모든 아이디어가 실현될 수 있도록 합니다. 우리 어시스턴트는 사용자에게 가장 세심하고 지능적인 서비스 경험을 제공하여 생활과 업무에서 가장 믿을 수 있는 디지털 파트너가 되고자 합니다.';

  @override
  String get profile_mission_core_values => '핵심 가치';

  @override
  String get profile_mission_core_values_content =>
      '• 사용자 최우선: 항상 사용자 요구에서 출발\n• 혁신 추구: 지속적으로 새로운 기술과 방법 탐색\n• 성실한 서비스: 신뢰할 수 있고 투명한 서비스 제공\n• 함께 성장: 사용자 및 파트너와 함께 나아감';

  @override
  String get profile_mission_service_promise => '서비스 약속';

  @override
  String get profile_mission_service_promise_content =>
      '모든 사용자에게 다음을 약속드립니다:\n\n✓ 24/7 지능형 서비스 지원\n✓ 개인화된 솔루션 추천\n✓ 안전하고 신뢰할 수 있는 데이터 보호\n✓ 지속적으로 최적화된 사용자 경험\n✓ 신속한 고객 서비스';

  @override
  String get profile_mission_future_vision => '미래 비전';

  @override
  String get profile_mission_future_vision_content =>
      'AI 기술로 역량을 강화하여 세계적으로 선도적인 지능형 서비스 플랫폼이 되어, 모든 사람이 개인화되고 효율적인 디지털 생활 경험을 누릴 수 있도록 합니다. 기술의 힘이 삶을 더 좋게 만들고 창의성을 더 쉽게 실현할 수 있다고 믿습니다.';

  @override
  String get profile_mission_questions_suggestions => '질문이나 제안이 있으신가요?';

  @override
  String get profile_mission_listening =>
      '저희는 항상 여러분의 목소리를 듣고, 함께 더 나은 미래를 만들어 가기를 기대합니다.';

  @override
  String get profile_mission_contact_us => '문의하기';

  @override
  String get profile_mission_contact_coming_soon => '연락 기능 출시 예정입니다!';

  @override
  String get profile_wallet_title => '내 지갑';

  @override
  String profile_wallet_error(String error) {
    return '오류: $error';
  }

  @override
  String profile_wallet_occurred_error(String error) {
    return '오류 발생: $error';
  }

  @override
  String get profile_wallet_retry => '다시 시도';

  @override
  String get profile_wallet_filter_all => '전체';

  @override
  String get profile_wallet_filter_income => '수입';

  @override
  String get profile_wallet_filter_expense => '지출';

  @override
  String get profile_wallet_no_transactions => '거래 내역이 없습니다';

  @override
  String profile_wallet_load_failed(String error) {
    return '불러오기 실패: $error';
  }

  @override
  String profile_wallet_load_more_failed(String error) {
    return '더 불러오기 실패: $error';
  }

  @override
  String get profile_wallet_account_balance => '계정 잔액';

  @override
  String get profile_wallet_pending_amount => '정산 대기 금액';

  @override
  String get profile_wallet_total_income => '총 수입';

  @override
  String get profile_wallet_withdraw => '출금';

  @override
  String get profile_wallet_status_completed => '완료됨';

  @override
  String get profile_wallet_status_pending => '처리 중';

  @override
  String get profile_wallet_status_failed => '실패';

  @override
  String get profile_wallet_status_unknown => '알 수 없음';

  @override
  String get profile_wallet_transaction_details => '거래 상세';

  @override
  String get profile_wallet_transaction_id => '거래 ID';

  @override
  String get profile_wallet_transaction_type => '유형';

  @override
  String get profile_wallet_transaction_type_income => '수입';

  @override
  String get profile_wallet_transaction_type_expense => '지출';

  @override
  String get profile_wallet_transaction_amount => '금액';

  @override
  String get profile_wallet_transaction_description => '설명';

  @override
  String get profile_wallet_transaction_date => '날짜';

  @override
  String get profile_wallet_transaction_status => '상태';

  @override
  String get profile_wallet_close => '닫기';

  @override
  String profile_wallet_available_balance(String symbol, String amount) {
    return '출금 가능 잔액: $symbol$amount';
  }

  @override
  String get profile_wallet_withdraw_amount => '출금 금액';

  @override
  String get profile_wallet_withdraw_hint => '출금 금액을 입력해 주세요';

  @override
  String get profile_wallet_withdraw_time => '출금 소요 시간: 1~3 영업일';

  @override
  String get profile_wallet_invalid_amount => '유효한 출금 금액을 입력해 주세요';

  @override
  String get profile_wallet_exceed_balance => '출금 금액이 가능한 잔액을 초과합니다';

  @override
  String get profile_wallet_confirm_withdraw => '출금 확인';

  @override
  String profile_wallet_withdraw_submitted(String symbol, String amount) {
    return '출금 신청이 제출되었습니다: $symbol$amount';
  }

  @override
  String get profile_wallet_not_implemented => '이 기능은 아직 사용할 수 없습니다';

  @override
  String get auth_verification_expired => '인증 코드가 만료되었습니다';

  @override
  String auth_login_failed(String error) {
    return '로그인 실패: $error';
  }

  @override
  String auth_code_send_failed(String error) {
    return '인증 코드 전송 실패: $error';
  }

  @override
  String get auth_login_success => '로그인 성공';

  @override
  String get auth_login => '로그인';

  @override
  String get auth_privacy_policy => '개인정보처리방침';

  @override
  String get auth_and => '및';

  @override
  String get auth_user_agreement => '이용약관';

  @override
  String get auth_invalid_phone => '유효한 11자리 휴대폰 번호를 입력해 주세요';

  @override
  String get auth_get_code => '인증 코드 받기';

  @override
  String get payment_creating_order => '주문 생성 중...';

  @override
  String get payment_processing => '처리 중...';

  @override
  String get payment_credit_card => '신용카드 결제';

  @override
  String get payment_confirm_order => '주문 확인';

  @override
  String get payment_quantity_label => '수량:';

  @override
  String get payment_order_summary => '주문 요약';

  @override
  String get payment_product_amount => '상품 금액';

  @override
  String get payment_quantity => '수량';

  @override
  String get payment_order_total => '주문 합계';

  @override
  String get payment_method => '결제 수단';

  @override
  String get payment_processing_ellipsis => '처리 중...';

  @override
  String get payment_confirm_pay => '결제 확인';

  @override
  String get payment_success => '결제가 완료되었습니다';

  @override
  String get payment_failed => '결제 실패';

  @override
  String get payment_view_order_detail => '주문 상세 보기';

  @override
  String get payment_back_to_orders => '주문 목록으로 돌아가기';

  @override
  String get payment_success_tip => '구매해 주셔서 감사합니다! 주문에서 상세 내용을 확인하실 수 있습니다.';

  @override
  String get payment_failed_tip => '결제에 실패했습니다. 다시 시도하거나 다른 결제 수단을 선택해 주세요.';

  @override
  String get home_banner_image_load_failed => '이미지 불러오기 실패';

  @override
  String home_banner_placeholder(int index) {
    return '배너 $index';
  }

  @override
  String get home_no_data => '데이터가 없습니다';

  @override
  String get product_detail_no_faq => '자주 묻는 질문이 없습니다';

  @override
  String product_detail_buy_button(String price) {
    return '바로 구매 $price';
  }

  @override
  String get product_detail_buyer_requirements => '구매자 제공 필요 정보';

  @override
  String get product_detail_no_buyer_requirements =>
      '판매자가 아직 구매자 제공 정보를 설정하지 않았습니다';

  @override
  String get after_sales_apply => '애프터서비스 신청';

  @override
  String get after_sales_apply_remake => '재제작 신청';

  @override
  String get after_sales_apply_supplement => '보충 신청';

  @override
  String get after_sales_apply_refund => '환불 신청';

  @override
  String after_sales_max_images(int max) {
    return '최대 $max장까지 업로드 가능합니다';
  }

  @override
  String after_sales_images_processed(int count, String ratio) {
    return '$count장 이미지 처리 완료, 평균 $ratio% 압축';
  }

  @override
  String after_sales_images_failed(int count) {
    return '$count장의 이미지 처리 실패';
  }

  @override
  String after_sales_image_pick_failed(String error) {
    return '이미지 선택 실패: $error';
  }

  @override
  String get after_sales_select_reason => '사유 선택';

  @override
  String get after_sales_reason_label => '신청 사유';

  @override
  String get after_sales_reason_quality => '상품 품질 문제';

  @override
  String get after_sales_reason_mismatch => '상품이 설명과 다릅니다';

  @override
  String get after_sales_reason_wrong_item => '판매자가 잘못된 상품을 발송함';

  @override
  String get after_sales_reason_unwanted => '더 이상 필요하지 않음';

  @override
  String get after_sales_reason_other => '기타';

  @override
  String get after_sales_description_label => '문제 설명';

  @override
  String get after_sales_description_hint => '문제를 자세히 설명해 주세요...';

  @override
  String after_sales_refund_max_hint(String symbol, String amount) {
    return '최대 환불 가능 금액 $symbol$amount';
  }

  @override
  String get after_sales_enter_refund_amount => '환불 금액을 입력해 주세요';

  @override
  String get after_sales_invalid_amount => '유효한 금액을 입력해 주세요';

  @override
  String get after_sales_amount_must_positive => '환불 금액은 0보다 커야 합니다';

  @override
  String after_sales_amount_exceed(String symbol, String amount) {
    return '환불 금액은 $symbol$amount을 초과할 수 없습니다';
  }

  @override
  String after_sales_upload_proof(int max) {
    return '증거 업로드 (최대 $max장)';
  }

  @override
  String get after_sales_remove_image => '이미지 제거';

  @override
  String get after_sales_submit => '신청 제출';

  @override
  String after_sales_loading_failed(String error) {
    return '불러오기 실패: $error';
  }

  @override
  String get after_sales_detail_retry => '다시 시도';

  @override
  String get after_sales_initializing => '초기화 중...';

  @override
  String get after_sales_status_audit_reject => '애프터서비스 신청 거절됨';

  @override
  String get after_sales_status_refund_success => '환불 완료';

  @override
  String get after_sales_status_processing => '처리 중';

  @override
  String get after_sales_subtitle_wait_audit => '판매자가 48시간 내에 신청을 처리할 예정입니다';

  @override
  String get after_sales_subtitle_audit_pass => '환불은 1~3 영업일 내 처리됩니다';

  @override
  String get after_sales_subtitle_audit_reject => '이의가 있으시면 플랫폼 조정을 신청할 수 있습니다';

  @override
  String get after_sales_subtitle_refund_success => '환불이 완료되었습니다. 계좌를 확인해 주세요';

  @override
  String get after_sales_subtitle_canceled => '애프터서비스 신청을 취소하셨습니다';

  @override
  String get after_sales_subtitle_default => '처리 결과를 기다려 주세요';

  @override
  String get after_sales_product_info => '상품 정보';

  @override
  String get after_sales_product_unknown => '상품명 알 수 없음';

  @override
  String after_sales_spec(String spec) {
    return '규격: $spec';
  }

  @override
  String after_sales_quantity(int count) {
    return '수량: $count';
  }

  @override
  String get after_sales_info => '애프터서비스 정보';

  @override
  String get after_sales_application_number => '신청 번호';

  @override
  String get after_sales_application_time => '신청 시간';

  @override
  String get after_sales_refund_amount_label => '환불 금액';

  @override
  String get after_sales_application_reason => '신청 사유';

  @override
  String get after_sales_detailed_description => '상세 설명';

  @override
  String get after_sales_audit_remark => '심사 비고';

  @override
  String get after_sales_revoke => '신청 취소';

  @override
  String get after_sales_modify => '신청 수정';

  @override
  String get after_sales_platform_intervention => '플랫폼 조정';

  @override
  String get after_sales_list_title => '애프터서비스 목록';

  @override
  String get after_sales_no_records => '애프터서비스 신청 내역이 없습니다';

  @override
  String get after_sales_please_wait => '잠시 기다려 주세요...';

  @override
  String get after_sales_unknown_product => '알 수 없는 상품';

  @override
  String after_sales_status_label(String status) {
    return '상태: $status';
  }

  @override
  String get after_sales_select_type => '애프터서비스 유형 선택';

  @override
  String get after_sales_type_remake => '재제작';

  @override
  String get after_sales_type_remake_desc =>
      '결과물이 만족스럽지 않으면 작가와 재제작을 협의할 수 있습니다';

  @override
  String get after_sales_type_supplement => '보충';

  @override
  String get after_sales_type_supplement_desc =>
      '결과물이 불완전하면 작가와 보충을 협의할 수 있습니다';

  @override
  String get after_sales_type_refund => '환불';

  @override
  String get after_sales_type_refund_desc => '환불 협의';

  @override
  String get after_sales_no_record_for_order => '해당 주문의 애프터서비스 내역이 없습니다';

  @override
  String after_sales_unknown_error(String error) {
    return '알 수 없는 오류: $error';
  }

  @override
  String get after_sales_server_error => '서버 오류';

  @override
  String get after_sales_cache_error => '캐시 오류';

  @override
  String get after_sales_network_error => '네트워크 연결 오류';

  @override
  String get after_sales_general_unknown_error => '알 수 없는 오류가 발생했습니다';

  @override
  String get favorites_title => '찜 목록';

  @override
  String get favorites_tab_services => '서비스';

  @override
  String get favorites_tab_sellers => '판매자';

  @override
  String get favorites_close => '닫기';

  @override
  String get favorites_empty_services => '저장된 서비스가 없습니다';

  @override
  String get favorites_empty_sellers => '팔로우한 판매자가 없습니다';

  @override
  String get favorites_empty_services_hint => '서비스를 둘러볼 때 찜 버튼을 탭하세요';

  @override
  String get favorites_empty_sellers_hint => '판매자를 둘러볼 때 팔로우 버튼을 탭하세요';

  @override
  String get favorites_unfollow => '팔로우 취소';

  @override
  String get favorites_remove => '찜 해제';

  @override
  String get favorites_seller_type_member => '개인 판매자';

  @override
  String get favorites_seller_type_enterprise => '기업 판매자';

  @override
  String get favorites_seller_type_platform => '플랫폼 판매자';

  @override
  String get favorites_seller_type_default => '판매자';

  @override
  String get favorites_status_active => '활성';

  @override
  String get favorites_status_inactive => '비활성';

  @override
  String get favorites_status_suspended => '정지됨';

  @override
  String get favorites_status_banned => '차단됨';

  @override
  String ai_docs_chat_create_failed(String error) {
    return '채팅 세션 생성 실패: $error';
  }

  @override
  String get ai_docs_chat_room_empty => '채팅방 ID가 없어 채팅에 입장할 수 없습니다';

  @override
  String ai_docs_chat_enter_error(String error) {
    return '채팅 입장 오류: $error';
  }

  @override
  String get ai_docs_rate_limit_details => '사용 횟수 상세';

  @override
  String ai_docs_rate_limit_remaining(int count) {
    return '남은 횟수 $count회';
  }

  @override
  String ai_docs_rate_limit_reset_in(String time) {
    return '$time 후 초기화';
  }

  @override
  String get ai_docs_rate_limit_rules => '사용 규칙';

  @override
  String get ai_docs_rate_limit_burst => '순간 한도';

  @override
  String get ai_docs_rate_limit_hourly => '시간당 한도';

  @override
  String get ai_docs_rate_limit_upgrade => '더 많은 횟수를 위해 업그레이드';

  @override
  String get ai_docs_rate_limit_upgrade_coming => '업그레이드 기능 출시 예정';

  @override
  String ai_docs_rate_limit_time_hours(int hours) {
    return '$hours시간';
  }

  @override
  String ai_docs_rate_limit_time_minutes(int minutes) {
    return '$minutes분';
  }

  @override
  String ai_docs_rate_limit_time_seconds(int seconds) {
    return '$seconds초';
  }

  @override
  String get ai_docs_rate_limit_reset => '초기화됨';

  @override
  String get ai_docs_rate_limit_warning_title => '사용 횟수 부족';

  @override
  String get ai_docs_rate_limit_today_remaining => '오늘 남은 횟수';

  @override
  String ai_docs_rate_limit_remaining_info(int count, String time) {
    return '$count회 남음, $time 후 초기화';
  }

  @override
  String get ai_docs_rate_limit_today_usage => '오늘 사용 현황';

  @override
  String get auth_verification_code_expired => '인증 코드가 만료되었습니다';

  @override
  String get auth_get_verification_code => '인증 코드 받기';

  @override
  String get home_image_load_failed => '이미지 불러오기 실패';

  @override
  String get home_reached_end => '마지막 항목입니다';

  @override
  String get home_reviews_title => '리뷰';

  @override
  String home_reviews_load_failed(String error) {
    return '불러오기 실패: $error';
  }

  @override
  String get home_reviews_no_reviews => '아직 리뷰가 없습니다';

  @override
  String get home_reviews_default_content => '좋아요, 매우 친절합니다';

  @override
  String get home_reviews_seller_reply => '판매자 답변';

  @override
  String home_reviews_years_ago(int count) {
    return '$count년 전';
  }

  @override
  String home_reviews_months_ago(int count) {
    return '$count달 전';
  }

  @override
  String home_reviews_days_ago(int count) {
    return '$count일 전';
  }

  @override
  String home_reviews_hours_ago(int count) {
    return '$count시간 전';
  }

  @override
  String home_reviews_minutes_ago(int count) {
    return '$count분 전';
  }

  @override
  String get home_reviews_just_now => '방금';

  @override
  String get after_sales_apply_title => '애프터서비스 신청';

  @override
  String get after_sales_select_reason_hint => '애프터서비스 사유를 선택해 주세요';

  @override
  String get after_sales_select_reason_validator => '애프터서비스 사유를 선택해 주세요';

  @override
  String after_sales_refund_amount_hint(String symbol, String amount) {
    return '최대 환불 가능 금액 $symbol$amount';
  }

  @override
  String get after_sales_refund_amount_required => '환불 금액을 입력해 주세요';

  @override
  String get after_sales_refund_amount_invalid => '유효한 금액을 입력해 주세요';

  @override
  String get after_sales_refund_amount_positive => '환불 금액은 0보다 커야 합니다';

  @override
  String after_sales_refund_amount_exceed(String symbol, String amount) {
    return '환불 금액은 $symbol$amount을 초과할 수 없습니다';
  }

  @override
  String after_sales_upload_evidence(int max) {
    return '증거 이미지 업로드 (최대 $max장)';
  }

  @override
  String after_sales_image_process_success(int count, String ratio) {
    return '$count장 이미지 처리 완료, 평균 $ratio% 압축';
  }

  @override
  String after_sales_image_process_failed(int count) {
    return '$count장의 이미지 처리 실패';
  }

  @override
  String after_sales_detail_load_failed(String error) {
    return '불러오기 실패: $error';
  }

  @override
  String get after_sales_detail_initializing => '초기화 중...';

  @override
  String get after_sales_info_title => '애프터서비스 정보';

  @override
  String get after_sales_info_order_number => '신청 번호';

  @override
  String get after_sales_info_apply_time => '신청 시간';

  @override
  String get after_sales_info_refund_amount => '환불 금액';

  @override
  String get after_sales_info_reason => '신청 사유';

  @override
  String get after_sales_info_description => '상세 설명';

  @override
  String get after_sales_info_audit_remark => '심사 비고';

  @override
  String after_sales_list_load_failed(String error) {
    return '불러오기 실패: $error';
  }

  @override
  String get after_sales_list_empty => '애프터서비스 내역이 없습니다';

  @override
  String get after_sales_list_loading => '불러오는 중...';

  @override
  String get after_sales_list_unknown_product => '알 수 없는 상품';

  @override
  String after_sales_list_status(String status) {
    return '상태: $status';
  }

  @override
  String after_sales_list_apply_time(String time) {
    return '신청 시간: $time';
  }

  @override
  String get after_sales_select_type_title => '애프터서비스 유형 선택';

  @override
  String get after_sales_type_remake_title => '재제작 요청';

  @override
  String get after_sales_type_remake_subtitle =>
      '결과물이 만족스럽지 않으면 작가와 재제작을 협의할 수 있습니다';

  @override
  String get after_sales_type_supplement_title => '보충 요청';

  @override
  String get after_sales_type_supplement_subtitle =>
      '결과물이 불완전하면 작가와 보충을 협의할 수 있습니다';

  @override
  String get after_sales_type_refund_title => '환불 요청';

  @override
  String get after_sales_type_refund_subtitle => '환불 협의';

  @override
  String get favorites_seller_status_active => '활성';

  @override
  String get favorites_seller_status_inactive => '비활성';

  @override
  String get favorites_seller_status_suspended => '정지됨';

  @override
  String get favorites_seller_status_banned => '차단됨';

  @override
  String get app_store_settings => '상점 설정';

  @override
  String get app_wallet => '지갑';

  @override
  String get app_wallet_init_failed => '지갑 페이지 초기화 실패';

  @override
  String get app_error_label => '오류';

  @override
  String get app_go_back => '뒤로 가기';

  @override
  String get app_page_not_found => '페이지를 찾을 수 없습니다';

  @override
  String get app_path_error => '경로 오류';

  @override
  String get app_error_generic => '오류';

  @override
  String get app_dev_menu_title => '개발자 디버그 메뉴';

  @override
  String get app_dev_common_entries => '공통 입구';

  @override
  String get app_dev_dskk => '다수칸칸';

  @override
  String get app_dev_order_module_buyer => '주문 모듈 (구매자)';

  @override
  String get app_dev_order_list => '주문 목록';

  @override
  String get app_dev_order_detail_example => '주문 상세 (예시)';

  @override
  String get app_dev_order_module_seller => '주문 모듈 (판매자)';

  @override
  String get app_dev_seller_order_list => '판매자 주문 목록';

  @override
  String get app_dev_seller_order_detail_example => '판매자 주문 상세 (예시)';

  @override
  String get app_dev_seller_module => '판매자 모듈';

  @override
  String get app_dev_seller_center => '판매자 센터 (홈)';

  @override
  String get app_dev_ai_docs_module => 'AI Docs 모듈';

  @override
  String get app_dev_ai_chat => 'AI 채팅';

  @override
  String get app_dev_test_other => '테스트/기타';

  @override
  String get app_dev_current_credentials => '현재 테스트 자격증명 (하드코딩): ';

  @override
  String get app_dev_temp_injection => '(임시 주입, Auth 모듈 통합 후 제거 예정)';

  @override
  String app_dev_navigation_failed(String path, String error) {
    return '이동 실패: $path - $error';
  }

  @override
  String get core_processing => '처리 중...';

  @override
  String get core_yesterday => '어제';

  @override
  String get payment_test_title => '결제 기능 테스트';

  @override
  String get payment_check_availability => '결제 수단 가용성 확인';

  @override
  String get payment_test_params => '테스트 파라미터';

  @override
  String get payment_order_number => '주문 번호';

  @override
  String get payment_amount_yuan => '금액';

  @override
  String get payment_product_name => '상품명';

  @override
  String get payment_select_method => '결제 수단 선택';

  @override
  String payment_test_button(String method, String amount) {
    return '$method ¥$amount 테스트';
  }

  @override
  String get payment_usage_instructions => '사용 안내';

  @override
  String get payment_instruction_1 => '1. 위의 테스트 파라미터 수정';

  @override
  String get payment_instruction_2 => '2. 테스트할 결제 수단 선택';

  @override
  String get payment_instruction_3 => '3. 테스트 버튼을 눌러 결제 시작';

  @override
  String get payment_instruction_4 => '4. 오른쪽 상단 정보 버튼을 눌러 결제 수단 가용성 확인';

  @override
  String get payment_test_warning => '알림: 테스트 환경에서는 0.01로 테스트하는 것을 권장합니다';

  @override
  String get payment_test_product => '테스트 상품';

  @override
  String payment_initiated_success(String message) {
    return '결제 시작됨: $message';
  }

  @override
  String payment_failed_message(String message) {
    return '결제 실패: $message';
  }

  @override
  String payment_exception(String error) {
    return '결제 오류: $error';
  }

  @override
  String get payment_availability_title => '결제 수단 가용성';

  @override
  String get payment_alipay => '알리페이';

  @override
  String get payment_wechat => '위챗페이';

  @override
  String get payment_wallet_balance => '잔액 결제';

  @override
  String get payment_confirm => '확인';

  @override
  String payment_check_failed(String error) {
    return '확인 실패: $error';
  }

  @override
  String get payment_alipay_subtitle => '빠르고 안전한 결제';

  @override
  String get payment_wechat_subtitle => '위챗 안전 결제';

  @override
  String get payment_amount_label => '결제 금액:';

  @override
  String get payment_terms_agreement =>
      '\"결제 확인\"을 누르면 관련 이용약관에 동의하는 것으로 간주됩니다';

  @override
  String get payment_create_order_failed => '결제 주문 생성 실패';

  @override
  String get payment_method_test_title => '결제 수단 테스트';

  @override
  String get payment_alipay_pay => '알리페이 결제';

  @override
  String get payment_test_functions => '테스트 기능';

  @override
  String get payment_test_alipay => '알리페이 결제 테스트';

  @override
  String get payment_test_wechat => '위챗페이 테스트';

  @override
  String get payment_test_credit_card => '신용카드 결제 테스트';

  @override
  String get payment_recent_test_result => '최근 테스트 결과';

  @override
  String get payment_no_test_result => '테스트 결과 없음';

  @override
  String get payment_available => '사용 가능';

  @override
  String get payment_unavailable => '사용 불가';

  @override
  String payment_method_label(String name) {
    return '결제 수단: $name';
  }

  @override
  String get payment_mock_mode => '목 모드';

  @override
  String payment_error_label(String error) {
    return '오류: $error';
  }

  @override
  String get payment_nav_network_failed => '네트워크 연결 실패';

  @override
  String get payment_nav_network_error_message =>
      '네트워크 오류가 발생했습니다. 연결을 확인 후 다시 시도해 주세요';

  @override
  String get payment_nav_view_orders => '주문 보기';

  @override
  String get payment_nav_retry_payment => '결제 재시도';

  @override
  String get payment_nav_result_unknown_title => '결제 결과 미확인';

  @override
  String get payment_nav_result_unknown_message =>
      '결제 결과를 확인할 수 없습니다. 잠시 후 주문 상태를 확인하거나 고객센터에 문의해 주세요';

  @override
  String get payment_nav_query_status => '상태 조회';

  @override
  String get payment_nav_cancel_continue => '결제를 취소하셨습니다. 계속 결제를 완료할 수 있습니다';

  @override
  String get payment_nav_processing => '결제 처리 중입니다. 잠시 후 주문 상태를 확인해 주세요';

  @override
  String get payment_nav_success => '결제 성공';

  @override
  String get payment_nav_failed => '결제 실패';

  @override
  String get payment_nav_retrying => '결제 재시도 중...';

  @override
  String get payment_nav_retry_failed => '결제 재시도 불가, 주문 정보 손실';

  @override
  String get payment_nav_querying => '결제 상태 조회 중...';

  @override
  String get payment_nav_query_failed => '상태 조회 불가, 주문 정보 손실';

  @override
  String payment_test_description(String subject) {
    return '$subject - 결제 테스트';
  }

  @override
  String get chat_translating => '번역 중...';

  @override
  String get chat_translation_label => '번역';

  @override
  String get after_sales_info_evidence => '증거 자료';
}
