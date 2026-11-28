import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/init_dependencies.dart';

import '../../bloc/participant_picker/participant_picker_bloc.dart';
import '../community_theme.dart';
import '../widgets/community_avatar.dart';
import '../widgets/community_header.dart';

/// Pops with the selected user ids (`List<String>`) when the user taps Done.
class ParticipantPickerScreen extends StatelessWidget {
  const ParticipantPickerScreen({
    super.key,
    this.excludeIds = const {},
    this.initialSelected = const {},
    this.title = 'Select participants',
  });

  final Set<String> excludeIds;
  final Set<String> initialSelected;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<ParticipantPickerBloc>()..add(ParticipantPickerStarted(
          excludeIds: excludeIds,
          initialSelected: initialSelected,
        )),
      child: _PickerView(title: title),
    );
  }
}

class _PickerView extends StatelessWidget {
  const _PickerView({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommunityColors.background,
      body: BlocBuilder<ParticipantPickerBloc, ParticipantPickerState>(
        builder: (context, state) {
          return Column(
            children: [
              CommunityHeader(
                title: title,
                subtitle: '${state.selectedIds.length} selected',
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: TextField(
                  onChanged: (q) => context
                      .read<ParticipantPickerBloc>()
                      .add(ParticipantPickerQueryChanged(q)),
                  decoration: InputDecoration(
                    hintText: 'Search people',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: CommunityColors.primary),
                    filled: true,
                    fillColor: CommunityColors.soft,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: CommunityColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: CommunityColors.border),
                    ),
                  ),
                ),
              ),
              Expanded(child: _buildList(context, state)),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CommunityColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () =>
                          Navigator.of(context).pop(state.selectedIds.toList()),
                      child: Text(
                        'Done (${state.selectedIds.length})',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, ParticipantPickerState state) {
    switch (state.status) {
      case ParticipantPickerStatus.initial:
      case ParticipantPickerStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case ParticipantPickerStatus.failure:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              state.errorMessage ?? 'Could not load users.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: CommunityColors.subtitle),
            ),
          ),
        );

      case ParticipantPickerStatus.success:
        final users = state.visibleUsers;
        if (users.isEmpty) {
          return const Center(
            child: Text('No users found',
                style: TextStyle(color: CommunityColors.subtitle)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final selected = state.selectedIds.contains(user.id);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: communityBorder,
              ),
              child: CheckboxListTile(
                value: selected,
                activeColor: CommunityColors.primary,
                controlAffinity: ListTileControlAffinity.trailing,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                secondary: CommunityUserAvatar(
                    name: user.name, photoUrl: user.photoUrl),
                title: Text(
                  user.name,
                  style: const TextStyle(
                    color: CommunityColors.title,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onChanged: (_) => context
                    .read<ParticipantPickerBloc>()
                    .add(ParticipantPickerToggled(user.id)),
              ),
            );
          },
        );
    }
  }
}
