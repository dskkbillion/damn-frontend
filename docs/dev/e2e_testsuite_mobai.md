# DSKK 前端 E2E 测试集（mobai 自动化）

## 0. 总览

| 维度 | 数值 |
|------|------|
| 模块数 | 11 |
| 总用例数 | 127 |
| 自动化 yes（可纯自动跑） | 43 |
| 自动化 partial（半自动） | 70 |
| 自动化 no（无法自动化/作废） | 14 |

**模块用例分布**

| Issue | 模块 | 用例数 |
|-------|------|--------|
| 209 | auth（登录认证） | 12 |
| 210 | Home（首页） | 15 |
| 211 | ai_docs（AI 对话） | 9 |
| 213 | Orders（订单） | 13 |
| 214 | Payment（支付） | 11 |
| 216 | favorites（收藏） | 8 |
| 217 | after_sales（售后） | 12 |
| 218 | seller（卖家） | 16 |
| 344 | Wallet & Connect（钱包/收款） | 31 |

> 注：seller 模块 JSON 中 SELL-08 缺位（编号跳号），实际为 16 条；Wallet & Connect 为单 issue 内 WAL（19 条）+ CON（12 条）两组共 31 条。

**登录基建说明（mobai type 自动化）**

所有需要登录态的 case 走统一登录基建，可用 mobai 全自动完成：

- 进入 `unified_login_page`，选「手机号」模式
- mobai `type` 输入手机号 **18888888888**
- 点击「获取验证码」
- mobai `type` 输入万能码 **565656**
- 点击「登录」→ 断言 SnackBar「登录成功!」+ 跳转 home

卖家登录同样使用 18888888888 + 565656（该账号 bound 状态视 fixture 而定）。这是除「真实邮箱/国际号码/Stripe/短信验证码」外，所有 case 的统一前置入口，已被验证为 `automatable=yes`（AUTH-01）。

---

## 1. 全局前置（Fixtures）

下面归纳全部 127 条 case 用到的前置态。**「本地 DB 已有」指现有 seed 数据可直接复用，「需造」指必须用 mysql CLI 插数据或后端造数据后才能跑绿。**

### 1.1 账号类 fixtures

| Fixture | 说明 | 状态 |
|---------|------|------|
| 买家账号（已登录） | 手机号 18888888888 + 565656 万能码 | 本地已有 |
| 卖家账号（已登录） | 同号码，AppMode=seller | 本地已有 |
| 卖家账号 bound=true（已绑定收款账户） | Stripe Connect 已激活 | **需造**（WAL-02/03/14、CON-09） |
| 卖家账号 bound=false（未绑定） | Stripe Connect 未初始化 | **需造**（WAL-18、CON-01/02） |
| 卖家账号 PendingVerification | Stripe 审核中状态 | **需造**（CON-07/08） |
| 卖家账号 ConnectAccountError | 检查账户返回错误 | **需造/模拟网络错误**（CON-10） |
| 真实邮箱账号 | 可收验证码邮件（可能进垃圾箱） | **需真实邮箱配置**（AUTH-03） |
| 国际号码账号 | 后端不支持，阻塞 | **不可造**（AUTH-02 阻塞） |
| token 已过期/被撤销的登录态 | 触发 401/403 | **需后端造数据**（AUTH-11） |

### 1.2 商品/收藏类 fixtures

| Fixture | 说明 | 状态 |
|---------|------|------|
| 已发布商品（多张图片、有描述、有 variant 价格） | 首页/详情/轮播 | 本地已有 |
| 有评价的商品（含 buyer 昵称、星级、skuName、时间） | HOME-08/09 | 本地建议有，**评价数据可能需造** |
| 已收藏商品（favoriteStatusMap=true） | HOME-07、FAV-05 | **需造收藏关系** |
| 未收藏商品 | HOME-06 | 本地已有 |
| 卖家有多件已发布商品 | 卖家主页商品列表 | 本地建议有 |
| 收藏服务 ≥ 1 | FAV-01/05/07 | **需造** |
| 关注卖家 ≥ 1 | FAV-02/06 | **需造** |
| 收藏服务 ≥ 10（分页） | FAV-04 | **需造 10+ 条** |
| 无收藏/无关注（空态） | FAV-08 | **需造空账号** |
| 卖家在售商品（status=normal）≥ 1 | SELL-04/06/15 | **需造** |
| 卖家已下架商品（status=disabled） | SELL-14/16/17 | **需造** |
| 卖家草稿商品 | SELL-16 | **需造** |
| 卖家周收入数据 | SELL-01/09、统计图表 | **需后端造** |
| 待审核售后申请（卖家侧） | SELL-13 | **需造** |
| 本地搜索历史（SharedPreferences） | HOME-15 | **需预置/手动产生** |

### 1.3 订单/支付/售后类 fixtures

| Fixture | 说明 | 状态 |
|---------|------|------|
| 待付款订单（awaitingPayment） | ORD-01/07、PAY-01 | **需造** |
| 待付款订单 ≥ 3 条 | ORD-03 下拉刷新（DEE-44） | **需造 3+ 条** |
| 待收货订单（awaitingConfirmation） | ORD-06、AS-02 | **需造** |
| 待评价订单（awaitingEvaluation） | ORD-10/11 | **需造** |
| 某状态完全无订单的 tab | ORD-04 空态 | **需造空状态** |
| 多状态混合订单 | ORD-02 筛选 | **需造多状态** |
| 已完成订单 + 对应售后记录 | AS-01/09 | **需造** |
| 多种 refundState 的售后申请 | AS-10（wait_audit/audit_pass/audit_reject/refund_success/canceled） | **需造多状态** |
| audit_reject 状态售后 | AS-12 平台介入 | **需造** |
| 有交易记录的钱包 | WAL-06/12/13 | **需造交易流水** |
| 多类型交易（收入/支出） | WAL-07 | **需造** |
| 跨日期交易记录 | WAL-08 | **需造** |
| 交易记录 ≥ pageSize | WAL-10 分页 | **需造大量流水** |
| 无交易记录的钱包 | WAL-11 空态 | **需造空账号** |
| 余额=0 的卖家 | WAL-02 | **需造** |
| 余额>0 的卖家 | WAL-03/14/15/16/17 | **需造** |

### 1.4 外部依赖类 fixtures（无法纯本地造）

| Fixture | 说明 | 依赖 |
|---------|------|------|
| 邮箱验证码 | 真实邮件，可能进垃圾箱 | 真实邮箱服务 |
| 短信/邮件验证码过期场景 | 等待 5 分钟或时间伪造 | 时间/后端造数据 |
| Stripe 支付成功回调 | success_url 重定向 | 真实 Stripe / webhook mock |
| Stripe WebView 取消/失败/过期/return/refresh | cancelUrl/refreshUrl/returnUrl 触发 | 真实 Stripe / mock WebView |
| 真实提现接口响应 | WAL-17 | 真实支付接口 |
| AI 流式响应 | AI-03 逐字渲染 | 真实 AI 服务 / mock 流 |
| AI 推荐列表 /get_related_services | AI-04/05/06 | 后端推荐数据 / mock |
| AI rate limit remaining ≤ 5 | AI-08/09 | 造数据 / 绕过真实限流 |
| 物流场景数据 | ORD-08（已作废） | 无 |

---

## 2. 分模块测试用例

### 2.1 auth（登录认证） — issue 209

