import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'nav_bar.dart';
import 'main.dart';
import 'Meal.dart';
import 'ai_image.dart';
import 'profile_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'utils/food_icon_helper.dart';

class DayReportScreen extends StatefulWidget {
  final DateTime? date;
  const DayReportScreen({super.key, this.date});

  @override
  State<DayReportScreen> createState() => _DayReportScreenState();
}

class _DayReportScreenState extends State<DayReportScreen> {
  int _index = 3; // Diary tab

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AiImageScreen()),
        );
        break;
      case 3:
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
      body: _ReportBody(date: widget.date ?? DateTime.now()),
    );
  }
}

/* ---------------------------------------------------------------------- */
/*                            REPORT BODY                                 */
/* ---------------------------------------------------------------------- */

class _ReportBody extends StatefulWidget {
  final DateTime date;
  const _ReportBody({required this.date});

  @override
  State<_ReportBody> createState() => _ReportBodyState();
}

class _ReportBodyState extends State<_ReportBody> {
  bool _loading = true;
  Map<String, dynamic>? _data;
  String? _error;

  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String get _formattedDate {
    final wd = _weekdays[widget.date.weekday - 1];
    final mo = _months[widget.date.month - 1];
    return '$wd ${widget.date.day} $mo ${widget.date.year}';
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final authService =
          Provider.of<AuthProvider>(context, listen: false).authService;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final response = await authService.getDaySummary(widget.date);
      await userProvider.fetchProfile();
      if (mounted) {
        setState(() {
          _data = Map<String, dynamic>.from(response.data);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            const SizedBox(height: 6),

            /* ---------------- DATE ---------------- */
            Center(
              child: Column(
                children: [
                  Text(
                    _formattedDate,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.calendar_today_rounded, size: 20),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /* ---------------- CONTENT ---------------- */
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Error loading data: $_error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else
              _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final meals = List<Map<String, dynamic>>.from(_data?['meals'] ?? []);
    final dailyTotal = _data?['daily_total_kcal'] as int? ?? 0;
    final kcalRemaining = _data?['kcal_remaining'] as int? ?? 0;
    final calorieTarget = _data?['calorie_target'] as int? ?? 2000;
    final profile = context.watch<UserProvider>().profile;

    final rawNutrients = _data?['nutrients'] as Map? ?? {};
    final sugar = (rawNutrients['sugar'] as num?)?.toDouble() ?? 0.0;
    final carb = (rawNutrients['carb'] as num?)?.toDouble() ?? 0.0;
    final protein = (rawNutrients['protein'] as num?)?.toDouble() ?? 0.0;
    final fat = (rawNutrients['fat'] as num?)?.toDouble() ?? 0.0;
    final sodium = (rawNutrients['sodium'] as num?)?.toDouble() ?? 0.0;
    final carbTarget = (profile?['carb_prefer'] as num?)?.toDouble() ?? 300.0;
    final proteinTarget =
        (profile?['protein_prefer'] as num?)?.toDouble() ?? 50.0;
    final fatTarget = (profile?['fat_prefer'] as num?)?.toDouble() ?? 70.0;
    final sugarTarget =
        (profile?['sugar_target_max'] as num?)?.toDouble() ??
        (profile?['sugar_target'] as num?)?.toDouble() ??
        50.0;
    final sodiumTarget =
        (profile?['sodium_target'] as num?)?.toDouble() ?? 2000.0;

    int calculatePercentage(double intake, double target) {
      if (target <= 0) {
        return intake <= 0 ? 0 : 100;
      }
      return ((intake / target) * 100).toInt();
    }

    final sugarPercentage = calculatePercentage(sugar, sugarTarget);
    final carbPercentage = calculatePercentage(carb, carbTarget);
    final proteinPercentage = calculatePercentage(protein, proteinTarget);
    final fatPercentage = calculatePercentage(fat, fatTarget);
    final sodiumPercentage = calculatePercentage(sodium, sodiumTarget);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /* ---------------- MEAL BLOCKS ---------------- */
        if (meals.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: const [
                  Icon(Icons.no_meals_rounded, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No meals logged for this day',
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              ),
            ),
          )
        else
          ...meals.map((meal) {
            final mealType = meal['meal_type'] as String? ?? 'other';
            final items = List<Map<String, dynamic>>.from(meal['items'] ?? []);
            final mealTotal = meal['total_kcal'] as int? ?? 0;
            final mealIds = List<int>.from(
              (meal['meal_ids'] as List?)?.map((e) => e as int) ?? [],
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _MealBlock(
                title: _capitalize(mealType),
                items: items,
                totalMealKcal: mealTotal,
                mealIds: mealIds,
                onDeleted: _loadData,
              ),
            );
          }),

        const SizedBox(height: 16),

        /* ---------------- NUTRITION SUMMARY ---------------- */
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0E0),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NutrientChip(
                icon: Icons.cake_rounded,
                label: 'Sugar',
                percentage: sugarPercentage,
                value: sugar,
                unit: 'g',
              ),
              _NutrientChip(
                icon: Icons.rice_bowl_rounded,
                label: 'Carb',
                percentage: carbPercentage,
                value: carb,
                unit: 'g',
              ),
              _NutrientChip(
                icon: Icons.egg_rounded,
                label: 'Protein',
                percentage: proteinPercentage,
                value: protein,
                unit: 'g',
              ),
              _NutrientChip(
                icon: Icons.local_pizza_rounded,
                label: 'Fat',
                percentage: fatPercentage,
                value: fat,
                unit: 'g',
              ),
              _NutrientChip(
                icon: Icons.bolt_rounded,
                label: 'Sodium',
                percentage: sodiumPercentage,
                value: sodium,
                unit: 'mg',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        /* ---------------- DAILY SUMMARY ---------------- */
        const Text(
          'Daily Summary',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Circular or Linear Progress Visualization
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Consumed',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$dailyTotal',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                              color: Color(0xFFFF9900),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text(
                              'kcal',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Daily Target',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$calorieTarget',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 3),
                            child: Text(
                              'kcal',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value:
                      calorieTarget > 0
                          ? (dailyTotal / calorieTarget).clamp(0.0, 1.0)
                          : 0,
                  minHeight: 12,
                  backgroundColor: const Color(0xFFF0F0F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    dailyTotal > calorieTarget
                        ? Colors.red.shade400
                        : const Color(0xFFFFC93C),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Remaining Calories Container
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      kcalRemaining < 0
                          ? Colors.red.withOpacity(0.1)
                          : const Color(0xFFF4F9F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      kcalRemaining < 0
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline_rounded,
                      color:
                          kcalRemaining < 0
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      kcalRemaining < 0
                          ? '${kcalRemaining.abs()} kcal over target'
                          : '$kcalRemaining kcal remaining',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color:
                            kcalRemaining < 0
                                ? Colors.red.shade700
                                : Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/* ---------------------------------------------------------------------- */
/*                           MEAL BLOCK                                   */
/* ---------------------------------------------------------------------- */

class _MealBlock extends StatefulWidget {
  const _MealBlock({
    required this.title,
    required this.items,
    required this.totalMealKcal,
    required this.mealIds,
    required this.onDeleted,
  });

  final String title;
  final List<Map<String, dynamic>> items;
  final int totalMealKcal;
  final List<int> mealIds;
  final VoidCallback onDeleted;

  @override
  State<_MealBlock> createState() => _MealBlockState();
}

class _MealBlockState extends State<_MealBlock> {
  bool _deleting = false;

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.delete_outline_rounded, color: Colors.red),
                const SizedBox(width: 8),
                Text('Delete ${widget.title}?'),
              ],
            ),
            content: Text(
              'This will permanently delete all ${widget.title.toLowerCase()} items for this day.'
              ' This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      final authService =
          Provider.of<AuthProvider>(context, listen: false).authService;
      // Delete all meal IDs in this group
      for (final id in widget.mealIds) {
        await authService.deleteMeal(id);
      }
      widget.onDeleted();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE1C7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header row: title + delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              _deleting
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red,
                    ),
                  )
                  : GestureDetector(
                    onTap: _confirmDelete,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                if (widget.items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No items',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...widget.items.map(
                    (item) => _MealItemRow(
                      key: ValueKey(item['meal_item_id'] as int? ?? item['food_name']),
                      foodId: item['food_id'] as int?,
                      name: item['food_name'] as String? ?? 'Unknown',
                      categoryName: item['category_name'] as String?,
                      kcal: item['kcal'] as int? ?? 0,
                      quantity: (item['quantity'] as num?)?.toDouble() ?? 1.0,
                      portionAmount: (item['portion'] as num?)?.toDouble(),
                      portionUnit: item['portion_unit'] as String?,
                      portionDescription:
                          item['portion_description'] as String?,
                      nutrients: Map<String, dynamic>.from(
                        item['nutrients'] as Map? ?? const {},
                      ),
                      mealItemId: item['meal_item_id'] as int? ?? 0,
                      mealIds: widget.mealIds,
                      shouldDeleteMealAfterRemoval:
                          widget.items.length <= 1 ||
                          (widget.totalMealKcal -
                                  (item['kcal'] as int? ?? 0)) <=
                              0,
                      onDeleted: widget.onDeleted,
                    ),
                  ),

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${widget.totalMealKcal} kcal',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------------------------------------------------------------- */
/*                           MEAL ITEM ROW                                */
/* ---------------------------------------------------------------------- */

class _MealItemRow extends StatefulWidget {
  const _MealItemRow({
    super.key,
    required this.foodId,
    required this.name,
    required this.kcal,
    required this.quantity,
    required this.portionAmount,
    required this.portionUnit,
    required this.portionDescription,
    required this.nutrients,
    required this.mealItemId,
    required this.mealIds,
    required this.shouldDeleteMealAfterRemoval,
    required this.onDeleted,
    this.categoryName,
  });

  final int? foodId;
  final String name;
  final int kcal;
  final double quantity;
  final double? portionAmount;
  final String? portionUnit;
  final String? portionDescription;
  final Map<String, dynamic> nutrients;
  final int mealItemId;
  final List<int> mealIds;
  final bool shouldDeleteMealAfterRemoval;
  final String? categoryName;
  final VoidCallback onDeleted;

  @override
  State<_MealItemRow> createState() => _MealItemRowState();
}

class _MealItemRowState extends State<_MealItemRow> {
  Widget _getFoodIcon(String? foodName, String? category) {
    return buildFoodCategoryIcon(
      categoryName: category,
      size: 20,
      color: const Color(0xFFFF9900),
    );
  }

  String _formatAmount(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  String _buildPortionText() {
    final amount = widget.portionAmount;
    final unit = widget.portionUnit?.trim() ?? '';
    final description = widget.portionDescription?.trim() ?? '';

    if (amount != null && amount > 0 && unit.isNotEmpty) {
      return '${_formatAmount(amount)} $unit';
    }

    if (description.isNotEmpty) {
      return widget.quantity > 1
          ? '${_formatAmount(widget.quantity)} x $description'
          : description;
    }

    return 'Qty ${_formatAmount(widget.quantity)}';
  }

  Future<void> _openDetails() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (_) => _MealItemDetailScreen(
              foodId: widget.foodId,
              name: widget.name,
              categoryName: widget.categoryName,
              kcal: widget.kcal,
              quantity: widget.quantity,
              portionAmount: widget.portionAmount,
              portionUnit: widget.portionUnit,
              portionDescription: widget.portionDescription,
              nutrients: widget.nutrients,
              mealItemId: widget.mealItemId,
              mealIds: widget.mealIds,
              shouldDeleteMealAfterRemoval: widget.shouldDeleteMealAfterRemoval,
            ),
      ),
    );
    if (changed == true) {
      widget.onDeleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _openDetails,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE1C7).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _getFoodIcon(widget.name, widget.categoryName),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _buildPortionText(),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 10.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5E5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.kcal} kcal',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFFFF8A47),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MealItemDetailScreen extends StatefulWidget {
  const _MealItemDetailScreen({
    required this.foodId,
    required this.name,
    required this.categoryName,
    required this.kcal,
    required this.quantity,
    required this.portionAmount,
    required this.portionUnit,
    required this.portionDescription,
    required this.nutrients,
    required this.mealItemId,
    required this.mealIds,
    required this.shouldDeleteMealAfterRemoval,
  });

  final int? foodId;
  final String name;
  final String? categoryName;
  final int kcal;
  final double quantity;
  final double? portionAmount;
  final String? portionUnit;
  final String? portionDescription;
  final Map<String, dynamic> nutrients;
  final int mealItemId;
  final List<int> mealIds;
  final bool shouldDeleteMealAfterRemoval;

  @override
  State<_MealItemDetailScreen> createState() => _MealItemDetailScreenState();
}

class _MealItemDetailScreenState extends State<_MealItemDetailScreen> {
  late double _portionAmount;
  late int _kcal;
  late Map<String, dynamic> _nutrients;
  bool _saving = false;
  bool _deleting = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _portionAmount = widget.portionAmount ?? 0;
    _kcal = widget.kcal;
    _nutrients = Map<String, dynamic>.from(widget.nutrients);
  }

  double _readNutrient(String key) => (_nutrients[key] as num?)?.toDouble() ?? 0.0;

  String _formatAmount(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  String _buildPortionText() {
    final amount = _portionAmount;
    final unit = widget.portionUnit?.trim() ?? '';
    final description = widget.portionDescription?.trim() ?? '';

    if (amount > 0 && unit.isNotEmpty) {
      return '${_formatAmount(amount)} $unit';
    }

    if (description.isNotEmpty) {
      return widget.quantity > 1
          ? '${_formatAmount(widget.quantity)} x $description'
          : description;
    }

    return 'Qty ${_formatAmount(widget.quantity)}';
  }

  Future<void> _editPortion() async {
    final controller = TextEditingController(
      text: _portionAmount > 0 ? _formatAmount(_portionAmount) : '',
    );

    final nextPortion = await showDialog<double>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Edit Portion'),
            content: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText:
                    'Portion (${(widget.portionUnit?.trim().isNotEmpty ?? false) ? widget.portionUnit : 'amount'})',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final value = double.tryParse(controller.text.trim());
                  if (value == null || value <= 0) return;
                  Navigator.pop(ctx, value);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );

    if (nextPortion == null || !mounted) return;

    setState(() => _saving = true);
    try {
      final authService =
          Provider.of<AuthProvider>(context, listen: false).authService;
      await authService.updateMealItemPortion(widget.mealItemId, nextPortion);

      final factor = _portionAmount > 0 ? nextPortion / _portionAmount : 1.0;
      setState(() {
        _portionAmount = nextPortion;
        _kcal = ((_kcal * factor)).round();
        _nutrients = _nutrients.map(
          (key, value) => MapEntry(
            key,
            ((value as num?)?.toDouble() ?? 0) * factor,
          ),
        );
        _hasChanges = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Portion updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update portion: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: const Text('Delete item?'),
            content: Text('Remove "${widget.name}" from this meal?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      final authService =
          Provider.of<AuthProvider>(context, listen: false).authService;
      await authService.deleteMealItem(widget.mealItemId);
      if (widget.shouldDeleteMealAfterRemoval) {
        for (final mealId in widget.mealIds) {
          await authService.deleteMeal(mealId);
        }
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete item: $e')),
        );
        setState(() => _deleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sugar = _readNutrient('sugar');
    final carb = _readNutrient('carb');
    final protein = _readNutrient('protein');
    final fat = _readNutrient('fat');
    final sodium = _readNutrient('sodium');

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) return;
        if (result == null && _hasChanges) {
          Navigator.pop(context, true);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFAF5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFFAF5),
          elevation: 0,
          foregroundColor: Colors.black87,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context, _hasChanges),
          ),
          title: const Text('Food Detail'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE1C7),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: buildFoodCategoryIcon(
                      categoryName: widget.categoryName,
                      size: 42,
                      color: const Color(0xFFFF9900),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if ((widget.categoryName ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      widget.categoryName!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$_kcal kcal',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF8A47),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _DetailInfoCard(
              title: 'Portion',
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      color: Color(0xFFFF9900),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _buildPortionText(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quantity ${_formatAmount(widget.quantity)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        if (widget.foodId != null)
                          Text(
                            'Food ID ${widget.foodId}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _editPortion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD8B4),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon:
                        _saving
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.edit_rounded),
                    label: const Text('Edit Portion'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _deleting ? null : _deleteItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFE6E3),
                      foregroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon:
                        _deleting
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.delete_outline_rounded),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Nutrition',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _DetailNutrientItem(
                    icon: Icons.cake_rounded,
                    label: 'Sugar',
                    value: '${sugar.toStringAsFixed(1)} g',
                  ),
                  _DetailNutrientItem(
                    icon: Icons.rice_bowl_rounded,
                    label: 'Carb',
                    value: '${carb.toStringAsFixed(1)} g',
                  ),
                  _DetailNutrientItem(
                    icon: Icons.egg_rounded,
                    label: 'Protein',
                    value: '${protein.toStringAsFixed(1)} g',
                  ),
                  _DetailNutrientItem(
                    icon: Icons.local_pizza_rounded,
                    label: 'Fat',
                    value: '${fat.toStringAsFixed(1)} g',
                  ),
                  _DetailNutrientItem(
                    icon: Icons.bolt_rounded,
                    label: 'Sodium',
                    value: '${sodium.toStringAsFixed(1)} mg',
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailInfoCard extends StatelessWidget {
  const _DetailInfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailNutrientItem extends StatelessWidget {
  const _DetailNutrientItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      child: Column(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFFF9900)),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------------------------------------------------------------- */
/*                          NUTRIENT CHIP                                 */
/* ---------------------------------------------------------------------- */

class _NutrientChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int percentage;
  final double value;
  final String unit;

  const _NutrientChip({
    required this.icon,
    required this.label,
    required this.percentage,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final isOver = percentage > 100;
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          Icon(icon, size: 22, color: Colors.black87),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          Text(
            '$percentage %',
            style: TextStyle(
              fontSize: 11,
              color: isOver ? Colors.red.shade700 : Colors.black87,
              fontWeight: isOver ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
