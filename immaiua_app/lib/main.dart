import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'Calenda.dart';
import 'Meal.dart';
import 'ai_image.dart';
import 'knowledge.dart';
import 'profile_screen.dart';
import 'EditProfile.dart';
import 'nav_bar.dart'; // ⭐ ใช้ NAV BAR กลาง
import 'login.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_setup_provider.dart';
import 'providers/user_provider.dart';
import 'providers/meal_provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const ImMaiUanApp());
}

class ImMaiUanApp extends StatelessWidget {
  const ImMaiUanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProxyProvider<AuthProvider, ProfileSetupProvider>(
          create:
              (context) => ProfileSetupProvider(
                context.read<AuthProvider>().authService,
              ),
          update:
              (_, auth, prev) => prev ?? ProfileSetupProvider(auth.authService),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create:
              (context) =>
                  UserProvider(context.read<AuthProvider>().authService),
          update: (_, auth, prev) => prev ?? UserProvider(auth.authService),
        ),
        ChangeNotifierProxyProvider<AuthProvider, MealProvider>(
          create:
              (context) =>
                  MealProvider(context.read<AuthProvider>().authService),
          update: (_, auth, prev) => prev ?? MealProvider(auth.authService),
        ),
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
      showBackButton: false,
      canPopScreen: false,
      body: const _HomeScreen(), // ⭐ BODY ของหน้า Home
    );
  }
}

/* --------------------------------------------------------------
 *                         HOME SCREEN (ตามรูป)
 * -------------------------------------------------------------- */

