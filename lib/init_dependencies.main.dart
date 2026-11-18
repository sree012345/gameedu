part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initNetworkconnectivityCubit();
  _initLanguageCubit();
  _initPasswordVisibility();
  _initConfirmPasswordVisibility();
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
