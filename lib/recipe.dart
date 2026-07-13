
enum RecipeType {
  dough,
  filling;

  // Convert enum → string
  String toMap() => name;

  // Convert string → enum
  static RecipeType fromMap(String value) {
    return RecipeType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => RecipeType.dough,
    );
  }
}

class Ingredient {
  final int id;
  final String name;
  final double amount;
  final String unit;

  Ingredient({required this.id, required this.name, required this.amount, required this.unit});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'amount': amount,
    'unit': unit,
  };

  factory Ingredient.fromMap(Map<String, dynamic> map) => Ingredient(
    id: map['id'] as int,
    name: map['name'] as String,
    amount: (map['amount'] as num).toDouble(),
    unit: map['unit'] as String,
  );
}

class Recipe {
  final int id;
  final String name; // eg: '祖母的广式月饼食谱'
  final RecipeType type; // 'dough or filling"
  final String? doughType;
  final String? fillingType;
  final String? description;
  final List<Ingredient> ingredients;
  final bool? isFavorite;
  final double? rating;
  final String? url;
  final String? comment;

  Recipe({
    required this.id,
    required this.name, // eg: '祖母的豆沙馅食谱'
    required this.type,
    this.doughType = '广式月饼',
    this.fillingType = '豆沙',
    this.description,
    required this.ingredients,
    this.isFavorite = false,
    this.rating = 5.0,
    this.url,
    this.comment,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type': type.toMap(),
    'doughType': doughType,
    'fillingType': fillingType,
    'description': description,
    'ingredients': ingredients.map((i) => i.toMap()).toList(),
    'isFavorite': isFavorite,
    'rating': rating,
    'url': url,
    'comment': comment,
  };

  factory Recipe.fromMap(Map<String, dynamic> map) => Recipe(
    id: map['id'] as int,
    name: map['name'] as String,
    type: RecipeType.fromMap(map['type'] as String),
    doughType: map['doughType'] as String?,
    fillingType: map['fillingType'] as String?,
    description: map['description'] as String?,
    ingredients: (map['ingredients'] as List<dynamic>)
        .map((i) => Ingredient.fromMap(i as Map<String, dynamic>))
        .toList(),
    isFavorite: map['isFavorite'] as bool?,
    rating: (map['rating'] as num?)?.toDouble(),
    url: map['url'] as String?,
    comment: map['comment'] as String?,
  );
}
