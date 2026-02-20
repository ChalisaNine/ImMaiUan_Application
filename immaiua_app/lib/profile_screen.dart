import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'Meal.dart';
import 'ai_image.dart';
import 'Calenda.dart';
import 'nav_bar.dart';
import 'EditProfile.dart';
import 'adjust_goal.dart';
import 'Setting_macro.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _index = 4;

  @override
  void initState() {
    super.initState();
    // Fetch profile data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchProfile();
    });
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CalendaScreen()),
        );
        break;
      case 4:
        // อยู่หน้า Profile แล้ว
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const peach = Color(0xFFFFE1C7);

    return MainScaffold(
      currentIndex: _index,
      onTap: _onTap,
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final profile = userProvider.profile;
          final isLoading = userProvider.isLoading;

          if (isLoading && profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final displayName = profile?['display_name'] ?? "User";
          // final imageUrl = profile?['image_url'] ?? ""; // Use if available
          final weight = profile?['weight_kg']?.toString() ?? "-";
          final height = profile?['height_cm']?.toString() ?? "-";
          final bmi = profile?['bmi']?.toStringAsFixed(1) ?? "-";
          final bmr = profile?['bmr']?.toString() ?? "-";
          final tdee = profile?['tdee']?.toString() ?? "-";

          return SingleChildScrollView(
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
                        backgroundImage: AssetImage('assets/Avatar.jpg'),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // ปุ่ม Edit -> EditProfileScreen
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text("Edit"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          ).then((_) {
                            // Refresh data when coming back from Edit
                            context.read<UserProvider>().fetchProfile();
                          });
                        },
                      ),

                      const SizedBox(height: 18),

                      // ================= METRICS ROW =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _metric("Weight", "$weight kg", Icons.fitness_center),
                          _metric("Height", "$height cm", Icons.height),
                          _metric("BMI", bmi, Icons.monitor_weight),
                          _metric("BMR", bmr, Icons.flash_on),
                          _metric("TDEE", tdee, Icons.directions_run_rounded),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ================= MENU 1 =================
                _menuBox([
                  _menuItem(
                    Icons.person,
                    "Personal details",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _menuItem(
                    Icons.flag,
                    "Adjust goal",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdjustGoalScreen(),
                        ),
                      );
                    },
                  ),
                  _menuItem(
                    Icons.pie_chart_outline,
                    "Adjust nutrition ratio",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MacroSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _menuItem(Icons.settings, "Setting", onTap: () {}),
                ]),

                const SizedBox(height: 18),

                // ================= MENU 2 =================
                _menuBox([
                  _menuItem(Icons.chat_bubble_outline, "Support", onTap: () {}),
                  _menuItem(Icons.tag, "Version 1.0", onTap: () {}),
                ]),

                const SizedBox(height: 24),

                // ================= LOGOUT BUTTON =================
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text(
                      "Logout",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      side: const BorderSide(color: Colors.redAccent),
                      foregroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const AuthGuard()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          );
        },
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