| Case ID | 描述 | 前置 | 自动化 | issue状态 |
|---------|------|------|--------|-----------|
| AUTH-01 | 手机号登录-中国大陆号码正常登录 | 未登录 | yes | ✅ |
| AUTH-02 | 手机号登录-国际号码选区号后登录 | 未登录 | no | ❌ 阻塞 |
| AUTH-03 | 邮箱登录-切换邮箱模式并登录 | 未登录+真实邮箱 | partial | ✅ 功能通过，验证码进垃圾箱 |
| AUTH-04 | 无效手机号格式-提示格式错误 | 未登录，手机号模式 | yes | ✅ |
| AUTH-05 | 无效邮箱格式-提示格式错误 | 未登录，邮箱模式 | yes | ⚠️ 待测试 |
| AUTH-06 | 发送验证码-按钮触发并显示倒计时 | 已输入有效手机号 | yes | ✅ |
| AUTH-07 | 验证码错误-提示文案正确（非技术报错） | 已获取验证码 | yes | ❌ 缺陷（已修复） |
| AUTH-08 | 验证码过期-提示文案正确 | 验证码已过期 | partial | ⚠️ 部分验证 |
| AUTH-09 | 重新发送验证码-倒计时结束后可重发 | 已发过一次验证码 | partial | ✅ |
| AUTH-10 | 退出登录-清除状态跳转登录页 | 已登录 | partial | ✅ |
| AUTH-11 | Token 过期-自动跳转登录页 | 已登录+token 过期 | no | ❓ 暂未验证 |
| AUTH-12 | 用户协议/隐私政策链接可跳转 | 进入登录页 | no | ⚠️ 待测试 |

**详细 steps / assertions**

- **AUTH-01** 手机号登录
  - 前置：未登录状态，进入登录页面
  - steps：选「手机号」模式 → 输入 18888888888 → 点「获取验证码」→ 输入万能码 565656 → 点「登录」
  - assertions：存在文本「手机号」「获取验证码」「登录」；成功后 SnackBar「登录成功!」；跳转 home route
- **AUTH-02** 国际号码登录
  - 前置：未登录，登录页
  - steps：选「手机号」→ 点国家选择器 → 选 US → 输入 US 10 位号码 → 获取验证码 → 登录
  - assertions：存在「选择国家/地区」；国家选择器允许切换非中国区号
  - blocker：后端仅支持中国大陆格式，国际号码无法通过后端验证（❌ 阻塞）
- **AUTH-03** 邮箱登录
  - 前置：未登录，登录页
  - steps：选「邮箱」模式 → 输入有效邮箱 → 获取验证码 → 输入码 → 登录
  - assertions：存在「邮箱」「邮箱地址」「请输入邮箱地址」；邮箱模式下「获取验证码」可点
  - blocker：邮箱验证码可能进垃圾箱，需真实邮箱配置；mobai 可自动化交互但无法自动获取邮箱码
- **AUTH-04** 无效手机号
  - steps：输入无效号码（如 123）→ 点获取验证码/登录
  - assertions：SnackBar「请输入11位手机号」或「请输入有效的电话号码」；按钮禁用或提交被阻止
- **AUTH-05** 无效邮箱
  - steps：邮箱模式输入无效格式（test 或 test@）→ 点获取验证码/登录
  - assertions：SnackBar「请输入有效的邮箱地址」；按钮禁用或表单验证失败
- **AUTH-06** 发送验证码倒计时
  - steps：点「获取验证码」→ 观察按钮
  - assertions：loading（CircularProgressIndicator）→ 倒计时「60 s」递减到 0 → 回到「获取验证码」
- **AUTH-07** 验证码错误
  - steps：输入错误码（000000）→ 点登录
  - assertions：SnackBar「验证码错误或已过期，请重新获取」；NOT 显示 ServerException 原始异常
  - 状态：已在 unified_login_page.dart 第 91-102 行修复
- **AUTH-08** 验证码过期
  - steps：等待过期 → 输入任意码 → 登录
  - assertions：SnackBar「验证码已过期」或「验证码错误或已过期，请重新获取」
  - blocker：需等待 5 分钟以上，自动化需后端造数据或时间伪造
- **AUTH-09** 重新发送
  - steps：等待倒计时完成（60 秒）→ 观察按钮 → 重新点击
  - assertions：倒计时为 0 时恢复「获取验证码」+ enabled；点击后开始新倒计时
  - blocker：完整验证需等 60 秒，耗时长；可只验证倒计时结束后状态
- **AUTH-10** 退出登录
  - steps：打开 profile tab → 找 logout 按钮 → 点击
  - assertions：导航到 unified_login_page；token/session 清除；重进 home 需重新登录
  - blocker：需 profile 模块 logout 入口存在
- **AUTH-11** Token 过期
  - steps：已登录态触发任意 API（进 orders）→ 观察
  - assertions：检测 401/403 → 自动导航登录页 → 之前状态不保留
  - blocker：需真实 token 过期或后端造数据，纯 mobai 无法模拟
- **AUTH-12** 协议/隐私链接
  - steps：滚到底部 → 点「用户协议」→ 验证跳转 → 返回 → 点「隐私政策」
  - assertions：存在「用户协议」「隐私政策」「和」；点击后跳转/打开 WebView
  - blocker：两个链接 onPressed 均为 TODO（第 341-365 行），仅 debugPrint，跳转未实现

---

### 2.2 Home（首页） — issue 210

| Case ID | 描述 | 前置 | 自动化 | issue状态 |
|---------|------|------|--------|-----------|
| HOME-01 | 首页加载-商品列表正常渲染 | 已登录买家 | yes | — |
| HOME-02 | 下拉刷新-列表内容刷新 | 首页已加载 | partial | DEE-38（后端待修） |
| HOME-03 | 触底加载更多 | 首页已加载 | partial | DEE-39（后端待修） |
| HOME-04 | 进入商品详情 | 首页已加载 | yes | — |
| HOME-05 | 商品图片轮播-左右滑动 | 详情页，多图 | yes | — |
| HOME-06 | 收藏商品-添加成功 | 详情页，未收藏 | yes | — |
| HOME-07 | 取消收藏-移除成功 | 详情页，已收藏 | yes | — |
| HOME-08 | 查看商品评价-跳转列表 | 详情页，有评价 | yes | — |
| HOME-09 | 评价列表加载-评分和内容 | 评价列表页 | yes | — |
| HOME-10 | 查看卖家主页 | 详情页 | yes | — |
| HOME-11 | 卖家主页商品列表 | 卖家主页，有商品 | yes | — |
| HOME-12 | 搜索入口-跳转搜索页 | 首页 | yes | — |
| HOME-13 | 搜索商品-显示匹配结果 | 搜索页 | yes | — |
| HOME-14 | 搜索无结果-空状态提示 | 搜索页 | yes | — |
| HOME-15 | 搜索历史-显示并可清除 | 有本地搜索历史 | yes | — |

**详细 steps / assertions**

- **HOME-01**：启动进首页 → wait_for 列表加载。断言：MasonryGrid 瀑布流卡片；文本「搜索服务」；顶部 AppBar 搜索栏
- **HOME-02**：下拉刷新手势 → wait RefreshIndicator。断言：文本「正在刷新推荐...」。blocker：DEE-38 刷新后列表无变化，后端需修复
- **HOME-03**：滚到底部（240px 内触发）→ wait 指示器消失。断言：文本「正在加载更多...」。blocker：DEE-39 滚动到底无响应，后端需修复
- **HOME-04**：点商品卡片 → wait 详情加载。断言：商品标题；图片（Hero tag product-image-{id}）；价格；描述；文本「已发布」
- **HOME-05**：图片区左滑 → 等动画。断言：ProductImagesCarousel；显示不同图片 URL
- **HOME-06**：点右上角收藏（heart_border）→ wait FavoritesBloc。断言：填充心形（琥珀色）；favoriteStatusMap[id]==true
- **HOME-07**：点已填充收藏 → wait。断言：空心心形；favoriteStatusMap[id]==false
- **HOME-08**：点「查看全部」/评价数 → wait。断言：product_reviews_page；AppBar「评论」；评价 ListView
- **HOME-09**：等加载。断言：用户昵称；5 颗星组件；评价内容；套餐名 skuName；评论时间
- **HOME-10**：点卖家信息区 → wait。断言：seller_public_profile_page；卖家昵称；粉丝数文本
- **HOME-11**：切到「我的服务」tab → wait。断言：TabBar 含「我的服务」；MasonryGridView；商品名+价格
- **HOME-12**：点 AppBar 搜索栏 → wait。断言：search_page；TextField autofocus；文本「热搜榜」「搜索历史」
- **HOME-13**：输入「设计」→ 点搜索/Enter → wait。断言：search_results_page；HomeFeedList 瀑布流；关键词在 AppBar title
- **HOME-14**：输入「zzzzzz」→ 搜索 → wait。断言：文本「没有找到相关的服务」；assert_not_exists 商品卡片
- **HOME-15**：观察历史区 → 点删除图标。断言：InputChip 历史关键词；每条有删除按钮；删除后 assert_not_exists 对应记录

