import '../../domain/entities/project_entity.dart';
import '../../domain/entities/team_member_entity.dart';
import '../../domain/enums/project_status.dart';
import '../../domain/repositories/projects_repository.dart';

/// Mock data source for projects during development
class MockProjectsDataSource {
  // Singleton instance
  static final MockProjectsDataSource _instance = MockProjectsDataSource._internal();
  factory MockProjectsDataSource() => _instance;
  MockProjectsDataSource._internal();

  // Mock team members
  final List<TeamMemberEntity> _teamMembers = [
    const TeamMemberEntity(
      id: 'tm-1',
      name: 'أحمد محمد',
      role: 'مدير مشروع',
      email: 'ahmed@rawnaq.com',
      phone: '+966501234567',
    ),
    const TeamMemberEntity(
      id: 'tm-2',
      name: 'سارة علي',
      role: 'مصممة داخلية',
      email: 'sara@rawnaq.com',
      phone: '+966507654321',
    ),
    const TeamMemberEntity(
      id: 'tm-3',
      name: 'محمد خالد',
      role: 'مهندس تنفيذ',
      email: 'mohammed@rawnaq.com',
      phone: '+966509876543',
    ),
    const TeamMemberEntity(
      id: 'tm-4',
      name: 'نورة عبدالله',
      role: 'مصممة داخلية',
      email: 'noura@rawnaq.com',
      phone: '+966502345678',
    ),
    const TeamMemberEntity(
      id: 'tm-5',
      name: 'عبدالرحمن سالم',
      role: 'مشرف موقع',
      email: 'abdulrahman@rawnaq.com',
      phone: '+966503456789',
    ),
  ];

