# 路由与屏幕映射文档

本文档提供了React Native应用、HTML原型和目标Flutter应用之间的映射关系，用于指导AI重构过程。

## 映射表格式说明

每个映射条目包含以下信息：

1. **React Native路径**: 原React Native项目中的文件路径
2. **HTML原型路径**: 对应的HTML原型文件路径
3. **Flutter目标路径**: 重构后的Flutter项目中的目标文件路径
4. **API端点**: 相关的API端点（如适用）
5. **说明**: 屏幕功能简述和注意事项

## 主标签页面 (Tabs)

### 首页模块 (Homepage)

| React Native路径 | HTML原型路径 | Flutter目标路径 | API端点 | 说明 |
|-----------------|-------------|----------------|--------|------|
| `app/(tabs)/homepage/index.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/homepage/index.html` | `lib/modules/home/presentation/screens/home_screen.dart` | `/api/services/recommended`, `/api/services/categories` | 主页面，显示推荐服务和分类 |
| `app/(tabs)/homepage/search.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/homepage/search.html` | `lib/modules/home/presentation/screens/search_screen.dart` | `/api/services/search` | 搜索页面 |
| `app/(tabs)/homepage/searchResult.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/homepage/search_result.html` | `lib/modules/home/presentation/screens/search_result_screen.dart` | `/api/services/search` | 搜索结果页面 |
| `app/(tabs)/homepage/load_portrait.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/homepage/load_portrait.html` | `lib/modules/home/presentation/screens/load_portrait_screen.dart` | `/api/user/portrait/upload` | 上传头像页面 |

### AI文档模块 (AI Docs)

| React Native路径 | HTML原型路径 | Flutter目标路径 | API端点 | 说明 |
|-----------------|-------------|----------------|--------|------|
| `app/(tabs)/ai_docs/docs_homepage.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/ai_docs/docs_homepage.html` | `lib/modules/ai_docs/presentation/screens/docs_homepage_screen.dart` | `/api/ai/documents` | AI文档主页 |
| `app/(tabs)/ai_docs/chat-view.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/ai_docs/chat-view.html` | `lib/modules/ai_docs/presentation/screens/chat_view_screen.dart` | `/api/ai/chat` | AI聊天视图 |
| `app/(tabs)/ai_docs/create_profile-1.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/ai_docs/create_profile-1.html` | `lib/modules/ai_docs/presentation/screens/create_profile_step1_screen.dart` | `/api/ai/profile/create` | 创建AI配置文件第1步 |
| `app/(tabs)/ai_docs/create_profile-2.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/ai_docs/create_profile-2.html` | `lib/modules/ai_docs/presentation/screens/create_profile_step2_screen.dart` | `/api/ai/profile/create` | 创建AI配置文件第2步 |
| `app/(tabs)/ai_docs/docs.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/ai_docs/docs.html` | `lib/modules/ai_docs/presentation/screens/docs_screen.dart` | `/api/ai/documents` | 文档列表 |
| `app/(tabs)/ai_docs/furnish-view.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/ai_docs/furnish-view.html` | `lib/modules/ai_docs/presentation/screens/furnish_view_screen.dart` | `/api/ai/furnish` | 文档润色视图 |
| `app/(tabs)/ai_docs/history.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/ai_docs/history.html` | `lib/modules/ai_docs/presentation/screens/history_screen.dart` | `/api/ai/history` | 历史记录 |
| `app/(tabs)/ai_docs/input-view.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/ai_docs/input-view.html` | `lib/modules/ai_docs/presentation/screens/input_view_screen.dart` | `/api/ai/input` | 输入视图 |
| `app/(tabs)/ai_docs/question-answer-view.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/ai_docs/question-answer-view.html` | `lib/modules/ai_docs/presentation/screens/question_answer_view_screen.dart` | `/api/ai/qa` | 问答视图 |
| `app/(tabs)/ai_docs/[id]/index.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/ai_docs/doc_detail.html` | `lib/modules/ai_docs/presentation/screens/doc_detail_screen.dart` | `/api/ai/documents/{id}` | 文档详情 |
| `app/(tabs)/ai_docs/[id]/doc_detail.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/ai_docs/doc_detail.html` | `lib/modules/ai_docs/presentation/screens/doc_detail_screen.dart` | `/api/ai/documents/{id}` | 文档详情 |

