import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocketroom/main.dart';
import 'package:pocketroom/src/common_widgets/search_bar_widget.dart';

void main() {
  testWidgets('Renders HomePage and finds search bar', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We must wrap the app in a ProviderScope for Riverpod to work in tests.
    await tester.pumpWidget(const ProviderScope(
      child: PocketRoomApp(),
    ));

    // Verify that a key widget, like the search bar, is present.
    expect(find.byType(SearchBarWidget), findsOneWidget);

    // You could also verify text within the search bar.
    expect(find.widgetWithText(TextField, 'Search'), findsOneWidget);
  });
}