  // Mock projects with interior design context
  late final List<ProjectEntity> _projects = [
    ProjectEntity(
      id: 'proj-1',
      name: 'إعادة تصميم الموقع الإلكتروني',
      status: ProjectStatus.active,
      progress: 75,
      startDate: DateTime(2024, 6, 1),
      endDate: DateTime(2024, 8, 30),
      managerId: 'tm-1',
      manager: _teamMembers[0],
      teamMemberIds: ['tm-1', 'tm-2', 'tm-3'],
      teamMembers: [_teamMembers[0], _teamMembers[1], _teamMembers[2]],
      description: 'إعادة تصميم شاملة للموقع الإلكتروني مع تحسين تجربة المستخدم',
      createdAt: DateTime(2024, 5, 15),
      updatedAt: DateTime.now(),
    ),
    ProjectEntity(
      id: 'proj-2',
      name: 'تطوير تطبيق الجوال',
      status: ProjectStatus.completed,
      progress: 100,
      startDate: DateTime(2024, 1, 15),
      endDate: DateTime(2024, 5, 15),
      managerId: 'tm-2',
      manager: _teamMembers[1],
      teamMemberIds: ['tm-2', 'tm-4'],
      teamMembers: [_teamMembers[1], _teamMembers[3]],
      description: 'تطوير تطبيق جوال متكامل لإدارة المشاريع',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 5, 15),
    ),
    ProjectEntity(
      id: 'proj-3',
      name: 'حملة التسويق الرقمي Q3',
      status: ProjectStatus.delayed,
      progress: 40,
      startDate: DateTime(2024, 7, 1),
      endDate: DateTime(2024, 9, 15),
      managerId: 'tm-1',
      manager: _teamMembers[0],
      teamMemberIds: ['tm-1', 'tm-3', 'tm-5'],
      teamMembers: [_teamMembers[0], _teamMembers[2], _teamMembers[4]],
      description: 'حملة تسويقية شاملة للربع الثالث من العام',
      createdAt: DateTime(2024, 6, 15),
      updatedAt: DateTime.now(),
    ),
    ProjectEntity(
      id: 'proj-4',
      name: 'ترقية البنية التحتية للخوادم',
      status: ProjectStatus.active,
      progress: 20,
      startDate: DateTime(2024, 7, 10),
      endDate: DateTime(2024, 10, 31),
      managerId: 'tm-3',
      manager: _teamMembers[2],
      teamMemberIds: ['tm-3', 'tm-5'],
      teamMembers: [_teamMembers[2], _teamMembers[4]],
      description: 'ترقية شاملة للبنية التحتية وتحسين الأداء',
      createdAt: DateTime(2024, 7, 1),
      updatedAt: DateTime.now(),
    ),
    ProjectEntity(
      id: 'proj-5',
      name: 'تصميم فيلا الرياض',
      status: ProjectStatus.active,
      progress: 60,
      startDate: DateTime(2024, 4, 1),
      endDate: DateTime(2024, 12, 31),
      managerId: 'tm-2',
      manager: _teamMembers[1],
      teamMemberIds: ['tm-2', 'tm-4', 'tm-5'],
      teamMembers: [_teamMembers[1], _teamMembers[3], _teamMembers[4]],
      description: 'تصميم داخلي متكامل لفيلا سكنية في الرياض',
      createdAt: DateTime(2024, 3, 15),
      updatedAt: DateTime.now(),
    ),
    ProjectEntity(
      id: 'proj-6',
      name: 'مكتب شركة التقنية',
      status: ProjectStatus.onHold,
      progress: 35,
      startDate: DateTime(2024, 5, 1),
      endDate: DateTime(2024, 11, 30),
      managerId: 'tm-1',
      manager: _teamMembers[0],
      teamMemberIds: ['tm-1', 'tm-2'],
      teamMembers: [_teamMembers[0], _teamMembers[1]],
      description: 'تصميم وتنفيذ مكتب شركة تقنية حديثة',
      createdAt: DateTime(2024, 4, 20),
      updatedAt: DateTime.now(),
    ),
    ProjectEntity(
      id: 'proj-7',
      name: 'مطعم البحر الأحمر',
      status: ProjectStatus.completed,
      progress: 100,
      startDate: DateTime(2024, 2, 1),
      endDate: DateTime(2024, 6, 30),
      managerId: 'tm-4',
      manager: _teamMembers[3],
      teamMemberIds: ['tm-4', 'tm-5'],
      teamMembers: [_teamMembers[3], _teamMembers[4]],
      description: 'تصميم داخلي لمطعم بحري فاخر',
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 6, 30),
    ),
    ProjectEntity(
      id: 'proj-8',
      name: 'شقة جدة الفاخرة',
      status: ProjectStatus.active,
      progress: 85,
      startDate: DateTime(2024, 3, 15),
      endDate: DateTime(2024, 9, 30),
      managerId: 'tm-2',
      manager: _teamMembers[1],
      teamMemberIds: ['tm-2', 'tm-3', 'tm-4'],
      teamMembers: [_teamMembers[1], _teamMembers[2], _teamMembers[3]],
      description: 'تصميم شقة فاخرة بإطلالة بحرية في جدة',
      createdAt: DateTime(2024, 3, 1),
      updatedAt: DateTime.now(),
    ),
    ProjectEntity(
      id: 'proj-9',
      name: 'معرض السيارات',
      status: ProjectStatus.delayed,
      progress: 25,
      startDate: DateTime(2024, 6, 1),
      endDate: DateTime(2024, 8, 31),
      managerId: 'tm-3',
      manager: _teamMembers[2],
      teamMemberIds: ['tm-3', 'tm-5'],
      teamMembers: [_teamMembers[2], _teamMembers[4]],
      description: 'تصميم معرض سيارات حديث ومبتكر',
      createdAt: DateTime(2024, 5, 20),
      updatedAt: DateTime.now(),
    ),
    ProjectEntity(
      id: 'proj-10',
      name: 'فندق الملك عبدالعزيز',
      status: ProjectStatus.active,
      progress: 45,
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2025, 6, 30),
      managerId: 'tm-1',
      manager: _teamMembers[0],
      teamMemberIds: ['tm-1', 'tm-2', 'tm-3', 'tm-4', 'tm-5'],
      teamMembers: _teamMembers,
      description: 'مشروع تصميم داخلي ضخم لفندق 5 نجوم',
      createdAt: DateTime(2023, 12, 1),
      updatedAt: DateTime.now(),
    ),
  ];

  /// Get all projects
  List<ProjectEntity> getProjects({
    ProjectStatus? status,
    String? managerId,
    String? teamMemberId,
    String? searchQuery,
  }) {
    var filteredProjects = List<ProjectEntity>.from(_projects);

    if (status != null) {
      filteredProjects = filteredProjects
          .where((p) => p.status == status)
          .toList();
    }

    if (managerId != null) {
      filteredProjects = filteredProjects
          .where((p) => p.managerId == managerId)
          .toList();
    }

    if (teamMemberId != null) {
      filteredProjects = filteredProjects
          .where((p) => p.teamMemberIds.contains(teamMemberId))
          .toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredProjects = filteredProjects
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              (p.description?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    return filteredProjects;
  }

  /// Get project by ID
  ProjectEntity? getProjectById(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Create a new project
  ProjectEntity createProject(ProjectEntity project) {
    final newProject = project.copyWith(
      id: 'proj-${_projects.length + 1}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _projects.add(newProject);
    return newProject;
  }

  /// Update a project
  ProjectEntity? updateProject(ProjectEntity project) {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index == -1) return null;

    final updatedProject = project.copyWith(updatedAt: DateTime.now());
    _projects[index] = updatedProject;
    return updatedProject;
  }

  /// Delete a project
  bool deleteProject(String id) {
    final index = _projects.indexWhere((p) => p.id == id);
    if (index == -1) return false;

    _projects.removeAt(index);
    return true;
  }

  /// Get all team members
  List<TeamMemberEntity> getTeamMembers() {
    return List.unmodifiable(_teamMembers);
  }

  /// Get project statistics
  ProjectStatistics getProjectStatistics() {
    return ProjectStatistics(
      total: _projects.length,
      active: _projects.where((p) => p.status == ProjectStatus.active).length,
      completed: _projects.where((p) => p.status == ProjectStatus.completed).length,
      delayed: _projects.where((p) => p.status == ProjectStatus.delayed).length,
      onHold: _projects.where((p) => p.status == ProjectStatus.onHold).length,
    );
  }
}

