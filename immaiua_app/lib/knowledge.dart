import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'KnowledgeStep2.dart';
import 'main.dart';
import 'nav_bar.dart';

/* ======================== SCREEN ======================== */

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  int _index = 0;

  final _pages = <Widget>[
    const BasicKnowledgeBody(),
    const Center(child: Text('Meal Screen')),
    const Center(child: Text('Capture Screen')),
    const Center(child: Text('Diary Screen')),
    const Center(child: Text('Profile Screen')),
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
            // Back
            Align(
              alignment: Alignment.topLeft,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFE1C7),
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

            /* ================= METRICS ================= */

            PeachStrip(
              items: const [
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

            /* ================= DAILY NUTRITION ================= */

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
                      DailyItemSvg(
                        assetPath: 'assets/icons/sugar.svg',
                        title: 'Sugar',
                        line1: '31 g',
                        line2: 'Suggested',
                        line3: 'per day',
                      ),
                      DailyItemSvg(
                        assetPath: 'assets/icons/carbohydrates.svg',
                        title: 'Carb',
                        line1: '315 g',
                        line2: 'Suggested',
                        line3: 'per day',
                      ),
                      DailyItemSvg(
                        assetPath: 'assets/icons/protein.svg',
                        title: 'Protein',
                        line1: '120 g',
                        line2: 'Suggested',
                        line3: 'per day',
                      ),
                      DailyItemSvg(
                        assetPath: 'assets/icons/fat.svg',
                        title: 'Fat',
                        line1: '78 g',
                        line2: 'Suggested',
                        line3: 'per day',
                      ),
                      DailyItemSvg(
                        assetPath: 'assets/icons/sodium.svg',
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

            /* ================= INFO ================= */

            CardContainer(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: const [
                  InfoRowSvg(
                    assetPath: 'assets/icons/sugar.svg',
                    title: 'Sugar',
                    text:
                        'Sugar comes from fruits, honey, and sweets; grams × 4 kcal.',
                  ),
                  SizedBox(height: 10),
                  InfoRowSvg(
                    assetPath: 'assets/icons/carbohydrates.svg',
                    title: 'Carb',
                    text:
                        'Carbohydrates from rice, grains, bread; grams × 4 kcal.',
                  ),
                  SizedBox(height: 10),
                  InfoRowSvg(
                    assetPath: 'assets/icons/protein.svg',
                    title: 'Protein',
                    text:
                        'Protein from meat, eggs, fish, beans; grams × 4 kcal.',
                  ),
                  SizedBox(height: 10),
                  InfoRowSvg(
                    assetPath: 'assets/icons/fat.svg',
                    title: 'Fat',
                    text:
                        'Fat from oils, nuts, cheese; grams × 9 kcal.',
                  ),
                  SizedBox(height: 10),
                  InfoRowSvg(
                    assetPath: 'assets/icons/sodium.svg',
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
                  child: const Text('Next >>'),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE1C7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: items
            .map(
              (e) => Expanded(
                child: Column(
                  children: [
                    _MetricIcon(label: e.label, icon: e.icon),
                    const SizedBox(height: 6),
                    Text(e.label, style: const TextStyle(fontSize: 12)),
                    Text(
                      e.value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFFA94D),
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

class _MetricIcon extends StatelessWidget {
  const _MetricIcon({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    const size = 22.0;

    if (label == 'BMI') {
      return SvgPicture.asset('assets/icons/bmi.svg', width: size, height: size);
    }
    if (label == 'TDEE') {
      return SvgPicture.asset('assets/icons/tdee.svg', width: size, height: size);
    }
    return Icon(icon, size: size);
  }
}

class PeachMetric {
  final IconData icon;
  final String label;
  final String value;
  const PeachMetric({required this.icon, required this.label, required this.value});
}

/* ======================== SHARED COMPONENTS ======================== */

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
      ),
      child: child,
    );
  }
}

class CardHeaderRow extends StatelessWidget {
  const CardHeaderRow({super.key, required this.left, required this.right});
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

class DailyItemSvg extends StatelessWidget {
  const DailyItemSvg({
    super.key,
    required this.assetPath,
    required this.title,
    required this.line1,
    required this.line2,
    required this.line3,
  });

  final String assetPath;
  final String title;
  final String line1, line2, line3;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      child: Column(
        children: [
          SvgPicture.asset(assetPath, width: 22, height: 22),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          Text(line1, style: const TextStyle(fontSize: 11)),
          Text(line2, style: const TextStyle(fontSize: 10)),
          Text(line3, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}

class InfoRowSvg extends StatelessWidget {
  const InfoRowSvg({
    super.key,
    required this.assetPath,
    required this.title,
    required this.text,
  });

  final String assetPath;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SvgPicture.asset(assetPath, width: 22, height: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(text, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
