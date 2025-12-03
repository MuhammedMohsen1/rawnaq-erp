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
        startDate: DateTime(saturday.year, saturday.month, saturday.day, 9, 0),
        endDate: DateTime(saturday.year, saturday.month, saturday.day + 1, 17, 0),
        status: TaskStatus.inProgress,
        notes: 'تصميم الواجهات الرئيسية للموقع',
      ),
      // Appointment
      TaskEntity(
        id: 'task-2',
        name: 'اجتماع مع العميل',
        taskType: TaskType.appointment,
        assigneeId: 'tm-1',
        assignee: _teamMembers[0],
        startDate: DateTime(saturday.year, saturday.month, saturday.day + 2, 10, 30),
        endDate: DateTime(saturday.year, saturday.month, saturday.day + 2, 10, 30),
        status: TaskStatus.waiting,
        customerName: 'محمد العبدالله',
        customerPhone: '+966501234567',
        locationLink: 'https://maps.google.com/?q=24.7136,46.6753',
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
        startDate: DateTime(saturday.year, saturday.month, saturday.day + 4, 10, 0),
        endDate: DateTime(saturday.year, saturday.month, saturday.day + 6, 16, 0),
        status: TaskStatus.delayed,
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
        startDate: DateTime(saturday.year, saturday.month, saturday.day + 1, 9, 0),
        endDate: DateTime(saturday.year, saturday.month, saturday.day + 3, 17, 0),
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
        startDate: DateTime(saturday.year, saturday.month, saturday.day + 4, 14, 0),
        endDate: DateTime(saturday.year, saturday.month, saturday.day + 4, 14, 0),
        status: TaskStatus.waiting,
        customerName: 'فاطمة السعيد',
        customerPhone: '+966507654321',
        locationLink: 'شارع الملك فهد، جدة',
      ),
      // General Task
      TaskEntity(
        id: 'task-6',
        name: 'تحديث ملف العروض',
        taskType: TaskType.generalTask,
        assigneeId: 'tm-2',
        assignee: _teamMembers[1],
        startDate: DateTime(saturday.year, saturday.month, saturday.day + 5, 10, 0),
        endDate: DateTime(saturday.year, saturday.month, saturday.day + 5, 14, 0),
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
        startDate: DateTime(saturday.year, saturday.month, saturday.day, 8, 0),
        endDate: DateTime(saturday.year, saturday.month, saturday.day, 12, 0),
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
        startDate: DateTime(saturday.year, saturday.month, saturday.day + 1, 9, 0),
        endDate: DateTime(saturday.year, saturday.month, saturday.day + 2, 15, 0),
        status: TaskStatus.inProgress,
      ),
      // Appointment
      TaskEntity(
        id: 'task-9',
        name: 'زيارة معرض المواد',
        taskType: TaskType.appointment,
        assigneeId: 'tm-3',
        assignee: _teamMembers[2],
        startDate: DateTime(saturday.year, saturday.month, saturday.day + 3, 11, 0),
        endDate: DateTime(saturday.year, saturday.month, saturday.day + 3, 11, 0),
        status: TaskStatus.waiting,
        customerName: 'معرض الديكور الحديث',
        customerPhone: '+966512345678',
        locationLink: 'https://maps.google.com/?q=21.5433,39.1728',
      ),
      // General Task
      TaskEntity(
        id: 'task-10',
        name: 'إعداد تقرير الأسبوع',
        taskType: TaskType.generalTask,
        assigneeId: 'tm-3',
        assignee: _teamMembers[2],
        startDate: DateTime(saturday.year, saturday.month, saturday.day + 6, 14, 0),
        endDate: DateTime(saturday.year, saturday.month, saturday.day + 6, 17, 0),
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
        startDate: DateTime(saturday.year, saturday.month, saturday.day, 9, 0),
        endDate: DateTime(saturday.year, saturday.month, saturday.day + 2, 17, 0),
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
        startDate: DateTime(saturday.year, saturday.month, saturday.day + 3, 9, 0),
        endDate: DateTime(saturday.year, saturday.month, saturday.day + 4, 17, 0),
        status: TaskStatus.inProgress,
      ),
      // Appointment
      TaskEntity(
        id: 'task-13',
        name: 'عرض التصميم للعميل',
        taskType: TaskType.appointment,
        assigneeId: 'tm-4',
        assignee: _teamMembers[3],
        startDate: DateTime(saturday.year, saturday.month, saturday.day + 5, 16, 0),
        endDate: DateTime(saturday.year, saturday.month, saturday.day + 5, 16, 0),
        status: TaskStatus.waiting,
        customerName: 'خالد التميمي',
        customerPhone: '+966509876543',
        locationLink: 'مقر شركة التقنية، الرياض',
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
        startDate: DateTime(saturday.year, saturday.month, saturday.day + 1, 7, 0),
        endDate: DateTime(saturday.year, saturday.month, saturday.day + 2, 16, 0),
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
        startDate: DateTime(saturday.year, saturday.month, saturday.day + 3, 7, 0),
        endDate: DateTime(saturday.year, saturday.month, saturday.day + 6, 16, 0),
        status: TaskStatus.inProgress,
      ),
      // Appointment
      TaskEntity(
        id: 'task-16',
        name: 'استلام مواد من المورد',
        taskType: TaskType.appointment,
        assigneeId: 'tm-5',
        assignee: _teamMembers[4],
        startDate: DateTime(saturday.year, saturday.month, saturday.day + 4, 9, 0),
        endDate: DateTime(saturday.year, saturday.month, saturday.day + 4, 9, 0),
        status: TaskStatus.waiting,
        customerName: 'مؤسسة المواد الحديثة',
        customerPhone: '+966511112222',
        locationLink: 'مستودع المواد، المنطقة الصناعية',
      ),
      // General Task
      TaskEntity(
        id: 'task-17',
        name: 'جرد أدوات الموقع',
        taskType: TaskType.generalTask,
        assigneeId: 'tm-5',
        assignee: _teamMembers[4],
        startDate: DateTime(saturday.year, saturday.month, saturday.day, 13, 0),
        endDate: DateTime(saturday.year, saturday.month, saturday.day, 16, 0),
        status: TaskStatus.completed,
        notes: 'جرد وتحديث قائمة أدوات الموقع',
      ),
    ]);
  }

  /// Add a new task
  void addTask(TaskEntity task) {
    _tasks.add(task);
  }

  /// Update an existing task
  void updateTask(TaskEntity updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
    }
  }

  /// Delete a task
  void deleteTask(String taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
  }

  /// Get draft tasks (no assignee)
  List<TaskEntity> getDraftTasks() {
    return _tasks.where((t) => t.isDraft || t.assigneeId == null).toList();
  }

  /// Assign a draft task to an employee
  /// The task starts from [newStartDate] but preserves its original time
  void assignTask(String taskId, String assigneeId, DateTime newStartDate) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final assignee = _teamMembers.firstWhere(
        (m) => m.id == assigneeId,
        orElse: () => _teamMembers.first,
      );
      
      // Calculate duration in days
      final durationDays = task.endDateOnly.difference(task.startDateOnly).inDays;
      
      // Create new start date preserving original time
      final newStart = DateTime(
        newStartDate.year,
        newStartDate.month,
        newStartDate.day,
        task.startDate.hour,
        task.startDate.minute,
      );
      
      // Create new end date preserving original time
      final newEndDate = DateTime(
        newStartDate.year,
        newStartDate.month,
        newStartDate.day + durationDays,
        task.endDate.hour,
        task.endDate.minute,
      );
      
      _tasks[index] = task.copyWith(
        assigneeId: assigneeId,
        assignee: assignee,
        startDate: newStart,
        endDate: newEndDate,
        isDraft: false,
      );
    }
  }

  /// Update task dates (for drag and drop)
  /// The task moves to [newStartDate] but preserves:
  /// - Original start/end times
  /// - Original duration in days
  /// Optionally changes assignee if [newAssigneeId] is provided
  void updateTaskDates(String taskId, DateTime newStartDate, {String? newAssigneeId}) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      
      // Calculate duration in days (date-only)
      final durationDays = task.endDateOnly.difference(task.startDateOnly).inDays;
      
      // Create new start date preserving original time
      final newStart = DateTime(
        newStartDate.year,
        newStartDate.month,
        newStartDate.day,
        task.startDate.hour,
        task.startDate.minute,
      );
      
      // Create new end date preserving original time and duration
      final newEnd = DateTime(
        newStartDate.year,
        newStartDate.month,
        newStartDate.day + durationDays,
        task.endDate.hour,
        task.endDate.minute,
      );
      
      // Get new assignee if changing
      TeamMemberEntity? newAssignee;
      String? finalAssigneeId = task.assigneeId;
      if (newAssigneeId != null && newAssigneeId != task.assigneeId) {
        newAssignee = _teamMembers.firstWhere(
          (m) => m.id == newAssigneeId,
          orElse: () => _teamMembers.first,
        );
        finalAssigneeId = newAssigneeId;
      }
      
      _tasks[index] = task.copyWith(
        startDate: newStart,
        endDate: newEnd,
        assigneeId: finalAssigneeId,
        assignee: newAssignee ?? task.assignee,
      );
    }
  }

  /// Update task with full details (for edit dialog)
  void updateTaskFull(
    String taskId, {
    DateTime? startDate,
    DateTime? endDate,
    String? assigneeId,
    TaskStatus? status,
    String? name,
    String? notes,
  }) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      
      TeamMemberEntity? newAssignee;
      if (assigneeId != null && assigneeId != task.assigneeId) {
        newAssignee = _teamMembers.firstWhere(
          (m) => m.id == assigneeId,
          orElse: () => _teamMembers.first,
        );
      }
      
      _tasks[index] = task.copyWith(
        startDate: startDate ?? task.startDate,
        endDate: endDate ?? task.endDate,
        assigneeId: assigneeId ?? task.assigneeId,
        assignee: newAssignee ?? task.assignee,
        status: status ?? task.status,
        name: name ?? task.name,
        notes: notes ?? task.notes,
        isDraft: false,
      );
    }
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
      if (task.status != TaskStatus.completed && task.assigneeId != null) {
        taskCounts[task.assigneeId!] =
            (taskCounts[task.assigneeId!] ?? 0) + 1;
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
