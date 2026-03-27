import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'Meal.dart';
import 'ai_image.dart';
import 'Calenda.dart';
import 'nav_bar.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';

enum _MacroType { carb, protein, fat }

class MacroSettingsScreen extends StatefulWidget {
  const MacroSettingsScreen({super.key});

  @override
  State<MacroSettingsScreen> createState() => _MacroSettingsScreenState();
}

class _MacroSettingsScreenState extends State<MacroSettingsScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  int _carb = 50;
  int _protein = 20;
  int _fat = 30;
  double _calorieTarget = 2000;
  double _bmr = 0;
  double _tdee = 0;
  final TextEditingController _calorieController = TextEditingController();

  double get _carbGrams => (_calorieTarget * _carb / 100) / 4;
  double get _proteinGrams => (_calorieTarget * _protein / 100) / 4;
  double get _fatGrams => (_calorieTarget * _fat / 100) / 9;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMacroPreferences();
    });
  }

  void _onTap(int i) {
    if (i == 4) {
      Navigator.pop(context);
      return;
    }

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
    }
  }

  Future<void> _loadMacroPreferences() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.fetchProfile();
    final profile = userProvider.profile ?? <String, dynamic>{};

    final loadedCarb = _readAsInt(profile['carb_percent'], 50);
    final loadedProtein = _readAsInt(profile['protein_percent'], 20);
    final loadedFat = _readAsInt(profile['fat_percent'], 30);
    final normalized = _normalizeTo100(loadedCarb, loadedProtein, loadedFat);

    if (!mounted) return;
    setState(() {
      _carb = normalized[0];
      _protein = normalized[1];
      _fat = normalized[2];
      _calorieTarget = _readAsDouble(profile['calorie_target'], 2000);
      _bmr = _readAsDouble(profile['bmr'], 0);
      _tdee = _readAsDouble(profile['tdee'], 0);
      _calorieController.text = _calorieTarget.round().toString();
      _isLoading = false;
    });
  }

  int _readAsInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  double _readAsDouble(dynamic value, double fallback) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  List<int> _normalizeTo100(int carb, int protein, int fat) {
    final total = carb + protein + fat;
    if (total == 100) return [carb, protein, fat];
    if (total <= 0) return [50, 20, 30];

    final scaledCarb = ((carb * 100) / total).round();
    final scaledProtein = ((protein * 100) / total).round();
    final scaledFat = 100 - scaledCarb - scaledProtein;
    return [scaledCarb, scaledProtein, scaledFat];
  }

  void _setMacro(_MacroType type, double value) {
    final changed = value.round().clamp(0, 100);

    int carb = _carb;
    int protein = _protein;
    int fat = _fat;

    if (type == _MacroType.carb) {
      final distributed = _distributeRemaining(changed, protein, fat);
      carb = changed;
      protein = distributed[0];
      fat = distributed[1];
    } else if (type == _MacroType.protein) {
      final distributed = _distributeRemaining(changed, carb, fat);
      protein = changed;
      carb = distributed[0];
      fat = distributed[1];
    } else {
      final distributed = _distributeRemaining(changed, carb, protein);
      fat = changed;
      carb = distributed[0];
      protein = distributed[1];
    }

    setState(() {
      _carb = carb;
      _protein = protein;
      _fat = fat;
    });
  }

  List<int> _distributeRemaining(int changed, int otherA, int otherB) {
    final remaining = 100 - changed;
    final otherTotal = otherA + otherB;

    if (remaining <= 0) return [0, 0];

    if (otherTotal <= 0) {
      final first = remaining ~/ 2;
      return [first, remaining - first];
    }

    final first = ((remaining * otherA) / otherTotal).round().clamp(
      0,
      remaining,
    );
    return [first, remaining - first];
  }

  Future<void> _savePreferences() async {
    if (_isSaving) return;
    final parsedCalories = double.tryParse(_calorieController.text.trim());
    if (parsedCalories == null || parsedCalories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid calorie target')),
      );
      return;
    }
    if (_bmr > 0 && parsedCalories < _bmr) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Calories cannot be lower than your BMR (${_bmr.round()} kcal)',
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final authService = context.read<AuthProvider>().authService;
      final response = await authService.updateMacroPercentages(
        carbPercent: _carb,
        proteinPercent: _protein,
        fatPercent: _fat,
        calorieTarget: parsedCalories.round(),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        await context.read<UserProvider>().fetchProfile();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Macro percentages updated')),
        );
      } else {
        final message =
            response.data is Map<String, dynamic>
                ? (response.data['error']?.toString() ??
                    'Failed to update macros')
                : 'Failed to update macros';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _calorieController.dispose();
    super.dispose();
  }

  void _resetCaloriesToTdee() {
    if (_tdee <= 0) return;
    setState(() {
      _calorieTarget = _tdee;
      _calorieController.text = _tdee.round().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFFFA94D);
    const softPeach = Color(0xFFFFF5EA);

    return MainScaffold(
      currentIndex: 4,
      onTap: _onTap,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, softPeach],
          ),
        ),
        child: SafeArea(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 4),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Edit Nutrition Percentage',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          child: Text(
                            'Current Goal',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildCalorieEditor(primaryOrange),
                              Divider(
                                height: 1,
                                indent: 16,
                                color: Colors.grey.withOpacity(0.2),
                              ),
                              _buildMacroRow(
                                'Carbohydrates',
                                '${_carbGrams.toStringAsFixed(1)} g',
                                '$_carb%',
                                primaryOrange,
                              ),
                              Divider(
                                height: 1,
                                indent: 16,
                                color: Colors.grey.withOpacity(0.2),
                              ),
                              _buildMacroRow(
                                'Protein',
                                '${_proteinGrams.toStringAsFixed(1)} g',
                                '$_protein%',
                                primaryOrange,
                              ),
                              Divider(
                                height: 1,
                                indent: 16,
                                color: Colors.grey.withOpacity(0.2),
                              ),
                              _buildMacroRow(
                                'Fat',
                                '${_fatGrams.toStringAsFixed(1)} g',
                                '$_fat%',
                                primaryOrange,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          child: Text(
                            'Adjust Macro Split',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        _sliderCard(
                          child: Column(
                            children: [
                              _macroSlider(
                                label: 'Carbohydrates',
                                value: _carb.toDouble(),
                                onChanged: (v) => _setMacro(_MacroType.carb, v),
                                activeColor: const Color(0xFFFB8C00),
                              ),
                              _macroSlider(
                                label: 'Protein',
                                value: _protein.toDouble(),
                                onChanged:
                                    (v) => _setMacro(_MacroType.protein, v),
                                activeColor: const Color(0xFF43A047),
                              ),
                              _macroSlider(
                                label: 'Fat',
                                value: _fat.toDouble(),
                                onChanged: (v) => _setMacro(_MacroType.fat, v),
                                activeColor: const Color(0xFF8E24AA),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Total: ${_carb + _protein + _fat}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _savePreferences,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child:
                                _isSaving
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text(
                                      'Save Macro Percentages',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _sliderCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _macroSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required Color activeColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              '${value.round()}%',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(
            context,
          ).copyWith(activeTrackColor: activeColor, thumbColor: activeColor),
          child: Slider(
            min: 0,
            max: 100,
            divisions: 100,
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroRow(
    String label,
    String value,
    String? percentage,
    Color accentColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (percentage == null)
            Text(
              value,
              style: TextStyle(
                color: accentColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 45,
                  child: Text(
                    percentage,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCalorieEditor(Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Calories',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                width: 110,
                child: TextField(
                  controller: _calorieController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.end,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    suffixText: 'kcal',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: accentColor, width: 1.5),
                    ),
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed <= 0) return;
                    if (_bmr > 0 && parsed < _bmr) return;
                    setState(() {
                      _calorieTarget = parsed;
                    });
                  },
                ),
              ),
            ],
          ),
          if (_bmr > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Minimum allowed: ${_bmr.round()} kcal (BMR)',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
                TextButton(
                  onPressed: _resetCaloriesToTdee,
                  child: const Text('Use TDEE'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
