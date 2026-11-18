import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/widgets/base/base_textfield.dart';
import '../../constants/auth_constants.dart';

/// Bottom sheet with a searchable college list. Returns the chosen name.
Future<String?> showCollegePickerSheet(
  BuildContext context, {
  String? selected,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppPalette.transparentColor,
    builder: (_) => _CollegePickerSheet(selected: selected),
  );
}

class _CollegePickerSheet extends StatefulWidget {
  const _CollegePickerSheet({this.selected});

  final String? selected;

  @override
  State<_CollegePickerSheet> createState() => _CollegePickerSheetState();
}

class _CollegePickerSheetState extends State<_CollegePickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colleges = AuthConstants.colleges
        .where((c) => c.toLowerCase().contains(_query.trim().toLowerCase()))
        .toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.65,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        decoration: const BoxDecoration(
          color: AppPalette.authCardSurfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppPalette.inputBorderColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select your college',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppPalette.authTextPrimaryColor,
              ),
            ),
            const SizedBox(height: 14),
            BaseTextfield(
              hintText: 'Search college',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppPalette.inputIconColor,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: colleges.isEmpty
                  ? const Center(
                      child: Text(
                        'No colleges found',
                        style: TextStyle(
                          color: AppPalette.authTextSecondaryColor,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: colleges.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        color: AppPalette.authDividerColor,
                      ),
                      itemBuilder: (context, index) {
                        final name = colleges[index];
                        final isSelected = name == widget.selected;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.school_outlined,
                            color: AppPalette.primaryBlue,
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppPalette.authTextPrimaryColor,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppPalette.successColor,
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(name),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
