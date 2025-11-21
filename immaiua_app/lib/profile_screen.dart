import 'package:flutter/material.dart';
import 'main.dart';
import 'Meal.dart';
import 'ai_image.dart';
import 'Calenda.dart';
import 'nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _index = 4;

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

      // ⭐ กลับไปใช้ AiImageScreen แบบเดิม (ไม่มี imagePath)
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AiImageScreen(),
          ),
        );
        break;

      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CalendaScreen()),
        );
        break;

      case 4:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const peach = Color(0xFFFFE1C7);

    return MainScaffold(
      currentIndex: _index,
      onTap: _onTap,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ================= PROFILE HEADER =================
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: peach,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage('assets/profile.png'),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Monser",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text("Edit"),
                    onPressed: () {},
                  ),

                  const SizedBox(height: 18),

                  // ================= METRICS ROW =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _metric("Weight", "78 kg", Icons.fitness_center),
                      _metric("Height", "176 cm", Icons.height),
                      _metric("BMI", "26.1", Icons.monitor_weight),
                      _metric("BMR", "2561", Icons.flash_on),
                      _metric("TDEE", "3564", Icons.directions_run_rounded),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= MENU 1 =================
            _menuBox([
              _menuItem(Icons.person, "Personal details", onTap: () {}),
              _menuItem(Icons.flag, "Adjust goal", onTap: () {}),
              _menuItem(Icons.settings, "Setting", onTap: () {}),
            ]),

            const SizedBox(height: 18),

            // ================= MENU 2 =================
            _menuBox([
              _menuItem(Icons.chat_bubble_outline, "Support", onTap: () {}),
              _menuItem(Icons.tag, "Version 1.0", onTap: () {}),
            ]),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // ================= METRIC BOX =================
  Widget _metric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 26),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ================= MENU BOX =================
  Widget _menuBox(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE1C7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  // ================= MENU ITEM =================
  Widget _menuItem(IconData icon, String text, {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(text, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 0,
    );
  }
}
