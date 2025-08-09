# Seller Module Localization TODO

## Status
- ✅ Batch 1: Authentication Pages (Completed)
- 🔄 Batch 2: Product Management (In Progress)
- ⏳ Batch 3: Auto Reply Settings
- ⏳ Batch 4: Time Management Settings  
- ⏳ Batch 5: My Wallet

## Batch 2: Product Management Pages 🔄

### Files to Update:
- [ ] `lib/features/seller/presentation/pages/product_management_page.dart`
- [ ] `lib/features/seller/presentation/pages/product_edit_page.dart`
- [ ] `lib/features/seller/presentation/pages/product_preview_page.dart`

### Text to Localize:

#### Product Management Page
- Tab labels: 在售, 草稿箱, 已下架
- Actions: 下架, 上架, 编辑, 删除, 发布, 重新提交
- Status tags: 审核中, 审核失败, 已上架, 已下架, 草稿, 等待审核
- Messages: 草稿状态的商品需要先发布才能预览, 没有更多商品了
- Empty states: 暂无在售商品, 暂无草稿商品, 暂无已下架商品
- Confirm dialogs: 确认下架, 确认删除
- Labels: 库存, 销量, 创建商品

#### Product Edit Page
- Basic fields: 商品名称, 商品描述, 商品价格, 基础信息
- Features: 商品图片, 服务档位设置, 详情介绍
- Actions: 保存草稿, 发布商品, 预览商品, 编辑商品, 创建商品, 添加图片
- Validation: 请至少上传一张商品图片
- Status: 上传中...

#### Product Preview Page
- Labels: 当前卖家, 卖家用户

## Batch 3: Auto Reply Settings ⏳

### Files to Find:
- Need to search for auto reply related pages
- Check for files like: auto_reply_page.dart, auto_reply_settings_page.dart

### Expected Text to Localize:
- 自动回复设置
- 启用自动回复
- 回复内容
- 工作时间设置
- 非工作时间回复

## Batch 4: Time Management Settings ⏳

### Files to Find:
- Need to search for time management pages
- Check for files like: time_management_page.dart, time_settings_page.dart

### Expected Text to Localize:
- 时间管理
- 工作时间
- 休息时间
- 时区设置
- 营业时间

## Batch 5: My Wallet ⏳

### Files to Find:
- Need to search for wallet pages
- Check for files like: wallet_page.dart, my_wallet_page.dart

### Expected Text to Localize:
- 我的钱包
- 余额
- 提现
- 充值
- 交易记录
- 收入明细
- 支出明细

## Implementation Notes

1. Use null-safe pattern: `AppLocalizations.of(context)?.key ?? 'Fallback'`
2. Add keys to both `intl_zh.arb` and `intl_en.arb`
3. Run `flutter gen-l10n` after adding translations
4. Run `flutter analyze` to verify no errors
5. Test both languages in the app