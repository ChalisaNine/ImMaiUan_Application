import 'package:flutter/material.dart';
import 'KnowledgeStep2.dart';
import 'main.dart';
import 'nav_bar.dart'; // ใช้ MainScaffold

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  int _index = 0;

  final _pages = const <Widget>[
    BasicKnowledgeBody(),
    Center(child: Text('Meal Screen')),
    Center(child: Text('Capture Screen')),
    Center(child: Text('Diary Screen')),
    Center(child: Text('Profile Screen')),
  ];

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
        Navigator.pushReplacementNamed(context, '/meal');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/capture');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/diary');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      body: _pages[_index],
      currentIndex: _index,
      onTap: _onTap,
    );
  }
}

/* ======================== CONTENT ======================== */

class BasicKnowledgeBody extends StatelessWidget {
  const BasicKnowledgeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context)
        .textTheme
        .headlineSmall
        ?.copyWith(fontWeight: FontWeight.w700);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // << Back
            Align(
              alignment: Alignment.topLeft,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA94D),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainHomeScreen(),
                    ),
                  );
                },
                child: const Text(
                  '<< Back',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            Center(child: Text('Welcome Monser.', style: titleStyle)),
            const SizedBox(height: 12),

            const PeachStrip(
              items: [
                PeachMetric(
                    icon: Icons.fitness_center_rounded,
                    label: 'Weight',
                    value: '78 kg'),
                PeachMetric(
                    icon: Icons.height_rounded,
                    label: 'Height',
                    value: '176 cm'),
                PeachMetric(
                    icon: Icons.monitor_weight_rounded,
                    label: 'BMI',
                    value: '26.1'),
                PeachMetric(
                    icon: Icons.local_fire_department_rounded,
                    label: 'BMR',
                    value: '2561'),
                PeachMetric(
                    icon: Icons.bolt_rounded,
                    label: 'TDEE',
                    value: '3564'),
              ],
            ),

            const SizedBox(height: 16),

            const Text(
              'Basic knowledge',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),

            CardContainer(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                children: const [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CardHeaderRow(left: '', right: 'Daily nutrition'),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DailyItem(
                        icon: Icons.cookie_rounded,
                        title: 'Sugar',
                        line1: '31 g',
                        line2: 'Suggested',
                        line3: 'per day',
                      ),
                      DailyItem(
                        icon: Icons.rice_bowl_rounded,
                        title: 'Carb',
                        line1: '315 g',
                        line2: 'Suggested',
                        line3: 'per day',
                      ),
                      DailyItem(
                        icon: Icons.egg_rounded,
                        title: 'Protein',
                        line1: '120 g',
                        line2: 'Suggested',
                        line3: 'per day',
                      ),
                      DailyItem(
                        icon: Icons.oil_barrel_rounded,
                        title: 'Fat',
                        line1: '78 g',
                        line2: 'Suggested',
                        line3: 'per day',
                      ),
                      DailyItem(
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

            CardContainer(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: const [
                  InfoRow(
                    icon: Icons.cookie_rounded,
                    title: 'Sugar',
                    text:
                        'Sugar comes from fruits, honey, and sweets; calculate grams × 4 kcal.',
                  ),
                  SizedBox(height: 10),
                  InfoRow(
                    icon: Icons.rice_bowl_rounded,
                    title: 'Carb',
                    text:
                        'Carbohydrates from rice, grains, bread; grams × 4 kcal.',
                  ),
                  SizedBox(height: 10),
                  InfoRow(
                    icon: Icons.egg_rounded,
                    title: 'Protein',
                    text:
                        'Protein from meat, eggs, fish, beans; grams × 4 kcal.',
                  ),
                  SizedBox(height: 10),
                  InfoRow(
                    icon: Icons.oil_barrel_rounded,
                    title: 'Fat',
                    text:
                        'Fat from oils, nuts, cheese; grams × 9 kcal.',
                  ),
                  SizedBox(height: 10),
                  InfoRow(
                    icon: Icons.snowing,
                    title: 'Sodium',
                    text:
                        'Sodium in salt and sauces; measured in mg, no calories.',
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const KnowledgeStep2Screen(),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

class PeachStrip extends StatelessWidget {
  const PeachStrip({super.key, required this.items});

  final List<PeachMetric> items;

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
                  children: [
                    Icon(e.icon, size: 22, color: Colors.black87),
                    const SizedBox(height: 6),
                    Text(e.label, style: const TextStyle(fontSize: 12)),
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

class PeachMetric {
  final IconData icon;
  final String label;
  final String value;

  const PeachMetric({
    required this.icon,
    required this.label,
    required this.value,
  });
}

/* ======================== CARD ======================== */

class CardContainer extends StatelessWidget {
  const CardContainer({super.key, required this.child, this.padding});

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
            offset: Offset(0, 2),
            color: Color(0x11000000),
          ),
        ],
      ),
      child: child,
    );
  }
}

/* ======================== HEADER ======================== */

class CardHeaderRow extends StatelessWidget {
  const CardHeaderRow({super.key, required this.left, required this.right});

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
      children: [
        Text(left, style: style),
        Text(right, style: style),
      ],
    );
  }
}

/* ======================== DAILY ITEM ======================== */

class DailyItem extends StatelessWidget {
  const DailyItem({
    super.key,
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
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(line1, style: const TextStyle(fontSize: 11)),
          Text(
            line2,
            style:
                const TextStyle(fontSize: 10, color: Colors.black54),
          ),
          Text(
            line3,
            style:
                const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

/* ======================== INFO ROW ======================== */

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
  });

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
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
