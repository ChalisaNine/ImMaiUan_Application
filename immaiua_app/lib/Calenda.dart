import 'package:flutter/material.dart';
import 'main.dart';
import 'Meal.dart';
import 'ai_image.dart';
import 'profile_screen.dart';

class CalendaScreen extends StatefulWidget {
  const CalendaScreen({super.key});

  @override
  State<CalendaScreen> createState() => _CalendaScreenState();
}

class _CalendaScreenState extends State<CalendaScreen> {
  int _index = 3; // Diary tab

  // ⭐ ปุ่มตรงกลาง ไปหน้า AiImageScreen แบบไม่ใช้กล้อง
  void _goToAiImage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AiImageScreen()),
    );
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
        _goToAiImage();
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
    const navColor = Color(0xFFFFE1C7);
    const activeColor = Color(0xFFFFA94D);
    const headerYellow = Color(0xFFFFC93C);
    const bodyYellow = Color(0xFFFFE6B3);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 68,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const SizedBox(width: 40),
            Expanded(
              child: Center(
                child: Image.asset('assets/immaiuan_logo.jpg', height: 38),
              ),
            ),
            IconButton(
              onPressed: () => _onTap(4),
              icon: const Icon(Icons.tune_rounded, size: 26),
            ),
          ],
        ),
      ),

      /* ========================= BODY ========================= */
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              const Text(
                "Select the date to view summaries",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Calendar card
              Container(
                width: 300,
                decoration: BoxDecoration(
                  color: bodyYellow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: headerYellow,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Icon(Icons.chevron_left_rounded, size: 22),
                          Text(
                            "Sep 2025",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, size: 22),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
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

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: GridView.count(
                        crossAxisCount: 7,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(35, (i) {
                          final day = i + 1;
                          final isSelected = day == 19;

                          return Center(
                            child: Container(
                              decoration: isSelected
                                  ? BoxDecoration(
                                      color: Colors.orangeAccent,
                                      borderRadius: BorderRadius.circular(10),
                                    )
                                  : null,
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                '$day',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 14),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Weekly report
              SizedBox(
                width: 260,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: headerYellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_today_rounded,
                      color: Colors.black87),
                  label: const Text(
                    "Weekly report",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {},
                ),
              ),

              const SizedBox(height: 14),

              // Monthly report
              SizedBox(
                width: 260,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: headerYellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_month_rounded,
                      color: Colors.black87),
                  label: const Text(
                    "Monthly report",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),

      /* ================= FAB CAMERA BUTTON ================= */
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 74,
        height: 74,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF825C2A),
          elevation: 6,
          shape: const CircleBorder(),
          // ⭐ ไปหน้า AiImageScreen
          onPressed: _goToAiImage,
          child: const Icon(Icons.camera_alt_rounded,
              color: Colors.white, size: 32),
        ),
      ),

      /* ================= NAV BAR ================= */
      bottomNavigationBar: BottomAppBar(
        color: navColor,
        height: 90,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, "Home", activeColor),
              _navItem(1, Icons.restaurant_menu_rounded, "Meal", activeColor),
              const SizedBox(width: 36),
              _navItem(3, Icons.calendar_month_rounded, "Diary", activeColor),
              _navItem(4, Icons.person_rounded, "Profile", activeColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, Color activeColor) {
    final selected = _index == index;

    return InkWell(
      onTap: () => _onTap(index),
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: selected ? activeColor : Colors.black45),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? activeColor : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    );
  }
}
