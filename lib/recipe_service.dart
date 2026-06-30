import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:xml/xml.dart';
import 'recipe.dart';
import 'task.dart';

class RecipeService {
  RecipeService({String? databaseName}) : _databaseName = databaseName ?? 'recipes.db';

  static Database? _database;
  final String _databaseName;

  Future<List<Recipe>> loadRecipes() async {
    final database = await _databaseInstance();
    final recipeMaps = await database.query('recipes', orderBy: 'id');

    final recipes = <Recipe>[];
    for (final recipeMap in recipeMaps) {
      final ingredientMaps = await database.query(
        'recipe_ingredients',
        where: 'recipe_id = ?',
        whereArgs: [recipeMap['id']],
        orderBy: 'id',
      );

      recipes.add(
        Recipe(
          name: recipeMap['name'] as String,
          type: recipeMap['type'] as String,
          style: recipeMap['style'] as String?,
          fillingType: recipeMap['filling_type'] as String?,
          description: recipeMap['description'] as String,
          ingredients: ingredientMaps.map((ingredientMap) {
            return Ingredient(
              name: ingredientMap['name'] as String,
              amount: (ingredientMap['amount'] as num).toDouble(),
              unit: ingredientMap['unit'] as String,
            );
          }).toList(),
          isFavorite: (recipeMap['is_favorite'] as int) == 1,
          rating: (recipeMap['rating'] as num).toDouble(),
        ),
      );
    }

    return recipes;
  }

  Future<String?> saveRecipe(Recipe recipe) async {
    final database = await _databaseInstance();

    final recipeId = await database.insert('recipes', {
      'name': recipe.name,
      'type': recipe.type,
      'style': recipe.style,
      'filling_type': recipe.fillingType,
      'description': recipe.description,
      'is_favorite': recipe.isFavorite ? 1 : 0,
      'rating': recipe.rating,
    });

    for (final ingredient in recipe.ingredients) {
      await database.insert('recipe_ingredients', {
        'recipe_id': recipeId,
        'name': ingredient.name,
        'amount': ingredient.amount,
        'unit': ingredient.unit,
      });
    }

    return null;
  }

  Future<int> saveTask(Task task) async {
    final database = await _databaseInstance();

    final taskId = await database.insert('tasks', task.toMap());

    for (final ingredient in task.ingredients) {
      await database.insert('task_ingredients', {
        'task_id': taskId,
        'section': ingredient.section,
        'name': ingredient.name,
        'amount': ingredient.amount,
        'unit': ingredient.unit,
      });
    }

    return taskId;
  }

  Future<List<Task>> loadTasks() async {
    final database = await _databaseInstance();
    final taskMaps = await database.query('tasks', orderBy: 'created_at DESC');

    final tasks = <Task>[];
    for (final taskMap in taskMaps) {
      final ingredientMaps = await database.query(
        'task_ingredients',
        where: 'task_id = ?',
        whereArgs: [taskMap['id']],
        orderBy: 'id',
      );

      tasks.add(
        Task(
          id: taskMap['id'] as int,
          doughRecipeName: taskMap['dough_recipe_name'] as String,
          fillingRecipeName: taskMap['filling_recipe_name'] as String,
          size: taskMap['size'] as int,
          quantity: taskMap['quantity'] as int,
          ratio: taskMap['ratio'] as String,
          ingredients: ingredientMaps.map((ingredientMap) {
            return TaskIngredient(
              section: ingredientMap['section'] as String,
              name: ingredientMap['name'] as String,
              amount: (ingredientMap['amount'] as num).toDouble(),
              unit: ingredientMap['unit'] as String,
            );
          }).toList(),
          createdAt: DateTime.parse(taskMap['created_at'] as String),
        ),
      );
    }

    return tasks;
  }

  Future<Database> _databaseInstance() async {
    if (_database != null) {
      return _database!;
    }

    final databaseDirectory = await getDatabasesPath();
    final databasePath = '${databaseDirectory}${Platform.pathSeparator}$_databaseName';

    _database = await openDatabase(
      databasePath,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE recipes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            style TEXT,
            filling_type TEXT,
            description TEXT NOT NULL,
            is_favorite INTEGER NOT NULL DEFAULT 0,
            rating REAL NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE recipe_ingredients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            recipe_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            amount REAL NOT NULL,
            unit TEXT NOT NULL,
            FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            dough_recipe_name TEXT NOT NULL,
            filling_recipe_name TEXT NOT NULL,
            size INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            ratio TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE task_ingredients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            task_id INTEGER NOT NULL,
            section TEXT NOT NULL,
            name TEXT NOT NULL,
            amount REAL NOT NULL,
            unit TEXT NOT NULL,
            FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE recipes ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE recipes ADD COLUMN rating REAL NOT NULL DEFAULT 0');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE tasks (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              dough_recipe_name TEXT NOT NULL,
              filling_recipe_name TEXT NOT NULL,
              size INTEGER NOT NULL,
              quantity INTEGER NOT NULL,
              ratio TEXT NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE task_ingredients (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              task_id INTEGER NOT NULL,
              section TEXT NOT NULL,
              name TEXT NOT NULL,
              amount REAL NOT NULL,
              unit TEXT NOT NULL,
              FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
            )
          ''');
        }
      },
    );

    await _seedFromXmlIfNeeded(_database!);
    return _database!;
  }

  Future<void> _seedFromXmlIfNeeded(Database database) async {
    final count = Sqflite.firstIntValue(
      await database.rawQuery('SELECT COUNT(*) FROM recipes'),
    );

    if (count != null && count > 0) {
      return;
    }

    final xml = await rootBundle.loadString('assets/recipes.xml');
    final document = XmlDocument.parse(xml);
    final recipeNodes = document.findAllElements('recipe');

    for (final node in recipeNodes) {
      final recipeId = await database.insert('recipes', {
        'name': node.findElements('name').first.innerText,
        'type': node.findElements('type').first.innerText,
        'style': node.findElements('style').isNotEmpty
            ? node.findElements('style').first.innerText
            : null,
        'filling_type': node.findElements('filling_type').isNotEmpty
            ? node.findElements('filling_type').first.innerText
            : null,
        'description': node.findElements('description').first.innerText,
        'is_favorite': 0,
        'rating': 0,
      });

      final ingredientNodes = node
          .findElements('ingredients')
          .first
          .findElements('ingredient');

      for (final ingredientNode in ingredientNodes) {
        await database.insert('recipe_ingredients', {
          'recipe_id': recipeId,
          'name': ingredientNode.getAttribute('name')!,
          'amount': double.parse(ingredientNode.getAttribute('amount')!),
          'unit': ingredientNode.getAttribute('unit')!,
        });
      }
    }
  }
}
