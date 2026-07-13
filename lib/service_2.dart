import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:xml/xml.dart';
import 'recipe.dart';
import 'task.dart';


class MCService {
  MCService({String? databaseName}) : _databaseName = databaseName ?? 'mooncake.db';
  static Database? _database;
  final String _databaseName;

  Future<Recipe?> getRecipeById(String id) async {
  final db = await _databaseInstance();
  final result = await db.query(
    'recipe',
    where: 'id = ?',
    whereArgs: [id],
  );

  if (result.isNotEmpty) {
    return Recipe.fromMap(result.first);
  } else {
    return null;
  }
}

  Future<List<Recipe>> loadRecipes() async {
    final database = await _databaseInstance();
    final List<Map<String, Object?>> recipeMaps = await database.query('recipes');
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
          id: recipeMap['id'] as int,
          name: recipeMap['name'] as String,   
          type: RecipeType.values.firstWhere((t) => t.toString() == recipeMap['type']),
          doughType: recipeMap['dough_type'] as String?,
          fillingType: recipeMap['filling_type'] as String?,
          description: recipeMap['description'] as String,
          ingredients: ingredientMaps.map((ingredientMap) {
            return Ingredient(
              id: ingredientMap['id'] as int,
              name: ingredientMap['name'] as String,
              amount: (ingredientMap['amount'] as num).toDouble(),
              unit: ingredientMap['unit'] as String,
            );
          }).toList(),
          isFavorite: (recipeMap['is_favorite'] as int) == 1,
          rating: (recipeMap['rating'] as num).toDouble(),
          url: recipeMap['url'] as String?,
          comment: recipeMap['comment'] as String?,
        ),
      );
    }

    return recipes;
  }

  Future<int?> saveRecipe(Recipe recipe) async {
    final database = await _databaseInstance();
    final recipeId = await database.insert('recipes', 
    recipe.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,);

    for (final ingredient in recipe.ingredients) {
      await database.insert('recipe_ingredients',
      ingredient.toMap(),
       conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    return recipeId;
  }

  Future<int> saveTask(Task task) async {
    final database = await _databaseInstance();

    final taskId = await database.insert('tasks', task.toMap());

    for (final ingredient in task.ingredients) {
      await database.insert('task_ingredients', 
      ingredient.toMap());
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
          doughRecipe: taskMap['dough_recipe'] as Recipe,
          fillingRecipe: taskMap['filling_recipe'] as Recipe,
          size: taskMap['size'] as int,
          quantity: taskMap['quantity'] as int,
          ratio: taskMap['ratio'] as String,
          ingredients: ingredientMaps.map((ingredientMap) {
            return TaskIngredient(
              type: ingredientMap['type'] as String,
              name: ingredientMap['name'] as String,
              amount: (ingredientMap['amount'] as num).toDouble(),
              unit: ingredientMap['unit'] as String,
            );
          }).toList(),
          createdAt: DateTime.parse(taskMap['created_at'] as String),
          comment: taskMap['comment'] as String?,
          isCompleted: taskMap['is_completed'] as bool?,
        ),
      );
    }

    return tasks;
  }
  
   
  Future<Database> _databaseInstance() async {
    if (_database != null) {
      return _database!;    }

    final databaseDirectory = await getDatabasesPath();
    final databasePath = '${databaseDirectory}${Platform.pathSeparator}$_databaseName';

    // Delete old database to reset on app restart
    final databaseFile = File(databasePath);
    if (await databaseFile.exists()) {
      await databaseFile.delete();
    }

    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE recipes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            dough_type TEXT,
            filling_type TEXT,
            description TEXT NOT NULL,
            is_favorite INTEGER NOT NULL DEFAULT 0,
            rating REAL NOT NULL DEFAULT 0,
            url TEXT,
            comment TEXT
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
            created_at TEXT NOT NULL,
            comment TEXT,
            is_completed INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE task_ingredients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            task_id INTEGER NOT NULL,
            type TEXT NOT NULL,
            name TEXT NOT NULL,
            amount REAL NOT NULL,
            unit TEXT NOT NULL,
            FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
          )
        ''');
      },
      );

    var cantoneseDough = Recipe(
    id: 0000000,
    name: '经典广式月饼',
    type:  RecipeType.dough,
    doughType: '广式月饼',
    fillingType: null,
    description: '经典广式月饼食谱，适合制作传统的广式月饼。',
    ingredients: [
      Ingredient(id: 00000001, name: '低筋面粉', amount: 162.0, unit: '克'),
      Ingredient(id: 00000002, name: '糖浆', amount: 114.0, unit: '克'),
      Ingredient(id: 00000003, name: '油', amount: 44.0, unit: '克'),
      Ingredient(id: 00000004, name: '碱水', amount: 1.0, unit: '克'),
    ],
    isFavorite: false,
    rating: 0,
    url: null,
    comment: null,
  );

    var snowSkinDough = Recipe(
    id: 0000001,
    name: '经典冰皮月饼',
    type:  RecipeType.dough,
    doughType: '冰皮月饼',
    fillingType: null,
    description: '经典冰皮月饼食谱，适合制作传统的广式月饼。',
    ingredients: [
      Ingredient(id: 00000011, name: '糯米粉', amount: 41.0, unit: '克'),
      Ingredient(id: 00000012, name: '澄粉', amount: 26.0, unit: '克'),
      Ingredient(id: 00000013, name: '粘米粉', amount: 34.0, unit: '克'),
      Ingredient(id: 00000014, name: '糯米粉', amount: 25.0, unit: '克'),
      Ingredient(id: 00000015, name: '牛奶', amount: 172.0, unit: '克'),
      Ingredient(id: 00000016, name: '植物油', amount: 25.0, unit: '克'),
    ],
    isFavorite: false,
    rating: 0,
    url: null,
    comment: null,
  );

   var redBeanFilling = Recipe(
    id: 0000002,
    name: '经典红豆沙食谱',
    type:  RecipeType.filling,
    doughType: null,
    fillingType: '豆沙',
    description: '经典豆沙馅食谱，适合制作传统的广式月饼。',
    ingredients: [
      Ingredient(id: 00000021, name: '红豆（干）', amount: 168.0, unit: '克'),
      Ingredient(id: 00000022, name: '转化糖浆', amount: 33.0, unit: '克'),
      Ingredient(id: 00000023, name: '糖', amount: 33.0, unit: '克'),
      Ingredient(id: 00000026, name: '植物油', amount: 33.0, unit: '克'),
    ],
    isFavorite: false,
    rating: 0,
    url: null,
    comment: null,
  );

    await saveRecipe(cantoneseDough);
    await saveRecipe(snowSkinDough);
    await saveRecipe(redBeanFilling);
    return _database!;
  }
}