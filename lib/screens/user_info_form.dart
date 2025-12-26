import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:makla_app/screens/main_screen.dart';
import 'package:makla_app/utils/app_theme.dart';

class UserInfoForm extends StatefulWidget {
  final List<CameraDescription> cameras;
  const UserInfoForm({super.key, required this.cameras});

  @override
  State<UserInfoForm> createState() => _UserInfoFormState();
}

class _UserInfoFormState extends State<UserInfoForm> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form data
  DateTime? _selectedDate;
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
    'None',
    'Peanuts',
    'Dairy',
    'Gluten',
    'Shellfish',
    'Pork',
    'Meat',
  ];
  final List<String> _selectedRestrictions = [];
  final List<String> _diseaseOptions = [
    'None',
    'Diabetes',
    'Hypertension',
    'Celiac Disease',
    'High Cholesterol',
  ];
  final List<String> _selectedDiseases = [];

  // State for Goals Page
  final List<String> _goalOptions = [
    'Lose Weight',
    'Maintain Weight',
    'Gain Weight',
    'Build Muscle',
  ];
  String? _selectedGoal;

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
                  onPressed: () {
                    if (_currentPage < 3) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>
                              MainScreen(cameras: widget.cameras),
                        ),
                      );
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
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
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
                    _selectedDate == null
                        ? 'Select your birth date'
                        : "${_selectedDate!.toLocal()}".split(' ')[0],
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
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _purposeOptions.map((purpose) {
              return FilterChip(
                label: Text(purpose, style: AppTextStyles.chip),
                selected: _selectedPurposes.contains(purpose),
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _selectedPurposes.add(purpose);
                    } else {
                      _selectedPurposes.remove(purpose);
                    }
                  });
                },
                backgroundColor: AppColors.lightGrey,
                selectedColor: AppColors.accent.withOpacity(0.5),
                checkmarkColor: AppColors.secondary,
              );
            }).toList(),
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
            children: _restrictionsOptions.map((item) {
              return FilterChip(
                label: Text(item, style: AppTextStyles.chip),
                selected: _selectedRestrictions.contains(item),
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _selectedRestrictions.add(item);
                    } else {
                      _selectedRestrictions.remove(item);
                    }
                  });
                },
                backgroundColor: AppColors.lightGrey,
                selectedColor: AppColors.accent.withOpacity(0.5),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Diseases
          Text('Known Diseases', style: AppTextStyles.body),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _diseaseOptions.map((item) {
              return FilterChip(
                label: Text(item, style: AppTextStyles.chip),
                selected: _selectedDiseases.contains(item),
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _selectedDiseases.add(item);
                    } else {
                      _selectedDiseases.remove(item);
                    }
                  });
                },
                backgroundColor: AppColors.lightGrey,
                selectedColor: AppColors.accent.withOpacity(0.5),
              );
            }).toList(),
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
          Text('Health Goal', style: AppTextStyles.subtitle),
          const SizedBox(height: 16),
          Text('Select your primary health goal.', style: AppTextStyles.body),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _goalOptions.map((goal) {
              return ChoiceChip(
                label: Text(goal, style: AppTextStyles.chip),
                selected: _selectedGoal == goal,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _selectedGoal = goal;
                    }
                  });
                },
                backgroundColor: AppColors.lightGrey,
                selectedColor: AppColors.accent.withOpacity(0.5),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
