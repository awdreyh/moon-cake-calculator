class Ingredient {
  final String name;
  final double amount;
  final String unit;

  Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
  });
}

class Recipe {
  final String name;
  final String type;
  final String? style;
  final String? fillingType;
  final String description;
  final List<Ingredient> ingredients;
  final bool isFavorite;
  final double rating;

  Recipe({
    required this.name,
    required this.type,
    this.style,
    this.fillingType,
    required this.description,
    required this.ingredients,
    this.isFavorite = false,
    this.rating = 0.0,
  });
}
