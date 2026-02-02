import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocketroom/main.dart';
import 'package:pocketroom/src/features/home/presentation/widgets/category_pills.dart';

void main() {
  testWidgets('Tapping category filters the product list', (WidgetTester tester) async {
    // Build app and trigger a frame.
    // We must wrap the app in a ProviderScope for Riverpod to work.
    await tester.pumpWidget(const ProviderScope(
      child: PocketRoomApp(),
    ));

    // The first frame should show a loading spinner because of our FutureProvider.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the FutureProvider to finish and the UI to settle.
    await tester.pumpAndSettle();

    // After loading, all initial products should be visible.
    expect(find.text('The Sofa'), findsOneWidget);
    expect(find.text('Sofa Max'), findsOneWidget);
    expect(find.text('Sofa Lite'), findsOneWidget);

    // Find the 'Minimalistic' category chip to tap on.
    final minimalisticChip = find.widgetWithText(CategoryChip, 'Minimalistic');
    expect(minimalisticChip, findsOneWidget);

    // Simulate a user tap on the chip.
    await tester.tap(minimalisticChip);
    // Rebuild the widget tree to reflect the new state.
    await tester.pump();

    // After filtering, only 'Sofa Lite' should be visible.
    expect(find.text('Sofa Lite'), findsOneWidget);

    // The other products should no longer be on screen.
    expect(find.text('The Sofa'), findsNothing);
    expect(find.text('Sofa Max'), findsNothing);
  });
}
