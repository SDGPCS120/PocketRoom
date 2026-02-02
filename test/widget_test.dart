import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocketroom/main.dart';
import 'package:pocketroom/src/features/home/data/models/furniture_model.dart';
import 'package:pocketroom/src/features/home/data/providers.dart';
import 'package:pocketroom/src/features/home/data/repositories/furniture_repository.dart';
import 'package:pocketroom/src/features/home/presentation/widgets/category_pills.dart';

// 1. A mock implementation of our repository.
// It returns data with empty image lists to prevent network calls in the test.
class MockFurnitureRepository implements IFurnitureRepository {
  @override
  Future<List<Furniture>> fetchFurniture() async {
    return [
      Furniture(
        id: 1,
        name: "The Sofa",
        price: 88000,
        brand: "FurnitureMan",
        rating: 4.0,
        images: [], // Empty list prevents Image.network call
        furnitureType: "Sofa",
        dimensions: "H:90 W:200 D:100",
      ),
      Furniture(
        id: 2,
        name: "Sofa Max",
        price: 100000,
        brand: "Arpico",
        rating: 4.0,
        images: [], // Empty list
        furnitureType: "Sofa",
        dimensions: "H:95 W:220 D:105",
      ),
      Furniture(
        id: 3,
        name: "Sofa Lite",
        price: 54000,
        brand: "Damro",
        rating: 4.0,
        images: [], // Empty list
        furnitureType: "Sofa",
        dimensions: "H:85 W:180 D:90",
      ),
    ];
  }
}

void main() {
  testWidgets('Tapping category filters the product list', (WidgetTester tester) async {
    // 2. Override the real repository with our mock version for this test.
    await tester.pumpWidget(ProviderScope(
      overrides: [
        furnitureRepositoryProvider.overrideWithValue(MockFurnitureRepository()),
      ],
      child: const PocketRoomApp(),
    ));

    // The first frame should show a loading spinner.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the FutureProvider to finish and the UI to settle.
    await tester.pumpAndSettle();

    // After loading, all initial products should be visible.
    // The rest of the test is exactly the same as before.
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
