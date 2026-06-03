import '../../../../core/constants/endpoints.dart';
import '../../../../core/network/api_client.dart';

class RecentlyDeletedApiDataSource {
  final ApiClient _apiClient;

  RecentlyDeletedApiDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<RecentlyDeletedItem>> getItems(String pin) async {
    final response = await _apiClient.get(
      ApiEndpoints.recentlyDeleted,
      queryParameters: {'pin': pin},
    );
    final responseData = response.data as Map<String, dynamic>;
    final itemsJson = responseData['data'] as List<dynamic>;

    return itemsJson
        .map(
          (json) => RecentlyDeletedItem.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> restore({
    required String id,
    required String type,
    required String pin,
  }) async {
    await _apiClient.patch(
      ApiEndpoints.restoreRecentlyDeleted,
      data: {'id': id, 'type': type, 'pin': pin},
    );
  }
}

class RecentlyDeletedItem {
  final String id;
  final String type;
  final String title;
  final String? subtitle;
  final DateTime deletedAt;
  final bool canRestore;

  const RecentlyDeletedItem({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    required this.deletedAt,
    required this.canRestore,
  });

  factory RecentlyDeletedItem.fromJson(Map<String, dynamic> json) {
    return RecentlyDeletedItem(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      deletedAt: DateTime.parse(json['deletedAt'] as String),
      canRestore: json['canRestore'] as bool? ?? false,
    );
  }
}
