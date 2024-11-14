import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food/car_ao.dart';
import 'package:food/main.dart';
import 'package:provider/provider.dart';

void main() {
  group('CarApp Widget Tests', () {
    testWidgets('1. Enter text to add a car', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => CarProvider.test(),
          child: MaterialApp(home: CarApp()),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), 'Tesla');
      await tester.enterText(find.byType(TextField).at(1), '50000');
      await tester.enterText(find.byType(TextField).at(2), '1000');
      await tester.enterText(find.byType(TextField).at(3), 'image.png');

      await tester.pump(Duration(seconds: 2)); // Pause to observe input

      expect(find.text('Tesla'), findsOneWidget);
      expect(find.text('50000'), findsOneWidget);
    });

    testWidgets('2. Tap to add a car and check list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => CarProvider.test(),
          child: MaterialApp(home: CarApp()),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), 'Tesla');
      await tester.enterText(find.byType(TextField).at(1), '50000');
      await tester.enterText(find.byType(TextField).at(2), '1000');
      await tester.enterText(find.byType(TextField).at(3), 'image.png');

      await tester.pump(Duration(seconds: 2)); // Pause to observe input

      await tester.tap(find.text('Add Car'));
      await tester.pump(Duration(seconds: 2)); // Pause to observe added car

      expect(find.text('Tesla'), findsOneWidget);
    });

    testWidgets('3. Tap on car item to update it', (WidgetTester tester) async {
      final testProvider = CarProvider.test();
      testProvider.addCarTest(Car(
          name: 'Tesla', price: '50000', distance: '1000', image: 'image.png'));

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: testProvider,
          child: MaterialApp(home: CarApp()),
        ),
      );

      await tester.pump(Duration(seconds: 2)); // Pause to observe initial list

      await tester.tap(find.text('Tesla'));
      await tester.pump(Duration(seconds: 2)); // Pause to observe tapped state

      expect(testProvider.getCar('Tesla')?.price, '50000');
    });

    testWidgets('4. Drag to delete car', (WidgetTester tester) async {
      final testProvider = CarProvider.test();
      testProvider.addCarTest(Car(
          name: 'Tesla', price: '50000', distance: '1000', image: 'image.png'));

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: testProvider,
          child: MaterialApp(home: CarApp()),
        ),
      );

      expect(find.text('Tesla'), findsOneWidget);
      await tester.pump(Duration(seconds: 2)); // Pause to observe car in list

      await tester.drag(find.text('Tesla'), Offset(-500, 0));
      await tester
          .pumpAndSettle(Duration(seconds: 2)); // Pause to observe deletion

      expect(find.text('Tesla'), findsNothing);
    });

    testWidgets('5. Add multiple cars and check list length',
        (WidgetTester tester) async {
      final testProvider = CarProvider.test();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: testProvider,
          child: MaterialApp(home: CarApp()),
        ),
      );

      testProvider.addCarTest(Car(
          name: 'Tesla',
          price: '50000',
          distance: '1000',
          image: 'image1.png'));
      testProvider.addCarTest(Car(
          name: 'BMW', price: '45000', distance: '900', image: 'image2.png'));
      await tester.pump(Duration(seconds: 2)); // Pause to observe cars in list

      expect(find.text('Tesla'), findsOneWidget);
      expect(find.text('BMW'), findsOneWidget);
    });
  });
}
