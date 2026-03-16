import 'dart:async';

import 'package:diploma_work_prog/data/dao/food_dao.dart';
import 'package:diploma_work_prog/data/dao/vit_food_dao.dart';
import 'package:diploma_work_prog/models/food.dart';
import 'package:diploma_work_prog/models/portion.dart';
import 'package:diploma_work_prog/services/calculators/vitamin_calculator.dart';
import 'package:diploma_work_prog/ui/widgets/app_input.dart';
import 'package:diploma_work_prog/ui/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class DayVitaminCalculatorScreen extends StatefulWidget {
  const DayVitaminCalculatorScreen({super.key});

  @override
  State<DayVitaminCalculatorScreen> createState() =>
      _DayVitaminCalculatorScreenState();
}

class _DayVitaminCalculatorScreenState extends State<DayVitaminCalculatorScreen> {
  final FoodDao _foodDao = FoodDao();
  final VitFoodDao _vitFoodDao = VitFoodDao();
  late final VitaminCalculator _vitCalculator = VitaminCalculator(_vitFoodDao);

  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _gramsCtrl = TextEditingController();

  Timer? _debounce;
  bool _isSearching = false;
  List<Food> _results = [];
  Food? _selectedFood;

  final List<_DayItem> _items = [];

  Gender _gender = Gender.male;
  WeightCategory _weightCategory = WeightCategory.kg61_75;

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

    super.dispose();
  }

  void _onSearchChanged() {
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

  void _selectFood(Food food) {
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

  double? _parseGrams(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;

    final normalized = t.replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  void _addItem() {
    final food = _selectedFood;
    if (food == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product from the list.')),
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

    setState(() {
      _items.add(_DayItem(food: food, grams: grams));
    });

    setState(() {
      _selectedFood = null;
      _searchCtrl.clear();
      _gramsCtrl.clear();
      _results = [];
      _isSearching = false;
    });

    FocusScope.of(context).unfocus();
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  Widget _addedItemsWidget() {
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

  static const Map<String, double> _baseNormMaleMg = {
    'A': 0.9,
    'B1': 1.2,
    'B2': 1.3,
    'B3': 16.0,
    'B5': 5.0,
    'B6': 1.3,
    'B7': 0.03,
    'B9': 0.4,
    'B12': 0.0024,
    'C': 90.0,
    'D': 0.015,
    'E': 15.0,
    'K': 0.12,
  };

  static const Map<String, double> _baseNormFemaleMg = {
    'A': 0.7,
    'B1': 1.1,
    'B2': 1.1,
    'B3': 14.0,
    'B5': 5.0,
    'B6': 1.3,
    'B7': 0.03,
    'B9': 0.4,
    'B12': 0.0024,
    'C': 75.0,
    'D': 0.015,
    'E': 15.0,
    'K': 0.09,
  };

  static const Map<WeightCategory, double> _weightMultiplier = {
    WeightCategory.kg40_60: 0.90,
    WeightCategory.kg61_75: 1.00,
    WeightCategory.kg76_90: 1.10,
    WeightCategory.kg91_105: 1.20,
    WeightCategory.kg105Plus: 1.30,
  };

  double? _getNormMg(String vitaminName) {
    final base = (_gender == Gender.male) ? _baseNormMaleMg : _baseNormFemaleMg;
    final baseNorm = base[vitaminName];
    if (baseNorm == null) return null;

    final mult = _weightMultiplier[_weightCategory] ?? 1.0;
    return baseNorm * mult;
  }

  Future<void> _calculateAndShowDialog() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one product first.')),
      );
      return;
    }

    setState(() => _isCalculating = true);

    try {
      final portions = _items
          .map((it) => Portion(it.food.id!, it.grams))
          .toList();

      final res = await _vitCalculator.calculateForList(portions);

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (ctx) => _ResultDialog(
          gender: _gender,
          weightCategory: _weightCategory,
          mg: res.mg,
          percentShare: res.percent,
          getNormMg: _getNormMg,
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vitamin calculator (daily)'),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'User parameters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                DropdownButtonFormField<Gender>(
                  key: ValueKey(_gender),
                  initialValue: _gender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: Gender.male, child: Text('Male')),
                    DropdownMenuItem(value: Gender.female, child: Text('Female')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _gender = v);
                  },
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<WeightCategory>(
                  key: ValueKey(_weightCategory),
                  initialValue: _weightCategory,
                  decoration: const InputDecoration(
                    labelText: 'Weight category',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: WeightCategory.kg40_60,
                      child: Text('40–60 kg'),
                    ),
                    DropdownMenuItem(
                      value: WeightCategory.kg61_75,
                      child: Text('61–75 kg'),
                    ),
                    DropdownMenuItem(
                      value: WeightCategory.kg76_90,
                      child: Text('76–90 kg'),
                    ),
                    DropdownMenuItem(
                      value: WeightCategory.kg91_105,
                      child: Text('91–105 kg'),
                    ),
                    DropdownMenuItem(
                      value: WeightCategory.kg105Plus,
                      child: Text('105+ kg'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _weightCategory = v);
                  },
                ),

                const SizedBox(height: 16),

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

                PrimaryButton(
                    text: _isCalculating ? 'Calculating...' : 'Calculate daily vitamins',
                    onPressed: _isCalculating ? () {} : _calculateAndShowDialog,
                ),
              ],
            ),
          ),
      ),
    );
  }
}

