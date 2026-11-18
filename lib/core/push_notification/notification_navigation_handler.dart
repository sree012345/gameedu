import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/core/push_notification/notification_cold_start_handler.dart';
import 'package:game_edu/core/responsive/responsive_sizes.dart';
import 'package:game_edu/core/routes/router_path.dart';
import 'package:game_edu/main.dart';



class NotificationNavigationHandler {
  NotificationNavigationHandler._();

  static String _normalizeRoute(String? raw) {
    switch (raw) {
      case 'connection':
      case 'connections':
        return 'connection';
      case 'chat':
      case 'message':
        return 'chat';
      case 'post':
      case 'post_detail':
        return 'post_detail';
      case 'profile':
        return 'profile';
      case 'liveStream':
      case 'live_stream':
        return 'liveStream';
      case 'missed_call':
        return 'missed_call';
      case 'class_detail':
        return 'class_detail';
      case 'fixture_detail':
        return 'fixture_detail';
      case 'member_request':
        return 'member_request';
      case 'user_member_request':
        return 'user_member_request';
      case 'teams':
        return 'teams';
      default:
        return raw ?? '';
    }
  }

  static void handle(Map<String, dynamic> data, String? route) {
    final context = rootNavKey.currentContext;

    if (context == null) {
      NotificationColdStartHandler.isFromColdStartNotification = true;
      NotificationColdStartHandler.pendingData = data;
      return;
    }

    Map<String, dynamic> payload = {};
    try {
      if (data['payload'] != null) {
        payload = jsonDecode(data['payload']);
      }
    } catch (_) {}

    final normalizedRoute = _normalizeRoute(route);
    debugPrint('🔔 raw route=$route → normalized=$normalizedRoute');
    switch (normalizedRoute) {
      case 'profile':
        Map<String, dynamic> profilePayload = payload;

        // Handle nested payload
        if (payload['payload'] is String) {
          profilePayload = jsonDecode(payload['payload']);
        }

        final userId = profilePayload['userId'];

        if (userId == null || userId.isEmpty) {
          debugPrint('❌ Profile notification missing userId');
          return;
        }

        rootNavKey.currentState?.pushNamed(
          Uri(
            path: RouterPath.publicProfile,
            queryParameters: {'userId': userId},
          ).toString(),
        );
        break;
      case 'post_detail':
        final postId = (data['clickAction'] as String?)?.isNotEmpty == true
            ? data['clickAction'] as String
            : (data['postId'] as String?)?.isNotEmpty == true
            ? data['postId'] as String
            : payload['postId'] as String?;

        debugPrint('🔔 postId from clickAction: ${data['clickAction']}');
        debugPrint('🔔 postId from data: ${data['postId']}');
        debugPrint('🔔 postId from payload: ${payload['postId']}');
        debugPrint('🔔 final postId: $postId');

        if (postId == null || postId.isEmpty) {
          debugPrint('🔔 postId is null — going home');
          rootNavKey.currentState?.pushNamed(RouterPath.home);
          return;
        }
        rootNavKey.currentState?.pushNamed(
          '${RouterPath.postDetail}?postId=$postId',
        );
        break;

      case 'chat':
      case "message":
        final isGroup =
            payload['isGroup'] == true || payload['isGroup'] == 'true';
        final isTeamChat =
            payload['isTeamChat'] == true || payload['isTeamChat'] == 'true';
        final chatId = isGroup
            ? payload['chatId'] as String?
            : payload['senderId'] as String?;
        final profilePic = payload['profilePic'] as String? ?? '';
        final handleName = payload['handleName'] as String? ?? '';
        final profileName = payload['profileName'] as String? ?? '';
        final device = ResponsiveSizes.whichDevice();
        final isLarge =
            device != ResponsiveSizes.mobile &&
            device != ResponsiveSizes.tablet;

        // 👇 use team route if isTeamChat, else normal direct message route
        final basePath = isTeamChat
            ? RouterPath.directMessageTeams
            : RouterPath.directMessage;

        final chatRoute =
            '$basePath'
            '?:=$chatId'
            '&n=${Uri.encodeComponent(profileName)}'
            '&pf=${Uri.encodeComponent(profilePic)}'
            '&hn=${Uri.encodeComponent(handleName)}'
            '&isGroupChat=$isGroup'
            '&isLarge=$isLarge';

        debugPrint('🔔 [chat/message] isGroup: $isGroup');
        debugPrint('🔔 [chat/message] isTeamChat: $isTeamChat');
        debugPrint('🔔 [chat/message] chatId: $chatId');
        debugPrint('🔔 [chat/message] basePath: $basePath');
        debugPrint('🔔 [chat/message] full route: $chatRoute');

        rootNavKey.currentState?.pushNamed(chatRoute);
        break;
      case 'order':
        rootNavKey.currentState?.pushNamed('/order', arguments: payload);
        break;

      case 'liveStream':
       final payload = data['payload'];

  if (payload == null) {
    debugPrint('Live stream notification missing payload');
    return;
  }

  final Map<String, dynamic> payloadData = jsonDecode(payload);
  final channelId = payloadData['streamerId'];

  if (channelId == null || channelId.toString().isEmpty) {
    debugPrint('Live stream notification missing streamerId');
    return;
  }



  rootNavKey.currentState?.pushNamed(
    '${RouterPath.channel}?channelId=$channelId',
  );
  break;

      // case 'profile':
      //   rootNavKey.currentState?.pushNamed('/profile', arguments: payload);

      //   break;
      // case 'connection':
      //   rootNavKey.currentState?.pushNamed(
      //     RouterPath.connections,
      //     arguments: payload,
      //   );

      //   break;
 

      case 'user_member_request':
        final uid = payload['uid'] ?? data['uid'];

        rootNavKey.currentState?.pushNamed(
          '${RouterPath.userMemberRequest}?uid=$uid',
        );
        break;
      case 'member_request':
        final teamId = payload['teamId'] ?? data['teamId'];

        final index = payload['index'] ?? data['index'] ?? 0;

        rootNavKey.currentState?.pushNamed(
          '/member_request?teamId=$teamId&index=$index',
        );

        break;
      // case 'teams':
      //   // final teamId = payload['teamId'] ?? data['teamId'];

      //   // rootNavKey.currentState?.pushNamed('/teams?teamId=$teamId');
      //   rootNavKey.currentState?.pushNamed('/teams');

      //   break;
      case 'teams':
        final navState = rootNavKey.currentState;
        if (navState == null) break;

        bool teamsAlreadyInStack = false;
        navState.popUntil((r) {
          if (r.settings.name == RouterPath.teams) {
            teamsAlreadyInStack = true;
            return true; // stop popping — we're back on Teams
          }
          // Safety stop so we never pop past Home / the root route
          return r.isFirst || r.settings.name == RouterPath.home;
        });

        if (!teamsAlreadyInStack) {
          navState.pushNamed(RouterPath.teams);
        } else {
          // Teams page instance already existed — its initState won't
          // re-run, so force a refresh so it isn't showing stale data
          // from before the invite/decline happened.
          final context = rootNavKey.currentContext;
          if (context != null) {
  
          }
        }
        break;
      case 'missed_call':
        // final callId = payload['callId'] ?? data['callId'];
        final callerId = payload['callerId'] ?? data['callerId'];
        final callerName = payload['callerName'] ?? data['callerName'];
        final callerPic = payload['callerPic'] ?? data['callerPic'] ?? '';
        final isAudioOnly =
            payload['isAudioOnly'] == true || data['isAudioOnly'] == true;

        debugPrint(
          "🔔 Missed call notification tapped - calling back: $callerName",
        );

     

  
      case "/meetings":
        rootNavKey.currentState?.pushNamed(
          RouterPath.meetings,
          arguments: payload,
        );
        break;
    case 'class_detail':
        debugPrint('🔔 → case: class_detail');
        debugPrint('🔔   data[clickAction]: ${data['clickAction']}');
        debugPrint('🔔   data[classId]:     ${data['classId']}');
        debugPrint('🔔   payload[classId]:  ${payload['classId']}');
        final classId = (data['clickAction'] as String?)?.isNotEmpty == true
            ? data['clickAction'] as String
            : (data['classId'] as String?)?.isNotEmpty == true
            ? data['classId'] as String
            : payload['classId'] as String?;
        debugPrint('🔔   final classId: $classId');
        if (classId == null || classId.isEmpty) {
          debugPrint('🔔 ❌ classId is null/empty — navigating home');
          rootNavKey.currentState?.pushNamed(RouterPath.home);
          break;
        }
        // ── Step 1: Build the full deep-link URL ──────────────────────────────
        final classDetailUrl = '${RouterPath.classDetail}?classId=$classId';
        debugPrint(
          '🔔 ✅ switching to coach section then pushing: $classDetailUrl',
        );
        // ── Step 2: Update browser URL (web) ────────────────────────────────────
        SystemNavigator.routeInformationUpdated(uri: Uri.parse(classDetailUrl));
        // ── Step 3: Navigate root navigator to the coach section ────────────────
        // This makes the dashboard render CoachSectionWrapper as the body.
        // We use pushNamed with the coach route so CoachSectionWrapper
        // initialises with the classDetail URL as its initialRoute,
        // which causes it to open ClassDetailPage directly.
        rootNavKey.currentState?.pushNamed(classDetailUrl);
        break;

      case 'fixture_detail':
        debugPrint('🔔 → case: fixture_detail');
        debugPrint('🔔   data[clickAction]:   ${data['clickAction']}');
        debugPrint('🔔   data[fixtureId]:     ${data['fixtureId']}');
        debugPrint('🔔   data[tournamentId]:  ${data['tournamentId']}');
        final fixtureId = (data['clickAction'] as String?)?.isNotEmpty == true
            ? data['clickAction'] as String
            : (data['fixtureId'] as String?)?.isNotEmpty == true
            ? data['fixtureId'] as String
            : payload['fixtureId'] as String?;
        final tournamentId =
            (data['tournamentId'] as String?)?.isNotEmpty == true
            ? data['tournamentId'] as String
            : payload['tournamentId'] as String?;
        debugPrint(
          '🔔   final fixtureId: $fixtureId, tournamentId: $tournamentId',
        );
        if (tournamentId == null || tournamentId.isEmpty) {
          debugPrint('🔔 ❌ tournamentId is null/empty — navigating home');
          rootNavKey.currentState?.pushNamed(RouterPath.home);
          break;
        }
        // ── Build the full deep-link URL ──────────────────────────────────────
        final viewFixtureUrl =
            '${RouterPath.viewFixture}?tournamentId=$tournamentId&isPublished=true';
        debugPrint(
          '🔔 ✅ switching to tournaments section then pushing: $viewFixtureUrl',
        );
        // ── Update browser URL (web) ────────────────────────────────────────────
        SystemNavigator.routeInformationUpdated(uri: Uri.parse(viewFixtureUrl));
        // ── Navigate root navigator to the tournaments section ────────────────
        // viewFixture wraps into DashboardPage(initialRoute: ...), which selects
        // the tournaments menu and TournamentSectionWrapper opens FixturesPage
        // directly using its own onGenerateRoute handling for viewFixture.
        rootNavKey.currentState?.pushNamed(viewFixtureUrl);
        break;

      default:
        debugPrint(
          '🔔 ⚠️ NO MATCHING CASE for route="$route" — falling to default → home',
        );
        debugPrint('🔔   full data dump: $data');
        rootNavKey.currentState?.pushNamed('/home');
    }
  }
}

