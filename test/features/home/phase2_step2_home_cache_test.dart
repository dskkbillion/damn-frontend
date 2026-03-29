import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/home/data/datasources/home_local_data_source.dart';
import 'package:dskk_flutter_refactor/features/home/data/models/banner_model.dart';
import 'package:dskk_flutter_refactor/features/home/data/models/home_feed_item_model.dart';
import 'package:dskk_flutter_refactor/features/home/data/models/home_page_data_model.dart';
import 'package:dskk_flutter_refactor/features/home/domain/entities/banner.dart';
import 'package:dskk_flutter_refactor/features/home/domain/entities/home_category.dart';
import 'package:dskk_flutter_refactor/features/home/domain/entities/home_feed_item.dart';
import 'package:dskk_flutter_refactor/features/home/domain/entities/home_page_data.dart';
import 'package:dskk_flutter_refactor/features/home/domain/usecases/get_home_feed_usecase.dart';
import 'package:dskk_flutter_refactor/features/home/domain/usecases/get_home_page_data_usecase.dart';
import 'package:dskk_flutter_refactor/features/home/presentation/bloc/home_bloc.dart';
import 'package:dskk_flutter_refactor/features/home/presentation/bloc/home_event.dart';
import 'package:dskk_flutter_refactor/features/home/presentation/bloc/home_state.dart';
import 'package:dskk_flutter_refactor/features/home/presentation/navigation/home_navigation_service.dart';

// ── Manual use-case stubs ────────────────────────────────────────────────────

/// Stub for GetHomePageDataUseCase that does not depend on a real repository.
class _StubGetHomePageDataUseCase implements GetHomePageDataUseCase {
  Either<Failure, HomePageData>? _result;

  void returns(Either<Failure, HomePageData> result) => _result = result;

  @override
  Future<Either<Failure, HomePageData>> call(NoParams params) async {
    return _result!;
  }

  // GetHomePageDataUseCase extends UseCase which only requires `call` —
  // expose the repository field to satisfy the class contract.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Stub for GetHomeFeedUseCase — never called in these tests.
class _StubGetHomeFeedUseCase implements GetHomeFeedUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ── Manual data-source stub ──────────────────────────────────────────────────

class _StubHomeLocalDataSource implements HomeLocalDataSource {
  HomePageDataModel? _cached;
  bool throwOnGet = false;

  void setCache(HomePageDataModel data) => _cached = data;

  @override
  Future<HomePageDataModel> getLastHomePageData() async {
    if (throwOnGet || _cached == null) throw CacheException();
    return _cached!;
  }

  @override
  Future<void> cacheHomePageData(HomePageDataModel homePageData) async {}

  @override
  Future<List<HomeFeedItemModel>> getLastHomeFeed(int page) async {
    throw CacheException();
  }

