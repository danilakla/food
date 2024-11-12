import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food/car_model.dart';
import 'package:food/details.dart';
import 'package:food/firebase_options.dart';
import 'package:github_sign_in/github_sign_in.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting
import 'package:device_info/device_info.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();

  Hive.registerAdapter(CarAdapter()); // Register the adapter
  // await Hive.openBox<Car>('favorites'); // Open a box for User objects
  // await Hive.openBox<Car>('carsed'); // Open a box for User objects

  // Hive.registerAdapter(UserAdapter()); // Register the adapter
  // await Hive.openBox<User>('users'); // Open a box for User objects
  // final userBox = Hive.box<User>('users');

  // final newUser1 = User(name: 'Jon', role: "user");
  // final newUser2 = User(name: 'Ban', role: "manager");
  // final newUser3 = User(name: 'Ton', role: "admin");

  // userBox.add(newUser3);
  // userBox.add(newUser1);
  // userBox.add(newUser2);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CarProvider()),
      ],
      child: MaterialApp(
        home: AuthenticationWrapper(),
      ),
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
  // User? _currentUser; // Current user object
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
    // _loadUsers();
    // Provider.of<CarProvider>(context, listen: false).loadAll();
    // _loadCars();
  }

  // Future<void> _loadUsers() async {
  //   final userBox = Hive.box<User>('users');

  //   setState(() {
  //     _users = userBox.values.toList();
  //     if (_users.isNotEmpty) {
  //       _currentUser = _users.first; // Set the first user as default
  //     }
  //   });
  // }

  // void _switchUser(User user) {
  //   setState(() {
  //     _currentUser = user;
  //   });
  // }

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
                  if (true)
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.white),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserProfileScreen(),
                              ),
                            );
                          },
                          child: Text('View User Profile'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FCMDemo(),
                              ),
                            );
                          },
                          child: Text('Chat'),
                        ),
                      ],
                    ),
                  if (true)
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
              // onSelected: _switchUser,
              itemBuilder: (context) {
                return _users.map((user) {
                  return PopupMenuItem(
                    value: user,
                    child: Text('da'),
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
                            currentUser: null,
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
    bool isFavorite = false;
    // Provider.of<CarProvider>(context).carFavoeiteBox.containsKey(carName);
    bool canManageCars = true;
    // (currentUser!.role == 'admin' || currentUser!.role == 'manager');

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
    final carProvider = Provider.of<CarProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Cars'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: carProvider._favoritesCollection.snapshots()
            as Stream<QuerySnapshot<Map<String, dynamic>>>,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          List<Car> favoriteCars = snapshot.data!.docs
              .map((doc) => Car.fromJson(doc.data()))
              .toList();

          return favoriteCars.isEmpty
              ? const Center(
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
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Remove from favorites
                          carProvider.deleteFromFavorite(car.name);
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

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // User is signed in
          return RentalCarApp(); // Navigate to RentalCarApp
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          // User is not signed in
          return AuthenticationScreen(); // Show the AuthenticationScreen
        }
      },
    );
  }
}

