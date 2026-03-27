import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../activity_level_options.dart';
import '../providers/profile_setup_provider.dart';
import 'ask1.dart';
import 'ask3.dart';

class Ask2Screen extends StatefulWidget {
  const Ask2Screen({super.key});

  @override
  State<Ask2Screen> createState() => _Ask2ScreenState();
}

class _Ask2ScreenState extends State<Ask2Screen> {
  String? _selectedLevel;

  @override
  void initState() {
    super.initState();
    _selectedLevel = normalizeActivityLevel(
      context.read<ProfileSetupProvider>().activityLevel,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFFE1C7);
    const buttonColor = Color(0xFFFFA94D);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const Ask1Screen()),
                      );
                    },
                    child: const Text(
                      '<< back',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFD84E),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    size: 80,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'How many workouts\ndo you do per week ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 28),
                Column(
                  children:
                      activityLevelOptions
                          .map(
                            (text) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: GestureDetector(
                                onTap:
                                    () => setState(() => _selectedLevel = text),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _selectedLevel == text
                                            ? const Color(0xFFFFD84E)
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color:
                                          _selectedLevel == text
                                              ? Colors.black87
                                              : Colors.black26,
                                      width: 1.3,
                                    ),
                                  ),
                                  child: Text(
                                    text,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          _selectedLevel == text
                                              ? Colors.black
                                              : Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const Ask1Screen()),
                        );
                      },
                      child: const Text(
                        '<< Previous',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed:
                          _selectedLevel == null
                              ? null
                              : () {
                                context
                                    .read<ProfileSetupProvider>()
                                    .setActivityLevel(_selectedLevel!);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Ask3Screen(),
                                  ),
                                );
                              },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Next ',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(
                            Icons.double_arrow_rounded,
                            size: 16,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
