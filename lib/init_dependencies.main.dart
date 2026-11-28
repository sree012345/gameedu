part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initNetworkconnectivityCubit();
  _initLanguageCubit();
  _initPasswordVisibility();
  _initConfirmPasswordVisibility();
  _initAuthDependencies();
  _initDashboardDependencies();
  _initCreateProfileDependencies();
  _initSplashDependencies();
  _initProfileDependencies();
  _initClassesDependencies();
  _initEventsDependencies();
  _initCommunityDependencies();
}

void _initNetworkconnectivityCubit() {
  serviceLocator.registerFactory(
    () => ConnectivityCubit(serviceLocator<ConnectionChecker>()),
  );
}

void _initLanguageCubit() {
  if (!serviceLocator.isRegistered<LanguageCubit>()) {
    serviceLocator.registerLazySingleton<LanguageCubit>(() => LanguageCubit());
  }
}

void _initPasswordVisibility() {
  if (!serviceLocator.isRegistered<PasswordIconVisibilityCubit>()) {
    serviceLocator.registerLazySingleton<PasswordIconVisibilityCubit>(
      () => PasswordIconVisibilityCubit(),
    );
  }
}

void _initConfirmPasswordVisibility() {
  if (!serviceLocator.isRegistered<ConfirmPasswordVisibilityCubit>()) {
    serviceLocator.registerLazySingleton<ConfirmPasswordVisibilityCubit>(
      () => ConfirmPasswordVisibilityCubit(),
    );
  }
}
void _initAuthDependencies() {
  if (!serviceLocator.isRegistered<FirebaseAuthService>()) {
    serviceLocator.registerLazySingleton<FirebaseAuthService>(
      () => FirebaseAuthService(),
    );
  }

  if (!serviceLocator.isRegistered<AuthBloc>()) {
    serviceLocator.registerFactory<AuthBloc>(
      () => AuthBloc(authService: serviceLocator<FirebaseAuthService>()),
    );
  }
}

void _initDashboardDependencies() {
  if (!serviceLocator.isRegistered<DashboardService>()) {
    serviceLocator.registerLazySingleton<DashboardService>(
      () => DashboardService(),
    );
  }

  if (!serviceLocator.isRegistered<DashboardBloc>()) {
    serviceLocator.registerFactory<DashboardBloc>(
      () => DashboardBloc(service: serviceLocator<DashboardService>()),
    );
  }
}
void _initCreateProfileDependencies() {
  if (!serviceLocator.isRegistered<CreateProfileService>()) {
    serviceLocator.registerLazySingleton<CreateProfileService>(
      () => CreateProfileService(),
    );
  }
  if (!serviceLocator.isRegistered<CreateProfileBloc>()) {
    serviceLocator.registerFactory<CreateProfileBloc>(
      () => CreateProfileBloc(service: serviceLocator<CreateProfileService>()),
    );
  }
}

void _initSplashDependencies() {
  if (!serviceLocator.isRegistered<StartupService>()) {
    serviceLocator.registerLazySingleton<StartupService>(
      () => StartupService(),
    );
  }
}
void _initProfileDependencies() {
  if (!serviceLocator.isRegistered<ProfileService>()) {
    serviceLocator.registerLazySingleton<ProfileService>(() => ProfileService());
  }
  if (!serviceLocator.isRegistered<MyProfileBloc>()) {
    serviceLocator.registerFactory<MyProfileBloc>(
      () => MyProfileBloc(service: serviceLocator<ProfileService>()),
    );
  }
  if (!serviceLocator.isRegistered<EditProfileBloc>()) {
    serviceLocator.registerFactory<EditProfileBloc>(
      () => EditProfileBloc(service: serviceLocator<ProfileService>()),
    );
  }
}

void _initClassesDependencies() {
  if (!serviceLocator.isRegistered<ClassesService>()) {
    serviceLocator.registerLazySingleton<ClassesService>(() => ClassesService());
  }
  if (!serviceLocator.isRegistered<ClassesBloc>()) {
    serviceLocator.registerFactory<ClassesBloc>(
      () => ClassesBloc(service: serviceLocator<ClassesService>()),
    );
  }

    if (!serviceLocator.isRegistered<ClassDetailService>()) {
    serviceLocator.registerLazySingleton<ClassDetailService>(
      () => ClassDetailService(),
    );
  }
  if (!serviceLocator.isRegistered<ClassDetailBloc>()) {
    serviceLocator.registerFactory<ClassDetailBloc>(
      () => ClassDetailBloc(service: serviceLocator<ClassDetailService>(), classId: ''),
    );
  }
    if (!serviceLocator.isRegistered<ClassDetailService>()) {
    serviceLocator.registerLazySingleton<ClassDetailService>(
      () => ClassDetailService(),
    );
  }
  if (!serviceLocator.isRegistered<LessonBloc>()) {
    serviceLocator.registerFactory<LessonBloc>(
      () => LessonBloc(service: serviceLocator<ClassDetailService>(), classId: '', lessonId: '', videoDone:false, videoIds: []),
    );
  }

}

     void _initEventsDependencies() {
       if (!serviceLocator.isRegistered<EventsService>()) {
         serviceLocator.registerLazySingleton<EventsService>(() => EventsService());
       }
       if (!serviceLocator.isRegistered<EventsBloc>()) {
         serviceLocator.registerFactory<EventsBloc>(
           () => EventsBloc(service: serviceLocator<EventsService>()));
       }
     }


void _initCommunityDependencies() {
  if (!serviceLocator.isRegistered<CommunityFirebaseService>()) {
    serviceLocator.registerLazySingleton<CommunityFirebaseService>(
      () => CommunityFirebaseService(
        // Optional: use your existing session/auth instead of reading the
        // `{env}_users` document. Delete this if `role == 'admin'` is on the user doc.
        // currentUserLoader: () async => CommunityUser(
        //   id: yourUid, name: yourName, photoUrl: yourPhoto, isAdmin: yourIsAdmin,
        // ),
      ),
    );
  }

  if (!serviceLocator.isRegistered<CommunityListBloc>()) {
    serviceLocator.registerFactory<CommunityListBloc>(
      () => CommunityListBloc(service: serviceLocator<CommunityFirebaseService>()),
    );
  }
  if (!serviceLocator.isRegistered<CreateCommunityBloc>()) {
    serviceLocator.registerFactory<CreateCommunityBloc>(
      () => CreateCommunityBloc(service: serviceLocator<CommunityFirebaseService>()),
    );
  }
  if (!serviceLocator.isRegistered<ParticipantPickerBloc>()) {
    serviceLocator.registerFactory<ParticipantPickerBloc>(
      () => ParticipantPickerBloc(service: serviceLocator<CommunityFirebaseService>()),
    );
  }
  if (!serviceLocator.isRegistered<CommunityDetailsBloc>()) {
    serviceLocator.registerFactory<CommunityDetailsBloc>(
      () => CommunityDetailsBloc(service: serviceLocator<CommunityFirebaseService>(), ),
    );
  }
  if (!serviceLocator.isRegistered<CommunityChatBloc>()) {
    serviceLocator.registerFactory<CommunityChatBloc>(
      () => CommunityChatBloc(service: serviceLocator<CommunityFirebaseService>(),),
    );
  }
}