import 'dart:async';

/// -------------------------------------------------------------------------
/// [ConnectivityCubit]
/// -------------------------------------------------------------------------
/// Manages the to check the  internet connection
/// -------------------------------------------------------------------------
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/core/network/internet_status_checker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
class ConnectivityCubit extends Cubit<bool> {
  final ConnectionChecker _connectionChecker;
  late final StreamSubscription<InternetStatus> _subscription;

  Timer? _offlineTimer;
  static const _offlineDelay = Duration(seconds: 10);

  ConnectivityCubit(this._connectionChecker) : super(true) {
    _subscription = _connectionChecker.onStatusChange.listen(
      (status) {
        _offlineTimer?.cancel();
        if (status == InternetStatus.connected) {
          emit(true);
        } else {
          _offlineTimer ??= Timer(_offlineDelay, () {
            emit(false);
          });
        }
      },
      onError: (error, stack) {
        _offlineTimer ??= Timer(_offlineDelay, () {
          emit(false);
        });
      },
    );
  }
  bool get isConnected => state;

  Future<void> checkNow() async {
    final online = await _connectionChecker.isConnected;
    emit(online);
  }

  Future<bool> checkRealConnection() async {
    return await _connectionChecker.isConnected;
  }

  @override
  Future<void> close() {
    _offlineTimer?.cancel();
    _subscription.cancel();
    return super.close();
  }
}
