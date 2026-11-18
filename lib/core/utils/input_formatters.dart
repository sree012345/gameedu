import 'package:flutter/services.dart'
    show TextInputFormatter, TextSelection, TextEditingValue, TextRange;

class InputFormatters {
  static TextInputFormatter noLeadingSpaces() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final trimmed = newValue.text.replaceFirst(RegExp(r'^\s+'), '');
      // Adjust cursor position
      int offset =
          newValue.selection.baseOffset -
          (newValue.text.length - trimmed.length);
      // Ensure cursor doesn't go out of bounds
      offset = offset.clamp(0, trimmed.length);
      return newValue.copyWith(
        text: trimmed,
        selection: TextSelection.collapsed(offset: offset),
      );
    });
  }

  static TextInputFormatter displayNameFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String text = newValue.text;

      // Remove leading spaces
      text = text.replaceFirst(RegExp(r'^\s+'), '');

      // Allow only letters, numbers and space
      text = text
          .split('')
          .where((c) => RegExp(r'[a-zA-Z0-9 ]').hasMatch(c))
          .join();

      // // Limit to 50 chars
      // if (text.length > 50) {
      //   text = text.substring(0, 50);
      // }

      int diff = newValue.text.length - text.length;
      int offset = newValue.selection.baseOffset - diff;
      offset = offset.clamp(0, text.length);

      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: offset),
      );
    });
  }

  // static TextInputFormatter handleFormatter() {
  //   return TextInputFormatter.withFunction((oldValue, newValue) {
  //     String text = newValue.text;

  //     // --- 1. Remove leading spaces ---
  //     text = text.replaceFirst(RegExp(r'^\s+'), '');

  //     // --- 2. Keep only allowed chars (lowercase, numbers, underscore) ---
  //     text = text
  //         .toLowerCase()
  //         .split('')
  //         .where((c) => RegExp(r'[a-z0-9_]').hasMatch(c))
  //         .join();

  //     // --- 3. Limit length to 20 ---
  //     if (text.length > 20) {
  //       text = text.substring(0, 20);
  //     }

  //     // --- 4. Adjust cursor relative to new text ---
  //     int diff = newValue.text.length - text.length;
  //     int offset = newValue.selection.baseOffset - diff;
  //     offset = offset.clamp(0, text.length);

  //     return TextEditingValue(
  //       text: text,
  //       selection: TextSelection.collapsed(offset: offset),
  //     );
  //   });
  // }
  static TextInputFormatter handleFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String newText = newValue.text;

      // 1. Remove leading spaces
      newText = newText.replaceFirst(RegExp(r'^\s+'), '');

      // 2. Keep only allowed chars: a-z, 0-9, _
      String filtered = '';
      int cursorOffset = newValue.selection.baseOffset;

      for (int i = 0; i < newText.length; i++) {
        String c = newText[i];
        if (RegExp(r'[a-z0-9_]').hasMatch(c)) {
          filtered += c;
        } else {
          if (i < cursorOffset) cursorOffset--;
        }
      }

      // // 3. Limit length to 20
      // if (filtered.length > 20) {
      //   filtered = filtered.substring(0, 20);
      //   if (cursorOffset > 20) cursorOffset = 20;
      // }

      // 4. Clamp cursor
      cursorOffset = cursorOffset.clamp(0, filtered.length);

      return TextEditingValue(
        text: filtered,
        selection: TextSelection.collapsed(offset: cursorOffset),
        composing: TextRange.empty,
      );
    });
  }
}

class EmailInputFormatter extends TextInputFormatter {
  final RegExp _allowedChars = RegExp(r'[a-zA-Z0-9@._\-+]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    int cursorPosition = newValue.selection.baseOffset;

    // remove spaces
    text = text.replaceAll(' ', '');

    // convert to lowercase
    text = text.toLowerCase();

    // keep only allowed characters
    text = text.split('').where((c) => _allowedChars.hasMatch(c)).join();

    // prevent multiple @
    final parts = text.split('@');
    if (parts.length > 2) {
      text = '${parts[0]}@${parts.sublist(1).join('')}';
    }

    // prevent consecutive dots
    text = text.replaceAll('..', '.');

    // clamp cursor inside text
    if (cursorPosition > text.length) {
      cursorPosition = text.length;
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class PasswordInputFormatter extends TextInputFormatter {
  final RegExp _allowedChars = RegExp(r'[A-Za-z0-9@$!%*?&.#_\-]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String filtered = newValue.text
        .split('')
        .where((char) => _allowedChars.hasMatch(char))
        .join();

    int cursorPosition = newValue.selection.baseOffset;

    // Clamp cursor if text length changed
    if (cursorPosition > filtered.length) {
      cursorPosition = filtered.length;
    }

    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

/// Blocks a user from ever typing/pasting an invalid URL fragment.
/// Works together with a final `isValidUrl()` check on submit (see below)
/// since a formatter alone can't fully validate a URL that's still
/// mid-typing (e.g. "https://example." is invalid but must be typeable
/// on the way to "https://example.com").
class UrlInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) return newValue;

    // Block ANY whitespace (space, tab, newline)
    //   → kills "https:// example.com", "https://exa mple.com"
    if (RegExp(r'\s').hasMatch(text)) return oldValue;

    // Only allow characters that are legal in a URL.
    //   → kills "example,com", "example!.com"
    final allowedChars = RegExp(r"^[a-zA-Z0-9\-._~:/?#\[\]@%&=+;,]*$");
    if (!allowedChars.hasMatch(text)) return oldValue;

    // Block consecutive dots anywhere
    //   → kills "https://example..com"
    if (text.contains('..')) return oldValue;

    // Block a dot or hyphen immediately after "://" or after another dot
    //   → kills "https://.com", "https://.", "https://-example.com"
    if (RegExp(r'(://|\.)[.\-]').hasMatch(text)) return oldValue;

    // Block a hyphen immediately before a dot (a label can't end in "-")
    //   → kills "https://example-.com"
    if (text.contains('-.')) return oldValue;

    // Block more than one "://"
    if ('://'.allMatches(text).length > 1) return oldValue;

    return newValue;
  }
}

/// Final, strict validation to run on submit (paste can bypass a
/// TextInputFormatter, so always re-check the finished string too).
///
/// Rejects everything in your invalid list:
///   http://.com                (empty first label)
///   https://example            (no TLD / no dot)
///   https:// example.com       (space after protocol)
///   https://exa mple.com       (space in domain)
///   https://example..com       (double dot)
///   https://-example.com       (label starts with '-')
///   https://example-.com       (label ends with '-')
///   https://example,com        (invalid char, no TLD)
///   https://example!.com       (invalid char)
///   https://.                  (empty/invalid host)
bool isValidUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return true; // treat empty as "not provided", allowed

  final urlPattern = RegExp(
    r'^https?:\/\/'
    r'(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+' // one or more labels + dot
    r'[a-zA-Z]{2,}' // TLD, letters only, len >= 2
    r'(?::\d{1,5})?' // optional port
    r'(?:\/[^\s]*)?$', // optional path/query/fragment, no whitespace
  );

  return urlPattern.hasMatch(trimmed);
}
