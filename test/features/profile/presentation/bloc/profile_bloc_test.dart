import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/profile/domain/entities/user_profile.dart';
import 'package:dskk_flutter_refactor/features/profile/domain/entities/wallet_summary.dart';
import 'package:dskk_flutter_refactor/features/profile/domain/usecases/check_auth_status.dart';
import 'package:dskk_flutter_refactor/features/profile/domain/usecases/get_user_profile.dart';
import 'package:dskk_flutter_refactor/features/profile/domain/usecases/get_wallet_summary.dart';
import 'package:dskk_flutter_refactor/features/profile/domain/usecases/logout.dart';
import 'package:dskk_flutter_refactor/features/profile/domain/usecases/update_user_profile.dart';
import 'package:dskk_flutter_refactor/features/profile/domain/usecases/upload_avatar.dart';
import 'package:dskk_flutter_refactor/features/profile/presentation/bloc/profile_bloc.dart';

@GenerateMocks([
  GetUserProfileUseCase,
  UpdateUserProfileUseCase,
  UploadAvatarUseCase,
  GetWalletSummary,
  CheckAuthStatusUseCase,
  LogoutUseCase,
])
import 'profile_bloc_test.mocks.dart';

void main() {
  late ProfileBloc bloc;
  late MockGetUserProfileUseCase mockGetUserProfile;
  late MockUpdateUserProfileUseCase mockUpdateUserProfile;
  late MockUploadAvatarUseCase mockUploadAvatar;
  late MockGetWalletSummary mockGetWalletSummary;
  late MockCheckAuthStatusUseCase mockCheckAuthStatus;
  late MockLogoutUseCase mockLogout;

  setUp(() {
    mockGetUserProfile = MockGetUserProfileUseCase();
    mockUpdateUserProfile = MockUpdateUserProfileUseCase();
    mockUploadAvatar = MockUploadAvatarUseCase();
    mockGetWalletSummary = MockGetWalletSummary();
    mockCheckAuthStatus = MockCheckAuthStatusUseCase();
    mockLogout = MockLogoutUseCase();

    bloc = ProfileBloc(
      getUserProfile: mockGetUserProfile,
      updateUserProfile: mockUpdateUserProfile,
      uploadAvatar: mockUploadAvatar,
      getWalletSummary: mockGetWalletSummary,
      checkAuthStatus: mockCheckAuthStatus,
      logout: mockLogout,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('初始状态应该是ProfileInitial', () {
    expect(bloc.state, equals(ProfileInitial()));
  });

  const tUserProfile = UserProfile(
    userId: '1',
    nickName: '测试用户',
    avatarUrl: 'assets/images/avatar_placeholder.png',
    onlineFlag: true,
  );

  final tWalletSummary = WalletSummary(
    balance: 1000.0,
    pendingAmount: 200.0,
    totalIncome: 5000.0,
    hasBankCard: false,
    hasPaymentPassword: false,
    recentTransactionsCount: 0,
  );

  group('CheckAuthStatusEvent', () {
    blocTest<ProfileBloc, ProfileState>(
      '应该发出 [ProfileLoading, ProfileAuthStatusLoaded] 当认证检查成功',
      build: () {
        when(mockCheckAuthStatus(any))
            .thenAnswer((_) async => const Right(true));
        return bloc;
      },
      act: (bloc) => bloc.add(CheckAuthStatusEvent()),
      expect: () => [
        ProfileLoading(),
        const ProfileAuthStatusLoaded(isAuthenticated: true),
      ],
      verify: (_) {
        verify(mockCheckAuthStatus(NoParams()));
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      '应该发出 [ProfileLoading, ProfileAuthStatusLoaded(false)] 当用户未认证',
      build: () {
        when(mockCheckAuthStatus(any))
            .thenAnswer((_) async => const Right(false));
        return bloc;
      },
      act: (bloc) => bloc.add(CheckAuthStatusEvent()),
      expect: () => [
        ProfileLoading(),
        const ProfileAuthStatusLoaded(isAuthenticated: false),
      ],
    );
  });

  group('GetUserProfileEvent', () {
    blocTest<ProfileBloc, ProfileState>(
      '应该发出 [ProfileLoading, ProfileLoaded] 当获取用户资料成功',
      build: () {
        when(mockGetUserProfile(any))
            .thenAnswer((_) async => const Right(tUserProfile));
        return bloc;
      },
      act: (bloc) => bloc.add(GetUserProfileEvent()),
      expect: () => [
        ProfileLoading(),
        const ProfileLoaded(profile: tUserProfile),
      ],
      verify: (_) {
        verify(mockGetUserProfile(NoParams()));
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      '应该发出 [ProfileLoading, ProfileError] 当获取用户资料失败',
      build: () {
        when(mockGetUserProfile(any))
            .thenAnswer((_) async => Left(ServerFailure(message: '服务器错误')));
        return bloc;
      },
      act: (bloc) => bloc.add(GetUserProfileEvent()),
      expect: () => [
        ProfileLoading(),
        ProfileError(message: 'ServerFailure(服务器错误, null)'),
      ],
    );
  });

  group('GetWalletSummaryEvent', () {
    blocTest<ProfileBloc, ProfileState>(
      '应该发出 [WalletSummaryLoading, WalletSummaryLoaded] 当获取钱包摘要成功',
      build: () {
        when(mockGetWalletSummary(any))
            .thenAnswer((_) async => Right(tWalletSummary));
        return bloc;
      },
      act: (bloc) => bloc.add(GetWalletSummaryEvent()),
      expect: () => [
        WalletSummaryLoading(),
        WalletSummaryLoaded(walletSummary: tWalletSummary),
      ],
      verify: (_) {
        verify(mockGetWalletSummary(NoParams()));
      },
    );
  });

  group('LogoutEvent', () {
    blocTest<ProfileBloc, ProfileState>(
      '应该发出 [ProfileLoggingOut, ProfileLoggedOut] 当退出登录成功',
      build: () {
        when(mockLogout(any))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(LogoutEvent()),
      expect: () => [
        ProfileLoggingOut(),
        const ProfileLoggedOut(),
      ],
      verify: (_) {
        verify(mockLogout(NoParams()));
      },
    );
  });

  group('SwitchToSellerModeEvent', () {
    blocTest<ProfileBloc, ProfileState>(
      '应该发出 [ProfileSwitchingToSellerMode, ProfileSwitchedToSellerMode] 当切换到卖家模式',
      build: () => bloc,
      act: (bloc) => bloc.add(const SwitchToSellerModeEvent()),
      expect: () => [
        const ProfileSwitchingToSellerMode(),
        const ProfileSwitchedToSellerMode(),
      ],
    );
  });

  group('SwitchToBuyerModeEvent', () {
    blocTest<ProfileBloc, ProfileState>(
      '应该发出 [ProfileSwitchingToBuyerMode, ProfileSwitchedToBuyerMode] 当切换到买家模式',
      build: () => bloc,
      act: (bloc) => bloc.add(const SwitchToBuyerModeEvent()),
      expect: () => [
        const ProfileSwitchingToBuyerMode(),
        const ProfileSwitchedToBuyerMode(),
      ],
    );
  });
}
