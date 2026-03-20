import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'main.dart';
import 'Meal.dart';
import 'nav_bar.dart';
import 'profile_screen.dart';
import 'Calenda.dart';

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

  String _selectedMealType = "Breakfast"; // Default

  @override
  void initState() {
    super.initState();
    if (widget.foodId != null) {
      _fetchFoodDetails();
      _checkFavorite();
    }
  }

  Future<void> _checkFavorite() async {
    try {
      final authService = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).authService;
      final isFav = await authService.checkFavorite(widget.foodId!);
      if (mounted) setState(() => _isFavorite = isFav);
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    if (_isFavoriteLoading) return;
    setState(() => _isFavoriteLoading = true);
    try {
      final authService = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).authService;
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
      final authService = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).authService;
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
      bodyContent = _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text("Error: $_error"))
          : _CameraLogBody(
              foodDetails: _foodDetails,
              fallbackName: widget.foodName,
              selectedMealType: _selectedMealType,
              isFavorite: _isFavorite,
              isFavoriteLoading: _isFavoriteLoading,
              onToggleFavorite: widget.foodId != null ? _toggleFavorite : null,
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
  late final TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: '1');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.profile == null && !userProvider.isLoading) {
        userProvider.fetchProfile();
      }
    });
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _changeQty(double delta) {
    setState(() {
      _quantity = (_quantity + delta).clamp(0.5, 99.0);
      // Round to 1 decimal if not whole
      _quantity = double.parse(_quantity.toStringAsFixed(1));
      _qtyController.text = _quantity == _quantity.truncateToDouble()
          ? _quantity.toInt().toString()
          : _quantity.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    const peach = Color(0xFFFFE1C7);

    // Parse data
    final foodDetails = widget.foodDetails;
    final name = foodDetails?['name'] ?? widget.fallbackName ?? "Unknown Food";
    final baseCalDouble = (foodDetails?['calories'] as num?)?.toDouble() ?? 0.0;
    final scaledCal = (baseCalDouble * _quantity).round();
    final portionStr = "per ${foodDetails?['portion'] ?? 'serving'}";

    final nutrients = foodDetails?['nutrients'] ?? {};
    final sugarValue = _readAsDouble(nutrients['Sugar']) * _quantity; // g
    final carbValue = _readAsDouble(nutrients['Carb']) * _quantity; // g
    final proteinValue = _readAsDouble(nutrients['Protein']) * _quantity; // g
    final fatValue = _readAsDouble(nutrients['Fat']) * _quantity; // g
    final sodiumValue = _readAsDouble(nutrients['Sodium']) * _quantity; // mg

    final sugar = sugarValue.toStringAsFixed(1);
    final carb = carbValue.toStringAsFixed(1);
    final protein = proteinValue.toStringAsFixed(1);
    final fat = fatValue.toStringAsFixed(1);
    final sodium = sodiumValue.toStringAsFixed(1);

    final profile = context.watch<UserProvider>().profile;
    final carbTarget = _readAsDouble(profile?['carb_prefer']);
    final proteinTarget = _readAsDouble(profile?['protein_prefer']);
    final fatTarget = _readAsDouble(profile?['fat_prefer']);

    final carbPercent = _calculatePercent(carbValue, carbTarget);
    final proteinPercent = _calculatePercent(proteinValue, proteinTarget);
    final fatPercent = _calculatePercent(fatValue, fatTarget);

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
    ];

    final ingredientsList = (foodDetails?['ingredients'] as List?) ?? [];
    String ingredientText = "";
    for (int i = 0; i < ingredientsList.length; i++) {
      ingredientText += "${i + 1}. ${ingredientsList[i]}\n";
    }
    if (ingredientText.isEmpty) ingredientText = "No ingredients data.";

    final categoryName = foodDetails?['category'] ?? "Unknown";

    IconData getCategoryIcon(String category) {
      switch (category.toLowerCase()) {
        case 'boiled':
          return Icons.soup_kitchen;
        case 'fried':
          return Icons.ramen_dining; // or rice_bowl / fastfood
        case 'curry':
          return Icons.set_meal;
        case 'stir-fried':
          return Icons.local_dining;
        case 'grilled':
          return Icons.kebab_dining;
        case 'beverage':
          return Icons.local_cafe;
        case 'dessert':
          return Icons.cake;
        default:
          return Icons.fastfood;
      }
    }

    final categoryIcon = getCategoryIcon(categoryName);

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
                    "This meal exceeds your macro target.",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    alignment: WrapAlignment.spaceBetween,
                    children: excessRows
                        .map(
                          (item) =>
                              _ExcessRow(label: item.label, value: item.value),
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
                  child: Icon(
                    categoryIcon,
                    size: 60,
                    color: Colors.orangeAccent,
                  ),
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
                                color: widget.isFavorite
                                    ? Colors.red
                                    : Colors.grey,
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
                  "${_quantity == _quantity.truncateToDouble() ? _quantity.toInt() : _quantity} × $portionStr",
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
                  percent: "", // TODO: Calculate %
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
                  percent: "",
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
              items: [
                "Breakfast",
                "Lunch",
                "Dinner",
                "Snack",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: widget.onMealTypeChanged,
            ),
          ),
          const SizedBox(height: 18),

          /* ---------------- QUANTITY STEPPER ---------------- */
          const Text(
            "Quantity",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE6E6E6)),
            ),
            child: Row(
              children: [
                // Minus button
                IconButton(
                  onPressed: () => _changeQty(-0.5),
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                  color: Colors.orange,
                  iconSize: 28,
                ),
                // Editable number field
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null && parsed > 0) {
                        setState(() => _quantity = parsed.clamp(0.5, 99.0));
                      }
                    },
                  ),
                ),
                // Plus button
                IconButton(
                  onPressed: () => _changeQty(0.5),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  color: Colors.orange,
                  iconSize: 28,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'servings  ·  $scaledCal kcal total',
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
                  onPressed: () => _showExcessWarningDialog(
                    context,
                    foodDetails ?? {},
                    widget.selectedMealType,
                    _quantity,
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

      final profile = Provider.of<UserProvider>(context, listen: false).profile;
      final carbTarget = _safeToDouble(profile?['carb_prefer']);
      final proteinTarget = _safeToDouble(profile?['protein_prefer']);
      final fatTarget = _safeToDouble(profile?['fat_prefer']);

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
                      children: excessRows
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
                              final authService = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              ).authService;

                              await authService.logFood({
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
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        Text(
          percent,
          style: const TextStyle(fontSize: 10, color: Colors.black54),
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

  @override
  void initState() {
    super.initState();
    _grams = widget.detections
        .map((d) => _safeToDouble(d['estimated_portion_g']))
        .toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.profile == null && !userProvider.isLoading) {
        userProvider.fetchProfile();
      }
    });
  }

  void _changeGrams(int index, double delta) {
    setState(() {
      _grams[index] = (_grams[index] + delta).clamp(10.0, 2000.0);
    });
  }

  Future<void> _submitMultiMeal() async {
    setState(() => _isLogging = true);
    try {
      final authService = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).authService;
      List<Map<String, dynamic>> items = [];

      for (int i = 0; i < widget.detections.length; i++) {
        final d = widget.detections[i];
        if (d['food_id'] == null) continue;

        items.add({
          "food_id": d['food_id'],
          "quantity": _grams[i] / _safeToDouble(d['portion_qty'] ?? 100.0),
        });
      }

      if (items.isEmpty) {
        throw Exception("No valid database foods detected to log.");
      }

      await authService.logFood({
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
    final carbTarget = _safeToDouble(profile?['carb_prefer']);
    final proteinTarget = _safeToDouble(profile?['protein_prefer']);
    final fatTarget = _safeToDouble(profile?['fat_prefer']);

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
                    "This meal exceeds your macro target.",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    alignment: WrapAlignment.spaceBetween,
                    children: excessRows
                        .map(
                          (item) =>
                              _ExcessRow(label: item.label, value: item.value),
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
              items: [
                "Breakfast",
                "Lunch",
                "Dinner",
                "Snack",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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
            final kcal = d['food_id'] != null
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
