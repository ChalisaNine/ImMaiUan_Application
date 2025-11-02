import 'package:flutter/material.dart';
import 'knowledge.dart'; 
import 'profile_screen.dart'; 

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

    // หน้าแต่ละแท็บ (แท็บ 0 คือ Home + มีแถบความรู้ตรงกลาง)
    final pages = <Widget>[
      const _HomeBodyWithKnowledgeTab(),
      const Center(child: Text('Meal Screen')),
      const Center(child: Text('Capture Screen')),
      const Center(child: Text('Profile Screen')),
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
          height: 36,
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

      // FAB กล้องวงกลมตรงกลาง
      floatingActionButton: _CaptureFab(
        onPressed: () => _onTap(2),
        isSelected: _index == 2,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom bar + spacing เท่ากัน
      bottomNavigationBar: BottomAppBar(
        height: 84,
        color: peach,
        elevation: 8,
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

/* ======================= HOME BODY + KNOWLEDGE TAB ======================= */

class _HomeBodyWithKnowledgeTab extends StatelessWidget {
  const _HomeBodyWithKnowledgeTab();

  @override
  Widget build(BuildContext context) {
    final titleStyle =
        Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text('Welcome Monser.', style: titleStyle)),
            const SizedBox(height: 12),

            // การ์ดตัวอย่างสรุปวันนี้ (วางเพื่อให้หน้าไม่โล่ง)
            _SimpleCard(
              child: Row(
                children: const [
                  Icon(Icons.today_rounded, size: 28),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Today summary • Calories, macros, and tips.',
                      style: TextStyle(fontSize: 13.5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ▼▼ “แถบความรู้” อยู่ช่วงกลางหน้าตามที่ขอ — กดแล้วไป KnowledgeScreen ▼▼
            const _KnowledgeQuickTab(),
            // ▲▲ ---------------------------------------------------------------- ▲▲

            const SizedBox(height: 12),

            _SimpleCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Recent meals', style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 8),
                  Text('• Breakfast: Chicken rice (550 kcal)'),
                  Text('• Lunch: Pad kra pao (680 kcal)'),
                  Text('• Dinner: Tom yum soup (320 kcal)'),
                ],
              ),
            ),

            const SizedBox(height: 100), // เผื่อพื้นที่ให้เลื่อนพ้นแถบล่าง
          ],
        ),
      ),
    );
  }
}

class _SimpleCard extends StatelessWidget {
  const _SimpleCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      child: child,
    );
  }
}

/// การ์ดปุ่มลัดไปหน้าความรู้
class _KnowledgeQuickTab extends StatelessWidget {
  const _KnowledgeQuickTab({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFFE1C7);     // พีชอ่อน
    const accent = Color(0xFFFFA94D); // พีชเข้ม

    return InkWell(
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
          color: bg,
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
              child: const Icon(Icons.menu_book_rounded, size: 24, color: Colors.black87),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Basic knowledge',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  SizedBox(height: 2),
                  Text('Tap to learn daily nutrition & tips',
                      style: TextStyle(fontSize: 12.5, color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: accent),
          ],
        ),
      ),
    );
  }
}

/* ============================ WIDGET HELPERS ============================ */

class _CardContainer extends StatelessWidget {
  const _CardContainer({required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E6E6)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 2),
            color: Color(0x11000000),
          )
        ],
      ),
      child: child,
    );
  }
}

/* ============================== NAV BAR/FAB ============================= */

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
    onTap: () {
      if (idx == 0) {
        // Home -> กลับไปหน้าแรก (main.dart) โดยเคลียร์สแตกจนเหลือหน้าราก
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (idx == 3) {
        // Profile -> เปิดหน้าโปรไฟล์
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      } else {
        // แท็บอื่นทำงานตามปกติ
        onTap(idx);
      }
    },
    splashFactory: InkRipple.splashFactory,
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
        Expanded(
          child:
              item(idx: 1, icon: Icons.restaurant_menu_rounded, label: 'Meal'),
        ),
        const Expanded(child: SizedBox.shrink()), // ช่องกลางให้ FAB
        Expanded(
          child: item(idx: 3, icon: Icons.person_rounded, label: 'Profile'),
        ),
        Expanded(
          child: item(idx: 4, icon: Icons.settings_rounded, label: 'Setting'),
        ),
      ],
    );
  }
}

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
              child: const Icon(
                Icons.photo_camera_rounded,
                size: 26,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
