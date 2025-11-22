import 'package:flutter/material.dart';
import 'nav_bar.dart';
import 'main.dart';
import 'Meal.dart';
import 'Calenda.dart';
import 'profile_screen.dart';
import 'ai_image.dart';

class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  int _index = 3; // Diary tab

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
        Navigator.pushReplacement(
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /* ---------------- BACK BUTTON ---------------- */
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC93C),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const CalendaScreen()),
                    );
                  },
                  child: const Text(
                    "« back",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ================= DATE HEADER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.calendar_today_rounded, size: 18),
                  SizedBox(width: 6),
                  Text(
                    "Friday 19 Sep 2025",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "Health metric",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 12),

              // ================= METRIC TABLE =================
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _metricRowTitle(),
                    const Divider(),
                    _metricRow("BMI", "26.53", "26.17", "+0.34"),
                    _metricRow("TDEE", "3470", "3510", "+40"),
                    _metricRow("BMR", "2120", "2160", "+40"),
                    _metricRow("Weight", "83.7", "84.6", "+1.10"),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ================= SUMMARY BOX =================
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC778),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "14,534",
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 18),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Total calories intake",
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFA35B),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "-9,764",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Colors.black87),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Calorie deficit/surplus",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ================= WARNING BOX =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD1D1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.warning_rounded,
                            color: Colors.red, size: 26),
                        SizedBox(width: 8),
                        Text(
                          "WARNING",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Harmful, big gap of deficit.\n"
                      "Having a weekly deficit of -9,764 kcal\n"
                      "is too much and can harm your body.\n"
                      "Please consult a health professional.",
                      style: TextStyle(fontSize: 13, height: 1.3),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "Weight graph",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 12),

              // ================= WEIGHT GRAPH =================
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Graph placeholder\n(Replace with real chart)",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black45),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================== TABLE TITLE ROW ========================
  Widget _metricRowTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text("Date", style: TextStyle(fontWeight: FontWeight.w700))),
          Expanded(child: Text("11/8/2568", textAlign: TextAlign.center)),
          Expanded(child: Text("18/9/2568", textAlign: TextAlign.center)),
          Expanded(child: Text("Progress", textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  // ======================== TABLE DATA ROW ========================
  Widget _metricRow(String metric, String oldV, String newV, String progress) {
    final isPositive = progress.contains("+");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              metric,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(oldV, textAlign: TextAlign.center)),
          Expanded(child: Text(newV, textAlign: TextAlign.center)),
          Expanded(
            child: Text(
              progress,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
