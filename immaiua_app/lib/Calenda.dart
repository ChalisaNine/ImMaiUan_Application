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
    const yellowHeader = Color(0xFFFFC93C);
    const yellowBody = Color(0xFFFFE6B3);

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
        color: yellowBody,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Month header with navigation
          Container(
            decoration: const BoxDecoration(
              color: yellowHeader,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _prevMonth,
                      child: const Icon(Icons.chevron_left_rounded, size: 28),
                    ),
                    Text(
                      "${_monthNames[month - 1]} $year",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: _nextMonth,
                      child: const Icon(Icons.chevron_right_rounded, size: 28),
                    ),
                  ],
                ),
                // Show "Today" button only when not on current month
                if (_displayMonth.year != _today.year ||
                    _displayMonth.month != _today.month)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: GestureDetector(
                      onTap: _goToToday,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange, width: 1.2),
                        ),
                        child: const Text(
                          'Go to Today',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10),

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

          const SizedBox(height: 8),

          // Calendar grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
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
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.orangeAccent
                            : isToday
                            ? const Color(0xFFFFC93C)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isToday && !isSelected
                            ? Border.all(color: Colors.orange, width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          "$dayNum",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isToday || isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // Buttons
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
            color: Colors.black87,
          ),
        ),
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
