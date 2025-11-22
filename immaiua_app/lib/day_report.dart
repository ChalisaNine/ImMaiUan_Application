import 'package:flutter/material.dart';
import 'nav_bar.dart';
import 'main.dart';
import 'Meal.dart';
import 'ai_image.dart';
import 'profile_screen.dart';
import 'Calenda.dart';

class DayReportScreen extends StatefulWidget {
  const DayReportScreen({super.key});

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
            context, MaterialPageRoute(builder: (_) => const MainHomeScreen()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MealScreen()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AiImageScreen()));
        break;
      case 3:
        break;
      case 4:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: _index,
      onTap: _onTap,
      body: const _ReportBody(),
    );
  }
}

/* ---------------------------------------------------------------------- */
/*                            REPORT BODY                                 */
/* ---------------------------------------------------------------------- */

class _ReportBody extends StatelessWidget {
  const _ReportBody();

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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                children: const [
                  Text(
                    "Friday 19 Sep 2025",
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  SizedBox(height: 4),
                  Icon(Icons.calendar_today_rounded, size: 20),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /* ---------------- BREAKFAST ---------------- */
            const _MealBlock(
              title: "Breakfast",
              items: [
                _MealItem(name: "Chicken Rice", kcal: "762 kcal"),
                _MealItem(name: "Milk green tea", kcal: "509 kcal"),
                _MealItem(name: "Chocolate bar", kcal: "762 kcal"),
              ],
              totalMeal: "2063",
              totalLeft: "543",
            ),

            const SizedBox(height: 20),

            /* ---------------- LUNCH ---------------- */
            const _MealBlock(
              title: "Lunch",
              items: [
                _MealItem(name: "Green curry", kcal: "546 kcal"),
              ],
              totalMeal: "546",
              totalLeft: "-3",
            ),

            const SizedBox(height: 20),

            /* ---------------- DINNER ---------------- */
            const _MealBlock(
              title: "Dinner",
              items: [
                _MealItem(name: "Papaya salad", kcal: "246 kcal"),
              ],
              totalMeal: "246",
              totalLeft: "-249",
            ),

            const SizedBox(height: 30),

            /* ---------------- SUMMARY ---------------- */
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _NutritionBox(label: "Sugar", value: "46 g", remain: "20 g remain"),
                _NutritionBox(label: "Carb", value: "90 g", remain: "119 g remain"),
                _NutritionBox(label: "Protein", value: "33 g", remain: "66 g remain"),
                _NutritionBox(label: "Fat", value: "55 g", remain: "8 g remain"),
                _NutritionBox(label: "Sodium", value: "953 mg", remain: "200 mg remain"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------------------------------------------------------------- */
/*                           MEAL BLOCK                                   */
/* ---------------------------------------------------------------------- */

class _MealBlock extends StatelessWidget {
  const _MealBlock({
    required this.title,
    required this.items,
    required this.totalMeal,
    required this.totalLeft,
  });

  final String title;
  final List<_MealItem> items;
  final String totalMeal;
  final String totalLeft;

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
            child: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16)),
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
                ...items,

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Meal Calorie",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          totalMeal,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const Text("kcal",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Calorie left",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      totalLeft,
                      style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
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

class _MealItem extends StatelessWidget {
  const _MealItem({
    required this.name,
    required this.kcal,
  });

  final String name;
  final String kcal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.restaurant_menu_rounded, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
          ),
          Text(kcal,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}

/* ---------------------------------------------------------------------- */
/*                         NUTRITION SUMMARY BOX                          */
/* ---------------------------------------------------------------------- */

class _NutritionBox extends StatelessWidget {
  const _NutritionBox({
    required this.label,
    required this.value,
    required this.remain,
  });

  final String label;
  final String value;
  final String remain;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE1C7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13)),
          Text(remain,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }
}
