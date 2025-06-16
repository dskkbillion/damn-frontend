# 订单模块当前实现任务清单

> 📅 创建时间：2024年12月19日
> 🎯 目标：完善订单管理模块的核心缺失功能
> 📋 基于后端API重新分析结果制定

## 🚨 高优先级修复任务

### 1. 邀请评价功能修复
**状态：** ❌ 前端实现有误，后端已完整实现  
**API端点：** `POST /api/shop/evaluate/invite`  
**问题：** 前端标记为未实现，实际后端功能完整  

**任务详情：**
- [ ] 修复 `inviteEvaluation` 方法实现
- [ ] 添加重复邀请检查的错误处理
- [ ] 在卖家订单详情页添加邀请评价按钮
- [ ] 实现邀请成功的反馈提示
- [ ] 添加"今日已邀请"状态显示
- [ ] 添加邀请次数限制逻辑（最多3次）
- [ ] 实现邀请状态的本地缓存

**相关文件：**
- `lib/features/orders/data/datasources/order_remote_data_source_impl.dart`
- `lib/features/orders/presentation/seller/widgets/seller_order_item_card_action_buttons.dart`
- `lib/features/orders/presentation/widgets/order_action_buttons.dart`
- `lib/features/orders/domain/usecases/invite_evaluation_usecase.dart` (新建)

### 2. 平台介入功能正确实现
**状态：** ⚠️ 理解有误，需要重新实现  
**API端点：** `POST /api/project/orderDemand/add` (type="platform")  
**设计思路：** 不改变订单状态，设置平台标记，发送到管理后台处理  

**任务详情：**
- [ ] 创建平台介入申请页面
- [ ] 实现平台标记显示逻辑 (buyerPlatformFlag/sellerPlatformFlag)
- [ ] 添加"申请平台介入"按钮（适当状态下）
- [ ] 实现"等待平台处理"状态显示
- [ ] 添加平台介入申请历史查看
- [ ] 实现介入申请的理由分类和表单验证
- [ ] 添加申请限制逻辑（最多2次）

**相关文件：**
- `lib/features/orders/presentation/pages/platform_intervention_apply_page.dart` (新建)
- `lib/features/orders/presentation/widgets/platform_intervention_status_widget.dart` (新建)
- `lib/features/orders/domain/entities/order.dart` (添加平台标记字段)
- `lib/features/orders/domain/usecases/platform_intervention_usecase.dart` (新建)

## 🔥 高优先级新功能

### 3. 买家申请补充材料功能
**状态：** ❌ 未实现，后端API完整  
**API端点：** `POST /api/project/orderDemand/add`  
**类型：** replenishment（补充），reform（重做）  

**任务详情：**
- [ ] 创建订单需求状态枚举 (`OrderDemandStatus`)
- [ ] 创建订单需求实体类 (`OrderDemand`)
- [ ] 创建订单需求数据模型 (`OrderDemandModel`)
- [ ] 实现订单需求Repository和DataSource
- [ ] 创建买家申请页面
- [ ] 实现申请理由选择和表单提交
- [ ] 添加申请历史列表页面
- [ ] 在订单详情页添加申请入口
- [ ] 实现文件上传和图片选择功能
- [ ] 添加申请状态的实时更新

**新建文件：**
- `lib/features/orders/domain/entities/order_demand.dart`
- `lib/features/orders/domain/entities/order_demand_status.dart`
- `lib/features/orders/data/models/order_demand_model.dart`
- `lib/features/orders/data/datasources/order_demand_remote_data_source.dart`
- `lib/features/orders/data/repositories/order_demand_repository_impl.dart`
- `lib/features/orders/domain/repositories/order_demand_repository.dart`
- `lib/features/orders/domain/usecases/apply_order_demand_usecase.dart`
- `lib/features/orders/domain/usecases/get_order_demand_list_usecase.dart`
- `lib/features/orders/presentation/pages/order_demand_apply_page.dart`
- `lib/features/orders/presentation/pages/order_demand_list_page.dart`
- `lib/features/orders/presentation/bloc/order_demand_bloc.dart`

