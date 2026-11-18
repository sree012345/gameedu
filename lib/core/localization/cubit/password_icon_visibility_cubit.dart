import 'package:flutter_bloc/flutter_bloc.dart';

/// -------------------------------------------------------------------------
/// [PasswordIconVisibilityCubit]
/// -------------------------------------------------------------------------
/// Manages the visibility state of the password field.
/// - true => obscured (default)
/// - false => visible
/// -------------------------------------------------------------------------
class PasswordIconVisibilityCubit extends Cubit<bool> {
  PasswordIconVisibilityCubit() : super(false); 

  void toggle() => emit(!state);
    void reset() => emit(false);
}
