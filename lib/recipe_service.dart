import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';
import 'recipe.dart';

class _LoadResult {
  final String xml;
  final bool createdFile;

  const _LoadResult({required this.xml, required this.createdFile});
}

class RecipeService {
  Future<List<Recipe>> loadRecipes() async {
    final loadResult = await _loadRecipesXml();
    final document = XmlDocument.parse(loadResult.xml);

    final recipeNodes = document.findAllElements('recipe');

    return recipeNodes.map((node) {
      final ingredients = node
          .findElements('ingredients')
          .first
          .findElements('ingredient')
          .map((i) => Ingredient(
                name: i.getAttribute('name')!,
                amount: double.parse(i.getAttribute('amount')!),
                unit: i.getAttribute('unit')!,
              ))
          .toList();

      return Recipe(
        name: node.findElements('name').first.innerText,
        type: node.findElements('type').first.innerText,
        style: node.findElements('style').isNotEmpty
            ? node.findElements('style').first.innerText
            : null,
        fillingType: node.findElements('filling_type').isNotEmpty
            ? node.findElements('filling_type').first.innerText
            : null,
        description: node.findElements('description').first.innerText,
        ingredients: ingredients,
      );
    }).toList();
  }

  Future<String?> saveRecipe(Recipe recipe) async {
    final loadResult = await _loadRecipesXml();
    final document = XmlDocument.parse(loadResult.xml);
    final root = document.rootElement;

    final ingredientNodes = recipe.ingredients.map((ingredient) {
      return XmlElement(
        XmlName('ingredient'),
        [
          XmlAttribute(XmlName('name'), ingredient.name),
          XmlAttribute(XmlName('amount'), ingredient.amount.toString()),
          XmlAttribute(XmlName('unit'), ingredient.unit),
        ],
      );
    }).toList();

    final recipeNode = XmlElement(
      XmlName('recipe'),
      [],
      [
        XmlElement(XmlName('name'), [], [XmlText(recipe.name)]),
        XmlElement(XmlName('type'), [], [XmlText(recipe.type)]),
        if (recipe.type.toLowerCase() == 'dough' && recipe.style != null)
          XmlElement(XmlName('style'), [], [XmlText(recipe.style!)]),
        if (recipe.type.toLowerCase() == 'filling' && recipe.fillingType != null)
          XmlElement(XmlName('filling_type'), [], [XmlText(recipe.fillingType!)]),
        XmlElement(XmlName('description'), [], [XmlText(recipe.description)]),
        XmlElement(XmlName('ingredients'), [], ingredientNodes),
      ],
    );

    root.children.add(XmlText('\n  '));
    root.children.add(recipeNode);
    root.children.add(XmlText('\n'));

    final formattedXml = document.toXmlString(pretty: true, indent: '  ');
    final file = await _recipesFile();
    await file.writeAsString(formattedXml);
    return loadResult.createdFile ? 'Created local recipes file.' : null;
  }

  Future<_LoadResult> _loadRecipesXml() async {
    final file = await _recipesFile();
    if (await file.exists()) {
      return _LoadResult(xml: await file.readAsString(), createdFile: false);
    }

    final initialXml = await rootBundle.loadString('assets/recipes.xml');
    await file.writeAsString(initialXml);
    return _LoadResult(xml: initialXml, createdFile: true);
  }

  Future<File> _recipesFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}${Platform.pathSeparator}recipes.xml');
  }
}
