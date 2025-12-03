import 'package:flutter/material.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/enums/task_status.dart';
import '../../domain/enums/task_type.dart';
import '../../../projects/domain/entities/team_member_entity.dart';

/// Mock data source for tasks during development
class MockTasksDataSource {
  // Singleton instance
  static final MockTasksDataSource _instance = MockTasksDataSource._internal();
  factory MockTasksDataSource() => _instance;
  MockTasksDataSource._internal() {
    _initializeTasks();
  }

  // Mock team members
  final List<TeamMemberEntity> _teamMembers = const [
    TeamMemberEntity(
      id: 'tm-1',
      name: 'أحمد محمود',
      role: 'مدير مشروع',
      email: 'ahmed@rawnaq.com',
    ),
    TeamMemberEntity(
      id: 'tm-2',
      name: 'سارة علي',
      role: 'مصممة داخلية',
      email: 'sara@rawnaq.com',
    ),
    TeamMemberEntity(
      id: 'tm-3',
      name: 'محمد خالد',
      role: 'مهندس تنفيذ',
      email: 'mohammed@rawnaq.com',
    ),
    TeamMemberEntity(
      id: 'tm-4',
      name: 'نورة عبدالله',
      role: 'مصممة داخلية',
      email: 'noura@rawnaq.com',
    ),
    TeamMemberEntity(
      id: 'tm-5',
      name: 'كريم سالم',
      role: 'مشرف موقع',
      email: 'karim@rawnaq.com',
    ),
  ];

  // Mutable task list
  final List<TaskEntity> _tasks = [];

  // Get current week dates (Saturday to Friday)
  DateTime get _currentSaturday {
    final now = DateTime.now();
    int daysToSubtract = (now.weekday + 1) % 7;
    return DateTime(now.year, now.month, now.day - daysToSubtract);
  }