---

### 2.3 ai_docs（AI 对话） — issue 211

| Case ID | 描述 | 前置 | 自动化 | issue状态 |
|---------|------|------|--------|-----------|
| AI-01 | AI 对话页加载-历史消息显示 | 已登录买家+≥1 历史会话 | yes | ✅ |
| AI-02 | 发送消息-显示在列表 | 已选/自动创建会话 | yes | ✅ |
| AI-03 | 接收 AI 回复-流式响应渲染 | 已发送消息 | partial | — |
| AI-04 | 请求商品推荐-底部弹推荐列表 | 会话有消息历史 | partial | — |
| AI-05 | 推荐卡片-图片/标题/价格 | AI-04 列表已加载 | partial | — |
| AI-06 | 点击推荐商品-触发分配进聊天 | AI-05 卡片可见，未分发 | partial | DEE-40（匹配度不足） |
| AI-07 | 会话侧边栏-切换历史会话 | ≥2 历史会话 | yes | ✅ |
| AI-08 | 限流提示-显示警告横幅 | 剩余次数 ≤ 5 | partial | DEE-41（计数从不更新） |
| AI-09 | 关闭限流提示-横幅可关闭 | AI-08 横幅已显示 | partial | — |

**详细 steps / assertions**

- **AI-01**：tap menu → 选既有会话 → 侧边栏关闭。断言：文本「欢迎使用AI助手」或历史气泡；左对齐 AI / 右对齐用户消息
- **AI-02**：输入「测试消息」→ tap send/「发送」→ 等更新。断言：用户气泡在底部（右对齐，文本=测试消息）；输入框清空
- **AI-03**：等流式开始 → 观察逐字渲染 → 等完成。断言：StreamingMessageBubble（左对齐逐字动画）；最终完整 AI 气泡。blocker：流式依赖后端，需真实 AI 或 mock 流；难验证逐字效果
- **AI-04**：tap「匹配」按钮 → 等加载。断言：ModalBottomSheet 打开；标题「推荐服务」；GridView 商品卡片。blocker：依赖 /get_related_services，需造数据或 mock
- **AI-05**：观察卡片。断言：商品图（AppNetworkImage）；标题（maxLines=1）；价格「￥XX.XX」。blocker：需推荐数据 + 网络
- **AI-06**：tap「让ta看看」→ 等 loading → 等分配完成。断言：先 loading spinner；完成后变「进入聊天」（绿色）+刷新图标；createdChatRoomId 非空。blocker：DEE-40，需真实后端分配或 mock，难验证分配正确性
- **AI-07**：tap menu → 侧边栏 → tap 非当前会话 → 自动关闭。断言：Drawer 打开；「新建聊天」按钮；ListTile（title=会话标题）；选中高亮 selectedTileColor；切换后消息列表更新
- **AI-08**：进页面加载 rate limit（FetchRateLimitStatus）→ 等横幅初始化。断言：RateLimitWarningBanner（margin=16）；文本含「今日剩余次数」或「使用次数即将耗尽」（≤2）；「还可使用 {remaining} 次，{resetTime}后重置」；关闭按钮可见。blocker：DEE-41 计数从不更新；需 mock remaining≤5，100 次触发无法测
- **AI-09**：tap 关闭按钮（Icons.close）。断言：横幅消失（SizedBox.shrink）；_isRateLimitWarningDismissed=true。blocker：需 remaining≤5 横幅才显示

---

### 2.4 Orders（订单） — issue 213

| Case ID | 描述 | 前置 | 自动化 | issue状态 |
|---------|------|------|--------|-----------|
| ORD-01 | 订单列表加载 | 买家+≥1 待付款订单 | yes | — |
| ORD-02 | 订单状态筛选 | 多状态订单 | partial | — |
| ORD-03 | 下拉刷新 | ≥3 条订单 | partial | DEE-44 |
| ORD-04 | 订单空状态 | 某 tab 无订单 | partial | — |
| ORD-05 | 查看订单详情 | ≥1 订单 | yes | — |
| ORD-06 | 确认收货-变可评价 | 待收货订单 | partial | — |
| ORD-07 | 取消订单-状态更新 | 待付款订单 | partial | DEE-45 |
| ORD-08 | 查看物流信息 | 待交付订单 | no | 作废（无物流场景） |
| ORD-09 | 联系卖家-跳转聊天页 | 订单有卖家信息 | partial | 跳转逻辑未实现 |
| ORD-10 | 发起订单评价-跳转评价页 | 待评价订单 | yes | — |
| ORD-11 | 提交评价-内容提交成功 | 评价页填写内容 | partial | — |
| ORD-12 | 上传评价图片 | 评价页+本地图片 | partial | — |
| ORD-13 | 申请平台介入 | 待收货订单 | no | 作废（前端无入口） |

**详细 steps / assertions**

- **ORD-01**：进我的订单 → wait 加载完成 → scroll。断言：「我的订单」title；OrderItemCard（卖家昵称/头像、图、名、总价）；状态标签；assert_not_exists SkeletonCard
- **ORD-02**：tap「待付款」tab(1) → wait → tap「待评价」tab(6)。断言：TabBar 8 个 Tab（全部/待付款/待提交/待接单/待交付/待收货/待评价/售后中）；列表仅对应状态；assert_not_exists 跨状态混合。blocker：需多状态订单数据
- **ORD-03**：待付款 tab → 下拉 → wait 重载。断言：RefreshIndicator enabled；重载无 SkeletonCard；触发 LoadOrders(forceRefresh=true)。blocker：DEE-44 订单<3 条无法触发刷新
- **ORD-04**：选无订单 tab（待接单）→ wait。断言：文本「暂无相关订单」；Card 空态；assert_not_exists OrderItemCard。blocker：需造某状态完全无订单
- **ORD-05**：tap 订单卡片 → wait → scroll。断言：「订单详情」title；OrderStatusTimelineHeader；OrderItemsSection；OrderInfoSection；OrderPriceDetailsSection
- **ORD-06**：进待收货详情 → scroll 底部 → tap「确认收货」→ 对话框「确定」→ wait。断言：底部「确认收货」按钮（isPrimary）；对话框标题「确认收货」+内容「您确定已经收到货品...」；成功 SnackBar 绿色；状态变「待评价」+按钮变「去评价」。blocker：需待收货订单 + 真实后端/mock
- **ORD-07**：待付款 tab → tap「取消订单」→「确定」→ wait。断言：按钮 enabled；对话框「取消订单」+「您确定要取消这个订单吗？」；状态变「已取消」；提示「订单已取消」绿色。blocker：DEE-45 取消后列表顺序混乱；需真实后端/mock
- **ORD-08**：进详情 → scroll → tap「查看交付/物流」。断言：物流按钮；物流弹框。blocker：无物流场景数据，用例作废
- **ORD-09**：进详情/卡片 → tap 卖家区/「联系卖家」。断言：卖家昵称/头像；跳转 /chat 路由。blocker：依赖 chat 模块，当前未实现跳转
- **ORD-10**：tap「去评价」→ wait。断言：按钮 enabled；「评价订单」title；OrderEvaluationPage 商品卡片；路由 /evaluation/{itemId}
- **ORD-11**：进评价页 → 输入文字 → tap「提交评价」→ wait。断言：按钮 enabled；OrderEvaluationForm；成功 SnackBar 绿色；自动返回订单列表（pop(true)）延迟 1 秒。blocker：需真实后端/mock，POST /api/shop/evaluate/add
- **ORD-12**：tap「添加图片(最多9张)」→ 选 1-9 张 → wait。断言：「添加图片」enabled；预览缩略图；「成功处理 {count} 张图片，平均压缩 {ratio}%」；超 9 张提示「最多只能上传9张图片」。blocker：需真实图片资源+文件系统，依赖 image_picker
- **ORD-13**：进详情 → 找「平台介入」入口。断言：assert_not_exists「平台介入」按钮。blocker：前端无入口（order_action_buttons.dart 105-106 注释），用例作废

