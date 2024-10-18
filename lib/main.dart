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
                  if (_currentUser != null &&
                      (_currentUser!.role == 'admin' ||
                          _currentUser!.role == 'manager'))
                    IconButton(
                      icon:
                          Icon(Icons.admin_panel_settings, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManageCarsPage(
                              currentUser: _currentUser,
                            ),
                          ),
                        );
                      },
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
                            currentUser: _currentUser,
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
                            currentUser: _currentUser,
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
  final User? currentUser; // Current user object

  CarCard({
    required this.colorCircle,
    required this.carName,
    required this.rating,
    required this.recommend,
    required this.price,
    required this.distance,
    required this.carImage,
    required this.logoImage,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    var favoritesBox = Hive.box<Car>('favorites');
    bool isFavorite = favoritesBox.containsKey(carName);
    bool canManageCars = currentUser != null &&
        (currentUser!.role == 'admin' || currentUser!.role == 'manager');
    bool canManageFavorites =
        currentUser != null && currentUser!.role == 'user';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetailsPage(
              carName: carName,
              carImage: carImage,
              logoImage: logoImage,
              rating: rating,
              distance: distance,
              maxSpeed: '250',
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
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car information UI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(logoImage),
                          radius: 30,
                        ),
                        SizedBox(width: 10),
                        Text(carName,
                            style:
                                TextStyle(color: Colors.white, fontSize: 24)),
                      ],
                    ),
                    Text(recommend,
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    Text('Price: $price',
                        style: TextStyle(color: Colors.white)),
                    Text('Distance: $distance',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
                if (canManageCars)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        // Edit car logic
                      } else if (value == 'delete') {
                        // Delete car logic
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ];
                    },
                  ),
              ],
            ),
            if (canManageFavorites)
              IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red),
                onPressed: () {
                  if (isFavorite) {
                    favoritesBox.delete(carName);
                  } else {
                    favoritesBox.put(
                        carName,
                        Car(
                            name: carName,
                            price: price,
                            distance: distance,
                            image: carImage));
                  }
                },
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

class ManageCarsPage extends StatefulWidget {
  final User? currentUser;
  ManageCarsPage({required this.currentUser});

  @override
  _ManageCarsPageState createState() => _ManageCarsPageState();
}

class _ManageCarsPageState extends State<ManageCarsPage> {
  final _carBox = Hive.box<Car>('favorites');
  final _formKey = GlobalKey<FormState>();

  String? _carName, _price, _distance, _image;

  void _addCar() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _carBox.add(Car(
          name: _carName!,
          price: _price!,
          distance: _distance!,
          image: _image!));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Cars')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Car Name'),
                onSaved: (value) => _carName = value,
                validator: (value) => value!.isEmpty ? 'Enter car name' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                onSaved: (value) => _price = value,
                validator: (value) => value!.isEmpty ? 'Enter price' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Distance'),
                onSaved: (value) => _distance = value,
                validator: (value) => value!.isEmpty ? 'Enter distance' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Image URL'),
                onSaved: (value) => _image = value,
                validator: (value) => value!.isEmpty ? 'Enter image URL' : null,
              ),
              ElevatedButton(
                onPressed: _addCar,
                child: Text('Add Car'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
