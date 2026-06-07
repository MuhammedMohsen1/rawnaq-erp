import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../projects/data/datasources/projects_api_datasource.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/enums/task_status.dart';
import '../../../tasks/domain/enums/task_type.dart';
import '../../../tasks/data/datasources/tasks_api_datasource.dart';
import '../../../projects/domain/entities/team_member_entity.dart';
import '../widgets/gantt_filters_widget.dart';
import '../widgets/add_task_dialog_simple.dart';
import '../widgets/appointment_widgets.dart';
import '../widgets/edit_task_dialog.dart';
import '../widgets/gantt_chart_widgets.dart';

/// Gantt Chart page for task visualization
class GanttChartPage extends StatefulWidget {
  const GanttChartPage({super.key});

  @override
  State<GanttChartPage> createState() => _GanttChartPageState();
}

class _ZoomInIntent extends Intent {
  const _ZoomInIntent();
}

class _ZoomOutIntent extends Intent {
  const _ZoomOutIntent();
}

class _ResetZoomIntent extends Intent {
  const _ResetZoomIntent();
}

class _GanttChartPageState extends State<GanttChartPage>
    with WidgetsBindingObserver {
  static const MethodChannel _desktopZoomChannel = MethodChannel(
    'rawnaq/gantt_zoom',
  );
  static const int _timelinePastDays = 90;
  static const int _timelineDisplayWorkDays = 365;
  static const int _timelineFetchCalendarDays = 520;

  final TasksApiDataSource _dataSource = TasksApiDataSource();
  final ProjectsApiDataSource _projectsDataSource = ProjectsApiDataSource();
  final ScrollController _horizontalTimelineScrollController =
      ScrollController();

  static final Map<ShortcutActivator, Intent> _zoomShortcuts = {
    const SingleActivator(LogicalKeyboardKey.equal, control: true):
        const _ZoomInIntent(),
    const SingleActivator(LogicalKeyboardKey.equal, control: true, shift: true):
        const _ZoomInIntent(),
    const SingleActivator(LogicalKeyboardKey.add, control: true):
        const _ZoomInIntent(),
    const SingleActivator(LogicalKeyboardKey.numpadAdd, control: true):
        const _ZoomInIntent(),
    const SingleActivator(LogicalKeyboardKey.minus, control: true):
        const _ZoomOutIntent(),
    const SingleActivator(LogicalKeyboardKey.numpadSubtract, control: true):
        const _ZoomOutIntent(),
    const SingleActivator(LogicalKeyboardKey.digit0, control: true):
        const _ResetZoomIntent(),
    const SingleActivator(LogicalKeyboardKey.numpad0, control: true):
        const _ResetZoomIntent(),
    const SingleActivator(LogicalKeyboardKey.equal, meta: true):
        const _ZoomInIntent(),
    const SingleActivator(LogicalKeyboardKey.equal, meta: true, shift: true):
        const _ZoomInIntent(),
    const SingleActivator(LogicalKeyboardKey.add, meta: true):
        const _ZoomInIntent(),
    const SingleActivator(LogicalKeyboardKey.numpadAdd, meta: true):
        const _ZoomInIntent(),
    const SingleActivator(LogicalKeyboardKey.minus, meta: true):
        const _ZoomOutIntent(),
    const SingleActivator(LogicalKeyboardKey.numpadSubtract, meta: true):
        const _ZoomOutIntent(),
    const SingleActivator(LogicalKeyboardKey.digit0, meta: true):
        const _ResetZoomIntent(),
    const SingleActivator(LogicalKeyboardKey.numpad0, meta: true):
        const _ResetZoomIntent(),
  };

  GanttTimePeriod _selectedPeriod = GanttTimePeriod.week;
  GanttLayoutOrientation _selectedOrientation =
      GanttLayoutOrientation.horizontal;
  double _horizontalZoom = 1.0;
  bool _showTeamTasks = true;
  String? _selectedMemberId;
  bool _isDraftPanelExpanded = true;
  bool _didAutoScrollTimelineToToday = false;
  bool _rawMetaHeld = false;
  bool _rawControlHeld = false;
  double _gestureBaseZoom = 1.0;
  double? _touchPinchBaseDistance;
  bool _isLoading = true;
  String? _errorMessage;
  final Map<int, Offset> _activeTouchPoints = {};

  List<TaskEntity> _tasks = [];
  List<TaskEntity> _draftTasks = [];
  List<TeamMemberEntity> _teamMembers = [];
  List<TeamMemberEntity> _overloadedMembers = [];
  List<String> _delayedProjects = [];
  List<Map<String, String>> _projects = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HardwareKeyboard.instance.addHandler(_handleGlobalZoomShortcut);
    RawKeyboard.instance.addListener(_handleRawZoomShortcut);
    _desktopZoomChannel.setMethodCallHandler(_handleDesktopZoomMethodCall);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    HardwareKeyboard.instance.removeHandler(_handleGlobalZoomShortcut);
    RawKeyboard.instance.removeListener(_handleRawZoomShortcut);
    _desktopZoomChannel.setMethodCallHandler(null);
    _horizontalTimelineScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _rawMetaHeld = false;
      _rawControlHeld = false;
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _teamMembers = await _dataSource.getTeamMembers();
      _projects = await _loadProjectsForTasks();
      await _applyFilters(setLoading: false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل المهام';
      });
    }
  }

  Future<List<Map<String, String>>> _loadProjectsForTasks() async {
    try {
      final response = await _projectsDataSource.getProjects(limit: 100);
      final projects = response['projects'] as List<dynamic>;
      return projects
          .map((json) {
            final map = json as Map<String, dynamic>;
            return {
              'id': map['id'] as String,
              'name': map['name'] as String? ?? '',
            };
          })
          .where((project) => project['name']!.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _applyFilters({bool setLoading = true}) async {
    if (setLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final startDate = _getStartDate();
      final endDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day + _timelineFetchCalendarDays,
      );
      final assigneeId = _showTeamTasks ? _selectedMemberId : null;
      final tasks = _showTeamTasks
          ? await _dataSource.getTasks(
              assigneeId: assigneeId,
              startDate: startDate,
              endDate: endDate,
              includeDrafts: true,
            )
          : await _dataSource.getMyTasks(
              startDate: startDate,
              endDate: endDate,
            );

      if (!mounted) return;
      setState(() {
        _tasks = tasks
            .where((t) => !t.isDraft && t.assigneeId != null)
            .toList();
        _draftTasks = tasks
            .where((t) => t.isDraft || t.assigneeId == null)
            .toList();
        _overloadedMembers = _calculateOverloadedMembers(_tasks);
        _delayedProjects = _calculateDelayedProjects(_tasks);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل المهام';
      });
    }
  }

  Future<void> _refreshTasksPreservingTimeline() async {
    final offset = _horizontalTimelineScrollController.hasClients
        ? _horizontalTimelineScrollController.offset
        : null;

    await _applyFilters(setLoading: false);

    if (offset == null || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_horizontalTimelineScrollController.hasClients) return;
      final position = _horizontalTimelineScrollController.position;
      final target = offset.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      _horizontalTimelineScrollController.jumpTo(target);
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedPeriod = GanttTimePeriod.week;
      _showTeamTasks = true;
      _selectedMemberId = null;
    });
    _applyFilters();
  }

  void _zoomIn() {
    _setHorizontalZoom(_horizontalZoom + 0.15);
  }

  void _zoomOut() {
    _setHorizontalZoom(_horizontalZoom - 0.15);
  }

  void _resetZoom() {
    setState(() => _horizontalZoom = 1.0);
  }

  void _setHorizontalZoom(double zoom) {
    final nextZoom = zoom.clamp(0.75, 2.2).toDouble();
    if (nextZoom == _horizontalZoom) return;
    setState(() => _horizontalZoom = nextZoom);
  }

  List<TeamMemberEntity> _calculateOverloadedMembers(List<TaskEntity> tasks) {
    final counts = <String, int>{};
    for (final task in tasks) {
      if (task.status != TaskStatus.completed && task.assigneeId != null) {
        counts[task.assigneeId!] = (counts[task.assigneeId!] ?? 0) + 1;
      }
    }

    return _teamMembers.where((m) => (counts[m.id] ?? 0) > 3).toList();
  }

  List<String> _calculateDelayedProjects(List<TaskEntity> tasks) {
    return tasks
        .where(
          (task) =>
              task.status == TaskStatus.delayed && task.projectName != null,
        )
        .map((task) => task.projectName!)
        .toSet()
        .toList();
  }

  DateTime _getStartDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - _timelinePastDays);
  }

  int _getViewDays() {
    return _timelineDisplayWorkDays;
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AddTaskDialogSimple(
        projects: _projects,
        onTaskAdded: (task) {
          bool wasAdjusted = false;
          _dataSource.createTask(task).then((createdTask) {
            wasAdjusted = createdTask.wasAdjusted;
            _refreshTasksPreservingTimeline();

            if (!mounted) return;
            if (wasAdjusted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم إضافة المهمة: ${task.name}\nتم تعديل الوقت تلقائياً لتجنب التعارض',
                  ),
                  backgroundColor: AppColors.warning,
                  duration: const Duration(seconds: 4),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم إضافة المهمة: ${task.name}'),
                  backgroundColor: AppColors.statusOnHold,
                ),
              );
            }
          });
        },
      ),
    );
  }

  void _showAppointmentDetails(TaskEntity task) {
    showDialog(
      context: context,
      builder: (context) => AppointmentDetailsDialog(task: task),
    );
  }

  Future<void> _onTaskDropped(
    TaskEntity task,
    String assigneeId,
    DateTime date,
  ) async {
    final updatedTask = task.isDraft || task.assigneeId == null
        ? await _dataSource.assignTask(
            task.id,
            assigneeId: assigneeId,
            startDate: _datePreservingTaskTime(date, task.startDate),
          )
        : await _dataSource.scheduleTask(
            task.id,
            startDate: _datePreservingTaskTime(date, task.startDate),
            assigneeId: assigneeId,
          );

    await _refreshTasksPreservingTimeline();

    final action = (task.isDraft || task.assigneeId == null)
        ? 'تم تعيين المهمة'
        : (task.assigneeId != assigneeId
              ? 'تم نقل المهمة'
              : 'تم تحديث تاريخ المهمة');

    if (updatedTask.wasAdjusted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$action: ${task.name}\nتم تعديل الوقت تلقائياً لتجنب التعارض',
          ),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$action: ${task.name}'),
          backgroundColor: AppColors.statusCompleted,
        ),
      );
    }
  }

  /// Called when a task is resized by dragging its edges
  Future<void> _onTaskResized(
    TaskEntity task,
    DateTime newStart,
    DateTime newEnd,
  ) async {
    // Skip conflict check for appointments
    if (task.taskType == TaskType.appointment || task.assigneeId == null) {
      await _dataSource.scheduleTask(
        task.id,
        startDate: newStart,
        endDate: newEnd,
      );
      await _refreshTasksPreservingTimeline();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تعديل مدة المهمة: ${task.name}'),
          backgroundColor: AppColors.statusCompleted,
        ),
      );
      return;
    }

    final updatedTask = await _dataSource.scheduleTask(
      task.id,
      startDate: newStart,
      endDate: newEnd,
      assigneeId: task.assigneeId,
    );
    await _refreshTasksPreservingTimeline();

    final wasAdjusted = updatedTask.wasAdjusted;
    if (wasAdjusted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تعديل مدة المهمة: ${task.name}\nتم تعديل الوقت تلقائياً لتجنب التعارض',
          ),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تعديل مدة المهمة: ${task.name}'),
          backgroundColor: AppColors.statusCompleted,
        ),
      );
    }
  }

  DateTime _datePreservingTaskTime(DateTime date, DateTime timeSource) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      timeSource.hour,
      timeSource.minute,
      timeSource.second,
    );
  }

  void _showEditTaskDialog(TaskEntity task) {
    showDialog(
      context: context,
      builder: (dialogContext) => EditTaskDialog(
        task: task,
        teamMembers: _teamMembers,
        onTaskUpdated: (updatedTask) async {
          final savedTask = await _dataSource.updateTask(updatedTask);
          await _refreshTasksPreservingTimeline();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                savedTask.wasAdjusted
                    ? 'تم تحديث المهمة: ${updatedTask.name}\nتم تعديل الوقت تلقائياً لتجنب التعارض'
                    : 'تم تحديث المهمة: ${updatedTask.name}',
              ),
              backgroundColor: savedTask.wasAdjusted
                  ? AppColors.warning
                  : AppColors.statusCompleted,
              duration: savedTask.wasAdjusted
                  ? const Duration(seconds: 4)
                  : const Duration(seconds: 3),
            ),
          );
        },
        onTaskDeleted: () {
          _dataSource
              .deleteTask(task.id)
              .then((_) => _refreshTasksPreservingTimeline());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حذف المهمة: ${task.name}'),
              backgroundColor: AppColors.statusDelayed,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startDate = _getStartDate();

    return Scaffold(
      backgroundColor: AppColors.sidebarBackground,
      body: Shortcuts(
        shortcuts: _zoomShortcuts,
        child: Actions(
          actions: {
            _ZoomInIntent: CallbackAction<_ZoomInIntent>(
              onInvoke: (_) {
                _zoomIn();
                return null;
              },
            ),
            _ZoomOutIntent: CallbackAction<_ZoomOutIntent>(
              onInvoke: (_) {
                _zoomOut();
                return null;
              },
            ),
            _ResetZoomIntent: CallbackAction<_ResetZoomIntent>(
              onInvoke: (_) {
                _resetZoom();
                return null;
              },
            ),
          },
          child: Focus(
            autofocus: true,
            onKeyEvent: _handleZoomShortcut,
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerSignal: _handleZoomWheel,
              onPointerPanZoomStart: _handlePointerPanZoomStart,
              onPointerPanZoomUpdate: _handlePointerPanZoomUpdate,
              onPointerDown: _handleTouchPointerDown,
              onPointerMove: _handleTouchPointerMove,
              onPointerUp: _handleTouchPointerUp,
              onPointerCancel: _handleTouchPointerCancel,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: GanttChartPageBody(
                  selectedPeriod: _selectedPeriod,
                  selectedOrientation: _selectedOrientation,
                  horizontalZoom: _horizontalZoom,
                  onPointerSignal: _handleZoomWheel,
                  showTeamTasks: _showTeamTasks,
                  selectedMemberId: _selectedMemberId,
                  teamMembers: _teamMembers,
                  draftTasks: _draftTasks,
                  overloadedMembers: _overloadedMembers,
                  delayedProjects: _delayedProjects,
                  isDraftPanelExpanded: _isDraftPanelExpanded,
                  isLoading: _isLoading,
                  errorMessage: _errorMessage,
                  startDate: startDate,
                  horizontalTimelineScrollController:
                      _horizontalTimelineScrollController,
                  shouldScrollTimelineToToday: !_didAutoScrollTimelineToToday,
                  onTimelineScrolledToToday: () {
                    _didAutoScrollTimelineToToday = true;
                  },
                  tasks: _tasks,
                  onPeriodChanged: (period) {
                    setState(() => _selectedPeriod = period);
                  },
                  onOrientationChanged: (orientation) {
                    setState(() => _selectedOrientation = orientation);
                  },
                  onTeamTasksChanged: (showTeam) {
                    setState(() => _showTeamTasks = showTeam);
                  },
                  onMemberChanged: (memberId) {
                    setState(() => _selectedMemberId = memberId);
                  },
                  onZoomIn: _zoomIn,
                  onZoomOut: _zoomOut,
                  onResetZoom: _resetZoom,
                  onApplyFilters: _applyFilters,
                  onClearFilters: _clearFilters,
                  onToggleDraftPanel: () => setState(
                    () => _isDraftPanelExpanded = !_isDraftPanelExpanded,
                  ),
                  onAddTaskPressed: _showAddTaskDialog,
                  onRetry: _loadData,
                  onAppointmentDetails: _showAppointmentDetails,
                  onEditTask: _showEditTaskDialog,
                  onTaskDropped: _onTaskDropped,
                  onTaskResized: _onTaskResized,
                  onTaskUpdated: _applyFilters,
                  onTaskCreated: _dataSource.createTask,
                  onTaskDeleted: _deleteTaskAndRefresh,
                  onUpdateTask: _dataSource.updateTask,
                  datePreservingTaskTime: _datePreservingTaskTime,
                  isToday: _isToday,
                  isSameDate: _isSameDate,
                  getViewDays: _getViewDays,
                  getStartDate: _getStartDate,
                  calculateTaskLanes: _calculateTaskLanes,
                  laneCount: _laneCount,
                  daysInMonth: _daysInMonth,
                  toJulianDay: _toJulianDay,
                  timeToFraction: _timeToFraction,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  KeyEventResult _handleZoomShortcut(FocusNode node, KeyEvent event) {
    _trackHardwareZoomModifier(event);
    return _handleZoomKeyEvent(event)
        ? KeyEventResult.handled
        : KeyEventResult.ignored;
  }

  bool _handleGlobalZoomShortcut(KeyEvent event) {
    _trackHardwareZoomModifier(event);
    return _handleZoomKeyEvent(event);
  }

  void _handleRawZoomShortcut(RawKeyEvent event) {
    _trackRawZoomModifier(event);
    if (event is! RawKeyDownEvent) return;
    if (!_isRawZoomModifierPressed(event)) return;

    final key = event.logicalKey;
    final keyLabel = key.keyLabel;
    final data = event.data;
    final macKeyCode = data is RawKeyEventDataMacOs ? data.keyCode : null;

    if (key == LogicalKeyboardKey.equal ||
        key == LogicalKeyboardKey.add ||
        key == LogicalKeyboardKey.numpadAdd ||
        keyLabel == '+' ||
        keyLabel == '=' ||
        macKeyCode == 24) {
      _zoomIn();
      return;
    }
    if (key == LogicalKeyboardKey.minus ||
        key == LogicalKeyboardKey.numpadSubtract ||
        keyLabel == '-' ||
        keyLabel == '_' ||
        macKeyCode == 27) {
      _zoomOut();
      return;
    }
    if (key == LogicalKeyboardKey.digit0 ||
        key == LogicalKeyboardKey.numpad0 ||
        keyLabel == '0' ||
        macKeyCode == 29) {
      _resetZoom();
    }
  }

  bool _handleZoomKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (!_isZoomModifierPressed()) return false;

    final key = event.logicalKey;
    final character = event.character;
    if (key == LogicalKeyboardKey.equal ||
        key == LogicalKeyboardKey.add ||
        key == LogicalKeyboardKey.numpadAdd ||
        character == '+' ||
        character == '=') {
      _zoomIn();
      return true;
    }
    if (key == LogicalKeyboardKey.minus ||
        key == LogicalKeyboardKey.numpadSubtract ||
        character == '-' ||
        character == '_') {
      _zoomOut();
      return true;
    }
    if (key == LogicalKeyboardKey.digit0 ||
        key == LogicalKeyboardKey.numpad0 ||
        character == '0') {
      _resetZoom();
      return true;
    }
    return false;
  }

  Future<void> _handleDesktopZoomMethodCall(MethodCall call) async {
    final arguments = call.arguments;
    if (arguments is! Map) return;

    if (call.method == 'modifierChanged') {
      _handleNativeModifierChanged(arguments);
      return;
    }
    if (call.method != 'commandScroll') return;

    if (_usesMetaZoomModifier && arguments['commandPressed'] == false) {
      return;
    }
    if (!_usesMetaZoomModifier && arguments['controlPressed'] == false) {
      return;
    }

    final delta = arguments['delta'];
    final scrollAmount = delta is num ? delta.toDouble() : 0;
    if (scrollAmount > 0) {
      _zoomIn();
    } else if (scrollAmount < 0) {
      _zoomOut();
    }
  }

  void _handleNativeModifierChanged(Map<dynamic, dynamic> arguments) {
    final commandPressed = arguments['commandPressed'];
    if (commandPressed is bool) {
      _rawMetaHeld = commandPressed;
    }

    final controlPressed = arguments['controlPressed'];
    if (controlPressed is bool) {
      _rawControlHeld = controlPressed;
    }
  }

  void _handleZoomWheel(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;

    _syncZoomModifierFromHardwareKeyboard();
    final modifierPressed = _isWheelZoomModifierPressed();
    if (!modifierPressed) return;

    GestureBinding.instance.pointerSignalResolver.register(event, (
      PointerSignalEvent resolvedEvent,
    ) {
      if (resolvedEvent is! PointerScrollEvent) return;
      final scrollAmount = resolvedEvent.scrollDelta.dy != 0
          ? resolvedEvent.scrollDelta.dy
          : resolvedEvent.scrollDelta.dx;
      if (scrollAmount < 0) {
        _zoomIn();
      } else if (scrollAmount > 0) {
        _zoomOut();
      }
    });
  }

  void _handlePointerPanZoomStart(PointerPanZoomStartEvent event) {
    _gestureBaseZoom = _horizontalZoom;
  }

  void _handlePointerPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    if (event.scale == 1.0) return;
    _setHorizontalZoom(_gestureBaseZoom * event.scale);
  }

  void _handleTouchPointerDown(PointerDownEvent event) {
    if (event.kind != PointerDeviceKind.touch) return;
    _activeTouchPoints[event.pointer] = event.position;
    _startTouchPinchIfReady();
  }

  void _handleTouchPointerMove(PointerMoveEvent event) {
    if (event.kind != PointerDeviceKind.touch) return;
    if (!_activeTouchPoints.containsKey(event.pointer)) return;
    _activeTouchPoints[event.pointer] = event.position;
    _updateTouchPinchZoom();
  }

  void _handleTouchPointerUp(PointerUpEvent event) {
    if (event.kind != PointerDeviceKind.touch) return;
    _activeTouchPoints.remove(event.pointer);
    _resetTouchPinchIfNeeded();
  }

  void _handleTouchPointerCancel(PointerCancelEvent event) {
    if (event.kind != PointerDeviceKind.touch) return;
    _activeTouchPoints.remove(event.pointer);
    _resetTouchPinchIfNeeded();
  }

  void _startTouchPinchIfReady() {
    if (_activeTouchPoints.length != 2) return;
    _touchPinchBaseDistance = _currentTouchPinchDistance();
    _gestureBaseZoom = _horizontalZoom;
  }

  void _updateTouchPinchZoom() {
    if (_activeTouchPoints.length != 2) return;
    final baseDistance = _touchPinchBaseDistance;
    final currentDistance = _currentTouchPinchDistance();
    if (baseDistance == null || baseDistance <= 0 || currentDistance <= 0) {
      _startTouchPinchIfReady();
      return;
    }
    _setHorizontalZoom(_gestureBaseZoom * (currentDistance / baseDistance));
  }

  double _currentTouchPinchDistance() {
    if (_activeTouchPoints.length < 2) return 0;
    final points = _activeTouchPoints.values.take(2).toList();
    return (points[0] - points[1]).distance;
  }

  void _resetTouchPinchIfNeeded() {
    if (_activeTouchPoints.length >= 2) {
      _startTouchPinchIfReady();
      return;
    }
    _touchPinchBaseDistance = null;
  }

  bool _isZoomModifierPressed() {
    final keyboard = HardwareKeyboard.instance;
    return _usesMetaZoomModifier
        ? keyboard.isMetaPressed
        : keyboard.isControlPressed;
  }

  bool _isRawZoomModifierPressed(RawKeyEvent event) {
    if (_usesMetaZoomModifier) {
      return event.isMetaPressed;
    }
    return event.isControlPressed;
  }

  void _trackHardwareZoomModifier(KeyEvent event) {
    final key = event.logicalKey;
    final isDown = event is KeyDownEvent || event is KeyRepeatEvent;
    final isUp = event is KeyUpEvent;
    if (!isDown && !isUp) return;

    if (_isMetaKey(key)) {
      _rawMetaHeld = isDown;
    }
    if (_isControlKey(key)) {
      _rawControlHeld = isDown;
    }
  }

  void _trackRawZoomModifier(RawKeyEvent event) {
    final key = event.logicalKey;
    final isDown = event is RawKeyDownEvent;
    final isUp = event is RawKeyUpEvent;
    if (!isDown && !isUp) return;

    if (_isMetaKey(key)) {
      _rawMetaHeld = isDown;
    }
    if (_isControlKey(key)) {
      _rawControlHeld = isDown;
    }
  }

  void _syncZoomModifierFromHardwareKeyboard() {
    final pressed = HardwareKeyboard.instance.logicalKeysPressed;
    _rawMetaHeld = _rawMetaHeld || pressed.any(_isMetaKey);
    _rawControlHeld = _rawControlHeld || pressed.any(_isControlKey);
  }

  bool _isMetaKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.meta ||
        key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight;
  }

  bool _isControlKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.control ||
        key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight;
  }

  bool _isWheelZoomModifierPressed() {
    final keyboard = HardwareKeyboard.instance;
    if (_usesMetaZoomModifier) {
      return keyboard.isMetaPressed || _rawMetaHeld;
    }
    return keyboard.isControlPressed || _rawControlHeld;
  }

  bool get _usesMetaZoomModifier =>
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.iOS;

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Future<void> _deleteTaskAndRefresh(String taskId) async {
    await _dataSource.deleteTask(taskId);
    await _refreshTasksPreservingTimeline();
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Convert a date to Julian day number (accurate calendar calculation)
  int _toJulianDay(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
  }

  /// Get the actual number of days in a month
  int _daysInMonth(int year, int month) {
    // Use DateTime to get the last day of the month
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    return lastDayOfMonth.day;
  }

  /// Convert time to fraction of day (0.0 to 1.0)
  /// 00:00 = 0.0, 12:00 = 0.5, 23:59 = ~1.0
  double _timeToFraction(DateTime dateTime) {
    return (dateTime.hour * 60 + dateTime.minute) / (24 * 60);
  }

  Map<String, int> _calculateTaskLanes(
    List<TaskEntity> tasks, {
    DateTime? visibleStart,
    DateTime? visibleEnd,
  }) {
    final sortedTasks = [...tasks]
      ..sort((a, b) {
        final startCompare = a.startDate.compareTo(b.startDate);
        if (startCompare != 0) return startCompare;
        return a.endDate.compareTo(b.endDate);
      });

    final laneEnds = <DateTime>[];
    final lanes = <String, int>{};

    for (final task in sortedTasks) {
      final laneStart =
          visibleStart != null && task.startDate.isBefore(visibleStart)
          ? visibleStart
          : task.startDate;
      final laneEnd = visibleEnd != null && task.endDate.isAfter(visibleEnd)
          ? visibleEnd
          : task.endDate;

      if (!laneStart.isBefore(laneEnd)) continue;

      var laneIndex = laneEnds.indexWhere(
        (currentLaneEnd) => !laneStart.isBefore(currentLaneEnd),
      );
      if (laneIndex == -1) {
        laneIndex = laneEnds.length;
        laneEnds.add(laneEnd);
      } else {
        laneEnds[laneIndex] = laneEnd;
      }
      lanes[task.id] = laneIndex;
    }

    return lanes;
  }

  int _laneCount(Map<String, int> lanes) {
    if (lanes.isEmpty) return 1;
    return lanes.values.reduce((a, b) => a > b ? a : b) + 1;
  }
}
