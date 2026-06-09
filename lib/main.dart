import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_bottom_navigation.dart';
import 'app_strings.dart';
import 'language_provider.dart';
import 'recipe_details.dart';
import 'package:moon_cake_app/utils/greeting.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';



void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
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
      theme: ThemeData(
           colorScheme: .fromSeed(
          seedColor: const Color.fromARGB(255, 183, 131, 58),
        ),


    // Modern sans-serif for body text
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.openSans(
        fontSize: 18,
        color: const Color.fromARGB(255, 44, 26, 3),
      ),
      bodyMedium: GoogleFonts.openSans(
        fontSize: 16,
        color: Colors.black87,
      ),
    ),
  ),
      locale: languageProvider.locale,
      home: const MyHomePage(title: 'Moon Cake Calculator'),
    );
  }
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
  String? _selectedType = 'Cantonese-style';
  String? _fillingType;
  String? _selectedRecipe;
  String? _ratio = '4:6';
  int _quantity = 8;
  int _size = 100;
  final TextEditingController _sizeController = TextEditingController(
    text: '100',
  );

  final Map<String, List<Map<String, String>>> _recipeOptions = {
    'Cantonese-style': [
      {
        'label': '老爸的食光',
        'image': 'https://picsum.photos/seed/canto1/400/240',
        'flour': '50.7%',
        'vegetableOil': '13.4%',
        'syrup': '35.8%',
      },
      {
        'label': '萨姐的食谱',
        'image': 'https://picsum.photos/seed/canto2/400/240',
        'flour': '50.7%',
        'vegetableOil': '13.4%',
        'syrup': '35.8%',
      },
    ],
    'Snow skin': [
      {'label': '萨姐的食谱', 'image': 'https://picsum.photos/seed/snow1/400/240'},
      {'label': 'Taro', 'image': 'https://picsum.photos/seed/snow2/400/240'},
    ],
  };

  @override
  void dispose() {
    _sizeController.dispose();
    super.dispose();
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
          statusBarColor: const Color.fromARGB(255, 154, 10, 10), // background of the top bar
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
                 const SizedBox(height: 40),
              Text(
    GreetingHelper.greeting(),
    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
  ),
              Text(
                AppStrings.get('addNewTask', lang),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
             // Text(AppStrings.get('type', lang)),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedType == 'Cantonese-style'
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300],
                           shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16), // adjust radius
    ),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedType = 'Cantonese-style';
                        _selectedRecipe = null;
                      });
                    },
                    child: Text(
                      AppStrings.get('cantonese', lang),
                      style: TextStyle(
                        color: _selectedType == 'Cantonese-style'
                            ? Colors.white
                            : Colors.black,
                            fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedType == 'Snow skin'
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300],
                           shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16), // adjust radius
    ),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedType = 'Snow skin';
                        _selectedRecipe = null;
                      });
                    },
                    child: Text(
                      AppStrings.get('snowSkin', lang),
                      style: TextStyle(
                        color: _selectedType == 'Snow skin'
                            ? Colors.white
                            : Colors.black,
                            fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
              if (_selectedType != null) ...[
                const SizedBox(height: 24),
                Text(AppStrings.get('selectRecipe', lang)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _recipeOptions[_selectedType]!
                      .map(
                        (option) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 110,
                                  child: Material(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        setState(() {
                                          _selectedRecipe = option['label'];
                                        });
                                      },
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              option['image']!,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                          border: Border.all(
                                            color:
                                                _selectedRecipe ==
                                                    option['label']
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : Colors.transparent,
                                            width: 3,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                gradient: LinearGradient(
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                  colors: [
                                                    Colors.black.withAlpha(140),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomLeft,
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Text(
                                                  option['label']!,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RecipeDetailsPage(
                                          recipeName: option['label']!,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    AppStrings.get('viewDetails', lang),
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
              Text(AppStrings.get('fillingType', lang)),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _fillingType == 'Read Bean'
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300],
                    ),
                    onPressed: () {
                      setState(() => _fillingType = 'Read Bean');
                    },
                    child: Text(
                      AppStrings.get('readBean', lang),
                      style: TextStyle(
                        color: _fillingType == 'Read Bean'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _fillingType == 'Lotus Seed'
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300],
                    ),
                    onPressed: () {
                      setState(() => _fillingType = 'Lotus Seed');
                    },
                    child: Text(
                      AppStrings.get('lotusSeeds', lang),
                      style: TextStyle(
                        color: _fillingType == 'Lotus Seed'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _fillingType == 'Five Nuts'
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300],
                    ),
                    onPressed: () {
                      setState(() => _fillingType = 'Five Nuts');
                    },
                    child: Text(
                      AppStrings.get('fiveNuts', lang),
                      style: TextStyle(
                        color: _fillingType == 'Five Nuts'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
                            : Colors.grey[300],
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
              const SizedBox(height: 24),
              Text(AppStrings.get('size', lang)),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in [25, 35, 50, 75, 100])
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _size == option
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
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
              const SizedBox(height: 12),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _sizeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: AppStrings.get('size', lang),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _size = int.tryParse(value) ?? _size;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
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
                    child: TextField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
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
              const SizedBox(height: 40),
              const Divider(thickness: 2),
              const SizedBox(height: 24),
              Text(
                AppStrings.get('calculate', lang),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: _currentNavIndex),
    );
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
