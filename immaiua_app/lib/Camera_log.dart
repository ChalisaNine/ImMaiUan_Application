import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'main.dart';
import 'Meal.dart';
import 'nav_bar.dart';
import 'profile_screen.dart';
import 'Calenda.dart';
import 'utils/food_icon_helper.dart';

class CameraLogScreen extends StatefulWidget {
  final int? foodId;
  final String? foodName;
  final List<dynamic>? detections;

  const CameraLogScreen({
    super.key,
    this.foodId,
    this.foodName,
    this.detections,
  });

  @override
  State<CameraLogScreen> createState() => _CameraLogScreenState();
}

class _CameraLogScreenState extends State<CameraLogScreen> {
  int _index = 2; // Capture tab
  bool _isLoading = false;
  Map<String, dynamic>? _foodDetails;
  String? _error;
  bool _isFavorite = false;
  bool _isFavoriteLoading = false;

  late String _selectedMealType;

  @override
  void initState() {
    super.initState();
    _selectedMealType = _defaultMealTypeForTime(DateTime.now());
    if (widget.foodId != null) {
      _fetchFoodDetails();
      _checkFavorite();
    }
  }

  String _defaultMealTypeForTime(DateTime time) {
    final hour = time.hour;

    if (hour >= 5 && hour < 11) {
      return "Breakfast";
    }
    if (hour >= 11 && hour < 15) {
      return "Lunch";
    }
    if (hour >= 17 && hour < 22) {
      return "Dinner";
    }
    return "Snack";
  }

  Future<void> _checkFavorite() async {
    try {
      final authService =
          Provider.of<AuthProvider>(context, listen: false).authService;
      final isFav = await authService.checkFavorite(widget.foodId!);
      if (mounted) setState(() => _isFavorite = isFav);
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    if (_isFavoriteLoading) return;
    setState(() => _isFavoriteLoading = true);
    try {
      final authService =
          Provider.of<AuthProvider>(context, listen: false).authService;
      final newState = await authService.toggleFavorite(widget.foodId!);
      if (mounted) {
        setState(() => _isFavorite = newState);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newState ? 'Added to favorites' : 'Removed from favorites',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update favorite')),
        );
      }
    } finally {
      if (mounted) setState(() => _isFavoriteLoading = false);
    }
  }

  Future<void> _fetchFoodDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService =
          Provider.of<AuthProvider>(context, listen: false).authService;
      final response = await authService.getFoodDetails(widget.foodId!);
      if (response.statusCode == 200) {
        setState(() {
          _foodDetails = response.data;
        });
      } else {
        setState(() => _error = "Failed to load details");
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onTap(int i) {
    setState(() => _index = i);

    switch (i) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainHomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MealScreen()),
        );
        break;
      case 2:
        break; // Already here
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CalendaScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    if (widget.detections != null && widget.detections!.isNotEmpty) {
      bodyContent = _CameraLogMultiBody(
        detections: widget.detections!,
        selectedMealType: _selectedMealType,
        onMealTypeChanged: (val) {
          if (val != null) setState(() => _selectedMealType = val);
        },
      );
    } else {
      bodyContent =
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text("Error: $_error"))
              : _CameraLogBody(
                foodDetails: _foodDetails,
                fallbackName: widget.foodName,
                selectedMealType: _selectedMealType,
                isFavorite: _isFavorite,
                isFavoriteLoading: _isFavoriteLoading,
                onToggleFavorite:
                    widget.foodId != null ? _toggleFavorite : null,
                onMealTypeChanged: (val) {
                  if (val != null) setState(() => _selectedMealType = val);
                },
              );
    }

    return MainScaffold(currentIndex: _index, onTap: _onTap, body: bodyContent);
  }
}

/* ---------------------------------------------------------
                    BODY CONTENT (UI)
---------------------------------------------------------- */

class _CameraLogBody extends StatefulWidget {
  final Map<String, dynamic>? foodDetails;
  final String? fallbackName;
  final String selectedMealType;
  final ValueChanged<String?> onMealTypeChanged;
  final bool isFavorite;
  final bool isFavoriteLoading;
  final VoidCallback? onToggleFavorite;

