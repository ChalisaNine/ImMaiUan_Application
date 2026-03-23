import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Calenda.dart';
import 'Meal.dart';
import 'ai_image.dart';
import 'main.dart';
import 'models/allergy_option.dart';
import 'nav_bar.dart';
import 'providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  int _index = 4;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  bool _isMale = true;
  String? _bmr;
  String? _tdee;
  int? _age;
  double _multiplier = 1.2;
  String _goalType = 'MAINTAIN';
  double _goalCalorieAdjustment = 0;

  final List<AllergyOption> _selectedAllergies = [];
  List<AllergyOption> _availableAllergies = [];
  AllergyOption? _dropdownValue;
  bool _isLoadingAllergies = true;
  String? _allergyError;

  @override
  void initState() {
    super.initState();
    _syncFromProfile(context.read<UserProvider>().profile);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllergyOptions();
    });

    _weightController.addListener(_calculateMetrics);
    _heightController.addListener(_calculateMetrics);
  }

  void _syncFromProfile(Map<String, dynamic>? profile) {
    if (profile == null) return;

    _nameController.text = profile['display_name']?.toString() ?? '';
    _weightController.text = (profile['weight_kg'] ?? '').toString();
    _heightController.text = (profile['height_cm'] ?? '').toString();
    _isMale = (profile['gender'] == 'Male');
    _bmr = (profile['bmr'] ?? '').toString();
    _age = _readInt(profile['age']);
    _goalType = (profile['goal_type'] ?? 'MAINTAIN').toString();

    final bmrVal = _readDouble(profile['bmr']);
    final rawTdeeVal = _readDouble(profile['tdee']);
    final calorieTarget = _readDouble(profile['calorie_target']);

    if (bmrVal > 0 && rawTdeeVal > 0) {
      _multiplier = rawTdeeVal / bmrVal;
    }

    _goalCalorieAdjustment =
        _goalType == 'MAINTAIN' ? 0 : calorieTarget - rawTdeeVal;
    _tdee = _effectiveTdeeValue(rawTdeeVal).toString();
  }

  void _calculateMetrics() {
    if (_age == null) return;

    final weight = double.tryParse(_weightController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;

    if (weight > 0 && height > 0) {
      double bmrVal = (10 * weight) + (6.25 * height) - (5 * _age!);
      if (_isMale) {
        bmrVal += 5;
      } else {
        bmrVal -= 161;
      }

      final rawTdee = bmrVal * _multiplier;

      setState(() {
        _bmr = bmrVal.round().toString();
        _tdee = _effectiveTdeeValue(rawTdee).toString();
      });
    }
  }

  int _effectiveTdeeValue(double rawTdee) {
    final effectiveTdee = _goalType == 'MAINTAIN'
        ? rawTdee
        : rawTdee + _goalCalorieAdjustment;
    return effectiveTdee.round();
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
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    final userProvider = context.read<UserProvider>();

    if (name.isEmpty || weight == null || height == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in valid data')),
      );
      return;
    }

    final profileSuccess = await userProvider.updateProfile({
      'display_name': name,
      'weight_kg': weight,
      'height_cm': height,
      'gender': _isMale ? 'Male' : 'Female',
    });

    if (!profileSuccess) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userProvider.error ?? 'Error')),
      );
      return;
    }

    final allergySuccess = await userProvider.updateAllergies(
      _selectedAllergies.map((item) => item.id).toList(),
    );

    if (!mounted) return;

    if (allergySuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userProvider.error ?? 'Error')),
      );
    }
  }

  Future<void> _loadAllergyOptions() async {
    final userProvider = context.read<UserProvider>();

    setState(() {
      _isLoadingAllergies = true;
      _allergyError = null;
    });

    try {
      if (userProvider.profile == null) {
        await userProvider.fetchProfile();
      }

      if (!mounted) return;

      _syncFromProfile(userProvider.profile);
      final options = await userProvider.fetchAllergyOptions();
      if (!mounted) return;

      final selected = _mapProfileAllergies(userProvider.profile, options);
      setState(() {
        _availableAllergies = options;
        _selectedAllergies
          ..clear()
          ..addAll(selected);
        _dropdownValue = _nextAvailableAllergy();
        _isLoadingAllergies = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _allergyError = 'Failed to load allergy list';
        _isLoadingAllergies = false;
      });
    }
  }

  List<AllergyOption> _mapProfileAllergies(
    Map<String, dynamic>? profile,
    List<AllergyOption> options,
  ) {
    final rawAllergies = profile?['allergies'];
    if (rawAllergies is! List) return [];

    final selected = <AllergyOption>[];
    for (final item in rawAllergies) {
      AllergyOption? match;

      if (item is Map<String, dynamic>) {
        final id = _readInt(item['id']);
        final name = item['name']?.toString();
        match = options.cast<AllergyOption?>().firstWhere(
          (option) =>
              option != null &&
              ((id != null && option.id == id) ||
                  (name != null &&
                      option.name.toLowerCase() == name.toLowerCase())),
          orElse: () =>
              id != null && name != null
                  ? AllergyOption(
                      id: id,
                      name: name,
                      type: item['type']?.toString(),
                    )
                  : null,
        );
      } else {
        final name = item.toString();
        match = options.cast<AllergyOption?>().firstWhere(
          (option) =>
              option != null && option.name.toLowerCase() == name.toLowerCase(),
          orElse: () => null,
        );
      }

      if (match != null &&
          !_selectedAllergies.any((selectedItem) => selectedItem.id == match!.id) &&
          !selected.any((selectedItem) => selectedItem.id == match!.id)) {
        selected.add(match);
      }
    }

    return selected;
  }

  AllergyOption? _nextAvailableAllergy() {
    return _availableAllergies.cast<AllergyOption?>().firstWhere(
      (item) =>
          item != null &&
          !_selectedAllergies.any((selected) => selected.id == item.id),
      orElse: () => null,
    );
  }

  void _removeAllergy(AllergyOption allergy) {
    setState(() {
      _selectedAllergies.removeWhere((item) => item.id == allergy.id);
      _dropdownValue ??= allergy;
    });
  }

  String _allergyLabel(AllergyOption allergy) {
    return allergy.type == null || allergy.type!.isEmpty
        ? allergy.name
        : '${allergy.name} (${allergy.type})';
  }

  int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  double _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    const peach = Color(0xFFFFE1C7);

    return MainScaffold(
      currentIndex: _index,
      onTap: _onTap,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: peach,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage('assets/Avatar.jpg'),
                      ),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'UPLOAD',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Personal details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _labelWithField(
                          label: 'Weight',
                          controller: _weightController,
                          suffix: 'kg',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _labelWithField(
                          label: 'Height',
                          controller: _heightController,
                          suffix: 'cm',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Gender',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _genderChip(true, 'Male'),
                      const SizedBox(width: 8),
                      _genderChip(false, 'Female'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_bmr != null && _tdee != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('BMR : $_bmr'), Text('TDEE : $_tdee')],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'History of food allergies',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (_isLoadingAllergies)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: CircularProgressIndicator(),
                    )
                  else if (_allergyError != null)
                    Column(
                      children: [
                        Text(
                          _allergyError!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _loadAllergyOptions,
                          child: const Text('Retry'),
                        ),
                      ],
                    )
                  else if (_selectedAllergies.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No allergy history selected.',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    )
                  else
                    ..._selectedAllergies.map(
                      (allergy) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _allergyLabel(allergy),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () => _removeAllergy(allergy),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                      onPressed: _showAddAllergyDialog,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                onPressed: _saveProfile,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'finish',
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
      ),
    );
  }

  Widget _labelWithField({
    required String label,
    required TextEditingController controller,
    required String suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(suffix),
          ],
        ),
      ],
    );
  }

  Widget _genderChip(bool maleChip, String label) {
    final isSelected = _isMale == maleChip;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _isMale = maleChip);
          _calculateMetrics();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade400,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: isSelected ? Colors.white : Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddAllergyDialog() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Add allergy'),
          content: _isLoadingAllergies
              ? const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                )
              : _allergyError != null
              ? Text(_allergyError!)
              : DropdownButtonFormField<AllergyOption>(
                  value: _dropdownValue,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    hintText: 'Select an allergy',
                    border: OutlineInputBorder(),
                  ),
                  items: _availableAllergies
                      .where(
                        (allergy) => !_selectedAllergies.any(
                          (selected) => selected.id == allergy.id,
                        ),
                      )
                      .map(
                        (allergy) => DropdownMenuItem(
                          value: allergy,
                          child: Text(_allergyLabel(allergy)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setModalState(() {
                      _dropdownValue = value;
                    });
                  },
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final selected = _dropdownValue;
                if (selected != null) {
                  setState(() {
                    _selectedAllergies.add(selected);
                    _dropdownValue = _nextAvailableAllergy();
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
