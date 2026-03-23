import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:pocketroom/src/features/home/data/repositories/firestore_product_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreProductRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = FirestoreProductRepository(firestore: fakeFirestore);
  });

  group('FirestoreProductRepository', () {
    test('fetchFurniture returns list of products from Firestore', () async {
      // Add mock data
      await fakeFirestore.collection('products').add({
        'name': 'Modern Sofa',
        'price': 499.0,
        'brand': 'ComfortCo',
        'category': 'Sofa',
        'images': ['sofa.png'],
        'rating': 4.5,
      });

      final products = await repository.fetchFurniture();

      expect(products.length, 1);
      expect(products.first.name, 'Modern Sofa');
      expect(products.first.price, 499.0);
    });

    test('fetchFurniture handles missing fields gracefully', () async {
      // Missing price and image
      await fakeFirestore.collection('products').add({
        'name': 'Mini Table',
        'brand': 'OfficePro',
      });

      final products = await repository.fetchFurniture();

      expect(products.length, 1);
      expect(products.first.name, 'Mini Table');
      expect(products.first.price, isNaN); 
    });

  });
}
