// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get language_settings => '言語設定';

  @override
  String get system_language => 'システムに従う';

  @override
  String get system_language_description => 'デバイスの言語設定を自動的に使用します';

  @override
  String get ai_docs_assistant_title => 'AIアシスタント';

  @override
  String get ai_docs_unnamed_conversation => '名称未設定の会話';

  @override
  String get ai_docs_loading => '読み込み中...';

  @override
  String get ai_docs_match_button => 'マッチング';

  @override
  String get ai_docs_select_conversation_first => 'まず会話を選択してください';

  @override
  String get ai_docs_please_enter_message => 'メッセージを入力してください';

  @override
  String get ai_docs_recommended_services => 'おすすめサービス';

  @override
  String ai_docs_recommendations_error(String error) {
    return 'おすすめサービスの読み込みに失敗しました: $error';
  }

  @override
  String get ai_docs_no_recommendations => 'おすすめサービスはありません';

  @override
  String get ai_docs_dispatched => '送信済み';

  @override
  String get ai_docs_enter_chat => 'チャットへ';

  @override
  String get ai_docs_let_them_see => '見てもらう';

  @override
  String get ai_docs_welcome_title => 'AIアシスタントへようこそ';

  @override
  String get ai_docs_welcome_message =>
      'メッセージを送信すると会話が始まります。チャットルームは自動的に作成されます';

  @override
  String get ai_docs_auto_create_text =>
      '会話が選択されていないため、新しい会話を自動作成してメッセージを送信します';

  @override
  String get ai_docs_auto_create_voice =>
      '会話が選択されていないため、新しい会話を自動作成して音声メッセージを送信します';

  @override
  String get ai_docs_cancelling_generation => '生成をキャンセル中...';

  @override
  String get allocating_step1 => '送信中';

  @override
  String get allocating_step2 => '送信中.';

  @override
  String get allocating_step3 => '送信中..';

  @override
  String get allocating_step4 => '送信中...';

  @override
  String get ai_docs_add_image => '画像を追加';

  @override
  String get ai_docs_stop_recording => '録音を停止';

  @override
  String get ai_docs_start_recording => '音声を録音';

  @override
  String get ai_docs_recording => '録音中...タップして停止・送信';

  @override
  String get ai_docs_enter_message => 'メッセージを入力...';

  @override
  String get ai_docs_stop_generation => '生成を停止';

  @override
  String get ai_docs_send_message => '送信';

  @override
  String get ai_docs_uploading_images => '画像をアップロード中です。しばらくお待ちください...';

  @override
  String get ai_docs_mic_permission_denied => 'マイクの権限が拒否されました';

  @override
  String ai_docs_recording_error(String error) {
    return '録音の開始に失敗しました: $error';
  }

  @override
  String get ai_docs_recording_file_not_found => 'エラー：録音ファイルが見つかりません';

  @override
  String get ai_docs_stop_recording_error => '録音の停止に失敗しました';

  @override
  String ai_docs_stop_recording_error_with_reason(String error) {
    return '録音の停止に失敗しました: $error';
  }

  @override
  String ai_docs_image_picking_error(String error) {
    return '画像の選択に失敗しました: $error';
  }

  @override
  String get ai_docs_conversation_list => '会話一覧';

  @override
  String get ai_docs_no_messages => 'メッセージはありません。チャットを始めましょう！';

  @override
  String get ai_docs_new_chat => '新しいチャット';

  @override
  String get ai_docs_load_conversations_failed => '会話の読み込みに失敗しました';

  @override
  String get ai_docs_retry => '再試行';

  @override
  String get ai_docs_no_conversations => '会話はありません';

  @override
  String get ai_docs_delete_conversation_tooltip => '会話を削除';

  @override
  String get ai_docs_delete_conversation_title => '会話を削除しますか？';

  @override
  String get ai_docs_delete_conversation_content => 'この会話を完全に削除しますか？';

  @override
  String get ai_docs_cancel => 'キャンセル';

  @override
  String get ai_docs_delete => '削除';

  @override
  String get ai_docs_please_select_conversation_to_delete =>
      '削除する会話を先に選択してください';

  @override
  String get ai_docs_generate_title => 'AIでタイトルを生成';

  @override
  String get ai_docs_generate_title_tooltip => 'AIがこの会話のタイトルを生成します';

  @override
  String get ai_docs_generating_title => 'タイトルを生成中...';

  @override
  String get ai_docs_title_generated => 'タイトルが生成されました';

  @override
  String ai_docs_title_generation_failed(String error) {
    return 'タイトルの生成に失敗しました: $error';
  }

  @override
  String get ai_docs_edit_title => 'タイトルを編集';

  @override
  String get ai_docs_edit_title_hint => '新しいタイトルを入力してください';

  @override
  String get ai_docs_title_updated => 'タイトルが更新されました';

  @override
  String ai_docs_title_update_failed(String error) {
    return 'タイトルの更新に失敗しました: $error';
  }

  @override
  String get ai_docs_title_too_long => 'タイトルは50文字以内にしてください';

  @override
  String get ai_docs_title_empty => 'タイトルは空にできません';

  @override
  String get nav_ai_assistant => 'DeepStream';

  @override
  String get nav_home => 'ホーム';

  @override
  String get nav_messages => 'メッセージ';

  @override
  String get nav_profile => 'マイページ';

  @override
  String get nav_dev => '開発';

  @override
  String get nav_seller_analytics => 'データ';

  @override
  String get nav_seller_products => '商品';

  @override
  String get nav_seller_messages => 'メッセージ';

  @override
  String get nav_seller_profile => 'マイページ';

  @override
  String get chat_list_title => 'チャット一覧';

  @override
  String get chat_loading => '読み込み中...';

  @override
  String chat_error_loading(String error) {
    return '読み込みに失敗しました: $error';
  }

  @override
  String get chat_no_messages => 'メッセージはありません。チャットを始めましょう！';

  @override
  String get chat_admin_title => 'システム管理者';

  @override
  String get chat_notification_center => '通知センター';

  @override
  String get chat_notification_description => 'システム・注文・レビューなどの重要なお知らせ';

  @override
  String get chat_enter_message => 'メッセージを入力...';

  @override
  String get chat_yesterday => '昨日';

  @override
  String get chat_image_message => '[画像]';

  @override
  String get chat_audio_message => '[音声]';

  @override
  String get chat_file_message => '【ファイル】';

  @override
  String get chat_allocate_message => '【DeepStream】';

  @override
  String get chat_payment_prompt_message => '【支払いリクエスト】';

  @override
  String get chat_revoked_message => '[メッセージが取り消されました]';

  @override
  String get chat_unknown_message => '[不明なメッセージ]';

  @override
  String get chat_unsupported_message => 'このメッセージはまだ表示できません';

  @override
  String get chat_unknown_user => '不明なユーザー';

  @override
  String get chat_invalid_session => '無効なセッション';

  @override
  String get chat_opponent_not_found => '相手の情報が見つかりません';

  @override
  String get chat_message_recalled => 'メッセージが取り消されました';

  @override
  String get chat_copy => 'コピー';

  @override
  String get chat_recall => '取り消し';

  @override
  String get chat_copied_to_clipboard => 'クリップボードにコピーしました';

  @override
  String get chat_me => '自分';

  @override
  String get chat_buyer => '購入者';

  @override
  String get chat_i_want_seller_to_see => '出品者に見てもらいたい';

  @override
  String get chat_wants_to_see => '見たい';

  @override
  String get chat_collapse => '折りたたむ';

  @override
  String get chat_expand => '展開する';

  @override
  String get chat_summary_hidden => 'この要約は生成に失敗したため非表示にしました';

  @override
  String get chat_admin_connection_error => 'システム管理者に接続できません';

  @override
  String get chat_audio_pause => '一時停止';

  @override
  String get chat_audio_play => '再生';

  @override
  String get chat_markdown_example_title1 => '見出し1';

  @override
  String get chat_markdown_example_title2 => '見出し2';

  @override
  String get chat_markdown_example_bold_italic => 'これは**太字**テキストと*斜体*テキストです。';

  @override
  String get chat_markdown_example_list1 => 'リスト項目1';

  @override
  String get chat_markdown_example_list2 => 'リスト項目2';

  @override
  String get chat_markdown_example_list3 => 'ネストされたリスト項目';

  @override
  String get chat_markdown_example_quote => 'これは引用テキストです。複数行の表示に対応しています';

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
  String get chat_pick_from_gallery => 'ギャラリーから選択';

  @override
  String get chat_take_photo => '写真を撮る';

  @override
  String get chat_send_markdown => 'Markdownサンプルを送信';

  @override
  String get chat_switch_to_text => 'テキスト入力に切り替え';

  @override
  String get chat_switch_to_voice => '音声入力に切り替え';

  @override
  String get chat_send => '送信';

  @override
  String get chat_attach => '画像/ファイルを送信';

  @override
  String get chat_filter_all => 'すべて';

  @override
  String get chat_filter_buyer => '買い手チャット';

  @override
  String get chat_filter_seller => '売り手チャット';

  @override
  String get chat_filter_mode_all => 'すべてのチャットを表示';

  @override
  String get chat_filter_mode_buyer => '買い手チャットのみ表示';

  @override
  String get chat_filter_mode_seller => '売り手チャットのみ表示';

  @override
  String get chat_press_to_talk => '押して話す';

  @override
  String chat_release_to_send(int duration) {
    return '離して送信 ($duration秒)';
  }

  @override
  String get chat_camera_permission_denied_title => 'カメラの権限が無効です';

  @override
  String get chat_camera_permission_denied_message =>
      '写真を撮るには、システム設定でカメラの権限を手動で有効にしてください。';

  @override
  String get chat_mic_permission_denied_title => 'マイクの権限が無効です';

  @override
  String get chat_mic_permission_denied_message =>
      '録音するには、システム設定でマイクの権限を手動で有効にしてください。';

  @override
  String get chat_permission_denied_cancel => 'キャンセル';

  @override
  String get chat_permission_denied_settings => '設定へ';

  @override
  String get chat_mic_permission_denied => 'マイクの権限がないため、録音できません';

  @override
  String get chat_camera_permission_denied => 'カメラの権限がないため、写真を撮れません';

  @override
  String chat_recording_error(String error) {
    return '録音を開始できません: $error';
  }

  @override
  String chat_stop_recording_error(String error) {
    return '録音の停止に失敗しました: $error';
  }

  @override
  String chat_image_picking_error(String error) {
    return '画像の選択に失敗しました: $error';
  }

  @override
  String get chat_web_recording_not_supported =>
      'Webプラットフォームでは録音機能はサポートされていません';

  @override
  String get profile_personal_center => 'マイページ';

  @override
  String get profile_login_prompt => 'プロフィールを表示するにはログインしてください';

  @override
  String get profile_login_button => 'ログインする';

  @override
  String get auth_phone_number => '電話番号';

  @override
  String get auth_select_country_region => '国/地域を選択';

  @override
  String get auth_phone_validation_empty => '電話番号を入力してください';

  @override
  String get auth_phone_validation_invalid_cn => '11桁の電話番号を入力してください';

  @override
  String get auth_phone_validation_invalid_cn_start => '電話番号は1から始まる必要があります';

  @override
  String get auth_phone_validation_invalid_us => '10桁の電話番号を入力してください';

  @override
  String get auth_phone_validation_invalid_jp_kr => '10桁または11桁の電話番号を入力してください';

  @override
  String get auth_phone_validation_invalid_general => '有効な電話番号を入力してください';

  @override
  String profile_loading_error(String error) {
    return '読み込みに失敗しました: $error';
  }

  @override
  String get profile_my_dskk => 'マイDSKK';

  @override
  String get profile_favorites => 'お気に入り';

  @override
  String get profile_my_wallet => 'ウォレット';

  @override
  String get profile_wallet => 'ウォレット';

  @override
  String get profile_settings => '設定';

  @override
  String get profile_account_security => 'アカウントとセキュリティ';

  @override
  String get profile_message_notifications => '通知設定';

  @override
  String get profile_about_us => '会社について';

  @override
  String get profile_assistant_mission => 'アシスタントのミッション';

  @override
  String get profile_switch_to_seller => '出品者モードに切り替え';

  @override
  String profile_switch_error(String error) {
    return '出品者モードに切り替えできません: $error';
  }

  @override
  String get profile_edit_nickname => 'ニックネームを変更';

  @override
  String get profile_nickname_hint => '新しいニックネームを入力してください';

  @override
  String get profile_nickname_empty_error => 'ニックネームは必須です';

  @override
  String get profile_nickname_length_error => 'ニックネームは20文字以内にしてください';

  @override
  String get profile_cancel => 'キャンセル';

  @override
  String get profile_save => '保存';

  @override
  String get profile_default_name => 'ユーザー';

  @override
  String get profile_online => 'オンライン';

  @override
  String get profile_offline => 'オフライン';

  @override
  String get profile_avatar_upload_failed => 'アバターのアップロードに失敗しました。もう一度お試しください';

  @override
  String get profile_orders => '注文履歴';

  @override
  String get profile_pending_payment => '支払い待ち';

  @override
  String get profile_in_progress => '提出待ち';

  @override
  String get profile_completed => '受取待ち';

  @override
  String get profile_refund => 'アフターサービス';

  @override
  String profile_navigation_error(String error) {
    return '注文一覧への移動に失敗しました: $error';
  }

  @override
  String get home_title => 'ホーム';

  @override
  String get home_search_hint => 'サービスを検索';

  @override
  String get home_loading => '読み込み中...';

  @override
  String home_loading_failed(String error) {
    return '読み込みに失敗しました: $error';
  }

  @override
  String get home_retry => '再試行';

  @override
  String get home_end_of_list => '最後まで表示しました';

  @override
  String get home_no_content => 'おすすめコンテンツはありません';

  @override
  String get home_pull_to_refresh => '引っ張って更新し、おすすめを表示';

  @override
  String get home_refreshing_recommendations => 'おすすめを更新中...';

  @override
  String get home_loading_more => 'さらに読み込み中...';

  @override
  String get home_back_to_top_refresh => 'トップに戻って更新';

  @override
  String home_banner_clicked(String targetType, String targetValue) {
    return 'バナーをタップしました: $targetType - $targetValue';
  }

  @override
  String home_product_card_clicked(String name) {
    return 'サービスカードをタップしました: $name';
  }

  @override
  String home_recommend_clicked(String name) {
    return '「見てもらう」ボタンをタップしました: $name';
  }

  @override
  String get product_recommend_button => '見てもらう';

  @override
  String get product_image_loading_failed => '画像の読み込みに失敗しました';

  @override
  String get product_default_name => '商品';

  @override
  String get search_title => '検索';

  @override
  String get search_button => '検索';

  @override
  String get search_hot_keywords => '急上昇ワード';

  @override
  String get search_history => '検索履歴';

  @override
  String get search_no_results => '関連するサービスが見つかりませんでした';

  @override
  String search_failed(String error) {
    return '検索に失敗しました: $error';
  }

  @override
  String product_detail_loading_failed(String error) {
    return '読み込みに失敗しました: $error';
  }

  @override
  String get product_detail_retry => '再試行';

  @override
  String get product_detail_please_wait => '少々お待ちください...';

  @override
  String get product_detail_contact_seller => '出品者に問い合わせる';

  @override
  String get product_detail_verified_label => '認証済み';

  @override
  String get product_detail_published_status => '公開中';

  @override
  String get product_detail_more => 'もっと見る';

  @override
  String get product_detail_collapse => '折りたたむ';

  @override
  String get product_detail_delivery_times => '納品回数';

  @override
  String get product_detail_delivery_period => '納期';

  @override
  String get product_detail_buy_now => '今すぐ購入(1)';

  @override
  String product_detail_buy_now_with_price(String price) {
    return '今すぐ購入 ¥$price';
  }

  @override
  String get product_detail_faq => 'よくある質問';

  @override
  String get product_detail_case_showcase => '事例紹介';

  @override
  String get product_detail_no_cases => '事例はまだありません';

  @override
  String product_detail_reviews(int count) {
    return 'レビュー($count件)';
  }

  @override
  String get product_detail_view_all => 'すべて見る';

  @override
  String get product_detail_no_reviews => 'レビューはまだありません';

  @override
  String get product_detail_basic_package => 'ベーシック';

  @override
  String get product_detail_standard_package => 'スタンダード';

  @override
  String get product_detail_premium_package => 'プレミアム';

  @override
  String get product_detail_basic_tier => 'ベーシック';

  @override
  String get product_detail_standard_tier => 'スタンダード';

  @override
  String get product_detail_premium_tier => 'プレミアム';

  @override
  String get product_detail_sample_review => '丁寧で良かったです';

  @override
  String get product_detail_sample_user => 'ユーザー123';

  @override
  String get product_reviews_title => 'レビュー';

  @override
  String product_reviews_loading_failed(String error) {
    return '読み込みに失敗しました: $error';
  }

  @override
  String get product_reviews_retry => '再試行';

  @override
  String get product_reviews_no_reviews => 'レビューはまだありません';

  @override
  String get product_reviews_sample_content => '丁寧で良かったです';

  @override
  String product_reviews_years_ago(int count) {
    return '$count年前';
  }

  @override
  String product_reviews_months_ago(int count) {
    return '$countヶ月前';
  }

  @override
  String product_reviews_days_ago(int count) {
    return '$count日前';
  }

  @override
  String product_reviews_hours_ago(int count) {
    return '$count時間前';
  }

  @override
  String product_reviews_minutes_ago(int count) {
    return '$count分前';
  }

  @override
  String get product_reviews_just_now => 'たった今';

  @override
  String get product_reviews_seller_reply => '出品者の返信';

  @override
  String product_reviews_total_count(int count) {
    return '全$count件のレビュー';
  }

  @override
  String get product_reviews_filter_all => 'すべて';

  @override
  String get product_reviews_filter_with_images => '画像あり';

  @override
  String get product_reviews_filter_good => '高評価';

  @override
  String get product_reviews_filter_medium => '普通';

  @override
  String get product_reviews_filter_bad => '低評価';

  @override
  String get seller_profile_default_title => '出品者ページ';

  @override
  String get seller_profile_seller => '出品者';

  @override
  String get seller_profile_no_description => '説明はまだありません';

  @override
  String seller_profile_followers(int count) {
    return '$count人のフォロワー';
  }

  @override
  String get seller_profile_followed => 'フォロー中';

  @override
  String get seller_profile_follow => 'フォローする';

  @override
  String get seller_profile_unfollow_success => 'フォローを解除しました';

  @override
  String get seller_profile_follow_success => 'フォローしました';

  @override
  String seller_profile_chat_failed(String error) {
    return 'チャットの作成に失敗しました: $error';
  }

  @override
  String seller_profile_error_occurred(String error) {
    return 'エラーが発生しました: $error';
  }

  @override
  String get seller_profile_about_merchant => '出品者について';

  @override
  String get seller_profile_my_services => '提供サービス';

  @override
  String get seller_profile_no_merchant_info => '出品者情報はありません';

  @override
  String get seller_profile_member_level => '会員ランク';

  @override
  String get seller_profile_level_two => 'シルバー会員';

  @override
  String get seller_profile_seller_rating => '出品者評価';

  @override
  String get seller_profile_response_time => '返信時間';

  @override
  String get seller_profile_response_hours => '3時間';

  @override
  String get seller_profile_certification_status => '認証状態';

  @override
  String get seller_profile_certified => '認証済み';

  @override
  String get seller_profile_not_certified => '未認証';

  @override
  String get seller_profile_no_products => '商品はまだありません';

  @override
  String get seller_profile_image_load_failed => '画像の読み込みに失敗しました';

  @override
  String get seller_profile_no_image => '画像はありません';

  @override
  String get seller_profile_title => 'マイページ';

  @override
  String get seller_profile_auth_management => '認証管理';

  @override
  String get seller_profile_my_wallet => 'ウォレット';

  @override
  String get seller_profile_time_management => 'スケジュール管理';

  @override
  String get seller_profile_settings => '設定';

  @override
  String get seller_profile_notifications => '通知設定';

  @override
  String get seller_profile_about_us => '会社について';

  @override
  String get seller_profile_mission => 'アシスタントのミッション';

  @override
  String get seller_profile_user_name => 'ユーザー';

  @override
  String get seller_profile_seller_mode_online => '出品者モード：オンライン';

  @override
  String get seller_profile_seller_mode_offline => '出品者モード：オフライン';

  @override
  String get seller_profile_seller_mode => '出品者モード';

  @override
  String get seller_profile_buyer_mode => '購入者モード';

  @override
  String get seller_profile_my_orders => '注文管理';

  @override
  String get seller_profile_order_pending => '確認待ち';

  @override
  String get seller_profile_order_processing => '進行中';

  @override
  String get seller_profile_order_delivered => '納品済み';

  @override
  String get seller_profile_order_refund => '返金/アフターサービス';

  @override
  String seller_profile_feature_not_implemented(String feature) {
    return '$feature機能はまだ実装されていません';
  }

  @override
  String get seller_home_loading_failed => '読み込みに失敗しました';

  @override
  String get seller_home_no_data => 'データはありません';

  @override
  String get seller_home_no_store_info => 'ショップ情報はありません';

  @override
  String get seller_home_online => 'オンライン';

  @override
  String get seller_home_offline => 'オフライン';

  @override
  String seller_home_completion_rate(String rate) {
    return '完了率 $rate%';
  }

  @override
  String get seller_home_switch_to_buyer => '購入者モードに切り替え';

  @override
  String seller_home_switch_failed(String error) {
    return '購入者モードに切り替えできません: $error';
  }

  @override
  String get seller_home_income => '収益';

  @override
  String get seller_home_view_details => '明細を見る';

  @override
  String get seller_home_total_income => '総収益';

  @override
  String get seller_home_today_income => '本日の収益';

  @override
  String get seller_home_pending_settlement => '精算待ち';

  @override
  String get seller_home_orders => '注文';

  @override
  String get seller_home_view_all => 'すべて見る';

  @override
  String get seller_home_orders_all => 'すべて';

  @override
  String get seller_home_orders_pending => '処理待ち';

  @override
  String get seller_home_orders_processing => '進行中';

  @override
  String get seller_home_orders_aftersales => 'アフターサービス中';

  @override
  String get seller_home_orders_awaiting_delivery => '発送待ち';

  @override
  String get seller_home_orders_completed => '完了';

  @override
  String get seller_home_orders_canceled => 'キャンセル済み';

  @override
  String get seller_home_functions => '機能';

  @override
  String get seller_home_wallet => 'ウォレット';

  @override
  String get seller_home_auth_management => '認証管理';

  @override
  String get seller_home_time_management => 'スケジュール管理';

  @override
  String get seller_home_auto_reply => '自動返信';

  @override
  String get seller_home_provider_task_center => '受付タスク';

  @override
  String get seller_home_recent_income => '最近の収益';

  @override
  String get seller_home_no_recent_income => '最近の収益データはありません';

  @override
  String get seller_home_no_income_data => '収益データはありません';

  @override
  String get seller_statistics_title => '出品者データ';

  @override
  String get seller_statistics_seller_homepage => '出品者ページ';

  @override
  String get seller_statistics_heat_value => '人気度';

  @override
  String get seller_statistics_reply_rate => '返信率';

  @override
  String get seller_statistics_completion_rate => '完了率';

  @override
  String get seller_statistics_positive_rate => '高評価率';

  @override
  String get seller_statistics_upgrade_to_next_level => '次のレベルへアップ';

  @override
  String seller_statistics_become_level3_seller(String days) {
    return 'レベル3会員になってから$days日';
  }

  @override
  String seller_statistics_complete_orders(String orderNum) {
    return '注文完了数: $orderNum件';
  }

  @override
  String seller_statistics_profit_amount(String amount) {
    return '収益額: $amount円';
  }

  @override
  String get seller_statistics_indicators => '指標';

  @override
  String get seller_statistics_total_earnings => '総収益';

  @override
  String get seller_statistics_monthly_earnings => '今月の収益';

  @override
  String get seller_statistics_total_orders => '総注文数';

  @override
  String get seller_statistics_active_orders => '進行中の注文数';

  @override
  String get seller_statistics_pending => '処理待ち';

  @override
  String get seller_statistics_incomplete_orders => '未完了の注文数';

  @override
  String get seller_statistics_pending_completion => '完了待ち';

  @override
  String get seller_statistics_receipt => '領収書';

  @override
  String get seller_statistics_next_delivery_date => '次の納品予定まで';

  @override
  String get seller_statistics_earliest => '最短';

  @override
  String seller_statistics_loading_failed(String error) {
    return '読み込みに失敗しました: $error';
  }

  @override
  String get seller_statistics_retry => '再試行';

  @override
  String get seller_auth_management_title => '認証管理';

  @override
  String get seller_auth_management_certified_items => '認証済み項目';

  @override
  String get seller_auth_management_open_certification => '認証を申請する';

  @override
  String get seller_auth_management_no_items => '認証済み項目はありません';

  @override
  String get seller_auth_management_unknown_status => '不明なステータス';

  @override
  String get seller_auth_management_certified => '認証済み';

  @override
  String get seller_auth_management_pending => '審査中';

  @override
  String get seller_auth_management_rejected => '否認';

  @override
  String get seller_auth_management_not_submitted => '未提出';

  @override
  String get seller_auth_management_server_timeout => 'サーバーがタイムアウトしました';

  @override
  String get seller_auth_management_server_timeout_desc =>
      'サーバーの処理に時間がかかっています。しばらくしてから再試行してください';

  @override
  String get seller_auth_management_network_error => 'ネットワーク接続エラー';

  @override
  String get seller_auth_management_network_error_desc =>
      'サーバーに接続できません。ネットワーク設定を確認してください';

  @override
  String get seller_auth_management_loading_failed => '読み込みに失敗しました';

  @override
  String get seller_auth_management_unknown_error => '不明なエラーが発生しました。再試行してください';

  @override
  String get seller_auth_management_troubleshooting => 'トラブルシューティングのヒント：';

  @override
  String get seller_auth_management_check_network =>
      '• ネットワーク接続が安定しているか確認してください';

  @override
  String get seller_auth_management_wait_retry => '• 数分待ってから再試行してください';

  @override
  String get seller_auth_management_contact_support =>
      '• 問題が続く場合はサポートへお問い合わせください';

  @override
  String get seller_auth_management_check_wifi =>
      '• Wi-Fiまたはモバイルデータの接続を確認してください';

  @override
  String get seller_auth_management_switch_network => '• 別のネットワークに切り替えてみてください';

  @override
  String get seller_auth_management_restart_app => '• アプリを閉じて再起動してください';

  @override
  String get seller_auth_management_check_connection => '• ネットワーク接続状態を確認してください';

  @override
  String get seller_auth_management_try_later => '• しばらくしてから再試行してください';

  @override
  String get seller_auth_management_contact_tech =>
      '• 問題が続く場合はテクニカルサポートへお問い合わせください';

  @override
  String get seller_auth_management_reload => '再読み込み';

  @override
  String get seller_auth_management_back => '戻る';

  @override
  String seller_auth_application_title(String type) {
    return '$type認証';
  }

  @override
  String seller_auth_application_desc(String type) {
    return '$type認証の説明';
  }

  @override
  String get seller_auth_application_review_time =>
      '認証の審査には通常1〜3営業日かかります。しばらくお待ちください。';

  @override
  String get seller_auth_application_basic_info => '基本情報';

  @override
  String get seller_auth_application_company_name => '会社名';

  @override
  String get seller_auth_application_company_name_hint => '会社の正式名称を入力してください';

  @override
  String get seller_auth_application_company_name_required => '会社名を入力してください';

  @override
  String get seller_auth_application_credit_code => '統一社会信用コード';

  @override
  String get seller_auth_application_credit_code_hint =>
      '18桁の統一社会信用コードを入力してください';

  @override
  String get seller_auth_application_credit_code_required =>
      '統一社会信用コードを入力してください';

  @override
  String get seller_auth_application_credit_code_invalid =>
      '統一社会信用コードは18桁である必要があります';

  @override
  String get seller_auth_application_company_intro => '会社概要';

  @override
  String get seller_auth_application_company_intro_hint =>
      '会社の事業内容を簡潔に説明してください';

  @override
  String get seller_auth_application_real_name => '氏名';

  @override
  String get seller_auth_application_real_name_hint => '本名を入力してください';

  @override
  String get seller_auth_application_real_name_required => '氏名を入力してください';

  @override
  String get seller_auth_application_id_number => '身分証番号';

  @override
  String get seller_auth_application_id_number_hint => '18桁の身分証番号を入力してください';

  @override
  String get seller_auth_application_id_number_required => '身分証番号を入力してください';

  @override
  String get seller_auth_application_id_number_invalid => '身分証番号は18桁である必要があります';

  @override
  String get seller_auth_application_school_name => '学校名';

  @override
  String get seller_auth_application_school_name_hint => '学校の正式名称を入力してください';

  @override
  String get seller_auth_application_school_name_required => '学校名を入力してください';

  @override
  String get seller_auth_application_degree => '学歴/学位';

  @override
  String get seller_auth_application_degree_hint => '例：学士、修士など';

  @override
  String get seller_auth_application_degree_required => '学歴/学位を入力してください';

  @override
  String get seller_auth_application_major => '専攻';

  @override
  String get seller_auth_application_major_hint => '専攻名を入力してください';

  @override
  String get seller_auth_application_profession => '職業/役職';

  @override
  String get seller_auth_application_profession_hint => '職業または役職を入力してください';

  @override
  String get seller_auth_application_profession_required => '職業/役職を入力してください';

  @override
  String get seller_auth_application_cert_number => '証明書番号';

  @override
  String get seller_auth_application_cert_number_hint => '職業資格証明書の番号を入力してください';

  @override
  String get seller_auth_application_work_experience => '職務経歴';

  @override
  String get seller_auth_application_work_experience_hint => '職務経歴を簡潔に説明してください';

  @override
  String get seller_auth_application_auth_name => '認証名称';

  @override
  String get seller_auth_application_auth_name_hint => '認証名称を入力してください';

  @override
  String get seller_auth_application_auth_name_required => '認証名称を入力してください';

  @override
  String get seller_auth_application_auth_identifier => '認証識別子';

  @override
  String get seller_auth_application_auth_identifier_hint =>
      '認証識別子または番号を入力してください';

  @override
  String get seller_auth_application_auth_description => '認証説明';

  @override
  String get seller_auth_application_auth_description_hint => '認証内容を説明してください';

  @override
  String get seller_auth_application_upload_materials => '証明書類をアップロード';

  @override
  String get seller_auth_application_upload_file => 'ファイルをアップロード';

  @override
  String seller_auth_application_selected_files(int count) {
    return '$count個のファイルが選択されました';
  }

  @override
  String get seller_auth_application_selected_images => '選択された画像：';

  @override
  String get seller_auth_application_load_failed => '読み込みに失敗しました';

  @override
  String get seller_auth_application_id_upload_hint =>
      '身分証の表裏が鮮明に写った写真をアップロードしてください。情報が隠れたり修正されていないことを確認してください';

  @override
  String get seller_auth_application_education_upload_hint =>
      '学位証明書や卒業証書など、完全な情報を含む証明書類をアップロードしてください';

  @override
  String get seller_auth_application_profession_upload_hint =>
      '職業資格証明書や専門技能証明書などをアップロードしてください';

  @override
  String get seller_auth_application_company_upload_hint =>
      '営業許可証や組織コード証など、企業の資格証明書をアップロードしてください';

  @override
  String get seller_auth_application_default_upload_hint =>
      '関連する証明書類をアップロードしてください。画像が鮮明で情報が完全であることを確認してください';

  @override
  String get seller_auth_application_agreement_read => '以下を読んで同意します';

  @override
  String get seller_auth_application_agreement_link => '「認証サービス規約」';

  @override
  String get seller_auth_application_agreement_guarantee =>
      '。提供する情報が真実かつ有効であることを保証します';

  @override
  String get seller_auth_application_agreement_title => '認証サービス規約';

  @override
  String get seller_auth_application_agreement_content =>
      '本規約は、お客様とDSKKプラットフォームの間の認証サービスに関する法的契約です。本規約のすべての権利と義務を十分に理解した上でご同意ください。\n\n第1条 サービス内容\nDSKKプラットフォームは、お客様が提供する身元・資格等の情報の真正性を確認し、プラットフォーム上の信頼性を高めるための認証サービスを提供します。\n\n第2条 ユーザーの義務\n1. 真実、正確かつ完全な認証情報と書類を提供してください。\n2. 提供する認証書類が第三者の正当な権利を侵害しないことを保証してください。\n\n第3条 プラットフォームの権利と義務\n1. プラットフォームはお客様が提供する認証情報と書類を審査する権利を有します。\n2. プラットフォームは合理的な期間内に審査を完了し、審査結果をお知らせします。';

  @override
  String get seller_auth_application_agreement_close => '閉じる';

  @override
  String get seller_auth_application_agreement_agree => '同意する';

  @override
  String get seller_auth_application_submit => '認証申請を提出する';

  @override
  String get seller_auth_application_check_form => 'フォームの入力内容を確認してください';

  @override
  String get seller_auth_application_submit_success => '提出完了';

  @override
  String get seller_auth_application_submit_success_desc =>
      '認証申請が提出されました。1〜3営業日以内に審査を完了します。しばらくお待ちください。';

  @override
  String get seller_auth_application_ok => '確認';

  @override
  String seller_auth_application_select_file_failed(String error) {
    return 'ファイルの選択に失敗しました: $error';
  }

  @override
  String get product_management_title => '商品管理';

  @override
  String get product_management_tab_on_sale => '販売中';

  @override
  String get product_management_tab_draft => '下書き';

  @override
  String get product_management_tab_off_shelf => '非公開';

  @override
  String get product_management_action_off_shelf => '非公開にする';

  @override
  String get product_management_action_on_shelf => '公開する';

  @override
  String get product_management_action_edit => '編集';

  @override
  String get product_management_action_delete => '削除';

  @override
  String get product_management_action_publish => '公開';

  @override
  String get product_management_action_resubmit => '再提出';

  @override
  String get product_management_status_reviewing => '審査中';

  @override
  String get product_management_status_rejected => '審査不合格';

  @override
  String get product_management_status_on_shelf => '公開中';

  @override
  String get product_management_status_off_shelf => '非公開';

  @override
  String get product_management_status_draft => '下書き';

  @override
  String get product_management_status_waiting_review => '審査待ち';

  @override
  String get product_management_status_unknown => '不明';

  @override
  String get product_management_stock_label => '在庫';

  @override
  String get product_management_sales_label => '販売数';

  @override
  String get product_management_create_product => '商品を作成';

  @override
  String get product_management_no_more_products => '商品はこれ以上ありません';

  @override
  String get product_management_empty_on_sale => '販売中の商品はありません';

  @override
  String get product_management_empty_draft => '下書きの商品はありません';

  @override
  String get product_management_empty_off_shelf => '非公開の商品はありません';

  @override
  String get product_management_empty_default => '商品データはありません';

  @override
  String get product_management_draft_preview_hint =>
      '下書き状態の商品はプレビューの前に公開する必要があります';

  @override
  String get product_management_confirm_off_shelf_title => '非公開の確認';

  @override
  String product_management_confirm_off_shelf_message(String name) {
    return '商品「$name」を非公開にしますか？';
  }

  @override
  String get product_management_confirm_off_shelf_desc => '非公開にすると：';

  @override
  String get product_management_confirm_off_shelf_point1 =>
      '• 購入者はこの商品を見たり購入したりできなくなります';

  @override
  String get product_management_confirm_off_shelf_point2 => '• いつでも再公開できます';

  @override
  String get product_management_confirm_off_shelf_point3 => '• 商品データは保持されます';

  @override
  String get product_management_confirm_delete_title => '削除の確認';

  @override
  String get product_management_confirm_delete_message =>
      'この商品を削除しますか？この操作は取り消せません。';

  @override
  String get product_management_cancel => 'キャンセル';

  @override
  String get product_management_confirm => '非公開にする';

  @override
  String get product_management_delete => '削除';

  @override
  String get product_edit_title_create => '商品を作成';

  @override
  String get product_edit_title_edit => '商品を編集';

  @override
  String get product_edit_basic_info => '基本情報';

  @override
  String get product_edit_product_name => '商品名';

  @override
  String get product_edit_product_name_hint => '商品名を入力してください';

  @override
  String get product_edit_product_description => '商品説明';

  @override
  String get product_edit_product_description_hint => '商品説明を入力してください';

  @override
  String get product_edit_product_price => '価格';

  @override
  String get product_edit_product_images => '商品画像';

  @override
  String get product_edit_add_image => '画像を追加';

  @override
  String get product_edit_uploading => 'アップロード中...';

  @override
  String get product_edit_service_tiers => 'サービスプランの設定';

  @override
  String get product_edit_detail_intro => '詳細説明';

  @override
  String get product_edit_save_draft => '下書きを保存';

  @override
  String get product_edit_publish_product => '商品を公開';

  @override
  String get product_edit_preview_product => '商品をプレビュー';

  @override
  String get product_edit_at_least_one_image => '商品画像を少なくとも1枚アップロードしてください';

  @override
  String get product_edit_save_draft_dialog_title => '下書きを保存';

  @override
  String get product_edit_save_draft_dialog_message => '下書きとして保存しますか？';

  @override
  String get product_edit_save_draft_dialog_confirm => '保存';

  @override
  String get product_edit_edit_attribute => '商品属性を編集';

  @override
  String get product_edit_validation_name_required => '商品名を入力してください';

  @override
  String get product_edit_validation_description_required => '商品説明を入力してください';

  @override
  String get product_edit_validation_image_required =>
      '商品画像を少なくとも1枚アップロードしてください';

  @override
  String get product_preview_current_seller => '現在の出品者';

  @override
  String get product_preview_seller_user => '出品者ユーザー';

  @override
  String get product_edit_success_cases => '成功事例';

  @override
  String get product_edit_add_success_case => '成功事例を追加';

  @override
  String get product_edit_edit_success_case => '成功事例を編集';

  @override
  String product_edit_uploading_progress(int uploaded, int total) {
    return 'アップロード中 $uploaded/$total';
  }

  @override
  String get product_edit_please_enter_label => '情報ラベルを入力してください';

  @override
  String get product_edit_please_enter_attribute_name => '属性名を入力してください';

  @override
  String get product_edit_attribute_name_hint => '属性名を入力してください';

  @override
  String get product_edit_placeholder_hint => '例：色を選択、型番を入力';

  @override
  String get product_edit_placeholder_label => 'プレースホルダーテキスト';

  @override
  String get product_edit_product_preview_title => '商品プレビュー';

  @override
  String get product_edit_publish_service => 'サービスを公開';

  @override
  String get product_edit_edit_service => 'サービスを編集';

  @override
  String product_edit_max_characters(int max) {
    return '最大$max文字';
  }

  @override
  String get after_sales_review_title => 'アフターサービス審査';

  @override
  String get after_sales_detail_title => 'アフターサービス詳細';

  @override
  String get after_sales_refresh => '更新';

  @override
  String get after_sales_no_pending => '審査待ちのアフターサービス申請はありません';

  @override
  String get after_sales_load_failed => '読み込みに失敗しました。再試行してください';

  @override
  String get after_sales_not_found => '対応するアフターサービス申請が見つかりません';

  @override
  String get after_sales_order_number => '注文番号';

  @override
  String get after_sales_apply_type => '申請種別';

  @override
  String get after_sales_apply_time => '申請日時';

  @override
  String get after_sales_refund_amount => '返金金額';

  @override
  String get after_sales_refund_type => '返金種別';

  @override
  String get after_sales_apply_reason => '申請理由';

  @override
  String get after_sales_image_evidence => '画像証拠';

  @override
  String get after_sales_image_view => '画像を表示';

  @override
  String get after_sales_image_load_failed => '画像の読み込みに失敗しました';

  @override
  String get after_sales_reject => '拒否';

  @override
  String get after_sales_agree => '承認';

  @override
  String get after_sales_reject_application => '申請を拒否';

  @override
  String get after_sales_agree_application => '申請を承認';

  @override
  String get after_sales_confirm => '確認';

  @override
  String get after_sales_cancel => 'キャンセル';

  @override
  String get after_sales_confirm_title => '確認';

  @override
  String get after_sales_confirm_message => 'このアフターサービス申請を承認しますか？';

  @override
  String get after_sales_reject_reason => '拒否理由';

  @override
  String get after_sales_reject_reason_hint => '拒否理由を入力してください';

  @override
  String get after_sales_reject_reason_required => '拒否理由を入力してください';

  @override
  String get after_sales_type_refund_only => '返金のみ';

  @override
  String get after_sales_type_refund_return => '返品・返金';

  @override
  String get after_sales_type_unknown => '不明な種別';

  @override
  String get after_sales_status_wait_audit => '審査待ち';

  @override
  String get after_sales_status_refused => '拒否済み';

  @override
  String get after_sales_status_audit_pass => '審査通過';

  @override
  String get after_sales_status_buyer_shipped => '購入者が発送済み';

  @override
  String get after_sales_status_seller_received => '出品者が受取済み';

  @override
  String get after_sales_status_finished => '完了';

  @override
  String get after_sales_status_canceled => 'キャンセル済み';

  @override
  String get after_sales_status_unknown => '不明なステータス';

  @override
  String get time_management_title => 'スケジュール管理';

  @override
  String get time_management_current_status => '現在のステータス';

  @override
  String get time_management_online => 'オンライン';

  @override
  String get time_management_offline => 'オフライン';

  @override
  String get time_management_online_status_description => 'オンラインステータスについて';

  @override
  String get time_management_offline_status_description => 'オフラインステータスについて';

  @override
  String get time_management_online_description =>
      '現在オンラインです。購入者からメッセージを受け取ることができ、新着メッセージの通知が届きます。購入者への返信を迅速に行うことで、サービス評価の向上につながります。';

  @override
  String get time_management_offline_description =>
      '現在オフラインです。購入者は引き続きメッセージを送ることができますが、システムがオフライン中であることをお知らせします。新着メッセージの通知は届きますが、すぐに返信できない場合があります。長時間のオフラインは受注効率に影響する可能性があります。';

  @override
  String get time_management_save_settings => '設定を保存';

  @override
  String get time_management_settings_saved => '設定が保存されました';

  @override
  String get time_management_load_failed => '読み込みに失敗しました';

  @override
  String get time_management_retry => '再試行';

  @override
  String get time_management_unknown_status => '不明なステータス';

  @override
  String get auto_reply_title => '自動返信設定';

  @override
  String get auto_reply_enable => '自動返信';

  @override
  String get auto_reply_content => '返信内容';

  @override
  String get auto_reply_content_hint => '自動返信の内容を入力してください';

  @override
  String get auto_reply_content_description =>
      'お客様からメッセージが届いた際に、この内容が自動的に返信されます';

  @override
  String get auto_reply_save_settings => '設定を保存';

  @override
  String get auto_reply_settings_saved => '設定が保存されました';

  @override
  String get auto_reply_content_required => '返信内容を入力してください';

  @override
  String get auto_reply_load_failed => '読み込みに失敗しました。再試行してください';

  @override
  String get order_delivery_title => '注文納品';

  @override
  String order_delivery_title_with_sn(String orderSn) {
    return '注文納品: $orderSn';
  }

  @override
  String get order_delivery_submitting => '納品内容を送信中...';

  @override
  String get order_delivery_load_failed => '読み込みに失敗しました。再試行してください';

  @override
  String get order_delivery_instruction_title => '注文納品について';

  @override
  String get order_delivery_instruction_content =>
      'この注文に対する納品物を提出してください。詳細な説明や関連ファイルを添付して、購入者がご提供のサービスや成果物を明確に確認できるようにしてください。';

  @override
  String get order_delivery_content_label => '納品内容の説明：';

  @override
  String get order_delivery_content_hint => '納品内容を説明してください...';

  @override
  String get order_delivery_attachments_label => '添付ファイル：';

  @override
  String get order_delivery_submit_button => '納品を提出';

  @override
  String get order_delivery_content_required => '納品内容の説明を入力してください';

  @override
  String get order_delivery_submit_success => '納品内容が正常に提出されました';

  @override
  String get order_delivery_logistics_company => '配送会社';

  @override
  String get order_delivery_tracking_number => '追跡番号';

  @override
  String get order_delivery_shipping_address => '発送元住所';

  @override
  String get order_delivery_receiving_address => 'お届け先住所';

  @override
  String get order_delivery_status_pending => '発送待ち';

  @override
  String get order_delivery_status_shipped => '発送済み';

  @override
  String get order_delivery_status_received => '受取済み';

  @override
  String get order_delivery_status_in_transit => '配送中';

  @override
  String get order_delivery_confirm_shipment => '発送を確認';

  @override
  String get order_delivery_view_details => '詳細を見る';

  @override
  String get order_delivery_no_pending_orders => '発送待ちの注文はありません';

  @override
  String get notification_center_title => '通知センター';

  @override
  String get notification_tab_all => 'すべて';

  @override
  String get notification_tab_order => '注文';

  @override
  String get notification_tab_system => 'システム';

  @override
  String get notification_tab_refund => 'アフターサービス';

  @override
  String get notification_tab_message => 'メッセージ';

  @override
  String get notification_type_order => '注文通知';

  @override
  String get notification_type_system => 'システム通知';

  @override
  String get notification_type_refund => 'アフターサービス通知';

  @override
  String get notification_type_message => 'メッセージ通知';

  @override
  String get notification_type_review => 'レビュー通知';

  @override
  String get notification_type_authentication => '認証通知';

  @override
  String get notification_type_other => 'その他の通知';

  @override
  String get notification_status_unread => '未読';

  @override
  String get notification_status_read => '既読';

  @override
  String get notification_mark_all_read => 'すべて既読にする';

  @override
  String get notification_empty_all => '通知はありません';

  @override
  String get notification_empty_order => '注文通知はありません';

  @override
  String get notification_empty_system => 'システム通知はありません';

  @override
  String get notification_empty_refund => 'アフターサービス通知はありません';

  @override
  String get notification_empty_message => 'メッセージ通知はありません';

  @override
  String get notification_empty_review => 'レビュー通知はありません';

  @override
  String get notification_empty_authentication => '認証通知はありません';

  @override
  String get notification_empty_other => 'その他の通知はありません';

  @override
  String get notification_empty_generic => '通知はありません';

  @override
  String get notification_refresh => '更新';

  @override
  String get notification_retry => '再試行';

  @override
  String notification_load_failed(String error) {
    return '通知センターの読み込みに失敗しました: $error';
  }

  @override
  String get notification_detail_title => '通知詳細';

  @override
  String get notification_detail_view => '詳細を見る';

  @override
  String get notification_detail_close => '閉じる';

  @override
  String get notification_click_to_view => 'タップして詳細を表示';

  @override
  String get notification_default_title => '通知';

  @override
  String get notification_time_just_now => 'たった今';

  @override
  String notification_time_minutes_ago(int minutes) {
    return '$minutes分前';
  }

  @override
  String notification_time_hours_ago(int hours) {
    return '$hours時間前';
  }

  @override
  String notification_time_days_ago(int days) {
    return '$days日前';
  }

  @override
  String notification_time_months_ago(int months) {
    return '$monthsヶ月前';
  }

  @override
  String get materialsInfo => '素材情報';

  @override
  String get buyerSubmittedMaterials => '購入者が提出した素材';

  @override
  String get sellerDeliveryContent => '出品者の納品内容';

  @override
  String get noBuyerMaterials => '購入者が提出した素材はありません';

  @override
  String get noSellerDelivery => '出品者はまだ納品していません';

  @override
  String get attachments => '添付ファイル：';

  @override
  String get deliveryFiles => '納品ファイル：';

  @override
  String get deliveryDescription => '納品説明';

  @override
  String get tapToPreview => 'タップしてプレビュー';

  @override
  String get tapToOpen => 'タップして開く';

  @override
  String get downloadFile => 'ファイルをダウンロード';

  @override
  String get storagePermissionDenied => 'ストレージの権限が拒否されました';

  @override
  String get cancelDownload => 'ダウンロードをキャンセル';

  @override
  String get pageLoadFailed => 'ページの読み込みに失敗しました';

  @override
  String get openFile => 'ファイルを開く';

  @override
  String get downloaded => 'ダウンロード済み';

  @override
  String get downloadCompleted => 'ダウンロード完了';

  @override
  String get downloadFailed => 'ダウンロードに失敗しました';

  @override
  String get openFileFailed => 'ファイルを開けませんでした';

  @override
  String get storagePermissionRequired => 'ファイルをダウンロードするにはストレージの権限が必要です';

  @override
  String get pdfLoadFailed => 'PDFの読み込みに失敗しました';

  @override
  String get retry => '再試行';

  @override
  String product_detail_translated_from(String language) {
    return '$languageから翻訳';
  }

  @override
  String get product_detail_translation_auto => '自動翻訳';

  @override
  String get product_detail_show_original => '原文を表示';

  @override
  String get order_status_awaiting_payment => '支払待ち';

  @override
  String get order_status_awaiting_submission => '要件提出待ち';

  @override
  String get order_status_buy_awaiting_submission => '資料再送信待ち';

  @override
  String get order_status_awaiting_start => '開始待ち';

  @override
  String get order_status_awaiting_delivery => '配送待ち';

  @override
  String get order_status_awaiting_confirmation => '確認待ち';

  @override
  String get order_status_awaiting_evaluation => '評価待ち';

  @override
  String get order_status_completed => '完了';

  @override
  String get order_status_canceled => 'キャンセル済み';

  @override
  String get order_status_after_sale => 'アフターサービス中';

  @override
  String get order_status_unknown => '不明な状態';

  @override
  String get order_action_cancel => '注文をキャンセル';

  @override
  String get order_action_go_pay => '支払いへ';

  @override
  String get order_action_submit_materials => '資料を提出';

  @override
  String get order_action_contact_support => 'カスタマーサポートに連絡';

  @override
  String get order_action_view_feedback => 'フィードバックを見る';

  @override
  String get order_action_remind_delivery => '発送を催促';

  @override
  String get order_action_platform_intervention => 'プラットフォーム介入';

  @override
  String get order_action_view_delivery => '納品を確認';

  @override
  String get order_action_apply_after_sale => 'アフターサービスを申請';

  @override
  String get order_action_confirm_receipt => '受取を確認';

  @override
  String get order_action_view_logistics => '配送状況を確認';

  @override
  String get order_action_go_evaluate => '評価する';

  @override
  String get order_action_apply_rework => '再制作を申請';

  @override
  String get order_action_delete_order => '注文を削除';

  @override
  String get order_action_view_order => '注文を確認';

  @override
  String get order_action_view_details => '詳細を見る';

  @override
  String get order_action_processing => '処理中...';

  @override
  String get order_confirm_cancel_title => '注文のキャンセル';

  @override
  String get order_confirm_cancel_content => 'この注文をキャンセルしてよろしいですか？';

  @override
  String get order_confirm_receipt_title => '受取確認';

  @override
  String get order_confirm_receipt_content => '商品を受け取りましたか？受取確認をしますか？';

  @override
  String get order_confirm_delete_title => '注文の削除';

  @override
  String get order_confirm_delete_content => 'この注文を削除しますか？削除後は元に戻せません。';

  @override
  String get order_dialog_cancel => 'キャンセル';

  @override
  String get order_dialog_confirm => '確認';

  @override
  String get order_dialog_close => '閉じる';

  @override
  String get order_dialog_submit => '申請を送信';

  @override
  String get order_snackbar_connecting_support => 'サポートに接続中...';

  @override
  String get order_snackbar_feedback_in_progress => '販売者フィードバックの確認機能は開発中';

  @override
  String get order_snackbar_reminded_delivery => '販売者に発送を催促しました';

  @override
  String order_snackbar_nav_failed(String error) {
    return '遷移に失敗しました: $error';
  }

  @override
  String get order_snackbar_no_items_after_sale =>
      'エラー：商品のない注文にはアフターサービスを申請できません';

  @override
  String get order_snackbar_no_items_evaluate => 'エラー：商品のない注文は評価できません';

  @override
  String order_snackbar_operation_failed(String error) {
    return '操作に失敗しました: $error';
  }

  @override
  String get order_dialog_data_not_loaded =>
      'データの読み込みが完了していません。しばらくしてからお試しください';

  @override
  String get order_dialog_view_delivery_title => '納品を確認';

  @override
  String get order_dialog_seller_delivery_content => '販売者の納品内容：';

  @override
  String get order_dialog_buyer_materials => '購入者が提出した資料：';

  @override
  String get order_dialog_no_seller_delivery => '販売者はまだ納品していません';

  @override
  String get order_dialog_no_buyer_materials => '購入者が提出した資料はありません';

  @override
  String order_dialog_delivery_note(String content) {
    return '納品説明: $content';
  }

  @override
  String get order_dialog_delivery_files => '納品ファイル:';

  @override
  String get order_intervention_title => 'プラットフォーム介入を申請';

  @override
  String get order_intervention_desc =>
      '解決できない紛争がありますか？プラットフォームサポートが24時間以内に介入します。';

  @override
  String get order_intervention_problem_type => '問題の種類:';

  @override
  String get order_intervention_problem_desc => '問題の説明:';

  @override
  String get order_intervention_problem_hint => '問題を詳しく説明してください...';

  @override
  String get order_intervention_validation_empty => '問題の説明を入力してください';

  @override
  String get order_intervention_validation_min => '問題の説明は10文字以上必要です';

  @override
  String get order_intervention_tip => 'ヒント：送信後は取り消せません。各注文につき最大2回申請できます。';

  @override
  String get order_intervention_reason_communication => 'コミュニケーションの問題';

  @override
  String get order_intervention_reason_quality => '品質の紛争';

  @override
  String get order_intervention_reason_delivery => '配送の問題';

  @override
  String get order_intervention_reason_refund => '返金の紛争';

  @override
  String get order_intervention_reason_service => 'サービス態度';

  @override
  String get order_intervention_reason_other => 'その他の問題';

  @override
  String get order_intervention_submitting => '申請を送信中...';

  @override
  String order_intervention_failed(String error) {
    return '申請に失敗しました: $error';
  }

  @override
  String get order_demand_replenishment_title => '補充資料申請';

  @override
  String get order_demand_reform_title => '再制作申請';

  @override
  String get order_demand_replenishment_desc =>
      '販売者に追加資料や説明を求める場合は、詳しくご記入ください。';

  @override
  String get order_demand_reform_desc =>
      '納品内容に不満がある場合は再制作を申請できます。具体的な問題をご説明ください。';

  @override
  String get order_demand_detail_label => '詳細説明:';

  @override
  String get order_demand_replenishment_hint => '補充が必要な資料や情報を詳しく記入してください...';

  @override
  String get order_demand_reform_hint => '再制作の理由と要件を詳しく記入してください...';

  @override
  String get order_demand_validation_empty => '詳細説明を入力してください';

  @override
  String get order_demand_validation_min => '説明は10文字以上必要です';

  @override
  String get order_demand_replenishment_tip =>
      'ヒント：販売者は申請受領後24時間以内に回答し、関連資料を補充します。';

  @override
  String get order_demand_reform_tip => 'ヒント：再制作申請を送信後、販売者が注文を再処理します。';

  @override
  String get order_demand_reason_incomplete => '情報が不完全';

  @override
  String get order_demand_reason_unclear => '要件が不明確';

  @override
  String get order_demand_reason_additional => '追加説明が必要';

  @override
  String get order_demand_reason_reference => '参考資料が必要';

  @override
  String get order_demand_reason_other => 'その他の理由';

  @override
  String get order_demand_reason_quality => '品質が不満';

  @override
  String get order_demand_reason_requirement => '要件を満たしていない';

  @override
  String get order_demand_reason_content_incomplete => '内容が不完全';

  @override
  String get order_demand_reason_error => 'エラーがある';

  @override
  String get order_demand_submitting_replenishment => '補充資料申請を送信中...';

  @override
  String get order_demand_submitting_reform => '再制作申請を送信中...';

  @override
  String order_demand_failed(String error) {
    return '申請に失敗しました：$error';
  }

  @override
  String order_demand_edit_info_auto(int current, int remaining) {
    return '現在$current回納品済み。残り$remaining回の無料修正（自動承認）';
  }

  @override
  String order_demand_edit_info_approval(int current) {
    return '現在$current回納品済み。無料修正回数を使い切りました。販売者の承認が必要です';
  }

  @override
  String get order_info_title => '注文情報';

  @override
  String get order_info_order_number => '注文番号：';

  @override
  String get order_info_order_time => '注文日時：';

  @override
  String get order_info_pay_time => '支払日時：';

  @override
  String get order_info_complete_time => '完了日時：';

  @override
  String get order_info_remark => '注文備考：';

  @override
  String get order_items_title => '商品情報';

  @override
  String get order_items_empty => '商品情報がありません';

  @override
  String order_items_count(int count) {
    return '$count件';
  }

  @override
  String get order_price_title => '価格内訳';

  @override
  String get order_price_total => '商品合計';

  @override
  String get order_price_shipping => '送料';

  @override
  String get order_price_discount => '割引額';

  @override
  String get order_price_paid => '支払金額';

  @override
  String get order_price_total_amount => '商品合計金額';

  @override
  String get order_price_actual_paid => '実際の支払額';

  @override
  String get order_requirement_title => '要件を提出';

  @override
  String order_requirement_service_selected(String skuName, String price) {
    return '選択したサービス：$skuName - ¥$price';
  }

  @override
  String get order_requirement_q1 => '1. 要件を詳しく記入してください';

  @override
  String get order_requirement_q1_hint => '具体的な要件や期待する結果など、できる限り詳しく記入してください';

  @override
  String get order_requirement_q1_helper =>
      '参考資料がある場合は、下の添付ファイルエリアにアップロードしてください';

  @override
  String get order_requirement_q2 => '2. 補足説明（任意）';

  @override
  String get order_requirement_q2_hint => 'その他の補足説明や特別な要件があればご記入ください';

  @override
  String get order_requirement_warning =>
      '要件を丁寧にご記入ください。送信後、販売者はご要件に基づいてサービスを開始します';

  @override
  String get order_requirement_attachment_title => '添付ファイル';

  @override
  String order_requirement_attachment_limit(int maxCount, int maxSize) {
    return '最大$maxCountファイル、1ファイルあたり${maxSize}MB以下';
  }

  @override
  String get order_requirement_add => '追加';

  @override
  String get order_requirement_click_select_file => 'ここをタップしてファイルを選択';

  @override
  String get order_requirement_confirm_submit => '送信を確認';

  @override
  String get order_requirement_wait_upload => 'ファイルのアップロードが完了するまでお待ちください';

  @override
  String get order_requirement_upload_failed_title => 'ファイルのアップロード失敗';

  @override
  String order_requirement_upload_failed_count(int count) {
    return '$count個のファイルのアップロードに失敗しました。再試行しますか？';
  }

  @override
  String get order_requirement_remove_failed => '失敗したファイルを削除';

  @override
  String get order_requirement_retry_upload => 'アップロードを再試行';

  @override
  String get order_requirement_error_product_id => 'エラー：商品IDを取得できません';

  @override
  String get order_requirement_load_draft_failed => '下書きの読み込みに失敗しました';

  @override
  String get order_requirement_save_draft_failed => '下書きの保存に失敗しました';

  @override
  String order_requirement_max_files(int count) {
    return '添付ファイルは最大$count個まで';
  }

  @override
  String order_requirement_pick_failed(String error) {
    return 'ファイルの選択に失敗しました: $error';
  }

  @override
  String get order_requirement_default_service => '基本サービス';

  @override
  String get order_evaluation_title => '評価する';

  @override
  String get order_evaluation_hint => 'このサービスはいかがでしたか？率直なご感想をお聞かせください...';

  @override
  String get order_evaluation_add_images => '画像を追加（最大9枚）';

  @override
  String get order_evaluation_anonymous => '匿名で評価';

  @override
  String get order_evaluation_submit => '評価を送信';

  @override
  String get order_evaluation_error_no_item => 'エラー：評価する商品が見つかりません';

  @override
  String get order_evaluation_max_images => '画像は最大9枚まで';

  @override
  String order_evaluation_success_count(int count, String ratio) {
    return '$count枚の画像を処理しました（平均圧縮率$ratio%）';
  }

  @override
  String order_evaluation_failed_count(int count) {
    return '$count枚の画像の処理に失敗しました';
  }

  @override
  String order_evaluation_pick_failed(String error) {
    return '画像の選択に失敗しました: $error';
  }

  @override
  String get order_evaluation_processing => '処理中...';

  @override
  String get order_evaluation_page_title => '注文を評価';

  @override
  String get order_delivery_not_satisfied => '納品内容に不満ですか？';

  @override
  String get order_delivery_communicate_tip =>
      '配送回数が不足している場合は、追加配送について先に販売者とご相談ください';

  @override
  String get order_delivery_supplement => '補足を希望する';

  @override
  String get order_delivery_remake => '再制作を希望する';

  @override
  String get order_delivery_refund => '返金を希望する';

  @override
  String get order_delivery_unknown_file => '不明なファイル';

  @override
  String order_item_delivery_days(int days) {
    return '納期: $days日';
  }

  @override
  String order_item_edit_count(int count) {
    return '修正可能回数: $count回';
  }

  @override
  String get order_countdown_expired => 'タイムアウト';

  @override
  String order_countdown_days_hours(int days, int hours) {
    return '$days日$hours時間';
  }

  @override
  String order_countdown_hours_minutes(int hours, int minutes) {
    return '$hours時間$minutes分';
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
    return '$days日';
  }

  @override
  String order_countdown_minutes_seconds(int minutes, int seconds) {
    return '$minutes分$seconds秒';
  }

  @override
  String order_upload_progress(int percent) {
    return 'アップロード中 $percent%';
  }

  @override
  String get order_upload_retry => 'アップロードを再試行';

  @override
  String order_upload_failed(String error) {
    return 'アップロード失敗: $error';
  }

  @override
  String order_upload_size_limit(String size) {
    return 'ファイルサイズが制限を超えています（最大$size）';
  }

  @override
  String order_upload_max_retry(int count) {
    return '最大再試行回数（$count回）に達しました';
  }

  @override
  String get order_after_sale_processing => 'アフターサービス処理中';

  @override
  String get order_after_sale_processing_msg =>
      'アフターサービス申請を処理中です。販売者がxx時間以内に対応します。しばらくお待ちください。';

  @override
  String get order_after_sale_mediation => 'プラットフォーム調停中';

  @override
  String get order_after_sale_mediation_msg =>
      'プラットフォームサポートが介入しました。xx営業日以内に結果をお知らせします。通知にご注意ください。';

  @override
  String get order_after_sale_rejected => 'アフターサービス申請が拒否されました';

  @override
  String get order_after_sale_rejected_msg =>
      '申し訳ありませんが、アフターサービス申請は審査を通過しませんでした。';

  @override
  String get order_after_sale_default_title => 'アフターサービス状態';

  @override
  String get order_after_sale_default_msg => 'この注文は現在アフターサービス処理中です。';

  @override
  String get order_after_sale_contact_seller => '販売者に連絡';

  @override
  String get order_after_sale_cancel_apply => '申請をキャンセル';

  @override
  String get order_after_sale_contact_platform => 'プラットフォームサポートに連絡';

  @override
  String get order_after_sale_add_evidence => '証拠を追加';

  @override
  String get order_after_sale_add_evidence_tip =>
      '証拠を追加するか、プラットフォームの処理結果をお待ちください。';

  @override
  String get order_after_sale_apply_intervention => 'プラットフォーム介入を申請';

  @override
  String get order_after_sale_refund_status => '返金状態:';

  @override
  String get order_after_sale_refund_amount => '返金金額:';

  @override
  String get order_after_sale_reject_reason => '拒否理由:';

  @override
  String get order_after_sale_reject_reason_detail =>
      '理由：証拠不十分または返金条件を満たしていません。';

  @override
  String get order_platform_intervention_title => 'プラットフォーム介入';

  @override
  String get order_platform_intervention_desc =>
      '協議で解決できない紛争がある場合は、プラットフォームサポートへの介入を申請できます';

  @override
  String get order_platform_intervention_apply => 'プラットフォーム介入を申請';

  @override
  String get order_platform_intervention_in_progress => 'プラットフォーム介入中';

  @override
  String get order_platform_intervention_processing => '処理中';

  @override
  String get order_platform_intervention_processing_msg =>
      '申請を受け付けました。プラットフォームサポートが24時間以内に連絡します';

  @override
  String get order_platform_intervention_step1 => '申請受付';

  @override
  String get order_platform_intervention_step1_desc => 'プラットフォームサポートの処理を待ちます';

  @override
  String get order_platform_intervention_step2 => 'サポート介入';

  @override
  String get order_platform_intervention_step2_desc => '24時間以内に双方へ連絡';

  @override
  String get order_platform_intervention_step3 => '問題解決';

  @override
  String get order_platform_intervention_step3_desc => 'プラットフォームの判断に基づき処理';

  @override
  String get order_card_product_unknown => '商品名不明';

  @override
  String get order_card_deleting => '注文を削除中...';

  @override
  String get order_card_deleted => '注文を削除しました';

  @override
  String order_card_delete_failed(String error) {
    return '削除失敗: $error';
  }

  @override
  String get order_card_canceling => '注文をキャンセル中...';

  @override
  String get order_card_canceled => '注文をキャンセルしました';

  @override
  String order_card_cancel_failed(String error) {
    return 'キャンセル失敗: $error';
  }

  @override
  String order_card_load_detail_failed(String error) {
    return '注文詳細の読み込みに失敗しました: $error';
  }

  @override
  String get order_card_timeout_canceling => 'タイムアウト、間もなくキャンセルされます';

  @override
  String order_card_pay_in_time(String time) {
    return '$time以内にお支払いください';
  }

  @override
  String get order_card_timeout_submit => 'タイムアウト、早急に提出してください';

  @override
  String order_card_submit_in_time(String time) {
    return '$time以内に資料を提出してください';
  }

  @override
  String get order_card_seller_timeout => '販売者が受注時間を超過しました';

  @override
  String order_card_seller_accept_in_time(String time) {
    return '販売者が$time以内に受注確認します';
  }

  @override
  String order_card_delivery_days(int days) {
    return '納期: $days日以内';
  }

  @override
  String get order_card_auto_confirm_soon => '間もなく自動受取確認';

  @override
  String order_card_auto_confirm_in(String time) {
    return '$time後に自動確認';
  }

  @override
  String get order_card_evaluate_for_points => '評価待ち。評価後にポイントを獲得できます';

  @override
  String order_card_duration_days_hours(int days, int hours) {
    return '$days日$hours時間';
  }

  @override
  String order_card_duration_hours_minutes(int hours, int minutes) {
    return '$hours時間$minutes分';
  }

  @override
  String order_card_duration_minutes(int minutes) {
    return '$minutes分';
  }

  @override
  String get order_card_duration_less_than_minute => '1分未満';

  @override
  String get order_detail_invalid_id => '無効な注文IDです';

  @override
  String get order_detail_error => 'エラー';

  @override
  String get order_detail_title => '注文詳細';

  @override
  String order_detail_title_with_id(int id) {
    return '注文詳細（ID: $id）';
  }

  @override
  String order_detail_load_failed(String error) {
    return '読み込み失敗: $error';
  }

  @override
  String get order_detail_reload => '再読み込み';

  @override
  String get order_detail_unavailable => '注文データが利用できません';

  @override
  String get order_list_title => '注文一覧';

  @override
  String get order_list_search_hint => '注文番号または商品名で検索';

  @override
  String get order_list_empty => '注文はありません';

  @override
  String order_list_load_error(String error) {
    return '読み込みエラー: $error';
  }

  @override
  String order_list_load_failed(String error) {
    return '読み込み失敗: $error';
  }

  @override
  String get order_list_select_category => 'カテゴリーを選択して注文を確認してください';

  @override
  String get order_list_tab_all => 'すべて';

  @override
  String get order_list_tab_awaiting_payment => '支払待ち';

  @override
  String get order_list_tab_awaiting_submission => '提出待ち';

  @override
  String get order_list_tab_awaiting_start => '受注待ち';

  @override
  String get order_list_tab_awaiting_delivery => '配送待ち';

  @override
  String get order_list_tab_awaiting_confirmation => '受取待ち';

  @override
  String get order_list_tab_awaiting_evaluation => '評価待ち';

  @override
  String get order_list_tab_after_sale => 'アフターサービス中';

  @override
  String get order_route_error => 'エラー';

  @override
  String order_route_invalid_item_id(String id) {
    return '無効な商品ID: $id';
  }

  @override
  String order_seller_detail_title(int id) {
    return '注文詳細（販売者）- #$id';
  }

  @override
  String order_seller_load_failed(int id, String error) {
    return '注文#$idの読み込みに失敗しました: $error';
  }

  @override
  String get order_seller_preparing => '読み込みを準備中...';

  @override
  String get order_seller_order_number => '注文番号';

  @override
  String get order_seller_order_time => '注文日時';

  @override
  String get order_seller_pay_time => '支払日時';

  @override
  String get order_seller_complete_time => '完了日時';

  @override
  String get order_seller_cancel_time => 'キャンセル日時';

  @override
  String get order_seller_list_title => '受注一覧';

  @override
  String get order_seller_tab_all => 'すべて';

  @override
  String get order_seller_tab_awaiting_start => '受注待ち';

  @override
  String get order_seller_tab_awaiting_delivery => '配送待ち';

  @override
  String get order_seller_tab_awaiting_confirmation => '受取確認待ち';

  @override
  String get order_seller_tab_awaiting_evaluation => '評価待ち';

  @override
  String get order_seller_tab_completed => '完了';

  @override
  String get order_seller_tab_after_sale => 'アフターサービス中';

  @override
  String get order_seller_tab_canceled => 'キャンセル済み';

  @override
  String order_seller_load_failed_msg(String error) {
    return '読み込み失敗: $error';
  }

  @override
  String get order_seller_empty => 'この状態の注文はありません';

  @override
  String order_seller_action_failed(String error) {
    return '操作に失敗しました: $error';
  }

  @override
  String order_seller_pending_count(int count) {
    return '$count件の注文が処理待ちです';
  }

  @override
  String order_seller_pending_awaiting_start(int count) {
    return '$count件の受注待ち';
  }

  @override
  String order_seller_pending_awaiting_delivery(int count) {
    return '$count件の配送待ち';
  }

  @override
  String get order_seller_reject_order => '注文を断る';

  @override
  String get order_seller_confirm_order => '受注を確認';

  @override
  String get order_seller_contact_buyer => '購入者に連絡';

  @override
  String get order_seller_go_deliver => '納品する';

  @override
  String get order_seller_view_delivery_content => '納品内容を確認';

  @override
  String get order_seller_remind_buyer => '購入者に確認を促す';

  @override
  String get order_seller_delete_record => '記録を削除';

  @override
  String get order_seller_confirm_accept_title => '受注確認';

  @override
  String get order_seller_confirm_accept_content => 'この注文を受けますか？';

  @override
  String get order_seller_confirm_delete_title => '削除確認';

  @override
  String get order_seller_confirm_delete_content =>
      'この注文記録を削除しますか？この操作は元に戻せません。';

  @override
  String get order_seller_confirm_delete_canceled_content =>
      'このキャンセル済み注文記録を削除しますか？この操作は元に戻せません。';

  @override
  String get order_seller_confirm_btn => '確認';

  @override
  String get order_seller_confirm_reject_title => '拒否確認';

  @override
  String get order_seller_confirm_reject_content => 'この注文を拒否しますか？';

  @override
  String get order_seller_confirm_reject_btn => '拒否を確認';

  @override
  String get order_seller_reject_dialog_title => '注文を断る';

  @override
  String get order_seller_reject_reason_label => '断る理由 *';

  @override
  String get order_seller_reject_reason_hint => '断る理由を入力してください';

  @override
  String get order_seller_reject_reason_empty => '断る理由は必須です';

  @override
  String get order_seller_reject_reason_required => '断る理由を入力してください';

  @override
  String get order_seller_remarks_label => '補足説明（任意）';

  @override
  String get order_seller_remarks_hint => '任意';

  @override
  String get order_seller_delivery_dialog_title => '納品内容';

  @override
  String get order_seller_delivery_desc_label => '納品説明 *';

  @override
  String get order_seller_delivery_desc_hint => '納品内容を説明してください';

  @override
  String get order_seller_delivery_desc_empty => '納品説明は必須です';

  @override
  String get order_seller_delivery_desc_required => '納品説明を入力してください';

  @override
  String get order_seller_delivery_attachment => '添付ファイル';

  @override
  String get order_seller_delivery_select_file => '下のボタンをタップしてファイルを選択';

  @override
  String get order_seller_delivery_add_attachment => '添付ファイルを追加';

  @override
  String get order_seller_delivery_file_select_soon => 'ファイル選択機能は近日公開予定';

  @override
  String get order_seller_delivery_confirm => '納品確認';

  @override
  String order_seller_delivery_chat_hint(String productName) {
    return '商品「$productName」に関するチャットを選択してください';
  }

  @override
  String get order_seller_dynamic_delivered => 'サービスを納品しました';

  @override
  String get order_seller_dynamic_delivered_msg =>
      'サービスの納品が完了しました。購入者の確認をお待ちください。問題がある場合、購入者がアフターサービスを申請することがあります。';

  @override
  String get order_seller_dynamic_completed => 'この注文は正常に完了しました。';

  @override
  String get order_seller_dynamic_canceled => 'この注文はキャンセルされました。';

  @override
  String get order_seller_dynamic_refused => '注文拒否を申請しました';

  @override
  String get order_seller_dynamic_refused_msg => '拒否申請を送信しました。処理をお待ちください。';

  @override
  String get order_seller_buyer_materials => '購入者が提供した資料';

  @override
  String get order_seller_attachment_label => '添付ファイル:';

  @override
  String order_seller_view_attachment(String fileName) {
    return '添付ファイルの表示（近日公開）: $fileName';
  }

  @override
  String get order_evaluation_product_info => '商品情報';

  @override
  String get order_list_retry => '再試行';

  @override
  String chat_get_user_info_failed(String error) {
    return 'ユーザー情報の取得に失敗しました: $error';
  }

  @override
  String get chat_user_refer_id_not_found => 'ユーザーreferIdが見つかりません';

  @override
  String get chat_no_chat_records => 'チャット記録はありません';

  @override
  String get chat_opponent_info_missing => '相手の情報がありません';

  @override
  String get chat_product_default => '商品';

  @override
  String get chat_view_details => '詳細を見る';

  @override
  String get chat_product_info_incomplete => '商品情報が不完全なため詳細を確認できません';

  @override
  String get chat_uploading => 'アップロード中...';

  @override
  String get chat_upload_failed => 'アップロード失敗';

  @override
  String get chat_retry => '再試行';

  @override
  String get chat_image_loading => '読み込み中...';

  @override
  String get chat_image_load_failed => '読み込み失敗';

  @override
  String get chat_revoke_time_missing => 'メッセージの時刻情報がないため取り消せません';

  @override
  String get chat_revoke_available => '取り消し可能';

  @override
  String chat_revoke_expired(int seconds) {
    return 'メッセージ送信から2分以上経過しているため取り消せません（$seconds秒超過）';
  }

  @override
  String get chat_unknown_seller => '不明な販売者';

  @override
  String get chat_product_conversation => '商品会話';

  @override
  String chat_product_conversation_count(int count) {
    return '$count件の商品会話';
  }

  @override
  String get chat_unknown_product => '不明な商品';

  @override
  String chat_user_inquiry_count(int count) {
    return '$count件のユーザー問い合わせ';
  }

  @override
  String get chat_weekday_mon => '月曜日';

  @override
  String get chat_weekday_tue => '火曜日';

  @override
  String get chat_weekday_wed => '水曜日';

  @override
  String get chat_weekday_thu => '木曜日';

  @override
  String get chat_weekday_fri => '金曜日';

  @override
  String get chat_weekday_sat => '土曜日';

  @override
  String get chat_weekday_sun => '日曜日';

  @override
  String get chat_select_multiple_images => '複数の画像を選択';

  @override
  String chat_image_compressed(String ratio) {
    return '画像を$ratio%圧縮しました';
  }

  @override
  String chat_image_process_failed(String error) {
    return '画像の処理に失敗しました: $error';
  }

  @override
  String chat_images_processed_success(int count, String ratio) {
    return '$count枚の画像を処理しました（平均圧縮率$ratio%）';
  }

  @override
  String chat_images_process_failed_count(int count) {
    return '$count枚の画像の処理に失敗しました';
  }

  @override
  String get chat_tap_to_view_product => 'タップして商品詳細を表示';

  @override
  String chat_yesterday_time(String time) {
    return '昨日 $time';
  }

  @override
  String get chat_no_messages_brief => 'メッセージなし';

  @override
  String chat_select_image_error(String error) {
    return '画像の選択中にエラーが発生しました: $error';
  }

  @override
  String get after_sales_reason_none => 'なし';

  @override
  String seller_auth_status_title(String type) {
    return '$type認証';
  }

  @override
  String get seller_auth_status_label => '認証状態：';

  @override
  String get seller_auth_status_name_label => '認証名称：';

  @override
  String get seller_auth_status_materials => '認証資料';

  @override
  String get seller_auth_status_no_materials => '認証資料はありません';

  @override
  String get seller_auth_status_info => '認証情報';

  @override
  String get seller_auth_status_history => '認証履歴';

  @override
  String get seller_auth_status_no_history => '履歴はありません';

  @override
  String get seller_auth_status_reapply => '再申請';

  @override
  String get seller_auth_status_approved_hint => '認証済みのため、再提出は不要です';

  @override
  String get seller_auth_status_pending_hint => '認証審査中です。しばらくお待ちください';

  @override
  String get seller_auth_status_tag_approved => '認証済み';

  @override
  String get seller_auth_status_tag_pending => '審査中';

  @override
  String get seller_auth_status_tag_rejected => '不承認';

  @override
  String get seller_auth_status_tag_not_submitted => '未提出';

  @override
  String get seller_auth_status_type_idcard => '身分';

  @override
  String get seller_auth_status_type_education => '学歴';

  @override
  String get seller_auth_status_type_profession => '職業';

  @override
  String get seller_auth_status_type_company => '法人';

  @override
  String get seller_auth_status_type_other => 'その他';

  @override
  String get seller_auth_status_field_auth_name => '認証名称';

  @override
  String get seller_auth_status_field_auth_type => '認証種別';

  @override
  String get seller_auth_status_field_company_name => '会社名';

  @override
  String get seller_auth_status_field_name => '氏名';

  @override
  String get seller_auth_status_field_school_name => '学校名';

  @override
  String get seller_auth_status_field_profession => '職業/役職';

  @override
  String get seller_auth_status_field_name_or_title => '氏名/名称';

  @override
  String get seller_auth_status_field_remarks => '備考';

  @override
  String get seller_auth_status_field_cert_number => '証書番号';

  @override
  String get seller_auth_status_field_work_experience => '職務経歴';

  @override
  String get seller_auth_status_field_issuer => '発行機関';

  @override
  String get seller_auth_status_field_credit_code => '統一社会信用コード';

  @override
  String get seller_auth_status_field_legal_rep => '法人代表';

  @override
  String get seller_auth_status_field_registered_capital => '登録資本金';

  @override
  String get seller_auth_status_field_establishment_date => '設立日';

  @override
  String get seller_auth_status_field_degree => '学歴';

  @override
  String get seller_auth_status_field_major => '専攻';

  @override
  String get seller_auth_status_field_graduation_year => '卒業年';

  @override
  String get seller_auth_status_field_id_number => '身分証番号';

  @override
  String get seller_auth_status_field_valid_period => '有効期間';

  @override
  String get seller_auth_status_field_submit_time => '提出日時';

  @override
  String get seller_auth_status_field_reject_reason => '拒否理由';

  @override
  String get seller_auth_status_history_approved_title => '認証申請が承認されました';

  @override
  String seller_auth_status_history_approved_desc(String type) {
    return '$type認証申請が承認されました。認証済み販売者のすべての特典をご利用いただけます。';
  }

  @override
  String get seller_auth_status_history_submitted_title => '認証申請を提出';

  @override
  String seller_auth_status_history_submitted_desc(String type) {
    return '$type認証申請を提出しました。1〜3営業日以内に審査が完了します。';
  }

  @override
  String get seller_auth_status_history_rejected_title => '認証申請が却下されました';

  @override
  String seller_auth_status_history_rejected_desc(String type, String reason) {
    return '$type認証申請が却下されました。理由：$reason';
  }

  @override
  String get seller_auth_status_history_rejected_default_reason =>
      '資料が要件を満たしていません';

  @override
  String get seller_product_preview_title => '商品プレビュー';

  @override
  String get seller_product_preview_back_to_edit => '編集に戻る';

  @override
  String get seller_product_preview_loading => '商品情報を読み込み中...';

  @override
  String get seller_product_preview_load_failed => '商品情報の読み込みに失敗しました';

  @override
  String get seller_product_preview_retry => '再試行';

  @override
  String get seller_product_preview_fetching => '商品データを取得中...';

  @override
  String get seller_product_preview_hint => 'これはプレビューモードです。購入者には同様の画面が表示されます';

  @override
  String get seller_product_edit_unsaved_changes_title => '未保存の変更があります';

  @override
  String get seller_product_edit_unsaved_changes_message =>
      '未保存の内容があります。下書きとして保存しますか？';

  @override
  String get seller_product_edit_cancel => 'キャンセル';

  @override
  String get seller_product_edit_discard => '保存しない';

  @override
  String get seller_product_edit_operation_failed => '操作に失敗しました';

  @override
  String get seller_product_edit_draft_saved => '下書きを保存しました';

  @override
  String get seller_product_edit_publish_success =>
      'サービスを公開しました！審査中です。「販売中」リストでご確認ください';

  @override
  String get seller_product_edit_update_success => 'サービスを更新しました';

  @override
  String get seller_product_edit_max_images => '画像は最大9枚まで。最初の9枚が選択されました';

  @override
  String seller_product_edit_price_required(String tierName) {
    return '$tierNameの価格は0より大きくなければなりません';
  }

  @override
  String get seller_product_edit_form_incomplete =>
      'フォームデータが不完全です。赤くハイライトされた項目を確認してください';

  @override
  String get seller_product_edit_add_attribute => '属性を追加';

  @override
  String seller_product_edit_attribute_max_chars(int max) {
    return '属性名は最大$max文字';
  }

  @override
  String get seller_product_edit_confirm => '確認';

  @override
  String get seller_product_edit_options_config => 'オプション設定';

  @override
  String get seller_product_edit_new_option => '新しいオプション';

  @override
  String get seller_product_edit_option_hint => 'オプション内容を入力してください';

  @override
  String get seller_product_edit_service_name_hint => 'サービス名';

  @override
  String get seller_product_edit_description_hint =>
      'サービスの具体的な情報を説明してください（例：...）';

  @override
  String get seller_product_edit_faq_title => 'よくある質問の編集';

  @override
  String seller_product_edit_faq_count(int count) {
    return '$count件の質問';
  }

  @override
  String get seller_product_edit_add_question => '質問を追加';

  @override
  String get seller_product_edit_question_label => '質問';

  @override
  String get seller_product_edit_question_hint => '購入者が質問しそうな内容を入力してください';

  @override
  String get seller_product_edit_delete_question => '質問を削除';

  @override
  String get seller_product_edit_answer_label => '回答';

  @override
  String get seller_product_edit_answer_hint => '回答を入力してください';

  @override
  String get seller_product_edit_buyer_info_title => '購入者に必要な情報';

  @override
  String seller_product_edit_buyer_info_count(int count) {
    return '$count項目の情報';
  }

  @override
  String get seller_product_edit_buyer_info_desc =>
      '購入者に提供してもらう情報の種類を選択してください（注文詳細ページに表示されます）';

  @override
  String get seller_product_edit_selected_items => '選択済み情報項目：';

  @override
  String get seller_product_edit_required => '必須';

  @override
  String get seller_product_edit_edit_tooltip => '編集';

  @override
  String get seller_product_edit_delete_tooltip => '削除';

  @override
  String seller_product_edit_add_info_title(String type) {
    return '$type情報を追加';
  }

  @override
  String get seller_product_edit_info_label => '情報ラベル';

  @override
  String get seller_product_edit_info_label_hint => '例：会社ロゴデザイン要件';

  @override
  String get seller_product_edit_info_description => '詳細説明';

  @override
  String get seller_product_edit_info_description_hint =>
      '購入者に提供してもらう情報の内容を詳しく説明してください';

  @override
  String get seller_product_edit_required_field => '必須項目';

  @override
  String get seller_product_edit_add => '追加';

  @override
  String seller_product_edit_edit_info_title(String type) {
    return '$type情報を編集';
  }

  @override
  String get seller_product_edit_save => '保存';

  @override
  String seller_product_edit_cases_count(int count) {
    return '$count件の事例';
  }

  @override
  String get seller_product_edit_add_case => '事例を追加';

  @override
  String get seller_product_edit_image_load_failed => '画像の読み込みに失敗しました';

  @override
  String get seller_product_edit_click_select_image => 'タップして画像を選択';

  @override
  String get seller_product_edit_upload_failed => 'アップロード失敗';

  @override
  String get seller_product_edit_upload_retry => '再試行';

  @override
  String get seller_product_edit_case_title_label => '事例タイトル';

  @override
  String get seller_product_edit_case_title_hint => 'この事例を簡潔に説明してください';

  @override
  String get seller_product_edit_case_desc_label => '事例の説明';

  @override
  String get seller_product_edit_case_desc_hint => '事例の背景、実施過程、または結果を説明してください';

  @override
  String get seller_product_edit_select_image_and_title =>
      '画像を選択しタイトルを入力してください';

  @override
  String get seller_product_edit_cover_image => 'サービスカバー画像';

  @override
  String get seller_product_edit_upload_success => 'アップロード成功';

  @override
  String seller_product_edit_upload_error(String error) {
    return 'アップロードエラー: $error';
  }

  @override
  String get seller_product_edit_image_format_hint =>
      'jpg、png、jpeg形式に対応。1枚あたり最大5MB、最大9枚';

  @override
  String get seller_product_edit_main_image => 'メイン';

  @override
  String seller_product_edit_tier_price_label(String tierName) {
    return '$tierNameの価格';
  }

  @override
  String seller_product_edit_max_price(String max) {
    return '最大値：$max';
  }

  @override
  String seller_product_edit_price_exceed_max(String max) {
    return '価格は$maxを超えることはできません';
  }

  @override
  String get seller_product_edit_price_min => '価格の最小値は0.01です';

  @override
  String get seller_product_edit_delivery_period => '納期';

  @override
  String get seller_product_edit_delivery_days_suffix => '日';

  @override
  String seller_product_edit_max_days(int max) {
    return '最大$max日';
  }

  @override
  String get seller_product_edit_times => '回数';

  @override
  String get seller_product_edit_times_suffix => '回';

  @override
  String seller_product_edit_max_times(int max) {
    return '最大$max回';
  }

  @override
  String get seller_product_edit_input => '入力';

  @override
  String get seller_product_edit_radio => '単一選択';

  @override
  String get seller_product_edit_draft_label => '下書き';

  @override
  String get seller_product_edit_draft_unsaved_label => '下書き*';

  @override
  String get seller_product_edit_publish => '公開';

  @override
  String get seller_product_edit_yes => 'はい';

  @override
  String get seller_product_edit_no => 'いいえ';

  @override
  String get seller_product_edit_add_selection_attribute => '単一選択属性を追加';

  @override
  String get seller_product_edit_default_options_yes_no => 'デフォルトオプション：はい/いいえ';

  @override
  String get seller_product_edit_attribute_name_label => '属性名 *';

  @override
  String get seller_product_edit_attribute_name_example => '例：色、型番、素材、対象年齢';

  @override
  String get seller_product_edit_attribute_type_label => '属性種別';

  @override
  String get seller_product_edit_required_item => '必須';

  @override
  String seller_product_card_sales(int count) {
    return '販売数: $count';
  }

  @override
  String get seller_product_card_view => '確認';

  @override
  String get seller_image_preview_main_image => 'メイン画像';

  @override
  String get seller_image_preview_set_main => 'メイン画像に設定';

  @override
  String get seller_image_preview_load_failed => '画像の読み込みに失敗しました';

  @override
  String get seller_image_preview_delete_title => '画像を削除';

  @override
  String seller_image_preview_delete_confirm(int index) {
    return '$index枚目の画像を削除しますか？';
  }

  @override
  String get seller_image_preview_delete => '削除';

  @override
  String get seller_file_select => 'ファイルを選択';

  @override
  String get seller_file_selected => '選択されたファイル:';

  @override
  String seller_file_size(String size) {
    return 'サイズ: $size';
  }

  @override
  String get seller_file_size_unknown => 'サイズを取得できません';

  @override
  String seller_file_preview_unsupported(String name) {
    return 'このファイル形式はプレビューできません: $name';
  }

  @override
  String get seller_common_cancel => 'キャンセル';

  @override
  String get profile_user_name_default => 'ユーザー名';

  @override
  String get profile_buyer_mode => '購入者モード';

  @override
  String get profile_my_orders => 'マイ注文';

  @override
  String get profile_my_dskk_section => 'マイDSKK';

  @override
  String get profile_liked_stories => 'いいねしたストーリー';

  @override
  String get profile_logout => 'ログアウト';

  @override
  String get profile_avatar_updated_local => 'アバターを更新しましたが、サーバーにはまだ保存されていません';

  @override
  String profile_image_pick_error(String error) {
    return '画像の選択中にエラーが発生しました: $error';
  }

  @override
  String profile_feature_not_implemented(String feature) {
    return '$feature機能はまだ利用できません';
  }

  @override
  String get profile_pending_payment_order => '支払待ち';

  @override
  String get profile_in_progress_order => '進行中';

  @override
  String get profile_completed_order => '完了';

  @override
  String get profile_refund_after_sales => '返金/アフターサービス';

  @override
  String get profile_account_deletion => 'アカウントを削除';

  @override
  String get profile_bound_phone => '登録済みの電話番号';

  @override
  String get profile_not_bound => '未登録';

  @override
  String get profile_nickname => 'ニックネーム';

  @override
  String get profile_confirm_logout => 'ログアウトを確認';

  @override
  String get profile_confirm_logout_message => 'ログアウトしてよろしいですか？';

  @override
  String get profile_confirm => '確認';

  @override
  String get profile_update_avatar => 'アバターを更新';

  @override
  String get profile_update_avatar_confirm => 'アバターを更新してよろしいですか？';

  @override
  String get profile_info_updated => 'プロフィールを更新しました！';

  @override
  String get profile_avatar_upload_timeout =>
      'アバターのアップロードがタイムアウトしました。ネットワーク接続を確認して再試行してください';

  @override
  String get profile_network_failed => 'ネットワーク接続に失敗しました。接続を確認して再試行してください';

  @override
  String profile_avatar_optimized(String ratio) {
    return 'アバターを最適化しました（$ratio%圧縮）';
  }

  @override
  String profile_avatar_process_failed(String error) {
    return 'アバターの処理に失敗しました: $error';
  }

  @override
  String profile_logout_error(String error) {
    return 'ログアウト中にエラーが発生しました: $error';
  }

  @override
  String get profile_nickname_empty => 'ニックネームを入力してください';

  @override
  String get profile_nickname_too_short => 'ニックネームは2文字以上必要です';

  @override
  String get profile_nickname_too_long => 'ニックネームは20文字以内にしてください';

  @override
  String get profile_nickname_no_spaces => 'ニックネームにスペースは使用できません';

  @override
  String get profile_nickname_invalid_chars =>
      'ニックネームには中国語、英語、数字、アンダースコアのみ使用できます';

  @override
  String get profile_nickname_only_underscores => 'ニックネームはアンダースコアのみにすることはできません';

  @override
  String get profile_nickname_unchanged => 'ニックネームに変更はありません';

  @override
  String get profile_edit_nickname_title => 'ニックネームを編集';

  @override
  String get profile_nickname_input_hint => 'ニックネームを入力してください';

  @override
  String get profile_nickname_rules =>
      '2〜20文字で設定してください。中国語、英語、数字、アンダースコアのみ使用できます';

  @override
  String get profile_nickname_updated => 'ニックネームを変更しました！';

  @override
  String profile_nickname_update_failed(String error) {
    return 'ニックネームの変更に失敗しました: $error';
  }

  @override
  String get profile_submit_changes => '変更を送信';

  @override
  String get profile_avatar_uploaded => 'アバターをアップロードしました';

  @override
  String get profile_updated => 'プロフィールを更新しました';

  @override
  String get profile_reload => '再読み込み';

  @override
  String get profile_account_balance => 'アカウント残高';

  @override
  String get profile_pending_settlement => '精算待ち';

  @override
  String get profile_total_income => '総収入';

  @override
  String get profile_load_wallet => 'タップしてウォレット情報を読み込む';

  @override
  String get profile_all_orders => 'すべての注文';

  @override
  String get profile_awaiting_payment => '支払待ち';

  @override
  String get profile_awaiting_shipment => '発送待ち';

  @override
  String get profile_awaiting_receipt => '受取待ち';

  @override
  String get profile_awaiting_review => '評価待ち';

  @override
  String get profile_shipping_address => '配送先住所';

  @override
  String get profile_browsing_history => '閲覧履歴';

  @override
  String get profile_contact_support => 'サポートに連絡';

  @override
  String get profile_help_center => 'ヘルプセンター';

  @override
  String get profile_feedback => 'フィードバック';

  @override
  String get profile_switch_to_seller_mode => '販売者モードに切り替え';

  @override
  String get profile_take_photo => '写真を撮る';

  @override
  String get profile_choose_from_album => 'アルバムから選択';

  @override
  String profile_image_pick_failed(String error) {
    return '画像の選択に失敗しました: $error';
  }

  @override
  String get profile_edit_profile => 'プロフィールを編集';

  @override
  String get profile_online_status => 'オンライン状態';

  @override
  String get profile_mission_title => 'アシスタントのミッション';

  @override
  String get profile_mission_our_mission => '私たちのミッション';

  @override
  String get profile_mission_our_mission_content =>
      'クリエイティビティとニーズをつなぎ、すべてのアイデアが実現の可能性を持てるようにします。アシスタントはユーザーに最も心のこもったインテリジェントなサービス体験を提供し、生活と仕事の中で最も信頼できるデジタルパートナーになることを目指しています。';

  @override
  String get profile_mission_core_values => 'コアバリュー';

  @override
  String get profile_mission_core_values_content =>
      '• ユーザーファースト：常にユーザーのニーズを出発点に\n• イノベーション：新技術と新手法を継続的に探求\n• 誠実なサービス：信頼できる透明性の高いサービス体験を提供\n• 共に成長：ユーザーとパートナーと共に前進';

  @override
  String get profile_mission_service_promise => 'サービスの約束';

  @override
  String get profile_mission_service_promise_content =>
      'すべてのユーザーに以下を提供することをお約束します：\n\n✓ 24時間365日のインテリジェントサービスサポート\n✓ パーソナライズされたソリューション推薦\n✓ 安全で信頼性の高いデータ保護\n✓ 継続的に最適化されるユーザー体験\n✓ 迅速なカスタマーサービス';

  @override
  String get profile_mission_future_vision => '未来のビジョン';

  @override
  String get profile_mission_future_vision_content =>
      'AI技術で強化されたグローバルトップのスマートサービスプラットフォームになり、すべての人がパーソナライズされた効率的なデジタル生活体験を享受できるようにします。テクノロジーの力で生活をより豊かにし、アイデアをより実現しやすくすることを信じています。';

  @override
  String get profile_mission_questions_suggestions => 'ご質問・ご提案はありますか？';

  @override
  String get profile_mission_listening =>
      '私たちは常にあなたの声に耳を傾け、より良い未来を共に創ることを楽しみにしています。';

  @override
  String get profile_mission_contact_us => 'お問い合わせ';

  @override
  String get profile_mission_contact_coming_soon => '連絡機能は近日公開予定です。お楽しみに！';

  @override
  String get profile_wallet_title => 'マイウォレット';

  @override
  String profile_wallet_error(String error) {
    return 'エラー: $error';
  }

  @override
  String profile_wallet_occurred_error(String error) {
    return 'エラーが発生しました: $error';
  }

  @override
  String get profile_wallet_retry => '再試行';

  @override
  String get profile_wallet_filter_all => 'すべて';

  @override
  String get profile_wallet_filter_income => '収入';

  @override
  String get profile_wallet_filter_expense => '支出';

  @override
  String get profile_wallet_no_transactions => '取引記録はありません';

  @override
  String profile_wallet_load_failed(String error) {
    return '読み込み失敗: $error';
  }

  @override
  String profile_wallet_load_more_failed(String error) {
    return '追加読み込みに失敗しました: $error';
  }

  @override
  String get profile_wallet_account_balance => 'アカウント残高';

  @override
  String get profile_wallet_pending_amount => '精算待ち金額';

  @override
  String get profile_wallet_total_income => '総収入';

  @override
  String get profile_wallet_withdraw => '出金';

  @override
  String get profile_wallet_status_completed => '完了';

  @override
  String get profile_wallet_status_pending => '処理中';

  @override
  String get profile_wallet_status_failed => '失敗';

  @override
  String get profile_wallet_status_unknown => '不明';

  @override
  String get profile_wallet_transaction_details => '取引詳細';

  @override
  String get profile_wallet_transaction_id => '取引ID';

  @override
  String get profile_wallet_transaction_type => '種別';

  @override
  String get profile_wallet_transaction_type_income => '収入';

  @override
  String get profile_wallet_transaction_type_expense => '支出';

  @override
  String get profile_wallet_transaction_amount => '金額';

  @override
  String get profile_wallet_transaction_description => '説明';

  @override
  String get profile_wallet_transaction_date => '日付';

  @override
  String get profile_wallet_transaction_status => '状態';

  @override
  String get profile_wallet_close => '閉じる';

  @override
  String profile_wallet_available_balance(String symbol, String amount) {
    return '出金可能残高: $symbol$amount';
  }

  @override
  String get profile_wallet_withdraw_amount => '出金金額';

  @override
  String get profile_wallet_withdraw_hint => '出金金額を入力してください';

  @override
  String get profile_wallet_withdraw_time => '出金到着日数：1〜3営業日';

  @override
  String get profile_wallet_invalid_amount => '有効な出金金額を入力してください';

  @override
  String get profile_wallet_exceed_balance => '出金金額は利用可能残高を超えることはできません';

  @override
  String get profile_wallet_confirm_withdraw => '出金を確認';

  @override
  String profile_wallet_withdraw_submitted(String symbol, String amount) {
    return '出金申請を送信しました：$symbol$amount';
  }

  @override
  String get profile_wallet_not_implemented => 'この機能はまだ利用できません';

  @override
  String get auth_verification_expired => '確認コードの有効期限が切れました';

  @override
  String auth_login_failed(String error) {
    return 'ログインに失敗しました: $error';
  }

  @override
  String auth_code_send_failed(String error) {
    return '確認コードの送信に失敗しました: $error';
  }

  @override
  String get auth_login_success => 'ログインしました！';

  @override
  String get auth_login => 'ログイン';

  @override
  String get auth_privacy_policy => 'プライバシーポリシー';

  @override
  String get auth_and => 'および';

  @override
  String get auth_user_agreement => 'ユーザー規約';

  @override
  String get auth_invalid_phone => '有効な11桁の電話番号を入力してください';

  @override
  String get auth_get_code => '確認コードを取得';

  @override
  String get payment_creating_order => '注文を作成中...';

  @override
  String get payment_processing => '支払い処理中...';

  @override
  String get payment_credit_card => 'クレジットカード払い';

  @override
  String get payment_confirm_order => '注文を確認';

  @override
  String get payment_quantity_label => '数量:';

  @override
  String get payment_order_summary => '注文概要';

  @override
  String get payment_product_amount => '商品金額';

  @override
  String get payment_quantity => '数量';

  @override
  String get payment_order_total => '注文合計';

  @override
  String get payment_method => '支払方法';

  @override
  String get payment_processing_ellipsis => '処理中...';

  @override
  String get payment_confirm_pay => '支払いを確認';

  @override
  String get payment_success => '支払い成功';

  @override
  String get payment_failed => '支払い失敗';

  @override
  String get payment_view_order_detail => '注文詳細を確認';

  @override
  String get payment_back_to_orders => '注文一覧へ戻る';

  @override
  String get payment_success_tip => 'ご購入ありがとうございます！注文から詳細をご確認いただけます。';

  @override
  String get payment_failed_tip => '支払いが完了しませんでした。再試行するか、別の支払方法を選択してください。';

  @override
  String get home_banner_image_load_failed => '画像の読み込みに失敗しました';

  @override
  String home_banner_placeholder(int index) {
    return 'バナー$index';
  }

  @override
  String get home_no_data => 'データがありません';

  @override
  String get product_detail_no_faq => 'よくある質問はありません';

  @override
  String product_detail_buy_button(String price) {
    return '今すぐ購入 $price';
  }

  @override
  String get product_detail_buyer_requirements => '購入者への必要情報';

  @override
  String get product_detail_no_buyer_requirements => '販売者はまだ購入者への必要情報を設定していません';

  @override
  String get after_sales_apply => 'アフターサービスを申請';

  @override
  String get after_sales_apply_remake => '再制作を申請';

  @override
  String get after_sales_apply_supplement => '補足を申請';

  @override
  String get after_sales_apply_refund => '返金を申請';

  @override
  String after_sales_max_images(int max) {
    return '最大$max枚の画像をアップロードできます';
  }

  @override
  String after_sales_images_processed(int count, String ratio) {
    return '$count枚の画像を処理しました（平均圧縮率$ratio%）';
  }

  @override
  String after_sales_images_failed(int count) {
    return '$count枚の画像の処理に失敗しました';
  }

  @override
  String after_sales_image_pick_failed(String error) {
    return '画像の選択に失敗しました: $error';
  }

  @override
  String get after_sales_select_reason => 'アフターサービス理由を選択してください';

  @override
  String get after_sales_reason_label => 'アフターサービス理由';

  @override
  String get after_sales_reason_quality => '商品品質の問題';

  @override
  String get after_sales_reason_mismatch => '商品が説明と異なる';

  @override
  String get after_sales_reason_wrong_item => '商品が違う';

  @override
  String get after_sales_reason_unwanted => '不要になった';

  @override
  String get after_sales_reason_other => 'その他';

  @override
  String get after_sales_description_label => '問題の説明';

  @override
  String get after_sales_description_hint => '問題の詳細をご記入ください...';

  @override
  String after_sales_refund_max_hint(String symbol, String amount) {
    return '最大返金額：$symbol$amount';
  }

  @override
  String get after_sales_enter_refund_amount => '返金金額を入力してください';

  @override
  String get after_sales_invalid_amount => '有効な金額を入力してください';

  @override
  String get after_sales_amount_must_positive => '返金金額は0より大きくなければなりません';

  @override
  String after_sales_amount_exceed(String symbol, String amount) {
    return '返金金額は$symbol$amountを超えることはできません';
  }

  @override
  String after_sales_upload_proof(int max) {
    return '証拠をアップロード（最大$max枚）';
  }

  @override
  String get after_sales_remove_image => '画像を削除';

  @override
  String get after_sales_submit => '申請を送信';

  @override
  String after_sales_loading_failed(String error) {
    return '読み込み失敗: $error';
  }

  @override
  String get after_sales_detail_retry => '再試行';

  @override
  String get after_sales_initializing => '初期化中...';

  @override
  String get after_sales_status_audit_reject => 'アフターサービス申請が拒否されました';

  @override
  String get after_sales_status_refund_success => '返金完了';

  @override
  String get after_sales_status_processing => 'アフターサービス処理中';

  @override
  String get after_sales_subtitle_wait_audit => '販売者が48時間以内に対応します';

  @override
  String get after_sales_subtitle_audit_pass => '返金は1〜3営業日以内に反映されます';

  @override
  String get after_sales_subtitle_audit_reject => 'ご不満の場合はプラットフォーム介入を申請できます';

  @override
  String get after_sales_subtitle_refund_success => '返金が完了しました。ご確認ください';

  @override
  String get after_sales_subtitle_canceled => 'アフターサービス申請をキャンセルしました';

  @override
  String get after_sales_subtitle_default => '処理結果をお待ちください';

  @override
  String get after_sales_product_info => '商品情報';

  @override
  String get after_sales_product_unknown => '商品名不明';

  @override
  String after_sales_spec(String spec) {
    return '仕様：$spec';
  }

  @override
  String after_sales_quantity(int count) {
    return '数量：$count';
  }

  @override
  String get after_sales_info => 'アフターサービス情報';

  @override
  String get after_sales_application_number => '申請番号';

  @override
  String get after_sales_application_time => '申請日時';

  @override
  String get after_sales_refund_amount_label => '返金金額';

  @override
  String get after_sales_application_reason => '申請理由';

  @override
  String get after_sales_detailed_description => '詳細説明';

  @override
  String get after_sales_audit_remark => '審査備考';

  @override
  String get after_sales_revoke => '申請を取り消す';

  @override
  String get after_sales_modify => '申請を修正';

  @override
  String get after_sales_platform_intervention => 'プラットフォーム介入';

  @override
  String get after_sales_list_title => 'アフターサービス一覧';

  @override
  String get after_sales_no_records => 'アフターサービス記録なし';

  @override
  String get after_sales_please_wait => 'しばらくお待ちください...';

  @override
  String get after_sales_unknown_product => '不明な商品';

  @override
  String after_sales_status_label(String status) {
    return '状態: $status';
  }

  @override
  String get after_sales_select_type => 'アフターサービス種別を選択';

  @override
  String get after_sales_type_remake => '再制作';

  @override
  String get after_sales_type_remake_desc => '納品内容に不満がある場合、クリエイターと再制作を協議できます';

  @override
  String get after_sales_type_supplement => '補足';

  @override
  String get after_sales_type_supplement_desc => '納品内容が不完全な場合、クリエイターと補足を協議できます';

  @override
  String get after_sales_type_refund => '返金';

  @override
  String get after_sales_type_refund_desc => '返金を協議する';

  @override
  String get after_sales_no_record_for_order => 'この注文のアフターサービス記録がありません';

  @override
  String after_sales_unknown_error(String error) {
    return 'アフターサービス詳細の読み込み中に不明なエラーが発生しました: $error';
  }

  @override
  String get after_sales_server_error => 'サーバーエラー';

  @override
  String get after_sales_cache_error => 'キャッシュエラー';

  @override
  String get after_sales_network_error => 'ネットワーク接続エラー';

  @override
  String get after_sales_general_unknown_error => '不明なエラーが発生しました';

  @override
  String get favorites_title => 'お気に入り';

  @override
  String get favorites_tab_services => 'サービス';

  @override
  String get favorites_tab_sellers => '販売者';

  @override
  String get favorites_close => '閉じる';

  @override
  String get favorites_empty_services => '保存したサービスはありません';

  @override
  String get favorites_empty_sellers => 'フォロー中の販売者はいません';

  @override
  String get favorites_empty_services_hint => 'サービスを閲覧する際にお気に入りボタンをタップしてください';

  @override
  String get favorites_empty_sellers_hint => '販売者を閲覧する際にフォローボタンをタップしてください';

  @override
  String get favorites_unfollow => 'フォローを外す';

  @override
  String get favorites_remove => 'お気に入りから削除';

  @override
  String get favorites_seller_type_member => '個人販売者';

  @override
  String get favorites_seller_type_enterprise => '法人販売者';

  @override
  String get favorites_seller_type_platform => 'プラットフォーム販売者';

  @override
  String get favorites_seller_type_default => '販売者';

  @override
  String get favorites_status_active => 'アクティブ';

  @override
  String get favorites_status_inactive => '非アクティブ';

  @override
  String get favorites_status_suspended => '一時停止中';

  @override
  String get favorites_status_banned => '凍結済み';

  @override
  String ai_docs_chat_create_failed(String error) {
    return 'チャットセッションを作成できませんでした: $error';
  }

  @override
  String get ai_docs_chat_room_empty => 'チャットルームIDが空のため入室できません';

  @override
  String ai_docs_chat_enter_error(String error) {
    return 'チャット入室中にエラーが発生しました: $error';
  }

  @override
  String get ai_docs_rate_limit_details => '利用回数詳細';

  @override
  String ai_docs_rate_limit_remaining(int count) {
    return '残り$count回';
  }

  @override
  String ai_docs_rate_limit_reset_in(String time) {
    return '$time後にリセット';
  }

  @override
  String get ai_docs_rate_limit_rules => '利用規則';

  @override
  String get ai_docs_rate_limit_burst => 'バースト制限';

  @override
  String get ai_docs_rate_limit_hourly => '時間制限';

  @override
  String get ai_docs_rate_limit_upgrade => 'アップグレードしてより多く利用';

  @override
  String get ai_docs_rate_limit_upgrade_coming => 'アップグレード機能は近日公開予定';

  @override
  String ai_docs_rate_limit_time_hours(int hours) {
    return '$hours時間';
  }

  @override
  String ai_docs_rate_limit_time_minutes(int minutes) {
    return '$minutes分';
  }

  @override
  String ai_docs_rate_limit_time_seconds(int seconds) {
    return '$seconds秒';
  }

  @override
  String get ai_docs_rate_limit_reset => 'リセット済み';

  @override
  String get ai_docs_rate_limit_warning_title => '利用回数が残りわずかです';

  @override
  String get ai_docs_rate_limit_today_remaining => '本日残り回数';

  @override
  String ai_docs_rate_limit_remaining_info(int count, String time) {
    return '残り$count回、$time後にリセット';
  }

  @override
  String get ai_docs_rate_limit_today_usage => '本日の利用状況';

  @override
  String get auth_verification_code_expired => '確認コードの有効期限が切れました';

  @override
  String get auth_get_verification_code => '確認コードを取得';

  @override
  String get home_image_load_failed => '画像の読み込みに失敗しました';

  @override
  String get home_reached_end => 'これ以上ありません';

  @override
  String get home_reviews_title => 'レビュー';

  @override
  String home_reviews_load_failed(String error) {
    return '読み込み失敗: $error';
  }

  @override
  String get home_reviews_no_reviews => 'まだレビューはありません';

  @override
  String get home_reviews_default_content => '良かったです、とても丁寧でした';

  @override
  String get home_reviews_seller_reply => '販売者の返信';

  @override
  String home_reviews_years_ago(int count) {
    return '$count年前';
  }

  @override
  String home_reviews_months_ago(int count) {
    return '$countヶ月前';
  }

  @override
  String home_reviews_days_ago(int count) {
    return '$count日前';
  }

  @override
  String home_reviews_hours_ago(int count) {
    return '$count時間前';
  }

  @override
  String home_reviews_minutes_ago(int count) {
    return '$count分前';
  }

  @override
  String get home_reviews_just_now => 'たった今';

  @override
  String get after_sales_apply_title => 'アフターサービス申請';

  @override
  String get after_sales_select_reason_hint => 'アフターサービス理由を選択してください';

  @override
  String get after_sales_select_reason_validator => 'アフターサービス理由を選択してください';

  @override
  String after_sales_refund_amount_hint(String symbol, String amount) {
    return '最大 $symbol$amount まで返金可能';
  }

  @override
  String get after_sales_refund_amount_required => '返金金額を入力してください';

  @override
  String get after_sales_refund_amount_invalid => '有効な金額を入力してください';

  @override
  String get after_sales_refund_amount_positive => '返金金額は0より大きくなければなりません';

  @override
  String after_sales_refund_amount_exceed(String symbol, String amount) {
    return '返金金額は$symbol$amountを超えることはできません';
  }

  @override
  String after_sales_upload_evidence(int max) {
    return '証拠をアップロード（最大$max枚）';
  }

  @override
  String after_sales_image_process_success(int count, String ratio) {
    return '$count枚の画像を処理しました（平均圧縮率$ratio%）';
  }

  @override
  String after_sales_image_process_failed(int count) {
    return '$count枚の画像の処理に失敗しました';
  }

  @override
  String after_sales_detail_load_failed(String error) {
    return '読み込み失敗: $error';
  }

  @override
  String get after_sales_detail_initializing => '初期化中...';

  @override
  String get after_sales_info_title => 'アフターサービス情報';

  @override
  String get after_sales_info_order_number => '申請番号';

  @override
  String get after_sales_info_apply_time => '申請日時';

  @override
  String get after_sales_info_refund_amount => '返金金額';

  @override
  String get after_sales_info_reason => '申請理由';

  @override
  String get after_sales_info_description => '詳細説明';

  @override
  String get after_sales_info_audit_remark => '審査備考';

  @override
  String after_sales_list_load_failed(String error) {
    return '読み込み失敗: $error';
  }

  @override
  String get after_sales_list_empty => 'アフターサービス記録はありません';

  @override
  String get after_sales_list_loading => 'しばらくお待ちください...';

  @override
  String get after_sales_list_unknown_product => '不明な商品';

  @override
  String after_sales_list_status(String status) {
    return '状態: $status';
  }

  @override
  String after_sales_list_apply_time(String time) {
    return '申請日時: $time';
  }

  @override
  String get after_sales_select_type_title => 'アフターサービス種別を選択';

  @override
  String get after_sales_type_remake_title => '再制作を希望する';

  @override
  String get after_sales_type_remake_subtitle =>
      '納品内容に不満がある場合、クリエイターと再制作を協議できます';

  @override
  String get after_sales_type_supplement_title => '補足を希望する';

  @override
  String get after_sales_type_supplement_subtitle =>
      '納品内容が不完全な場合、クリエイターと補足を協議できます';

  @override
  String get after_sales_type_refund_title => '返金を希望する';

  @override
  String get after_sales_type_refund_subtitle => '返金を協議する';

  @override
  String get favorites_seller_status_active => 'アクティブ';

  @override
  String get favorites_seller_status_inactive => '非アクティブ';

  @override
  String get favorites_seller_status_suspended => '一時停止中';

  @override
  String get favorites_seller_status_banned => '凍結済み';

  @override
  String get app_store_settings => 'ショップ設定';

  @override
  String get app_wallet => 'ウォレット';

  @override
  String get app_wallet_init_failed => 'ウォレットページの初期化に失敗しました';

  @override
  String get app_error_label => 'エラー';

  @override
  String get app_go_back => '戻る';

  @override
  String get app_page_not_found => 'ページが見つかりません';

  @override
  String get app_path_error => 'パスエラー';

  @override
  String get app_error_generic => 'エラー';

  @override
  String get app_dev_menu_title => '開発デバッグメニュー';

  @override
  String get app_dev_common_entries => 'よく使う入口';

  @override
  String get app_dev_dskk => 'DeepStream';

  @override
  String get app_dev_order_module_buyer => '注文モジュール（購入者）';

  @override
  String get app_dev_order_list => '注文一覧';

  @override
  String get app_dev_order_detail_example => '注文詳細（例）';

  @override
  String get app_dev_order_module_seller => '注文モジュール（販売者）';

  @override
  String get app_dev_seller_order_list => '販売者注文一覧';

  @override
  String get app_dev_seller_order_detail_example => '販売者注文詳細（例）';

  @override
  String get app_dev_seller_module => '販売者モジュール';

  @override
  String get app_dev_seller_center => '販売者センター（ホーム）';

  @override
  String get app_dev_ai_docs_module => 'AI Docsモジュール';

  @override
  String get app_dev_ai_chat => 'AIチャット';

  @override
  String get app_dev_test_other => 'テスト/その他';

  @override
  String get app_dev_current_credentials => '現在のテスト認証情報（ハードコード）: ';

  @override
  String get app_dev_temp_injection => '（一時的な注入。Authモジュール統合後に削除されます）';

  @override
  String app_dev_navigation_failed(String path, String error) {
    return '遷移に失敗しました: $path - $error';
  }

  @override
  String get core_processing => '処理中...';

  @override
  String get core_yesterday => '昨日';

  @override
  String get payment_test_title => '支払い機能テスト';

  @override
  String get payment_check_availability => '支払方法の利用可否を確認';

  @override
  String get payment_test_params => 'テストパラメータ';

  @override
  String get payment_order_number => '注文番号';

  @override
  String get payment_amount_yuan => '金額（元）';

  @override
  String get payment_product_name => '商品名';

  @override
  String get payment_select_method => '支払方法を選択';

  @override
  String payment_test_button(String method, String amount) {
    return '$methodをテスト ¥$amount';
  }

  @override
  String get payment_usage_instructions => '使用説明';

  @override
  String get payment_instruction_1 => '1. 上のテストパラメータを変更する';

  @override
  String get payment_instruction_2 => '2. テストする支払方法を選択する';

  @override
  String get payment_instruction_3 => '3. テストボタンをタップして支払いを開始する';

  @override
  String get payment_instruction_4 => '4. 右上の情報ボタンで支払方法の利用可否を確認する';

  @override
  String get payment_test_warning => '注意：テスト環境では0.01を使用することをお勧めします';

  @override
  String get payment_test_product => 'テスト商品';

  @override
  String payment_initiated_success(String message) {
    return '支払いを開始しました：$message';
  }

  @override
  String payment_failed_message(String message) {
    return '支払いに失敗しました：$message';
  }

  @override
  String payment_exception(String error) {
    return '支払いエラー: $error';
  }

  @override
  String get payment_availability_title => '支払方法の利用可否';

  @override
  String get payment_alipay => 'Alipay';

  @override
  String get payment_wechat => 'WeChat Pay';

  @override
  String get payment_wallet_balance => '残高払い';

  @override
  String get payment_confirm => 'OK';

  @override
  String payment_check_failed(String error) {
    return '確認失敗: $error';
  }

  @override
  String get payment_alipay_subtitle => '安全・迅速な支払い';

  @override
  String get payment_wechat_subtitle => 'WeChatセキュア支払い';

  @override
  String get payment_amount_label => '支払金額：';

  @override
  String get payment_terms_agreement => '「支払いを確認」をタップすると、利用規約に同意したことになります';

  @override
  String get payment_create_order_failed => '支払い注文の作成に失敗しました';

  @override
  String get payment_method_test_title => '支払方法テスト';

  @override
  String get payment_alipay_pay => 'Alipayで支払う';

  @override
  String get payment_test_functions => 'テスト機能';

  @override
  String get payment_test_alipay => 'Alipay支払いをテスト';

  @override
  String get payment_test_wechat => 'WeChat Pay支払いをテスト';

  @override
  String get payment_test_credit_card => 'クレジットカード支払いをテスト';

  @override
  String get payment_recent_test_result => '直近のテスト結果';

  @override
  String get payment_no_test_result => 'テスト結果はまだありません';

  @override
  String get payment_available => '利用可能';

  @override
  String get payment_unavailable => '利用不可';

  @override
  String payment_method_label(String name) {
    return '支払方法：$name';
  }

  @override
  String get payment_mock_mode => 'モックモード';

  @override
  String payment_error_label(String error) {
    return 'エラー: $error';
  }

  @override
  String get payment_nav_network_failed => 'ネットワーク接続失敗';

  @override
  String get payment_nav_network_error_message =>
      'ネットワーク接続エラーが発生しました。接続を確認して再試行してください';

  @override
  String get payment_nav_view_orders => '注文を確認';

  @override
  String get payment_nav_retry_payment => '支払いを再試行';

  @override
  String get payment_nav_result_unknown_title => '支払い結果不明';

  @override
  String get payment_nav_result_unknown_message =>
      '支払い結果を確認できません。後ほど注文状態をご確認いただくか、サポートにお問い合わせください';

  @override
  String get payment_nav_query_status => '状態を確認';

  @override
  String get payment_nav_cancel_continue => '支払いをキャンセルしました。引き続き支払いを完了できます';

  @override
  String get payment_nav_processing => '支払いを処理中です。後ほど注文状態をご確認ください';

  @override
  String get payment_nav_success => '支払い成功';

  @override
  String get payment_nav_failed => '支払い失敗';

  @override
  String get payment_nav_retrying => '支払いを再開始中...';

  @override
  String get payment_nav_retry_failed => '支払いを再試行できません。注文情報が見つかりません';

  @override
  String get payment_nav_querying => '支払い状態を確認中...';

  @override
  String get payment_nav_query_failed => '状態を確認できません。注文情報が見つかりません';

  @override
  String payment_test_description(String subject) {
    return '$subject - 支払いテスト';
  }

  @override
  String get chat_translating => '翻訳中...';

  @override
  String get chat_translation_label => '翻訳';

  @override
  String get after_sales_info_evidence => '証拠画像';

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
  String get agentAndCliTitle => 'Agent と CLI';

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
  String get agentOpenChat => '相談チャットを開く';

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
  String get agentAbandon => '破棄';

  @override
  String get agentManageConnectedAgents => '接続済み Agent を管理';

  @override
  String get agentErrorInvalidCode => '接続コードが無効です。';

  @override
  String get agentErrorExpired => '接続リクエストの有効期限が切れました。CLI から再度ログインしてください。';

  @override
  String get agentErrorAlreadyUsed => 'この接続リクエストは使用済みまたはキャンセル済みです。';

  @override
  String get agentErrorDenied => 'この接続リクエストは拒否されました。';

  @override
  String get agentErrorRateLimited => '試行回数が多すぎます。しばらくしてから再試行してください。';

  @override
  String get agentErrorNotFound => 'この Agent レコードは存在しません。';

  @override
  String get agentErrorGeneric => 'Agent 操作を完了できませんでした。接続を確認して再試行してください。';

  @override
  String get agentAuthorizationAlreadyApproved => 'この接続は承認済みです。CLI に戻ってください。';

  @override
  String get agentAuthorizationAlreadyDenied => 'この接続は拒否済みです。';

  @override
  String get agentAuthorizationAlreadyUsed => 'この接続コードは使用済みです。';

  @override
  String get agentAuthorizationUnavailable => 'この接続リクエストは利用できません。';

  @override
  String get agentAuditConnected => 'Agent が接続されました';

  @override
  String get agentAuditRefreshed => 'セッションが更新されました';

  @override
  String get agentAuditReplayBlocked => '不審なトークン再利用をブロックしました';

  @override
  String get agentAuditPermissionsReduced => '権限が縮小されました';

  @override
  String get agentAuditRevoked => 'Agent が取り消されました';

  @override
  String get agentAuditSecurityEvent => 'セキュリティイベント';

  @override
  String get agentAuditSuccess => '成功';

  @override
  String get agentAuditRecorded => '記録済み';

  @override
  String get agentClientType => 'クライアント種別';

  @override
  String get agentClientId => 'クライアント識別子';

  @override
  String get agentAccessExpiresAt => 'アクセス有効期限';

  @override
  String get agentAuthorizationExpiresAt => '認可有効期限';

  @override
  String get agentAuthorizationRequestExpiresAt => '接続リクエストの有効期限';

  @override
  String get agentClientMetadataNotice =>
      '上記のクライアント、デバイス、システム、バージョン情報は接続プログラムによる自己申告です。デバイスを確認し、DeepStream の公式ドメインからのみ CLI をインストールしてください。';

  @override
  String get agentAuditAuthorizationRequested => '接続がリクエストされました';

  @override
  String get agentAuditAuthorizationApproved => '接続が承認されました';

  @override
  String get agentAuditAuthorizationDenied => '接続が拒否されました';

  @override
  String get agentAuditAllRevoked => 'すべての Agent が取り消されました';

  @override
  String get agentAuditRequestCreated => 'リクエスト下書きが作成されました';

  @override
  String get agentAuditRequestApproved => 'リクエスト下書きが承認されました';

  @override
  String get agentAuditRequestAbandoned => 'リクエスト下書きが破棄されました';

  @override
  String get agentViewTaskStatus => 'タスクの状態を表示';

  @override
  String get dsnTaskStatusTitle => 'タスクの状態';

  @override
  String get dsnTaskIdentity => 'タスク識別情報';

  @override
  String get dsnTaskTraceId => 'タスク追跡 ID';

  @override
  String get dsnTaskOperationTraceId => '操作追跡 ID';

  @override
  String get dsnTaskAxes => 'インタラクション状態';

  @override
  String get dsnTaskLifecycle => 'タスクのライフサイクル';

  @override
  String get dsnTaskResponsibility => '責任アクション';

  @override
  String get dsnTaskSyncStatus => '同期状態';

  @override
  String get dsnTaskWaitingOn => '待機対象';

  @override
  String get dsnTaskPrimaryAction => '主操作';

  @override
  String get dsnTaskRefreshProjection => '状態を更新';

  @override
  String get dsnTaskReceipt => 'レシート';

  @override
  String get dsnTaskNoReceipt => 'レシートはまだありません。';

  @override
  String get dsnTaskLoadReceipt => 'レシートを読み込む';

  @override
  String get dsnTaskRefreshReceipt => 'レシートを更新';

  @override
  String get dsnTaskReceiptState => 'レシート状態';

  @override
  String get dsnTaskReceiptOrder => '注文 ID';

  @override
  String get dsnTaskReceiptDeliveries => '配送数';

  @override
  String get dsnTaskReceiptGeneratedAt => '生成日時';

  @override
  String get dsnTaskReceiptSource => 'レシートソース';

  @override
  String get dsnTaskLegacyFallback => '追加専用レシートが利用できないため、旧事実ビューを使用しています。';

  @override
  String get dsnTaskActionRecoverOperation => '元の操作状態を復旧';

  @override
  String get dsnTaskActionRecoverTask => 'タスク状態を復旧';

  @override
  String get dsnTaskActionReviewResponsibility => '保留中の責任を確認';

  @override
  String get dsnTaskActionRecoveryInProgress => '復旧中';

  @override
  String get dsnTaskActionViewProgress => '進捗を表示';

  @override
  String get dsnTaskActionViewSystemStatus => 'システム状態を表示';

  @override
  String get dsnTaskActionViewRecord => '記録を表示';

  @override
  String get dsnTaskActionDomain => '次のステップを表示';

  @override
  String get dsnTaskActionUnknown => '追加確認が必要です';

  @override
  String get credit_wallet_available => '利用可能なクレジット';

  @override
  String get credit_wallet_usage_notice =>
      'クレジットは DeepStream 内の商品やサービスに利用できます。現在、出金や譲渡はできません。';

  @override
  String get credit_purchase_title => 'クレジットを購入';

  @override
  String get credit_purchase_subtitle => 'クレジットパックを選択してください。支払いはアプリストアで処理されます。';

  @override
  String get credit_purchase_unavailable => '現在、クレジットを購入できません。';

  @override
  String get credit_purchase_reload => '再読み込み';

  @override
  String credit_purchase_credits(int credits) {
    return '$creditsクレジット';
  }

  @override
  String get credit_purchase_checking => '確認中…';

  @override
  String get credit_purchase_check => '状況を確認';

  @override
  String get credit_purchase_check_arrival => '反映を確認';

  @override
  String get credit_purchase_disclaimer =>
      'クレジットは DeepStream 内でのみ利用でき、出金、譲渡、現金への換金はできません。支払いと返金はアプリストアで処理されます。';

  @override
  String credit_amount_positive(int credits) {
    return '+$creditsクレジット';
  }

  @override
  String credit_amount_negative(int credits) {
    return '-$creditsクレジット';
  }

  @override
  String get credit_purchase_status_pending_detected =>
      '確認待ちの購入が見つかりました。クレジットの反映状況を確認しています。';

  @override
  String get credit_purchase_status_server_pending =>
      '前回の購入をサーバーで処理中です。しばらくしてから再度確認してください。';

  @override
  String get credit_purchase_status_no_products => '現在購入できるクレジットパックはありません。';

  @override
  String get credit_purchase_status_load_failed =>
      'クレジットパックを読み込めませんでした。しばらくしてから再試行してください。';

  @override
  String get credit_purchase_status_balance_preflight_failed =>
      '最新のクレジット残高を取得できなかったため、購入は開始されませんでした。';

  @override
  String get credit_purchase_status_cancelled => '購入をキャンセルしました。';

  @override
  String get credit_purchase_status_store_pending =>
      'アプリストアで支払いを処理中です。重複して購入しないでください。';

  @override
  String get credit_purchase_status_submitted => '支払いを送信しました。クレジットの反映を確認しています。';

  @override
  String get credit_purchase_status_network_ambiguous =>
      '通信が途切れたため、購入結果を確認できません。重複して購入しないでください。';

  @override
  String get credit_purchase_status_store_ambiguous =>
      'アプリストアから明確な結果を取得できませんでした。確認中のため、重複して購入しないでください。';

  @override
  String get credit_purchase_status_failed =>
      '購入を完了できませんでした。しばらくしてから再試行してください。';

  @override
  String get credit_purchase_status_unsafe_reconciliation =>
      '前回の購入を安全に確認できません。重複購入せず、サポートにお問い合わせください。';

  @override
  String get credit_purchase_status_checking_again => '購入状況を再確認しています。';

  @override
  String get credit_purchase_status_balance_updated_guarded =>
      'クレジット残高は更新されましたが、端末上の購入確認記録を安全に消去できませんでした。しばらくしてから再度確認してください。';

  @override
  String get credit_purchase_status_confirmed => 'クレジットが反映されました。';

  @override
  String get credit_purchase_status_reversed =>
      'この購入は取り消しまたは返金されたため、クレジットは反映されませんでした。';

  @override
  String get credit_purchase_status_delayed =>
      '支払い記録を引き続き確認しています。重複して購入しないでください。長時間反映されない場合やアプリストアで請求されていない場合は、サポートにお問い合わせください。';

  @override
  String get agentMandates => 'Agent 预授权';

  @override
  String get agentMandatesHint =>
      '预授权是你在本 App 内审核的固定、有限授权；它不会共享你的登录凭证或 Agent 凭证。';

  @override
  String get agentCreateMandate => '创建预授权';

  @override
  String get agentMandateNoItems => '暂无预授权';

  @override
  String get agentMandateNoAgents => '请先连接一个活跃的 Agent，再创建预授权。';

  @override
  String get agentMandateTemplate => '固定模板';

  @override
  String get agentMandateAgent => '已连接的 Agent';

  @override
  String get agentMandateResource => '服务端资源引用';

  @override
  String get agentMandateResourceHint =>
      '使用 DeepStream 提供的请求、已接受报价或 Commitment 引用。';

  @override
  String get agentMandateResourceVersion => '预期资源版本（可选）';

  @override
  String get agentMandateSpecHash => '预期规格哈希（可选）';

  @override
  String get agentMandateQuoteHash => '预期报价哈希（可选）';

  @override
  String get agentMandatePreview => '审核固定授权';

  @override
  String get agentMandateReviewTitle => '审核预授权';

  @override
  String get agentMandateConfirm => '确认预授权';

  @override
  String get agentMandateConfirmMessage =>
      '确认后将为展示的 Agent 和服务端资源创建有限授权。Agent 无法自行扩大该授权。';

  @override
  String get agentMandateExpiresAt => '审核过期时间';

  @override
  String get agentMandateAllowedActions => '允许动作';

  @override
  String get agentMandateStatus => '状态';

  @override
  String get agentMandateVersion => '预授权版本';

  @override
  String get agentMandateHash => '预授权哈希';

  @override
  String get agentMandateRevokedAt => '撤销时间';

  @override
  String get agentMandateRevoke => '撤销预授权';

  @override
  String get agentMandateRevokeConfirm => '现在撤销此授权？新的 Agent 操作将被阻断，历史事实仍会保留。';

  @override
  String get agentMandateBuyerTemplate => '买方固定承诺';

  @override
  String get agentMandateProviderTaskTemplate => '服务方固定任务';

  @override
  String get agentMandateActionBuyerCommitment => '确认固定承诺';

  @override
  String get agentMandateActionProviderOffer => '提交固定报价';

  @override
  String get agentMandateActionProviderAccept => '接受固定请求';

  @override
  String get agentMandateActionProviderDelivery => '在 Commitment 存在后提交交付';
}
