import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coaching_assignment.dart';
import 'api_client.dart';
import 'api_data.dart';

/// Online coaching assignment API.
class CoachingService {
  final Dio dio;
  CoachingService(this.dio);

  Future<CoachingAssignment?> getMyCoaching() async {
    final res = await dio.get('/members/me/coaching');
    if (res.data == null) return null;
    final map = asMap(res.data);
    if (map.isEmpty || map['id'] == null) return null;
    return CoachingAssignment.fromJson(map);
  }

  Future<CoachingAssignment> requestSwitch({String? reason}) async {
    final res = await dio.post('/members/me/coaching/request-switch', data: {
      if (reason != null) 'reason': reason,
    });
    return CoachingAssignment.fromJson(asMap(res.data));
  }
}

final coachingServiceProvider = Provider<CoachingService>((ref) {
  return CoachingService(ref.watch(dioProvider));
});