  void _initializeTasks() {
    if (_tasks.isNotEmpty) return;

    final saturday = _currentSaturday;

    _tasks.addAll([
      // ========== أحمد محمود - مدير مشروع ==========
      // Work Task
      TaskEntity(
        id: 'task-1',
        name: 'تصميم الواجهات الرئيسية',
        taskType: TaskType.workTask,
        projectId: 'proj-1',
        projectName: 'فيلا العبدالله',
        assigneeId: 'tm-1',
        assignee: _teamMembers[0],
        startDate: saturday,
        endDate: saturday.add(const Duration(days: 1)),
        status: TaskStatus.inProgress,
        taskTime: const TimeOfDay(hour: 9, minute: 0),
        notes: 'تصميم الواجهات الرئيسية للموقع',
      ),
      // Appointment
      TaskEntity(
        id: 'task-2',
        name: 'اجتماع مع العميل',
        taskType: TaskType.appointment,
        assigneeId: 'tm-1',
        assignee: _teamMembers[0],
        startDate: saturday.add(const Duration(days: 2)),
        endDate: saturday.add(const Duration(days: 2)),
        status: TaskStatus.waiting,
        customerName: 'محمد العبدالله',
        customerPhone: '+966501234567',
        locationLink: 'https://maps.google.com/?q=24.7136,46.6753',
        taskTime: const TimeOfDay(hour: 10, minute: 30),
      ),
      // Work Task
      TaskEntity(
        id: 'task-3',
        name: 'إعداد الرسومات التنفيذية',
        taskType: TaskType.workTask,
        projectId: 'proj-2',
        projectName: 'برج التجارة',
        assigneeId: 'tm-1',
        assignee: _teamMembers[0],
        startDate: saturday.add(const Duration(days: 4)),
        endDate: saturday.add(const Duration(days: 6)),
        status: TaskStatus.delayed,
        taskTime: const TimeOfDay(hour: 10, minute: 0),
        notes: 'إعداد الرسومات التنفيذية للمطبخ',
      ),

      // ========== سارة علي - مصممة داخلية ==========
      // Work Task
      TaskEntity(
        id: 'task-4',
        name: 'تعديلات العميل (الدورة الأولى)',
        taskType: TaskType.workTask,
        projectId: 'proj-1',
        projectName: 'فيلا العبدالله',
        assigneeId: 'tm-2',
        assignee: _teamMembers[1],
        startDate: saturday.add(const Duration(days: 1)),
        endDate: saturday.add(const Duration(days: 3)),
        status: TaskStatus.inProgress,
        notes: 'تعديلات العميل على التصميم',
      ),
      // Appointment
      TaskEntity(
        id: 'task-5',
        name: 'معاينة موقع المشروع',
        taskType: TaskType.appointment,
        assigneeId: 'tm-2',
        assignee: _teamMembers[1],
        startDate: saturday.add(const Duration(days: 4)),
        endDate: saturday.add(const Duration(days: 4)),
        status: TaskStatus.waiting,
        customerName: 'فاطمة السعيد',
        customerPhone: '+966507654321',
        locationLink: 'شارع الملك فهد، جدة',
        taskTime: const TimeOfDay(hour: 14, minute: 0),
      ),
      // General Task
      TaskEntity(
        id: 'task-6',
        name: 'تحديث ملف العروض',
        taskType: TaskType.generalTask,
        assigneeId: 'tm-2',
        assignee: _teamMembers[1],
        startDate: saturday.add(const Duration(days: 5)),
        endDate: saturday.add(const Duration(days: 5)),
        status: TaskStatus.waiting,
        notes: 'تحديث ملف عروض الأسعار للعملاء الجدد',
      ),

      // ========== محمد خالد - مهندس تنفيذ ==========
      // Work Task
      TaskEntity(
        id: 'task-7',
        name: 'اجتماع الانطلاق',
        taskType: TaskType.workTask,
        projectId: 'proj-2',
        projectName: 'برج التجارة',
        assigneeId: 'tm-3',
        assignee: _teamMembers[2],
        startDate: saturday,
        endDate: saturday,
        status: TaskStatus.completed,
        notes: 'اجتماع انطلاق المشروع',
      ),
      // Work Task
      TaskEntity(
        id: 'task-8',
        name: 'اختيار المواد',
        taskType: TaskType.workTask,
        projectId: 'proj-3',
        projectName: 'شقة جدة',
        assigneeId: 'tm-3',
        assignee: _teamMembers[2],
        startDate: saturday.add(const Duration(days: 1)),
        endDate: saturday.add(const Duration(days: 2)),
        status: TaskStatus.inProgress,
      ),
      // Appointment
      TaskEntity(
        id: 'task-9',
        name: 'زيارة معرض المواد',
        taskType: TaskType.appointment,
        assigneeId: 'tm-3',
        assignee: _teamMembers[2],
        startDate: saturday.add(const Duration(days: 3)),
        endDate: saturday.add(const Duration(days: 3)),
        status: TaskStatus.waiting,
        customerName: 'معرض الديكور الحديث',
        customerPhone: '+966512345678',
        locationLink: 'https://maps.google.com/?q=21.5433,39.1728',
        taskTime: const TimeOfDay(hour: 11, minute: 0),
      ),
      // General Task
      TaskEntity(
        id: 'task-10',
        name: 'إعداد تقرير الأسبوع',
        taskType: TaskType.generalTask,
        assigneeId: 'tm-3',
        assignee: _teamMembers[2],
        startDate: saturday.add(const Duration(days: 6)),
        endDate: saturday.add(const Duration(days: 6)),
        status: TaskStatus.waiting,
        notes: 'إعداد التقرير الأسبوعي للإدارة',
      ),

      // ========== نورة عبدالله - مصممة داخلية ==========
      // Work Task
      TaskEntity(
        id: 'task-11',
        name: 'تصميم الاستقبال',
        taskType: TaskType.workTask,
        projectId: 'proj-4',
        projectName: 'مكتب شركة التقنية',
        assigneeId: 'tm-4',
        assignee: _teamMembers[3],
        startDate: saturday,
        endDate: saturday.add(const Duration(days: 2)),
        status: TaskStatus.completed,
      ),
      // Work Task
      TaskEntity(
        id: 'task-12',
        name: 'تصميم غرف الاجتماعات',
        taskType: TaskType.workTask,
        projectId: 'proj-4',
        projectName: 'مكتب شركة التقنية',
        assigneeId: 'tm-4',
        assignee: _teamMembers[3],
        startDate: saturday.add(const Duration(days: 3)),
        endDate: saturday.add(const Duration(days: 4)),
        status: TaskStatus.inProgress,
      ),
      // Appointment
      TaskEntity(
        id: 'task-13',
        name: 'عرض التصميم للعميل',
        taskType: TaskType.appointment,
        assigneeId: 'tm-4',
        assignee: _teamMembers[3],
        startDate: saturday.add(const Duration(days: 5)),
        endDate: saturday.add(const Duration(days: 5)),
        status: TaskStatus.waiting,
        customerName: 'خالد التميمي',
        customerPhone: '+966509876543',
        locationLink: 'مقر شركة التقنية، الرياض',
        taskTime: const TimeOfDay(hour: 16, minute: 0),
        notes: 'عرض تصميم المكتب على المدير التنفيذي',
      ),

      // ========== كريم سالم - مشرف موقع ==========
      // Work Task
      TaskEntity(
        id: 'task-14',
        name: 'تنسيق الموقع',
        taskType: TaskType.workTask,
        projectId: 'proj-4',
        projectName: 'مكتب شركة التقنية',
        assigneeId: 'tm-5',
        assignee: _teamMembers[4],
        startDate: saturday.add(const Duration(days: 1)),
        endDate: saturday.add(const Duration(days: 2)),
        status: TaskStatus.completed,
      ),
      // Work Task
      TaskEntity(
        id: 'task-15',
        name: 'متابعة أعمال البناء',
        taskType: TaskType.workTask,
        projectId: 'proj-1',
        projectName: 'فيلا العبدالله',
        assigneeId: 'tm-5',
        assignee: _teamMembers[4],
        startDate: saturday.add(const Duration(days: 3)),
        endDate: saturday.add(const Duration(days: 6)),
        status: TaskStatus.inProgress,
      ),
      // Appointment
      TaskEntity(
        id: 'task-16',
        name: 'استلام مواد من المورد',
        taskType: TaskType.appointment,
        assigneeId: 'tm-5',
        assignee: _teamMembers[4],
        startDate: saturday.add(const Duration(days: 4)),
        endDate: saturday.add(const Duration(days: 4)),
        status: TaskStatus.waiting,
        customerName: 'مؤسسة المواد الحديثة',
        customerPhone: '+966511112222',
        locationLink: 'مستودع المواد، المنطقة الصناعية',
        taskTime: const TimeOfDay(hour: 9, minute: 0),
      ),
      // General Task
      TaskEntity(
        id: 'task-17',
        name: 'جرد أدوات الموقع',
        taskType: TaskType.generalTask,
        assigneeId: 'tm-5',
        assignee: _teamMembers[4],
        startDate: saturday,
        endDate: saturday,
        status: TaskStatus.completed,
        notes: 'جرد وتحديث قائمة أدوات الموقع',
      ),
    ]);
  }

