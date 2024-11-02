import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class CarDetailsPage extends StatelessWidget {
  final String carName;
  final String carImage;
  final String logoImage;
  final double rating;
  final String distance;
  final String maxSpeed;
  final String power;
  final String price;
  final String description =
      "The car will give you unforgettable comfort and feeling of great space.";
  final String safetyNotice =
      "For your safety, we recommend not exceeding the speed limit.";

  const CarDetailsPage({
    super.key,
    required this.carName,
    required this.carImage,
    required this.logoImage,
    required this.rating,
    required this.distance,
    required this.maxSpeed,
    required this.power,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
          255, 20, 19, 25), // Adjust background to match the real design
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        backgroundColor: const Color.fromARGB(255, 252, 235, 117),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [
          Icon(Icons.tune, color: Colors.black), // Settings or filter icon
          SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          // Car Image as the background container
          Stack(
            children: [
              Container(
                child: Container(
                  height: 457,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/images/image4.png'), // Car image as the background
                        fit: BoxFit.fill,
                      ),
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          children: [
                            Text(
                              'Car Detail',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              'Model 360° ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            // Car Name and Logo
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: AssetImage(logoImage),
                                  radius: 25, // Adjust logo size as per design
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  carName,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            // Model 360 angle text

                            const SizedBox(height: 15),
                            // Car Description
                            Text(
                              description,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 67, 67, 67),
                                fontSize: 14,
                              ),
                            ),
                            // Safety Icon and Notice
                            const Row(
                              children: [
                                Icon(Icons.shield, color: Colors.black),
                                SizedBox(width: 5),
                                Text(
                                  "For your safety, ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "we recommend not exceeding the speed limit.",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.fromLTRB(3, 8, 3, 8),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          const Color.fromRGBO(61, 61, 61, 1)),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      backgroundImage:
                                          AssetImage('assets/images/face.png'),
                                      radius: 12,
                                    ),
                                    const SizedBox(width: 5),
                                    const CircleAvatar(
                                      backgroundImage:
                                          AssetImage('assets/images/face.png'),
                                      radius: 12,
                                    ),
                                    const SizedBox(width: 5),
                                    const CircleAvatar(
                                      backgroundImage:
                                          AssetImage('assets/images/face.png'),
                                      radius: 12,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '$rating ★',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    // Reviews text and Arrow Icon
                                    const Text(
                                      'Reviews',
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 176, 127, 190),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      Icons.arrow_circle_right_sharp,
                                      size: 20,
                                      color: Color.fromARGB(255, 176, 127, 190),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          // Row with Avatars and Rating

          // Car Features (distance, speed, power)

          Container(
            decoration:
                const BoxDecoration(color: Color.fromARGB(255, 20, 19, 25)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                      padding: const EdgeInsets.all(30),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Color.fromARGB(255, 36, 34, 45)),
                      child: const Column(
                        children: [
                          Icon(Icons.battery_5_bar, color: Colors.white),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                '433',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                'km',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        ],
                      )),
                  Container(
                      padding: const EdgeInsets.all(28),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Color.fromARGB(255, 36, 34, 45)),
                      child: Column(
                        children: [
                          const Icon(Icons.lock_clock, color: Colors.white),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                maxSpeed,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              const Text(
                                'km/h',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        ],
                      )),
                  Container(
                      padding: const EdgeInsets.all(30),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Color.fromARGB(255, 36, 34, 45)),
                      child: Column(
                        children: [
                          const Icon(Icons.power, color: Colors.white),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                power,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              const Text(
                                'kW',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        ],
                      )),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Booking Section
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 20, 19, 25),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // Changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              price,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const Text(
              '/1 day',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            ElevatedButton(
                onPressed: () {
                  // Booking logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 176, 127, 190),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Row(
                  children: [
                    Text(
                      'Book Car',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.arrow_forward,
                        color: Color.fromARGB(255, 255, 255, 255)),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
