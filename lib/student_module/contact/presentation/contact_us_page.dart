import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/widgets/base/base_textfield.dart';
import 'package:game_edu/core/widgets/buttons/medium_button.dart';
import 'package:game_edu/student_module/classes/presentation/widgets/gradient_header.dart';

import '../bloc/contact_bloc.dart';

/// "Contact Us": subject + message -> saved in Firestore.
///
///   Navigator.of(context).push(
///     MaterialPageRoute(builder: (_) => const ContactUsPage()));
class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ContactBloc>(
      create: (_) => ContactBloc(),
      child: const _ContactView(),
    );
  }
}

class _ContactView extends StatefulWidget {
  const _ContactView();

  @override
  State<_ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<_ContactView> {
  final TextEditingController _subject = TextEditingController();
  final TextEditingController _message = TextEditingController();

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppPalette.authTextPrimaryColor,
        ),
      );
  }

  void _send() {
    FocusScope.of(context).unfocus();
    context.read<ContactBloc>().add(
      ContactSubmitted(subject: _subject.text, message: _message.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContactBloc, ContactState>(
      listenWhen: (p, c) =>
          (c.message != null && p.message != c.message) ||
          (p.status != c.status && c.status == ContactStatus.success),
      listener: (context, state) {
        if (state.message != null) _toast(state.message!);

        if (state.status == ContactStatus.success) {
          _toast('Message sent. We will get back to you soon.');
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        final bottom = MediaQuery.of(context).padding.bottom;

        return Scaffold(
          backgroundColor: AppPalette.authCardSurfaceColor,
          body: Column(
            children: [
              GradientHeader(
                title: 'Contact Us',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Stack(
                  children: [
                    // soft waves at the bottom
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 230,
                      child: IgnorePointer(
                        child: CustomPaint(painter: _WavesPainter()),
                      ),
                    ),
                    SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(20, 40, 20, 24 + bottom),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 76,
                              height: 76,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppPalette.primaryBlue,
                              ),
                              child: const Icon(
                                Icons.mail_outline_rounded,
                                size: 38,
                                color: AppPalette.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'How can we help?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 34,
                              height: 1.1,
                              fontWeight: FontWeight.w800,
                              color: AppPalette.authTextPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Have a question? Send us a message.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              color: AppPalette.authTextPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 34),
                          const _Label('Subject'),
                          const SizedBox(height: 8),
                          _Field(
                            controller: _subject,
                            hint: 'Enter subject',
                            error: state.subjectError,
                            enabled: !state.sending,
                            maxLength: 150,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => context.read<ContactBloc>().add(
                              const ContactSubjectChanged(),
                            ),
                          ),
                          const SizedBox(height: 22),
                          const _Label('Message'),
                          const SizedBox(height: 8),
                          _Field(
                            controller: _message,
                            hint: 'Write your message',
                            error: state.messageError,
                            enabled: !state.sending,
                            maxLength: 2000,
                            minLines: 6,
                            maxLines: 10,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            onChanged: (_) => context.read<ContactBloc>().add(
                              const ContactMessageChanged(),
                            ),
                          ),
                          const SizedBox(height: 26),
                          MediumButton( text: 'Send Message', onPressed:_send),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w800,
        color: AppPalette.authTextPrimaryColor,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.enabled,
    required this.maxLength,
    this.error,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final int maxLength;
  final String? error;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {

    return BaseTextfield(
      controller: controller,
      onChanged: onChanged,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      textInputAction: textInputAction,
   
    );
  }
}
/// Two soft light-blue hills at the bottom of the page.
class _WavesPainter extends CustomPainter {
  const _WavesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppPalette.primaryBlue.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    // left hill
    final left = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.40,
        size.width * 0.62,
        size.height * 0.78,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.92,
        size.width * 0.80,
        size.height,
      )
      ..lineTo(0, size.height)
      ..close();

    // right hill
    final right = Path()
      ..moveTo(size.width * 0.38, size.height)
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.45,
        size.width,
        size.height * 0.12,
      )
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(left, paint);
    canvas.drawPath(right, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
