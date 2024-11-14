// test_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:food/main.dart';
import 'package:mockito/mockito.dart';
import 'file.mocks.mocks.dart';

void main() {
  late CarProvider testProvider;
  late MockCar mockCar;

  setUp(() {
    testProvider = CarProvider.test();
    mockCar = MockCar();
  });

  test('should add a car using mock', () {
    // Настраиваем мок, чтобы возвращал определенные значения
    when(mockCar.name).thenReturn('Tesla');
    when(mockCar.price).thenReturn('50000');
    when(mockCar.distance).thenReturn('1000');
    when(mockCar.image).thenReturn('image.png');

    // Добавляем мок-объект в провайдер
    testProvider.addCarTest(mockCar);

    // Проверяем, что мок-объект добавлен
    expect(testProvider.cars.contains(mockCar), true);
    expect(
        testProvider.cars.firstWhere((e) => e.name == 'Tesla').name == 'Tesla',
        true);

    // Проверяем, что вызов имени произошел у мок-объекта
    // verify(testProvider.cars.length).called(1);
  });

  test('should remove a car by name using mock', () {
    when(mockCar.name).thenReturn('Tesla');
    testProvider.addCarTest(mockCar);

    // Удаляем автомобиль по имени
    testProvider.deleteTest('Tesla');

    // Проверяем, что автомобиль был удален
    expect(testProvider.cars.contains(mockCar), false);

    // Проверяем, что имя автомобиля было вызвано
    // verify(mockCar.name).called(1);
  });

  test('should update car details using mock', () {
    when(mockCar.name).thenReturn('Tesla');
    when(mockCar.price).thenReturn('50000');
    when(mockCar.distance).thenReturn('1000');
    when(mockCar.image).thenReturn('image.png');

    // Добавляем начальный автомобиль
    testProvider.addCarTest(mockCar);

    // Создаем другой мок для обновленного автомобиля
    final updatedMockCar = MockCar();
    when(updatedMockCar.name).thenReturn('Tesla');
    when(updatedMockCar.price).thenReturn('55000');
    when(updatedMockCar.distance).thenReturn('1200');
    when(updatedMockCar.image).thenReturn('image_updated.png');

    // Обновляем автомобиль в провайдере
    testProvider.updateCarTest(updatedMockCar);

    // Проверяем, что обновленный автомобиль теперь в списке
    final updatedCar = testProvider.getCar('Tesla');
    expect(updatedCar?.price, '55000');

    // Проверяем вызовы
    verify(updatedMockCar.price).called(1);
  });
}
