import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'utils/app_bottom_navigation.dart';
import 'app_strings.dart';
import 'language_provider.dart';

import 'recipe.dart';
import 'recipe_service.dart';
import 'task.dart';
import 'package:moon_cake_app/utils/greeting.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LanguageProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return MaterialApp(
      title: 'Moon Cake Calculator',
      theme: AppTheme.lightTheme,
      locale: languageProvider.locale,
      home: const MyHomePage(title: 'Moon Cake Calculator'),
    );
  }
}

class _CalculatedIngredient {
  final String section;
  final String name;
  final double amount;
  final String unit;

  const _CalculatedIngredient({
    required this.section,
    required this.name,
    required this.amount,
    required this.unit,
  });
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //int _counter = 0;
  final int _currentNavIndex = 0;
  final RecipeService _recipeService = RecipeService();
  late Future<List<Recipe>> _recipesFuture;
  List<Recipe> _recipes = [];
  String? _selectedType = 'Cantonese-style';
  String? _fillingType;
  String? _selectedRecipe;
  String? _selectedFillingRecipe;
  String? _ratio = '4:6';
  int _quantity = 8;
  int _size = 100;
  final TextEditingController _sizeController = TextEditingController(
    text: '100',
  );

  @override
  void initState() {
    super.initState();
    _recipesFuture = _recipeService.loadRecipes().then((recipes) {
      if (mounted) {
        setState(() {
          _recipes = recipes;
        });
      }
      return recipes;
    });
  }

  @override
  void dispose() {
    _sizeController.dispose();
    super.dispose();
  }

