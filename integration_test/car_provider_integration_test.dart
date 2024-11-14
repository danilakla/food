// integration_test/car_provider_integration_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:food/main.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CarProvider integration test', (WidgetTester tester) async {
    // Инициализируем провайдер в тестовом виджете
    final testProvider = CarProvider.test();

    // Создаем тестовое приложение с провайдером
    await tester.pumpWidget(
      ChangeNotifierProvider<CarProvider>.value(
        value: testProvider,
        child: MaterialApp(
          home: Scaffold(
            body: Consumer<CarProvider>(
              builder: (context, provider, child) {
                return ListView(
                  children: provider.cars.map((car) {
                    return ListTile(
                      title: Text(car.name),
                      subtitle: Text(car.price),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(testProvider.cars.length, 0);
    var duration = const Duration(seconds: 2);

    final car = Car(
        name: 'Tesla', price: '50000', distance: '1000', image: 'image.png');
    testProvider.addCarTest(car);
    sleep(duration);

    await tester.pump();

    expect(find.text('Tesla'), findsOneWidget);
    expect(testProvider.cars.length, 1);

    final updatedCar = Car(
        name: 'Tesla',
        price: '55000',
        distance: '1200',
        image: 'image_updated.png');
    testProvider.updateCarTest(updatedCar);
    sleep(duration);

    await tester.pump();

    expect(find.text('55000'), findsOneWidget);
    expect(testProvider.getCar('Tesla')?.price, '55000');

    testProvider.deleteTest('Tesla');
    sleep(duration);

    await tester.pump();

    expect(find.text('Tesla'), findsNothing);
    expect(testProvider.cars.length, 0);
  });
}
//flutter test integration_test/car_provider_integration_test.dart
