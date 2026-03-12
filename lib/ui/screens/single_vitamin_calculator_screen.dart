import 'dart:async';
import 'package:flutter/material.dart';
import 'package:diploma_work_prog/data/dao/food_dao.dart';
import 'package:diploma_work_prog/data/dao/vit_food_dao.dart';
import 'package:diploma_work_prog/models/food.dart';
import 'package:diploma_work_prog/services/calculators/vitamin_calculator.dart';
import 'package:diploma_work_prog/ui/widgets/app_input.dart';
import 'package:diploma_work_prog/ui/widgets/primary_button.dart';

class SingleVitaminCalculatorScreen extends StatefulWidget {
  const SingleVitaminCalculatorScreen({super.key});

  @override
  State<SingleVitaminCalculatorScreen> createState() =>
      _SingleVitaminCalculatorScreenState();
}

class _SingleVitaminCalculatorScreenState extends
  State<SingleVitaminCalculatorScreen> {
  final FoodDao _foodDao = FoodDao();
  final VitFoodDao _vitFoodDao = VitFoodDao();
  late final VitaminCalculator _vitCalculator = VitaminCalculator(_vitFoodDao);

  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _gramsCtrl = TextEditingController();

  Timer? _debounce;

  bool _isSearching = false;
  bool _isCalculating = false;
  bool _hasCalculated = false;

  List<Food> _results = [];
  Food? _selectedFood;

  Map<String, double> _mgByVitamin = {};

  @override
  void initState() {
    super.initState();

    _searchCtrl.addListener(_onSearchChanged);
    _gramsCtrl.addListener(_onGramsChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();

    _searchCtrl.removeListener(_onSearchChanged);
    _gramsCtrl.removeListener(_onGramsChanged);

    _searchCtrl.dispose();
    _gramsCtrl.dispose();

    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 250), () async {
      final query = _searchCtrl.text.trim();
      if(query.isEmpty){
        if(!mounted) return;
        setState(() {
          _isSearching = false;
          _results = [];
          _selectedFood = null;

          _mgByVitamin = {};
          _hasCalculated = false;
        });
        return;
      }

      if(_selectedFood != null && _selectedFood!.name != query){
        if(!mounted) return;
        setState(() {
          _selectedFood = null;
          _mgByVitamin = {};
          _hasCalculated = false;
        });
      }

      if(!mounted) return;
      setState(() => _isSearching = true);

      final foods = await _foodDao.searchByName(query, limit: 30);

      if (!mounted) return;
      setState(() {
        _results = foods;
        _isSearching = false;
      });
    });
  }

  void _onGramsChanged() {
    if (!_hasCalculated) return;
    setState(() {
      _hasCalculated = false;
      _mgByVitamin = {};
    });
  }

  void _selectFood(Food food) {
    setState(() {
      _selectedFood = food;
      _searchCtrl.text = food.name;
      _results = [];
      _isSearching = false;
      _searchCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchCtrl.text.length),
      );
      _mgByVitamin = {};
      _hasCalculated = false;
    });
  }

  double? _parseGrams(String raw) {
    final t = raw.trim();
    if(t.isEmpty) return null;

    final normalized = t.replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  Future<void> _calculate() async {
    final food = _selectedFood;

    if (food == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product first.')),
      );
      return;
    }

    final grams = _parseGrams(_gramsCtrl.text);
    if (grams == null || grams <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter grams > 0.')),
      );
      return;
    }

    setState(() => _isCalculating = true);

    try{
      final mgMap = await _vitCalculator.calculateForFood(
        foodId: food.id!,
        grams: grams,
      );

      if (!mounted) return;

      setState(() {
        _mgByVitamin = mgMap;
        _hasCalculated = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Calculation error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isCalculating = false);
      }
    }
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
            onTap: () => _selectFood(f),
          );
        },
      ),
    );
  }

  Widget _vitaminResultsWidget() {
    if (!_hasCalculated) {
      return const Text('Press "Calculate vitamins" to see the result.');
    }

    if (_mgByVitamin.isEmpty) {
      return const Text('No vitamin data found for this product.');
    }

    final entries = _mgByVitamin.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final e = entries[index];

        final mgText = e.value.toStringAsFixed(2);

        return ListTile(
          title: Text(e.key),
          trailing: Text('$mgText mg'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Vitamin calculator (single)'),
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

              if (_selectedFood != null) ...[
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

              const SizedBox(height: 12),

              PrimaryButton(
                text: _isCalculating ? 'Calculating...' : 'Calculate vitamins',
                onPressed: _isCalculating ? () {} : _calculate,
              ),

              const SizedBox(height: 16),

              const Text(
                'Vitamins in selected portion',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),

              _vitaminResultsWidget(),
            ],
          ),
        ),
      ),
    );
  }
}