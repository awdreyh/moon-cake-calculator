import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'recipe.dart';
import 'task.dart';


class MCService {

  MCService({String? databaseName}) : _databaseName = databaseName ?? 'mooncake.db';
  
  static Database? _database;
  final String _databaseName;

   Future<Database> get _databaseInstance async {
    if (_database != null) {
      return _database!;    }
    else {
      _database = await _initDatabase();
      return _database!;
    }
    
   }

   Future<void> _seedDefaultRecipes(Database db) async {
    final existingRecipeNames = await db.query(
      'recipes',
      columns: ['name'],
      where: 'name IN (?, ?, ?)',
      whereArgs: ['经典广式月饼', '经典冰皮月饼', '经典红豆沙食谱'],
    );

    final seededNames = existingRecipeNames
        .map((row) => row['name'] as String)
        .toSet();

    final defaultRecipes = [
      Recipe(
        id: 0000000,
        name: '经典广式月饼饼皮',
        type: RecipeType.dough,
        quantity: 8,
        size: 100,
        ratio: 0.4,
        doughType: '广式月饼',
        fillingType: null,
        description: '经典广式月饼饼皮食谱，适合制作传统的广式月饼。',
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
      ),
      Recipe(
        id: 0000001,
        name: '经典冰皮月饼饼皮',
        type: RecipeType.dough,
        quantity: 8,
        size: 100,
        ratio: 0.4,
        doughType: '冰皮月饼',
        fillingType: null,
        description: '经典冰皮月饼饼皮食谱，适合制作传统的冰皮月饼。',
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
      ),
      Recipe(
        id: 0000002,
        name: '经典红豆沙馅料',
        type: RecipeType.filling,
        quantity: 8,
        size: 100,
        ratio: 0.4,
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
      ),
    ];

    for (final recipe in defaultRecipes) {
      if (!seededNames.contains(recipe.name)) {
        await saveRecipe(recipe, database: db);
      }
    }
  }

   Future<Database> _initDatabase() async {  

    final databaseDirectory = await getDatabasesPath();
    final databasePath = '${databaseDirectory}${Platform.pathSeparator}$_databaseName';

    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE recipes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            size INTEGER NOT NULL,
            ratio REAL NOT NULL,
            dough_type TEXT,
            filling_type TEXT,
            description TEXT NOT NULL,
            is_favorite INTEGER NOT NULL DEFAULT 0,
            rating REAL,
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
        await _seedDefaultRecipes(db);
      },
      onOpen: (db) async {
        await _seedDefaultRecipes(db);
      },
      );

   return _database!;
  }


  Future<Recipe?> getRecipeById(String id) async {
    final db = await _databaseInstance;
    final result = await db.query(
      'recipes',
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
    final database = await _databaseInstance;
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
          type: RecipeType.fromMap(recipeMap['type'] as String),
          size: recipeMap['size'] as int,
          quantity: recipeMap['quantity'] as int,
          ratio: (recipeMap['ratio'] as num?)?.toDouble(),
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

  Future<int?> saveRecipe(Recipe recipe, {Database? database}) async {
    final db = database ?? await _databaseInstance;
    final recipeId = await db.insert(
      'recipes',
      {
        'id': recipe.id,
        'name': recipe.name,
        'type': recipe.type.toMap(),
        'quantity': recipe.quantity,
        'size': recipe.size,
        'ratio': recipe.ratio,
        'dough_type': recipe.doughType,
        'filling_type': recipe.fillingType,
        'description': recipe.description,
        'is_favorite': (recipe.isFavorite ?? false) ? 1 : 0,
        'rating': recipe.rating,
        'url': recipe.url,
        'comment': recipe.comment,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await db.delete(
      'recipe_ingredients',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );

    for (final ingredient in recipe.ingredients) {
      await db.insert(
        'recipe_ingredients',
        {
          'recipe_id': recipeId,
          'name': ingredient.name,
          'amount': ingredient.amount,
          'unit': ingredient.unit,
        },
      );
    }
    return recipeId;
  }

  Future<int> saveTask(Task task) async {
    final database = await _databaseInstance;

    final taskId = await database.insert('tasks', task.toMap());

    for (final ingredient in task.ingredients) {
      await database.insert('task_ingredients', 
      ingredient.toMap());
    }

    return taskId;
  }

  Future<List<Task>> loadTasks() async {
    final database = await _databaseInstance;
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
  
   
 
  Future<void> deleteRecipe(int recipeId) async {
    final database = await _databaseInstance;
    await database.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [recipeId],
    );
  }

  Future<void> updateRecipeFavorite(int recipeId, bool isFavorite) async {
    final database = await _databaseInstance;
    await database.update(
      'recipes',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [recipeId],
    );
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final database = await _databaseInstance;
    await database.update(
      'recipes',
      {
        'name': recipe.name,
        'type': recipe.type.toMap(),
        'quantity': recipe.quantity,
        'size': recipe.size,
        'ratio': recipe.ratio,
        'dough_type': recipe.doughType,
        'filling_type': recipe.fillingType,
        'description': recipe.description,
        'is_favorite': (recipe.isFavorite ?? false) ? 1 : 0,
        'rating': recipe.rating,
        'url': recipe.url,
        'comment': recipe.comment,
      },
      where: 'id = ?',
      whereArgs: [recipe.id],
    );

    // Update ingredients
    await database.delete(
      'recipe_ingredients',
      where: 'recipe_id = ?',
      whereArgs: [recipe.id],
    );

    for (final ingredient in recipe.ingredients) {
      await database.insert(
        'recipe_ingredients',
        {
          'recipe_id': recipe.id,
          'name': ingredient.name,
          'amount': ingredient.amount,
          'unit': ingredient.unit,
        },
      );
    }
  }
}