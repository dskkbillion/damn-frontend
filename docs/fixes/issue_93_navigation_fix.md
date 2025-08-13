# Issue #93 Fix: 国内开发入口home页面点击商品无法进入详情页

## Problem Description
When using the domestic development entry point (`main_domestic_dev.dart`), clicking on products in the home page doesn't navigate to the product detail page. The app only prints to console but doesn't perform actual navigation.

## Root Cause Analysis

### 1. Navigation Service Registration Issue
The domestic dev entry was calling `initHomeDi()` which registers a `SimpleHomeNavigationService` - a mock implementation that only prints to console:

```dart
// In home_di.dart
sl.registerLazySingleton<HomeNavigationService>(
  () => SimpleHomeNavigationService(), // Mock implementation!
);
```

### 2. Missing Real Navigation Service
The real navigation service (`RealHomeNavigationService`) requires a GoRouter instance to work properly, but it was never registered in the domestic dev entry.

### 3. Comparison with Working Entry
The international dev entry (`main_international_dev.dart`) correctly registers the real navigation service after obtaining the GoRouter instance:

```dart
HomeNavigationDI.registerRealNavigationService(getIt, router);
```

## Solution Implementation

### Files Modified
1. **`lib/main_domestic_dev.dart`**
   - Added imports for `HomeNavigationDI` and `goRouterProvider`
   - Modified app initialization to use Consumer pattern
   - Added proper registration of RealHomeNavigationService

### Key Changes

```dart
// Added imports
import 'package:dskk_flutter_refactor/features/home/presentation/navigation/home_navigation_di.dart';
import 'package:dskk_flutter_refactor/app/navigation/app_router.dart';

// Updated app initialization
runApp(
  ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: Builder(
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            // Get GoRouter instance
            final router = ref.read(goRouterProvider);
            
            // Register real navigation service
            WidgetsBinding.instance.addPostFrameCallback((_) {
              print('[Domestic Dev] Registering navigation service...');
              HomeNavigationDI.registerRealNavigationService(getIt, router);
              print('[Domestic Dev] Navigation service registered successfully.');
            });
            
            return const MyApp();
          },
        );
      },
    ),
  ),
);
```

## How the Fix Works

1. **Consumer Pattern**: Uses Riverpod's Consumer to access the GoRouter provider after the app context is built
2. **Post-Frame Callback**: Registers the navigation service after the first frame is rendered to ensure all dependencies are ready
3. **Dependency Override**: The `HomeNavigationDI.registerRealNavigationService()` method allows reassignment to replace the mock service with the real one
4. **GoRouter Integration**: The real navigation service uses GoRouter's named routes to properly navigate to product details

## Navigation Flow After Fix

1. User clicks product in home page
2. `ProductCardClicked` event is dispatched to HomeBloc
3. HomeBloc calls `navigationService.navigateToProductDetail(productId)`
4. RealHomeNavigationService uses GoRouter to navigate: `router.pushNamed('productDetail', pathParameters: {'productId': productId})`
5. Product detail page opens successfully

## Testing Instructions

1. Run the domestic dev entry:
   ```bash
   flutter run -t lib/main_domestic_dev.dart
   ```

2. Verify console output shows:
   ```
   [Domestic Dev] Registering navigation service...
   [Domestic Dev] Navigation service registered successfully.
   ```

3. Navigate to home page and click any product

4. Product detail page should open successfully

## Prevention

To prevent similar issues in the future:

1. **Consistent Entry Points**: All entry points should follow the same initialization pattern
2. **Documentation**: Document the requirement for registering real navigation services
3. **Module Independence**: Consider making modules work with default real implementations rather than mocks
4. **Testing**: Add integration tests for navigation in different entry points

## Related Files

- `lib/main_domestic_dev.dart` - Fixed entry point
- `lib/main_international_dev.dart` - Reference implementation
- `lib/features/home/di/home_di.dart` - Module DI configuration
- `lib/features/home/presentation/navigation/home_navigation_di.dart` - Navigation DI
- `lib/features/home/presentation/navigation/real_home_navigation_service.dart` - Real navigation implementation
- `lib/app/navigation/app_router.dart` - Router configuration