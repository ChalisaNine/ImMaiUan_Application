import 'package:flutter/material.dart';
import 'main.dart';
import 'Meal.dart';
import 'nav_bar.dart';
import 'profile_screen.dart';
import 'Calenda.dart';
import 'ai_image.dart';

class CameraLogScreen extends StatefulWidget {
  const CameraLogScreen({super.key});

  @override
  State<CameraLogScreen> createState() => _CameraLogScreenState();
}

class _CameraLogScreenState extends State<CameraLogScreen> {
  int _index = 2; // Capture tab

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
        Navigator.push(
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: _index,
      onTap: _onTap,
      body: const _CameraLogBody(),
    );
  }
}

/* ---------------------------------------------------------
                    BODY CONTENT (UI)
---------------------------------------------------------- */

class _CameraLogBody extends StatelessWidget {
  const _CameraLogBody();

  @override
  Widget build(BuildContext context) {
    const peach = Color(0xFFFFE1C7);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* ---------------- WARNING BOX ---------------- */
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5C5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: Colors.amber),
                    SizedBox(width: 8),
                    Text("WARNING",
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "This meal contains excess nutrients.",
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _ExcessRow(label: "Sodium", value: "501 mg (102%)"),
                    _ExcessRow(label: "Sugar", value: "21 g (103%)"),
                    _ExcessRow(label: "Fat", value: "41 g (130%)"),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          /* ---------------- MEAL CARD ---------------- */
          Container(
            decoration: BoxDecoration(
              color: peach,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(16),
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

                const Text(
                  "Chicken Rice",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "95% confident",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 8),

                const Text(
                  "765 kcal",
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "per 1 plate",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          /* ---------------- NUTRIENT SUMMARY ---------------- */
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: peach,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _NutItem(icon: Icons.cake_rounded, label: "Sugar", value: "7.2 g", percent: "20%"),
                _NutItem(icon: Icons.rice_bowl_rounded, label: "Carb", value: "89 g", percent: "33%"),
                _NutItem(icon: Icons.egg_rounded, label: "Protein", value: "27 g", percent: "50%"),
                _NutItem(icon: Icons.local_pizza_rounded, label: "Fat", value: "32 g", percent: "50%"),
                _NutItem(icon: Icons.bolt_rounded, label: "Sodium", value: "2585 mg", percent: "78%"),
              ],
            ),
          ),

          const SizedBox(height: 18),

          /* ---------------- INGREDIENT ---------------- */
          const Text("Ingredient",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: peach,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "1. Chicken\n"
              "2. Jasmine rice\n"
              "3. Chicken broth\n"
              "4. Garlic\n"
              "5. Ginger\n"
              "6. Cucumber\n"
              "7. Coriander / cilantro",
              style: TextStyle(fontSize: 13.5, height: 1.45),
            ),
          ),

          const SizedBox(height: 18),

          /* ---------------- GRAM + SERVING ---------------- */
          Row(
            children: const [
            Expanded(
                child: _DropdownBox(
                  defaultValue: "100 g",
                  items: ["50 g", "100 g", "200 g"],
                  label: "Gram per serving",
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _DropdownBox(
                  defaultValue: "Plate",
                  items: ["Bowl", "Plate", "Cup"],
                  label: "Serving",
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /* ---------------- BUTTONS ---------------- */
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {}, // stay this page
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB8B8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Decline",
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showExcessWarningDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA6F1A6),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Add",
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

/* ---------------------------------------------------------
                     POPUP (Yes = go Meal)
---------------------------------------------------------- */

void _showExcessWarningDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /* Warning box inside popup */
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5C5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _ExcessRow(label: "Sodium", value: "501 mg (102%)"),
                  _ExcessRow(label: "Sugar", value: "21 g (103%)"),
                  _ExcessRow(label: "Fat", value: "41 g (130%)"),
                ],
              ),
            ),

            const SizedBox(height: 14),
            const Text(
              "Are you sure to add this meal?",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB8B8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("No",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MealScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA6F1A6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Yes",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    },
  );
}

/* ---------------------------------------------------------
                     SMALL WIDGETS
---------------------------------------------------------- */

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
        const Icon(Icons.circle, size: 7, color: Colors.black54),
        const SizedBox(width: 6),
        Text(
          "$label : $value",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _NutItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String percent;

  const _NutItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22),
        const SizedBox(height: 3),
        Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        Text(value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        Text(percent,
            style: const TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }
}

class _DropdownBox extends StatelessWidget {
  final String defaultValue;
  final List<String> items;
  final String label;

  const _DropdownBox({
    required this.defaultValue,
    required this.items,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),

        Container(
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
        ),
      ],
    );
  }
}

