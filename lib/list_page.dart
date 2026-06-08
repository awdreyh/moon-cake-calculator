import 'package:flutter/material.dart';
import 'recipe.dart';
import 'recipe_service.dart';
import 'add_recipe_page.dart';

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  late Future<List<Recipe>> _recipesFuture;
  final RecipeService _recipeService = RecipeService();

  @override
  void initState() {
    super.initState();
    _recipesFuture = _recipeService.loadRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Recipe>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading recipes: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No recipes found'));
          }

          final recipes = snapshot.data!;
          final doughRecipes = recipes.where((recipe) => recipe.type.toLowerCase() == 'dough').toList();
          final fillingRecipes = recipes.where((recipe) => recipe.type.toLowerCase() == 'filling').toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _buildCategorySection('Dough', doughRecipes),
              _buildCategorySection('Filling', fillingRecipes),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const AddRecipePage()),
          );
          if (result == true) {
            setState(() {
              _recipesFuture = _recipeService.loadRecipes();
            });
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Recipe',
      ),
    );
  }

  Widget _buildCategorySection(String title, List<Recipe> recipes) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      initiallyExpanded: true,
      children: recipes.isEmpty
          ? [
              const ListTile(
                title: Text('No recipes available'),
              ),
            ]
          : recipes.map(_buildRecipeTile).toList(),
    );
  }

  Widget _buildRecipeTile(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      elevation: 1,
      child: ExpansionTile(
        title: Text(recipe.name),
        subtitle: Text(
          recipe.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          if (recipe.style != null || recipe.fillingType != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (recipe.style != null)
                    Chip(
                      label: Text(recipe.style!),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (recipe.fillingType != null)
                    Chip(
                      label: Text(recipe.fillingType!),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Ingredients',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ...recipe.ingredients.map(
            (ingredient) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(ingredient.name)),
                  Text(
                    '${ingredient.amount} ${ingredient.unit}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