### 4. 卖家需求审核功能
**状态：** ❌ 未实现，后端API完整  
**API端点：** `POST /api/project/orderDemand/sellerReview`  

**任务详情：**
- [ ] 创建卖家审核页面
- [ ] 实现审核通过/拒绝操作
- [ ] 添加审核意见填写
- [ ] 实现需求列表查看
- [ ] 添加审核结果通知
- [ ] 实现审核状态的实时同步
- [ ] 添加审核历史记录

**新建文件：**
- `lib/features/orders/domain/usecases/seller_review_demand_usecase.dart`
- `lib/features/orders/presentation/seller/pages/seller_demand_review_page.dart`
- `lib/features/orders/presentation/seller/pages/seller_demand_list_page.dart`
- `lib/features/orders/presentation/seller/bloc/seller_demand_bloc.dart`

### 5. 需求状态跟踪功能
**状态：** ❌ 未实现  
**API端点：** `GET /api/project/orderDemand/detail`, `POST /api/project/orderDemand/list`  

**任务详情：**
- [ ] 创建需求详情页面
- [ ] 实现状态时间线组件
- [ ] 添加需求处理历史显示
- [ ] 集成到订单详情页面
- [ ] 实现状态变更通知
- [ ] 添加进度追踪可视化
- [ ] 实现状态变更的推送通知

**新建文件：**
- `lib/features/orders/domain/usecases/get_order_demand_detail_usecase.dart`
- `lib/features/orders/presentation/pages/order_demand_detail_page.dart`
- `lib/features/orders/presentation/widgets/order_demand_timeline_widget.dart`
- `lib/features/orders/presentation/bloc/order_demand_detail_bloc.dart`

## 🔧 中优先级功能完善

### 6. 提醒发货功能
**状态：** ⚠️ 后端已实现，前端未集成  
**API端点：** `GET /api/shop/order/remind`  

**任务详情：**
- [ ] 修复提醒发货API调用
- [ ] 添加12小时限制提示
- [ ] 在买家订单详情页添加提醒按钮
- [ ] 实现提醒成功反馈
- [ ] 添加提醒次数统计和显示
- [ ] 实现提醒冷却时间的倒计时显示

### 7. 订单统计功能
**状态：** ⚠️ 后端已实现，前端未使用  
**API端点：** `POST /api/shop/order/counts`  

**任务详情：**
- [ ] 实现订单数量统计API调用
- [ ] 在订单列表Tab上显示数量Badge
- [ ] 添加订单统计面板
- [ ] 实现数据实时更新
- [ ] 添加统计数据的本地缓存
- [ ] 实现统计数据的定时刷新

### 8. 物流跟踪功能
**状态：** ❌ 基础设施缺失  

**任务详情：**
- [ ] 设计物流信息数据结构
- [ ] 创建物流跟踪页面
- [ ] 实现物流状态查询
- [ ] 添加物流时间线展示
- [ ] 集成第三方物流API（如有）
- [ ] 实现物流状态推送通知

## 🏗️ 技术架构完善

### 9. 数据层架构完善
**任务详情：**
- [ ] 完善OrderDemand相关的Repository模式实现
- [ ] 统一API响应数据的错误处理机制
- [ ] 实现数据模型的JSON序列化优化
- [ ] 添加数据验证和边界条件检查
- [ ] 完善本地缓存策略（Drift数据库）
- [ ] 实现数据同步和冲突解决机制

### 10. 状态管理架构优化
**任务详情：**
- [ ] 设计OrderDemand相关的Bloc/Event/State架构
- [ ] 优化现有订单状态管理的复杂度
- [ ] 实现跨页面状态同步机制
- [ ] 添加状态持久化支持
- [ ] 优化状态变更的性能

