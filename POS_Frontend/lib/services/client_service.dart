import '../core/constants/api_constants.dart';
import '../models/client.dart';
import 'api_service.dart';

/// Appels CRUD vers l'API Django pour Client.
class ClientService {
  final ApiService _api = ApiService();

  Future<List<Client>> getAll() async {
    final data = await _api.get(ApiConstants.clients);
    return (data as List).map((json) => Client.fromJson(json)).toList();
  }

  Future<Client> getById(int id) async {
    final data = await _api.get('${ApiConstants.clients}$id/');
    return Client.fromJson(data);
  }

  Future<Client> create(Client item) async {
    final data = await _api.post(ApiConstants.clients, item.toJson());
    return Client.fromJson(data);
  }

  Future<Client> update(int id, Client item) async {
    final data = await _api.put('${ApiConstants.clients}$id/', item.toJson());
    return Client.fromJson(data);
  }

  Future<void> delete(int id) async {
    await _api.delete('${ApiConstants.clients}$id/');
  }
}
