import 'package:flutter/material.dart';
import 'ai_image.dart';
import 'profile_screen.dart';
import 'main.dart';
import 'Calenda.dart';

class CameraLogScreen extends StatefulWidget {
  const CameraLogScreen({super.key});

  @override
  State<CameraLogScreen> createState() => _CameraLogScreenState();
}

class _CameraLogScreenState extends State<CameraLogScreen> {
  int _index = 2; // Capture tab เป็นค่าเริ่มต้น

  void _onTap(int i) {
    if (i == 0) {
      // ✅ ปุ่ม Home → กลับไปหน้า MainHomeScreen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainHomeScreen()),
        (route) => false,
      );
    } else if (i == 3) {
      // ✅ Profile
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    } else {
      setState(() => _index = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    const peach = Color(0xFFFFE1C7);

    final pages = <Widget>[
      const Center(child: Text('Home Screen')),
      const Center(child: Text('Meal Screen')),
      const _CameraLogBody(),
      const ProfileScreen(),
      const Center(child: Text('Setting Screen')),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.calendar_today_rounded),
        ),
        centerTitle: true,
        title: SizedBox(
          height: 40,
          child: Image.asset('assets/immaiuan_logo.jpg', fit: BoxFit.contain),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),

      body: pages[_index],

      floatingActionButton: _CaptureFab(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiImageScreen()),
          );
        },
        isSelected: _index == 2,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        height: 80,
        color: peach,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 6),
          child: _BottomBarItems(
            currentIndex: _index,
            onTap: _onTap,
          ),
        ),
      ),
    );
  }
}

/* ========================= MAIN BODY ========================= */

class _CameraLogBody extends StatelessWidget {
  const _CameraLogBody();

  @override
  Widget build(BuildContext context) {
    const peach = Color(0xFFFFE1C7);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🍛 Meal Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: peach,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/sample_food.jpg',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Fried Chicken',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('95% confident',
                    style: TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 8),
                const Text('765 kcal',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const Text('per 1 plate',
                    style: TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 🍽 Nutrient Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: peach,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _NutrientItem(
                    icon: Icons.cake_rounded,
                    label: 'Sugar',
                    value: '7.2 g',
                    percent: '20% of day'),
                _NutrientItem(
                    icon: Icons.rice_bowl_rounded,
                    label: 'Carb',
                    value: '89.1 g',
                    percent: '33% of day'),
                _NutrientItem(
                    icon: Icons.egg_rounded,
                    label: 'Protein',
                    value: '27.5 g',
                    percent: '50% of day'),
                _NutrientItem(
                    icon: Icons.local_pizza_rounded,
                    label: 'Fat',
                    value: '32.2 g',
                    percent: '50% of day'),
                _NutrientItem(
                    icon: Icons.bolt_rounded,
                    label: 'Sodium',
                    value: '2585.8 g',
                    percent: '78% of day'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Ingredient',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: peach,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '1. Chicken',
              style: TextStyle(fontSize: 13.5, height: 1.5),
            ),
          ),
          const SizedBox(height: 20),

          const Text('Gram per serving',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _DropdownBox(defaultValue: '100 g', items: ['50 g', '100 g', '200 g']),
          const SizedBox(height: 14),

          const Text('Serving',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _DropdownBox(defaultValue: 'Plate', items: ['Bowl', 'Plate', 'Cup']),
          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB8B8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Decline',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _showExcessWarningDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA6F1A6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Add',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

/* ====================== WARNING DIALOG ====================== */

void _showExcessWarningDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // กล่องเหลืองด้านบน
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5C5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        'WARNING',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This meal contains excess nutrients.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // กล่องขาวด้านใน (list nutrient)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _ExcessRow(
                          label: 'Sodium',
                          value: '501 mg (102%)',
                        ),
                        SizedBox(height: 4),
                        _ExcessRow(
                          label: 'Sugar',
                          value: '21 g (103%)',
                        ),
                        SizedBox(height: 4),
                        _ExcessRow(
                          label: 'Fat',
                          value: '41 g (130%)',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Are you sure to add this meal?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // ปุ่ม No / Yes
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // ❌ ไม่เพิ่ม: แค่ปิด dialog แล้วอยู่หน้าเดิม
                      Navigator.of(dialogCtx).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB8B8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'No',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // ✅ Yes: ปิด dialog แล้วไปหน้าต่อไป
                      Navigator.of(dialogCtx).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CalendarScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA6F1A6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Yes',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

class _ExcessRow extends StatelessWidget {
  final String label;
  final String value;

  const _ExcessRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.circle,
          size: 8,
          color: Colors.black54,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$label : $value',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/* ----------------------- Helper Widgets ----------------------- */

class _DropdownBox extends StatelessWidget {
  final String defaultValue;
  final List<String> items;

  const _DropdownBox({required this.defaultValue, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: DropdownButton<String>(
        value: defaultValue,
        underline: const SizedBox(),
        isExpanded: true,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) {},
      ),
    );
  }
}

class _NutrientItem extends StatelessWidget {
  const _NutrientItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.percent,
  });

  final IconData icon;
  final String label;
  final String value;
  final String percent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.black87),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600)),
        Text(value,
            style: const TextStyle(
                fontSize: 11, color: Colors.black87)),
        Text(percent,
            style: const TextStyle(
                fontSize: 10, color: Colors.black54)),
      ],
    );
  }
}

/* ======================== NAVIGATION BAR ======================== */

class _BottomBarItems extends StatelessWidget {
  const _BottomBarItems({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final active = Theme.of(context).colorScheme.primary;
    const inactive = Colors.black54;

    Widget item({
      required int idx,
      required IconData icon,
      required String label,
    }) {
      final selected = currentIndex == idx;
      return InkWell(
        onTap: () => onTap(idx),
        child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: selected ? active : inactive),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? active : inactive,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: item(idx: 0, icon: Icons.home_rounded, label: 'Home')),
        Expanded(child: item(idx: 1, icon: Icons.restaurant_menu_rounded, label: 'Meal')),
        const Expanded(child: SizedBox.shrink()),
        Expanded(child: item(idx: 3, icon: Icons.person_rounded, label: 'Profile')),
        Expanded(child: item(idx: 4, icon: Icons.settings_rounded, label: 'Setting')),
      ],
    );
  }
}

class _CaptureFab extends StatelessWidget {
  const _CaptureFab({
    required this.onPressed,
    this.isSelected = false,
  });

  final VoidCallback onPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final active = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 68,
      height: 68,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 8,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected ? active : Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_camera_rounded,
                size: 26,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
