import 'package:hive/hive.dart';

part 'car_model.g.dart'; // Не забудь сгенерировать этот файл командой

@HiveType(typeId: 0)
class Car extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String price;

  @HiveField(2)
  String distance;

  @HiveField(3)
  String image;

  Car({
    required this.name,
    required this.price,
    required this.distance,
    required this.image,
  });
}
