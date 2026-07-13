import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:moon_cake_app/recipe.dart';
import 'package:moon_cake_app/service_2.dart';
import 'package:moon_cake_app/task.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('saveRecipe creates a sqlite database and stores the recipe', () async {
    final service = MCService(databaseName: 'recipe_service_test.db');
    final dbDirectory = await getDatabasesPath();
    final dbFile = File('${dbDirectory}${Platform.pathSeparator}recipe_service_test.db');

    if (await dbFile.exists()) {
      await dbFile.delete();
    }

    final testRecipe = Recipe(
      id: 1,
      name: 'Test recipe',
      type: RecipeType.dough,
      doughType: 'Cantonese style',
      description: 'Persisted via sqlite',
      ingredients: [
        Ingredient(id:11, name: 'Flour', amount: 100, unit: 'g'),
      ],
      isFavorite: true,
      rating: 4.5,
    );

    await service.saveRecipe(testRecipe);
    final recipes = await service.loadRecipes();

    expect(await dbFile.exists(), isTrue);
    expect(recipes.any((item) => item.name == 'Test recipe'), isTrue);
  });

  test('saveTask creates tasks and task_ingredients tables and stores task data', () async {
    final service = MCService(databaseName: 'task_service_test.db');
    final dbDirectory = await getDatabasesPath();
    final dbFile = File('${dbDirectory}${Platform.pathSeparator}task_service_test.db');

    if (await dbFile.exists()) {
      await dbFile.delete();
    }
    
    final task = Task(
      id: 1,  
      doughRecipe: Recipe.fromMap(  {
        'id': '1',
        'name': 'Cantonese Dough',
        'type': RecipeType.dough.toString(),
        'doughType': 'Cantonese style',
        'fillingType': null,
        'description': 'A test dough recipe',
        'ingredients': [
          {'name': 'Flour', 'amount': 200.0, 'unit': 'g'},
          {'name': 'Sugar', 'amount': 50.0, 'unit': 'g'},
        ],
        'isFavorite': true,
        'rating': 4.5,
      } ),
      fillingRecipe: Recipe.fromMap(  {
        'id': '2',
        'name': 'Red Bean Filling',
        'type': RecipeType.filling.toString(),
        'doughType': null,
        'fillingType': 'Red Bean',
        'description': 'A test filling recipe',
        'ingredients': [
          {'name': 'Red Bean', 'amount': 300.0, 'unit': 'g'},
          {'name': 'Sugar', 'amount': 100.0, 'unit': 'g'},
        ],
        'isFavorite': false,
        'rating': 4.0,
      } ),

      size: 100,
      quantity: 8,
      ratio: '4:6',
      ingredients: [
        TaskIngredient(type: 'Dough', name: 'Flour', amount: 320.0, unit: 'g'),
        TaskIngredient(type: 'Filling', name: 'Red Bean', amount: 480.0, unit: 'g'),
      ],
    );

    final taskId = await service.saveTask(task);
    final tasks = await service.loadTasks();

    expect(taskId, greaterThan(0));
    expect(tasks.isNotEmpty, isTrue);
    expect(tasks.first.doughRecipe, 'Cantonese Dough');
    expect(tasks.first.fillingRecipe, 'Red Bean Filling');
    expect(tasks.first.ingredients.length, 2);
    expect(tasks.first.ingredients.first.name, 'Flour');
  });
}

