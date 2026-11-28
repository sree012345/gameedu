import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/widgets/base/base_textfield.dart';
import 'package:game_edu/core/widgets/buttons/medium_button.dart';
import 'package:game_edu/student_module/classes/presentation/widgets/gradient_header.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/faq_bloc.dart';
import '../models/faq_item.dart';

/// Help centre: search, chips (All / Classes / Chat / Events), questions
/// that open and close, and a "Contact Support" card.
///
///   Navigator.of(context).push(
///     MaterialPageRoute(builder: (_) => const FaqPage()));
///
/// [onContactSupport] replaces the default (opens the e-mail app with
/// [supportEmail]).
class FaqPage extends StatelessWidget {
  const FaqPage({
    super.key,
    this.supportEmail = 'support@gameedu.com', // <- put your real address
    this.onContactSupport,
  });

  final String supportEmail;
  final VoidCallback? onContactSupport;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FaqBloc>(
      create: (_) => FaqBloc()..add(const FaqStarted()),
      child: _FaqView(
        supportEmail: supportEmail,
        onContactSupport: onContactSupport,
      ),
    );
  }
}

class _FaqView extends StatefulWidget {
  const _FaqView({required this.supportEmail, required this.onContactSupport});

  final String supportEmail;
  final VoidCallback? onContactSupport;

  @override
  State<_FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<_FaqView> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _contactSupport() async {
    if (widget.onContactSupport != null) {
      widget.onContactSupport!();
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri(
      scheme: 'mailto',
      path: widget.supportEmail,
      queryParameters: {'subject': 'Game Edu support'},
    );

    try {
      final opened = await launchUrl(uri);
      if (!opened) throw Exception('no mail app');
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Write to us at ${widget.supportEmail}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearSearch() {
    _search.clear();
    context.read<FaqBloc>().add(const FaqSearchChanged(''));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppPalette.authCardSurfaceColor,
      body: Column(
        children: [
          GradientHeader(
            title: 'FAQs',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: BlocBuilder<FaqBloc, FaqState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 28 + bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'How can we help?',
                        style: TextStyle(
                          fontSize: 24,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          color: AppPalette.authTextPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Find answers about classes, chat and events.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppPalette.authTextSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _CategoryChips(selected: state.category),
                      const SizedBox(height: 22),
                      const Text(
                        'Frequently Asked Questions',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppPalette.authTextPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ..._list(context, state),
                      const SizedBox(height: 14),
                      _SupportCard(onTap: _contactSupport),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _list(BuildContext context, FaqState state) {
    switch (state.status) {
      case FaqStatus.loading:
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(child: CircularProgressIndicator()),
          ),
        ];

      case FaqStatus.failure:
        return [
          _EmptyMessage(
            icon: Icons.cloud_off_outlined,
            text: 'Could not load the FAQs',
            actionLabel: 'Retry',
            onAction: () => context.read<FaqBloc>().add(const FaqStarted()),
          ),
        ];

      case FaqStatus.loaded:
        final items = state.visible;

        if (items.isEmpty) {
          return [
            _EmptyMessage(
              icon: Icons.search_off_rounded,
              text: 'No questions found',
              actionLabel: state.query.isEmpty ? null : 'Clear search',
              onAction: state.query.isEmpty ? null : _clearSearch,
            ),
          ];
        }

        return [
          for (final item in items)
            _FaqTile(
              item: item,
              expanded: state.expandedId == item.id,
              onTap: () => context.read<FaqBloc>().add(FaqToggled(item.id)),
            ),
        ];
    }
  }
}

// ───────────────────────── search ─────────────────────────

// ───────────────────────── chips ─────────────────────────

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected});

  /// null = All
  final FaqCategory? selected;

  static const List<FaqCategory?> _chips = [
    null,
    FaqCategory.classes,
    FaqCategory.chat,
    FaqCategory.events,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final chip in _chips) ...[
            _Chip(
              label: chip == null ? 'All' : chip.label,
              selected: selected == chip,
              onTap: () =>
                  context.read<FaqBloc>().add(FaqCategorySelected(chip)),
            ),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppPalette.primaryBlue : AppPalette.authCardSurfaceColor,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected
              ? AppPalette.primaryBlue
              : AppPalette.primaryBlue.withValues(alpha: 0.25),
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: selected
                  ? AppPalette.white
                  : AppPalette.authTextPrimaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── question ─────────────────────────

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.item,
    required this.expanded,
    required this.onTap,
  });

  final FaqItem item;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: expanded
            ? AppPalette.primaryBlue.withValues(alpha: 0.07)
            : AppPalette.authCardSurfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppPalette.primaryBlue.withValues(alpha: expanded ? 0.35 : 0.22),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(item.icon, size: 34, color: AppPalette.primaryBlue),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item.question,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                          color: AppPalette.authTextPrimaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 30,
                        color: AppPalette.primaryBlue,
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: expanded
                      ? Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(
                                height: 1,
                                color: AppPalette.primaryBlue.withValues(
                                  alpha: 0.18,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text(
                                  item.answer,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: AppPalette.authTextSecondaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── support / empty ─────────────────────────

class _SupportCard extends StatelessWidget {
  const _SupportCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.headset_mic_outlined,
                  size: 40,
                  color: AppPalette.primaryBlue,
                ),
              ),
              Container(
                width: 1,
                height: 44,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: AppPalette.primaryBlue.withValues(alpha: 0.2),
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Still need help?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppPalette.authTextPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Get in touch with our support team.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppPalette.authTextSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          MediumButton(text: 'Contact Support', onPressed: onTap),
        ],
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(icon, size: 44, color: AppPalette.primaryBlue),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppPalette.authTextSecondaryColor,
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
