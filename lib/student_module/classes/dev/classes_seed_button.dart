import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/student_module/classes/bloc/classes_bloc.dart';

import 'classes_seed.dart';

/// TEMPORARY, debug builds only: writes the 10 test classes to Firestore
/// and reloads the list. Remove it (and classes_seed.dart) after testing.
class ClassesSeedButton extends StatefulWidget {
  const ClassesSeedButton({super.key});

  @override
  State<ClassesSeedButton> createState() => _ClassesSeedButtonState();
}

class _ClassesSeedButtonState extends State<ClassesSeedButton> {
  bool _loading = false;

  Future<void> _seed() async {
    final bloc = context.read<ClassesBloc>();
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _loading = true);

    String message;
    try {
      await ClassesSeed.run();
      bloc.add(const ClassesStarted()); // reload the list
      message = '10 test classes added';
    } catch (e) {
      message = 'Could not add classes: $e';
    }

    if (mounted) setState(() => _loading = false);

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppPalette.authTextPrimaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Never shown in release builds.
    if (!kDebugMode) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _loading ? null : _seed,
          icon: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add_circle_outline_rounded),
          label: const Text(
            'Add test classes (debug)',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppPalette.primaryBlue,
            side: const BorderSide(color: AppPalette.primaryBlue, width: 1.5),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}