### 11. 路由和导航完善
**任务详情：**
- [ ] 更新 `order_routes.dart` 添加新页面路由
- [ ] 实现深度链接支持（订单详情、需求详情等）
- [ ] 优化页面跳转参数传递
- [ ] 添加路由权限控制（买家/卖家权限）
- [ ] 实现页面返回结果处理

**需要更新的路由文件：**
- `lib/features/orders/presentation/routes/order_routes.dart`
- `lib/app/navigation/app_router.dart`

### 12. 依赖注入配置
**任务详情：**
- [ ] 更新 `orders_di.dart` 注册新的UseCase和Repository
- [ ] 配置OrderDemand相关服务的依赖关系
- [ ] 优化依赖注入的性能和内存使用
- [ ] 添加开发环境的Mock服务配置

**需要更新的DI文件：**
- `lib/features/orders/di/orders_di.dart`
- `lib/app/di/app_di.dart`

## 🌐 国际化和本地化

### 13. 多语言支持
**任务详情：**
- [ ] 添加订单需求相关的国际化文案
- [ ] 更新 `app_localizations.arb` 文件
- [ ] 实现平台介入相关的多语言支持
- [ ] 添加错误信息的本地化
- [ ] 实现日期时间格式的本地化

**需要更新的本地化文件：**
- `lib/l10n/app_zh.arb`
- `lib/l10n/app_en.arb`

## 🔒 安全性和数据保护

### 14. 安全性增强
**任务详情：**
- [ ] 实现订单操作的权限验证
- [ ] 添加敏感操作的二次确认
- [ ] 实现API调用的防重放攻击机制
- [ ] 加强文件上传的安全验证
- [ ] 实现数据传输的加密保护
- [ ] 添加操作日志记录

### 15. 数据验证和边界条件
**任务详情：**
- [ ] 实现表单输入的前端验证
- [ ] 添加API参数的格式验证
- [ ] 实现文件上传的大小和格式限制
- [ ] 添加网络异常的优雅处理
- [ ] 实现数据完整性检查

## 📱 UI/UX优化任务

### 16. 订单操作优化
**任务详情：**
- [ ] 优化操作按钮布局和交互
- [ ] 统一确认对话框样式
- [ ] 改善加载状态显示
- [ ] 优化错误提示用户体验
- [ ] 实现操作成功的动画反馈
- [ ] 添加操作引导和帮助文案

### 17. 状态显示优化
**任务详情：**
- [ ] 统一订单状态颜色和样式
- [ ] 优化状态时间线组件
- [ ] 改善状态变更动画
- [ ] 添加状态说明文案
- [ ] 实现状态图标的统一设计
- [ ] 优化状态切换的视觉效果

### 18. 响应式设计优化
**任务详情：**
- [ ] 优化平板设备的页面布局
- [ ] 实现横屏模式的适配
- [ ] 优化不同屏幕尺寸的显示效果
- [ ] 改善触摸交互的响应性
- [ ] 优化键盘弹出时的页面适配

## 🧪 测试和质量保证

### 19. 单元测试
**任务详情：**
- [ ] 为新增UseCase编写单元测试
- [ ] 为Repository和DataSource编写测试
- [ ] 为Bloc状态管理编写测试
- [ ] 实现数据模型的测试覆盖
- [ ] 添加边界条件和异常情况的测试

### 20. 集成测试
**任务详情：**
- [ ] 验证所有API调用的参数正确性
- [ ] 测试错误情况的处理
- [ ] 验证状态流转的正确性
- [ ] 测试并发操作的安全性
- [ ] 验证跨页面数据同步的正确性

### 21. 用户体验测试
**任务详情：**
- [ ] 测试完整的订单流程
- [ ] 验证买卖双方的操作权限
- [ ] 测试异常情况的用户引导
- [ ] 优化页面加载性能
- [ ] 验证无障碍访问支持

