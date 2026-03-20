import 'package:flutter/material.dart';
import 'main.dart';
import 'Meal.dart';
import 'ai_image.dart';
import 'profile_screen.dart';
import 'day_report.dart';
import 'weekly_report.dart';
import 'monthly_report.dart';
import 'nav_bar.dart';

class CalendaScreen extends StatefulWidget {
  const CalendaScreen({super.key});

  @override
  State<CalendaScreen> createState() => _CalendaScreenState();
}

class _CalendaScreenState extends State<CalendaScreen> {
  int _index = 3; // Diary tab

  // Calendar state
  final DateTime _today = DateTime.now();
  late DateTime _displayMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _displayMonth = DateTime(_today.year, _today.month);
    _selectedDate = DateTime(_today.year, _today.month, _today.day);
  }

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

  void _prevMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
    });
  }

  void _goToToday() {
    setState(() {
      _displayMonth = DateTime(_today.year, _today.month);
      _selectedDate = DateTime(_today.year, _today.month, _today.day);
    });
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

                  const SizedBox(height: 20),

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
  // Calendar Section
  // -------------------------------------------------------

  static const _monthNames = [
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

  Widget _buildCalendar() {

    final year = _displayMonth.year;
    final month = _displayMonth.month;

    // Day of week the 1st falls on (0=Sun, 1=Mon, ..., 6=Sat)
    final firstWeekday = DateTime(year, month, 1).weekday % 7; // Sun=0
    // Total days in month
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    // Total cells needed
    final totalCells = firstWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE6B3), // Soft orange body
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month header with navigation
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFC93C), // Stronger orange header
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _prevMonth,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_left_rounded, size: 24, color: Colors.black87),
                  ),
                ),
                Text(
                  "${_monthNames[month - 1]} $year",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                GestureDetector(
                  onTap: _nextMonth,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right_rounded, size: 24, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          if (_displayMonth.year != _today.year || _displayMonth.month != _today.month)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: _goToToday,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5E5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Back to Today',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF9900),
                    ),
                  ),
                ),
              ),
            ),

          // Weekday labels
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

          const SizedBox(height: 12),

          // Calendar grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 0,
                childAspectRatio: 1,
              ),
              itemCount: rows * 7,
              itemBuilder: (context, index) {
                final dayNum = index - firstWeekday + 1;

                // Empty cell before month starts or after it ends
                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const SizedBox.shrink();
                }

                final cellDate = DateTime(year, month, dayNum);
                final isToday = DateUtils.isSameDay(cellDate, _today);
                final isSelected =
                    _selectedDate != null &&
                    DateUtils.isSameDay(cellDate, _selectedDate!);

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = cellDate);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DayReportScreen(date: cellDate),
                      ),
                    );
                  },
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFF9900)
                            : isToday
                            ? const Color(0xFFFFF5E5)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "$dayNum",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isToday || isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected 
                                ? Colors.white 
                                : (isToday ? const Color(0xFFFF9900) : Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // Buttons
  // -------------------------------------------------------

  Widget _weeklyButton() {
    return _buildReportCard(
      title: "Weekly report",
      subtitle: "View your trends for the week",
      icon: Icons.calendar_view_week_rounded,
      color: const Color(0xFFE8F5E9),
      iconColor: Colors.green.shade600,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WeeklyReportScreen()),
        );
      },
    );
  }

  Widget _monthlyButton() {
    return _buildReportCard(
      title: "Monthly report",
      subtitle: "See your progress over the month",
      icon: Icons.calendar_month_rounded,
      color: const Color(0xFFE3F2FD),
      iconColor: Colors.blue.shade600,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MonthlyReportScreen()),
        );
      },
    );
  }

  Widget _buildReportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 28),
          ],
        ),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String text;
  const _WeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