---

### 2.5 Payment（支付） — issue 214

| Case ID | 描述 | 前置 | 自动化 | issue状态 |
|---------|------|------|--------|-----------|
| PAY-01 | 进入支付确认页-显示商品和金额 | 待支付商品参数已传入 | yes | — |
| PAY-02 | 订单金额计算-小计/合计正确 | 确认订单页 | yes | — |
| PAY-03 | 切换支付方式 | — | no | 🗑️ 作废（仅 Stripe） |
| PAY-04 | 余额不足提示 | 余额<订单金额 | no | ❓ 未接入余额 |
| PAY-05 | 微信支付流程 | 已装微信 | no | ❓ 未接入微信 |
| PAY-06 | 支付宝支付流程 | 已装支付宝 | no | ❓ 未接入支付宝 |
| PAY-07 | 支付成功-跳转结果页 | 完成 Stripe 支付 | partial | — |
| PAY-08 | 支付取消-返回确认页 | Stripe WebView 取消 | partial | — |
| PAY-09 | 支付失败-显示原因允许重试 | Stripe 支付错误 | no | ❓ 本次未测试 |
| PAY-10 | 结果页查看订单-跳转详情 | 支付成功，orderId 非空 | yes | — |
| PAY-11 | 结果页返回首页-跳转 | 结果页任意状态 | yes | ❌ DEE-43（已修复） |

**详细 steps / assertions**

- **PAY-01**：进 order_confirm_page → 等加载。断言：「确认订单」title；商品 Card 含名称；「数量:」+数值；PriceFormatter 格式化价格
- **PAY-02**：进确认页 → 查看摘要。断言：「订单摘要」；「商品金额」行；「数量」行；「订单总计」行；总计=金额×数量
- **PAY-03**：作废。blocker：当前仅 Stripe，UnifiedRegionConfig.supportedPaymentMethods 仅含 stripe
- **PAY-04**：未实现。blocker：未接入余额，无余额支付逻辑
- **PAY-05**：未实现。blocker：未接入微信
- **PAY-06**：未实现。blocker：未接入支付宝
- **PAY-07**：进确认页 → 点「确认支付」→ 关订单创建对话框 → 点「打开链接」完成 Stripe → 重定向 success_url → 等跳转 result_page。断言：「支付成功」；check_circle 图标；「订单 [orderId] 已支付完成」；「提示:订单状态可能需要几分钟更新...」；「查看订单详情」「返回订单列表」按钮。blocker：需真实 Stripe 或 webhook mock，success_url 需后端支持
- **PAY-08**：进确认页 → 确认支付 → 打开 Stripe WebView → 取消/返回（cancelUrlPattern）。断言：cancel_url 触发；跳 result_page（success=false，errorMessage="用户取消支付"）；「支付失败」。blocker：需真实 Stripe WebView 或 mock cancelUrl
- **PAY-09**：未测试。blocker：需实现 Stripe 失败处理和重试
- **PAY-10**：进 result_page（success）→ 点「查看订单详情」。断言：按钮 enabled；触发导航 orderDetail（popUntil 或 go /orderDetail/[orderId]）
- **PAY-11**：进 result_page → 点「返回订单列表」/AppBar 返回键。断言：「返回订单列表」按钮；触发 _exitPaymentFlow → context.go('/profile/orders')。状态：DEE-43 Back 逐层弹栈已通过 PopScope+_exitPaymentFlow 修复

---

### 2.6 favorites（收藏） — issue 216

| Case ID | 描述 | 前置 | 自动化 | issue状态 |
|---------|------|------|--------|-----------|
| FAV-01 | 收藏列表加载-商品 Tab | 买家+≥1 收藏服务 | yes | — |
| FAV-02 | 切换 Tab-卖家 Tab 加载 | ≥1 关注卖家 | yes | — |
| FAV-03 | 下拉刷新 | 服务 Tab 已显示 | yes | — |
| FAV-04 | 触底加载更多-分页 | >10 个收藏 | partial | 需造 10+ 条 |
| FAV-05 | 取消收藏商品-从列表移除 | 服务 Tab ≥1 收藏 | yes | — |
| FAV-06 | 取关卖家-从列表移除 | 卖家 Tab ≥1 关注 | yes | — |
| FAV-07 | 跳转商品详情 | 服务 Tab ≥1 收藏 | partial | 导航实现待确认 |
| FAV-08 | 空状态展示 | 无任何收藏 | yes | — |

**详细 steps / assertions**

- **FAV-01**：进收藏页自动加载 → 等完成。断言：「我的收藏」；Tab「服务」选中；Tab「卖家」；≥1 服务卡片（title+price）
- **FAV-02**：点「卖家」Tab → 等加载。断言：「卖家」选中；≥1 卖家卡片（nickName+头像）；「取消关注」按钮
- **FAV-03**：顶部下拉 → 等刷新。断言：RefreshIndicator；loading 显示后消失
- **FAV-04**：下滚至距底 100px → 等加载。断言：CircularProgressIndicator；itemCount 增加。blocker：需后端造 10+ 条收藏
- **FAV-05**：点红心（Icons.favorite）→ 等刷新。断言：卡片消失；全部移除后显示「暂无收藏的服务」
- **FAV-06**：点「取消关注」→ 等刷新。断言：卡片消失；全部移除后「暂无关注的卖家」
- **FAV-07**：点卡片（红心外区域）。断言：跳转服务详情页。blocker：onTap 回调为空，路由未明确定义，需确认导航
- **FAV-08**：进收藏页服务 Tab 观察空态。断言：Icons.favorite_border；「暂无收藏的服务」；「您可以在浏览服务时点击收藏按钮」；卖家 Tab 空态「暂无关注的卖家」+「您可以在浏览卖家时点击关注按钮」

---

### 2.7 after_sales（售后） — issue 217

| Case ID | 描述 | 前置 | 自动化 | issue状态 |
|---------|------|------|--------|-----------|
| AS-01 | 售后列表加载 | ≥1 已完成售后记录 | partial | 需造售后数据 |
| AS-02 | 申请售后入口-从订单详情跳转 | awaitingConfirmation/orderCompleted 订单 | partial | 需造订单数据 |
| AS-03 | 选择重做-跳转申请页 | 选择类型页已加载 | yes | — |
| AS-04 | 选择补充-跳转申请页 | 选择类型页已加载 | yes | — |
| AS-05 | 选择退款-跳转申请页（含金额输入） | 选择类型页已加载 | yes | — |
| AS-06 | 填写售后原因-信息完整 | 申请页 | yes | — |
| AS-07 | 上传凭证图片-上传成功 | 申请页填写必要字段 | yes | — |
| AS-08 | 提交售后申请-提交成功 | 必填字段已填写 | partial | 需后端处理 apply |
| AS-09 | 查看售后详情-完整信息展示 | 已提交申请 | partial | DEE-96（退款金额显示原价） |
| AS-10 | 售后状态跟踪-显示当前状态 | 详情页已加载 | partial | 需造多状态 |
| AS-11 | 撤销售后申请-撤销成功 | WAIT_AUDIT/AUDIT_PASS | partial | TODO 未实现 |
| AS-12 | 申请平台介入-填写原因提交 | audit_reject 状态 | partial | TODO 未实现 |

