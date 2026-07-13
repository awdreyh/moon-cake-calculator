import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'utils/app_bottom_navigation.dart';
import 'app_strings.dart';
import 'language_provider.dart';

import 'recipe.dart';
import 'service_2.dart';
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
  final MCService _mcService = MCService();
  late Future<List<Recipe>> _recipesFuture;
  List<Recipe> _recipes = [];
  String? _selectedType = 'Cantonese-style';
  String? _fillingType;
  String? _selectedRecipeId;
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
    _recipesFuture = _mcService.loadRecipes().then((recipes) {
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
            _selectedRecipeId = null;
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
            158,
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

  

 
 
 


 }
