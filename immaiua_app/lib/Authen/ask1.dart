import 'package:flutter/material.dart';
import 'ask2.dart';

class Ask1Screen extends StatefulWidget {
  const Ask1Screen({super.key});

  @override
  State<Ask1Screen> createState() => _Ask1ScreenState();
}

class _Ask1ScreenState extends State<Ask1Screen> {
  bool? _isMale;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFFE1C7);
    const buttonColor = Color(0xFFFFA94D);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "<< back",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Icon in circle
              Container(
                padding: const EdgeInsets.all(22),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFD84E),
                ),
                child: const Icon(
                  Icons.transgender_rounded,
                  size: 80,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "Biological Genders",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 28),

              // Male / Female buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _genderButton(
                    icon: Icons.male_rounded,
                    label: "Male",
                    selected: _isMale == true,
                    onTap: () => setState(() => _isMale = true),
                  ),
                  const SizedBox(width: 14),
                  _genderButton(
                    icon: Icons.female_rounded,
                    label: "Female",
                    selected: _isMale == false,
                    onTap: () => setState(() => _isMale = false),
                  ),
                ],
              ),

              const Spacer(),

              // Next button
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isMale != null
                      ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Ask2Screen(),
                            ),
                          );
                        }
                      : null,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Next  ",
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genderButton({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFD84E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? Colors.black87 : Colors.black26,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: selected ? Colors.black87 : Colors.black54,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.black : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
