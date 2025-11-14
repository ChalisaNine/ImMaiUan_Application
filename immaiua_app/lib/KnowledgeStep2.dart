import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'main.dart';

class KnowledgeStep2Screen extends StatelessWidget {
  const KnowledgeStep2Screen({super.key});

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
          onPressed: () => Navigator.pop(context),
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

      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonal(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: peach,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('« back',
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.w700)),
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Welcome Monser.',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),

              const _K2PeachStrip(items: [
                _K2PeachMetric(icon: Icons.fitness_center_rounded, label: 'Weight', value: '78 kg'),
                _K2PeachMetric(icon: Icons.height_rounded, label: 'Height', value: '176 cm'),
                _K2PeachMetric(icon: Icons.monitor_weight_rounded, label: 'BMI', value: '26.1'),
                _K2PeachMetric(icon: Icons.local_fire_department_rounded, label: 'BMR', value: '2561'),
                _K2PeachMetric(icon: Icons.bolt_rounded, label: 'TDEE', value: '3564'),
              ]),

              const SizedBox(height: 16),
              const Text('Basic knowledge',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),

              const SizedBox(height: 8),

              _K2Card(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  children: const [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [ _K2CardHeader(left: '', right: 'Daily nutrition') ],
                    ),
                    SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _K2DailyTile(icon: Icons.cookie_rounded, title: 'Sugar', line1: '31 g', line2: 'Suggested', line3: 'per day'),
                        _K2DailyTile(icon: Icons.rice_bowl_rounded, title: 'Carb', line1: '315 g', line2: 'Suggested', line3: 'per day'),
                        _K2DailyTile(icon: Icons.egg_rounded, title: 'Protein', line1: '120 g', line2: 'Suggested', line3: 'per day'),
                        _K2DailyTile(icon: Icons.oil_barrel_rounded, title: 'Fat', line1: '78 g', line2: 'Suggested', line3: 'per day'),
                        _K2DailyTile(icon: Icons.snowing, title: 'Sodium', line1: '2434 mg', line2: 'Suggested', line3: 'per day'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              _K2Card(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: const [
                    _K2ExplainRow(leftTitle: 'BMR', rightText:
                        'The calories your body needs at rest (breathing, circulation, organ function).'),
                    SizedBox(height: 14),
                    _K2ExplainRow(leftTitle: 'TDEE', rightText:
                        'The total calories you burn daily including activity + digestion.'),
                    SizedBox(height: 14),
                    _K2ExplainRow(leftTitle: 'BMI', rightText:
                        'A simple weight/height ratio to categorize body condition; not body-fat direct.'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton.tonal(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MainHomeScreen()),
                        (route) => false,
                      );
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Finish »'),
                  ),
                ],
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      // 🍑 FAB กล้องตรงกลางแบบเหมือนหน้าแรก
      floatingActionButton: const _CaptureFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 🍑 Bottom Navbar แบบเดียวกับหน้าแรก (Home – Meal – Capture – Diary – Profile)
      bottomNavigationBar: _BottomNavBar(
        currentIndex: 1,
        onTap: (i) {
          if (i == 2) return; // central Capture via FAB
        },
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                METRIC STRIP                                */
/* -------------------------------------------------------------------------- */

class _K2PeachStrip extends StatelessWidget {
  const _K2PeachStrip({required this.items});
  final List<_K2PeachMetric> items;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFFE1C7);
    const accent = Color(0xFFFFA94D);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: items
            .map(
              (e) => Expanded(
                child: Column(
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
              ),
            )
            .toList(),
      ),
    );
  }
}

class _K2PeachMetric {
  final IconData icon;
  final String label;
  final String value;
  const _K2PeachMetric({required this.icon, required this.label, required this.value});
}

/* -------------------------------------------------------------------------- */
/*                                   CARDS                                    */
/* -------------------------------------------------------------------------- */

class _K2Card extends StatelessWidget {
  const _K2Card({required this.child, this.padding});
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
              blurRadius: 8, offset: Offset(0, 2), color: Color(0x11000000)),
        ],
      ),
      child: child,
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                               CARD COMPONENTS                               */
/* -------------------------------------------------------------------------- */

class _K2DailyTile extends StatelessWidget {
  const _K2DailyTile({
    required this.icon,
    required this.title,
    required this.line1,
    required this.line2,
    required this.line3,
  });

  final IconData icon;
  final String title;
  final String line1, line2, line3;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      child: Column(
        children: [
          Icon(icon, size: 22),
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

class _K2CardHeader extends StatelessWidget {
  const _K2CardHeader({required this.left, required this.right});
  final String left, right;

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

class _K2ExplainRow extends StatelessWidget {
  const _K2ExplainRow({required this.leftTitle, required this.rightText});
  final String leftTitle, rightText;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: 64,
            child: Text(leftTitle,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            rightText,
            style: const TextStyle(fontSize: 13, height: 1.25),
          ),
        )
      ],
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                           NEW NAVBAR (MATCH UI)                            */
/* -------------------------------------------------------------------------- */

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const inactive = Color(0xFF8E8E8E);
    const active = Color(0xFFFFA94D);

    Widget item({required int idx, required IconData icon, required String label}) {
      final selected = currentIndex == idx;

      return Expanded(
        child: InkWell(
          onTap: () => onTap(idx),
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                Icon(icon, size: 24, color: selected ? active : inactive),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 11,
                      color: selected ? active : inactive,
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
        ),
      );
    }

    return BottomAppBar(
      height: 88,
      color: const Color(0xFFFFE1C7),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        children: [
          item(idx: 0, icon: Icons.home_rounded, label: "Home"),
          item(idx: 1, icon: Icons.menu_book_rounded, label: "Meal"),
          const Expanded(child: SizedBox.shrink()), // เว้นที่ปุ่ม Capture
          item(idx: 3, icon: Icons.calendar_month_rounded, label: "Diary"),
          item(idx: 4, icon: Icons.person_rounded, label: "Profile"),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                          CAPTURE FAB (MATCH UI)                           */
/* -------------------------------------------------------------------------- */

class _CaptureFab extends StatelessWidget {
  const _CaptureFab();

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
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
            ),
          ),
          Material(
            color: Colors.white,
            elevation: 6,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {},
              child: Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_camera_rounded,
                    size: 30, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
