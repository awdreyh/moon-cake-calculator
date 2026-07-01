import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:moon_cake_app/recipe.dart';
import 'package:moon_cake_app/recipe_service.dart';
import 'package:moon_cake_app/task.dart';
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

  test('saveTask creates tasks and task_ingredients tables and stores task data', () async {
    final service = RecipeService(databaseName: 'task_service_test.db');
    final dbDirectory = await getDatabasesPath();
    final dbFile = File('${dbDirectory}${Platform.pathSeparator}task_service_test.db');

    if (await dbFile.exists()) {
      await dbFile.delete();
    }

    final task = Task(
      doughRecipeName: 'Cantonese Dough',
      fillingRecipeName: 'Red Bean Filling',
      size: 100,
      quantity: 8,
      ratio: '4:6',
      ingredients: [
        TaskIngredient(section: 'Dough', name: 'Flour', amount: 320.0, unit: 'g'),
        TaskIngredient(section: 'Filling', name: 'Red Bean', amount: 480.0, unit: 'g'),
      ],
    );

    final taskId = await service.saveTask(task);
    final tasks = await service.loadTasks();

    expect(taskId, greaterThan(0));
    expect(tasks.isNotEmpty, isTrue);
    expect(tasks.first.doughRecipeName, 'Cantonese Dough');
    expect(tasks.first.fillingRecipeName, 'Red Bean Filling');
    expect(tasks.first.ingredients.length, 2);
    expect(tasks.first.ingredients.first.name, 'Flour');
  });
}