  Widget _buildDoughStyleImageButton(
    String label,
    String value,
    String assetName,
  ) {
    final selected = _selectedType == value;
    final imageAsset = 'assets/${assetName}${selected ? '2' : ''}.jpg';

    return SizedBox(
      width: 140,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          setState(() {
            _selectedType = value;
            _selectedRecipe = null;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.16),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: Image.asset(imageAsset, height: 82, fit: BoxFit.cover),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(14),
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        //title: Text(widget.title),
        toolbarHeight: 32,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: const Color.fromARGB(
            255,
            154,
            10,
            10,
          ), // background of the top bar
          statusBarIconBrightness: Brightness.dark, // icons become white
        ),

        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (String value) {
              languageProvider.setLanguage(value);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'en',
                child: Row(
                  children: [
                    Radio<String>(
                      value: 'en',
                      groupValue: lang,
                      onChanged: (value) {
                        Navigator.pop(context);
                        languageProvider.setLanguage(value!);
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(AppStrings.get('english', lang)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'zh',
                child: Row(
                  children: [
                    Radio<String>(
                      value: 'zh',
                      groupValue: lang,
                      onChanged: (value) {
                        Navigator.pop(context);
                        languageProvider.setLanguage(value!);
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(AppStrings.get('chinese', lang)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 56),

              Text(
                GreetingHelper.greeting(),
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Theme.of(context).textTheme.headlineLarge?.color,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.get('addNewTask', lang),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Text(AppStrings.get('type', lang)),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 8,
                children: [
                  _buildDoughStyleImageButton(
                    AppStrings.get('cantonese', lang),
                    'Cantonese-style',
                    'cantoneseStyle',
                  ),
                  _buildDoughStyleImageButton(
                    AppStrings.get('snowSkin', lang),
                    'Snow skin',
                    'snowSkin',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              FutureBuilder<List<Recipe>>(
                future: _recipesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final recipes = snapshot.data ?? [];
                  final fillingTypes = recipes
                      .where((recipe) => recipe.type.toLowerCase() == 'filling')
                      .map((recipe) => recipe.fillingType)
                      .whereType<String>()
                      .toSet()
                      .toList();
                  final doughRecipes = recipes
                      .where(
                        (recipe) =>
                            recipe.type.toLowerCase() == 'dough' &&
                            _matchesSelectedDoughStyle(recipe),
                      )
                      .toList();
                  final fillingRecipes = recipes
                      .where(
                        (recipe) =>
                            recipe.type.toLowerCase() == 'filling' &&
                            _matchesSelectedFillingType(recipe),
                      )
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(AppStrings.get('fillingType', lang)),
                      const SizedBox(height: 8),
                      if (fillingTypes.isEmpty)
                        Column(
                          children: [
                            _buildFillingTypeButton(
                              label: AppStrings.get('redBean', lang),
                              value: 'Red Bean',
                            ),
                            const SizedBox(height: 12),
                            _buildFillingTypeButton(
                              label: AppStrings.get('lotusSeeds', lang),
                              value: 'Lotus Seed',
                            ),
                            if (_selectedType != 'Snow skin') ...[
                              const SizedBox(height: 12),
                              _buildFillingTypeButton(
                                label: AppStrings.get('fiveNuts', lang),
                                value: 'Five Nuts',
                              ),
                            ],
                          ],
                        )
                      else
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 8,
                          children: fillingTypes.map((type) {
                            return _buildFillingTypeButton(
                              label: type,
                              value: type,
                            );
                          }).toList(),
                        ),
                      if (doughRecipes.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Dough recipes',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: doughRecipes.map((recipe) {
                            return _buildRecipeChoiceButton(
                              label: recipe.name,
                              selected: _selectedRecipe == recipe.name,
                              onPressed: () {
                                setState(() {
                                  _selectedRecipe = recipe.name;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                      if (_fillingType != null) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Filling recipes',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (fillingRecipes.isEmpty)
                          const Text('No filling recipes for this selection.')
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: fillingRecipes.map((recipe) {
                              return _buildRecipeChoiceButton(
                                label: recipe.name,
                                selected: _selectedFillingRecipe == recipe.name,
                                onPressed: () {
                                  setState(() {
                                    _selectedFillingRecipe = recipe.name;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              Text(AppStrings.get('pastryFillingRatio', lang)),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in ['3:7', '4:6', '5:5'])
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _ratio == option
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _ratio = option;
                        });
                      },
                      child: Text(
                        option,
                        style: TextStyle(
                          color: _ratio == option ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 18),
              Row(
                children: [
                  Text(AppStrings.get('size', lang)),
                  const SizedBox(width: 12),

                  SizedBox(
                    width: 120,
                    height: 36,
                    child: TextField(
                      controller: _sizeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        // labelText: AppStrings.get('size', lang),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _size = int.tryParse(value) ?? _size;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in [35, 50, 75, 100])
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _size == option
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _size = option;
                          _sizeController.text = option.toString();
                        });
                      },
                      child: Text(
                        option.toString(),
                        style: TextStyle(
                          color: _size == option ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 18),
              Text(AppStrings.get('qty', lang)),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (_quantity > 1) _quantity--;
                      });
                    },
                  ),
                  SizedBox(
                    width: 80,
                    height: 36,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                      ),
                      controller: TextEditingController(
                        text: _quantity.toString(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _quantity = int.tryParse(value) ?? _quantity;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _quantity++;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(thickness: 2),
              const SizedBox(height: 18),
              Text(
                AppStrings.get('calculate', lang),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canCalculate() ? _calculateRecipe : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC70C0F),
                    disabledBackgroundColor: Colors.grey[400],
                  ),
                  child: const Text('Calculate ingredients'),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppStrings.get('totalWeight', lang)),
                        Text(
                          '${_size * _quantity}g',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (_ratio != null) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      ..._buildRatioBreakdown(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentNavIndex,
      ),
    );
  }

  bool _canCalculate() {
    return _selectedRecipe != null && _selectedFillingRecipe != null;
  }

  void _calculateRecipe() {
    final selectedDoughRecipe = _recipes.where((recipe) => recipe.name == _selectedRecipe).firstOrNull;
    final selectedFillingRecipe = _recipes.where((recipe) => recipe.name == _selectedFillingRecipe).firstOrNull;

    if (selectedDoughRecipe == null || selectedFillingRecipe == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both a dough recipe and a filling recipe.')),
      );
      return;
    }

    final totalWeight = (_size * _quantity).toDouble();
    final parts = _ratio!.split(':');
    final pastryPart = int.parse(parts[0]);
    final fillingPart = int.parse(parts[1]);
    final totalParts = pastryPart + fillingPart;

    final baseDoughWeight = 800.0 * pastryPart / totalParts;
    final baseFillingWeight = 800.0 * fillingPart / totalParts;
    final doughWeight = totalWeight * pastryPart / totalParts;
    final fillingWeight = totalWeight * fillingPart / totalParts;

    final doughScale = doughWeight / baseDoughWeight;
    final fillingScale = fillingWeight / baseFillingWeight;

    final ingredients = <_CalculatedIngredient>[];
    ingredients.addAll(
      selectedDoughRecipe.ingredients.map(
        (ingredient) => _CalculatedIngredient(
          section: 'Dough',
          name: ingredient.name,
          amount: ingredient.amount * doughScale,
          unit: ingredient.unit,
        ),
      ),
    );
    ingredients.addAll(
      selectedFillingRecipe.ingredients.map(
        (ingredient) => _CalculatedIngredient(
          section: 'Filling',
          name: ingredient.name,
          amount: ingredient.amount * fillingScale,
          unit: ingredient.unit,
        ),
      ),
    );

    _showCalculationResultDialog(ingredients);
  }

  void _showCalculationResultDialog(List<_CalculatedIngredient> ingredients) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calculation Result'),
        content: SingleChildScrollView(
          child: _buildDialogIngredientsList(ingredients),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _saveCalculationAsTask(ingredients),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogIngredientsList(List<_CalculatedIngredient> ingredients) {
    if (ingredients.isEmpty) {
      return const Text('No ingredients.');
    }

    final sections = ingredients.fold<Map<String, List<_CalculatedIngredient>>>(
      <String, List<_CalculatedIngredient>>{},
      (map, ingredient) {
        map.putIfAbsent(ingredient.section, () => <_CalculatedIngredient>[]).add(ingredient);
        return map;
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Size: ${_size}g x ${_quantity} cakes\nRatio: ${_ratio}',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        ...sections.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                ...entry.value.map((ingredient) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(ingredient.name)),
                        Text(
                          '${ingredient.amount.toStringAsFixed(1)} ${ingredient.unit}',
                          style: const TextStyle(color: Colors.black54),
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

  Future<void> _saveCalculationAsTask(List<_CalculatedIngredient> ingredients) async {
    final task = Task(
      doughRecipeName: _selectedRecipe!,
      fillingRecipeName: _selectedFillingRecipe!,
      size: _size,
      quantity: _quantity,
      ratio: _ratio!,
      ingredients: ingredients
          .map((i) => TaskIngredient(section: i.section, name: i.name, amount: i.amount, unit: i.unit))
          .toList(),
    );

    try {
      await _recipeService.saveTask(task);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save task: $e')),
        );
      }
    }
  }

  Widget _buildFillingTypeButton({required String label, required String value}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 10,
        ),
        backgroundColor: _fillingType == value
            ? Theme.of(context).colorScheme.primary
            : Colors.white,
      ),
      onPressed: () {
        setState(() {
          _fillingType = value;
          _selectedFillingRecipe = null;
        });
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w300,
          color: _fillingType == value ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildRecipeChoiceButton({
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        backgroundColor: selected
            ? Theme.of(context).colorScheme.primary
            : Colors.white,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: selected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  bool _matchesSelectedDoughStyle(Recipe recipe) {
    final selected = _normalizeSelection(_selectedType);
    final style = _normalizeSelection(recipe.style);
    return selected.isNotEmpty && style.isNotEmpty && selected == style;
  }

  bool _matchesSelectedFillingType(Recipe recipe) {
    final selected = _normalizeSelection(_fillingType);
    final type = _normalizeSelection(recipe.fillingType);
    return selected.isNotEmpty && type.isNotEmpty && selected == type;
  }

  String _normalizeSelection(String? value) {
    return (value ?? '')
        .toLowerCase()
        .replaceAll(RegExp(r'[\s-]+'), ' ')
        .trim();
  }

  List<Widget> _buildRatioBreakdown() {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;
    final totalWeight = _size * _quantity;
    final parts = _ratio!.split(':');
    final pastryPart = int.parse(parts[0]);
    final fillingPart = int.parse(parts[1]);
    final totalParts = pastryPart + fillingPart;

    final pastryWeight = (totalWeight * pastryPart / totalParts)
        .toStringAsFixed(1);
    final fillingWeight = (totalWeight * fillingPart / totalParts)
        .toStringAsFixed(1);

    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(AppStrings.get('pastryWeight', lang)),
          Text(
            '${pastryWeight}g',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(AppStrings.get('fillingWeight', lang)),
          Text(
            '${fillingWeight}g',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ];
  }
}
