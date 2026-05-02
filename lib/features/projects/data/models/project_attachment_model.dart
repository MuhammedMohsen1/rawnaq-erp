import '../../domain/entities/project_attachment_entity.dart';

class ProjectAttachmentModel extends ProjectAttachmentEntity {
  const ProjectAttachmentModel({
    required super.id,
    required super.projectId,
    required super.originalName,
    required super.fileName,
    required super.mimeType,
    required super.size,
    required super.url,
    required super.uploadedById,
    super.uploadedByName,
    required super.createdAt,
  });

  factory ProjectAttachmentModel.fromJson(Map<String, dynamic> json) {
    return ProjectAttachmentModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      originalName: json['originalName'] as String,
      fileName: json['fileName'] as String,
      mimeType: json['mimeType'] as String,
      size: (json['size'] as num).toInt(),
      url: json['url'] as String,
      uploadedById: json['uploadedById'] as String,
      uploadedByName: json['uploadedByName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  ProjectAttachmentEntity toEntity() {
    return ProjectAttachmentEntity(
      id: id,
      projectId: projectId,
      originalName: originalName,
      fileName: fileName,
      mimeType: mimeType,
      size: size,
      url: url,
      uploadedById: uploadedById,
      uploadedByName: uploadedByName,
      createdAt: createdAt,
    );
  }
}
