import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:pocketroom/src/core/firebase_providers.dart';
import 'package:pocketroom/src/features/auth/presentation/signup_page.dart';

void main() {
  testWidgets('SignupPage shows validation errors on empty fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(MockFirebaseAuth()),
          firestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
        ],
        child: const MaterialApp(
          home: SignupPage(),
        ),
      ),
    );

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a username'), findsOneWidget);
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Min 6 characters'), findsOneWidget);
  });

  testWidgets('SignupPage validates password confirmation', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(MockFirebaseAuth()),
        ],
        child: const MaterialApp(
          home: SignupPage(),
        ),
      ),
    );

    // Fill email and password (indexes: 0=username, 1=email, 2=password, 3=confirm)
    await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.enterText(find.byType(TextFormField).at(3), 'wrongpassword');

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('SignupPage sanitizes username', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(MockFirebaseAuth()),
        ],
        child: const MaterialApp(
          home: SignupPage(),
        ),
      ),
    );

    final usernameField = find.byType(TextFormField).at(0);
    await tester.enterText(usernameField, '  test user  ');
    
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    
    // If it sanitized to test_user, the "Enter a username" error should be gone.
    expect(find.text('Enter a username'), findsNothing);
  });
}
