# TestFlight staging E2E 验收记录

- 验证日期：2026-07-12
- 构建：1.0.0 (202607121)
- 环境：`.env.staging`
- 后端：`https://dskk-api-staging.zeabur.app`
- 设备：iOS Simulator `DSKK-QA-iPhone17`
- 测试账号：项目 staging 测试账号（手机号已在截图中脱敏）

## 已验证链路

- 手机号登录与远程鉴权
- 买家：首页、消息、个人中心
- 买家/卖家模式切换
- 卖家个人中心、卖家数据统计
- 卖家消息列表、通知中心
- 会话详情、会话内商品详情
- 统计接口返回 `weeklyIncome` 数据

## 结果

核心业务链路通过。Flutter 日志中的业务请求均指向 Zeabur staging，未发现登录完成后的业务请求回落到 localhost。

登录页首次加载时，匿名 PV 埋点 `/api/project/dau/add` 有部分并发请求超过 10 秒；后续埋点请求成功，且不影响登录和核心页面链路。这属于待优化的埋点性能问题，不阻断本次 TestFlight staging 验收。

## 截图

1. [买家首页](01-home-buyer.png)
2. [买家首页 Tab](02-buyer-home.png)
3. [消息页](03-messages.png)
4. [买家个人中心](04-profile.png)
5. [卖家个人中心](05-seller-home.png)
6. [卖家数据](06-seller-statistics.png)
7. [卖家消息](07-seller-messages.png)
8. [通知中心](08-notifications.png)
9. [会话详情](09-chat-detail.png)
10. [商品详情](10-product-detail.png)
11. [卖家数据主题色修复后](11-seller-statistics-blue.png)
12. [卖家数据玻璃/磨砂效果](12-seller-statistics-glass.png)

## Issue #415 验收截图

- [买家个人中心统一卡片](../e2e/buyer-profile-glass.png)
- [卖家个人中心统一卡片](../e2e/seller-profile-glass.png)
- [卖家中心 Shimmer 骨架屏](../e2e/seller-home-skeleton.png)

## 全局卡片统一回归截图

- [买家首页商品卡](../e2e/global-card-home-20260713.png)
- [买家个人中心卡片](../e2e/global-card-profile-20260713.png)
- [卖家中心统一卡片](../e2e/global-card-seller-20260713.png)