### 22. 性能测试
**任务详情：**
- [ ] 测试大量订单数据的加载性能
- [ ] 优化列表滚动的流畅性
- [ ] 测试图片加载和缓存效果
- [ ] 验证内存使用的合理性
- [ ] 测试网络异常时的应用表现

## 📋 开发里程碑

### 里程碑 1：核心功能修复（1周）
- [x] 重新分析后端API实现
- [ ] 修复邀请评价功能
- [ ] 实现平台介入正确逻辑
- [ ] 更新相关文档和规则
- [ ] 完善数据层架构设计

### 里程碑 2：买家需求功能（2周）
- [ ] 实现OrderDemand完整数据层
- [ ] 实现买家申请补充材料
- [ ] 创建申请历史和详情页面
- [ ] 集成到现有订单流程
- [ ] 完成基础测试和路由配置

### 里程碑 3：卖家审核功能（1-2周）
- [ ] 实现卖家需求审核
- [ ] 创建审核列表和详情页面
- [ ] 完善状态跟踪功能
- [ ] 完成功能集成测试
- [ ] 实现国际化支持

### 里程碑 4：体验优化和完善（1周）
- [ ] 完成UI/UX优化
- [ ] 实现统计和提醒功能
- [ ] 完成全面测试
- [ ] 实现安全性增强
- [ ] 准备发布文档

## 🔍 技术债务和改进

### 代码质量
- [ ] 统一API调用错误处理模式
- [ ] 改善数据模型的类型安全
- [ ] 优化状态管理复杂度
- [ ] 增加单元测试覆盖率
- [ ] 完善代码文档和注释
- [ ] 实现代码静态分析规则

### 性能优化
- [ ] 优化列表页面分页加载
- [ ] 减少不必要的API调用
- [ ] 实现数据缓存策略
- [ ] 优化页面渲染性能
- [ ] 实现图片懒加载和预加载
- [ ] 优化内存使用和垃圾回收

### 监控和分析
- [ ] 添加性能监控埋点
- [ ] 实现错误日志收集
- [ ] 添加用户行为分析
- [ ] 实现API调用监控
- [ ] 添加崩溃报告收集

## 📝 注意事项

### 开发规范
1. **严格遵循后端API规范**：确保所有API调用参数和后端完全一致
2. **状态管理一致性**：前端状态枚举必须与后端完全对应
3. **错误处理完整性**：所有API调用都需要完整的错误处理
4. **用户体验优先**：所有操作都需要明确的反馈和引导
5. **代码复用性**：优先使用现有组件和工具类
6. **性能考虑**：避免不必要的重建和API调用

### 测试要求
1. **功能测试**：每个新功能都需要完整的功能测试
2. **集成测试**：验证与现有功能的集成正确性
3. **边界测试**：测试各种异常和边界情况
4. **用户测试**：从用户角度验证操作流程的合理性
5. **回归测试**：确保新功能不影响现有功能
6. **性能测试**：验证新功能的性能表现

### 发布准备
1. **文档更新**：更新相关开发文档和用户指南
2. **代码审查**：确保代码质量和规范性
3. **性能验证**：确保新功能不影响整体性能
4. **兼容性测试**：验证在不同设备和网络环境下的表现
5. **安全审查**：确保没有安全漏洞和数据泄露风险
6. **发布计划**：制定分阶段发布策略和回滚方案

---

**最后更新：** 2024年12月19日 - 基于后端API重新分析结果，完善技术实现细节  
**负责人：** 开发团队  
**预计完成：** 4-5周  
**优先级排序：** 邀请评价修复 > 平台介入 > 买家需求申请 > 卖家审核 > 其他功能

## 📊 工作量估算

| 分类 | 工作量(人天) | 占比 |
|------|-------------|------|
| 核心功能修复 | 5天 | 20% |
| 新功能开发 | 15天 | 60% |
| UI/UX优化 | 3天 | 12% |
| 测试和优化 | 2天 | 8% |
| **总计** | **25天** | **100%** | 