  const _CameraLogBody({
    this.foodDetails,
    this.fallbackName,
    required this.selectedMealType,
    required this.onMealTypeChanged,
    this.isFavorite = false,
    this.isFavoriteLoading = false,
    this.onToggleFavorite,
  });

  @override
  State<_CameraLogBody> createState() => _CameraLogBodyState();
}

class _CameraLogBodyState extends State<_CameraLogBody> {
  double _quantity = 1.0;
  late final TextEditingController _portionController;
  late final TextEditingController _qtyController;
  double _consumedCaloriesToday = 0;
  int? _initializedFoodId;

  @override
  void initState() {
    super.initState();
    _portionController = TextEditingController(text: '1');
    _qtyController = TextEditingController(text: '1');
    _syncQuantityInputFromFoodDetails();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.profile == null && !userProvider.isLoading) {
        userProvider.fetchProfile();
      }
      _loadTodaySummary();
    });
  }

  @override
  void didUpdateWidget(covariant _CameraLogBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldFoodId = oldWidget.foodDetails?['food_id'] as int?;
    final newFoodId = widget.foodDetails?['food_id'] as int?;
    if (oldFoodId != newFoodId) {
      _syncQuantityInputFromFoodDetails(force: true);
    }
  }

  Future<void> _loadTodaySummary() async {
    try {
      final authService = context.read<AuthProvider>().authService;
      final response = await authService.getDailySummary(
        _formatDate(DateTime.now()),
      );
      if (response.statusCode == 200 && mounted) {
        final total = response.data?['total'] ?? {};
        setState(() {
          _consumedCaloriesToday = _readAsDouble(total['calories']);
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _portionController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  void _syncQuantityInputFromFoodDetails({bool force = false}) {
    final foodId = widget.foodDetails?['food_id'] as int?;
    if (!force && _initializedFoodId == foodId) return;

    final defaultPortionQty = _defaultPortionQuantity;
    _initializedFoodId = foodId;
    _quantity = 1.0;
    _portionController.text = _formatNumber(defaultPortionQty);
    _qtyController.text = '1';
  }

  double get _defaultPortionQuantity {
    final value = _readAsDouble(widget.foodDetails?['quantity']);
    return value > 0 ? value : 1.0;
  }

  String get _portionUnit {
    final unit = widget.foodDetails?['unit']?.toString().trim() ?? '';
    return unit.isNotEmpty ? unit : 'serving';
  }

  double get _enteredPortionAmount {
    final entered = double.tryParse(_portionController.text);
    if (entered != null && entered > 0) return entered;
    return _defaultPortionQuantity;
  }

  double get _portionMultiplier => _enteredPortionAmount / _defaultPortionQuantity;

  double get _totalMultiplier => _portionMultiplier * _quantity;

  List<double> _buildPickerValues({
    required double currentValue,
    required double min,
    required double max,
    required double step,
  }) {
    final values = <double>{};
    for (double value = min; value <= max + (step / 2); value += step) {
      values.add(double.parse(value.toStringAsFixed(2)));
    }
    values.add(double.parse(currentValue.toStringAsFixed(2)));

    final sorted = values.toList()..sort();
    return sorted;
  }

  int _findClosestIndex(List<double> values, double target) {
    int closestIndex = 0;
    double closestDelta = double.infinity;

    for (int i = 0; i < values.length; i++) {
      final delta = (values[i] - target).abs();
      if (delta < closestDelta) {
        closestDelta = delta;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  Future<void> _showValuePicker({
    required String title,
    required List<double> values,
    required double currentValue,
    required ValueChanged<double> onSelected,
  }) async {
    final initialIndex = _findClosestIndex(values, currentValue);
    double selectedValue = values[initialIndex];
    final scrollController = FixedExtentScrollController(
      initialItem: initialIndex,
    );

    await showCupertinoModalPopup<void>(
      context: context,
      builder:
          (pickerContext) => Container(
            height: 300,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE6E6E6)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(pickerContext).pop(),
                        child: const Text("Cancel"),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.brown,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          onSelected(selectedValue);
                          Navigator.of(pickerContext).pop();
                        },
                        child: const Text("Done"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: scrollController,
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      selectedValue = values[index];
                    },
                    children:
                        values
                            .map(
                              (value) => Center(
                                child: Text(
                                  _formatNumber(value),
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _showPortionPicker() async {
    final currentValue = _enteredPortionAmount;
    final step =
        _defaultPortionQuantity >= 100
            ? 10.0
            : _defaultPortionQuantity >= 10
            ? 5.0
            : _defaultPortionQuantity >= 1
            ? 0.5
            : 0.1;
    final maxValue = math.max(_defaultPortionQuantity * 10, 20.0);
    final values = _buildPickerValues(
      currentValue: currentValue,
      min: step,
      max: maxValue,
      step: step,
    );

    await _showValuePicker(
      title: "Portion",
      values: values,
      currentValue: currentValue,
      onSelected: (value) {
        setState(() {
          _portionController.text = _formatNumber(value);
        });
      },
    );
  }

  Future<void> _showQuantityPicker() async {
    final currentValue = _quantity;
    final values = _buildPickerValues(
      currentValue: currentValue,
      min: 1,
      max: math.max(currentValue + 10, 20),
      step: 1,
    );

    await _showValuePicker(
      title: "Quantity",
      values: values,
      currentValue: currentValue,
      onSelected: (value) {
        setState(() {
          _quantity = value;
          _qtyController.text = _formatNumber(value);
        });
      },
    );
  }

  String _formatNumber(double value) {
    final text = value.toStringAsFixed(2);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    const peach = Color(0xFFFFE1C7);

    // Parse data
    final foodDetails = widget.foodDetails;
    final name = foodDetails?['name'] ?? widget.fallbackName ?? "Unknown Food";
    final baseCalDouble = (foodDetails?['calories'] as num?)?.toDouble() ?? 0.0;
    final scaledCal = (baseCalDouble * _totalMultiplier).round();
    final portionAmount = _formatNumber(_enteredPortionAmount);
    final quantityAmount = _formatNumber(_quantity);

    final nutrients = foodDetails?['nutrients'] ?? {};
    final sugarValue = _readAsDouble(nutrients['Sugar']) * _totalMultiplier; // g
    final carbValue = _readAsDouble(nutrients['Carb']) * _totalMultiplier; // g
    final proteinValue =
        _readAsDouble(nutrients['Protein']) * _totalMultiplier; // g
    final fatValue = _readAsDouble(nutrients['Fat']) * _totalMultiplier; // g
    final sodiumValue =
        _readAsDouble(nutrients['Sodium']) * _totalMultiplier; // mg

    final sugar = sugarValue.toStringAsFixed(1);
    final carb = carbValue.toStringAsFixed(1);
    final protein = proteinValue.toStringAsFixed(1);
    final fat = fatValue.toStringAsFixed(1);
    final sodium = sodiumValue.toStringAsFixed(1);

    final profile = context.watch<UserProvider>().profile;
    final calorieTarget = _readAsDouble(profile?['calorie_target']);
    final carbTarget = _readAsDouble(profile?['carb_prefer']);
    final proteinTarget = _readAsDouble(profile?['protein_prefer']);
    final fatTarget = _readAsDouble(profile?['fat_prefer']);
    final sugarTarget = _readAsDouble(profile?['sugar_target_max']) > 0
        ? _readAsDouble(profile?['sugar_target_max'])
        : _readAsDouble(profile?['sugar_target']);
    final sodiumTarget = _readAsDouble(profile?['sodium_target']);
    final projectedCalories = _consumedCaloriesToday + scaledCal;
    final calorieWarning = _buildCalorieWarning(
      projectedCalories,
      calorieTarget,
    );

    final sugarPercent = _calculatePercent(sugarValue, sugarTarget);
    final carbPercent = _calculatePercent(carbValue, carbTarget);
    final proteinPercent = _calculatePercent(proteinValue, proteinTarget);
    final fatPercent = _calculatePercent(fatValue, fatTarget);
    final sodiumPercent = _calculatePercent(sodiumValue, sodiumTarget);

    final excessRows = <_ExcessData>[
      if (carbPercent >= 100 && carbValue > carbTarget)
        _ExcessData(
          label: "Carb",
          value: "${(carbValue - carbTarget).toStringAsFixed(1)} g",
        ),
      if (proteinPercent >= 100 && proteinValue > proteinTarget)
        _ExcessData(
          label: "Protein",
          value: "${(proteinValue - proteinTarget).toStringAsFixed(1)} g",
        ),
      if (fatPercent >= 100 && fatValue > fatTarget)
        _ExcessData(
          label: "Fat",
          value: "${(fatValue - fatTarget).toStringAsFixed(1)} g",
        ),
      if (calorieWarning != null)
        _ExcessData(label: "Calories", value: calorieWarning),
    ];

    final ingredientsList = (foodDetails?['ingredients'] as List?) ?? [];
    String ingredientText = "";
    for (int i = 0; i < ingredientsList.length; i++) {
      ingredientText += "${i + 1}. ${ingredientsList[i]}\n";
    }
    if (ingredientText.isEmpty) ingredientText = "No ingredients data.";

    final categoryName = foodDetails?['category'] ?? "Unknown";

    final categoryIcon = buildFoodCategoryIcon(
      categoryName: categoryName,
      size: 60,
      color: Colors.orangeAccent,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* ---------------- WARNING BOX ---------------- */
          if (excessRows.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5C5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        "WARNING",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "This meal is close to or exceeds your nutrition target.",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    alignment: WrapAlignment.spaceBetween,
                    children:
                        excessRows
                            .map(
                              (item) => _ExcessRow(
                                label: item.label,
                                value: item.value,
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          /* ---------------- MEAL CARD ---------------- */
          Container(
            decoration: BoxDecoration(
              color: peach,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: categoryIcon),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (widget.onToggleFavorite != null)
                      widget.isFavoriteLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : GestureDetector(
                            onTap: widget.onToggleFavorite,
                            child: Icon(
                              widget.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  widget.isFavorite ? Colors.red : Colors.grey,
                              size: 26,
                            ),
                          ),
                  ],
                ),
                // Hide or update confidence if not AI based
                const Text(
                  "Food Database",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 8),

                Text(
                  "$scaledCal kcal",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "$quantityAmount × $portionAmount $_portionUnit",
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          /* ---------------- NUTRIENT SUMMARY ---------------- */
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: peach,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NutItem(
                  icon: Icons.cake_rounded,
                  label: "Sugar",
                  value: "$sugar g",
                  percent: "$sugarPercent%",
                ),
                _NutItem(
                  icon: Icons.rice_bowl_rounded,
                  label: "Carb",
                  value: "$carb g",
                  percent: "$carbPercent%",
                ),
                _NutItem(
                  icon: Icons.egg_rounded,
                  label: "Protein",
                  value: "$protein g",
                  percent: "$proteinPercent%",
                ),
                _NutItem(
                  icon: Icons.local_pizza_rounded,
                  label: "Fat",
                  value: "$fat g",
                  percent: "$fatPercent%",
                ),
                _NutItem(
                  icon: Icons.bolt_rounded,
                  label: "Sodium",
                  value: "$sodium mg",
                  percent: "$sodiumPercent%",
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          /* ---------------- INGREDIENT ---------------- */
          if (ingredientsList.isNotEmpty) ...[
            const Text(
              "Ingredient",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: peach,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ingredientText,
                style: const TextStyle(fontSize: 13.5, height: 1.45),
              ),
            ),
            const SizedBox(height: 18),
          ],

          /* ---------------- MEAL TYPE SELECTOR ---------------- */
          const Text(
            "Meal Type",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE6E6E6)),
            ),
            child: DropdownButton<String>(
              value: widget.selectedMealType,
              underline: const SizedBox(),
              isExpanded: true,
              items:
                  ["Breakfast", "Lunch", "Dinner", "Snack"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: widget.onMealTypeChanged,
            ),
          ),
          const SizedBox(height: 18),

          /* ---------------- PORTION + QUANTITY ---------------- */
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Portion",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE6E6E6)),
                      ),
                      child: InkWell(
                        onTap: _showPortionPicker,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  portionAmount,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _portionUnit,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.unfold_more_rounded,
                                color: Colors.black38,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Quantity",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE6E6E6)),
                      ),
                      child: InkWell(
                        onTap: _showQuantityPicker,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  quantityAmount,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.unfold_more_rounded,
                                color: Colors.black38,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$quantityAmount × $portionAmount $_portionUnit  ·  $scaledCal kcal',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),

          const SizedBox(height: 20),

          /* ---------------- BUTTONS ---------------- */
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB8B8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Decline",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      () => _showExcessWarningDialog(
                        context,
                        foodDetails ?? {},
                        widget.selectedMealType,
                        _totalMultiplier,
                        _consumedCaloriesToday,
                        calorieTarget,
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA6F1A6),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Add",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  double _readAsDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _calculatePercent(double value, double target) {
    if (target <= 0) return value <= 0 ? 0 : 100;
    return ((value / target) * 100).toInt();
  }
}

/* ---------------------------------------------------------
                     POPUP (Yes = go Meal)
---------------------------------------------------------- */

void _showExcessWarningDialog(
  BuildContext context,
  Map<String, dynamic> foodDetails,
  String mealType,
  double quantity,
  double consumedCaloriesToday,
  double calorieTarget,
) {
  bool isLogging = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      // Extract nutrients for warning
      final nutrients = foodDetails['nutrients'] ?? {};
      final carb = _safeToDouble(nutrients['Carb']) * quantity;
      final protein = _safeToDouble(nutrients['Protein']) * quantity;
      final fat = _safeToDouble(nutrients['Fat']) * quantity;
      final kcal =
          ((foodDetails['calories'] as num?)?.toDouble() ?? 0.0) * quantity;

      final profile = Provider.of<UserProvider>(context, listen: false).profile;
      final carbTarget = _safeToDouble(profile?['carb_prefer']);
      final proteinTarget = _safeToDouble(profile?['protein_prefer']);
      final fatTarget = _safeToDouble(profile?['fat_prefer']);
      final projectedCalories = consumedCaloriesToday + kcal;
      final calorieWarning = _buildCalorieWarning(
        projectedCalories,
        calorieTarget,
      );

      final carbPercent = _calculatePercent(carb, carbTarget);
      final proteinPercent = _calculatePercent(protein, proteinTarget);
      final fatPercent = _calculatePercent(fat, fatTarget);

      final excessRows = <_ExcessData>[
        if (carbPercent >= 100 && carb > carbTarget)
          _ExcessData(
            label: "Carb",
            value: "${(carb - carbTarget).toStringAsFixed(1)} g",
          ),
        if (proteinPercent >= 100 && protein > proteinTarget)
          _ExcessData(
            label: "Protein",
            value: "${(protein - proteinTarget).toStringAsFixed(1)} g",
          ),
        if (fatPercent >= 100 && fat > fatTarget)
          _ExcessData(
            label: "Fat",
            value: "${(fat - fatTarget).toStringAsFixed(1)} g",
          ),
        if (calorieWarning != null)
          _ExcessData(label: "Calories", value: calorieWarning),
      ];

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            contentPadding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (excessRows.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5C5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          excessRows
                              .map(
                                (item) => _ExcessRow(
                                  label: item.label,
                                  value: item.value,
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                const Text(
                  "Are you sure to add this meal?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),

                const SizedBox(height: 16),

                if (isLogging)
                  const CircularProgressIndicator()
                else
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB8B8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "No",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() => isLogging = true);
                            try {
                              final authService =
                                  Provider.of<AuthProvider>(
                                    context,
                                    listen: false,
                                  ).authService;

                              await authService.logFoodV2({
                                "meal_type": mealType,
                                "items": [
                                  {
                                    "food_id": foodDetails['food_id'],
                                    "quantity": quantity,
                                  },
                                ],
                              });

                              if (context.mounted) {
                                Navigator.of(dialogCtx).pop(); // Close dialog
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MealScreen(),
                                  ),
                                );
                              }
                            } catch (e) {
                              setState(() => isLogging = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Failed to log meal: $e"),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA6F1A6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "Yes",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}

double _safeToDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _calculatePercent(double value, double target) {
  if (target <= 0) return value <= 0 ? 0 : 100;
  return ((value / target) * 100).toInt();
}

String? _buildCalorieWarning(double projectedCalories, double calorieTarget) {
  if (calorieTarget <= 0) return null;

  if (projectedCalories > calorieTarget) {
    return '${(projectedCalories - calorieTarget).round()} kcal over target';
  }

  if (projectedCalories >= calorieTarget * 0.9) {
    return '${(calorieTarget - projectedCalories).round()} kcal left to target';
  }

  return null;
}

String _formatDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

class _ExcessData {
  final String label;
  final String value;

  const _ExcessData({required this.label, required this.value});
}

/* ---------------------------------------------------------
                     SMALL WIDGETS
---------------------------------------------------------- */

class _ExcessRow extends StatelessWidget {
  final String label;
  final String value;

  const _ExcessRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 7, color: Colors.black54),
        const SizedBox(width: 6),
        Text(
          "$label : $value",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _NutItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String percent;

  const _NutItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        Text(
          percent,
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/* ---------------------------------------------------------
                     MULTI-BODY UI
---------------------------------------------------------- */

class _CameraLogMultiBody extends StatefulWidget {
  final List<dynamic> detections;
  final String selectedMealType;
  final ValueChanged<String?> onMealTypeChanged;

  const _CameraLogMultiBody({
    required this.detections,
    required this.selectedMealType,
    required this.onMealTypeChanged,
  });

  @override
  State<_CameraLogMultiBody> createState() => _CameraLogMultiBodyState();
}

class _CameraLogMultiBodyState extends State<_CameraLogMultiBody> {
  // Store adjusted grams per detection index
  late List<double> _grams;
  bool _isLogging = false;
  double _consumedCaloriesToday = 0;

  @override
  void initState() {
    super.initState();
    _grams =
        widget.detections
            .map((d) => _safeToDouble(d['estimated_portion_g']))
            .toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.profile == null && !userProvider.isLoading) {
        userProvider.fetchProfile();
      }
      _loadTodaySummary();
    });
  }

  Future<void> _loadTodaySummary() async {
    try {
      final authService = context.read<AuthProvider>().authService;
      final response = await authService.getDailySummary(
        _formatDate(DateTime.now()),
      );
      if (response.statusCode == 200 && mounted) {
        final total = response.data?['total'] ?? {};
        setState(() {
          _consumedCaloriesToday = _safeToDouble(total['calories']);
        });
      }
    } catch (_) {}
  }

  void _changeGrams(int index, double delta) {
    setState(() {
      _grams[index] = (_grams[index] + delta).clamp(10.0, 2000.0);
    });
  }

  Future<void> _submitMultiMeal() async {
    setState(() => _isLogging = true);
    try {
      final authService =
          Provider.of<AuthProvider>(context, listen: false).authService;
      List<Map<String, dynamic>> items = [];

      for (int i = 0; i < widget.detections.length; i++) {
        final d = widget.detections[i];
        if (d['food_id'] == null) continue;

        items.add({
          "food_id": d['food_id'],
          "grams": _grams[i],
        });
      }

      if (items.isEmpty) {
        throw Exception("No valid database foods detected to log.");
      }

      await authService.logFoodAI({
        "meal_type": widget.selectedMealType,
        "items": items,
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MealScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to log meal: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLogging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const peach = Color(0xFFFFE1C7);

    double totalKcal = 0;
    double totalCarb = 0;
    double totalProtein = 0;
    double totalFat = 0;

    for (int i = 0; i < widget.detections.length; i++) {
      final d = widget.detections[i];
      if (d['food_id'] != null) {
        final nuts = d['per_100g_nutrients'] ?? {};
        final factor = _grams[i] / 100.0;
        totalKcal += _safeToDouble(nuts['calories']) * factor;
        totalCarb += _safeToDouble(nuts['carb']) * factor;
        totalProtein += _safeToDouble(nuts['protein']) * factor;
        totalFat += _safeToDouble(nuts['fat']) * factor;
      }
    }

    final profile = context.watch<UserProvider>().profile;
    final calorieTarget = _safeToDouble(profile?['calorie_target']);
    final carbTarget = _safeToDouble(profile?['carb_prefer']);
    final proteinTarget = _safeToDouble(profile?['protein_prefer']);
    final fatTarget = _safeToDouble(profile?['fat_prefer']);
    final projectedCalories = _consumedCaloriesToday + totalKcal;
    final calorieWarning = _buildCalorieWarning(
      projectedCalories,
      calorieTarget,
    );

    final carbPercent = _calculatePercent(totalCarb, carbTarget);
    final proteinPercent = _calculatePercent(totalProtein, proteinTarget);
    final fatPercent = _calculatePercent(totalFat, fatTarget);

    final excessRows = <_ExcessData>[
      if (carbPercent >= 100 && totalCarb > carbTarget)
        _ExcessData(
          label: "Carb",
          value: "${(totalCarb - carbTarget).toStringAsFixed(1)} g",
        ),
      if (proteinPercent >= 100 && totalProtein > proteinTarget)
        _ExcessData(
          label: "Protein",
          value: "${(totalProtein - proteinTarget).toStringAsFixed(1)} g",
        ),
      if (fatPercent >= 100 && totalFat > fatTarget)
        _ExcessData(
          label: "Fat",
          value: "${(totalFat - fatTarget).toStringAsFixed(1)} g",
        ),
      if (calorieWarning != null)
        _ExcessData(label: "Calories", value: calorieWarning),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (excessRows.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5C5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        "WARNING",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "This meal is close to or exceeds your nutrition target.",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    alignment: WrapAlignment.spaceBetween,
                    children:
                        excessRows
                            .map(
                              (item) => _ExcessRow(
                                label: item.label,
                                value: item.value,
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: peach,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Text(
                  "AI Detected Meal",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${totalKcal.round()} kcal Total",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NutItem(
                      icon: Icons.rice_bowl_rounded,
                      label: "Carb",
                      value: "${totalCarb.toStringAsFixed(1)}g",
                      percent: "$carbPercent%",
                    ),
                    _NutItem(
                      icon: Icons.egg_rounded,
                      label: "Protein",
                      value: "${totalProtein.toStringAsFixed(1)}g",
                      percent: "$proteinPercent%",
                    ),
                    _NutItem(
                      icon: Icons.local_pizza_rounded,
                      label: "Fat",
                      value: "${totalFat.toStringAsFixed(1)}g",
                      percent: "$fatPercent%",
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            "Meal Type",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE6E6E6)),
            ),
            child: DropdownButton<String>(
              value: widget.selectedMealType,
              underline: const SizedBox(),
              isExpanded: true,
              items:
                  ["Breakfast", "Lunch", "Dinner", "Snack"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: widget.onMealTypeChanged,
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            "Detected Items",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),

          ...List.generate(widget.detections.length, (i) {
            final d = widget.detections[i];
            final name = d['db_name'] ?? d['class'] ?? "Unknown";
            final nuts = d['per_100g_nutrients'] ?? {};

            // Only calc kcal if we have food_id, otherwise 0
            final kcal =
                d['food_id'] != null
                    ? (_safeToDouble(nuts['calories']) * (_grams[i] / 100.0))
                        .round()
                    : 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (d['food_id'] != null)
                          Text(
                            "$kcal kcal",
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          )
                        else
                          const Text(
                            "Not in DB (won't be logged)",
                            style: TextStyle(color: Colors.red, fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.orange,
                        ),
                        onPressed: () => _changeGrams(i, -10),
                      ),
                      Text(
                        "${_grams[i].round()}g",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.orange,
                        ),
                        onPressed: () => _changeGrams(i, 10),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          _isLogging
              ? const Center(child: CircularProgressIndicator())
              : Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitMultiMeal,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFFA6F1A6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Save Meal",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