  /// Add a new task
  void addTask(TaskEntity task) {
    _tasks.add(task);
  }

  /// Get all tasks
  List<TaskEntity> getTasks({
    TaskStatus? status,
    String? assigneeId,
    String? projectId,
    TaskType? taskType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var filteredTasks = List<TaskEntity>.from(_tasks);

    if (status != null) {
      filteredTasks = filteredTasks.where((t) => t.status == status).toList();
    }

    if (assigneeId != null) {
      filteredTasks =
          filteredTasks.where((t) => t.assigneeId == assigneeId).toList();
    }

    if (projectId != null) {
      filteredTasks =
          filteredTasks.where((t) => t.projectId == projectId).toList();
    }

    if (taskType != null) {
      filteredTasks =
          filteredTasks.where((t) => t.taskType == taskType).toList();
    }

    if (startDate != null) {
      filteredTasks = filteredTasks
          .where((t) =>
              t.startDate.isAfter(startDate) ||
              t.startDate.isAtSameMomentAs(startDate))
          .toList();
    }

    if (endDate != null) {
      filteredTasks = filteredTasks
          .where((t) =>
              t.endDate.isBefore(endDate) ||
              t.endDate.isAtSameMomentAs(endDate))
          .toList();
    }

    return filteredTasks;
  }

  /// Get tasks within a date range (for Gantt chart)
  List<TaskEntity> getTasksInRange(DateTime start, DateTime end) {
    return _tasks.where((task) {
      // Task overlaps with the range
      return task.startDate.isBefore(end) && task.endDate.isAfter(start);
    }).toList();
  }

  /// Get all team members
  List<TeamMemberEntity> getTeamMembers() {
    return List.unmodifiable(_teamMembers);
  }

  /// Get overdue tasks
  List<TaskEntity> getOverdueTasks() {
    return _tasks.where((t) => t.isOverdue).toList();
  }

  /// Get tasks for a specific team member
  List<TaskEntity> getTasksForMember(String memberId) {
    return _tasks.where((t) => t.assigneeId == memberId).toList();
  }

  /// Get team members with workload issues (more than 3 active tasks)
  List<TeamMemberEntity> getMembersWithOverload() {
    final Map<String, int> taskCounts = {};
    for (final task in _tasks) {
      if (task.status != TaskStatus.completed) {
        taskCounts[task.assigneeId] =
            (taskCounts[task.assigneeId] ?? 0) + 1;
      }
    }

    return _teamMembers.where((m) => (taskCounts[m.id] ?? 0) > 3).toList();
  }

  /// Get delayed projects
  List<String> getDelayedProjects() {
    return _tasks
        .where((t) => t.status == TaskStatus.delayed && t.projectName != null)
        .map((t) => t.projectName!)
        .toSet()
        .toList();
  }

  /// Get appointments for today
  List<TaskEntity> getTodayAppointments() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _tasks.where((t) {
      return t.taskType == TaskType.appointment &&
          t.startDate.isAfter(today.subtract(const Duration(seconds: 1))) &&
          t.startDate.isBefore(tomorrow);
    }).toList();
  }
}
