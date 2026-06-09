import 'package:flutter/material.dart';
import 'app_bottom_navigation.dart';

class RecipeDetailsPage extends StatelessWidget {
  final String recipeName;

  const RecipeDetailsPage({super.key, required this.recipeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('$recipeName - Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipeName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Ingredients',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                '• Ingredient 1\n'
                '• Ingredient 2\n'
                '• Ingredient 3\n'
                '• Ingredient 4',
              ),
              const SizedBox(height: 24),
              Text(
                'Instructions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Step 1\n'
                '2. Step 2\n'
                '3. Step 3\n'
                '4. Step 4',
              ),
              const SizedBox(height: 24),
              Text(
                'Cooking Time',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('30 minutes'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Back'),
                ),
              ),
            ],
          ),
       
        ),
      ),
       bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
    );
  }
}
