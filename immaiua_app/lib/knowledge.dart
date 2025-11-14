import 'package:flutter/material.dart';

import 'KnowledgeStep2.dart';
import 'profile_screen.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  int _index = 0;

  final _pages = const <Widget>[
    _BasicKnowledgeBody(),
    Center(child: Text('Meal Screen')),
    Center(child: Text('Capture Screen')),
    Center(child: Text('Diary Screen')),
    Center(child: Text('Profile Screen')),
  ];

  void _onTap(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    const peach = Color(0xFFFFE1C7);

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

      body: _pages[_index],

      floatingActionButton: _CaptureFab(
        onPressed: () => _onTap(2),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        height: 90,
        elevation: 0,
        color: peach,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 8),
          child: _BottomBarItems(
            currentIndex: _index,
            onTap: _onTap,
          ),
        ),
      ),
    );
  }
}

/* ======================== CONTENT ======================== */

class _BasicKnowledgeBody extends StatelessWidget {
  const _BasicKnowledgeBody();

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

            const _PeachStrip(
              items: [
                _PeachMetric(icon: Icons.fitness_center_rounded, label: 'Weight', value: '78 kg'),
                _PeachMetric(icon: Icons.height_rounded, label: 'height', value: '176 cm'),
                _PeachMetric(icon: Icons.monitor_weight_rounded, label: 'BMI', value: '26.1'),
                _PeachMetric(icon: Icons.local_fire_department_rounded, label: 'BMR', value: '2561'),
                _PeachMetric(icon: Icons.bolt_rounded, label: 'TDEE', value: '3564'),
              ],
            ),
            const SizedBox(height: 16),

            const Text('Basic knowledge',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),

            _CardContainer(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [ _CardHeaderRow(left: '', right: 'Daily nutrition') ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _DailyItem(icon: Icons.cookie_rounded, title: 'Sugar', line1: '31 g', line2: 'Suggested', line3: 'per day'),
                      _DailyItem(icon: Icons.rice_bowl_rounded, title: 'Carb', line1: '315 g', line2: 'Suggested', line3: 'per day'),
                      _DailyItem(icon: Icons.egg_rounded, title: 'Protein', line1: '120 g', line2: 'Suggested', line3: 'per day'),
                      _DailyItem(icon: Icons.oil_barrel_rounded, title: 'Fat', line1: '78 g', line2: 'Suggested', line3: 'per day'),
                      _DailyItem(icon: Icons.snowing, title: 'Sodium', line1: '2434 mg', line2: 'Suggested', line3: 'per day'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _CardContainer(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: const [
                  _InfoRow(icon: Icons.cookie_rounded, title: 'Sugar', text: 'Sugar comes from fruits, honey, and sweets; calculate grams × 4 kcal.'),
                  SizedBox(height: 10),
                  _InfoRow(icon: Icons.rice_bowl_rounded, title: 'Carb', text: 'Carbohydrates from rice, grains, bread; grams × 4 kcal.'),
                  SizedBox(height: 10),
                  _InfoRow(icon: Icons.egg_rounded, title: 'Protein', text: 'Protein from meat, eggs, fish, beans; grams × 4 kcal.'),
                  SizedBox(height: 10),
                  _InfoRow(icon: Icons.oil_barrel_rounded, title: 'Fat', text: 'Fat from oils, nuts, cheese; grams × 9 kcal.'),
                  SizedBox(height: 10),
                  _InfoRow(icon: Icons.snowing, title: 'Sodium', text: 'Sodium in salt and sauces; measured in mg, no calories.'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.tonal(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const KnowledgeStep2Screen()),
                    );
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    children: [
                      Text('Next'),
                      SizedBox(width: 8),
                      Icon(Icons.double_arrow_rounded, size: 18),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

/* ======================== METRIC STRIP ======================== */

class _PeachStrip extends StatelessWidget {
  const _PeachStrip({required this.items});
  final List<_PeachMetric> items;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFFE1C7);
    const accent = Color(0xFFFFA94D);

    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items
            .map((e) => Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(e.icon, size: 22, color: Colors.black87),
                      const SizedBox(height: 6),
                      Text(e.label, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(e.value,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, color: accent, fontSize: 12)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _PeachMetric {
  final IconData icon;
  final String label;
  final String value;
  const _PeachMetric({required this.icon, required this.label, required this.value});
}

/* ======================== CARD ======================== */

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
              blurRadius: 8, spreadRadius: 0, offset: Offset(0, 2), color: Color(0x11000000))
        ],
      ),
      child: child,
    );
  }
}

class _CardHeaderRow extends StatelessWidget {
  const _CardHeaderRow({required this.left, required this.right});
  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    final style =
        Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(left, style: style), Text(right, style: style)],
    );
  }
}

/* ======================== DAILY ITEM ======================== */

class _DailyItem extends StatelessWidget {
  const _DailyItem({
    required this.icon,
    required this.title,
    required this.line1,
    required this.line2,
    required this.line3,
  });

  final IconData icon;
  final String title;
  final String line1;
  final String line2;
  final String line3;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      child: Column(
        children: [
          Icon(icon, size: 22, color: Colors.black87),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 2),
          Text(line1, style: const TextStyle(fontSize: 11)),
          Text(line2, style: const TextStyle(fontSize: 10, color: Colors.black54)),
          Text(line3, style: const TextStyle(fontSize: 10, color: Colors.black54)),
        ],
      ),
    );
  }
}

/* ======================== INFO ROW ======================== */

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 2),
              Text(text, style: const TextStyle(fontSize: 12.5, height: 1.25)),
            ],
          ),
        ),
      ],
    );
  }
}

/* ======================== NAVBAR ======================== */

class _BottomBarItems extends StatelessWidget {
  const _BottomBarItems({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const inactive = Color(0xFF8E8E8E);
    const active = Color(0xFFFFA94D);

    Widget item({
      required int idx,
      required IconData icon,
      required String label,
      Color? customColor,
    }) {
      final selected = currentIndex == idx;
      final iconColor = customColor ?? (selected ? active : inactive);

      return InkWell(
        onTap: () => onTap(idx),
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: iconColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(child: item(idx: 0, icon: Icons.home_rounded, label: 'Home')),
        Expanded(child: item(idx: 1, icon: Icons.menu_book_rounded, label: 'Meal')),
        const Expanded(child: SizedBox.shrink()),
        Expanded(
          child: item(
            idx: 3,
            icon: Icons.calendar_month_rounded,
            label: 'Diary',
            customColor: currentIndex == 3 ? active : inactive,
          ),
        ),
        Expanded(child: item(idx: 4, icon: Icons.person_rounded, label: 'Profile')),
      ],
    );
  }
}

/* ======================== CENTER FAB ======================== */

class _CaptureFab extends StatelessWidget {
  const _CaptureFab({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      height: 78,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: 72,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE1C7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
              ),
            ),
          ),

          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 6,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
