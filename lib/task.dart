import 'recipe.dart';

class TaskIngredient {
  final String type;
  final String name;
  final double amount;
  final String unit;

  const TaskIngredient({
    required this.type,
    required this.name,
    required this.amount,
    required this.unit,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'name': name,
        'amount': amount,
        'unit': unit,
      };

  factory TaskIngredient.fromMap(Map<String, dynamic> map) => TaskIngredient(
        type: map['type'] as String,
        name: map['name'] as String,
        amount: (map['amount'] as num).toDouble(),
        unit: map['unit'] as String,
      );
}

class Task {
  final int id;
  final Recipe doughRecipe;
  final Recipe fillingRecipe;
  final int size;
  final int quantity;
  final String ratio;
  final List<TaskIngredient> ingredients;
  final DateTime createdAt;
  final String? comment;
  final bool? isCompleted;

  Task({
    required this.id,
    required this.doughRecipe,
    required this.fillingRecipe,
    required this.size,
    required this.quantity,
    required this.ratio,
    required this.ingredients,
    DateTime? createdAt,
    this.comment,
    this.isCompleted,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'dough_recipe': doughRecipe,
        'filling_recipe': fillingRecipe,
        'size': size,
        'quantity': quantity,
        'ratio': ratio,
        'ingredients': ingredients.map((ingredient) => ingredient.toMap()).toList(),
        'created_at': createdAt.toIso8601String(),
        'comment': comment,
        'is_completed': isCompleted,
      };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'] as int,
        doughRecipe: map['dough_recipe'] as Recipe,
        fillingRecipe: map['filling_recipe'] as Recipe,
        size: map['size'] as int,
        quantity: map['quantity'] as int,
        ratio: map['ratio'] as String,
        ingredients: [],
        createdAt: DateTime.parse(map['created_at'] as String),
        isCompleted: map['is_completed'] as bool?,
        comment: map['comment'] as String?,
      );
}
