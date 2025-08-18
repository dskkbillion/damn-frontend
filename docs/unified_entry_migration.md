# Unified Entry Point Migration Guide

## Overview

This document describes the migration from multiple entry points (domestic/international, dev/prod) to a unified entry point that supports all features.

## Current State (Before Migration)

### Entry Points
- `lib/main.dart` - Default development entry
- `lib/main_domestic.dart` - Domestic production 
- `lib/main_international.dart` - International production
- `lib/main_domestic_dev.dart` - Domestic development with test credentials
- `lib/main_international_dev.dart` - International development with test credentials

### Key Differences

| Feature | Domestic | International | Unified |
|---------|----------|---------------|---------|
| **Currency** | CNY (¥) | USD ($) | USD ($) |
| **Payment Methods** | Alipay, WeChat Pay | Stripe | All methods |
| **Login Methods** | WeChat | Google, Apple | All methods |
| **API Endpoint** | BACKEND_BASE_URL | INTERNATIONAL_API_URL | Configurable |
| **Test Credentials** | Dev only | Dev only | Dev mode only |

## New Unified Architecture

### Single Entry Point Options

#### Option 1: Simple Unified Entry (Recommended)
**File:** `lib/main_unified_simple.dart`

```bash
# Production
flutter run -t lib/main_unified_simple.dart

# Development (with test credentials)
flutter run -t lib/main_unified_simple.dart --dart-define=DEV_MODE=true
```

**Features:**
- Uses modified `RegionConfig` with `RegionType.unified`
- Minimal code changes required
- All payment and login methods enabled
- USD as universal currency

#### Option 2: Advanced Unified Entry
**File:** `lib/main_unified.dart`

```bash
# Production
flutter run -t lib/main_unified.dart

# Development
flutter run -t lib/main_unified.dart --dart-define=CONFIG_MODE=development
```

**Features:**
- New `UnifiedRegionConfig` class
- Runtime API endpoint switching capability
- More flexible configuration system
- Future-proof architecture

## Migration Steps

### Phase 1: Update RegionConfig (Completed)
✅ Add `RegionType.unified` enum value
✅ Update currency, payment, and feature configurations for unified mode
✅ Ensure all switch statements handle unified case

### Phase 2: Create Unified Entry Points (Completed)
✅ Create `main_unified_simple.dart` using existing RegionConfig
✅ Create `main_unified.dart` with new UnifiedRegionConfig
✅ Create adapter layer for gradual migration

### Phase 3: Update UI Components
- [ ] Update payment method selector to show all options
- [ ] Update login screen to show all authentication methods
- [ ] Ensure currency displays correctly as USD everywhere
- [ ] Update any region-specific UI logic

### Phase 4: Test and Validate
- [ ] Test all payment methods work correctly
- [ ] Verify login methods are accessible
- [ ] Confirm API endpoints are reachable
- [ ] Test both production and development modes

### Phase 5: Deprecate Old Entry Points
- [ ] Archive old entry points to `lib/archived_entries/`
- [ ] Update documentation
- [ ] Update build scripts and CI/CD pipelines

## Code Changes Required

### 1. Payment Method Selector
The payment selector already uses `RegionConfig.supportedPaymentMethods`, so it will automatically show all methods in unified mode.

### 2. Login Screen
Need to update the login screen to check features and display all login options:

```dart
// Before (region-specific)
if (RegionConfig.isFeatureEnabled('enableWechatLogin')) {
  // Show WeChat login
}

// After (unified - all methods shown)
// Show all login methods
```

### 3. Price Display
Already uses `RegionConfig.formatPrice()`, will automatically use USD in unified mode.

## Environment Configuration

### Required Variables
```env
# Always required
BACKEND_BASE_URL=https://your-api.com
MODEL_BASE_URL=https://your-model-api.com

# Optional for multi-region support
INTERNATIONAL_API_URL=https://international-api.com
CONFIG_MODE=production  # or development
```

### Build Commands

#### Production Builds
```bash
# Unified production APK
flutter build apk -t lib/main_unified_simple.dart --release

# Unified production iOS
flutter build ios -t lib/main_unified_simple.dart --release
```

#### Development Builds
```bash
# Unified development with test credentials
flutter build apk -t lib/main_unified_simple.dart --dart-define=DEV_MODE=true
```

## Benefits of Unified Approach

1. **Reduced Maintenance**: Single codebase to maintain
2. **Simplified Deployment**: One build for all regions
3. **Better User Experience**: Users can choose payment/login methods
4. **Cost Effective**: Single app store submission
5. **Future Proof**: Easy to add new payment methods or regions

## Potential Issues and Mitigations

### Issue 1: Non-functional Payment Methods
**Problem**: WeChat Pay might not work in some countries
**Mitigation**: Show all methods but handle errors gracefully

### Issue 2: Compliance Requirements
**Problem**: Different regions have different legal requirements
**Mitigation**: Use feature flags to enable/disable based on user location if needed

### Issue 3: Backend Compatibility
**Problem**: Backend might expect region-specific requests
**Mitigation**: Add region header to API requests if needed

### Issue 4: SDK Size
**Problem**: Including all payment SDKs increases app size
**Mitigation**: Use dynamic feature modules or code splitting if size becomes issue

## Testing Checklist

- [ ] All payment methods appear in payment selector
- [ ] All login methods appear on login screen
- [ ] Prices display in USD with $ symbol
- [ ] API calls work with primary endpoint
- [ ] API calls can switch to secondary endpoint if configured
- [ ] Test credentials inject correctly in dev mode
- [ ] App works without test credentials in production mode
- [ ] All features function correctly regardless of user location

## Rollback Plan

If issues arise, the old entry points are still available:
1. Switch back to using specific entry points
2. RegionConfig still supports domestic/international modes
3. No database or API changes required

## Timeline

- **Week 1**: Update UI components for unified mode
- **Week 2**: Testing and validation
- **Week 3**: Update documentation and CI/CD
- **Week 4**: Deploy unified version

## Conclusion

The unified entry point simplifies the application architecture while maintaining all functionality. By using USD as a universal currency and enabling all payment/login methods, we create a more flexible and maintainable application.