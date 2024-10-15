import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food/car_model.dart';
import 'package:food/details.dart';
import 'package:food/user_model.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting
import 'package:device_info/device_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(CarAdapter()); // Register the adapter
  await Hive.openBox<Car>('favorites'); // Open a box for User objects

  Hive.registerAdapter(UserAdapter()); // Register the adapter
  await Hive.openBox<User>('users'); // Open a box for User objects
  runApp(RentalCarApp());
}

class RentalCarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RentaX',
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
      home: RentaXHomePage(),
    );
  }
}

class RentaXHomePage extends StatefulWidget {
  @override
  _RentaXHomePageState createState() => _RentaXHomePageState();
}

class _RentaXHomePageState extends State<RentaXHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  String _deviceManufacturer = 'Неизвестно';
  User? _currentUser; // Current user object
  List<User> _users = []; // List of users

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final userBox = Hive.box<User>('users');

    setState(() {
      _users = userBox.values.toList();
      if (_users.isNotEmpty) {
        _currentUser = _users.first; // Set the first user as default
      }
    });
  }

  void _switchUser(User user) {
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _getDeviceManufacturer() async {
    String deviceManufacturer;
    const platform = MethodChannel('com.example/device_info');

    try {
      final String result =
          await platform.invokeMethod('getDeviceManufacturer');
      deviceManufacturer = result;
    } on PlatformException catch (e) {
      deviceManufacturer = "Не удалось получить информацию: '${e.message}'";
    }

    setState(() {
      _deviceManufacturer = deviceManufacturer;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.favorite),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FavoritesPage(),
                    ),
                  );
                },
              ),
              Row(
                children: [
                  Icon(Icons.location_pin, color: Colors.white),
                  if (_currentUser != null)
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.white),
                        Text(
                          'User: ${_currentUser!.name}, role: ${_currentUser!.role}',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          actions: [
            PopupMenuButton<User>(
              onSelected: _switchUser,
              itemBuilder: (context) {
                return _users.map((user) {
                  return PopupMenuItem(
                    value: user,
                    child: Text(user.name),
                  );
                }).toList();
              },
            ),
            Icon(Icons.notifications_none, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/face.png'),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),

                  Text(
                    "Premium",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 54,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                  Text(
                    "& Rental Car",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 54,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Horizontal Tab Menu
                  Container(
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      tabs: [
                        Tab(
                          text: "Premium",
                        ),
                        Tab(
                          child: Row(children: [
                            Text('Exclusive'),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'New',
                              style: TextStyle(
                                backgroundColor: Colors.purple,
                                fontSize: 10,
                              ),
                            )
                          ]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Date Selector with Down Arrow
                  Row(
                    children: [
                      Column(
                        children: [
                          Row(children: [
                            Text(
                              'Choose Date: ',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 101, 101, 101),
                                fontSize: 13,
                              ),
                            ),
                            Icon(Icons.calendar_today,
                                size: 13,
                                color: Color.fromARGB(255, 101, 101, 101)),
                          ]),
                          Row(children: [
                            Icon(Icons.check_circle,
                                color: const Color.fromARGB(255, 50, 242, 56)),
                            SizedBox(width: 5),
                            Text(
                              'Today ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              DateFormat('dd MMMM').format(_selectedDate),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.arrow_drop_down,
                                color: Colors.greenAccent),
                          ])
                        ],
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () => _selectDate(context),
                        icon: Icon(Icons.calendar_today, color: Colors.white),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        color: Colors.white30,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.grid_view, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  PageView(
                    children: [
                      ListView(
                        padding: EdgeInsets.all(10),
                        children: [
                          CarCard(
                            colorCircle: Colors.blue,
                            carName: 'Porsche 911 GT3',
                            rating: 4.3,
                            recommend: '82% Recommend',
                            price: '\$900',
                            distance: '570 km',
                            carImage: 'assets/images/image1.png',
                            logoImage: 'assets/images/pors.png', // Car logo
                          ),
                          SizedBox(height: 20),
                          CarCard(
                            colorCircle: Colors.grey,
                            carName: 'Lamborghini Huracan',
                            rating: 4.9,
                            recommend: '97% Recommend',
                            price: '\$1200',
                            distance: '712 km',
                            carImage: 'assets/images/image1.png',
                            logoImage: 'assets/images/pors.png', // Car logo
                          ),
                        ],
                      ),
                    ],
                  ),
                  // You can add content for the "Exclusive" tab here
                  Center(
                    child: Text(
                      "Exclusive Content",
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0)),
            color: const Color.fromARGB(255, 49, 49, 49),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.transparent,
            unselectedItemColor: Colors.transparent,
            selectedLabelStyle: TextStyle(backgroundColor: Colors.white),
            items: [
              BottomNavigationBarItem(
                  backgroundColor: const Color.fromARGB(255, 49, 49, 49),
                  icon: Icon(Icons.apps, color: Colors.white),
                  label: ''),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.schedule,
                    color: Colors.white,
                  ),
                  label: ''),
              BottomNavigationBarItem(
                  icon: Icon(Icons.assignment, color: Colors.white), label: ''),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings, color: Colors.white), label: ''),
            ],
          ),
        ));
  }
}

class CarCard extends StatelessWidget {
  final Color colorCircle;
  final String carName;
  final double rating;
  final String recommend;
  final String price;
  final String distance;
  final String carImage;
  final String logoImage;

  CarCard({
    required this.colorCircle,
    required this.carName,
    required this.rating,
    required this.recommend,
    required this.price,
    required this.distance,
    required this.carImage,
    required this.logoImage,
  });

  @override
  Widget build(BuildContext context) {
    // Коробка Hive для избранного
    var favoritesBox = Hive.box<Car>('favorites');

    // Проверяем, находится ли машина в избранном
    bool isFavorite = favoritesBox.containsKey(carName);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetailsPage(
              carName: carName,
              carImage: 'assets/images/image2.png',
              logoImage: logoImage,
              rating: rating,
              distance: distance,
              maxSpeed: '250', // Пример значений
              power: '300',
              price: price,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(carImage),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(30)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Логотип машины и секция цвета
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(logoImage),
                          radius: 30,
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Color:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 5),
                                CircleAvatar(
                                  backgroundColor: colorCircle,
                                  radius: 10,
                                ),
                              ],
                            ),
                            Text(
                              carName,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    // Рейтинг и аватары пользователей
                    SizedBox(height: 10),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage('assets/images/face.png'),
                          radius: 12,
                        ),
                        SizedBox(width: 5),
                        CircleAvatar(
                          backgroundImage: AssetImage('assets/images/face.png'),
                          radius: 12,
                        ),
                        SizedBox(width: 5),
                        CircleAvatar(
                          backgroundImage: AssetImage('assets/images/face.png'),
                          radius: 12,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '$rating ★',
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    // Рекомендация
                    Text(
                      recommend,
                      style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                // Секция батареи и километража
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.battery_full, color: Colors.black, size: 20),
                        SizedBox(width: 5),
                        Text(
                          distance,
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                      ],
                    ),
                    // Кнопка избранного
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        if (isFavorite) {
                          favoritesBox.delete(carName); // Удаляем из избранного
                        } else {
                          // Добавляем в избранное
                          favoritesBox.put(
                            carName,
                            Car(
                              name: carName,
                              price: price,
                              distance: distance,
                              image: carImage,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                // Секция цены
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1 day rental',
                      style: TextStyle(
                        color: const Color.fromARGB(137, 223, 211, 211),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      price,
                      style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 60),
                // Иконка стрелки
                Icon(Icons.arrow_forward_sharp, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access the favorites box
    var favoritesBox = Hive.box<Car>('favorites');

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Cars'),
      ),
      body: ValueListenableBuilder(
        valueListenable: favoritesBox.listenable(), // Listen for changes
        builder: (context, Box<Car> box, _) {
          var favoriteCars = box.values.toList();

          return favoriteCars.isEmpty
              ? Center(
                  child: Text('No favorite cars yet.'),
                )
              : ListView.builder(
                  itemCount: favoriteCars.length,
                  itemBuilder: (context, index) {
                    final car = favoriteCars[index];

                    return ListTile(
                      leading: Image.asset(car.image),
                      title: Text(car.name),
                      subtitle: Text('${car.price} - ${car.distance} km'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Remove from favorites
                          box.delete(
                              car.key); // Assuming `key` is unique for each car
                        },
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