### 聊天模块 (Chat)

| React Native路径 | HTML原型路径 | Flutter目标路径 | API端点 | 说明 |
|-----------------|-------------|----------------|--------|------|
| `app/(tabs)/chat/index.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/chat/index.html` | `lib/modules/chat/presentation/screens/chat_list_screen.dart` | `/api/chat/list` | 聊天列表 |
| `app/(outer)/chatroom.tsx` | `DSKK-renew/new-proto/HTML-new/outer/chatroom.html` | `lib/modules/chat/presentation/screens/chat_room_screen.dart` | `/api/chat/messages`, `/api/chat/send` | 聊天室 |

### 个人资料模块 (Profile)

| React Native路径 | HTML原型路径 | Flutter目标路径 | API端点 | 说明 |
|-----------------|-------------|----------------|--------|------|
| `app/(tabs)/profile/index.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/profile/index.html` | `lib/modules/profile/presentation/screens/profile_screen.dart` | `/api/user/profile` | 个人资料主页 |
| `app/(tabs)/profile/notification.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/profile/notification.html` | `lib/modules/profile/presentation/screens/notification_screen.dart` | `/api/user/notifications` | 通知页面 |
| `app/(tabs)/profile/saved_list.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/profile/saved_list.html` | `lib/modules/profile/presentation/screens/saved_list_screen.dart` | `/api/user/saved` | 收藏列表 |
| `app/(tabs)/profile/timeManage.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/profile/timeManage.html` | `lib/modules/profile/presentation/screens/time_manage_screen.dart` | `/api/user/time` | 时间管理 |
| `app/(tabs)/profile/wallet.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/profile/wallet.html` | `lib/modules/profile/presentation/screens/wallet_screen.dart` | `/api/user/wallet` | 钱包页面 |

### 订单模块 (Orders)

| React Native路径 | HTML原型路径 | Flutter目标路径 | API端点 | 说明 |
|-----------------|-------------|----------------|--------|------|
| `app/(tabs)/profile/orders/index.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/profile/orders/index.html` | `lib/modules/orders/presentation/screens/orders_list_screen.dart` | `/api/orders/list` | 订单列表 |
| `app/(tabs)/profile/orders/evaluation.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/profile/orders/evaluation.html` | `lib/modules/orders/presentation/screens/evaluation_screen.dart` | `/api/orders/evaluation` | 评价页面 |
| `app/(tabs)/profile/orders/postsale.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/profile/orders/postsale.html` | `lib/modules/orders/presentation/screens/postsale_screen.dart` | `/api/orders/postsale` | 售后页面 |
| `app/(tabs)/profile/orders/search.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/profile/orders/search.html` | `lib/modules/orders/presentation/screens/order_search_screen.dart` | `/api/orders/search` | 订单搜索 |
| `app/(tabs)/profile/orders/searchOrderRes.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/profile/orders/searchOrderRes.html` | `lib/modules/orders/presentation/screens/order_search_result_screen.dart` | `/api/orders/search` | 订单搜索结果 |
| `app/(tabs)/profile/orders/[transaction_id]/index.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/profile/orders/order_detail.html` | `lib/modules/orders/presentation/screens/order_detail_screen.dart` | `/api/orders/{id}` | 订单详情 |
| `app/(tabs)/profile/orders/[transaction_id]/rePostMaterials.tsx` | `DSKK-renew/new-proto/HTML-new/tabs/profile/orders/rePostMaterials.html` | `lib/modules/orders/presentation/screens/repost_materials_screen.dart` | `/api/orders/{id}/repost` | 重新提交材料 |

