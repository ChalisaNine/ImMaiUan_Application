import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'main.dart';
import 'Meal.dart';
import 'nav_bar.dart';
import 'profile_screen.dart';
import 'Calenda.dart';

class CameraLogScreen extends StatefulWidget {
  final int? foodId;
  final String? foodName;

  const CameraLogScreen({super.key, this.foodId, this.foodName});

  @override
  State<CameraLogScreen> createState() => _CameraLogScreenState();
}

class _CameraLogScreenState extends State<CameraLogScreen> {
  int _index = 2; // Capture tab
  bool _isLoading = false;
  Map<String, dynamic>? _foodDetails;
  String? _error;

  String _selectedMealType = "Breakfast"; // Default

  @override
  void initState() {
    super.initState();
    if (widget.foodId != null) {
      _fetchFoodDetails();
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
    return MainScaffold(
      currentIndex: _index,
      onTap: _onTap,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text("Error: $_error"))
          : _CameraLogBody(
              foodDetails: _foodDetails,
              fallbackName: widget.foodName,
              selectedMealType: _selectedMealType,
              onMealTypeChanged: (val) {
                if (val != null) setState(() => _selectedMealType = val);
              },
            ),
    );
  }
}

/* ---------------------------------------------------------
                    BODY CONTENT (UI)
---------------------------------------------------------- */

class _CameraLogBody extends StatelessWidget {
  final Map<String, dynamic>? foodDetails;
  final String? fallbackName;
  final String selectedMealType;
  final ValueChanged<String?> onMealTypeChanged;

  const _CameraLogBody({
    this.foodDetails,
    this.fallbackName,
    required this.selectedMealType,
    required this.onMealTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    const peach = Color(0xFFFFE1C7);

    // Parse data
    final name = foodDetails?['name'] ?? fallbackName ?? "Unknown Food";
    final cal = foodDetails?['calories']?.toString() ?? "0";
    final portionStr = "per 1 ${(foodDetails?['portion'] ?? 'serving')}";

    final nutrients = foodDetails?['nutrients'] ?? {};
    final sugar = nutrients['Sugar']?.toString() ?? "0";
    final carb = nutrients['Carb']?.toString() ?? "0";
    final protein = nutrients['Protein']?.toString() ?? "0";
    final fat = nutrients['Fat']?.toString() ?? "0";
    final sodium = nutrients['Sodium']?.toString() ?? "0";

    final ingredientsList = (foodDetails?['ingredients'] as List?) ?? [];
    String ingredientText = "";
    for (int i = 0; i < ingredientsList.length; i++) {
      ingredientText += "${i + 1}. ${ingredientsList[i]}\n";
    }
    if (ingredientText.isEmpty) ingredientText = "No ingredients data.";

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* ---------------- WARNING BOX ---------------- */
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
                  "This meal contains excess nutrients.",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),

                // TODO: Calculate excess based on RDI
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    _ExcessRow(label: "Sodium", value: "$sodium mg"),
                    _ExcessRow(label: "Sugar", value: "$sugar g"),
                    _ExcessRow(label: "Fat", value: "$fat g"),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          /* ---------------- MEAL CARD ---------------- */
          Container(
            decoration: BoxDecoration(
              color: peach,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/sample_food.jpg', // Placeholder image
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Hide or update confidence if not AI based
                const Text(
                  "Food Database",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 8),

                Text(
                  "$cal kcal",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  portionStr,
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
                  percent: "",
                ),
                _NutItem(
                  icon: Icons.egg_rounded,
                  label: "Protein",
                  value: "$protein g",
                  percent: "",
                ),
                _NutItem(
                  icon: Icons.local_pizza_rounded,
                  label: "Fat",
                  value: "$fat g",
                  percent: "",
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
              value: selectedMealType,
              underline: const SizedBox(),
              isExpanded: true,
              items: [
                "Breakfast",
                "Lunch",
                "Dinner",
                "Snack",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onMealTypeChanged,
            ),
          ),
          const SizedBox(height: 18),

          /* ---------------- GRAM + SERVING ---------------- */
          Row(
            children: const [
              Expanded(
                child: _DropdownBox(
                  defaultValue: "100 g",
                  items: ["50 g", "100 g", "200 g"],
                  label: "Gram per serving",
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _DropdownBox(
                  defaultValue: "Plate",
                  items: ["Bowl", "Plate", "Cup"],
                  label: "Serving",
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /* ---------------- BUTTONS ---------------- */
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {}, // stay this page
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
                    selectedMealType,
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
}

/* ---------------------------------------------------------
                     POPUP (Yes = go Meal)
---------------------------------------------------------- */

void _showExcessWarningDialog(
  BuildContext context,
  Map<String, dynamic> foodDetails,
  String mealType,
) {
  bool isLogging = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      // Extract nutrients for warning
      final nutrients = foodDetails['nutrients'] ?? {};
      final sugar = nutrients['Sugar']?.toString() ?? "0";
      final fat = nutrients['Fat']?.toString() ?? "0";
      final sodium = nutrients['Sodium']?.toString() ?? "0";

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
                /* Warning box inside popup */
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5C5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ExcessRow(label: "Sodium", value: "$sodium mg"),
                      _ExcessRow(label: "Sugar", value: "$sugar g"),
                      _ExcessRow(label: "Fat", value: "$fat g"),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
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
                                    "quantity": 1, // Default 1 serving
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

class _DropdownBox extends StatelessWidget {
  final String defaultValue;
  final List<String> items;
  final String label;

  const _DropdownBox({
    required this.defaultValue,
    required this.items,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
            value: defaultValue,
            underline: const SizedBox(),
            isExpanded: true,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) {},
          ),
        ),
      ],
    );
  }
}