**详细 steps / assertions**

- **AS-01**：打开 After-Sales List → 等加载。断言：文本 'After-Sales List'；已完成售后记录列表；列表项含产品名/状态/申请时间。blocker：需造已完成订单+对应售后记录
- **AS-02**：打开订单详情 → scroll 找售后入口 → 点击。断言：跳「Select After-Sales Type」；订单商品信息（图/名/SKU/价）。blocker：需 awaitingConfirmation/orderCompleted 订单
- **AS-03**：点「I want a remake」卡片。断言：跳 AfterSalesApplyPage；AppBar「Apply for Remake」；订单商品卡片
- **AS-04**：点「I want a supplement」卡片。断言：跳申请页；AppBar「Apply for Supplement」；订单商品卡片
- **AS-05**：点「I want a refund」卡片。断言：跳申请页；AppBar「Apply for Refund」；退款金额输入框（提示「Maximum refund {symbol}{amount}」）
- **AS-06**：点 Reason 下拉 → 选原因 → 输入 Description →（REFUND 则输金额）。断言：下拉选中值更新；Description 显示文本；表单验证通过
- **AS-07**：点上传按钮（80x80，add_a_photo_outlined）→ 选 1 张 → 等处理。断言：80x80 缩略图；右上角 remove_circle 删除按钮；SnackBar「Successfully processed {count} images, avg compression {ratio}%」
- **AS-08**：scroll 底部 → 点「Submit Application」→ 等完成。断言：触发 ApplyForAfterSalesSubmitted；成功后跳详情/列表；成功 SnackBar 或列表刷新。blocker：需后端处理 POST /api/shop/order-refund/apply，mock 可初测
- **AS-09**：从列表点售后记录 → 等加载。断言：AppBar「After-sales Details」；状态卡片；产品信息卡片；售后信息卡片（申请号/时间/退款金额/原因/描述）；退款金额走 RegionConfig.formatPrice 显示申请填写金额。blocker：DEE-96 退款金额显示原价缺陷待修；需后端返回完整数据
- **AS-10**：观察状态卡片标题/副标题。断言：按 refundState 显示 — wait_audit→Pending Review；audit_pass→Approved；audit_reject→After-Sales Application Rejected；refund_success→Refund Successful；canceled→canceled；及对应图标/颜色。blocker：需造多种状态数据，mock 可初测
- **AS-11**：scroll 底部 → 点「Revoke Application」。断言：触发 CancelAfterSalesRequested；WAIT_AUDIT/AUDIT_PASS 时显示此按钮；撤销后状态变 canceled。blocker：cancel 接口为 TODO，未完全实现
- **AS-12**：scroll 底部 → 点「Platform Intervention」→ 填原因。断言：触发 ApplyMediationRequested；非 WAIT_AUDIT 状态显示此按钮；提交后 UI 更新。blocker：平台介入接口为 TODO，未完全实现

---

### 2.8 seller（卖家） — issue 218

| Case ID | 描述 | 前置 | 自动化 | issue状态 |
|---------|------|------|--------|-----------|
| SELL-01 | 卖家数据主页加载-数据概览 | 已登录卖家 | partial | ❌ DEE-73 |
| SELL-02 | 下拉刷新主页数据 | 主页已加载 | partial | ❌ 阻塞（依赖 SELL-01） |
| SELL-03 | 切换为买家模式 | 已登录卖家 | yes | ✅ |
| SELL-04 | 商品管理列表-在售商品 | ≥1 在售商品 | partial | ✅ |
| SELL-05 | 新建商品-表单填写发布 | 无待发布/草稿 | partial | ❌ DEE-74、DEE-75 |
| SELL-06 | 编辑商品-修改保存 | ≥1 在售商品 | partial | ⚠️ 案例展示需重传图片 |
| SELL-07 | 卖家订单列表-按状态筛选 | 多状态订单 | partial | ✅ 但徽章不一致 DEE-80 |
| SELL-09 | 统计数据-周收入图表 | 有周收入数据 | partial | ⚠️ |
| SELL-10 | 自动回复设置-配置保存 | 已登录卖家 | partial | ❌ DEE-81 |
| SELL-11 | 时间管理-设置在线时间段 | 已登录卖家 | partial | ❌ DEE-82 |
| SELL-12 | 卖家认证申请-提交认证 | 已登录卖家 | partial | ✅ |
| SELL-13 | 售后审核-审核买家申请 | 有待审核申请 | partial | ⚠️ |
| SELL-14 | 商品上架-下架商品重新上架 | ≥1 已下架商品 | partial | ✅ 但已下架列表未刷新 DEE-77 |
| SELL-15 | 商品下架-在售下架后买家不可见 | ≥1 在售商品 | partial | ✅ 但搜索仍可见 DEE-76 |
| SELL-16 | 商品删除-删除后移除不可恢复 | ≥1 已下架/草稿商品 | partial | ❌ DEE-79 |
| SELL-17 | 已下架商品无编辑入口 | ≥1 已下架商品 | partial | ⚠️ 待开发 DEE-78 |

> SELL-08 在 JSON 中缺位（编号跳号）。

**详细 steps / assertions**

- **SELL-01**：进 seller_home_page → 等加载。断言：「收入」「订单」「功能」文本；收入卡片（总收入/今日收入/待结算）；订单卡片（全部/待处理/已完成/已取消+数字）。blocker：DEE-73 概览可能无数据，需后端造数据
- **SELL-02**：顶部下拉刷新 → 等完成。断言：RefreshIndicator 触发；数据重载。blocker：依赖 SELL-01 修复
- **SELL-03**：进主页 → tap「切换到买家模式」。断言：文本存在；跳买家首页；AppMode=buyer
- **SELL-04**：进商品管理 →「在售」tab。断言：Tab「在售」；status=normal 卡片；每卡片名/价/销量/状态标签。blocker：需造 ≥1 在售商品
- **SELL-05**：tap FAB → 填名/描述/档位价/上传图 → 点「发布」。断言：FAB 存在；跳 ProductEditPage(create)；表单含 名/描述/Basic-Standard-Premium 档位/图上传；发布后成功提示+返回；新商品在在售列表。blocker：DEE-74 属性添加报错、DEE-75 案例展示未保存
- **SELL-06**：「在售」tab → tap「编辑」→ 改名/价 → 点「发布」。断言：编辑按钮 enabled（draft/已下架除外）；跳 ProductEditPage(edit)；成功提示；列表更新。blocker：DEE-75 案例展示需重传图片
- **SELL-07**：进订单列表 → tap 不同状态筛选。断言：支持状态筛选；切换显示对应订单；筛选按钮可交互。blocker：DEE-80 主页徽章数与列表不一致
- **SELL-09**：进统计页/主页统计卡片 → 观察周收入图。断言：「最近收入」或柱状图；7 天数据；x 轴 MM/dd 标签。blocker：需后端造周收入数据
- **SELL-10**：主页功能列表 → tap「自动回复」→ 跳 auto_reply_page → 配置保存。断言：功能网格含「自动回复」；跳 SellerRoutes.autoReply；有配置表单+保存按钮。blocker：DEE-81
- **SELL-11**：功能列表 → tap「时间管理」→ 跳 time_management_page。断言：网格含「时间管理」；跳 SellerRoutes.timeManagement。blocker：DEE-82
- **SELL-12**：进 auth_application_page → 填表单 → 提交。断言：页面可加载；必填字段验证；提交成功提示。blocker：需造测试账号+认证数据
- **SELL-13**：进 after_sales_review_page → 找 waitAudit 申请 → tap「同意」/「拒绝」。断言：待审核列表；卡片（订单号/类型/时间/退款金额）；显示「同意」「拒绝」；审核后状态更新。blocker：需造待审核申请
- **SELL-14**：「已下架」tab → tap「上架」。断言：tab 显示下架商品；「上架」按钮 enabled；点击后 status=normal；移到「在售」tab。blocker：DEE-77 已下架列表未刷新
- **SELL-15**：「在售」tab → tap「下架」→「确认下架」。断言：下架确认对话框；status=disabled；从在售移出到已下架；首页搜索不显示（需买家端验证）。blocker：DEE-76 搜索仍可见
- **SELL-16**：「已下架」/「草稿」tab → tap「删除」→ 确认。断言：删除确认对话框；调 DeleteProduct event；从列表移除。blocker：DEE-79
- **SELL-17**：「已下架」tab → 观察操作按钮。断言：只显示「上架」「删除」；「编辑」不显示（disabled/not_exists）。blocker：DEE-78 功能待开发

