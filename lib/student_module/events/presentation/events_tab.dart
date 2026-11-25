import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/init_dependencies.dart'; // exports serviceLocator
import 'package:game_edu/student_module/events/dev/events_seed_button.dart'; // TEMPORARY

import '../bloc/events_bloc.dart';
import 'widgets/event_card.dart';
import 'widgets/register_dialog.dart';

/// Body of the dashboard "Events" tab (header + bottom bar come from the
/// dashboard).
class EventsTab extends StatelessWidget {
  const EventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EventsBloc>(
      create: (_) => serviceLocator<EventsBloc>()..add(const EventsStarted()),
      child: const _EventsView(),
    );
  }
}

class _EventsView extends StatelessWidget {
  const _EventsView();

  Future<void> _register(BuildContext context, String id, String title) async {
    final bloc = context.read<EventsBloc>();

    final confirmed = await confirmEventRegistration(
      context,
      eventTitle: title,
    );
    if (confirmed) bloc.add(EventRegisterConfirmed(id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventsBloc, EventsState>(
      listenWhen: (p, c) => c.message != null && p.message != c.message,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(state.message!),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppPalette.authTextPrimaryColor,
            ),
          );
      },
      child: BlocBuilder<EventsBloc, EventsState>(
        builder: (context, state) {
          final bloc = context.read<EventsBloc>();

          return Column(
            children: [
            
              Expanded(child: _Content(state: state, bloc: bloc, onRegister: _register)),
            ],
          );
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.state,
    required this.bloc,
    required this.onRegister,
  });

  final EventsState state;
  final EventsBloc bloc;
  final Future<void> Function(BuildContext, String, String) onRegister;

  @override
  Widget build(BuildContext context) {
    if (state.status == EventsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == EventsStatus.failure) {
      return _Message(
        icon: Icons.cloud_off_outlined,
        title: state.error ?? 'Could not load events',
        isError: true,
        actionLabel: 'Retry',
        onAction: () => bloc.add(const EventsStarted()),
      );
    }

    if (state.events.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          bloc.add(const EventsRefreshed());
          await bloc.stream.firstWhere((s) => !s.refreshing);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 80),
            _Message(
              icon: Icons.event_busy_outlined,
              title: 'No upcoming events',
              subtitle: 'New events will show up here.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        bloc.add(const EventsRefreshed());
        await bloc.stream.firstWhere((s) => !s.refreshing);
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: state.events.length,
        itemBuilder: (context, i) {
          final event = state.events[i];

          return EventCard(
            event: event,
            registered: state.isRegistered(event.id),
            registering: state.registeringId == event.id,
            onRegister: () => onRegister(context, event.id, event.title),
          );
        },
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
      child: Padding(
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