class AuthenticationScreen extends StatefulWidget {
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUpMode = true; // Start in sign-up mode

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text);
      // Display a success message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent!')),
      );
    } on FirebaseAuthException catch (e) {
      // Handle errors (e.g., user not found)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final carProvider = Provider.of<CarProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUpMode ? 'Sign Up' : 'Sign In'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_isSignUpMode) {
                      carProvider.signUpWithEmailAndPassword(
                          _emailController.text, _passwordController.text);
                    } else {
                      carProvider.signInWithEmailAndPassword(
                          _emailController.text, _passwordController.text);
                    }
                  }
                },
                child: Text(_isSignUpMode ? 'Sign Up' : 'Sign In'),
              ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSignUpMode = !_isSignUpMode;
                  });
                },
                child: Text(_isSignUpMode
                    ? 'Already have an account? Sign In'
                    : 'Don\'t have an account? Sign Up'),
              ),
              if (!_isSignUpMode) // Show reset password button only for sign-in
                SizedBox(height: 16.0),
              if (!_isSignUpMode)
                ElevatedButton(
                  onPressed: _resetPassword,
                  child: Text('Reset Password'),
                ),
              ElevatedButton(
                onPressed: () {
                  carProvider.signInWithGitHub(context);
                },
                child: Text('Sign In with GitHub'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final carProvider = Provider.of<CarProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (carProvider.getDisplayName() != null)
              Text('Name: ${carProvider.getDisplayName()}'),
            if (carProvider.getEmail() != null)
              Text('Email: ${carProvider.getEmail()}'),
            if (carProvider.getPhotoURL() != null)
              CircleAvatar(
                backgroundImage: NetworkImage(carProvider.getPhotoURL()!),
                radius: 50,
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                carProvider.signOut();
                Navigator.pop(context); // Go back to the previous screen
              },
              child: Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}

class FCMDemo extends StatefulWidget {
  @override
  _FCMDemoState createState() => _FCMDemoState();
}

class _FCMDemoState extends State<FCMDemo> {
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final carProvider = Provider.of<CarProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('FCM Demo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: carProvider.messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(carProvider.messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter message',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    carProvider.sendMessageToTopic(_messageController.text);
                    _messageController.clear();
                  },
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CarProvider with ChangeNotifier {
  late FirebaseFirestore _firestore;
  late CollectionReference _carsCollection;
  late CollectionReference _favoritesCollection;

  List<Car> _cars = [];
  List<Car> _carsFavorite = [];

  List<Car> get cars => _cars;
  List<Car> get carsFavorite => _carsFavorite;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  void subscribeToTopic(String topic) async {
    while (true) {
      final response = await http.get(Uri.parse(
          'http://localhost:3333/get-topicl')); // Replace with your server's URL

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        _messages.clear();
        _messages.addAll(data.cast<String>());
        notifyListeners();
      } else {
        print('Error fetching messages: ${response.statusCode}');
      }
    }
  }

  CarProvider() {
    _firestore = FirebaseFirestore.instance;
    _carsCollection = _firestore.collection('cars');
    _favoritesCollection = _firestore.collection('favorites');
    _loadCars();
    subscribeToTopic("general");
  }
  final List<String> _messages = [];
  List<String> get messages => _messages;

  void sendMessage(String message) {
    _messages.add(message);
    notifyListeners();
  }

  Future<void> sendMessageToTopic(String message) async {
    final url =
        'http://localhost:3333/send-to-topic'; // Replace with your server's URL
    final body = {'message': message, 'topic': "general"};

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Message sent successfully!');
      } else {
        print('Error sending message: ${response.statusCode}');
        // Handle specific error codes here
      }
    } catch (error) {
      print('Error sending message: $error');
    }
  }

  Future<void> _loadCars() async {
    try {
      QuerySnapshot<Map<String, dynamic>> carsSnapshot =
          await _carsCollection.get() as QuerySnapshot<Map<String, dynamic>>;
      _cars = carsSnapshot.docs.map((doc) => Car.fromJson(doc.data())).toList();

      QuerySnapshot<Map<String, dynamic>> carsFavoriteSnapshot =
          await _favoritesCollection.get()
              as QuerySnapshot<Map<String, dynamic>>;
      _carsFavorite = carsFavoriteSnapshot.docs
          .map((doc) => Car.fromJson(doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading cars: $e');
    }
  }

  final GitHubSignIn _githubSignIn = GitHubSignIn(
    clientId: 'Ov23liPdHt7CKkXvxESd',
    clientSecret: '74303612ecb1d02d2d165e90f1c259e634e8d1c7',
    redirectUrl:
        'https://lab11-3c91b.firebaseapp.com/__/auth/handler', // Add your redirect URL here
  );
  Future<void> signInWithGitHub(BuildContext context) async {
    try {
      if (kIsWeb) {
        // For web: Use signInWithPopup
        final GithubAuthProvider authProvider = GithubAuthProvider();
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithPopup(authProvider);
        _currentUser = userCredential.user;
      } else {
        // For non-web platforms: Use signInWithRedirect
        final GitHubSignInResult result = await _githubSignIn.signIn(context);
        String token = result.token ?? "";
        final credential = GithubAuthProvider.credential(token);
        await FirebaseAuth.instance.signInWithCredential(credential);
        _currentUser = FirebaseAuth.instance.currentUser;
      }
      notifyListeners();
    } catch (e) {
      print('Error signing in with GitHub: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in with GitHub: $e')),
      );
    }
  }

  Stream<List<Car>> get carsStream =>
      _carsCollection.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) {
              if (doc.exists) {
                // If the document exists, safely cast doc.data() to Map<String, dynamic>
                return Car.fromJson(doc.data()! as Map<String, dynamic>);
              } else {
                return null; // Return null if the document doesn't exist
              }
            })
            .where((car) => car != null)
            .toList() as List<Car>;
      });

  Future<void> addCar(Car car) async {
    try {
      await _carsCollection.doc(car.name).set(car.toJson());
      _cars.add(car);
      notifyListeners();
    } catch (e) {
      print('Error adding car: $e');
    }
  }

  Future<void> removeCar(Car car) async {
    try {
      await _carsCollection.doc(car.name).delete();
      _cars.remove(car);
      notifyListeners();
    } catch (e) {
      print('Error removing car: $e');
    }
  }

  Future<void> delete(String name) async {
    try {
      await _carsCollection.doc(name).delete();
      _cars.removeWhere((el) => el.name == name);
      notifyListeners();
    } catch (e) {
      print('Error deleting car: $e');
    }
  }

  Future<void> deleteFromFavorite(String id) async {
    try {
      await _favoritesCollection.doc(id).delete();
      _carsFavorite.removeWhere((el) => el.name == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting from favorites: $e');
    }
  }

  Future<void> putFavorite(String carId, Car car) async {
    try {
      await _favoritesCollection.doc(carId).set(car.toJson());
      _carsFavorite.add(car);
      notifyListeners();
    } catch (e) {
      print('Error adding to favorites: $e');
    }
  }

  String? getDisplayName() {
    if (_currentUser != null) {
      return _currentUser!.displayName;
    }
    return null;
  }

  // Method to get the current user's email
  String? getEmail() {
    if (_currentUser != null) {
      return _currentUser!.email;
    }
    return null;
  }

  // Method to get the current user's photo URL
  String? getPhotoURL() {
    if (_currentUser != null) {
      return _currentUser!.photoURL;
    }
    return null;
  }

  Future<void> updateCar(Car carNew) async {
    try {
      await _carsCollection.doc(carNew.name).update(carNew.toJson());
      int index = _cars.indexWhere((car) => car.name == carNew.name);
      if (index != -1) {
        _cars[index] = carNew;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating car: $e');
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  User? get currentUser => _currentUser;

  // Sign Up
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      _currentUser = userCredential.user;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      print('Error signing up: ${e.code}');
      // Handle specific error codes (e.g., weak-password, email-already-in-use)
    } catch (e) {
      print('Error signing up: $e');
    }
  }

  // Sign In
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _currentUser = userCredential.user;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      print('Error signing in: ${e.code}');
      // Handle specific error codes (e.g., wrong-password, user-not-found)
    } catch (e) {
      print('Error signing in: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}

class Car {
  String name;
  String price;
  String distance;
  String image;

  Car({
    required this.name,
    required this.price,
    required this.distance,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'distance': distance,
      'image': image,
    };
  }

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      name: json['name'],
      price: json['price'],
      distance: json['distance'],
      image: json['image'],
    );
  }
}