  @override
  Future<void> cacheHomeFeed(int page, List<HomeFeedItemModel> homeFeed) async {}
}

// ── Navigation stub ──────────────────────────────────────────────────────────

class _StubNavigationService implements HomeNavigationService {
  @override
  void navigateToProductDetail(String productId) {}
  @override
  void navigateToSearch(String? query) {}
  @override
  void navigateToCategoryDetail(String categoryId) {}
  @override
  void navigateToUrl(String url) {}
  @override
  void showRecommendConfirmation(String productId, String productName) {}
}

// ── Fixtures ─────────────────────────────────────────────────────────────────

HomePageDataModel _cachedModel() => HomePageDataModel(
      banners: [
        BannerModel(
          id: 'b1',
          imageUrl: 'http://cached.img',
          targetType: 'none',
          targetValue: '',
          createTime: '',
          updateTime: '',
        ),
      ],
      categories: const [],
      feedItems: [
        HomeFeedItemModel(
          id: '1',
          type: 'product',
          name: 'Cached Product',
          images: const ['http://cached.product.img'],
          sellingPrice: 9.9,
          score: 5.0,
          evaluateNum: 0,
        ),
      ],
    );

HomePageData _remoteData() => HomePageData(
      banners: [
        const Banner(id: 'b2', imageUrl: 'http://remote.img'),
      ],
      categories: const <HomeCategory>[],
      feedItems: [
        HomeFeedItem(
          id: 'f2',
          name: 'Remote Product',
          images: const ['http://remote.product.img'],
          sellingPrice: 19.9,
        ),
      ],
    );

// ── Builder helper ────────────────────────────────────────────────────────────

HomeBloc _buildBloc({
  required _StubGetHomePageDataUseCase useCase,
  required _StubHomeLocalDataSource local,
}) =>
    HomeBloc(
      getHomePageData: useCase,
      getHomeFeed: _StubGetHomeFeedUseCase(),
      navigationService: _StubNavigationService(),
      localDataSource: local,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('HomeBloc — stale-while-revalidate caching', () {
    late _StubGetHomePageDataUseCase mockUseCase;
    late _StubHomeLocalDataSource mockLocal;

    setUp(() {
      mockUseCase = _StubGetHomePageDataUseCase();
      mockLocal = _StubHomeLocalDataSource();
    });

    // 1. 有缓存 + 远程成功：先 emit isRefreshing:true，再 emit isRefreshing:false
    blocTest<HomeBloc, HomeState>(
      'when cache exists and remote succeeds: '
      'emits HomeLoaded(isRefreshing:true) then HomeLoaded(isRefreshing:false)',
      build: () {
        mockLocal.setCache(_cachedModel());
        mockUseCase.returns(Right(_remoteData()));
        return _buildBloc(useCase: mockUseCase, local: mockLocal);
      },
      act: (bloc) => bloc.add(const LoadHomeData()),
      expect: () => [
        isA<HomeLoaded>()
            .having((s) => s.isRefreshing, 'isRefreshing first', true)
            .having((s) => s.feedItems.first.name, 'cached name', 'Cached Product'),
        isA<HomeLoaded>()
            .having((s) => s.isRefreshing, 'isRefreshing second', false)
            .having((s) => s.feedItems.first.name, 'remote name', 'Remote Product'),
      ],
    );

    // 2. 无缓存 + 远程成功：显示 HomeLoading，然后 HomeLoaded(isRefreshing:false)
    blocTest<HomeBloc, HomeState>(
      'when no cache and remote succeeds: emits HomeLoading then HomeLoaded',
      build: () {
        mockLocal.throwOnGet = true;
        mockUseCase.returns(Right(_remoteData()));
        return _buildBloc(useCase: mockUseCase, local: mockLocal);
      },
      act: (bloc) => bloc.add(const LoadHomeData()),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeLoaded>()
            .having((s) => s.isRefreshing, 'isRefreshing', false)
            .having((s) => s.feedItems.first.name, 'remote name', 'Remote Product'),
      ],
    );

    // 3. 有缓存 + 远程失败：保持缓存数据，不 emit HomeError
    blocTest<HomeBloc, HomeState>(
      'when cache exists and remote fails: keeps cached HomeLoaded, no HomeError emitted',
      build: () {
        mockLocal.setCache(_cachedModel());
        mockUseCase.returns(Left(ServerFailure(message: 'network error')));
        return _buildBloc(useCase: mockUseCase, local: mockLocal);
      },
      act: (bloc) => bloc.add(const LoadHomeData()),
      expect: () => [
        isA<HomeLoaded>()
            .having((s) => s.isRefreshing, 'isRefreshing', true)
            .having((s) => s.feedItems.first.name, 'cached name', 'Cached Product'),
        // No second state — remote failure is silently absorbed, cache stays
      ],
    );

    // 4. 无缓存 + 远程失败：emit HomeError
    blocTest<HomeBloc, HomeState>(
      'when no cache and remote fails: emits HomeLoading then HomeError',
      build: () {
        mockLocal.throwOnGet = true;
        mockUseCase.returns(Left(ServerFailure(message: 'network error')));
        return _buildBloc(useCase: mockUseCase, local: mockLocal);
      },
      act: (bloc) => bloc.add(const LoadHomeData()),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeError>().having((s) => s.message, 'error message', 'network error'),
      ],
    );
  });
}
