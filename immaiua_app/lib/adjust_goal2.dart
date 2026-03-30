import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Calenda.dart';
import 'Meal.dart';
import 'ai_image.dart';
import 'knowledge.dart';
import 'main.dart';
import 'nav_bar.dart';
import 'profile_screen.dart';
import 'providers/user_provider.dart';

class AdjustGoal2Screen extends StatefulWidget {
  final String selectedGoalType;

  const AdjustGoal2Screen({super.key, required this.selectedGoalType});

  @override
  State<AdjustGoal2Screen> createState() => _AdjustGoal2ScreenState();
}

class _AdjustGoal2ScreenState extends State<AdjustGoal2Screen> {
  int _index = 4;
  late String _goalType;
  double? _targetWeight;
  int? _durationMonths;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _goalType = widget.selectedGoalType;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.profile == null) {
        userProvider.fetchProfile();
      }
      _syncFromProfile(userProvider.profile);
    });
  }

  void _syncFromProfile(Map<String, dynamic>? profile) {
    if (_initialized || profile == null) return;
    final currentWeight = _readDouble(profile['weight_kg']);
    final savedDuration = _monthsUntil(profile['goal_end_date']);
    final profileGoalType = (profile['goal_type'] ?? _goalType).toString();

    setState(() {
      _goalType = widget.selectedGoalType;
      _targetWeight = currentWeight;
      _durationMonths = savedDuration ?? 1;
      if ((profile['goal_type'] ?? '').toString().isNotEmpty &&
          widget.selectedGoalType == profileGoalType) {
        _goalType = profileGoalType;
      }
      _initialized = true;
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
          if (!_initialized && profile != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _syncFromProfile(profile);
              }
            });
          }

          final currentWeight = _readDouble(profile?['weight_kg']);
          final bmi = _readDouble(profile?['bmi']);
          final targetWeight = _targetWeight ?? _defaultTargetWeight(currentWeight, _goalType);
          final durationMonths = _durationMonths ?? 1;
          final diffKg = (targetWeight - currentWeight).abs();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Expected Weight",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _editRowCard(
                  valueText: targetWeight.toStringAsFixed(1),
                  onEdit: _editTargetWeight,
                ),
                const SizedBox(height: 16),
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
                      Text(
                        "Goal : ${_goalLabel(_goalType)} ${diffKg.toStringAsFixed(1)} kg",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Text(
                              "Your Body Mass Index",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
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
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
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
                const Text(
                  "How long would you like to take?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _editRowCard(
                  valueText: _durationLabel(durationMonths),
                  onEdit: _editDurationMonths,
                ),
                if (userProvider.error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    userProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA94D),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: userProvider.isLoading ? null : _saveGoal,
                    child: userProvider.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "finish",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
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

  Future<void> _editTargetWeight() async {
    final controller = TextEditingController(
      text: (_targetWeight ?? 0).toStringAsFixed(1),
    );
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Target weight'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, double.tryParse(controller.text));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _targetWeight = result;
      });
    }
  }

  Future<void> _editDurationMonths() async {
    int selected = _durationMonths ?? 1;
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Goal duration'),
        content: StatefulBuilder(
          builder: (context, setModalState) => DropdownButtonFormField<int>(
            value: selected,
            decoration: const InputDecoration(
              labelText: 'Duration',
              border: OutlineInputBorder(),
            ),
            items: List.generate(
              12,
              (index) => DropdownMenuItem(
                value: index + 1,
                child: Text(_durationLabel(index + 1)),
              ),
            ),
            onChanged: (value) {
              if (value == null) return;
              setModalState(() {
                selected = value;
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, selected),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _durationMonths = result;
      });
    }
  }

  Future<void> _saveGoal() async {
    final success = await context.read<UserProvider>().updateGoal(
      goalType: _goalType,
      targetWeight: _targetWeight,
      durationMonths: _durationMonths,
    );

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }
  }

  Widget _editRowCard({
    required String valueText,
    required VoidCallback onEdit,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE1C7),
        borderRadius: BorderRadius.circular(16),
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
          Expanded(
            child: Text(
              valueText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const Icon(Icons.edit, size: 18),
          const SizedBox(width: 6),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onEdit,
            child: const Text("Edit", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

double _readDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

double _defaultTargetWeight(double currentWeight, String goalType) {
  switch (goalType) {
    case 'LOSE':
      return currentWeight > 1 ? currentWeight - 1 : currentWeight;
    case 'GAIN':
      return currentWeight + 1;
    default:
      return currentWeight;
  }
}

int? _monthsUntil(dynamic isoDate) {
  if (isoDate == null) return null;
  final endDate = DateTime.tryParse(isoDate.toString());
  if (endDate == null) return null;
  final now = DateTime.now();
  final months = ((endDate.year - now.year) * 12) + (endDate.month - now.month);
  return months <= 0 ? 1 : months;
}

String _goalLabel(String goalType) {
  switch (goalType) {
    case 'LOSE':
      return 'Lose';
    case 'GAIN':
      return 'Gain';
    default:
      return 'Maintain';
  }
}

String _durationLabel(int months) {
  return months == 1 ? '1 month' : '$months months';
}

String _bmiLabel(double bmi) {
  if (bmi < 18.5) return "Underweight";
  if (bmi < 25) return "Normal";
  if (bmi < 30) return "Overweight";
  return "Obese";
}
