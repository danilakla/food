import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String role;

  User({required this.name, required this.role});
}
