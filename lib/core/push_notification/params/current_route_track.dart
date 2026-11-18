import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CurrentRouteTracker extends NavigatorObserver {
  static String currentRoute = '/';
    static String currentRouteFull = '/';  // ✅ Added
  static Map<String, dynamic>? currentArguments;  // ✅ Added
    static String? previousRoute;              // ✅ NEW — tracks what was before current
  static String? previousRouteFull;     
  static const _channel = MethodChannel('com.esportcircle/route_sync');

  @override
  void didPush(Route route, Route? previousRoute) =>
      _update(route, previousRoute);

  @override
  void didPop(Route route, Route? previousRoute) =>
      _update(previousRoute, route); // after pop, `route` (popped) becomes the "previous"

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) =>
      _update(newRoute, oldRoute);

 void _update(Route? route, Route? prevRoute) {
    final name = route?.settings.name;
    if (name != null && name.isNotEmpty) {
      // Shift current → previous BEFORE overwriting current
      previousRoute = currentRoute;
      previousRouteFull = currentRouteFull;

      currentRoute = name;
      currentRouteFull = name;

      try {
        final args = route?.settings.arguments;
        if (args is Map<String, dynamic>) {
          currentArguments = args;
        } else {
          currentArguments = null;
        }
      } catch (e) {
        currentArguments = null;
      }

      _syncToNative(name);
    }
  }

  void _syncToNative(String route) {
    if (!kIsWeb && Platform.isIOS) {
      _channel.invokeMethod('updateRoute', {'route': route}).catchError((_) {});
    }
  }
}

final currentRouteTracker = CurrentRouteTracker();

// class DashboardPopObserver extends NavigatorObserver {
//   final BuildContext Function() contextGetter;

//   DashboardPopObserver(this.contextGetter);

//   @override
//   void didPop(Route route, Route? previousRoute) {
//     super.didPop(route, previousRoute);

//     final context = contextGetter();
//     final cubit = context.read<DashboardNavigationCubit>();
//     final menus = cubit.state.menus;
//     if (menus.isEmpty) return;

//     final homeMenu = menus.firstWhere(
//       (m) => m.routeName == RouterPath.home,
//       orElse: () => menus.first,
//     );

//     cubit.selectMenu(homeMenu); // 👈 resets left menu to home on any pop
//   }
// }