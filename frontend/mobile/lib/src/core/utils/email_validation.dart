import 'dart:io';

class EmailValidation {
  EmailValidation._();

  static final RegExp _emailRegex = RegExp(
    r"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$",
    caseSensitive: false,
  );

  static String? validateSyntax(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Enter a valid email';
    }
    if (!_emailRegex.hasMatch(email)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static Future<String?> validateForSubmission(String? value) async {
    final syntaxError = validateSyntax(value);
    if (syntaxError != null) {
      return syntaxError;
    }

    final email = value!.trim();
    final domain = email.split('@').last.toLowerCase();

    try {
      final records = await InternetAddress.lookup(domain);
      if (records.isEmpty) {
        return 'Enter a real email address';
      }
    } on SocketException {
      return 'Enter a real email address';
    }

    return null;
  }
}
