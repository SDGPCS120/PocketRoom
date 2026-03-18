import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pocketroom/src/features/home/data/models/furniture_model.dart';
import 'package:pocketroom/src/features/home/data/repositories/api_product_repository.dart';

@GenerateMocks([http.Client])
import 'api_product_repository_test.mocks.dart';

void main() {
  late ApiProductRepository repository;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    repository = ApiProductRepository(client: mockClient);
  });

  group('ApiProductRepository', () {
    test('returns a list of Furniture if the http call completes successfully',
        () async {
      final mockResponse = {
        'data': [
          {
            'id': '1',
            'name': 'Test Sofa',
            'price': 100.0,
            'brand': 'Test Brand',
            'furnitureType': 'sofa',
            'dimensions': '100x100',
            'stockStatus': true,
            'rating': 4.5,
            'images': ['image1.jpg'],
            'styleTags': ['modern']
          }
        ]
      };

      when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response(jsonEncode(mockResponse), 200));

      final result = await repository.fetchFurniture();

      expect(result, isA<List<Furniture>>());
      expect(result.length, 1);
      expect(result[0].name, 'Test Sofa');
      expect(result[0].price, 100.0);
    });

    test('throws an exception if the http call completes with an error',
        () async {
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(repository.fetchFurniture(), throwsException);
    });

    test('handles response without "data" key', () async {
      final mockResponse = [
        {
          'id': '1',
          'name': 'Test Sofa',
          'price': 100.0,
          'brand': 'Test Brand',
          'furnitureType': 'sofa',
          'dimensions': '100x100',
          'stockStatus': true,
          'rating': 4.5,
          'images': ['image1.jpg'],
          'styleTags': ['modern']
        }
      ];

      when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response(jsonEncode(mockResponse), 200));

      final result = await repository.fetchFurniture();

      expect(result.length, 1);
      expect(result[0].name, 'Test Sofa');
    });
  });
}
