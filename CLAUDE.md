# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter e-commerce application (多少看看 DSKK) being refactored from React Native using Clean Architecture principles. The app follows a modular, incremental refactoring approach where each feature module is developed in isolation with mock dependencies before integration.

## Requirements

- Flutter SDK: `>=3.4.0 <4.0.0`
- Dart SDK: Compatible with Flutter version
- Android/iOS development environment

## Architecture

### Core Pattern: Clean Architecture with Modular Design
- **Domain Layer**: Business logic, entities, use cases, repository interfaces
- **Data Layer**: Repository implementations, data sources, models/DTOs
- **Presentation Layer**: UI pages, widgets, state management (BLoC/Cubit)

### Key Modules
- `auth`: Authentication & user management
- `home`: Main home screen & service discovery
- `orders`: Order management for buyers and sellers
- `chat`: Real-time messaging
- `profile`: User profile management
- `seller`: Seller-specific features
- `ai_docs`: AI-powered documentation assistant
- `favorites`: User favorites/bookmarks
- `after_sales`: After-sales service handling
- `payment`: Payment integration (WeChat, Alipay)

## Common Development Commands

### Build & Run

#### Entry Points
The application has multiple entry points for different environments and regions:

**Production Entries:**
- `lib/main_domestic.dart` - Domestic production (China server: https://app.duoshaokankan.com/prod-api)
- `lib/main_international.dart` - International production (Global server: https://api-global.duoshaokankan.com)

**Development Entries:**
- `lib/main.dart` - Default development entry (with test credentials)
- `lib/main_domestic_dev.dart` - Domestic development with test account auto-login
- `lib/main_international_dev.dart` - International development with test account auto-login

```bash
# Run default development version
flutter run

# Run specific environment
flutter run -t lib/main_domestic.dart        # Domestic production
flutter run -t lib/main_international.dart   # International production
flutter run -t lib/main_domestic_dev.dart    # Domestic dev with test account
flutter run -t lib/main_international_dev.dart # International dev with test account

# Build APK for specific environment
flutter build apk -t lib/main_domestic.dart --release
flutter build apk -t lib/main_international.dart --release
```

**Note:** Module preview entries have been archived to `lib/archived_entries/` for reference.

### Code Generation
```bash
# Run build_runner for code generation (freezed, json_serializable, drift, injectable)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for continuous generation
dart run build_runner watch --delete-conflicting-outputs
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/module_name/test_file_test.dart

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

### Linting & Analysis
```bash
# Analyze code
flutter analyze

# Fix linting issues
dart fix --apply
```

### Internationalization
```bash
# Generate localization files after modifying ARB files
flutter gen-l10n
```

## Module Development Workflow

When developing a new feature module, follow the workflow documented in `docs/dev/模块开发核心工作流.md`:

1. Create feature branch: `refactor/module-name`
2. Define module boundaries in `docs/BD/module_boundary_definition.md`
3. Implement Domain layer interfaces first
4. Create Data layer with mock implementations
5. Build Presentation layer with BLoC/Cubit
6. Test in isolation using module preview entry points
7. Integrate with main app replacing mocks with real implementations

## API Development Standards

Before implementing any API calls:
1. Verify endpoint exists in backend code
2. Confirm HTTP method, request/response format
3. Check authentication requirements
4. Follow patterns in existing data sources (e.g., `OrderRemoteDataSourceImpl`)

Critical rules in `.cursor/rules/`:
- `api-development-standards.mdc`: Mandatory API verification checklist
- `backend-api-compliance.mdc`: Backend API compliance rules
- `order-data-models.mdc`: Order data model specifications
- `order-demand-development-guide.mdc`: Order feature development guide

## Environment Configuration

1. Copy `.env.example` to `.env`
2. Configure required variables:
   - `BACKEND_BASE_URL`: Backend API base URL
   - `MODEL_BASE_URL`: AI model service URL
   - `WECHAT_APP_ID`: WeChat app identifier
   - `WECHAT_UNIVERSAL_LINK`: WeChat universal link (default: `https://app.duoshaokankan.com/wechat/`)

## Database

Uses Drift (SQLite ORM) for local data persistence:
- Database configuration: `lib/core/database/app_database.dart`
- Current version: 1
- Includes order caching functionality
- Run code generation after modifying database schema

## Navigation

The app uses Go Router for navigation. Key points:
- Main router configuration: `lib/app/navigation/app_router_config.dart`
- Use standard Go Router navigation: `context.go()`, `context.push()`
- Each module defines its routes in `presentation/routes/`

## State Management

Primary: BLoC pattern with flutter_bloc
- BLoCs for complex state with multiple events
- Cubits for simpler state management
- Riverpod available for specific use cases

## Dependency Injection

Uses GetIt with injectable for DI:
- Main DI setup: `lib/app/di/injection_container.dart`
- Module-specific DI: `lib/features/[module]/di/[module]_di.dart`
- Mock configurations for isolated development

## Key Development Principles

1. **Modular Independence**: Each module should work in isolation with mocks
2. **Clean Architecture**: Strict separation between Domain, Data, and Presentation
3. **Reference-Based Development**: Use existing RN code and HTML prototypes as reference
4. **Test-Driven**: Write tests for critical business logic
5. **Mock-First**: Develop with mocks, integrate with real implementations later

## Payment Integration

WeChat and Alipay payment SDKs are integrated:
- WeChat: Uses `fluwx` package
- Alipay: Uses `tobias` package
- Configuration: `config/wechat_config.yaml`
- Test payments in `PaymentDemoPage`
- Android URL scheme: `com.duoshaokankan.weapp`

## Internationalization

The app supports multiple languages:
- Primary language: Chinese (`intl_zh.arb`)
- Secondary: English (`intl_en.arb`)
- Localization files: `lib/l10n/`
- Generated localizations: `app_localizations.dart`

## Important Files & Directories

- `lib/app/`: Core app configuration, DI, routing
- `lib/core/`: Shared utilities, network clients, common services
- `lib/features/`: Feature modules (each with domain/data/presentation)
- `docs/BD/`: Module boundary definitions
- `docs/dev/`: Development documentation
- `.cursor/rules/`: Cursor AI development rules
- `design-info/`: Reference HTML prototypes and API documentation
- `lib/l10n/`: Internationalization ARB files
- `assets/`: Images, icons, and other static resources

## Current Development Focus

The project is actively being refactored from React Native. Check git status and recent commits to understand current work:
- Multiple modified files indicate ongoing refactoring
- Feature branches show modules under development
- `.cursor/rules/` contains specific development guidelines for current features

## Development Best Practices

- 在每个flutter文件修改后，运行analyze进行检查