import 'package:flutter/material.dart';
import 'Calenda.dart';
import 'Meal.dart';
import 'ai_image.dart';
import 'knowledge.dart';
import 'profile_screen.dart';
import 'nav_bar.dart';   // ⭐ ใช้ NAV BAR กลาง

void main() => runApp(const ImMaiUanApp());

class ImMaiUanApp extends StatelessWidget {
  const ImMaiUanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ImMaiUan",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "Roboto",
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFA94D)),
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

  // ---------------- NAVIGATION ----------------
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MealScreen()),
        );
        break;

      case 2:
        Navigator.push(
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
      body: const _HomeScreen(),   // ⭐ BODY ของหน้า Home
    );
  }
}

/* --------------------------------------------------------------
 *                         HOME SCREEN (ตามรูป)
 * -------------------------------------------------------------- */

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    const lightPeach = Color(0xFFFFE1C7);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Column(
          children: [
            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.calendar_today_rounded,
                    size: 16, color: Colors.black87),
                SizedBox(width: 6),
                Text(
                  'Monday 21 Feb 2026',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 18),
            const _CalorieRing(),
            const SizedBox(height: 18),

            _SummaryCard(),
            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: lightPeach,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _NutrientChip(
                      icon: Icons.cake_rounded,
                      label: "Sugar",
                      percent: "40 %",
                      detail: "11g remain"),
                  _NutrientChip(
                      icon: Icons.rice_bowl_rounded,
                      label: "Carb",
                      percent: "20 %",
                      detail: "18g remain"),
                  _NutrientChip(
                      icon: Icons.egg_rounded,
                      label: "Protein",
                      percent: "33 %",
                      detail: "88g remain"),
                  _NutrientChip(
                      icon: Icons.local_pizza_rounded,
                      label: "Fat",
                      percent: "68 %",
                      detail: "18g remain"),
                  _NutrientChip(
                      icon: Icons.bolt_rounded,
                      label: "Sodium",
                      percent: "98 %",
                      detail: "200mg remain"),
                ],
              ),
            ),

            const SizedBox(height: 18),

            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KnowledgeScreen()),
              ),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.menu_book_rounded,
                        size: 26, color: Colors.black87),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Basic knowledge\nTap to learn Daily Nutrition & tips",
                        style: TextStyle(fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}

/* ---------------- components เหมือนเดิม (circle, summary, chips) ---------------- */

class _CalorieRing extends StatelessWidget {
  const _CalorieRing();

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFC93C);
    const blue = Color(0xFF8BC6FF);

    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: yellow, width: 26),
            ),
          ),

          Transform.rotate(
            angle: 0.55,
            child: CustomPaint(
              size: const Size(210, 210),
              painter: _ArcPainter(
                color: blue,
                strokeWidth: 26,
                startAngle: -0.4,
                sweepAngle: 0.75,
              ),
            ),
          ),

          Column(
            children: const [
              Text("2181 cal.",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text("remaining today",
                  style: TextStyle(fontSize: 13, color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double startAngle;
  final double sweepAngle;

  _ArcPainter({
    required this.color,
    required this.strokeWidth,
    required this.startAngle,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const orangeDeep = Color(0xFFFFA94D);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Weight",
                          style: TextStyle(fontSize: 12, color: Colors.black54)),
                      Text("78 kg.",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      SizedBox(height: 6),
                      Text("Height",
                          style: TextStyle(fontSize: 12, color: Colors.black54)),
                      Text("176 cm.",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Calorie intake",
                          style: TextStyle(fontSize: 12, color: Colors.black54)),
                      Text("500 kcal",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.green)),
                      SizedBox(height: 8),
                      Text("Burned calories",
                          style: TextStyle(fontSize: 12, color: Colors.black54)),
                      Text("1450 kcal",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            decoration: const BoxDecoration(
              color: orangeDeep,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              children: const [
                Expanded(
                  child: _SummaryCell(title: "BMI 24.4", subtitle: "Overweight"),
                ),
                Expanded(
                  child: _SummaryCell(title: "TDEE 3582", subtitle: "kcal"),
                ),
                Expanded(
                  child: _SummaryCell(title: "BMR 2452", subtitle: "kcal"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SummaryCell({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 2),
        Text(subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.white)),
      ],
    );
  }
}

class _NutrientChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String percent;
  final String detail;

  const _NutrientChip({
    required this.icon,
    required this.label,
    required this.percent,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      child: Column(
        children: [
          Icon(icon, size: 22, color: Colors.black87),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          Text(percent, style: const TextStyle(fontSize: 11)),
          Text(detail,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 9.5, color: Colors.black54)),
        ],
      ),
    );
  }
}