enum Gender { male, female }
enum WeightCategory { kg40_60, kg61_75, kg76_90, kg91_105, kg105Plus }

class _DayItem {
  final Food food;
  final double grams;

  const _DayItem({
    required this.food,
    required this.grams,
  });
}

class _ResultDialog extends StatelessWidget {
  final Gender gender;
  final WeightCategory weightCategory;

  final Map<String, double> mg;
  final Map<String, double> percentShare;

  final double? Function(String vitaminName) getNormMg;

  const _ResultDialog({
    required this.gender,
    required this.weightCategory,
    required this.mg,
    required this.percentShare,
    required this.getNormMg,
  });

  String _genderLabel(Gender g) => (g == Gender.male) ? 'Male' : 'Female';

  String _weightLabel(WeightCategory w) {
    switch (w) {
      case WeightCategory.kg40_60:
        return '40–60 kg';
      case WeightCategory.kg61_75:
        return '61–75 kg';
      case WeightCategory.kg76_90:
        return '76–90 kg';
      case WeightCategory.kg91_105:
        return '91–105 kg';
      case WeightCategory.kg105Plus:
        return '105+ kg';
    }
  }

  String _fmtMg(double v) {
    if (!v.isFinite) return '0';
    final abs = v.abs();
    if (abs >= 10) return v.toStringAsFixed(1);
    if (abs >= 1) return v.toStringAsFixed(2);
    if (abs >= 0.1) return v.toStringAsFixed(3);
    return v.toStringAsFixed(4);
  }

  @override
  Widget build(BuildContext context) {
    final keys = mg.keys.toList()..sort();

    return AlertDialog(
      title: const Text('Daily vitamins result'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Gender: ${_genderLabel(gender)}'),
              Text('Weight category: ${_weightLabel(weightCategory)}'),
              const SizedBox(height: 12),

              const Text(
                'Vitamin | mg | share % | mg / norm mg',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              for (final name in keys) ...[
                Builder(builder: (_) {
                  final mgValue = mg[name] ?? 0.0;
                  final share = percentShare[name] ?? 0.0;

                  final norm = getNormMg(name);
                  final normText = (norm == null)
                      ? 'n/a'
                      : '${_fmtMg(mgValue)} / ${_fmtMg(norm)} mg';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(name),
                        ),

                        Expanded(
                          flex: 2,
                          child: Text('${_fmtMg(mgValue)} mg'),
                        ),

                        Expanded(
                          flex: 2,
                          child: Text('${share.toStringAsFixed(1)}%'),
                        ),

                        Expanded(
                          flex: 3,
                          child: Text(normText),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 1),
              ],

              if (keys.isEmpty) ...[
                const Text('No vitamin data for selected products.'),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
