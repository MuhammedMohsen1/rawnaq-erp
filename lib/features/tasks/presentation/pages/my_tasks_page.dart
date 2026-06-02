import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/datasources/tasks_api_datasource.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/enums/task_status.dart';
import '../widgets/my_tasks_body.dart';

class MyTasksPage extends StatefulWidget {
  const MyTasksPage({super.key});

  @override
  State<MyTasksPage> createState() => _MyTasksPageState();
}

class _MyTasksPageState extends State<MyTasksPage> {
  final TasksApiDataSource _dataSource = TasksApiDataSource();

  bool _isLoading = true;
  String? _errorMessage;
  List<TaskEntity> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final today = DateTime.now();
      final startOfToday = DateTime(today.year, today.month, today.day);
      final startOfTomorrow = DateTime(today.year, today.month, today.day + 1);
      final tasks = await _dataSource.getMyTasks(
        startDate: startOfToday,
        endDate: startOfTomorrow,
      );
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل المهام';
      });
    }
  }

  Future<void> _updateStatus(TaskEntity task, TaskStatus status) async {
    try {
      await _dataSource.updateMyStatus(task.id, status);
      await _loadTasks();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث حالة المهمة: ${task.name}'),
          backgroundColor: AppColors.statusCompleted,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تحديث حالة المهمة'),
          backgroundColor: AppColors.statusDelayed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sidebarBackground,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مهامي اليوم', style: AppTextStyles.pageTitle),
            const SizedBox(height: 20),
            Expanded(
              child: MyTasksBody(
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                tasks: _tasks,
                onRetry: _loadTasks,
                onTaskStatusChanged: _updateStatus,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
