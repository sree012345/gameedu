import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/utils/app_utils.dart';
import 'package:game_edu/core/widgets/popup/es_dialog_box.dart';

import '../cubit/language_cubit.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool smallScreen;
  const LanguageSwitcher({super.key ,  this.smallScreen=false});

  static const _languages = [
    {'code': 'en', 'native': 'English', 'english': 'English', 'short': 'EN'},
    {'code': 'ta', 'native': 'தமிழ்', 'english': 'Tamil', 'short': 'த'},
    {'code': 'te', 'native': 'తెలుగు', 'english': 'Telugu', 'short': 'తె'},
    {'code': 'kn', 'native': 'ಕನ್ನಡ', 'english': 'Kannada', 'short': 'ಕ'},
    {'code': 'hi', 'native': 'हिन्दी', 'english': 'Hindi', 'short': 'हि'},
    {'code': 'ml', 'native': 'മലയാളം', 'english': 'Malayalam', 'short': 'മ'},
  ];

  void _showPicker(BuildContext context, Locale currentLocale) {
    EsDialogBox.show(
      context: context,
      barrierDismissible: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'language.choose_language'.tr(),
            style: const TextStyle(
              color: AppPalette.textPrimaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'language.select_language'.tr(),
            style: const TextStyle(
              color: AppPalette.textSecondaryColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),

          // Language list
          ..._languages.map((lang) {
            final isSelected = currentLocale.languageCode == lang['code'];
            return _LanguageTile(
              native: lang['native']!,
              english: lang['english']!,
              isSelected: isSelected,
              onTap: () {
                Navigator.pop(context);
                context.read<LanguageCubit>().changeLanguage(
                  Locale(lang['code']!),
                  context,
                );
              },
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;
    final currentLang = _languages.firstWhere(
      (l) => l['code'] == currentLocale.languageCode,
      orElse: () => _languages.first,
    );

    return AppUtils.clickable(
      onTap: () => _showPicker(context, currentLocale),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppPalette.cardSurfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppPalette.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(!smallScreen)
            const Icon(
              Icons.language_rounded,
              color: AppPalette.textPrimaryColor,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              currentLang['short']!,
              style: const TextStyle(
                color: AppPalette.textPrimaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppPalette.textSecondaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String native;
  final String english;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.native,
    required this.english,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
        mouseCursor: SystemMouseCursors.click,
        hoverColor: AppPalette.elevatedSurfaceColor.withAlpha(40),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: isSelected
                ? AppPalette.elevatedSurfaceColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  native,
                  style: const TextStyle(
                    color: AppPalette.textPrimaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  english,
                  style: const TextStyle(
                    color: AppPalette.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                color: AppPalette.primaryAccent,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
