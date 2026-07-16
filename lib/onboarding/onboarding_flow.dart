import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/goal_selection_screen.dart';
import 'screens/personal_details_screen.dart';
import 'screens/lifestyle_screen.dart';
import 'screens/final_screen.dart';
import 'widgets/progress_indicator.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Shared onboarding state
  String? _selectedGoal;
  Map<String, dynamic> _personalDetails = {
    'gender': 'Male',
    'age': 25,
    'height': 170,
    'weight': 70,
  };
  Map<String, String?> _lifestyleData = {
    'activityLevel': null,
    'dietPreference': null,
    'experience': null,
    'sleepSchedule': null,
  };

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _goToPage(_currentPage + 1);
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      _goToPage(_currentPage - 1);
    }
  }

  Map<String, dynamic> get _allUserData => {
        'goal': _selectedGoal,
        ..._personalDetails,
        ..._lifestyleData,
      };

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // Pages
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            children: [
              // Screen 1: Welcome
              WelcomeScreen(
                onGetStarted: () => _goToPage(1),
              ),

              // Screen 2: Goal Selection
              GoalSelectionScreen(
                initialGoal: _selectedGoal,
                onGoalSelected: (goal) {
                  setState(() => _selectedGoal = goal);
                },
                onContinue: _nextPage,
              ),

              // Screen 3: Personal Details
              PersonalDetailsScreen(
                initialData: _personalDetails,
                onDataChanged: (data) {
                  setState(() => _personalDetails = data);
                },
                onContinue: _nextPage,
              ),

              // Screen 4: Lifestyle
              LifestyleScreen(
                initialData: _lifestyleData,
                onDataChanged: (data) {
                  setState(() => _lifestyleData = data);
                },
                onContinue: _nextPage,
              ),

              // Screen 5: Final
              FinalScreen(
                userData: _allUserData,
                onGeneratePlan: () {
                  Navigator.of(context).pushReplacementNamed('/billing-plans');
                },
              ),
            ],
          ),

          // Progress bar + back button (visible from screen 2 onward)
          if (_currentPage > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _previousPage,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.bgSecondary,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.glassBorder,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OnboardingProgressIndicator(
                              currentStep: _currentPage - 1,
                              totalSteps: 4,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Page counter
                          Text(
                            '$_currentPage/4',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
