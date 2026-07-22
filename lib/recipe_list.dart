import 'package:flutter/material.dart';
import 'utils/app_bottom_navigation.dart';
import 'package:provider/provider.dart';
import 'recipe.dart';
import 'recipe_details.dart';
import 'service_2.dart';
import 'add_recipe.dart';
import 'app_strings.dart';
import 'language_provider.dart';

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  late Future<List<Recipe>> _recipesFuture;
  final MCService _mcService = MCService();

  @override
  void initState() {
    super.initState();
    _recipesFuture = _mcService.loadRecipes();
  }

  void _refreshRecipes() {
    setState(() {
      _recipesFuture = _mcService.loadRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;
    return Scaffold(
      appBar: AppBar(
        title:  Text(AppStrings.get('recipe_list_title', lang)),
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
            return  Center(child: Text(AppStrings.get('no_recipes_available', lang)));
          }

          final recipes = snapshot.data!;
          final doughRecipes = recipes.where((recipe) => recipe.type == RecipeType.dough).toList();
          final fillingRecipes = recipes.where((recipe) => recipe.type == RecipeType.filling).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: const [
              //       Text(
              //         'All recipes here are based on 8x100g 4:6 cakes.',
              //         style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              //       ),
              //       SizedBox(height: 4),
              //       Text(
              //         '所有食谱基于8x100g 4:6月饼。',
              //         style: TextStyle(fontSize: 13, color: Colors.black54),
              //       ),
              //     ],
              //   ),
              // ),
              _buildCategorySection(AppStrings.get('dough', lang), doughRecipes),
              _buildCategorySection(AppStrings.get('filling', lang), fillingRecipes),
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
            _refreshRecipes();
          }
        },
        tooltip: 'Add Recipe',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
    ); 
  }

  Widget _buildCategorySection(String title, List<Recipe> recipes) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      initiallyExpanded: true,
      children: recipes.isEmpty
          ? [
               ListTile(
                title: Text(AppStrings.get('no_recipes_available', lang)),
              ),
            ]
          : recipes.map(_buildRecipeTile).toList(),
    );
  }

  Widget _buildRecipeTile(Recipe recipe) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailsPage(recipe: recipe),
          ),
        );
        if (result == true) {
          _refreshRecipes();
        }
      },
      child: Card(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Type Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: recipe.type == RecipeType.dough
                      ? Colors.orange.shade100
                      : Colors.pink.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  recipe.type == RecipeType.dough ? Icons.grain : Icons.local_offer,
                  color: recipe.type == RecipeType.dough ? Colors.orange : Colors.pink,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Recipe Name and Type Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.type == RecipeType.dough
                          ? recipe.doughType ?? 'Dough'
                          : recipe.fillingType ?? 'Filling',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Favourite Icon
              IconButton(
                icon: Icon(
                  recipe.isFavorite ?? false ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                  size: 24,
                ),
                onPressed: () async {
                  final newStatus = !(recipe.isFavorite ?? false);
                  await _mcService.updateRecipeFavorite(recipe.id, newStatus);
                  _refreshRecipes();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),

              // Delete Icon
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 24,
                ),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title:  Text(AppStrings.get('delete_recipe', lang)),
                      content: Text(AppStrings.get('confirm_delete_recipe', lang).replaceAll('{recipe_name}', recipe.name)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child:  Text(AppStrings.get('cancel', lang)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child:  Text(AppStrings.get('delete_recipe', lang), style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirmed ?? false) {
                    await _mcService.deleteRecipe(recipe.id);
                    _refreshRecipes();
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
