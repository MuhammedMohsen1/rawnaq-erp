import '../../../../core/constants/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/domain/entities/user.dart';

class AdminUsersApiDataSource {
  final ApiClient _apiClient;

  AdminUsersApiDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<User>> getUsers() async {
    final response = await _apiClient.get(ApiEndpoints.users);
    final responseData = response.data as Map<String, dynamic>;
    final usersJson = responseData['data'] as List<dynamic>;

    return usersJson
        .map((json) => User.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<User> getUserById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.userById(id));
    final responseData = response.data as Map<String, dynamic>;
    return User.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  Future<User> createUser(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiEndpoints.users, data: data);
    final responseData = response.data as Map<String, dynamic>;
    return User.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  Future<User> updateUser(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.patch(
      ApiEndpoints.userById(id),
      data: data,
    );
    final responseData = response.data as Map<String, dynamic>;
    return User.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  Future<void> deleteUser(String id) async {
    await _apiClient.delete(ApiEndpoints.userById(id));
  }
}