---

### 2.9 Wallet（钱包） — issue 344（WAL）

| Case ID | 描述 | 前置 | 自动化 | issue状态 |
|---------|------|------|--------|-----------|
| WAL-01 | 钱包页加载-余额/待结算/累计收入 | 卖家+钱包已加载 | yes | — |
| WAL-02 | 余额=0-提款按钮禁用 | bound=true+余额=0 | partial | 需造余额=0 数据 |
| WAL-03 | 余额>0-提款按钮可点弹对话框 | bound=true+余额>0 | partial | 需造余额>0 数据 |
| WAL-04 | 刷新按钮-重拉余额与交易 | 钱包页已加载 | yes | — |
| WAL-05 | 加载失败-错误信息+重试 | 网络不可用/后端错误 | partial | 需模拟网络错误 |
| WAL-06 | 交易记录列表加载 | 有交易记录 | partial | 需造交易记录 |
| WAL-07 | 筛选-全部/收入/支出 | 多种交易类型 | partial | 需造多类型 |
| WAL-08 | 日期范围筛选 | 钱包页已加载 | partial | 需造跨日期记录 |
| WAL-09 | 清除筛选-恢复全部 | 已设过滤条件 | partial | 需造足够记录 |
| WAL-10 | 触底加载更多 | 记录≥pageSize | partial | 需造大量流水 |
| WAL-11 | 无记录空态 | 无任何交易记录 | partial | 需造空账号 |
| WAL-12 | 点击交易记录-底部弹详情 | 有交易记录 | partial | 需造交易记录 |
| WAL-13 | 交易状态展示-completed/pending/failed | 多状态交易 | partial | 需造多状态 |
| WAL-14 | 提款弹窗-显示可用余额 | bound+余额>0 | partial | 需造余额>0 |
| WAL-15 | 提款金额为空/非数字-提示 | 提款弹窗已打开 | partial | 需造余额>0 |
| WAL-16 | 提款金额超余额-提示 | 提款弹窗已打开 | partial | 需造余额数据 |
| WAL-17 | 提款成功-Toast+余额刷新 | 输入有效金额 | no | 需真实支付接口 |
| WAL-18 | 提款失败-未绑定账户-跳收款页 | bound=false | partial | 需造 bound=false |
| WAL-19 | 提款失败-其他错误-显示信息 | 后端业务错误 | partial | 需造特定业务错误 |

**详细 steps / assertions**

- **WAL-01**：进 /profile/wallet → 等加载 → 看顶部卡片。断言：「账户余额」「待结算金额」「总收入」；金额数字（如 $100.00）
- **WAL-02**：进钱包页 → 检查提现按钮。断言：「提现」文本；按钮 enabled=false。blocker：需造余额=0 卖家
- **WAL-03**：进钱包页 → 点提现。断言：按钮 enabled=true；对话框「提现」；「可提现余额:」；输入框 labelText 含「提现金额」。blocker：需造余额>0 卖家
- **WAL-04**：进钱包页 → 等加载 → 点右上角刷新。断言：刷新按钮可点；出现加载指示器或列表刷新
- **WAL-05**：网络离线进钱包页。断言：错误文本（profile_wallet_occurred_error）；「重试」按钮。blocker：需模拟网络错误
- **WAL-06**：进钱包页 → 等列表加载 → 看交易项。断言：金额（带货币符）；交易描述；日期（yyyy-MM-dd HH:mm）；状态图标+文本（已完成/处理中/失败）。blocker：需造交易记录
- **WAL-07**：选「收入」→ 等更新 →「支出」→「全部」。断言：选项「全部」「收入」「支出」；切换后列表重载。blocker：需造多类型交易
- **WAL-08**：点 date_range → 选起止日期 → 确认。断言：日期选择器弹出；日期范围文本（yyyy/MM/dd - yyyy/MM/dd）；列表按范围更新。blocker：需造跨日期记录
- **WAL-09**：设过滤条件 → 点 clear。断言：清除按钮仅活跃过滤时显示；点击后重置显示全部。blocker：需造足够记录
- **WAL-10**：等列表加载 → 滚到底部。断言：出现加载指示器/新数据；列表继续增长。blocker：需造 pageSize 倍数以上记录
- **WAL-11**：进钱包页 → 等加载列表为空。断言：receipt_long 空态图标；「暂无交易记录」。blocker：需造无交易记录账号
- **WAL-12**：点任意交易项。断言：ModalBottomSheet「交易详情」；交易ID 行；类型行（收入/支出）；金额行；日期行；状态行。blocker：需造交易记录
- **WAL-13**：观察各交易项状态。断言：已完成「✓」绿色；处理中「⏱」橙色；失败「✕」红色。blocker：需造多状态交易
- **WAL-14**：点提现按钮。断言：对话框 title「提现」；「可提现余额: $XXX.XX」；TextField labelText 含「提现金额」。blocker：需造余额>0
- **WAL-15**：开弹窗 → 不填/输非数字 → 点「确认提现」。断言：SnackBar「请输入有效的提现金额」。blocker：需造余额>0
- **WAL-16**：开弹窗 → 输超额（余额$100 输$200）→ 确认。断言：SnackBar「提现金额不能超过可用余额」。blocker：需造具体余额
- **WAL-17**：开弹窗 → 输有效金额 → 确认。断言：弹窗关闭；SnackBar「提现申请已提交，请耐心等待处理」绿色；余额刷新减少。blocker：需真实支付接口+余额>0 账号
- **WAL-18**：进钱包页 → 余额>0 观察提现按钮。断言：未绑定时按钮消失，显示「提现前需先绑定收款账户」；「绑定收款账户」按钮。blocker：需造 bound=false 卖家
- **WAL-19**：开弹窗 → 输有效金额提交（后端返回错误）。断言：SnackBar「提现失败：<具体错误>」。blocker：需造特定业务错误场景

---

### 2.10 Connect（收款绑定） — issue 344（CON）

| Case ID | 描述 | 前置 | 自动化 | issue状态 |
|---------|------|------|--------|-----------|
| CON-01 | 未绑定状态-显示引导页+开始绑定 | Stripe 未绑定 | yes | — |
| CON-02 | 点击开始绑定-打开 Onboarding WebView | CON-01 未绑定状态 | no | 需真实 Stripe/mock |
| CON-03 | WebView 加载-白名单域名正常 | onboardingUrl 白名单 | partial | 需真实链接/mock |
| CON-04 | Onboarding 完成-检测 return URL | 完成 Onboarding | no | 需真实完成流程 |
| CON-05 | Onboarding 链接过期-检测 refresh | 链接已过期 | no | 需过期场景/mock |
| CON-06 | 手动关闭 WebView-状态不变 | 已进入 WebView | partial | 需进入 WebView 环境 |
| CON-07 | 审核中状态-显示审核中+刷新状态 | PendingVerification | partial | 需造该状态账号 |
| CON-08 | 刷新状态按钮-重拉账户状态 | CON-07 审核中 | partial | 需造该状态账号 |
| CON-09 | 已激活状态-chargesEnabled/payoutsEnabled | ConnectAccountActive | partial | 需造已激活账号 |
| CON-10 | 错误状态-错误信息+重试 | ConnectAccountError | partial | 需模拟网络错误 |
| CON-11 | 非白名单域名-WebView 阻止跳转 | WebView 内跳非白名单 | partial | WebView 内部测试 |
| CON-12 | 非 HTTPS 请求-WebView 阻止 | WebView 内 HTTP 跳转 | partial | WebView 内部测试 |

