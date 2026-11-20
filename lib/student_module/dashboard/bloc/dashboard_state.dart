part of 'dashboard_bloc.dart';

enum DashboardStatus {
  loading,
  loaded,
  loggingOut,

  /// One-shot trigger: go back to the login screen.
  loggedOut,
}

/// Items of the left menu.
enum DashboardMenu {
  home,
  careers,
  courses,
  myLearning,
  events,
  chat,
  profile,
  help,
  about,
}

/// Bottom navigation indexes.
abstract final class DashboardTab {
  static const int home = 0;
  static const int courses = 1;
  static const int events = 2;
  static const int community = 3;
  static const int profile = 4;
  static const int count = 5;
}

final class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.loading,
    this.user,
    this.tabIndex = DashboardTab.home,
    this.unreadChatCount = 0,
    this.route,
    this.message,
  });

  final DashboardStatus status;
  final DashboardUser? user;
  final int tabIndex;

  /// Red badge on "Chat" in the left menu (hidden when 0).
  final int unreadChatCount;

  /// One-shot: named route to open.
  final String? route;

  /// One-shot: snackbar text.
  final String? message;

  /// Which left-menu item is highlighted for the current tab.
  DashboardMenu? get selectedMenu => switch (tabIndex) {
    DashboardTab.home => DashboardMenu.home,
    DashboardTab.courses => DashboardMenu.courses,
    DashboardTab.events => DashboardMenu.events,
    DashboardTab.profile => DashboardMenu.profile,
    _ => null,
  };

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardUser? user,
    int? tabIndex,
    int? unreadChatCount,
    String? route,
    String? message,
    bool clearRoute = false,
    bool clearMessage = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      user: user ?? this.user,
      tabIndex: tabIndex ?? this.tabIndex,
      unreadChatCount: unreadChatCount ?? this.unreadChatCount,
      route: clearRoute ? null : (route ?? this.route),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    tabIndex,
    unreadChatCount,
    route,
    message,
  ];
}