// class NotificationNavigationHandler {
//   NotificationNavigationHandler._(); // private constructor

//   static void handle(Map<String, dynamic> data, String route) {
//     // if (data.isEmpty && LoginDetails.userId.isEmpty) return;

//     final context = rootNavKey.currentContext;
//     if (context == null) {
//       NotificationColdStartHandler.isFromColdStartNotification = true;
//       NotificationColdStartHandler.pendingData = data;
//       return;
//     }
//     // switch (route) {
//     //   case '/tournament_details':
//     //     _openTournamentDetails(context, data);
//     //     break;
//     //   case '/tournament_info':
//     //     _openTournamentInfo(context, data);
//     //     break;

//     //   case '/tournament_approval':
//     //     _openTournamentInfo(context, data);
//     //     // _openTournamentApproval(context, data);
//     //     break;

//     //   case '/pendingInvites':
//     //     rootNavKey.currentState?.pushNamed(RouterPath.joinTeamPendingInvite);
//     //     break;

//     //   case '/team_home':
//     //     _updateTeamIdAndNavigateToTeamHome(context, data);
//     //     break;

//     //   case '/player_pending_request':
//     //     rootNavKey.currentState?.pushNamed(RouterPath.playerPendingRequest);
//     //     break;

//     //   // In APP notification navigation
//     //   case 'messages':
//     //     rootNavKey.currentState?.pushNamed(RouterPath.message);
//     //     break;

