import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/onboarding_state.dart';
import '../services/api_client.dart';

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;
  OnboardingNotifier(this._ref) : super(const OnboardingState());

  Timer? _persistDebounce;

  void updateGoal(String goal) {
    state = state.copyWith(goal: goal);
    _persistProgress();
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
    _persistProgress();
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
    _persistProgress();
  }

  void updateEquipmentAndBudget({
    String? equipmentAccess,
    String? budgetBand,
  }) {
    state = state.copyWith(
      equipmentAccess: equipmentAccess,
      budgetBand: budgetBand,
    );
    _persistProgress();
  }

  /// Best-effort per-step save so a killed app doesn't lose everything
  /// collected before the final screen. Never surfaces errors to the wizard
  /// UI — the authoritative save/validation still happens in
  /// [completeOnboarding]; this is purely a resilience measure.
  ///
  /// Debounced so continuous input (slider drags, chip taps) collapses into
  /// a single PATCH after the user pauses, instead of one network call per
  /// value change.
  void _persistProgress() {
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 600), () {
      final dio = _ref.read(dioProvider);
      dio.patch('/members/me/profile', data: state.toBackendJson()).catchError(
        (Object e) {
          if (kDebugMode) {
            debugPrint('⚠️ [Onboarding] Progress save failed (non-fatal): $e');
          }
          return Response(requestOptions: RequestOptions(path: '/members/me/profile'));
        },
      );
    });
  }

  /// Rehydrates local wizard state from the backend — used on session
  /// restore/login so a user resuming onboarding on a new device (or after
  /// the app was killed) doesn't have to redo steps already saved.
  Future<void> hydrateFromBackend() async {
    try {
      final dio = _ref.read(dioProvider);
      final res = await dio.get('/members/me/profile');
      final data = res.data as Map<String, dynamic>?;
      if (data == null) return;

      state = state.copyWith(
        goal: _goalFromBackend(data['goal'] as String?),
        gender: data['sex'] == 'FEMALE' ? 'Female' : (data['sex'] == 'MALE' ? 'Male' : null),
        height: (data['heightCm'] as num?)?.round(),
        weight: (data['weightKg'] as num?)?.round(),
        experience: _experienceFromBackend(data['experienceLevel'] as String?),
        dietPreference: _dietFromBackend(data['dietaryPreference'] as String?),
        equipmentAccess: _equipmentFromBackend(data['equipmentAccess'] as String?),
        budgetBand: _budgetFromBackend(data['budgetBand'] as String?),
      );
    } catch (_) {
      // No profile yet, or offline — the wizard just starts fresh.
    }
  }

  static String? _goalFromBackend(String? v) => switch (v) {
        'FAT_LOSS' => 'Lose Weight',
        'MUSCLE_GAIN' => 'Build Muscle',
        'GENERAL_FITNESS' => 'Stay Fit',
        _ => null,
      };

  static String? _experienceFromBackend(String? v) => switch (v) {
        'INTERMEDIATE' => 'Intermediate',
        'ADVANCED' => 'Advanced',
        'BEGINNER' => 'Beginner',
        _ => null,
      };

  static String? _dietFromBackend(String? v) => switch (v) {
        'VEG' => 'Vegetarian',
        'VEGAN' => 'Vegan',
        _ => null,
      };

  static String? _equipmentFromBackend(String? v) => switch (v) {
        'HOME_EQUIPMENT' => 'Home Equipment',
        'NO_EQUIPMENT' => 'No Equipment',
        'FULL_GYM' => 'Full Gym',
        _ => null,
      };

  static String? _budgetFromBackend(String? v) => switch (v) {
        'LOW' => 'Low',
        'HIGH' => 'High',
        'MEDIUM' => 'Medium',
        _ => null,
      };

  Future<void> completeOnboarding() async {
    // Cancel any pending debounced progress save — the authoritative PATCH
    // below supersedes it, and a stale one must not land after completion.
    _persistDebounce?.cancel();
    _persistDebounce = null;
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
    _persistDebounce?.cancel();
    _persistDebounce = null;
    state = const OnboardingState();
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(ref);
});
