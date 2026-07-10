import '../core/constants/api_constants.dart';
import '../models/dashboard_summary.dart';
import 'api_service.dart';

/// Tableau de bord — `GET /dashboard/summary/`.
class DashboardService {
  final ApiService _api = ApiService();

  Future<DashboardSummary> getSummary() async {
    final data = await _api.get(ApiConstants.dashboard);
    return DashboardSummary.fromJson(data as Map<String, dynamic>);
  }
}
