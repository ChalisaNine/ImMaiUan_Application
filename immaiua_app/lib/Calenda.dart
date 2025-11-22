import 'package:flutter/material.dart';
import 'main.dart';
import 'Meal.dart';
import 'ai_image.dart';
import 'profile_screen.dart';
import 'day_report.dart';
import 'weekly_report.dart';        // ⭐ เพิ่ม
import 'monthly_report.dart';      // ⭐ ถ้ายังไม่มี เดี๋ยวเราทำให้
import 'nav_bar.dart';

class CalendaScreen extends StatefulWidget {
  const CalendaScreen({super.key});

  @override
  State<CalendaScreen> createState() => _CalendaScreenState();
}

class _CalendaScreenState extends State<CalendaScreen> {
  int _index = 3; // Diary

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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  const Text(
                    "Select the date to view summaries",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  _buildCalendar(),

                  const SizedBox(height: 22),

                  _weeklyButton(),

                  const SizedBox(height: 14),

                  _monthlyButton(),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // ⭐ Calendar Section
  // -------------------------------------------------------

  Widget _buildCalendar() {
    const yellowHeader = Color(0xFFFFC93C);
    const yellowBody = Color(0xFFFFE6B3);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: yellowBody,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Month header
          Container(
            decoration: BoxDecoration(
              color: yellowHeader,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Icon(Icons.chevron_left_rounded),
                Text(
                  "Sep 2025",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Weekday row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _WeekdayLabel("Sun"),
                _WeekdayLabel("Mon"),
                _WeekdayLabel("Tue"),
                _WeekdayLabel("Wed"),
                _WeekdayLabel("Thu"),
                _WeekdayLabel("Fri"),
                _WeekdayLabel("Sat"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Calendar grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 7,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(35, (i) {
                final day = i + 1;
                final isPicked = day == 19;

                if (isPicked) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DayReportScreen(),
                        ),
                      );
                    },
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Text(
                          "19",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      "$day",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // ⭐ Buttons
  // -------------------------------------------------------

  Widget _weeklyButton() {
    return SizedBox(
      width: 260,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC93C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.calendar_today_rounded, color: Colors.black87),
        label: const Text(
          "Weekly report",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        // ⭐ ไปหน้า Weekly Report
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WeeklyReportScreen()),
          );
        },
      ),
    );
  }

  Widget _monthlyButton() {
    return SizedBox(
      width: 260,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC93C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.calendar_month_rounded, color: Colors.black87),
        label: const Text(
          "Monthly report",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87),
        ),

        // ⭐ ไปหน้า Monthly Report
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MonthlyReportScreen()),
          );
        },
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String text;
  const _WeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
