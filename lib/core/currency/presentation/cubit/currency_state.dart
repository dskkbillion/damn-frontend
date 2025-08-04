part of 'currency_cubit.dart';

@freezed
class CurrencyState with _$CurrencyState {
  const factory CurrencyState.initial() = CurrencyInitial;
  const factory CurrencyState.loading() = CurrencyLoading;
  const factory CurrencyState.loaded(
    Currency selectedCurrency,
    Map<String, Money> convertedPrices,
  ) = CurrencyLoaded;
  const factory CurrencyState.error(String message) = CurrencyError;
}