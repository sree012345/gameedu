/*
 * -----------------------------------------------------------------------------
 * File        : lib/core/routes/router_path.dart
 * Description : Route name constants used by the named-route navigation.
 * Author      : Revolution Games Private Limited
 * Created On  : 2025-12-18
 * Last Updated: 2025-12-18
 * -----------------------------------------------------------------------------
 * © 2025 Revolution Games Private Limited. All rights reserved.
 * -----------------------------------------------------------------------------
 *
 * Class       : RouterPath
 * Purpose     : Provide the routing paths
 * -----------------------------------------------------------------------------
 */

import 'package:flutter/material.dart';

class RouterPath {
  static const String authWrapper = '/';
  static const String welcome = '/entry';
  static const String loginStep = '/login';
  static const String adminLogin = '/admin_login';
  static const String splash = '/splash';
  static const String onBoarding = '/on_boarding';
  static const String onboardingStep = '/onboarding/step';
  static const String terms = '/terms';
  static const String resetPassword = '/resetPassword';
  static const String updateRequired = '/update_required';

  static const String home = '/home';
  static const String myProfile = '/my_profile';
  static const String editProfile = '/edit_profile';
  static const String publicProfile = '/publicProfile';
  static const String profileIntraction = '/profile_intraction';
  static const String gameProfile = '/game_profile';
  static const String settings = '/settings';
  static const String proPlan = '/proPlan';

  static const String explore = '/explore';
  static const String search = '/search';
  static const String live = '/live';
  static const String liveDiscover = '/live_discover';
  static const String goLive = '/go_live';
  static const String livePlayer = '/live_player';
  static const String broadcasterScreen = '/broadcaster_screen';
  static const String audienceScreen = '/audience_screen';
  static const String channel = '/channel';

  static const String createPost = '/create_post';
  static const String postDetail = '/post_detail';
  static const String savedPost = '/saved_post';
  static const String followList = '/follow_list';
  static const String viewComments = '/view_comments';
  static const String connections = '/connection';

  static const String shorts = '/shorts';
  static const String createShorts = '/create_shorts';
  static const String publishShorts = '/publish_shorts';
  static const String shortsDetail = '/shorts_detail';

  static const String message = '/messages';
  static const String directMessage = '/messages/directMessage';
  static const String directMessageTeams = '/teams/directMessage';
  static const String newChat = '/new_chat';
  static const String groupInfo = '/groupInfo';
  static const String createGroup = '/createGroup';
  static const String contactList = '/contactList';
  static const String notification = '/notification';
  static const String notificationSetting = '/notificationSetting';

  static const String meetings = '/meetings';
  static const String meeting = '/meeting';
  static const String createMeeting = '/createMeeting';
  static const String editMeeting = '/edit_meeting';
  static const String joinMeeting = '/join_meeting';
  static const String waitingRoom = '/waiting_room';
  static const String meetingRoom = '/meeting_room';
  static const String videoCall = '/videoCall';
  static const String recordingsList = '/recording_list';
  static const String recordingDetail = '/recording_detail';

  static const String tournaments = '/tournaments';
  static const String tournamentDetail = '/tournamentDetail';
  static const String createTournament = '/create_tournament';
  static const String editTournament = '/edit_tournament';
  static const String organizerDashboard = '/organizer_dashboard';
  static const String organizerManagement = '/organizer_management';
  static const String registrationsManager = '/registrationsManager';
  static const String announcements = '/announcements';
  static const String soloRegister = '/soloRegister';
  static const String soloChecing = '/soloCheckin';
  static const String chooseTeam = '/chooseTeam';
  static const String teamRegister = '/teamRegister';
  static const String teamCheckIn = '/teamCheckIn';
  static const String matchRoom = '/matchRoom';
  static const String createDispute = '/createDispute';
  static const String disputeResolution = '/disputeResolution';
  static const String reportScore = '/reportScore';
  static const String confirmScore = '/confirmScore';
  static const String bracketScreen = '/bracket';
  static const String fixture = '/fixture';
  static const String viewFixture = '/viewfixture';

  static const String teams = '/teams';
  static const String createTeam = '/createTeam';
  static const String editTeam = '/editTeam';
  static const String teamSearch = '/teamSearch';
  static const String teamPublicProfile = '/teamPublicProfile';
  static const String inviteMembers = '/invite_members';
  static const String memberRequest = '/member_request';
  static const String userMemberRequest = '/user_member_request';
  static const String rosterManagement = '/roster_management';

  static const String coach = '/coach';
  static const String coachProfile = '/coachProfile';
  static const String coachApproval = '/enrollment';
  static const String createClass = '/createClass';
  static const String editClass = '/editClass';
  static const String classDetail = '/classDetail';
  static const String calenderScreen = '/class_calender';
  static const String sessionLauncher = '/sessionLauncher';

  static const String jobs = '/jobs';
  static const String createjob = '/createjob';
  static const String jobsDetails = '/jobsDetails';
  static const String applyJob = '/applyJob';
  static const String applicationTracker = '/application_tracker';
  static const String jobManagement = '/job_management';
  static const String createTryout = '/createTryout';
  static const String registerTryout = '/register_tryout';
  static const String tryoutManagement = '/tryout_management';

  static const String moderationQueue = '/moderation_queue';
  static const String auditLogs = '/audit_logs';
  static const String userManagement = '/user_management';
  static const String reportDetail = '/report_detail';
  static const String auditReportDetail = '/audit_logs/report_detail';
  static const String adminJobManagement = '/admin_job_management';
  static const String brandListing = '/brand_listing';
  static const String brandDetail = '/brand_detail';

  static const List<String> mainScreens = [
    home,
    myProfile,
    explore,
    live,
    tournaments,
    teams,
    message,
    shorts,
    meetings,
    welcome,
    authWrapper,
    jobManagement,
    moderationQueue,
    brandListing,
    adminJobManagement,
  ];

  /// Helper function to check if a route is a main screen
  static bool isMainScreen(String? routeName) {
    return mainScreens.contains(routeName);
  }

  /// Pop until reaching any main screen or the first route
  static void popToMainScreen(BuildContext context) {
    Navigator.popUntil(context, (route) {
      final routeName = route.settings.name;
      return isMainScreen(routeName) || route.isFirst;
    });
  }
}