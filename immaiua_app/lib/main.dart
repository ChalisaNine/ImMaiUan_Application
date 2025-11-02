import 'package:flutter/material.dart';
import 'knowledge.dart';
import 'profile_screen.dart';
import 'ai_image.dart';

void main() => runApp(const ImMaiUanApp());

class ImMaiUanApp extends StatelessWidget {
  const ImMaiUanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImMaiUan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFA94D)),
        fontFamily: 'Roboto',
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _index = 0;
  void _onTap(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    const peach = Color(0xFFFFE1C7);

    final pages = <Widget>[
      const _HomeScreen(),
      const Center(child: Text('Meal Screen')),
      const Center(child: Text('Capture Screen')),
      const ProfileScreen(),
      const Center(child: Text('Setting Screen')),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.calendar_today_rounded),
        ),
        centerTitle: true,
        title: SizedBox(
          height: 40,
          child: Image.asset('assets/immaiuan_logo.jpg', fit: BoxFit.contain),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),

      body: pages[_index],

      floatingActionButton: _CaptureFab(
        onPressed: () {
          setState(() => _index = 2);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiImageScreen()),
          );
        },
        isSelected: _index == 2,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        height: 80,
        color: peach,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 6),
          child: _BottomBarItems(
            currentIndex: _index,
            onTap: _onTap,
          ),
        ),
      ),
    );
  }
}

/* ============================ HOME SCREEN ============================ */

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFFA94D);
    const lightPeach = Color(0xFFFFE1C7);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _arrowButton(Icons.chevron_left_rounded),
                const SizedBox(width: 8),
                const Text(
                  '2 November',
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                _arrowButton(Icons.chevron_right_rounded),
              ],
            ),
            const SizedBox(height: 20),

            // Basic knowledge card
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KnowledgeScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: lightPeach,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.menu_book_rounded,
                          size: 24, color: Colors.black87),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Basic knowledge',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                          SizedBox(height: 2),
                          Text('Tap to learn Daily Nutrition and tips',
                              style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Goal progress
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Goal',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 72,
                            width: 72,
                            child: CircularProgressIndicator(
                              value: 0.45,
                              strokeWidth: 6,
                              color: orange,
                              backgroundColor: lightPeach,
                            ),
                          ),
                          const Text('45%\nprogress',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Target weight',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54)),
                          SizedBox(height: 4),
                          Text('78 kg  →  65 kg',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text('Days',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54)),
                          SizedBox(height: 4),
                          Text('365 Days',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nutrients today
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: lightPeach,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Nutrients received today',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _NutrientItem(
                          icon: Icons.cake_rounded,
                          label: 'Sugar',
                          percent: '40%',
                          value: '18g remain'),
                      _NutrientItem(
                          icon: Icons.rice_bowl_rounded,
                          label: 'Carb',
                          percent: '20%',
                          value: '19g remain'),
                      _NutrientItem(
                          icon: Icons.egg_rounded,
                          label: 'Protein',
                          percent: '33%',
                          value: '10g remain'),
                      _NutrientItem(
                          icon: Icons.local_pizza_rounded,
                          label: 'Fat',
                          percent: '66%',
                          value: '19g remain'),
                      _NutrientItem(
                          icon: Icons.bolt_rounded,
                          label: 'Sodium',
                          percent: '36%',
                          value: '200mg remain'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _arrowButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, size: 22),
      ),
    );
  }
}

/* ============================ Nutrient Widget ============================ */

class _NutrientItem extends StatelessWidget {
  const _NutrientItem({
    required this.icon,
    required this.label,
    required this.percent,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String percent;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.black87),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600)),
        Text(percent,
            style: const TextStyle(
                fontSize: 11, color: Colors.black54)),
        Text(value,
            style: const TextStyle(
                fontSize: 10, color: Colors.black54)),
      ],
    );
  }
}

/* ============================ Bottom Bar ============================ */

class _BottomBarItems extends StatelessWidget {
  const _BottomBarItems({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final active = Theme.of(context).colorScheme.primary;
    const inactive = Colors.black54;

    Widget item({
      required int idx,
      required IconData icon,
      required String label,
    }) {
      final selected = currentIndex == idx;
      return InkWell(
        onTap: () => onTap(idx),
        child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: selected ? active : inactive),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? active : inactive,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: item(idx: 0, icon: Icons.home_rounded, label: 'Home')),
        Expanded(child: item(idx: 1, icon: Icons.restaurant_menu_rounded, label: 'Meal')),
        const Expanded(child: SizedBox.shrink()),
        Expanded(child: item(idx: 3, icon: Icons.person_rounded, label: 'Profile')),
        Expanded(child: item(idx: 4, icon: Icons.settings_rounded, label: 'Setting')),
      ],
    );
  }
}

/* ============================ FAB Camera ============================ */

class _CaptureFab extends StatelessWidget {
  const _CaptureFab({
    required this.onPressed,
    this.isSelected = false,
  });

  final VoidCallback onPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final active = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 68,
      height: 68,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 8,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected ? active : Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.photo_camera_rounded,
                  size: 26, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
