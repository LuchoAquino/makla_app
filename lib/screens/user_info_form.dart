import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:makla_app/providers/db_user_provider.dart';
import 'package:makla_app/screens/main_screen.dart';
import 'package:makla_app/utils/app_theme.dart';
import 'package:provider/provider.dart';

class UserInfoForm extends StatefulWidget {
  final List<CameraDescription> cameras;
  const UserInfoForm({super.key, required this.cameras});

  @override
  State<UserInfoForm> createState() => _UserInfoFormState();
}

class _UserInfoFormState extends State<UserInfoForm> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Custom Inputs
  final TextEditingController _customPurposeController =
      TextEditingController();
  final TextEditingController _customRestrictionController =
      TextEditingController();
  final TextEditingController _customDiseaseController =
      TextEditingController();
  final TextEditingController _customGoalController = TextEditingController();

  // Form data
  DateTime? _selectedDateBirthday;
  String? _selectedGender;
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];
  final List<String> _purposeOptions = [
    'Fitness Tracking',
    'Healthy Lifestyle',
    'Weight Management',
    'Diet Monitoring',
    'Medical Condition',
  ];
  final List<String> _selectedPurposes = [];

  // State for Dietary Page
  final List<String> _restrictionsOptions = [
    'Peanuts',
    'Dairy',
    'Gluten',
    'Shellfish',
    'Pork',
    'Meat',
  ];
  final List<String> _selectedRestrictions = [];
  final List<String> _diseaseOptions = [
    'Diabetes',
    'Hypertension',
    'Celiac Disease',
    'High Cholesterol',
  ];
  final List<String> _selectedDiseases = [];

  // State for Goals and Frequency Page
  final List<String> _goalOptions = [
    'Lose Weight',
    'Maintain Weight',
    'Gain Weight',
    'Build Muscle',
  ];
  String? _selectedGoal;

  final List<String> _frequencyOptions = [
    'Weekly',
    'Bi-weekly',
    'Monthly',
    'Every 3 Months',
    'Every 6 Months',
  ];

  String? _selectedFrequency;

  @override
  void dispose() {
    // "Delete" all the controllers to free up resources
    _pageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _customGoalController.dispose();
    _customPurposeController.dispose();
    _customRestrictionController.dispose();
    _customDiseaseController.dispose();

    // IMPORTANTE: Siempre llamar a super.dispose() al final
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_currentPage + 1} of 4'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: (_currentPage + 1) / 4),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildGeneralInfoPage(),
                _buildPurposePage(),
                _buildDietaryPage(),
                _buildGoalsPage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.primary,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Row(
            children: [
              // BACK button
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _currentPage > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        }
                      : null, // disabled on first page
                  child: Text('Back', style: AppTextStyles.button),
                ),
              ),

              const SizedBox(width: 16), // spacing between buttons
              // NEXT / FINISH button
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    if (_currentPage < 3) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    } else {
                      try {
                        double height = double.parse(
                          _heightController.text.trim(),
                        );
                        double weight = double.parse(
                          _weightController.text.trim(),
                        );

                        Map<String, dynamic> formData = {
                          'height': height,
                          'weight': weight,
                          'gender': _selectedGender,
                          'dateOfBirth': _selectedDateBirthday,
                          'purposes': _selectedPurposes,
                          'restrictions': _selectedRestrictions,
                          'diseases': _selectedDiseases,
                          'goal': _selectedGoal,
                          'checkInFrequency': _selectedFrequency, // NUEVO
                        };
                        await Provider.of<DbUserProvider>(
                          context,
                          listen: false,
                        ).updateUserData(formData);

                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) =>
                                  MainScreen(cameras: widget.cameras),
                            ),
                          );
                        }
                      } catch (e) {
                        debugPrint("Error completing form: $e");
                      }
                    }
                  },
                  child: Text(
                    _currentPage < 3 ? 'Next' : 'Finish',
                    style: AppTextStyles.button,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to add custom options
  Widget _buildAddOptionField({
    required String hintText,
    required TextEditingController controller,
    required Function(String) onAdd,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              onAdd(controller.text.trim());
              controller.clear();
            }
          },
          icon: const Icon(
            Icons.add_circle,
            color: AppColors.secondary,
            size: 30,
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('General Information', style: AppTextStyles.subtitle),
          const SizedBox(height: 24),
          // Date of Birth
          Text('Date of Birth', style: AppTextStyles.body),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDateBirthday ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null && picked != _selectedDateBirthday) {
                setState(() {
                  _selectedDateBirthday = picked;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDateBirthday == null
                        ? 'Select your birth date'
                        : "${_selectedDateBirthday!.toLocal()}".split(' ')[0],
                  ),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Gender
          Text('Gender', style: AppTextStyles.body),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedGender,
            hint: const Text('Select your gender'),
            items: _genders.map((String gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedGender = newValue;
              });
            },
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          // Height
          Text('Height (cm)', style: AppTextStyles.body),
          const SizedBox(height: 8),
          TextFormField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter your height',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          // Weight
          Text('Weight (kg)', style: AppTextStyles.body),
          const SizedBox(height: 8),
          TextFormField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter your weight',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurposePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Purpose', style: AppTextStyles.subtitle),
          const SizedBox(height: 16),
          Text('Select all that apply.', style: AppTextStyles.body),
          const SizedBox(height: 16),

          // 1.- Chips for predefined purposes
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              // Show predefined options
              ..._purposeOptions.map((purpose) {
                return FilterChip(
                  label: Text(purpose, style: AppTextStyles.chip),
                  selected: _selectedPurposes.contains(purpose),
                  onSelected: (bool selected) {
                    setState(() {
                      selected
                          ? _selectedPurposes.add(purpose)
                          : _selectedPurposes.remove(purpose);
                    });
                  },
                  backgroundColor: AppColors.lightGrey,
                  selectedColor: AppColors.accent.withOpacity(0.5),
                  checkmarkColor: AppColors.secondary,
                );
              }),
              // Show the CUSTOM ones added by the user
              ..._selectedPurposes
                  .where((p) => !_purposeOptions.contains(p))
                  .map((custom) {
                    return Chip(
                      label: Text(custom, style: AppTextStyles.chip),
                      backgroundColor: AppColors.accent.withOpacity(0.5),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _selectedPurposes.remove(custom);
                        });
                      },
                    );
                  }),
            ],
          ),
          const SizedBox(height: 20),
          // 2. Input to add custom purpose
          _buildAddOptionField(
            hintText: "Add custom purpose...",
            controller: _customPurposeController,
            onAdd: (val) {
              setState(() {
                if (!_selectedPurposes.contains(val)) {
                  _selectedPurposes.add(val);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dietary Information', style: AppTextStyles.subtitle),
          const SizedBox(height: 24),

          // Restrictions or Allergies
          Text('Restrictions or Allergies', style: AppTextStyles.body),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              ..._restrictionsOptions.map((item) {
                return FilterChip(
                  label: Text(item, style: AppTextStyles.chip),
                  selected: _selectedRestrictions.contains(item),
                  onSelected: (selected) {
                    setState(() {
                      selected
                          ? _selectedRestrictions.add(item)
                          : _selectedRestrictions.remove(item);
                    });
                  },
                  backgroundColor: AppColors.lightGrey,
                  selectedColor: AppColors.accent.withOpacity(0.5),
                );
              }),
              // Custom Added Chips
              ..._selectedRestrictions
                  .where((r) => !_restrictionsOptions.contains(r))
                  .map((custom) {
                    return Chip(
                      label: Text(custom, style: AppTextStyles.chip),
                      backgroundColor: AppColors.accent.withOpacity(0.5),
                      onDeleted: () =>
                          setState(() => _selectedRestrictions.remove(custom)),
                    );
                  }),
            ],
          ),
          const SizedBox(height: 10),
          _buildAddOptionField(
            hintText: "Add allergy/restriction...",
            controller: _customRestrictionController,
            onAdd: (val) => setState(() {
              if (!_selectedRestrictions.contains(val))
                _selectedRestrictions.add(val);
            }),
          ),

          const SizedBox(height: 24),

          // Diseases
          Text('Known Diseases', style: AppTextStyles.body),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              ..._diseaseOptions.map((item) {
                return FilterChip(
                  label: Text(item, style: AppTextStyles.chip),
                  selected: _selectedDiseases.contains(item),
                  onSelected: (selected) {
                    setState(() {
                      selected
                          ? _selectedDiseases.add(item)
                          : _selectedDiseases.remove(item);
                    });
                  },
                  backgroundColor: AppColors.lightGrey,
                  selectedColor: AppColors.accent.withOpacity(0.5),
                );
              }),
              // Custom Added Chips
              ..._selectedDiseases
                  .where((d) => !_diseaseOptions.contains(d))
                  .map((custom) {
                    return Chip(
                      label: Text(custom, style: AppTextStyles.chip),
                      backgroundColor: AppColors.accent.withOpacity(0.5),
                      onDeleted: () =>
                          setState(() => _selectedDiseases.remove(custom)),
                    );
                  }),
            ],
          ),
          const SizedBox(height: 10),
          _buildAddOptionField(
            hintText: "Add disease...",
            controller: _customDiseaseController,
            onAdd: (val) => setState(() {
              if (!_selectedDiseases.contains(val)) _selectedDiseases.add(val);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Goal (Single Selection)
          Text('Health Goal', style: AppTextStyles.subtitle),
          const SizedBox(height: 10),
          Text('Select your primary goal.', style: AppTextStyles.body),
          const SizedBox(height: 16),
          // A. Default Chips
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _goalOptions.map((goal) {
              return ChoiceChip(
                label: Text(goal, style: AppTextStyles.chip),
                // It is selected if it matches the _selectedGoal variable
                selected: _selectedGoal == goal,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _selectedGoal = goal;
                      _customGoalController
                          .clear(); // Clear the text if a chip is selected
                    }
                  });
                },
                backgroundColor: AppColors.lightGrey,
                selectedColor: AppColors.accent.withOpacity(0.5),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // B. Input for Custom Goal ("Other")
          TextField(
            controller: _customGoalController,
            decoration: InputDecoration(
              hintText: "Or type your own goal",
              prefixIcon: const Icon(
                Icons.edit_note,
                color: AppColors.secondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              filled: true,
              fillColor: AppColors.lightGrey.withOpacity(0.3),
            ),
            onChanged: (value) {
              setState(() {
                // If typing, the goal is what is being typed
                _selectedGoal = value;
                // By changing _selectedGoal to a value not in the _goalOptions list,
                // the ChoiceChips above are automatically deselected.
              });
            },
          ),

          const SizedBox(height: 24),

          // 2. Frequency (Single Selection)
          Text('Check-in Frequency', style: AppTextStyles.subtitle),
          const SizedBox(height: 10),
          Text(
            'How often should we review your goal?',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFrequency,
                isExpanded: true,
                items: _frequencyOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedFrequency = newValue!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
