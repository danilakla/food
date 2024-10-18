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
  await Hive.openBox<Car>('carsed'); // Open a box for User objects

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
  List<Car> _cars = []; // List to store added cars

  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  String _deviceManufacturer = 'Неизвестно';
  User? _currentUser; // Current user object
  List<User> _users = []; // List of users

  Future<void> _loadCars() async {
    final carBox = Hive.box<Car>('carsed');
    setState(() {
      _cars = carBox.values.toList();
    });
  }

  void _addCar(Car car) {
    final carBox = Hive.box<Car>('carsed');
    carBox.add(car); // Add the car to Hive storage
    setState(() {
      _cars.add(car); // Update the local list
    });
  }

  // Method to open the form and add a new car
  Future<void> _openAddCarForm() async {
    final newCar = await Navigator.push<Car>(
      context,
      MaterialPageRoute(
        builder: (context) => AddCarForm(),
      ),
    );

    if (newCar != null) {
      _addCar(newCar); // Add the car if the form is submitted with a valid car
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
    _loadCars();
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

  void _deleteCar(String name) {
    setState(() {
      _cars.removeWhere((el) => el.name == name);
    });
  }

  void _updateCar(Car carNew) {
    // Find the car by its name
    Car? carToUpdate = _cars.firstWhere((car) => car.name == carNew.name);
    final carBox = Hive.box<Car>('carsed');

    if (carToUpdate != null) {
      // Update the car's details
      carToUpdate.name = carNew.name;
      carToUpdate.price = carNew.price;
      carToUpdate.distance = carNew.distance;

      // Save the updated car object in Hive
      carBox.delete(carToUpdate.name);
      _deleteCar(carToUpdate.name);
      _addCar(carToUpdate);
      // Optionally, update the list if needed
      int index = _cars.indexOf(carToUpdate);
      _cars[index] = carToUpdate;

      print('Car updated successfully');
    } else {
      print('Car not found');
    }
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
                      icon: Icon(Icons.add),
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
                      ListView.builder(
                        itemCount: _cars.length,
                        itemBuilder: (context, index) {
                          final car = _cars[index];
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
                              onDelete: _deleteCar,
                              upData: _updateCar);
                        },
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
  final Function onDelete;
  final Function upData;

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
    required this.onDelete, // Pass the delete callback
    required this.upData, // Pass the delete callback
  });

  @override
  Widget build(BuildContext context) {
    var favoritesBox = Hive.box<Car>('favorites');
    bool isFavorite = favoritesBox.containsKey(carName);
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
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        if (isFavorite) {
                          favoritesBox.delete(carName); // Remove from favorites
                        } else {
                          favoritesBox.put(
                              carName,
                              Car(
                                  name: carName,
                                  price: price,
                                  distance: distance,
                                  image: carImage)); // Add to favorites
                        }
                      },
                    ),
                    if (canManageCars)
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          // Add edit functionality
                          _openEditCarForm(context, carName);
                        },
                      ),
                    if (canManageCars)
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.white),
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
        builder: (context) => EditCarForm(
          carName: carName,
          upData: upData,
        ), // Create a new EditCarForm
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
          title: Text("Delete Car"),
          content: Text("Are you sure you want to delete $carName?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Delete the car from Hive
                final carBox = Hive.box<Car>('carsed');
                carBox.delete(carName);
                Navigator.of(context).pop();
                this.onDelete(carName);
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
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

class AddCarForm extends StatefulWidget {
  @override
  _AddCarFormState createState() => _AddCarFormState();
}

class _AddCarFormState extends State<AddCarForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _price = '';
  String _distance = '';
  String _image = 'assets/images/default_car.png'; // Default image path

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Car'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Car Name'),
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
                decoration: InputDecoration(labelText: 'Price'),
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
                decoration: InputDecoration(labelText: 'Distance'),
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
              SizedBox(height: 20),
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
                    Navigator.pop(context, newCar); // Pass the car back
                  }
                },
                child: Text('Add Car'),
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
  final Function upData;

  EditCarForm({required this.carName, required this.upData});

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
        title: Text("Edit Car"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _price ?? '0', // Use default if null
                decoration: InputDecoration(labelText: 'Price'),
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
                decoration: InputDecoration(labelText: 'Distance'),
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
              SizedBox(height: 20),
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
                    widget.upData(updatedCar);
                  }
                },
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
