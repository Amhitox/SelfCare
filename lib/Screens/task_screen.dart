import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:selfcare/Models/task.dart';
import 'package:selfcare/Screens/add_task_screen.dart';
import 'package:selfcare/Services/ads_service.dart';
import 'package:selfcare/Widgets/ad_widgets.dart';
import 'package:selfcare/Widgets/state_widgets.dart';
import 'package:selfcare/providers/tasks_provider.dart';
import 'package:selfcare/utils/constants/colors.dart';
import 'package:selfcare/utils/constants/strings.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  String? _filterCategory;
  String? _filterPriority;
  // Status filter values: 'all', 'open', 'completed'
  String _statusFilter = 'all';

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<Task> _applyFilters(List<Task> tasks) {
    return tasks.where((t) {
      if (_filterCategory != null && t.category != _filterCategory) {
        return false;
      }
      if (_filterPriority != null && t.priority != _filterPriority) {
        return false;
      }
      if (_statusFilter == 'open' && t.isCompleted) return false;
      if (_statusFilter == 'completed' && !t.isCompleted) return false;
      return true;
    }).toList();
  }

  List<Task> _todayList(List<Task> tasks) {
    final now = DateTime.now();
    final list = tasks.where((t) => _sameDay(t.dueDate, now)).toList();
    list.sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      return a.dueDateTime.compareTo(b.dueDateTime);
    });
    return list;
  }

  List<Task> _upcomingList(List<Task> tasks) {
    final now = DateTime.now();
    final list = tasks
        .where((t) =>
            !t.isCompleted &&
            !_sameDay(t.dueDate, now) &&
            t.dueDateTime.isAfter(now))
        .toList();
    list.sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));
    return list;
  }

  List<Task> _completedList(List<Task> tasks) {
    final list = tasks.where((t) => t.isCompleted).toList();
    list.sort((a, b) =>
        (b.completedAt ?? b.dueDateTime).compareTo(a.completedAt ?? a.dueDateTime));
    return list;
  }

  Future<void> _openFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Filters',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Category',
                      style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _FilterChipTile(
                          label: 'All',
                          selected: _filterCategory == null,
                          onTap: () {
                            setSheetState(() => _filterCategory = null);
                            setState(() {});
                          },
                        ),
                        for (final c in AppConsts.taskCategories)
                          _FilterChipTile(
                            label: c,
                            selected: _filterCategory == c,
                            onTap: () {
                              setSheetState(() => _filterCategory = c);
                              setState(() {});
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Priority',
                      style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _FilterChipTile(
                          label: 'All',
                          selected: _filterPriority == null,
                          onTap: () {
                            setSheetState(() => _filterPriority = null);
                            setState(() {});
                          },
                        ),
                        for (final p in AppConsts.taskPriorities)
                          _FilterChipTile(
                            label: p,
                            selected: _filterPriority == p,
                            onTap: () {
                              setSheetState(() => _filterPriority = p);
                              setState(() {});
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Status',
                      style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _FilterChipTile(
                          label: 'All',
                          selected: _statusFilter == 'all',
                          onTap: () {
                            setSheetState(() => _statusFilter = 'all');
                            setState(() {});
                          },
                        ),
                        _FilterChipTile(
                          label: 'Open',
                          selected: _statusFilter == 'open',
                          onTap: () {
                            setSheetState(() => _statusFilter = 'open');
                            setState(() {});
                          },
                        ),
                        _FilterChipTile(
                          label: 'Completed',
                          selected: _statusFilter == 'completed',
                          onTap: () {
                            setSheetState(() => _statusFilter = 'completed');
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setSheetState(() {
                                _filterCategory = null;
                                _filterPriority = null;
                                _statusFilter = 'all';
                              });
                              setState(() {});
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: BorderSide(color: Theme.of(context).dividerColor),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Clear'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openAddTask({Task? existing}) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(existing: existing),
      ),
    );
    if (!mounted) return;
    if (ok == true) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
            content: Text(existing == null ? 'Task added' : 'Task updated'),
          ),
        );
    }
  }

  Future<void> _confirmDelete(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Delete task?'),
        content: Text('"${task.title}" will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(tasksProvider.notifier).delete(task);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
            content: const Text('Task deleted'),
          ),
        );
    }
  }

  Future<void> _toggleTask(Task task) async {
    final updated = await ref.read(tasksProvider.notifier).toggleComplete(task);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: updated.isCompleted
              ? AppColors.success
              : AppColors.textSecondary,
          content: Text(
            updated.isCompleted ? 'Task completed' : 'Task marked active',
          ),
        ),
      );
    if (updated.isCompleted) {
      AdsService.instance.maybeShowInterstitial();
    }
  }

  bool get _hasActiveFilters =>
      _filterCategory != null ||
      _filterPriority != null ||
      _statusFilter != 'all';

  Widget _buildList(List<Task> tasks, String emptyTitle, String emptyMessage) {
    if (tasks.isEmpty) {
      return EmptyState(
        icon: Icons.task_alt_rounded,
        title: emptyTitle,
        message: emptyMessage,
        actionLabel: 'Add task',
        onAction: () => _openAddTask(),
      );
    }
    final items = <Widget>[];
    for (var i = 0; i < tasks.length; i++) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _TaskTile(
            task: tasks[i],
            onToggle: () => _toggleTask(tasks[i]),
            onEdit: () => _openAddTask(existing: tasks[i]),
            onDelete: () => _confirmDelete(tasks[i]),
          ),
        ),
      );
      final nextIndex = i + 1;
      if (nextIndex % 6 == 0 && nextIndex < tasks.length) {
        items.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: NativeAdCard(),
          ),
        );
      }
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
      physics: const AlwaysScrollableScrollPhysics(),
      children: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(tasksProvider);
    final filtered = _applyFilters(allTasks);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Tasks',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: _openFilters,
                  icon: const Icon(Icons.tune_rounded),
                ),
                if (_hasActiveFilters)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 4),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(54),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    gradient: AppColors.pinkGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  indicatorPadding: const EdgeInsets.all(4),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  tabs: const [
                    Tab(text: 'Today'),
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Completed'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(
              _todayList(filtered),
              'No tasks today',
              'Plan your day by adding your first task.',
            ),
            _buildList(
              _upcomingList(filtered),
              'No upcoming tasks',
              'Future tasks will show here as you create them.',
            ),
            _buildList(
              _completedList(filtered),
              'Nothing completed yet',
              'Tick off tasks and they will appear here.',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          onPressed: () => _openAddTask(),
          icon: const Icon(Icons.add),
          label: const Text(
            'New task',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskTile({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  Color _priorityColor() {
    switch (task.priority) {
      case 'High':
        return AppColors.accent;
      case 'Medium':
        return AppColors.warning;
      case 'Low':
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onEdit,
        onLongPress: onDelete,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onToggle,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? AppColors.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted
                            ? AppColors.primary
                            : Theme.of(context).dividerColor,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style:
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: AppColors.textMuted,
                              ),
                    ),
                    if ((task.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _CategoryChip(label: task.category),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: priorityColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.priority,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule,
                                size: 13, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              task.formattedTime,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'More',
                icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (ctx) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline,
                          color: AppColors.error),
                      title: Text(
                        'Delete',
                        style: TextStyle(color: AppColors.error),
                      ),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _FilterChipTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
