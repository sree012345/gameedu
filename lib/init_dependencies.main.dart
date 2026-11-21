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