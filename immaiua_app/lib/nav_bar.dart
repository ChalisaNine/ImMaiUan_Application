import 'package:flutter/material.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback? onCameraTap;

  const MainScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onTap,
    this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    const peach = Color(0xFFFFE1C7);

    return Scaffold(
      // ---------------- TOP BAR ----------------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 68,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: Navigator.canPop(context) 
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        centerTitle: true,
        title: Image.asset("assets/immaiuan_logo.jpg", height: 38),
        actions: [
          IconButton(
            onPressed: () => onTap(4),
            icon: const Icon(Icons.tune_rounded, size: 26, color: Colors.black87),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ---------------- BODY with Modern Gradient Background ----------------
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              //Color.fromARGB(255, 253, 237, 225),
              Color.fromARGB(255, 250, 234, 222), // Soft peachy-orange
            ],
          ),
        ),
        child: body,
      ),

      // ---------------- FLOAT CAMERA BUTTON ----------------
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 74,
        height: 74,
        child: FloatingActionButton(
          heroTag: null,
          backgroundColor: const Color(0xFF825C2A),
          elevation: 6,
          shape: const CircleBorder(),
          onPressed: onCameraTap ?? () => onTap(2),
          child: const Icon(
            Icons.camera_alt_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),

      // ---------------- BOTTOM NAV BAR ----------------
      bottomNavigationBar: BottomAppBar(
        color: peach,
        height: 63,
        shape: const CircularNotchedRectangle(),
        notchMargin: 0,
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
        padding: const EdgeInsets.only(top: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: selected ? activeColor : inactiveColor),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
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
