import 'package:equatable/equatable.dart';

class ProjectAttachmentEntity extends Equatable {
  final String id;
  final String projectId;
  final String originalName;
  final String fileName;
  final String mimeType;
  final int size;
  final String url;
  final String uploadedById;
  final String? uploadedByName;
  final DateTime createdAt;

  const ProjectAttachmentEntity({
    required this.id,
    required this.projectId,
    required this.originalName,
    required this.fileName,
    required this.mimeType,
    required this.size,
    required this.url,
    required this.uploadedById,
    this.uploadedByName,
    required this.createdAt,
  });

  bool get isImage => mimeType.startsWith('image/');

  bool get isPdf => mimeType == 'application/pdf';

  @override
  List<Object?> get props => [
    id,
    projectId,
    originalName,
    fileName,
    mimeType,
    size,
    url,
    uploadedById,
    uploadedByName,
    createdAt,
  ];
}
