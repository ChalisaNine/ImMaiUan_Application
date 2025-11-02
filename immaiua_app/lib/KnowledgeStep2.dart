import 'package:flutter/material.dart';

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
                  child: const Text(
                    '« back',
                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
                  ),
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
                _K2PeachMetric(icon: Icons.height_rounded, label: 'height', value: '176 cm'),
                _K2PeachMetric(icon: Icons.monitor_weight_rounded, label: 'BMI', value: '26.1'),
                _K2PeachMetric(icon: Icons.local_fire_department_rounded, label: 'BMR', value: '2561'),
                _K2PeachMetric(icon: Icons.bolt_rounded, label: 'TDEE', value: '3564'),
              ]),
              const SizedBox(height: 16),

              const Text(
                'Basic knowledge',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),

              _K2Card(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _K2CardHeader(left: '', right: 'Daily nutrition'),
                      ],
                    ),
                     SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _K2DailyTile(
                          icon: Icons.cookie_rounded,
                          title: 'Sugar',
                          line1: '31 g',
                          line2: 'Suggested',
                          line3: 'per day',
                        ),
                        _K2DailyTile(
                          icon: Icons.rice_bowl_rounded,
                          title: 'Carb',
                          line1: '315 g',
                          line2: 'Suggested',
                          line3: 'per day',
                        ),
                        _K2DailyTile(
                          icon: Icons.egg_rounded,
                          title: 'Protein',
                          line1: '120 g',
                          line2: 'Suggested',
                          line3: 'per day',
                        ),
                        _K2DailyTile(
                          icon: Icons.oil_barrel_rounded,
                          title: 'Fat',
                          line1: '78 g',
                         line2: 'Suggested',
                         line3: 'per day',
                        ),
                        _K2DailyTile(
                          icon: Icons.snowing,
                          title: 'Sodium',
                          line1: '2434 mg',
                          line2: 'Suggested',
                         line3: 'per day',
                        ),
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
                    _K2ExplainRow(
                      leftTitle: 'BMR',
                      rightText:
                          'The number of calories your body needs to maintain basic functions at rest (breathing, circulation, organ function).',
                    ),
                    SizedBox(height: 14),
                    _K2ExplainRow(
                      leftTitle: 'TDEE',
                      rightText:
                          'The total calories you burn in a day, including BMR plus physical activity and digestion.',
                    ),
                    SizedBox(height: 14),
                    _K2ExplainRow(
                      leftTitle: 'BMI',
                      rightText:
                          'A simple ratio of weight to height used to categorize underweight, normal, overweight, or obese — but it doesn’t measure body fat directly.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton.tonal(
                    onPressed: () {
                      // TODO: เปลี่ยนปลายทางเมื่อกด Finish ได้ตาม flow ของคุณ
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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

      floatingActionButton: const _K2CaptureFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: const _K2BottomBar(),
    );
  }
}

/* ============================= Helper Widgets ============================= */

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items
            .map(
              (e) => Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(e.icon, size: 22, color: Colors.black87),
                    const SizedBox(height: 6),
                    Text(
                      e.label,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      e.value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: accent,
                        fontSize: 12,
                      ),
                    ),
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
  const _K2PeachMetric({
    required this.icon,
    required this.label,
    required this.value,
  });
}

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
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 2),
          Text(line1,
              style:
                  const TextStyle(fontSize: 11, color: Colors.black87)),
          Text(line2,
              style:
                  const TextStyle(fontSize: 10, color: Colors.black54)),
          Text(line3,
              style:
                  const TextStyle(fontSize: 10, color: Colors.black54)),
        ],
      ),
    );
  }
}

class _K2CardHeader extends StatelessWidget {
  const _K2CardHeader({required this.left, required this.right});
  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(fontWeight: FontWeight.w700);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(left, style: style), Text(right, style: style)],
    );
  }
}

class _K2ExplainRow extends StatelessWidget {
  const _K2ExplainRow({required this.leftTitle, required this.rightText});
  final String leftTitle;
  final String rightText;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            leftTitle,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            rightText,
            style: const TextStyle(fontSize: 13, height: 1.25),
          ),
        ),
      ],
    );
  }
}

class _K2BottomBar extends StatelessWidget {
  const _K2BottomBar();

  @override
  Widget build(BuildContext context) {
    const peach = Color(0xFFFFE1C7);

    return BottomAppBar(
      height: 84,
      color: peach,
      elevation: 8,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: const [
            _K2BottomItem(icon: Icons.home_rounded, label: 'Home'),
            _K2BottomItem(icon: Icons.restaurant_menu_rounded, label: 'Meal'),
            Expanded(child: SizedBox()), // ช่องเว้นให้ FAB ตรงกลาง
            _K2BottomItem(icon: Icons.person_rounded, label: 'Profile'),
            _K2BottomItem(icon: Icons.settings_rounded, label: 'Setting'),
          ],
        ),
      ),
    );
  }
}

class _K2BottomItem extends StatelessWidget {
  const _K2BottomItem({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: Colors.black54),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _K2CaptureFab extends StatelessWidget {
  const _K2CaptureFab();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 68,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 8,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {},
          child: Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Colors.black,
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
