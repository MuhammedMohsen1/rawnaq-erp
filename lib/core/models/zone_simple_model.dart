class ZoneSimpleModel {
  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final int? deliveryMenCount;

  const ZoneSimpleModel({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    this.deliveryMenCount,
  });

  factory ZoneSimpleModel.fromJson(Map<String, dynamic> json) {
    return ZoneSimpleModel(
      id: json['id'] as String,
      name: json['zoneName'] as String, // API returns 'zoneName' not 'name'
      description: json['description'] as String?,
      isActive: json['isActive'] as bool,
      deliveryMenCount: json['deliveryMenCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
      'deliveryMenCount': deliveryMenCount,
    };
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ZoneSimpleModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
