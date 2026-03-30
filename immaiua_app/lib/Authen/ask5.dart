import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/allergy_option.dart';
import '../providers/profile_setup_provider.dart';
import 'ask4.dart';
import 'ask6.dart';

class Ask5Screen extends StatefulWidget {
  const Ask5Screen({super.key});

  @override
  State<Ask5Screen> createState() => _Ask5ScreenState();
}

class _Ask5ScreenState extends State<Ask5Screen> {
  final List<AllergyOption> _selectedAllergies = [];
  List<AllergyOption> _availableAllergies = [];
  AllergyOption? _dropdownValue;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadAllergyOptions);
  }

  Future<void> _loadAllergyOptions() async {
    final provider = context.read<ProfileSetupProvider>();

    setState(() {
      _selectedAllergies
        ..clear()
        ..addAll(provider.allergies);
      _isLoading = true;
      _loadError = null;
    });

    try {
      final allergies = await provider.fetchAllergyOptions();
      if (!mounted) return;

      setState(() {
        _availableAllergies = allergies;
        _dropdownValue = allergies.firstWhere(
          (item) =>
              !_selectedAllergies.any((selected) => selected.id == item.id),
          orElse: () => allergies.isNotEmpty ? allergies.first : _emptyOption,
        );
        if (_dropdownValue == _emptyOption) {
          _dropdownValue = null;
        }
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Failed to load allergy list';
        _isLoading = false;
      });
    }
  }

  static const AllergyOption _emptyOption = AllergyOption(id: -1, name: '');

  void _addSelectedAllergy() {
    final allergy = _dropdownValue;
    if (allergy == null) return;
    if (_selectedAllergies.any((item) => item.id == allergy.id)) return;

    setState(() {
      _selectedAllergies.add(allergy);
      _dropdownValue = _availableAllergies.cast<AllergyOption?>().firstWhere(
        (item) =>
            item != null &&
            !_selectedAllergies.any((selected) => selected.id == item.id),
        orElse: () => null,
      );
    });
  }

  void _removeSelectedAllergy(AllergyOption allergy) {
    setState(() {
      _selectedAllergies.removeWhere((item) => item.id == allergy.id);
      _dropdownValue ??= allergy;
    });
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
                        MaterialPageRoute(builder: (_) => const Ask4Screen()),
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
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFD84E),
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    size: 80,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Do you have any allergy?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  '(skip if none)',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_loadError != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _loadError!,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _loadAllergyOptions,
                              child: const Text('Retry'),
                            ),
                          ],
                        )
                      else ...[
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<AllergyOption>(
                                value: _dropdownValue,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  hintText: 'Select an allergy',
                                  border: InputBorder.none,
                                  isDense: true,
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
                                        child: Text(allergy.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _dropdownValue = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _addSelectedAllergy,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add'),
                            ),
                          ],
                        ),
                        if (_availableAllergies.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'No allergies available from the database.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                      ],
                      const SizedBox(height: 8),
                      if (_selectedAllergies.isNotEmpty)
                        Column(
                          children: _selectedAllergies
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF7E9),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.black12),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.type == null || item.type!.isEmpty
                                                ? item.name
                                                : '${item.name} (${item.type})',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.redAccent,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              _removeSelectedAllergy(item),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const Ask4Screen()),
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
                      onPressed: () {
                        context.read<ProfileSetupProvider>().setAllergies(
                          List<AllergyOption>.from(_selectedAllergies),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const Ask6Screen()),
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
