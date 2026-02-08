import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'Calenda.dart';
import 'Meal.dart';
import 'ai_image.dart';
import 'knowledge.dart';
import 'profile_screen.dart';
import 'nav_bar.dart'; // ⭐ ใช้ NAV BAR กลาง
import 'login.dart';
import 'providers/auth_provider.dart';

void main() => runApp(const ImMaiUanApp());

class ImMaiUanApp extends StatelessWidget {
  const ImMaiUanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
      ],
      child: MaterialApp(
        title: "ImMaiUan",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: "Roboto",
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFA94D)),
        ),
        home: const AuthGuard(),
      ),
    );
  }
}

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case AuthStatus.authenticated:
            return const MainHomeScreen();
          case AuthStatus.unauthenticated:
            return const LoginScreen();
          case AuthStatus.unknown:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFFFA94D)),
              ),
            );
        }
      },
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
      body: const _HomeScreen(), // ⭐ BODY ของหน้า Home
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

            // ---------------- วันที่ ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Colors.black87,
                ),
                SizedBox(width: 6),
                Text(
                  'Monday 22 Feb 2026',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ---------------- วงแหวนแคลอรี่ ----------------
            const _CalorieRing(),

            const SizedBox(height: 18),

            // ---------------- การ์ดสรุป ----------------
            const _SummaryCard(),

            const SizedBox(height: 18),

            // ---------------- แถวสารอาหาร ----------------
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0E0),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _NutrientChip(
                    icon: Icons.cake_rounded,
                    label: "Sugar",
                    percent: "40 %",
                    detail: "kcal",
                  ),
                  _NutrientChip(
                    icon: Icons.rice_bowl_rounded,
                    label: "Carb",
                    percent: "20 %",
                    detail: "kcal",
                  ),
                  _NutrientChip(
                    icon: Icons.egg_rounded,
                    label: "Protein",
                    percent: "33 %",
                    detail: "kcal",
                  ),
                  _NutrientChip(
                    icon: Icons.local_pizza_rounded,
                    label: "Fat",
                    percent: "50 %",
                    detail: "kcal",
                  ),
                  _NutrientChip(
                    icon: Icons.bolt_rounded,
                    label: "Sodium",
                    percent: "98 %",
                    detail: "mg",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ---------------- Basic knowledge ----------------
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KnowledgeScreen()),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 26,
                      color: Colors.black87,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Basic knowledge\nTap to learn Daily Nutrition and tips",
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

/* --------------------------------------------------------------
 *                        COMPONENTS
 * -------------------------------------------------------------- */

