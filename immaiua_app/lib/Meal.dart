import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/meal_provider.dart';
import 'providers/user_provider.dart';

import 'main.dart';
import 'profile_screen.dart';
import 'Calenda.dart';
import 'ai_image.dart';
import 'camera_log.dart';
import 'nav_bar.dart'; // MainScaffold

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  int _index = 1; // Meal tab

  @override
  void initState() {
    super.initState();
    // Fetch all foods
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealProvider>().fetchFoods();
    });
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
        break;

      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AiImageScreen()),
        );
        break;

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

  void _openDetail({int? foodId, String? foodName}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraLogScreen(foodId: foodId, foodName: foodName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: _index,
      onTap: _onTap,

      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* ================= SEARCH BAR ================= */
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE6E6E6)),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search_rounded),
                    hintText: 'Search by name..',
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /* ================= CATEGORY ================= */
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MealCategoryCard(
                    icon: Icons.restaurant_menu_rounded,
                    title: "Category",
                    onTap: () => _openDetail(),
                  ),
                  _MealCategoryCard(
                    icon: Icons.bookmark_rounded,
                    title: "Favorites",
                    onTap: () => _openDetail(),
                  ),
                  _MealCategoryCard(
                    icon: Icons.list_alt_rounded,
                    title: "My List",
                    onTap: _openDetail,
                  ),
                ],
              ),

              const SizedBox(height: 22),

              const Text(
                "All Foods",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),

              const SizedBox(height: 14),

              /* ================= FOOD LIST ================= */
              Consumer2<MealProvider, UserProvider>(
                builder: (context, mealProvider, userProvider, child) {
                  if (mealProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (mealProvider.error != null) {
                    return Center(child: Text("Error: ${mealProvider.error}"));
                  }

                  final items = mealProvider.foodList;

                  if (items.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("No foods found."),
                      ),
                    );
                  }

                  // Get TDEE from UserProvider
                  final tdee =
                      (userProvider.profile?['tdee'] as num?)?.toInt() ?? 2000;
                  final safeTdee = tdee > 0 ? tdee : 2000;

                  return Column(
                    children: items.map((item) {
                      final kcal = (item['calories'] as num).toInt();
                      final percent = (kcal / safeTdee * 100).toStringAsFixed(
                        1,
                      );

                      return _MealRecentItem(
                        name: item['name'] ?? "Unknown Food",
                        subtitle:
                            "$percent% of calories per day (TDEE: $safeTdee)",
                        kcal: kcal.toString(),
                        onTap: () {
                          _openDetail(
                            foodId: item['food_id'],
                            foodName: item['name'],
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

/* ===================================================================== */
/*                     CATEGORY CARD                                    */
/* ===================================================================== */

class _MealCategoryCard extends StatelessWidget {
  const _MealCategoryCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE1C7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 26, color: Colors.black87),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================================================================== */
/*                       RECENT ITEM                                    */
/* ===================================================================== */

class _MealRecentItem extends StatelessWidget {
  const _MealRecentItem({
    required this.name,
    required this.subtitle,
    required this.kcal,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final String kcal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5))),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.rice_bowl_outlined,
              size: 28,
              color: Colors.black87,
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),

            Text(
              "$kcal kcal",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Color(0xFFFF8A47),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
