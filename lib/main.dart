import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/constants/typography/app_fonts.dart';
import 'package:game_edu/common/constants/ui/language_constants.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/firebase/firebase_initialization.dart';
import 'package:game_edu/core/localization/cubit/confirm_password_visibility_cubit.dart';
import 'package:game_edu/core/localization/cubit/language_cubit.dart';
import 'package:game_edu/core/localization/cubit/password_icon_visibility_cubit.dart';
import 'package:game_edu/core/localization/module_constants/localization_assets_constants.dart';
import 'package:game_edu/core/push_notification/notification_service.dart';
import 'package:game_edu/core/push_notification/params/current_route_track.dart';
import 'package:game_edu/core/responsive/responsive_sizes.dart';
import 'package:game_edu/core/routes/router.dart';
import 'package:game_edu/core/routes/router_path.dart';
import 'package:game_edu/core/state_management/cubit/connection_checker_cubit.dart';
import 'package:game_edu/core/widgets/popup/es_action_popup.dart';
import 'package:game_edu/firebase_options.dart';
import 'package:game_edu/init_dependencies.dart';
import 'package:game_edu/student_module/auth/auth/presentation/pages/login_page.dart';
import 'package:game_edu/user_session.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/localization/merged_asset_loader.dart';

/// Root Navigator
final GlobalKey<NavigatorState> rootNavKey = GlobalKey<NavigatorState>();

// ─────────────────────────────────────────────────────────────────────────────
// Singleton that lives for the entire app lifetime.
// Keeps the Firestore listener alive even after AuthWrapper is replaced
// by DashboardPage in the widget tree.
// ─────────────────────────────────────────────────────────────────────────────
class SessionListenerService {
  static final SessionListenerService _instance = SessionListenerService._();

  static SessionListenerService get instance => _instance;

  SessionListenerService._();

  bool _initialized = false;
  String? _currentUserId;
  bool _isManualLogout = false;

  void setManualLogout(bool value) {
    _isManualLogout = value;
  }

  Future<void> startListening({
    required String userId,
    required String sessionId,
  }) async {
    if (_initialized && _currentUserId == userId) {
      debugPrint("🛡️ [SessionListener] Already running for $userId");
      return;
    }

    if (_initialized) {
      reset();
    }

    _initialized = true;
    _currentUserId = userId;

    debugPrint("🛡️ [SessionListener] Listening started for $userId");
  }

  Future<void> _handleForceLogout() async {
    debugPrint("🔥 FORCE LOGOUT TRIGGERED");

    // Skip popup for manual logout
    if (_isManualLogout) {
      debugPrint("🛡️ [SessionListener] Manual logout detected");
      _isManualLogout = false;
      return;
    }

    reset();

    await FirebaseAuth.instance.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentSessionId');

    rootNavKey.currentState?.pushNamedAndRemoveUntil(
      RouterPath.welcome,
      (route) => false,
    );

    await Future.delayed(const Duration(milliseconds: 300));

    final context = rootNavKey.currentContext;

    if (context != null && context.mounted) {
      EsActionPopup.show(
        context: context,
        title: "auth.session.sessionEnded.title".tr(),
        subtitle: "auth.session.sessionEnded.subtitle".tr(),
        device: ResponsiveSizes.mobile,
        rightButtonText: "auth.session.sessionEnded.ok".tr(),
        onRightTap: () {
          Navigator.of(context).pop();
        },
        barrierDismissible: false,
      );
    }
  }

  void reset() {
    debugPrint("🛡️ [SessionListener] Reset");
    _initialized = false;
    _currentUserId = null;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    setUrlStrategy(PathUrlStrategy());
  }

  await EasyLocalization.ensureInitialized();

  if (!kIsWeb) {
    await Permission.ignoreBatteryOptimizations.request();
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await clearAuthOnFreshInstall();

  await NotificationService.initializeNotificationListeners();
  NotificationService.listenToTokenRefresh();
  NotificationService.listenToAuthForToken();

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Pass all uncaught asynchronous errors to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await initDependencies();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale(LanguageConstants.codeEnglish),
        Locale(LanguageConstants.codeHindi),
        Locale(LanguageConstants.codeTamil),
        Locale(LanguageConstants.codeTelugu),
        Locale(LanguageConstants.codeMalayalam),
        Locale(LanguageConstants.codeKannada),
      ],
      fallbackLocale: const Locale(LanguageConstants.codeEnglish),
      path: 'assets',

