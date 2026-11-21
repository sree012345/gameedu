import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/core/routes/router_path.dart';

import '../models/dashboard_user.dart';
import '../services/dashboard_service.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

/// Drives the dashboard, bottom navigation and the left menu.
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({required DashboardService service})
    : _service = service,
      super(const DashboardState()) {
    on<DashboardStarted>(_onStarted);
    on<DashboardTabChanged>(_onTabChanged);
    on<DashboardMenuSelected>(_onMenuSelected);
    on<DashboardRouteRequested>((e, emit) => _go(emit, e.route));
    on<DashboardLogoutConfirmed>(_onLogoutConfirmed);
  }

  final DashboardService _service;

  Future<void> _onStarted(
    DashboardStarted event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final user = await _service.loadUser();
      if (emit.isDone) return;

      if (user == null) {
        // Session lost -> back to login.
        emit(state.copyWith(status: DashboardStatus.loggedOut));
        return;
      }
      emit(state.copyWith(status: DashboardStatus.loaded, user: user));
    } catch (_) {
      if (emit.isDone) return;
      emit(state.copyWith(status: DashboardStatus.loaded));
    }
  }

  void _onTabChanged(DashboardTabChanged event, Emitter<DashboardState> emit) {
    if (event.index < 0 || event.index >= DashboardTab.count) return;
    emit(state.copyWith(tabIndex: event.index));
  }

  void _onMenuSelected(
    DashboardMenuSelected event,
    Emitter<DashboardState> emit,
  ) {
    switch (event.item) {
      // Items that live in the bottom navigation -> just switch the tab
      case DashboardMenu.home:
        emit(state.copyWith(tabIndex: DashboardTab.home));
      case DashboardMenu.courses:
        emit(state.copyWith(tabIndex: DashboardTab.courses));
      case DashboardMenu.events:
        emit(state.copyWith(tabIndex: DashboardTab.events));
      case DashboardMenu.profile:
        emit(state.copyWith(tabIndex: DashboardTab.profile));
      // Everything else opens its own screen
      case DashboardMenu.careers:
        _go(emit, RouterPath.careers);
      case DashboardMenu.myLearning:
        _go(emit, RouterPath.myLearning);
      case DashboardMenu.chat:
        _go(emit, RouterPath.message);
      case DashboardMenu.help:
        _go(emit, RouterPath.helpSupport);
      case DashboardMenu.about:
        _go(emit, RouterPath.aboutApp);
       
        
    }
  }

  Future<void> _onLogoutConfirmed(
    DashboardLogoutConfirmed event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.status == DashboardStatus.loggingOut) return;

    emit(state.copyWith(status: DashboardStatus.loggingOut));
    try {
      await _service.signOut();
      if (emit.isDone) return;
      emit(state.copyWith(status: DashboardStatus.loggedOut));
    } catch (_) {
      if (emit.isDone) return;
      emit(state.copyWith(status: DashboardStatus.loaded));
      _showMessage(emit, 'Could not log out. Please try again.');
    }
  }

  // ───────────── one-shot helpers ─────────────

  void _go(Emitter<DashboardState> emit, String route) {
    emit(state.copyWith(route: route));
    emit(state.copyWith(clearRoute: true));
  }

  void _showMessage(Emitter<DashboardState> emit, String message) {
    emit(state.copyWith(message: message));
    emit(state.copyWith(clearMessage: true));
  }
}