**详细 steps / assertions**

- **CON-01**：进 /seller/connect-account → 等加载。断言：AppBar「收款账户」；account_balance_outlined 图标；标题「绑定收款账户」；说明「绑定银行账号，通常只需 1-2 分钟...」；「开始绑定」按钮
- **CON-02**：点「开始绑定」。断言：切换 loading（CircularProgressIndicator）；成功进 StripeConnectEmbeddedPage/WebViewPage（按 clientSecret/onboardingUrl）。blocker：需真实 Stripe API 或 mock
- **CON-03**：进 WebView → 等加载。断言：WebView 正常加载无错误；AppBar「账户认证」；左侧 close 按钮。blocker：需真实链接或 mock WebView
- **CON-04**：完成 Onboarding 流程。断言：检测 return URL（含 stripe/connect/return）；自动关闭返回上页；触发 RefreshConnectAccountStatus。blocker：需真实完成流程
- **CON-05**：链接过期等待。断言：检测 refresh URL（含 stripe/connect/refresh）；关闭返回 ConnectWebViewResult.refresh；调 FetchOnboardingLink 重获链接。blocker：需过期场景/mock
- **CON-06**：点 AppBar close。断言：返回 ConnectWebViewResult.cancelled；回 ConnectAccountPage 状态不变不刷新。blocker：需进入 WebView 环境
- **CON-07**：进收款页（审核中）。断言：hourglass_top_rounded 图标（warning 背景）；标题「银行账号已绑定」；说明「...首次提现时需完成身份验证...」；「刷新状态」按钮。blocker：需造 PendingVerification 账号
- **CON-08**：点「刷新状态」。断言：可点；发起 RefreshConnectAccountStatus。blocker：需造 PendingVerification 账号
- **CON-09**：进收款页（已激活）。断言：check_circle_outline（success 背景）；标题「收款账户已激活」；「收款功能」行（✓/✕ 按 chargesEnabled）；「提款功能」行（✓/✕ 按 payoutsEnabled）。blocker：需造 ConnectAccountActive 账号
- **CON-10**：网络离线/后端错误进收款页。断言：error_outline 图标；错误信息文本；「重试」按钮。blocker：需模拟网络错误
- **CON-11**：WebView 内跳 evil.com。断言：拦截跳转，不加载非白名单。blocker：需 WebView 内部执行
- **CON-12**：WebView 内跳 http://stripe.com。断言：拦截非 HTTPS。blocker：需 WebView 内部执行

---

## 3. 覆盖缺口报告（最重要）

### 3.1 issue 里标 ⚠️待测/❓未验证 的 case（真空白，必须补测）

| Case ID | 模块 | 状态 | 缺口性质 |
|---------|------|------|----------|
| AUTH-05 | auth | ⚠️ 待测试 | 无效邮箱格式校验从未实测 |
| AUTH-08 | auth | ⚠️ 部分验证 | 验证码过期场景未完整验证 |
| AUTH-11 | auth | ❓ 暂未验证 | token 过期自动跳转登录页从未验证 |
| AUTH-12 | auth | ⚠️ 待测试 | 协议/隐私链接 onPressed 为 TODO，功能未实现 |
| PAY-04 | payment | ❓ | 余额支付未接入，无逻辑 |
| PAY-05 | payment | ❓ | 微信支付未接入 |
| PAY-06 | payment | ❓ | 支付宝支付未接入 |
| PAY-09 | payment | ❓ | Stripe 支付失败/重试本次未测试 |
| SELL-09 | seller | ⚠️ | 周收入图表待验证 |
| SELL-13 | seller | ⚠️ | 售后审核待验证 |
| SELL-17 | seller | ⚠️ | 已下架无编辑入口待开发（DEE-78） |

> 关键真空白：**AUTH-11（token 过期）** 和 **AUTH-12（协议链接）** 是登录基建的安全/合规缺口；AUTH-12 代码层面就是 TODO，属于「功能未实现」而非「未测试」，应优先排期。PAY-04/05/06 属产品决策性放弃（仅 Stripe），非缺陷。

### 3.2 automatable=no / partial 的 blocker 归类

**完全无法自动化（no，14 条）**

| 分类 | Cases | 说明 |
|------|-------|------|
| 已作废（产品决策/功能删除） | AUTH-02、PAY-03、ORD-08、ORD-13 | 国际号码后端不支持、仅 Stripe、无物流场景、前端无平台介入入口 |
| 功能未接入/未实现 | PAY-04/05/06/09、AUTH-12 | 余额/微信/支付宝未接入、Stripe 失败处理未实现、协议链接 TODO |
| 外部依赖-Stripe 真实流程 | CON-02、CON-04、CON-05 | 创建账户、Onboarding 完成、链接过期均需真实 Stripe |
| 外部依赖-真实支付/token | WAL-17、AUTH-11 | 真实提现接口、真实 token 过期 |

**半自动（partial，70 条）blocker 三大类**

| Blocker 类型 | 占比主体 | 代表 Cases |
|--------------|----------|-----------|
| **卡在数据 fixture**（最多） | Wallet 大部分、Orders 多状态、Seller 大部分、AS 多状态 | WAL-02/03/06~16/18/19、ORD-02/04/06/07、SELL-01/04~16、AS-01/02/08~12、FAV-04 |
| **卡在外部依赖**（Stripe/支付/AI/短信） | Payment、AI、Connect WebView | PAY-07/08、AI-03/04/05/06/08/09、CON-03/06、AUTH-08 |
| **卡在功能未实现/缺陷** | 后端待修 + 前端 TODO | HOME-02/03（DEE-38/39 后端）、ORD-09（聊天跳转未实现）、AS-11/12（cancel/介入 TODO）、FAV-07（路由未定义） |

> **结论**：partial 用例中绝大多数（约 50+ 条）卡点是「数据 fixture 未造」，**只要把 §1 的 fixtures 造齐，这批 partial 多数可转为 yes**。真正卡死在外部依赖（Stripe 真实流、AI 流式、真实短信/支付）的约 15 条，必须人工或 mock 服务介入。

### 3.3 模块 case 偏少/可能漏测

| 模块 | 用例数 | 风险评估 |
|------|--------|----------|
| **ai_docs** | 9 | 偏少。缺：新建会话流程、删除会话、消息发送失败/重试、空会话态、输入框为空提交校验。流式与推荐高度依赖后端，UI 之外覆盖薄 |
| **favorites** | 8 | 中等。缺：从商品详情页收藏后同步到收藏列表的端到端、卖家主页关注后同步、收藏排序 |
| **payment** | 11 但 6 条作废/未实现 | 实际有效仅 5 条（PAY-01/02/07/08/10/11）。Stripe 失败/退款/重试链路几乎零覆盖，是高风险区 |
| **after_sales** | 12 | 撤销（AS-11）、平台介入（AS-12）均 TODO，售后闭环后半段无真实覆盖 |
| **auth** | 12 | 数量够，但 token 过期、协议跳转、邮箱全链路三处实测空白 |
| Wallet/Connect | 31 | 数量充足，但 22 条卡 fixture，实测绿的极少（仅 WAL-01/04、CON-01） |

---

## 4. 执行建议

### 4.1 第一批：现在就能纯自动跑（automatable=yes 且 fixture 本地已有，约 30 条）

无需造数据，登录基建 + 现有 seed 即可跑绿：