      /// Modular localization loader
      assetLoader: const MergedAssetLoader([
        LocalizationAssetsConstants.welcomeScreen,
        LocalizationAssetsConstants.profile,
        LocalizationAssetsConstants.postDetail,
        LocalizationAssetsConstants.home,
        LocalizationAssetsConstants.updateRequired,
        LocalizationAssetsConstants.connection,
        LocalizationAssetsConstants.splash,
        LocalizationAssetsConstants.dashboard,
        LocalizationAssetsConstants.createPost,
        LocalizationAssetsConstants.shareTemplate,
        LocalizationAssetsConstants.savePost,
        LocalizationAssetsConstants.explore,
        LocalizationAssetsConstants.notification,
        LocalizationAssetsConstants.tournamentDiscover,
        LocalizationAssetsConstants.notificationSetting,
        LocalizationAssetsConstants.metting,
        LocalizationAssetsConstants.organizerDashboard,
        LocalizationAssetsConstants.registrationManager,
        LocalizationAssetsConstants.announcements,
        LocalizationAssetsConstants.coachDiscover,
        LocalizationAssetsConstants.createJob,
        LocalizationAssetsConstants.teams,
        LocalizationAssetsConstants.jobsHome,
        LocalizationAssetsConstants.classDetail,
        LocalizationAssetsConstants.sessionLauncher,
        LocalizationAssetsConstants.jobsDetails,
        LocalizationAssetsConstants.applicationTracker,
        LocalizationAssetsConstants.tryoutsDashboard,
        LocalizationAssetsConstants.adminHome,
        LocalizationAssetsConstants.joinMeeting,
        LocalizationAssetsConstants.goLive,
        LocalizationAssetsConstants.adminUserManagement,
        LocalizationAssetsConstants.waitingRoom,
        LocalizationAssetsConstants.liveDiscover,
        LocalizationAssetsConstants.meetingRoom,
        LocalizationAssetsConstants.recordingsList,
        LocalizationAssetsConstants.checkin,
        LocalizationAssetsConstants.fixtures,
        LocalizationAssetsConstants.tournamentWinners,
        LocalizationAssetsConstants.message,
        LocalizationAssetsConstants.gameProfile,
        LocalizationAssetsConstants.coach,
        LocalizationAssetsConstants.createTournament,
        LocalizationAssetsConstants.settings,
        LocalizationAssetsConstants.bracket,
        LocalizationAssetsConstants.shorts,
      ]),

      
        child: BlocProvider(
          create: (context) => LanguageCubit(),
          child: const MyApp(),
        ),
      ),
    );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    NotificationService.initializeToken();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   DeepLinkService.instance.init(rootNavKey);
    // });

    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) async {
      debugPrint("🔄 [MyApp] AUTH CHANGE -> ${user?.uid}");
      if (user != null) {
        await UserSession.instance.init(user.uid);
      } else {
        UserSession.instance.clear();
        SessionListenerService.instance.reset();
      }
    });
  }

  // Catches OS-level permission toggles on resume, all platforms
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      NotificationService.refreshTokenNow();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSub?.cancel();
    SessionListenerService.instance.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<ConnectivityCubit>()),
        BlocProvider(
          create: (_) => serviceLocator<PasswordIconVisibilityCubit>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<ConfirmPasswordVisibilityCubit>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorObservers: [routeObserver, currentRouteTracker],
        navigatorKey: rootNavKey,

        /// Localization
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        theme: ThemeData(
          fontFamily: AppFonts.calibr,
          scaffoldBackgroundColor: AppPalette.backgroundColor,
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: NoAnimationPageTransitionsBuilder(),
              TargetPlatform.iOS: NoAnimationPageTransitionsBuilder(),
            },
          ),
        ),

        /// Router
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute:
            kIsWeb &&
                Uri.base.path == '/resetPassword' &&
                Uri.base.queryParameters['oobCode'] != null
            ? Uri.base.toString()
            : RouterPath.authWrapper,
        builder: (context, child) {
          return PopScope(canPop: false, child: child ?? const SizedBox());
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<User?> _checkSession() async {
    if (!FirebaseInitialization.isFirebaseAppInitialized()) return null;
    return FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _checkSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;

        // Not logged in -> Login screen
        if (user == null) {
          if (AppRouter.isTermsRoute ||
              AppRouter.isResetPasswordRoute ||
              AppRouter.isAdminLoginRoute ||
              AppRouter.isLoginRoute) {
            return const SizedBox();
          }
          return const LoginPage();
        }

        return FutureBuilder<bool>(
          future: CheckUserExists().isUserRegistered(user.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (AppRouter.isResetPasswordRoute || AppRouter.isLoginRoute) {
              return const SizedBox();
            }
            if (userSnapshot.data == true) {
              return const Placeholder(); // TODO: Dashboard / Home
            }
            return const Placeholder(); // TODO: Onboarding
          },
        );
      },
    );
  }
}

class CheckUserExists {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isUserRegistered(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) return false;

    final data = doc.data();

    // Old users don't have this field, so treat them as completed
    if (data == null || !data.containsKey('onboardingCompleted')) {
      return true;
    }

    return data['onboardingCompleted'] == true;
  }
}

class NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

Future<void> clearAuthOnFreshInstall() async {
  final prefs = await SharedPreferences.getInstance();
  final bool hasLaunchedBefore = prefs.getBool('has_launched') ?? false;

  if (!hasLaunchedBefore) {
    // First launch after install: clear stale keychain session
    await FirebaseAuth.instance.signOut();
    await prefs.setBool('has_launched', true);
  }
}