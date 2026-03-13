import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'nav_bar.dart';
import 'main.dart';
import 'Meal.dart';
import 'ai_image.dart';
import 'profile_screen.dart';
import 'Calenda.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';

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
      final authService = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).authService;
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

            /* ---------------- BACK BUTTON ---------------- */
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC93C),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const CalendaScreen()),
                  );
                },
                child: const Text(
                  "« back",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

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
    final carbTarget =
        (profile?['carb_prefer'] as num?)?.toDouble() ?? 300.0;
    final proteinTarget =
        (profile?['protein_prefer'] as num?)?.toDouble() ?? 50.0;
    final fatTarget = (profile?['fat_prefer'] as num?)?.toDouble() ?? 70.0;

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
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _MealBlock(
                title: _capitalize(mealType),
                items: items,
                totalMealKcal: mealTotal,
              ),
            );
          }),

        const SizedBox(height: 16),

        /* ---------------- NUTRITION SUMMARY ---------------- */
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0E0),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
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
                value: sugar,
                unit: 'g',
                rdi: 50,
              ),
              _NutrientChip(
                icon: Icons.rice_bowl_rounded,
                label: 'Carb',
                value: carb,
                unit: 'g',
                rdi: carbTarget,
              ),
              _NutrientChip(
                icon: Icons.egg_rounded,
                label: 'Protein',
                value: protein,
                unit: 'g',
                rdi: proteinTarget,
              ),
              _NutrientChip(
                icon: Icons.local_pizza_rounded,
                label: 'Fat',
                value: fat,
                unit: 'g',
                rdi: fatTarget,
              ),
              _NutrientChip(
                icon: Icons.bolt_rounded,
                label: 'Sodium',
                value: sodium,
                unit: 'mg',
                rdi: 2300,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        /* ---------------- DAILY SUMMARY ---------------- */
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC93C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'Daily Summary',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Target',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '$calorieTarget kcal',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total consumed',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '$dailyTotal kcal',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Calories remaining',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  Text(
                    '$kcalRemaining kcal',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: kcalRemaining < 0
                          ? Colors.red.shade700
                          : Colors.green.shade800,
                    ),
                  ),
                ],
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

class _MealBlock extends StatelessWidget {
  const _MealBlock({
    required this.title,
    required this.items,
    required this.totalMealKcal,
  });

  final String title;
  final List<Map<String, dynamic>> items;
  final int totalMealKcal;

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
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
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
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No items',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...items.map(
                    (item) => _MealItemRow(
                      name: item['food_name'] as String? ?? 'Unknown',
                      kcal: item['kcal'] as int? ?? 0,
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
                      '$totalMealKcal kcal',
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

class _MealItemRow extends StatelessWidget {
  const _MealItemRow({required this.name, required this.kcal});

  final String name;
  final int kcal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.restaurant_menu_rounded, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Text(
            '$kcal kcal',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
  final double value;
  final String unit;
  final double rdi;

  const _NutrientChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.rdi,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = rdi > 0 ? (value / rdi * 100).toInt() : 0;
    final isOver = percentage > 100;
    return SizedBox(
      width: 60,
      child: Column(
        children: [
          Icon(icon, size: 22, color: Colors.black87),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          Text(
            '$percentage%',
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
