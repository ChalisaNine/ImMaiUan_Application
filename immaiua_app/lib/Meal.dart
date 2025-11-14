import 'package:flutter/material.dart';
import 'main.dart';
import 'profile_screen.dart';
import 'Calenda.dart';
import 'camera_log.dart';

class MealScreen extends StatelessWidget {
  const MealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const peach = Color(0xFFFFE1C7);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      /* ================= TOP NAV ================= */
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 40),

            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/immaiuan_logo.jpg',
                  height: 38,
                ),
              ),
            ),

            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.tune_rounded, size: 26),
            ),
          ],
        ),
      ),

      /* ================= BODY ================= */
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
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

              // Category Buttons
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
            ],
          ),
        ),
      ),

      /* ================= FAB ================= */
      floatingActionButton: _CaptureFab(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CameraLogScreen()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /* ================= BOTTOM NAV ================= */
      bottomNavigationBar: const _MealBottomBar(),
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
          Text(title,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
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

/* ===================================================================== */
/*                       BOTTOM NAVBAR                                  */
/* ===================================================================== */

class _MealBottomBar extends StatelessWidget {
  const _MealBottomBar();

  @override
  Widget build(BuildContext context) {
    const peach = Color(0xFFFFE1C7);

    return BottomAppBar(
      color: peach,
      height: 90,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _navItem(
              context,
              icon: Icons.home_rounded,
              label: "Home",
              selected: false,
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainHomeScreen()),
                  (route) => false,
                );
              },
            ),

            _navItem(
              context,
              icon: Icons.restaurant_menu_rounded,
              label: "Meal",
              selected: true,
              onTap: () {},
            ),

            const Expanded(child: SizedBox()),

            _navItem(
              context,
              icon: Icons.calendar_month_rounded,
              label: "Diary",
              selected: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalendarScreen()),
                );
              },
            ),

            _navItem(
              context,
              icon: Icons.person_rounded,
              label: "Profile",
              selected: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _navItem(
  BuildContext context, {
  required IconData icon,
  required String label,
  required bool selected,
  required VoidCallback onTap,
}) {
  final active = Theme.of(context).colorScheme.primary;
  const inactive = Colors.black54;

  return Expanded(
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: selected ? active : inactive),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? active : inactive,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/* ===================================================================== */
/*                             FAB BUTTON                               */
/* ===================================================================== */

class _CaptureFab extends StatelessWidget {
  const _CaptureFab({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: 70,
      height: 70,
      child: FloatingActionButton(
        elevation: 6,
        backgroundColor: primary,
        shape: const CircleBorder(),
        onPressed: onPressed,
        child: const Icon(Icons.camera_alt_rounded,
            size: 30, color: Colors.white),
      ),
    );
  }
}
