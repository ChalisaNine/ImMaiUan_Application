import 'package:flutter/material.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final Function(int) onTap;

  const MainScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const peach = Color(0xFFFFE1C7);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      // ---------------- TOP BAR ----------------
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
                child: Image.asset("assets/immaiuan_logo.jpg", height: 38),
              ),
            ),
            IconButton(
              onPressed: () => onTap(4),
              icon: const Icon(Icons.tune_rounded, size: 26),
            ),
          ],
        ),
      ),

      // ---------------- BODY ----------------
      body: body,

      // ---------------- FLOAT CAMERA BUTTON ----------------
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 74,
        height: 74,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF825C2A),
          elevation: 6,
          shape: const CircleBorder(),
          onPressed: () => onTap(2),
          child: const Icon(Icons.camera_alt_rounded,
              color: Colors.white, size: 32),
        ),
      ),

      // ---------------- BOTTOM NAV BAR ----------------
      bottomNavigationBar: BottomAppBar(
        color: peach,
        height: 90,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _item(0, "Home", Icons.home_rounded),
            _item(1, "Meal", Icons.restaurant_menu_rounded),
            const SizedBox(width: 36),
            _item(3, "Diary", Icons.calendar_month_rounded),
            _item(4, "Profile", Icons.person_rounded),
          ],
        ),
      ),
    );
  }

  // ---------------- NAV ITEM ----------------
  Widget _item(int index, String label, IconData icon) {
    const activeColor = Color(0xFFFFA94D);
    const inactiveColor = Colors.black45;

    final selected = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: selected ? activeColor : inactiveColor),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
