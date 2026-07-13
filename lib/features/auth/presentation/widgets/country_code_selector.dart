import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/country_code.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

class CountryCodeSelector extends StatelessWidget {
  final CountryCode selectedCountry;
  final ValueChanged<CountryCode> onCountryChanged;
  final bool enabled;

  const CountryCodeSelector({
    super.key,
    required this.selectedCountry,
    required this.onCountryChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => _showCountryPicker(context) : null,
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(AppDimensions.radiusMd),
        ),
        child: AnimatedOpacity(
          duration: AppDimensions.animationFast,
          opacity: enabled ? 1 : 0.52,
          child: Container(
            height: AppDimensions.inputHeightLg,
            padding: const EdgeInsets.only(left: 10, right: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.055),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppDimensions.radiusMd),
              ),
              border: Border(
                right: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.16),
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedCountry.flag,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 6),
                Text(
                  selectedCountry.dialCode,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (enabled) ...[
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: AppDimensions.iconMd,
                    color: AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isChineseLocale =
        Localizations.localeOf(context).languageCode == 'zh';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard.withValues(alpha: 0.96),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXl),
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.84)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary.withValues(alpha: 0.46),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusPill),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          localizations.auth_select_country_region,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.textSecondary,
                        tooltip: MaterialLocalizations.of(context)
                            .closeButtonTooltip,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingMd,
                      vertical: AppDimensions.spacingSm,
                    ),
                    itemCount: CountryCodes.commonCountries.length,
                    itemBuilder: (context, index) {
                      final country = CountryCodes.commonCountries[index];
                      final isSelected = country.code == selectedCountry.code;
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.spacingXs),
                        child: Material(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.backgroundPrimary
                                  .withValues(alpha: 0.42),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusLg),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusLg),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.25)
                                    : Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                            leading: Text(
                              country.flag,
                              style: const TextStyle(fontSize: 22),
                            ),
                            title: Text(
                              isChineseLocale ? country.name : country.nameEn,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: Text(
                              country.dialCode,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onTap: () {
                              onCountryChanged(country);
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
