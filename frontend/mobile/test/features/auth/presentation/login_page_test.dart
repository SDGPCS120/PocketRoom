import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:pocketroom/src/core/firebase_providers.dart';
import 'package:pocketroom/src/features/auth/presentation/login_page.dart';

void main() {
  testWidgets('LoginPage shows validation errors on empty fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(MockFirebaseAuth()),
          firestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
        ],
        child: const MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    // Initial state: no errors
    expect(find.text('Enter a valid email'), findsNothing);
    expect(find.text('Enter your password'), findsNothing);

    // Tap login button
    final loginButton = find.widgetWithText(ElevatedButton, 'Log in');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pump();

    // Should show validation errors
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('LoginPage shows error on invalid email', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(MockFirebaseAuth()),
        ],
        child: const MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    final emailField = find.byType(TextFormField).first;
    await tester.ensureVisible(emailField);
    await tester.enterText(emailField, 'invalid-email');
    
    final loginButton = find.widgetWithText(ElevatedButton, 'Log in');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Enter a valid email'), findsOneWidget);
  });

  testWidgets('LoginPage obscures password by default and can toggle', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(MockFirebaseAuth()),
        ],
        child: const MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    final passwordField = find.byType(TextField).last;
    final textField = tester.widget<TextField>(passwordField);
    expect(textField.obscureText, true);

    // Toggle visibility
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    final updatedTextField = tester.widget<TextField>(passwordField);
    expect(updatedTextField.obscureText, false);
  });
}
