class TaskIngredient {
  final String section;
  final String name;
  final double amount;
  final String unit;

  const TaskIngredient({
    required this.section,
    required this.name,
    required this.amount,
    required this.unit,
  });

  Map<String, dynamic> toMap() => {
        'section': section,
        'name': name,
        'amount': amount,
        'unit': unit,
      };

  factory TaskIngredient.fromMap(Map<String, dynamic> map) => TaskIngredient(
        section: map['section'] as String,
        name: map['name'] as String,
        amount: (map['amount'] as num).toDouble(),
        unit: map['unit'] as String,
      );
}

class Task {
  final int? id;
  final String doughRecipeName;
  final String fillingRecipeName;
  final int size;
  final int quantity;
  final String ratio;
  final List<TaskIngredient> ingredients;
  final DateTime createdAt;

  Task({
    this.id,
    required this.doughRecipeName,
    required this.fillingRecipeName,
    required this.size,
    required this.quantity,
    required this.ratio,
    required this.ingredients,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'dough_recipe_name': doughRecipeName,
        'filling_recipe_name': fillingRecipeName,
        'size': size,
        'quantity': quantity,
        'ratio': ratio,
        'created_at': createdAt.toIso8601String(),
      };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'] as int?,
        doughRecipeName: map['dough_recipe_name'] as String,
        fillingRecipeName: map['filling_recipe_name'] as String,
        size: map['size'] as int,
        quantity: map['quantity'] as int,
        ratio: map['ratio'] as String,
        ingredients: [],
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
