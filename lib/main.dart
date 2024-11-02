import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food/car_model.dart';
import 'package:food/details.dart';
import 'package:food/user_model.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting
import 'package:device_info/device_info.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(CarAdapter()); // Register the adapter
  await Hive.openBox<Car>('favorites'); // Open a box for User objects
  await Hive.openBox<Car>('carsed'); // Open a box for User objects

  Hive.registerAdapter(UserAdapter()); // Register the adapter
  await Hive.openBox<User>('users'); // Open a box for User objects
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CarProvider()),
      ],
      child: RentalCarApp(),
    ),
  );
}

class RentalCarApp extends StatelessWidget {
  const RentalCarApp({super.key});

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
  const RentaXHomePage({super.key});

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

  // Method to open the form and add a new car
  Future<void> _openAddCarForm() async {
    // final newCar =
    await Navigator.push<Car>(
      context,
      MaterialPageRoute(
        builder: (context) => AddCarForm(),
      ),
    );

    // if (newCar != null) {
    //   _addCar(newCar); // Add the car if the form is submitted with a valid car
    // }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
    Provider.of<CarProvider>(context, listen: false).loadAll();
    // _loadCars();
  }

  Future<void> _loadUsers() async {
    final userBox = Hive.box<User>('users');

    // final newUser1 = User(name: 'Jon', role: "user");
    // final newUser2 = User(name: 'Ban', role: "manager");
    // final newUser3 = User(name: 'Ton', role: "admin");

    // userBox.add(newUser3);
    // userBox.add(newUser1);
    // userBox.add(newUser2);
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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
                icon: const Icon(Icons.favorite),
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
                  const Icon(Icons.location_pin, color: Colors.white),
                  if (_currentUser != null)
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.white),
                        Text(
                          'User: ${_currentUser!.name}, role: ${_currentUser!.role}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  if (_currentUser != null &&
                      (_currentUser!.role == 'admin' ||
                          _currentUser!.role == 'manager'))
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed:
                          _openAddCarForm, // Open the form to add a new car
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
            const Icon(Icons.notifications_none, color: Colors.white),
            const Padding(
              padding: EdgeInsets.all(4.0),
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
                  const SizedBox(height: 10),

                  const Text(
                    "Premium",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 54,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                  const Text(
                    "& Rental Car",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 54,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Horizontal Tab Menu
                  Container(
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      tabs: const [
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
                  const SizedBox(height: 20),
                  // Date Selector with Down Arrow
                  Row(
                    children: [
                      Column(
                        children: [
                          const Row(children: [
                            Text(
                              'Choose Date: ',
                              style: TextStyle(
                                color: Color.fromARGB(255, 101, 101, 101),
                                fontSize: 13,
                              ),
                            ),
                            Icon(Icons.calendar_today,
                                size: 13,
                                color: Color.fromARGB(255, 101, 101, 101)),
                          ]),
                          Row(children: [
                            const Icon(Icons.check_circle,
                                color: Color.fromARGB(255, 50, 242, 56)),
                            const SizedBox(width: 5),
                            const Text(
                              'Today ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              DateFormat('dd MMMM').format(_selectedDate),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.arrow_drop_down,
                                color: Colors.greenAccent),
                          ])
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _selectDate(context),
                        icon: const Icon(Icons.calendar_today,
                            color: Colors.white),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        color: Colors.white30,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.grid_view, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  PageView(
                    children: [
                      ListView.builder(
                        itemCount:
                            Provider.of<CarProvider>(context)._cars.length,
                        itemBuilder: (context, index) {
                          final car =
                              Provider.of<CarProvider>(context)._cars[index];
                          return CarCard(
                            colorCircle: Colors.blue,
                            carName: car.name,
                            rating: 4.5, // Static rating for demo purposes
                            recommend: 'Recommended by users',
                            price: car.price,
                            distance: car.distance,
                            carImage: 'assets/images/image1.png',
                            logoImage:
                                'assets/images/pors.png', // Static logo for demo purposes
                            currentUser: _currentUser,
                          );
                        },
                      ),
                    ],
                  ),
                  // You can add content for the "Exclusive" tab here
                  const Center(
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
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0)),
            color: Color.fromARGB(255, 49, 49, 49),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.transparent,
            unselectedItemColor: Colors.transparent,
            selectedLabelStyle: const TextStyle(backgroundColor: Colors.white),
            items: const [
              BottomNavigationBarItem(
                  backgroundColor: Color.fromARGB(255, 49, 49, 49),
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
  final User? currentUser;

  const CarCard(
      {super.key,
      required this.colorCircle,
      required this.carName,
      required this.rating,
      required this.recommend,
      required this.price,
      required this.distance,
      required this.carImage,
      required this.logoImage,
      required this.currentUser});

  @override
  Widget build(BuildContext context) {
    bool isFavorite =
        Provider.of<CarProvider>(context).carFavoeiteBox.containsKey(carName);
    bool canManageCars = currentUser != null &&
        (currentUser!.role == 'admin' || currentUser!.role == 'manager');

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
        padding: const EdgeInsets.all(15),
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
                        const SizedBox(width: 10),
                        Text(carName,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 24)),
                      ],
                    ),
                    Text(recommend,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16)),
                    Text('Price: $price',
                        style: const TextStyle(color: Colors.white)),
                    Text('Distance: $distance',
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        if (isFavorite) {
                          Provider.of<CarProvider>(context, listen: false)
                              .deleteFromFavorite(carName);
                        } else {
                          Provider.of<CarProvider>(context, listen: false)
                              .putFavorite(
                                  carName,
                                  Car(
                                      name: carName,
                                      price: price,
                                      distance: distance,
                                      image: carImage));
                        }
                      },
                    ),
                    if (canManageCars)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          // Add edit functionality
                          _openEditCarForm(context, carName);
                        },
                      ),
                    if (canManageCars)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () {
                          // Delete car confirmation
                          _confirmDeleteCar(context, carName);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditCarForm(BuildContext context, String carName) async {
    // Implement logic to open edit form
    // You may want to pass the current details of the car to the edit form
    final updatedCar = await Navigator.push<Car>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditCarForm(carName: carName), // Create a new EditCarForm
      ),
    );

    if (updatedCar != null) {
      // Update car details in Hive and local state if edit is successful
      final carBox = Hive.box<Car>('carsed');
      carBox.put(carName, updatedCar);
    }
  }

  void _confirmDeleteCar(BuildContext context, String carName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Car"),
          content: Text("Are you sure you want to delete $carName?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Delete the car from Hive

                Navigator.of(context).pop();
                Provider.of<CarProvider>(context, listen: false)
                    .delete(carName);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the favorites box
    final carProvider = Provider.of<CarProvider>(context);

    var favoritesBox = carProvider.carFavoeiteBox;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Cars'),
      ),
      body: ValueListenableBuilder(
        valueListenable: favoritesBox.listenable(), // Listen for changes
        builder: (context, Box<Car> box, _) {
          var favoriteCars = carProvider.carFavoeiteBox;

          return carProvider._carsFavorite.isEmpty
              ? const Center(
                  child: Text('No favorite cars yet.'),
                )
              : ListView.builder(
                  itemCount: carProvider._carsFavorite.length,
                  itemBuilder: (context, index) {
                    final car = carProvider._carsFavorite[index];
                    return ListTile(
                      leading: Image.asset(car.image),
                      title: Text(car.name),
                      subtitle: Text('${car.price} - ${car.distance} km'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Remove from favorites
                          Provider.of<CarProvider>(context, listen: false)
                              .deleteFromFavorite(
                                  car.name); // Удалить из избранного
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

class AddCarForm extends StatefulWidget {
  const AddCarForm({super.key});

  @override
  _AddCarFormState createState() => _AddCarFormState();
}

class _AddCarFormState extends State<AddCarForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _price = '';
  String _distance = '';
  final String _image = 'assets/images/default_car.png'; // Default image path

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Car'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Car Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a car name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
                onSaved: (value) {
                  _price = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Distance'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a distance';
                  }
                  return null;
                },
                onSaved: (value) {
                  _distance = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final newCar = Car(
                      name: _name,
                      price: _price,
                      distance: _distance,
                      image: _image,
                    );
                    Provider.of<CarProvider>(context, listen: false)
                        .addCar(newCar);
                    Navigator.pop(context, newCar); // Pass the car back
                  }
                },
                child: const Text('Add Car'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditCarForm extends StatefulWidget {
  final String carName;

  const EditCarForm({super.key, required this.carName});

  @override
  _EditCarFormState createState() => _EditCarFormState();
}

class _EditCarFormState extends State<EditCarForm> {
  final _formKey = GlobalKey<FormState>();
  String? _price; // Use nullable type to avoid initialization issues
  String? _distance;

  @override
  void initState() {
    super.initState();
    _price = '0'; // Provide a default value to avoid null errors
    _distance = '0';
    _loadCarDetails();
  }

  Future<void> _loadCarDetails() async {
    final carBox = Hive.box<Car>('carsed');
    Car? car = carBox.get(widget.carName);
    if (car != null) {
      setState(() {
        _price = car.price;
        _distance = car.distance;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Car"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _price ?? '0', // Use default if null
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
                onSaved: (value) {
                  _price = value!;
                },
              ),
              TextFormField(
                initialValue: _distance ?? '0', // Use default if null
                decoration: const InputDecoration(labelText: 'Distance'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a distance';
                  }
                  return null;
                },
                onSaved: (value) {
                  _distance = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final updatedCar = Car(
                        name: widget.carName,
                        price: _price!,
                        distance: _distance!,
                        image: ''); // Update image as needed
                    Navigator.pop(
                        context, updatedCar); // Return the updated car
                    Provider.of<CarProvider>(context, listen: false)
                        .updateCar(updatedCar);
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CarProvider with ChangeNotifier {
  List<Car> _cars = [];
  List<Car> _carsFavorite = [];
  final Box<Car> carBox = Hive.box<Car>('carsed'); // Connects to Hive
  final Box<Car> carFavoeiteBox =
      Hive.box<Car>('favorites'); // Connects to Hive

  List<Car> get cars => _cars;
  List<Car> get carsFavorite => _carsFavorite;

  void addCar(Car car) {
    _cars.add(car);
    carBox.put(car.name, car); // Add to Hive
    notifyListeners();
  }

  void loadAll() {
    _cars = carBox.values.toList();
    _carsFavorite = carFavoeiteBox.values.toList();
    notifyListeners();
  }

  void removeCar(Car car) {
    _cars.remove(car);
    carBox.delete(car.name); // Remove from Hive
    notifyListeners();
  }

  void delete(String name) {
    carBox.delete(name); // Remove from Hive

    _cars.removeWhere((el) => el.name == name);
    notifyListeners();
  }

  void deleteFromFavorite(String key) {
    this.carFavoeiteBox.delete(key);
    _carsFavorite.removeWhere((el) => el.name == key);
    notifyListeners();
  }

  void putFavorite(String carName, Car car) {
    this.carFavoeiteBox.put(carName, car);
    this._carsFavorite.add(car);
    notifyListeners();
  }

  void updateCar(Car carNew) {
    Car? carToUpdate = _cars.firstWhere((car) => car.name == carNew.name);

    carToUpdate.name = carNew.name;
    carToUpdate.price = carNew.price;
    carToUpdate.distance = carNew.distance;

    delete(carToUpdate.name);
    addCar(carToUpdate);

    print('Car updated successfully');
    notifyListeners();
  }
}
