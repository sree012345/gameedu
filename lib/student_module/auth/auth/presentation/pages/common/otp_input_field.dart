import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_edu/common/theme/app_palette.dart';

/// 6-box OTP input.
///
/// One invisible [TextField] receives the keyboard input (so paste and
/// SMS autofill work) and the boxes only display the digits.
class OtpInputField extends StatefulWidget {
  const OtpInputField({
    super.key,
    required this.value,
    required this.onChanged,
    this.onSubmitted,
    this.length = 6,
    this.hasError = false,
    this.autofocus = true,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final int length;
  final bool hasError;
  final bool autofocus;

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() {});

  @override
  void didUpdateWidget(covariant OtpInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Bloc cleared / changed the OTP (e.g. resend) -> sync the hidden field.
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  int get _activeIndex {
    if (!_focusNode.hasFocus) return -1;
    return widget.value.length < widget.length ? widget.value.length : -1;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        children: [
          IgnorePointer(
            child: Row(
              children: [
                for (int i = 0; i < widget.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: _buildBox(i)),
                ],
              ],
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: widget.length,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofillHints: const [AutofillHints.oneTimeCode],
                enableInteractiveSelection: false,
                showCursor: false,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                ),
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBox(int index) {
    final hasDigit = index < widget.value.length;
    final isActive = index == _activeIndex;

    Color borderColor;
    double borderWidth = 1.5;
    if (widget.hasError) {
      borderColor = AppPalette.errorBorderColor;
    } else if (hasDigit) {
      borderColor = AppPalette.inputFocusedBorderColor;
    } else if (isActive) {
      borderColor = AppPalette.primaryBlueLight;
      borderWidth = 2;
    } else {
      borderColor = AppPalette.inputBorderColor;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppPalette.authCardSurfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppPalette.primaryBlueLight.withValues(alpha: 0.18),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: hasDigit
          ? Text(
              widget.value[index],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppPalette.authTextPrimaryColor,
              ),
            )
          : (isActive ? const _BlinkingCursor() : null),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 26,
        decoration: BoxDecoration(
          color: AppPalette.primaryBlue,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
