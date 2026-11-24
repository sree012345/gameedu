import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/widgets/base/base_textfield.dart';
import 'package:game_edu/init_dependencies.dart'; // exports serviceLocator

import '../bloc/classes_bloc.dart';
import '../models/class_item.dart';
import 'widgets/class_card.dart';
import 'class_detail_page.dart';

/// Body of the dashboard "Classes" tab (the header and the bottom bar
/// come from the dashboard).
class ClassesTab extends StatelessWidget {
  const ClassesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClassesBloc>(
      create: (_) => serviceLocator<ClassesBloc>()..add(const ClassesStarted()),
      child: const _ClassesView(),
    );
  }
}

class _ClassesView extends StatelessWidget {
  const _ClassesView();

  Future<void> _pickTopic(BuildContext context, ClassesState state) async {
    final bloc = context.read<ClassesBloc>();

    // '' = All Topics (null can't be returned from a sheet)
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppPalette.transparentColor,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: AppPalette.authCardSurfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                'Filter by topic',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.authTextPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final topic in ['', ...state.topics])
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          topic.isEmpty
                              ? 'All Topics'
                              : ClassItem.topicToLabel(topic),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppPalette.authTextPrimaryColor,
                          ),
                        ),
                        trailing: (state.topic ?? '') == topic
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppPalette.successColor,
                              )
                            : null,
                        onTap: () => Navigator.of(ctx).pop(topic),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (picked != null) {
      bloc.add(ClassesTopicSelected(picked.isEmpty ? null : picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassesBloc, ClassesState>(
      builder: (context, state) {
        final bloc = context.read<ClassesBloc>();
        final visible = state.visible;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: _ViewSwitch(
                selected: state.view,
                onChanged: (v) => bloc.add(ClassesViewChanged(v)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: BaseTextfield(
                hintText: 'Search classes',
                textInputAction: TextInputAction.search,
                onChanged: (v) => bloc.add(ClassesSearchChanged(v)),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppPalette.inputIconColor,
                  size: 24,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${visible.length} ${visible.length == 1 ? 'class' : 'classes'}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppPalette.authTextPrimaryColor,
                      ),
                    ),
                  ),
                  _TopicFilter(
                    label: state.topic == null
                        ? 'All Topics'
                        : ClassItem.topicToLabel(state.topic!),
                    onTap: () => _pickTopic(context, state),
                  ),
                ],
              ),
            ),
            Expanded(child: _Content(state: state, visible: visible)),
          ],
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state, required this.visible});

  final ClassesState state;
  final List<ClassItem> visible;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ClassesBloc>();

    if (state.status == ClassesStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == ClassesStatus.failure) {
      return _Message(
        icon: Icons.cloud_off_outlined,
        title: state.error ?? 'Could not load classes',
        isError: true,
        actionLabel: 'Retry',
        onAction: () => bloc.add(const ClassesStarted()),
      );
    }

    if (visible.isEmpty) {
      return _Message(
        icon: state.view == ClassesView.mine
            ? Icons.bookmark_border_rounded
            : Icons.search_off_rounded,
        title: state.view == ClassesView.mine
            ? 'No classes joined yet'
            : 'No classes found',
        subtitle: state.view == ClassesView.mine
            ? 'Classes you join will show up here.'
            : 'Try a different search or topic.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        bloc.add(const ClassesRefreshed());
        await bloc.stream.firstWhere((s) => !s.refreshing);
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: visible.length,
        itemBuilder: (context, i) => ClassCard(
          item: visible[i],
          onView: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ClassDetailPage(item: visible[i]),
            ),
          ),
        ),
      ),
    );
  }
}

/// "All Classes | My Classes"
class _ViewSwitch extends StatelessWidget {
  const _ViewSwitch({required this.selected, required this.onChanged});

  final ClassesView selected;
  final ValueChanged<ClassesView> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget item(ClassesView view, String label) {
      final isSelected = view == selected;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(view),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppPalette.authCardSurfaceColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              boxShadow: isSelected ? classCardShadow() : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? AppPalette.primaryBlue
                    : AppPalette.authTextSecondaryColor,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppPalette.inputBorderColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          item(ClassesView.all, 'All Classes'),
          item(ClassesView.mine, 'My Classes'),
        ],
      ),
    );
  }
}

class _TopicFilter extends StatelessWidget {
  const _TopicFilter({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.55,
      ),
      child: Material(
        color: AppPalette.authCardSurfaceColor,
        shape: const StadiumBorder(),
        elevation: 0,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.tune_rounded, size: 20, color: AppPalette.primaryBlue),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.primaryBlueDark,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 22,
                  color: AppPalette.primaryBlueDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isError = false,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isError;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPalette.primaryBlue.withValues(alpha: 0.10),
              ),
              child: Icon(icon, size: 40, color: AppPalette.primaryBlue),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isError
                    ? AppPalette.errorText
                    : AppPalette.authTextPrimaryColor,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppPalette.authTextSecondaryColor,
                ),
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: 10),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