//     //   case 'organizer':
//     //     rootNavKey.currentState?.pushNamed(RouterPath.message);
//     //     break;

//     //   case 'alert':
//     //     rootNavKey.currentState?.pushNamed(RouterPath.message);
//     //     break;

//     //   case 'tournament':
//     //     rootNavKey.currentState?.pushNamed(RouterPath.tournament);
//     //     break;

//     //   default:
//     //     debugPrint('Unhandled notification route: $route');
//     // }
//   }

//   // static void _openTournamentInfo(
//   //   BuildContext? context,
//   //   Map<String, dynamic> data,
//   // ) {
//   //   final String tournamentId = data['tournament_id'];

//   //   if (tournamentId.isEmpty) {
//   //     return;
//   //   }

//   //   context?.read<TournamentsBloc>().add(
//   //     LoadTournamentInfoEvent(id: tournamentId),
//   //   );

//   //   rootNavKey.currentState?.pushNamed(RouterPath.tournamentInfo);
//   // }

//   // static void _updateTeamIdAndNavigateToTeamHome(
//   //   BuildContext context,
//   //   Map<String, dynamic> data,
//   // ) {
//   //   final String teamId = data['team_id'];
//   //   if (teamId.isNotEmpty) {
//   //     // Update team ID in shared preferences
//   //     LoginDetails.updateTeamId(teamId).then((_) {
//   //       // After updating, navigate to the team home
//   //       rootNavKey.currentState?.pushNamed(RouterPath.teamHome);
//   //     });
//   //   }
//   // }

//   // static void _openTournamentDetails(
//   //   BuildContext? context,
//   //   Map<String, dynamic> data,
//   // ) {
//   //   final String tournamentId = data['tournament_id'];
//   //   if (tournamentId.isEmpty) {
//   //     return;
//   //   }
//   //   final String tournamentDataString =
//   //       data['tournament_data']; // this is a String
//   //   Map<String, dynamic> tournamentData = jsonDecode(tournamentDataString);
//   //   final name = tournamentData["name"];
//   //   final logo = tournamentData["logo"];
//   //   final format = tournamentData["format"];

//   //   goToTournamentDetail(
//   //     context: context!,
//   //     tournamentId: tournamentId,
//   //     tournamentName: name ?? '',
//   //     tournamentLogo: logo ?? '',
//   //     formatType: format ?? '',
//   //   );
//   // }
// }
