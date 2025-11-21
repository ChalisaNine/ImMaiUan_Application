import 'package:flutter/material.dart';
import 'main.dart';
import 'profile_screen.dart';
import 'Calenda.dart';
import 'ai_image.dart';
import 'nav_bar.dart'; // MainScaffold

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  int _index = 1; // Meal tab

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

      // ⭐ เปลี่ยนกลับเป็น AiImageScreen แบบเดิม — ไม่มี imagePath
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

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: _index,
      onTap: _onTap,

      /* ================= BODY ================= */
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
                  border: Border.all(color: Color(0xFFE6E6E6)),
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
                children: const [
                  _MealCategoryCard(
                    icon: Icons.restaurant_menu_rounded,
                    title: "Category",
                  ),
                  _MealCategoryCard(
                    icon: Icons.bookmark_rounded,
                    title: "Favorites",
                  ),
                  _MealCategoryCard(
                    icon: Icons.list_alt_rounded,
                    title: "My List",
                  ),
                ],
              ),

              const SizedBox(height: 22),

              const Text(
                "Recently",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),

              const SizedBox(height: 14),

              const _MealRecentItem(
                name: "Chicken Breast Salad",
                subtitle: "3% of calories per day",
                kcal: "70",
              ),
              const _MealRecentItem(
                name: "Boiled Chicken Rice",
                subtitle: "25% of calories per day",
                kcal: "512",
              ),
              const _MealRecentItem(
                name: "Fried Chicken Rice",
                subtitle: "60% of calories per day",
                kcal: "768",
              ),
              const _MealRecentItem(
                name: "Pizza",
                subtitle: "90% of calories per day",
                kcal: "900",
              ),
              const _MealRecentItem(
                name: "Chicken curry",
                subtitle: "30% of calories per day",
                kcal: "1024",
              ),
              const _MealRecentItem(
                name: "Pork fried rice",
                subtitle: "40% of calories per day",
                kcal: "456",
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
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
  });

  final String name;
  final String subtitle;
  final String kcal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5))),
      ),
      child: Row(
        children: [
          const Icon(Icons.rice_bowl_outlined,
              size: 28, color: Colors.black87),
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
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54),
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
    );
  }
}
