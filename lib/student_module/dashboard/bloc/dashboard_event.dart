part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load the user (name, email, college) from Firebase.
final class DashboardStarted extends DashboardEvent {
  const DashboardStarted();
}

/// Bottom navigation tap.
final class DashboardTabChanged extends DashboardEvent {
  const DashboardTabChanged(this.index);
  final int index;

  @override
  List<Object?> get props => [index];
}

/// Left menu item tap.
final class DashboardMenuSelected extends DashboardEvent {
  const DashboardMenuSelected(this.item);
  final DashboardMenu item;

  @override
  List<Object?> get props => [item];
}

/// Open a named route (quick actions, "View all", bell...).
final class DashboardRouteRequested extends DashboardEvent {
  const DashboardRouteRequested(this.route);
  final String route;

  @override
  List<Object?> get props => [route];
}

/// User pressed "Logout" in the confirm popup.
final class DashboardLogoutConfirmed extends DashboardEvent {
  const DashboardLogoutConfirmed();
}