class _HomeScreen extends StatefulWidget {
  const _HomeScreen();

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final today = DateTime.now().toIso8601String().split('T')[0];
      context.read<MealProvider>().fetchDailySummary(today);
      context.read<UserProvider>().fetchProfile();
    });
  }

  String _formatDate(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    const lightPeach = Color(0xFFFFE1C7);
    final today = DateTime.now();

    return SafeArea(
      top: false,
      child: Consumer2<MealProvider, UserProvider>(
        builder: (context, mealProvider, userProvider, child) {
          final dailySummary = mealProvider.dailySummary;
          final profile = userProvider.profile;
          final isLoading = mealProvider.isLoading || userProvider.isLoading;

          // Extract nutrient data with defaults
          final total = dailySummary?['total'] ?? {};
          final calories = (total['calories'] ?? 0).toDouble();
          final protein = (total['protein'] ?? 0).toDouble();
          final fat = (total['fat'] ?? 0).toDouble();
          final carb = (total['carb'] ?? 0).toDouble();
          final sugar = (total['sugar'] ?? 0).toDouble();
          final sodium = (total['sodium'] ?? 0).toDouble();

          // Extract profile data
          final calorieTarget = (profile?['calorie_target'] ?? 2000).toDouble();
          final carbTarget =
              (profile?['carb_prefer'] as num?)?.toDouble() ?? 300.0;
          final proteinTarget =
              (profile?['protein_prefer'] as num?)?.toDouble() ?? 50.0;
          final fatTarget =
              (profile?['fat_prefer'] as num?)?.toDouble() ?? 70.0;
          final sugarTarget =
              (profile?['sugar_target_max'] as num?)?.toDouble() ??
              (profile?['sugar_target'] as num?)?.toDouble() ??
              50.0;
          final sodiumTarget =
              (profile?['sodium_target'] as num?)?.toDouble() ?? 2000.0;
          final weight = profile?['weight_kg']?.toString() ?? "0";
          final height = profile?['height_cm']?.toString() ?? "0";
          final bmi = profile?['bmi']?.toStringAsFixed(1) ?? "0.0";
          final bmr = profile?['bmr']?.toString() ?? "0";
          final tdee = _displayTdee(profile);

          // Calculate remaining calories
          final remaining = calorieTarget - calories;
          final burnedCalories = calorieTarget - calories;
          final progress = calorieTarget > 0 ? calories / calorieTarget : 0.0;

          int calculatePercentage(double intake, double target) {
            if (target <= 0) {
              return intake <= 0 ? 0 : 100;
            }
            return ((intake / target) * 100).toInt();
          }

          final sugarPercentage = calculatePercentage(sugar, sugarTarget);
          final carbPercentage = calculatePercentage(carb, carbTarget);
          final proteinPercentage = calculatePercentage(protein, proteinTarget);
          final fatPercentage = calculatePercentage(fat, fatTarget);
          final sodiumPercentage = calculatePercentage(sodium, sodiumTarget);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Column(
              children: [
                const SizedBox(height: 6),

                // ---------------- วันที่ ----------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(today),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ---------------- วงแหวนแคลอรี่ ----------------
                if (isLoading && dailySummary == null)
                  const SizedBox(
                    width: 296,
                    height: 296,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  _CalorieRing(
                    calories: calories,
                    remaining: remaining,
                    progress: progress.clamp(0.0, 1.0),
                  ),

                const SizedBox(height: 18),

                // ---------------- การ์ดสรุป ----------------
                _SummaryCard(
                  weight: weight,
                  height: height,
                  calories: calories,
                  burnedCalories: burnedCalories,
                  tdee: tdee,
                  bmi: bmi,
                  bmr: bmr,
                ),

                const SizedBox(height: 18),

                // ---------------- แถวสารอาหาร ----------------
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
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
                    children: [
                      _NutrientChip(
                        icon: Icons.cake_rounded,
                        label: "Sugar",
                        percentage: sugarPercentage,
                        value: sugar,
                        unit: "g",
                      ),
                      _NutrientChip(
                        icon: Icons.rice_bowl_rounded,
                        label: "Carb",
                        percentage: carbPercentage,
                        value: carb,
                        unit: "g",
                      ),
                      _NutrientChip(
                        icon: Icons.egg_rounded,
                        label: "Protein",
                        percentage: proteinPercentage,
                        value: protein,
                        unit: "g",
                      ),
                      _NutrientChip(
                        icon: Icons.local_pizza_rounded,
                        label: "Fat",
                        percentage: fatPercentage,
                        value: fat,
                        unit: "g",
                      ),
                      _NutrientChip(
                        icon: Icons.bolt_rounded,
                        label: "Sodium",
                        percentage: sodiumPercentage,
                        value: sodium,
                        unit: "mg",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ---------------- Basic knowledge ----------------
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const KnowledgeScreen(),
                        ),
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
          );
        },
      ),
    );
  }
}

/* --------------------------------------------------------------
 *                        COMPONENTS
 * -------------------------------------------------------------- */

class _CalorieRing extends StatelessWidget {
  final double calories;
  final double remaining;
  final double progress;

  const _CalorieRing({
    required this.calories,
    required this.remaining,
    required this.progress,
  });

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
              progress: progress,
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
            children: [
              Text(
                "${remaining.round()} kcal.",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
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
    final paint =
        Paint()
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

    final paint =
        Paint()
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

    final paint =
        Paint()
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

    final paint =
        Paint()
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
  final String weight;
  final String height;
  final double calories;
  final double burnedCalories;
  final String tdee;
  final String bmi;
  final String bmr;

  const _SummaryCard({
    required this.weight,
    required this.height,
    required this.calories,
    required this.burnedCalories,
    required this.tdee,
    required this.bmi,
    required this.bmr,
  });

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
                      Text(
                        "$weight kg.",
                        style: const TextStyle(
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
                      Text(
                        "$height cm.",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Edit button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          ).then((_) {
                            // Refresh profile data when returning
                            context.read<UserProvider>().fetchProfile();
                          });
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
                        children: [
                          const Icon(
                            Icons.restaurant,
                            size: 28,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "${calories.round()}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
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
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            size: 28,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "${burnedCalories.round()}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF9800),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
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
              children: [
                _SummaryCell(
                  title: "BMI $bmi",
                  subtitle:
                      bmi != "0.0"
                          ? (double.parse(bmi) < 18.5
                              ? "Underweight"
                              : double.parse(bmi) < 25
                              ? "Normal"
                              : double.parse(bmi) < 30
                              ? "Overweight"
                              : "Obese")
                          : "-",
                ),
                _SummaryCell(title: "TDEE $tdee", subtitle: "kcal"),
                _SummaryCell(title: "BMR $bmr", subtitle: "kcal"),
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
  final int percentage;
  final double value;
  final String unit;

  const _NutrientChip({
    required this.icon,
    required this.label,
    required this.percentage,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final isOver = percentage > 100;
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
          Text(
            "$percentage %",
            style: TextStyle(
              fontSize: 11,
              color: isOver ? Colors.red.shade700 : Colors.black87,
              fontWeight: isOver ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
          Text(
            "${value.toStringAsFixed(1)} $unit",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

String _displayTdee(Map<String, dynamic>? profile) {
  final tdee = _readDouble(profile?['tdee']);
  if (tdee > 0) return tdee.round().toString();

  // Fallback to calorieTarget ONLY if TDEE is missing
  final calorieTarget = _readDouble(profile?['calorie_target']);
  if (calorieTarget > 0) return calorieTarget.round().toString();

  return '0';
}

double _readDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
