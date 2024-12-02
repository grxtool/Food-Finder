import 'package:flutter/material.dart';
import 'package:foodfinderproject/pages/food_detail.dart';

class FoodSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, String>> foodItems = [
      {'image': 'assets/piz1.jpg', 'name': 'Hawaiian Overload', 'price': '195',},
      {'image': 'assets/piz2.jpg', 'name': 'Meat Overload', 'price': '250', },
      {'image': 'assets/piz3.jpg', 'name': 'Beef and Mushroom', 'price': '195', },
      {'image': 'assets/piz4.jpg', 'name': 'Hawaiian', 'price': '175', },
      {'image': 'assets/piz5.jpg', 'name': 'Ham and Cheese', 'price': '175', },
      {'image': 'assets/piz6.jpg', 'name': 'All Cheese', 'price': '195', },
      {'image': 'assets/piz7.jpg', 'name': 'Mad Cow', 'price': '215', },
      {'image': 'assets/piz8.jpg', 'name': 'Cheesy Hotdog', 'price': '175', },
      {'image': 'assets/piz9.jpg', 'name': 'Pepperoni Pizza', 'price': '215',},
      {'image': 'assets/piz10.jpg', 'name': 'Tuna Delight', 'price': '195', },
      {'image': 'assets/piz11.jpg', 'name': 'Garden Special', 'price': '185', },

  ];

  final Function(String, String) addFeedback;
  final Function(Map<String, String>, int) addToCart;

  FoodSearchDelegate({required this.addFeedback, required this.addToCart});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // Clear the search query
        },
      ),
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = foodItems
        .where((food) => food['name']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Text('No food items found for "$query"'),
      );
    }

    final foodItem = results.first;

    return Column(
      children: [
        ListTile(
          leading: Image.asset(foodItem['image']!),
          title: Text(foodItem['name']!),
          subtitle: Text('₱${foodItem['price']}'),  // Add "₱" here for price display
        ),
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Text('Start typing to search for food items'),
      );
    }

    final suggestions = foodItems
        .where((food) => food['name']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (suggestions.isEmpty) {
      return Center(
        child: Text('No food items found for "$query"'),
      );
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final foodItem = suggestions[index];
        return ListTile(
          leading: Image.asset(foodItem['image']!),
          title: Text(foodItem['name']!),
          subtitle: Text('₱${foodItem['price']}'),  // Add "₱" here for price display
          onTap: () {
            query = foodItem['name']!;
            close(context, foodItem['name']!);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodDetailPage(
                  foodItem: foodItem,
                  addFeedback: addFeedback,
                  addToCart: addToCart, userEmail: '', userName: '', foodName: '', description: '', price: '',
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, ''); // Close the search bar
      },
    );
  }
}
