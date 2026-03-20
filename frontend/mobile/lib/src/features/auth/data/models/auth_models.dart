import 'package:firebase_auth/firebase_auth.dart';

enum AuthOutcome {
  success,
  needsUsername,
}

class RequiresPasswordException implements Exception {
  final String email;
  final AuthCredential credential;
  
  RequiresPasswordException(this.email, this.credential);
}
