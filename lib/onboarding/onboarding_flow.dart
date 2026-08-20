import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/goal_selection_screen.dart';
import 'screens/personal_details_screen.dart';
import 'screens/lifestyle_screen.dart';
import 'screens/final_screen.dart';
import 'widgets/progress_indicator.dart';
import '../providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';
import '../auth/screens/register_screen.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  final int initialPage;
  const OnboardingFlow({super.key, this.initialPage = 0});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  late final PageController _pageController;
  late int _currentPage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _goToPage(_currentPage + 1);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);

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

              // Screen 2: Register Screen (Before Onboarding)
              RegisterScreen(
                isEmbeddedInOnboarding: true,
                onRegisterSuccess: () {
                  _nextPage();
                },
              ),

              // Screen 3: Goal Selection (Step 1)
              GoalSelectionScreen(
                initialGoal: onboardingState.goal,
                onGoalSelected: (goal) {
                  ref.read(onboardingProvider.notifier).updateGoal(goal);
                },
                onContinue: _nextPage,
              ),

              // Screen 4: Personal Details (Step 2)
              PersonalDetailsScreen(
                initialData: {
                  'gender': onboardingState.gender,
                  'age': onboardingState.age,
                  'height': onboardingState.height,
                  'weight': onboardingState.weight,
                },
                onDataChanged: (data) {
                  ref.read(onboardingProvider.notifier).updatePersonalDetails(
                    gender: data['gender'] as String?,
                    age: data['age'] as int?,
                    height: data['height'] as int?,
                    weight: data['weight'] as int?,
                  );
                },
                onContinue: _nextPage,
              ),

              // Screen 5: Lifestyle (Step 3)
              LifestyleScreen(
                initialData: {
                  'activityLevel': onboardingState.activityLevel,
                  'dietPreference': onboardingState.dietPreference,
                  'experience': onboardingState.experience,
                  'sleepSchedule': onboardingState.sleepSchedule,
                  'equipmentAccess': onboardingState.equipmentAccess,
                  'budgetBand': onboardingState.budgetBand,
                },
                onDataChanged: (data) {
                  ref.read(onboardingProvider.notifier).updateLifestyle(
                    activityLevel: data['activityLevel'],
                    dietPreference: data['dietPreference'],
                    experience: data['experience'],
                    sleepSchedule: data['sleepSchedule'],
                  );
                  ref.read(onboardingProvider.notifier).updateEquipmentAndBudget(
                        equipmentAccess: data['equipmentAccess'],
                        budgetBand: data['budgetBand'],
                      );
                },
                onContinue: _nextPage,
              ),

              // Screen 6: Final (Plan generated)
              FinalScreen(
                onGeneratePlan: () async {
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  setState(() => _isLoading = true);
                  try {
                    await ref.read(onboardingProvider.notifier).completeOnboarding();
                    await ref.read(authProvider.notifier).refreshUser();
                    if (mounted) {
                      navigator.pushReplacementNamed('/billing-plans');
                    }
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(e.toString().replaceAll('Exception: ', '')),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  } finally {
                    if (mounted) {
                      setState(() => _isLoading = false);
                    }
                  }
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
                          if (_currentPage >= 2 && _currentPage <= 4) ...[
                            Expanded(
                              child: OnboardingProgressIndicator(
                                currentStep: _currentPage - 2,
                                totalSteps: 3,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Page counter
                            Text(
                              '${_currentPage - 1}/3',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ] else
                            const Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Glassmorphic loading overlay
          if (_isLoading)
            Positioned.fill(
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.accentBlue,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Generating your fitness plan...',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This may take up to 60 seconds on first launch.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
