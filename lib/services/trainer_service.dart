import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

/// Service layer for Trainer API calls.
///
/// Every method takes plain Dart params, calls the backend via Dio,
/// and returns a clean Dart model.
/// Methods will be added per-screen during §5 integration.
class TrainerService {
  final Dio dio;
  TrainerService(this.dio);

  // ── §5 methods will be added here ──
  // e.g. Future<TrainerProfile> getMyProfile() async { ... }
  // e.g. Future<void> submitCertification({...}) async { ... }
}

/// Riverpod provider for [TrainerService].
final trainerServiceProvider = Provider<TrainerService>((ref) {
  return TrainerService(ref.read(dioProvider));
});
