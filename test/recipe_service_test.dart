import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:moon_cake_app/recipe.dart';
import 'package:moon_cake_app/recipe_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('saveRecipe creates a sqlite database and stores the recipe', () async {
    final service = RecipeService(databaseName: 'recipe_service_test.db');
    final dbDirectory = await getDatabasesPath();
    final dbFile = File('${dbDirectory}${Platform.pathSeparator}recipe_service_test.db');

    if (await dbFile.exists()) {
      await dbFile.delete();
    }

    final recipe = Recipe(
      name: 'Test recipe',
      type: 'dough',
      style: 'Cantonese style',
      description: 'Persisted via sqlite',
      ingredients: [
        Ingredient(name: 'Flour', amount: 100, unit: 'g'),
      ],
      isFavorite: true,
      rating: 4.5,
    );

    await service.saveRecipe(recipe);
    final recipes = await service.loadRecipes();

    expect(await dbFile.exists(), isTrue);
    expect(recipes.any((item) => item.name == 'Test recipe'), isTrue);
  });
}
