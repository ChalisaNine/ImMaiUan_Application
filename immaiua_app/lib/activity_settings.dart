import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'activity_level_options.dart';
import 'Calenda.dart';
import 'Meal.dart';
import 'ai_image.dart';
import 'main.dart';
import 'nav_bar.dart';
import 'providers/user_provider.dart';

class ActivitySettingsScreen extends StatefulWidget {
  const ActivitySettingsScreen({super.key});

  @override
  State<ActivitySettingsScreen> createState() => _ActivitySettingsScreenState();
}

class _ActivitySettingsScreenState extends State<ActivitySettingsScreen> {
  int _index = 4;
  String? _selectedLevel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.profile == null) {
        userProvider.fetchProfile();
      } else {
        _syncFromProfile(userProvider.profile);
      }
    });
  }

  void _syncFromProfile(Map<String, dynamic>? profile) {
    final currentLevel = normalizeActivityLevel(profile?['activity_level']);
    if (currentLevel == null) return;

    if (mounted) {
      setState(() {
        _selectedLevel = currentLevel;
      });
    }
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

  Future<void> _saveActivityLevel() async {
    if (_selectedLevel == null) return;

    final profile = context.read<UserProvider>().profile ?? {};
    final data = <String, dynamic>{
      'activity_level': _selectedLevel,
      if (profile['display_name'] != null) 'display_name': profile['display_name'],
      if (profile['weight_kg'] != null)
        'weight_kg': _readDouble(profile['weight_kg']),
      if (profile['height_cm'] != null)
        'height_cm': _readDouble(profile['height_cm']),
      if (profile['gender'] != null) 'gender': profile['gender'],
    };

    final success = await context.read<UserProvider>().updateProfile(data);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      final error = context.read<UserProvider>().error ?? 'Update failed';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
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
          final currentLevel =
              normalizeActivityLevel(_selectedLevel) ??
              normalizeActivityLevel(profile?['activity_level']);

          if (_selectedLevel == null && profile != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _syncFromProfile(profile);
              }
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Workout frequency',
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
                  child: const Row(
                    children: [
                      Icon(Icons.fitness_center_rounded, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'How many workouts do you do per week?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (currentLevel != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Current activity: $currentLevel',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                ...activityLevelOptions.map(
                  (level) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _activityButton(
                      label: level,
                      selected: currentLevel == level,
                      onTap: () => setState(() => _selectedLevel = level),
                    ),
                  ),
                ),
                if (userProvider.error != null) ...[
                  const SizedBox(height: 8),
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
                    onPressed:
                        userProvider.isLoading || _selectedLevel == null
                            ? null
                            : _saveActivityLevel,
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
                                'Save',
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

  Widget _activityButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            const Icon(Icons.local_fire_department_outlined, size: 24),
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
