import 'package:flutter/material.dart';
import 'package:food/main.dart';
import 'package:provider/provider.dart';

class CarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CarProvider>(context);

    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final distanceController = TextEditingController();
    final imageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text("Car Manager")),
      body: Column(
        children: [
          TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name')),
          TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price')),
          TextField(
              controller: distanceController,
              decoration: InputDecoration(labelText: 'Distance')),
          TextField(
              controller: imageController,
              decoration: InputDecoration(labelText: 'Image')),
          ElevatedButton(
            onPressed: () {
              final car = Car(
                name: nameController.text,
                price: priceController.text,
                distance: distanceController.text,
                image: imageController.text,
              );
              provider.addCarTest(car);
            },
            child: Text('Add Car'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: provider.cars.length,
              itemBuilder: (context, index) {
                final car = provider.cars[index];
                return Dismissible(
                  key: Key(car.name),
                  onDismissed: (_) {
                    provider.deleteTest(car.name);
                  },
                  child: ListTile(
                    title: Text(car.name),
                    subtitle: Text(car.price),
                    onTap: () {
                      // Update logic (для тестов tap)
                      provider.updateCarTest(car);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
