import 'package:flutter_bloc/flutter_bloc.dart';

/// -------------------------------------------------------------------------
/// [ConfirmPasswordVisibilityCubit]
/// -------------------------------------------------------------------------
/// Manages the visibility state of the password field.
/// - true => obscured (default)
/// - false => visible
/// -------------------------------------------------------------------------
class ConfirmPasswordVisibilityCubit extends Cubit<bool> {
  ConfirmPasswordVisibilityCubit() : super(false);

  void toggle() => emit(!state);
  void reset() => emit(false);
}
