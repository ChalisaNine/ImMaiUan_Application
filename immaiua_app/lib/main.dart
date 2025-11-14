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
      const _HomeScreen(),        // 0
      const Center(child: Text('Meal Screen')),
      const Center(child: Text('Capture Screen')),
      const Center(child: Text('Diary Screen')),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 68,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 40),
            Image.asset('assets/immaiuan_logo.jpg', height: 38),
            IconButton(
              onPressed: () => setState(() => _index = 4),
              icon: const Icon(Icons.tune_rounded, size: 26),
            ),
          ],
        ),
      ),

      body: pages[_index],

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 74,
        height: 74,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF825C2A),
          shape: const CircleBorder(),
          elevation: 6,
          onPressed: () {
            setState(() => _index = 2);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AiImageScreen()),
            );
          },
          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 32),
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        color: peach,
        height: 90,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, "Home"),
              _navItem(1, Icons.restaurant_menu_rounded, "Meal"),
              const SizedBox(width: 36),
              _navItem(3, Icons.calendar_month_rounded, "Diary"),
              _navItem(4, Icons.person_rounded, "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final active = Theme.of(context).colorScheme.primary;
    final selected = _index == index;

    return InkWell(
      onTap: () => _onTap(index),
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 26, color: selected ? active : Colors.black54),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? active : Colors.black54,
                )),
          ],
        ),
      ),
    );
  }
}

/* ------------------------------------------------------------
 *                HOME SCREEN (ข้อมูลกลับมาครบ)
 * ------------------------------------------------------------ */

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

            // ------------------ DATE AREA ------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _arrowButton(Icons.chevron_left_rounded),
                const SizedBox(width: 8),
                const Text('2 November',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                _arrowButton(Icons.chevron_right_rounded),
              ],
            ),
            const SizedBox(height: 20),

            // ------------------ BASIC KNOWLEDGE BOX ------------------
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: lightPeach,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 8,
                        offset: Offset(0, 2))
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
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
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          SizedBox(height: 2),
                          Text('Tap to learn Daily Nutrition and tips',
                              style: TextStyle(
                                  fontSize: 12.5, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            // ------------------ GOAL BOX ------------------
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
                      offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Goal',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
                                  fontWeight: FontWeight.w600, fontSize: 12.5)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Target weight',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black54)),
                          SizedBox(height: 4),
                          Text('78 kg  →  65 kg',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text('Days',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black54)),
                          SizedBox(height: 4),
                          Text('365 Days',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ------------------ NUTRIENT BOX ------------------
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: lightPeach,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x11000000),
                      blurRadius: 8,
                      offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  const Text('Nutrients received today',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
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

            const SizedBox(height: 90),
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
              offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, size: 22),
      ),
    );
  }
}

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
            style:
                const TextStyle(fontSize: 11, color: Colors.black54)),
        Text(value,
            style:
                const TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }
}
