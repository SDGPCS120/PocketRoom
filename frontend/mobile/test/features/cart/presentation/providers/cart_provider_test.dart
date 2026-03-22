import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:pocketroom/src/core/firebase_providers.dart';
import 'package:pocketroom/src/features/cart/presentation/providers/cart_provider.dart';
import 'package:pocketroom/src/features/home/data/models/furniture_model.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;
  late ProviderContainer container;

  final testFurniture = Furniture(
    id: '1',
    name: 'Test Chair',
    price: 100.0,
    brand: 'Test Brand',
    imageUrl: ['chair.png'],
    furnitureType: 'Chair',
    dimensions: '10x10',
    rating: 4.0,
  );

  setUp(() {
    mockAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
    container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(mockAuth),
        firestoreProvider.overrideWithValue(fakeFirestore),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('CartProvider', () {
    test('initial state is empty', () {
      final cart = container.read(cartProvider);
      expect(cart, isEmpty);
    });

    test('addItem adds furniture to cart', () {
      container.read(cartProvider.notifier).addItem(testFurniture);
      final cart = container.read(cartProvider);
      expect(cart.length, 1);
      expect(cart.first.furniture.name, 'Test Chair');
      expect(cart.first.quantity, 1);
    });

    test('addItem increments quantity if already in cart', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addItem(testFurniture);
      notifier.addItem(testFurniture);
      final cart = container.read(cartProvider);
      expect(cart.length, 1);
      expect(cart.first.quantity, 2);
    });

    test('removeItem removes furniture from cart', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addItem(testFurniture);
      notifier.removeItem(testFurniture.id);
      final cart = container.read(cartProvider);
      expect(cart, isEmpty);
    });

    test('totalPrice calculates correctly', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addItem(testFurniture);
      notifier.addItem(testFurniture); // 200.0
      expect(container.read(cartProvider.notifier).totalPrice, 200.0);
    });

  });
}
