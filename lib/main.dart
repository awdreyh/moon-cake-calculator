import 'package:flutter/material.dart';
import 'list_page.dart';
import 'recipe_details_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moon Cake Calculator',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(
          seedColor: const Color.fromARGB(255, 183, 131, 58),
        ),
      ),
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
  int _counter = 0;
  int _currentNavIndex = 0;
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

  void _incrementCounter() {
    setState(() {

      _counter--;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('You have pushed the button this many times:'),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RecipeListPage()),
                  );
                },
                child: const Text('Go to List'),
              ),
              const SizedBox(height: 40),
              const Text(
                'Add new task',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text('Type'),
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
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedType = 'Cantonese-style';
                        _selectedRecipe = null;
                      });
                    },
                    child: Text(
                      'Cantonese-style',
                      style: TextStyle(
                        color: _selectedType == 'Cantonese-style'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedType == 'Snow skin'
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300],
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedType = 'Snow skin';
                        _selectedRecipe = null;
                      });
                    },
                    child: Text(
                      'Snow skin',
                      style: TextStyle(
                        color: _selectedType == 'Snow skin'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              if (_selectedType != null) ...[
                const SizedBox(height: 24),
                const Text('Select recipe'),
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
                                    'View Details',
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
              const Text('Filling type'),
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
                      'Read Bean',
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
                      'Lotus Seed',
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
                      'Five Nuts',
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
              const Text('Pastry/Filling Ratio'),
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
              const Text('Size (g)'),
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
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Size (g)',
                    contentPadding: EdgeInsets.symmetric(
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
              const Text('Qty'),
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
              const Text(
                'Calculate',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        const Text('Total Weight:'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey[600],
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Tasks'),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  List<Widget> _buildRatioBreakdown() {
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
          const Text('Pastry Weight:'),
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
          const Text('Filling Weight:'),
          Text(
            '${fillingWeight}g',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ];
  }
}
