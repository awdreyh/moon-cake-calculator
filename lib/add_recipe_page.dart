import 'package:flutter/material.dart';
import 'recipe.dart';
import 'recipe_service.dart';
import 'app_bottom_navigation.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _IngredientInput {
  final TextEditingController nameController;
  final TextEditingController amountController;

  _IngredientInput({String name = '', String amount = ''})
      : nameController = TextEditingController(text: name),
        amountController = TextEditingController(text: amount);

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final RecipeService _recipeService = RecipeService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fillingTypeController = TextEditingController();
  final List<_IngredientInput> _ingredients = List.generate(
    3,
    (_) => _IngredientInput(),
  );
  String _recipeType = 'Dough';
  String _doughStyle = 'Cantonese style';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _fillingTypeController.dispose();
    for (final ingredient in _ingredients) {
      ingredient.dispose();
    }
    super.dispose();
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(_IngredientInput());
    });
  }

  void _removeIngredient(int index) {
    if (_ingredients.length <= 1) {
      return;
    }
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ingredients = _ingredients
        .where((input) => input.nameController.text.trim().isNotEmpty)
        .map((input) => Ingredient(
              name: input.nameController.text.trim(),
              amount: double.parse(input.amountController.text.trim()),
              unit: 'g',
            ))
        .toList();

    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one ingredient.')),
      );
      return;
    }

    final recipe = Recipe(
      name: _nameController.text.trim(),
      type: _recipeType.toLowerCase(),
      style: _recipeType == 'Dough' ? _doughStyle : null,
      fillingType:
          _recipeType == 'Filling' ? _fillingTypeController.text.trim() : null,
      description: 'Custom recipe for ${_nameController.text.trim()}',
      ingredients: ingredients,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      final confirmMessage = await _recipeService.saveRecipe(recipe);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Recipe saved successfully.' +
                (confirmMessage != null ? ' $confirmMessage' : ''),
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save recipe: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipe'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a recipe name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _recipeType == 'Dough'
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                      ),
                      onPressed: () {
                        setState(() {
                          _recipeType = 'Dough';
                        });
                      },
                      child: Text(
                        'Dough',
                        style: TextStyle(
                          color: _recipeType == 'Dough'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _recipeType == 'Filling'
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                      ),
                      onPressed: () {
                        setState(() {
                          _recipeType = 'Filling';
                        });
                      },
                      child: Text(
                        'Filling',
                        style: TextStyle(
                          color: _recipeType == 'Filling'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_recipeType == 'Dough') ...[
                const Text(
                  'Style',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _doughStyle == 'Cantonese style'
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[300],
                        ),
                        onPressed: () {
                          setState(() {
                            _doughStyle = 'Cantonese style';
                          });
                        },
                        child: Text(
                          'Cantonese style',
                          style: TextStyle(
                            color: _doughStyle == 'Cantonese style'
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _doughStyle == 'Snow skin'
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[300],
                        ),
                        onPressed: () {
                          setState(() {
                            _doughStyle = 'Snow skin';
                          });
                        },
                        child: Text(
                          'Snow skin',
                          style: TextStyle(
                            color: _doughStyle == 'Snow skin'
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (_recipeType == 'Filling') ...[
                const Text(
                  'Filling type',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fillingTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Filling type',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_recipeType == 'Filling' &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Please enter a filling type.';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Ingredients',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._ingredients.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final ingredient = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: ingredient.nameController,
                            decoration: InputDecoration(
                              labelText: 'Ingredient ${index + 1}',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter ingredient name.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: ingredient.amountController,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter amount.';
                              }
                              if (double.tryParse(value.trim()) == null) {
                                return 'Invalid number.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('g'),
                        ),
                        const SizedBox(width: 8),
                        if (_ingredients.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _removeIngredient(index),
                          ),
                      ],
                    ),
                  );
                },
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addIngredient,
                  icon: const Icon(Icons.add),
                  label: const Text('Add ingredient'),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveRecipe,
                      child: _isSaving
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
    );
  }
}
