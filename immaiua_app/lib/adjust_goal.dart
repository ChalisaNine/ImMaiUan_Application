import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Calenda.dart';
import 'Meal.dart';
import 'ai_image.dart';
import 'adjust_goal2.dart';
import 'knowledge.dart';
import 'main.dart';
import 'nav_bar.dart';
import 'providers/user_provider.dart';

class AdjustGoalScreen extends StatefulWidget {
  const AdjustGoalScreen({super.key});

  @override
  State<AdjustGoalScreen> createState() => _AdjustGoalScreenState();
}

class _AdjustGoalScreenState extends State<AdjustGoalScreen> {
  int _index = 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.profile == null) {
        userProvider.fetchProfile();
      }
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
          final bmi = _readDouble(profile?['bmi']);
          final goalType = (profile?['goal_type'] ?? 'MAINTAIN').toString();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "What is your goal?",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: peach,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Text(
                              "Your Body Mass Index",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.monitor_weight_outlined, size: 18),
                                  SizedBox(width: 4),
                                  Text("BMI", style: TextStyle(fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bmi.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4FBE6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _bmiLabel(bmi),
                          style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                          ),
                          children: [
                            const TextSpan(text: "Learn more about "),
                            TextSpan(
                              text: "Body Mass Index(BMI)",
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const KnowledgeScreen(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                _goalButton(
                  icon: Icons.south_west,
                  label: "Lose Weight",
                  selected: goalType == "LOSE",
                  onTap: () => _goToAdjustGoal2("LOSE"),
                ),
                const SizedBox(height: 12),
                _goalButton(
                  icon: Icons.compare_arrows,
                  label: "Maintain Weight",
                  selected: goalType == "MAINTAIN",
                  onTap: () => _goToAdjustGoal2("MAINTAIN"),
                ),
                const SizedBox(height: 12),
                _goalButton(
                  icon: Icons.north_west,
                  label: "Gain Weight",
                  selected: goalType == "GAIN",
                  onTap: () => _goToAdjustGoal2("GAIN"),
                ),
                if (userProvider.error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    userProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
    );
  }

  void _goToAdjustGoal2(String goalType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdjustGoal2Screen(selectedGoalType: goalType),
      ),
    );
  }

  Widget _goalButton({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFD2A6) : const Color(0xFFFFE1C7),
          borderRadius: BorderRadius.circular(16),
          border: selected
              ? Border.all(color: const Color(0xFFFFA94D), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: Color(0xFFFFA94D)),
          ],
        ),
      ),
    );
  }
}

double _readDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _bmiLabel(double bmi) {
  if (bmi < 18.5) return "Underweight";
  if (bmi < 25) return "Normal";
  if (bmi < 30) return "Overweight";
  return "Obese";
}