## 外部页面 (Outer)

### 登录模块 (Login)

| React Native路径 | HTML原型路径 | Flutter目标路径 | API端点 | 说明 |
|-----------------|-------------|----------------|--------|------|
| `app/(outer)/login/index.tsx` | `DSKK-renew/new-proto/HTML-new/outer/login/index.html` | `lib/modules/auth/presentation/screens/login_screen.dart` | `/api/auth/login` | 登录页面 |
| `app/(outer)/login/mobile/mobileLogin.tsx` | `DSKK-renew/new-proto/HTML-new/outer/login/mobile/mobileLogin.html` | `lib/modules/auth/presentation/screens/mobile_login_screen.dart` | `/api/auth/mobile/login` | 手机登录 |
| `app/(outer)/login/mobile/verifyCode.tsx` | `DSKK-renew/new-proto/HTML-new/outer/login/mobile/verifyCode.html` | `lib/modules/auth/presentation/screens/verify_code_screen.dart` | `/api/auth/mobile/verify` | 验证码验证 |

### 其他外部页面

| React Native路径 | HTML原型路径 | Flutter目标路径 | API端点 | 说明 |
|-----------------|-------------|----------------|--------|------|
| `app/(outer)/modal.tsx` | `DSKK-renew/new-proto/HTML-new/outer/modal.html` | `lib/modules/common/presentation/screens/modal_screen.dart` | - | 模态页面 |
| `app/(outer)/seller_guide.tsx` | `DSKK-renew/new-proto/HTML-new/outer/seller_guide.html` | `lib/modules/seller/presentation/screens/seller_guide_screen.dart` | `/api/seller/guide` | 卖家指南 |

## 卖家页面 (Seller Screens)

| React Native路径 | HTML原型路径 | Flutter目标路径 | API端点 | 说明 |
|-----------------|-------------|----------------|--------|------|
| `app/(sellerscreens)/index.tsx` | `DSKK-renew/new-proto/HTML-new/sellerscreens/index.html` | `lib/modules/seller/presentation/screens/seller_home_screen.dart` | `/api/seller/dashboard` | 卖家主页 |
| `app/(sellerscreens)/chat/index.tsx` | `DSKK-renew/new-proto/HTML-new/sellerscreens/chat/index.html` | `lib/modules/seller/presentation/screens/seller_chat_screen.dart` | `/api/seller/chats` | 卖家聊天 |
| `app/(sellerscreens)/post/index.tsx` | `DSKK-renew/new-proto/HTML-new/sellerscreens/post/index.html` | `lib/modules/seller/presentation/screens/seller_post_screen.dart` | `/api/seller/posts` | 卖家发布 |
| `app/(sellerscreens)/profile/index.tsx` | `DSKK-renew/new-proto/HTML-new/sellerscreens/profile/index.html` | `lib/modules/seller/presentation/screens/seller_profile_screen.dart` | `/api/seller/profile` | 卖家资料 |

## 使用说明

1. **AI重构过程**：AI在重构每个屏幕时，应参考此映射文档找到对应的React Native代码、HTML原型和API端点。
2. **文件路径**：Flutter目标路径遵循`docs/Flutter项目结构设计.md`中定义的项目结构。
3. **API集成**：API端点信息来自`docs/页面-功能-API调用映射.md`和API文档（`api/backend-api.json`和`api/model-api.json`）。
4. **动态路由**：对于包含参数的动态路由（如`[id]`、`[transaction_id]`），Flutter实现应使用GoRouter的路由参数功能。

## 注意事项

1. 此映射文档可能不完整，在实际重构过程中可能需要根据具体情况进行调整。
2. 某些React Native页面可能没有对应的HTML原型，或者HTML原型可能与React Native实现有所不同，此时应以React Native代码为主要参考。
3. Flutter目标路径是基于`docs/Flutter项目结构设计.md`中的模块化结构推导的，实际实现时可能需要根据具体需求进行调整。