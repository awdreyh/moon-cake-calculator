import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'recipe.dart';
import 'service.dart';
import 'task.dart';
import 'app_strings.dart';
import 'language_provider.dart';
import 'utils/app_bottom_navigation.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final RecipeService _recipeService = RecipeService();
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = _recipeService.loadTasks();
  }

  void _showTaskDetailsModal(Task task, String lang) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm', lang == 'zh' ? 'zh_CN' : 'en_US');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${task.doughRecipeName} + ${task.fillingRecipeName}',
          style: const TextStyle(fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateFormat.format(task.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              _buildTaskInfo('Size', '${task.size}g'),
              _buildTaskInfo('Quantity', '${task.quantity} cakes'),
              _buildTaskInfo('Ratio', task.ratio),
              const SizedBox(height: 16),
              _buildRecipeLink(task.doughRecipeName, 'Dough', lang),
              const SizedBox(height: 8),
              _buildRecipeLink(task.fillingRecipeName, 'Filling', lang),
              const SizedBox(height: 16),
              const Text(
                'Calculated Ingredients',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildIngredientsList(task.ingredients),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get('close', lang)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeLink(String recipeName, String sectionTitle, String lang) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          sectionTitle,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
        GestureDetector(
          onTap: () => _showRecipeDetailModal(recipeName, lang),
          child: Text(
            recipeName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue,
              fontSize: 12,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  void _showRecipeDetailModal(String recipeName, String lang) async {
    final recipes = await _recipeService.loadRecipes();
    final recipe = recipes.firstWhere(
      (r) => r.name == recipeName,
      orElse: () => Recipe(
        name: recipeName,
        type: 'unknown',
        description: 'Recipe not found',
        ingredients: [],
      ),
    );

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(recipe.name),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recipe.style != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('Style: ${recipe.style}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ),
                if (recipe.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('Description: ${recipe.description}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ),
                const Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                ...recipe.ingredients.map((ingredient) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '${ingredient.name}: ${ingredient.amount} ${ingredient.unit}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.get('close', lang)),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTaskInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildIngredientsList(List<TaskIngredient> ingredients) {
    final sections = ingredients.fold<Map<String, List<TaskIngredient>>>(
      <String, List<TaskIngredient>>{},
      (map, ingredient) {
        map.putIfAbsent(ingredient.section, () => <TaskIngredient>[]).add(ingredient);
        return map;
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...sections.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                ...entry.value.map((ingredient) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(ingredient.name, style: const TextStyle(fontSize: 12))),
                        Text(
                          '${ingredient.amount.toStringAsFixed(1)} ${ingredient.unit}',
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm', lang == 'zh' ? 'zh_CN' : 'en_US');

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('tasks', lang)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final tasks = snapshot.data ?? [];

          if (tasks.isEmpty) {
            return Center(
              child: Text(
                AppStrings.get('noTasks', lang),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    '${task.doughRecipeName} + ${task.fillingRecipeName}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    dateFormat.format(task.createdAt),
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showTaskDetailsModal(task, lang),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: 1),
    );
  }
}
