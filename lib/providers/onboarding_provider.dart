import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/onboarding_state.dart';
import '../services/api_client.dart';

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;
  OnboardingNotifier(this._ref) : super(const OnboardingState());

  void updateGoal(String goal) {
    state = state.copyWith(goal: goal);
  }

  void updatePersonalDetails({
    String? gender,
    int? age,
    int? height,
    int? weight,
  }) {
    state = state.copyWith(
      gender: gender,
      age: age,
      height: height,
      weight: weight,
    );
  }

  void updateLifestyle({
    String? activityLevel,
    String? dietPreference,
    String? experience,
    String? sleepSchedule,
  }) {
    state = state.copyWith(
      activityLevel: activityLevel,
      dietPreference: dietPreference,
      experience: experience,
      sleepSchedule: sleepSchedule,
    );
  }

  Future<void> completeOnboarding() async {
    final dio = _ref.read(dioProvider);
    try {
      // 1. Save profile via PATCH
      await dio.patch('/members/me/profile', data: state.toBackendJson());
      // 2. Complete onboarding via POST
      await dio.post('/members/me/complete-onboarding');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Onboarding completion failed');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  void reset() {
    state = const OnboardingState();
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(ref);
});
