import 'package:flutter/material.dart';
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
    return InkWell(
      onTap: enabled ? () => _showCountryPicker(context) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            right: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedCountry.flag,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 4),
            Text(
              selectedCountry.dialCode,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (enabled) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: Theme.of(context).iconTheme.color,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isChineseLocale = Localizations.localeOf(context).languageCode == 'zh';
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localizations.auth_select_country_region ?? 'Select Country/Region',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: CountryCodes.commonCountries.length,
                  itemBuilder: (context, index) {
                    final country = CountryCodes.commonCountries[index];
                    final isSelected = country.code == selectedCountry.code;
                    
                    return ListTile(
                      leading: Text(
                        country.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        isChineseLocale ? country.name : country.nameEn,
                      ),
                      trailing: Text(
                        country.dialCode,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      onTap: () {
                        onCountryChanged(country);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}