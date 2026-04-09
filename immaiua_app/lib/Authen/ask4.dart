import 'package:flutter/material.dart';
import 'ask3.dart';
import 'ask5.dart'; // หน้าเป้าถัดไป (จะทำ placeholder ให้ด้านล่าง)
import 'package:provider/provider.dart';
import '../providers/profile_setup_provider.dart';

class Ask4Screen extends StatefulWidget {
  const Ask4Screen({super.key});

  @override
  State<Ask4Screen> createState() => _Ask4ScreenState();
}

class _Ask4ScreenState extends State<Ask4Screen> {
  String? _selectedGoal;
  double? _targetWeight;
  int _durationMonths = 1;
  bool _didLoadInitialValues = false;

  final List<String> _goals = [
    "I want to lose my weight",
    "I want to gain more weight",
    "I just want to be healthy",
    "No specific answer",
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadInitialValues) return;
    final provider = context.read<ProfileSetupProvider>();
    _selectedGoal ??= provider.goal;
    _targetWeight ??= provider.targetWeight;
    _durationMonths = provider.durationMonths ?? 1;
    _didLoadInitialValues = true;
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
                // ---------- Top back (ไป Ask3) ----------
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
                        MaterialPageRoute(builder: (_) => const Ask3Screen()),
                      );
                    },
                    child: const Text(
                      "<< back",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // ---------- Icon ----------
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
                  "What is your goal?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 28),

                // ---------- Goal options ----------
                Column(
                  children:
                      _goals
                          .map(
                            (text) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: GestureDetector(
                                onTap: () => _onGoalSelected(text),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _selectedGoal == text
                                            ? const Color(0xFFFFD84E)
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color:
                                          _selectedGoal == text
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
                                          _selectedGoal == text
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

                if (_shouldShowTargetWeight) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Expected Weight",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  _targetWeightCard(buttonColor),

                  const SizedBox(height: 24),
                ],

                if (_shouldShowDuration) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "How long would you like to take?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  _durationCard(buttonColor),

                  const SizedBox(height: 30),
                ],

                // ---------- Bottom buttons ----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // << Previous (กลับไป Ask3)
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const Ask3Screen()),
                        );
                      },
                      child: const Text(
                        "<< Previous",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Next >> (ไป Ask5)
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
                          _selectedGoal != null
                              ? () {
                                final provider =
                                    context.read<ProfileSetupProvider>();
                                provider.setGoal(_selectedGoal!);
                                provider.setTargetWeight(
                                  _shouldShowTargetWeight
                                      ? _targetWeight
                                      : null,
                                );
                                if (_shouldShowDuration) {
                                  provider.setDurationMonths(_durationMonths);
                                } else {
                                  provider.setDurationMonths(null);
                                }
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Ask5Screen(),
                                  ),
                                );
                              }
                              : null,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Next ",
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

  Widget _durationCard(Color buttonColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
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
              _durationLabel(_durationMonths),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _editDurationMonths,
            child: const Text("Edit", style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _targetWeightCard(Color buttonColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
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
              _formatWeight(_effectiveTargetWeight),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _editTargetWeight,
            child: const Text("Edit", style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Future<void> _onGoalSelected(String goal) async {
    final shouldOpenWeightEditor =
        goal != _selectedGoal &&
        (goal == "I want to lose my weight" ||
            goal == "I want to gain more weight");

    setState(() {
      _selectedGoal = goal;
      if (!_shouldShowTargetWeight) {
        _targetWeight = null;
      }
    });

    if (shouldOpenWeightEditor) {
      await _editTargetWeight();
    }
  }

  Future<void> _editTargetWeight() async {
    final controller = TextEditingController(
      text: _effectiveTargetWeight.toStringAsFixed(1),
    );
    final result = await showDialog<double>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Target weight'),
            content: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
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
    int selected = _durationMonths;
    final result = await showDialog<int>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Goal duration'),
            content: StatefulBuilder(
              builder:
                  (context, setModalState) => DropdownButtonFormField<int>(
                    initialValue: selected,
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

  bool get _shouldShowDuration =>
      _selectedGoal == "I want to lose my weight" ||
      _selectedGoal == "I want to gain more weight";

  bool get _shouldShowTargetWeight => _shouldShowDuration;

  double get _effectiveTargetWeight {
    if (_targetWeight != null) return _targetWeight!;
    final currentWeight = context.read<ProfileSetupProvider>().weight ?? 0;
    if (_selectedGoal == "I want to lose my weight") {
      return currentWeight > 1 ? currentWeight - 1 : currentWeight;
    }
    if (_selectedGoal == "I want to gain more weight") {
      return currentWeight + 1;
    }
    return currentWeight;
  }
}

String _durationLabel(int months) {
  return months == 1 ? '1 month' : '$months months';
}

String _formatWeight(double weight) {
  return '${weight.toStringAsFixed(1)} kg';
}