class _CalorieRing extends StatelessWidget {
  const _CalorieRing();

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFC93C);
    const blue = Color(0xFF8BC6FF);
    const lightGrey = Color(0xFFE8E8E8);

    return SizedBox(
      width: 296,
      height: 296,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring background (grey track)
          CustomPaint(
            size: const Size(296, 296),
            painter: _OuterRingTrackPainter(
              trackColor: lightGrey,
              thickness: 8,
            ),
          ),

          // Outer ring progress (blue arc showing calories used)
          CustomPaint(
            size: const Size(296, 296),
            painter: _OuterRingProgressPainter(
              progressColor: blue,
              thickness: 8,
              progress: 0.65, // 65% of calories used (example)
            ),
          ),

          // Yellow Ring + Curved Text
          CustomPaint(
            size: const Size(280, 280),
            painter: _CurvedRingPainter(ringColor: yellow, thickness: 45),
          ),

          // White inner circle with shadow
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),

          // Center Text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "2181 cal.",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4),
              Text(
                "remaining today",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurvedRingPainter extends CustomPainter {
  final Color ringColor;
  final double thickness;

  _CurvedRingPainter({required this.ringColor, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - thickness) / 2;

    // 1. Draw Ring Segments
    final paint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.butt;

    // We add small gaps by reducing sweep slightly
    const gap = 0.015; // Reduced from 0.04

    // Breakfast (-180 to -90)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 + gap,
      1.5708 - gap * 1.5,
      false,
      paint,
    );
    // Lunch (-90 to 0)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708 + gap,
      1.5708 - gap * 1.5,
      false,
      paint,
    );
    // Dinner (0 to 90)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0 + gap,
      1.5708 - gap * 1.5,
      false,
      paint,
    );
    // Snack (90 to 180)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.5708 + gap,
      1.5708 - gap * 1.5,
      false,
      paint,
    );

    // 2. Draw Curved Text
    final textStyle = TextStyle(
      color: Colors.black87.withOpacity(0.8),
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );

    // Radius for text baseline (center of ring)
    _drawTextOnArc(
      canvas,
      center,
      radius,
      "Breakfast",
      -3.14159,
      -1.5708,
      textStyle,
    );
    _drawTextOnArc(canvas, center, radius, "Lunch", -1.5708, 0, textStyle);

    // For bottom text to be readable, we might need adjustments,
    // but based on typical ring charts, they often flow clockwise:
    _drawTextOnArc(canvas, center, radius, "Dinner", 0, 1.5708, textStyle);
    _drawTextOnArc(canvas, center, radius, "Snack", 1.5708, 3.14159, textStyle);
  }

  void _drawTextOnArc(
    Canvas canvas,
    Offset center,
    double radius,
    String text,
    double startAngle,
    double endAngle,
    TextStyle style,
  ) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Approximate arc length for text
    final double textArcLength =
        textPainter.width / radius; // s = r*theta -> theta = s/r

    // Center the text in the segment
    final double midAngle = (startAngle + endAngle) / 2;
    final double textTotalAngle = textPainter.width / radius;
    final double textStartAngle = midAngle - (textTotalAngle / 2);

    double currentAngle = textStartAngle;
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final charSpan = TextSpan(text: char, style: style);
      final charPainter = TextPainter(
        text: charSpan,
        textDirection: TextDirection.ltr,
      );
      charPainter.layout();

      // Angle allocated for this char
      final charAngle = charPainter.width / radius;

      canvas.save();
      // Translate to center
      canvas.translate(center.dx, center.dy);
      // Rotate to character position (midpoint of character)
      // We rotate to currentAngle + half char width
      canvas.rotate(
        currentAngle + charAngle / 2 + 1.5708,
      ); // +90deg (PI/2) to orient text tangent to circle
      // Translate to radius
      canvas.translate(0, -radius);

      // Draw char centered
      charPainter.paint(
        canvas,
        Offset(-charPainter.width / 2, -charPainter.height / 2),
      );

      canvas.restore();

      currentAngle += charAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BlueRingPainter extends CustomPainter {
  final Color color;
  final double thickness;

  _BlueRingPainter({required this.color, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - thickness) / 1;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    // No blur

    // Draw an arc representing "total calories left" (e.g. 75%)
    // Starting from top (-PI/2) and sweeping
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // -90 degrees
      4.0, // Arbitrary sweep
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Outer ring track (grey background)
class _OuterRingTrackPainter extends CustomPainter {
  final Color trackColor;
  final double thickness;

  _OuterRingTrackPainter({required this.trackColor, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - thickness) / 2;

    final paint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    // Draw full circle track
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Outer ring progress (blue arc showing calories consumed)
class _OuterRingProgressPainter extends CustomPainter {
  final Color progressColor;
  final double thickness;
  final double progress; // 0.0 to 1.0

  _OuterRingProgressPainter({
    required this.progressColor,
    required this.thickness,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - thickness) / 2;

    final paint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    // Draw arc from top (-90 degrees) clockwise
    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // Start at top (-90 degrees)
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    const orangeDeep = Color(0xFFFFA94D);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 253, 253, 253),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // --------- Top section with Weight/Height and Calorie info ---------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Left: Weight, Height, Edit button
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Weight",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "78 kg.",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Height",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "176 cm.",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Edit button
                      ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFA94D),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.grey.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              elevation: 0,
                              shadowColor: Colors.grey.withOpacity(0.2),
                            ).copyWith(
                              overlayColor: WidgetStateProperty.all(
                                Colors.white.withOpacity(0.1),
                              ),
                            ),
                        onPressed: () {
                          // TODO: Edit user data
                        },
                        child: const Text(
                          "Edit",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Center divider
                Container(
                  width: 1.5,
                  height: 120,
                  color: Colors.grey.withOpacity(0.3),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),

                // Right: Calorie intake and Burned calories with icons
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Calorie intake",
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: const [
                          Icon(
                            Icons.restaurant,
                            size: 28,
                            color: Colors.black87,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "500",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            "kcal",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Burned calories",
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: const [
                          Icon(
                            Icons.local_fire_department,
                            size: 28,
                            color: Colors.black87,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "1450",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF9800),
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            "kcal",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --------- Bottom orange bar (BMI / TDEE / BMR) ---------
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFA94D), Color(0xFFFF8C42)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _SummaryCell(title: "BMI 24.4", subtitle: "Overweight"),
                _SummaryCell(title: "TDEE", subtitle: "3582 kcal"),
                _SummaryCell(title: "BMR", subtitle: "2452 kcal"),
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Colors.white),
        ),
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
      width: 64,
      child: Column(
        children: [
          Icon(icon, size: 22, color: Colors.black87),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          Text(percent, style: const TextStyle(fontSize: 11)),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