- **auth**：AUTH-01、AUTH-04、AUTH-05、AUTH-06、AUTH-07（共 5，仅需未登录态）
- **Home**：HOME-01、04、05、08、09、10、11、12、13、14（共 10，需已发布商品 seed，本地已有）
- **ai_docs**：AI-01、AI-02、AI-07（需 ≥1~2 历史会话，建议先造 1 次即长期可用）
- **Orders**：ORD-05、ORD-10（需 ≥1 订单/待评价订单——若 seed 无则归第二批）
- **Payment**：PAY-01、PAY-02、PAY-10、PAY-11（需支付参数/result_page 入口）
- **favorites**：FAV-01、02、03、05、06、08（需收藏/关注 seed——若无归第二批）
- **Wallet/Connect**：WAL-01、WAL-04、CON-01（钱包加载/刷新/未绑定引导页）

> 起步最稳的是 auth(5) + Home(10) + ai_docs(3) = **18 条**，这批仅依赖登录基建和商品 seed，可立即编排成第一条 mobai 自动化回归链。

### 4.2 第二批：先造 fixture，再纯自动跑（automatable=yes/partial 但缺数据）

用 mysql CLI / 后端造数据后即可转自动。**按 ROI 排序，优先造一次能解锁最多 case 的 fixture：**

1. **造多状态订单**（待付款≥3、待收货、待评价、某 tab 为空）→ 解锁 ORD-01/02/03/04/06/07/10，SELL-07
2. **造收藏/关注关系（含 10+ 条）** → 解锁 FAV-01/02/04/05/06/08，HOME-06/07
3. **造卖家商品（在售/已下架/草稿各 ≥1）+ 周收入** → 解锁 SELL-04/06/09/14/15/16/17
4. **造钱包交易流水（多类型/多状态/跨日期/≥pageSize/空账号各一套）** → 解锁 WAL-06~16
5. **造余额>0 / 余额=0 / bound=false 卖家** → 解锁 WAL-02/03/14/15/16/18
6. **造售后申请（多 refundState + 已完成订单关联）** → 解锁 AS-01/02/09/10、SELL-13

### 4.3 第三批：只能半自动/人工/mock（外部依赖，约 15 条）

无法纯本地造，需真实服务、mock server 或人工：

- **Stripe 真实流程**：PAY-07/08、CON-02/03/04/05/06、WAL-17 → 需真实 Stripe 测试账户或 mock webhook/WebView；建议人工 + 截图存证
- **AI 流式/推荐/限流**：AI-03/04/05/06/08/09 → 需真实 AI 服务或 mock 流；rate limit 需造数据绕过 100 次真实触发
- **真实邮箱/短信/时间**：AUTH-03（邮箱码进垃圾箱）、AUTH-08/09（验证码过期/60 秒倒计时）→ 人工或时间伪造
- **真实 token 过期**：AUTH-11 → 后端造过期 token 或人工
- **WebView 安全策略**：CON-11/12（非白名单/非 HTTPS 拦截）→ WebView 内部脚本注入测试

### 4.4 不纳入本轮执行（作废/未实现，应回归产品/开发）

- 作废：AUTH-02、PAY-03、ORD-08、ORD-13
- 功能未实现待开发：PAY-04/05/06/09、AUTH-12、ORD-09、AS-11、AS-12、SELL-17
- 后端缺陷待修后再测：HOME-02/03（DEE-38/39）、SELL-01/02/05/10/11/16（DEE-73/74/75/79/81/82）、AS-09（DEE-96）、ORD-07（DEE-45）、SELL-14/15（DEE-76/77）、SELL-07（DEE-80）

> 这批共约 30 条带 DEE 编号缺陷或 TODO，应作为「测试就绪度看板」回推给开发——**测试集要跑全绿，前提是这些 DEE 缺陷先修复**。建议将 §4.4 列为前端/后端联合排期的阻塞清单。

---

**文档关键结论**：127 条中真正「开箱即跑」约 18-30 条；70 条 partial 的最大杠杆是 §1 的数据 fixtures（造齐后 50+ 条可转 yes）；剩余约 15 条死锁在 Stripe/AI/短信等外部依赖只能半自动；另有约 30 条带 DEE 缺陷或 TODO 必须等开发修复才能验证。
---

## 补充模块（后续单独提取，11 模块齐）

### 2.10 chat（买家聊天） — issue 212

**相关页面**：`chat_list_page.dart`、`chat_room_page_refactored.dart`、`file_preview_page.dart`

| Case ID | 描述 | issue状态 | 前置态 | 自动化 | blocker |
|---|---|---|---|---|---|
| CHAT-01 | 聊天列表加载 — 显示所有会话 | ✅ | 已登录买家+≥1会话 | yes | |
| CHAT-02 | 进入聊天室 — 加载历史消息 | ✅ | 已登录买家+≥1会话 | yes | |
| CHAT-03 | 发送文字消息 | ✅ | 已登录买家+≥1会话 | yes | 需对端 |
| CHAT-04 | 发送图片 | ✅ | 已登录买家+≥1会话 | partial | 需造图片+后端上传 |
| CHAT-04b | 发送文件 | ✅ | 已登录买家+≥1会话 | partial | 需造文件+后端上传/下载 |
| CHAT-05 | 接收消息(实时) | ⚠️ | +对端发消息 | no | WebSocket+真实对端 |
| CHAT-06 | 文件预览跳转 | ✅ | +文件消息会话 | yes | |
| CHAT-07 | 消息时间分组 | ✅ | +≥3条不同时间消息 | yes | |
| CHAT-08 | 未读角标 | ❌DEE-72 | +收到自动回复后退出 | partial | 缺陷未读未清零+需对端 |

> 关键断言锚点：AppBar「聊天列表」(chat_list_title)、空态「暂无聊天记录」、消息气泡 isMe 左右对齐、时间分组「昨天/星期X/MM/dd」、未读角标(DEE-72 已知 bug)。详细 steps/assertions 见 workflow 原始输出。

### 2.11 profile（个人中心） — issue 215

**相关页面**：`profile_page.dart`、`account_security_page.dart`、`language_settings_page.dart`、`assistant_mission_page.dart`、`notification_list_page.dart`

| Case ID | 描述 | issue状态 | 前置态 | 自动化 | blocker |
|---|---|---|---|---|---|
| PROF-01 | 资料页加载(头像/昵称/订单概览) | ⚠️ | 已登录买家 | yes | |
| PROF-02 | 下拉刷新 | ⚠️ | 已登录买家 | yes | |
| PROF-03 | 未登录登录引导 | ⚠️ | 未登录 | yes | |
| PROF-04 | 跳转收藏 | ⚠️ | 已登录买家 | yes | |
| PROF-05 | 跳转钱包 | ⚠️ | 已登录买家 | partial | 详见 #344 WAL/CON |
| PROF-06 | 账户安全页加载 | ⚠️ | 已登录买家 | yes | |
| PROF-07 | 语言设置切换 | ⚠️ | 已登录买家 | yes | |
| PROF-08 | 通知列表加载 | ⚠️ | 已登录买家 | partial | 需通知数据 |
| PROF-09 | 助手任务页加载 | ⚠️ | 已登录买家 | yes | |

> 关键断言锚点：AppBar「个人中心」(profile_personal_center)、未登录「请登录查看个人资料」+「登录」按钮、菜单项「收藏/钱包/账户安全/语言设置/消息通知/小帮手的使命」均跳对应 route、语言设置 5 个 radio(简中/English/日本語/한국어/Tiếng Việt)。详细见 workflow 原始输出。

---

## 修订统计（11 模块齐）

| | |
|---|---|
| 模块数 | 11（209/210/211/212/213/214/215/216/217/218/344）|
| 总用例 | 144（127 + 聊天8 + 个人中心9）|
| 第一批可跑(yes+本地fixture) | ~25-35 |
