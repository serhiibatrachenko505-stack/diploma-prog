import 'dart:async';

import 'package:diploma_work_prog/data/dao/food_dao.dart';
import 'package:diploma_work_prog/models/food.dart';
import 'package:diploma_work_prog/models/portion.dart';
import 'package:diploma_work_prog/services/calculators/macro_calculator.dart';
import 'package:diploma_work_prog/ui/widgets/app_input.dart';
import 'package:diploma_work_prog/ui/widgets/primary_button.dart';
import 'package:flutter/material.dart';


class MacroCalculatorScreen extends StatefulWidget {
  const MacroCalculatorScreen({super.key});

  @override
  State<MacroCalculatorScreen> createState() => _MacroCalculatorScreenState();
}

class _MacroCalculatorScreenState extends State<MacroCalculatorScreen> {
  final FoodDao _foodDao = FoodDao();

  late final NutritionCalculator _calculator = NutritionCalculator(_foodDao);

  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _gramsCtrl = TextEditingController();

  final TextEditingController _kcalCtrl = TextEditingController();
  final TextEditingController _pCtrl = TextEditingController();
  final TextEditingController _fCtrl = TextEditingController();
  final TextEditingController _cCtrl = TextEditingController();

  Timer? _debounce;

  bool _isSearching = false;

  List<Food> _results = [];

  Food? _selectedFood;

  final List<_MacroItem> _items = [];

  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);

    _searchCtrl.dispose();
    _gramsCtrl.dispose();

    _kcalCtrl.dispose();
    _pCtrl.dispose();
    _fCtrl.dispose();
    _cCtrl.dispose();

    super.dispose();
  }

  void _onSearchChanged(){
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 250), () async {
      final query = _searchCtrl.text.trim();

      if (query.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isSearching = false;
          _results = [];
          _selectedFood = null;
        });
        return;
      }

      if (_selectedFood != null && _selectedFood!.name != query) {
        if (!mounted) return;
        setState(() => _selectedFood = null);
      }

      if (!mounted) return;
      setState(() => _isSearching = true);

      final foods = await _foodDao.searchByName(query, limit: 30);

      if (!mounted) return;
      setState(() {
        _results = foods;
        _isSearching = false;
      });
    });
  }

  void _selectFood(Food food){
    setState(() {
      _selectedFood = food;

      _searchCtrl.text = food.name;

      _results = [];
      _isSearching = false;

      _searchCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchCtrl.text.length),
      );
    });
  }

  double? _parseGrams(String raw){
    final t = raw.trim();
    if(t.isEmpty) return null;

    final normalized = t.replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  void _addItem() {
    final food = _selectedFood;
    if(food == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product from the list.')),
      );
      return;
    }

    final grams = _parseGrams(_gramsCtrl.text);
    if(grams == null || grams <= 0){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter grams > 0.')),
      );
      return;
    }

    setState(() {
      _items.add(_MacroItem(food: food, grams: grams));
    });

    _clearAddFields();
    _setTotalsZero();
    FocusScope.of(context).unfocus();
  }

  void _clearAddFields(){
    setState(() {
      _selectedFood = null;
      _searchCtrl.clear();
      _gramsCtrl.clear();
      _results = [];
      _isSearching = false;
    });
  }

  void _removeItem(int index){
    setState(() => _items.removeAt(index));
    _setTotalsZero();
  }

  Future<void> _calculateTotals() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one product first.')),
      );
      return;
    }

    setState(() => _isCalculating = true);

    try{
      final portions = _items
          .map((it) => Portion(it.food.id!, it.grams))
          .toList();

      final result = await _calculator.calculate(portions);

      if (!mounted) return;

      _kcalCtrl.text = result.kcal.toStringAsFixed(0);
      _pCtrl.text = result.proteins.toStringAsFixed(1);
      _fCtrl.text = result.fats.toStringAsFixed(1);
      _cCtrl.text = result.carbohydrates.toStringAsFixed(1);
    } catch (e){
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Calculation error: $e')),
      );
    } finally{
      if (mounted) {
        setState(() => _isCalculating = false);
      }
    }
  }

  void _setTotalsZero() {
    _kcalCtrl.text = '0';
    _pCtrl.text = '0';
    _fCtrl.text = '0';
    _cCtrl.text = '0';
  }

  Widget _readOnlyField(String label, TextEditingController ctrl){
    return TextFormField(
      controller: ctrl,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
  Widget _searchResultsWidget() {
    final query = _searchCtrl.text.trim();

    if (query.isEmpty) return const SizedBox.shrink();

    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: LinearProgressIndicator(),
      );
    }

    if (_results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text('No products found.'),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final f = _results[index];

          return ListTile(
            title: Text(f.name),
            subtitle: Text(
              'kcal ${f.kcal.toStringAsFixed(0)} | '
                  'P ${f.proteins.toStringAsFixed(1)} | '
                  'F ${f.fats.toStringAsFixed(1)} | '
                  'C ${f.carbohydrates.toStringAsFixed(1)} (per 100g)',
            ),
            onTap: () => _selectFood(f),
          );
        },
      ),
    );
  }

  Widget _addedItemsWidget(){
    if (_items.isEmpty) {
      return const Text('No added products yet.');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final it = _items[index];

        return ListTile(
          title: Text(it.food.name),
          subtitle: Text('${it.grams.toStringAsFixed(0)} g'),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _removeItem(index),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Macro calculator'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppInput(
                  hint: 'Search product...',
                  controller: _searchCtrl,
                  keyboardType: TextInputType.text,
              ),
              _searchResultsWidget(),

              if(_selectedFood != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Selected: ${_selectedFood!.name}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],

              const SizedBox(height: 16),

              AppInput(
                  hint: 'Grams (e.g. 150)',
                  controller: _gramsCtrl,
                  keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 10),

              PrimaryButton(
                text: 'Add to list',
                onPressed: _addItem,
              ),

              const SizedBox(height: 16),

              const Text(
                'Added products',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              _addedItemsWidget(),

              const SizedBox(height: 16),

              const Text(
                'Total macros',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              _readOnlyField('Kcal', _kcalCtrl),
              const SizedBox(height: 10),
              _readOnlyField('Proteins (g)', _pCtrl),
              const SizedBox(height: 10),
              _readOnlyField('Fats (g)', _fCtrl),
              const SizedBox(height: 10),
              _readOnlyField('Carbohydrates (g)', _cCtrl),

              const SizedBox(height: 14),

              PrimaryButton(
                text: _isCalculating ? 'Calculating...' : 'Calculate macros',
                onPressed: _isCalculating ? () {} : _calculateTotals,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroItem {
  final Food food;
  final double grams;

  const _MacroItem({
    required this.food,
    required this.grams,
  });
}