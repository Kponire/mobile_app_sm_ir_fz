import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../constants/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/schedule/schedule_bloc.dart';
import '../../models/models.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated && auth.farm != null) {
      context.read<ScheduleBloc>().add(ScheduleLoadRequested(auth.farm!.id));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddSchedule() {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated || auth.farm == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.xl),
        ),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ScheduleBloc>(),
        child: _AddScheduleSheet(farmId: auth.farm!.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppMainBar(
        title: 'Irrigation Schedule',
        showBack: true,
        actions: [
          IconButton(
            onPressed: _showAddSchedule,
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      body: BlocListener<ScheduleBloc, ScheduleState>(
        listener: (context, state) {
          if (state is ScheduleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceBg,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    border: Border.all(color: AppColors.primary),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textMuted,
                  labelStyle: AppTextStyles.labelLarge,
                  tabs: const [
                    Tab(text: '🌱 Irrigation'),
                    Tab(text: '🌿 Fertigation'),
                  ],
                ),
              ),
            ),

            Expanded(
              child: BlocBuilder<ScheduleBloc, ScheduleState>(
                builder: (context, state) {
                  if (state is ScheduleLoading) {
                    return const LoadingWidget(message: 'Loading schedules...');
                  }

                  final schedules = state is ScheduleLoaded
                      ? state.schedules
                      : <ScheduleModel>[];
                  final irrigation = schedules
                      .where((s) => s.type == 'irrigation')
                      .toList();
                  final fertigation = schedules
                      .where((s) => s.type == 'fertigation')
                      .toList();

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _ScheduleList(
                        schedules: irrigation,
                        emptyMessage: 'No irrigation schedules yet',
                        emptyIcon: Icons.water_drop_outlined,
                        onAdd: _showAddSchedule,
                      ),
                      _ScheduleList(
                        schedules: fertigation,
                        emptyMessage: 'No fertigation schedules yet',
                        emptyIcon: Icons.eco_outlined,
                        onAdd: _showAddSchedule,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSchedule,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Add Schedule',
          style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _ScheduleList extends StatelessWidget {
  final List<ScheduleModel> schedules;
  final String emptyMessage;
  final IconData emptyIcon;
  final VoidCallback onAdd;

  const _ScheduleList({
    required this.schedules,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 56, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text(emptyMessage, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Add Schedule',
              icon: Icons.add_rounded,
              onPressed: onAdd,
              width: 180,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: schedules.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => _ScheduleCard(schedule: schedules[i]),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;

  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final color = schedule.type == 'irrigation'
        ? AppColors.primary
        : AppColors.primaryLight;

    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            /*  decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ), */
            child: Icon(
              schedule.type == 'irrigation'
                  ? Icons.water_drop_rounded
                  : Icons.eco_rounded,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      schedule.zone != null
                          ? 'Zone ${schedule.zone}'
                          : schedule.type == 'fertigation'
                          ? 'Fertigation'
                          : 'All Zones',
                      style: AppTextStyles.headlineSmall,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    StatusBadge(
                      label: schedule.isEnabled ? 'Active' : 'Off',
                      color: schedule.isEnabled
                          ? AppColors.success
                          : AppColors.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${schedule.startTime} · ${schedule.durationMinutes} min · ${schedule.days.join(', ')}',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),

          Column(
            children: [
              Switch(
                value: schedule.isEnabled,
                onChanged: (v) {
                  context.read<ScheduleBloc>().add(
                    ScheduleToggleRequested(
                      scheduleId: schedule.id,
                      isEnabled: v,
                    ),
                  );
                },
              ),
              GestureDetector(
                onTap: () {
                  context.read<ScheduleBloc>().add(
                    ScheduleDeleteRequested(schedule.id),
                  );
                },
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddScheduleSheet extends StatefulWidget {
  final String farmId;
  const _AddScheduleSheet({required this.farmId});

  @override
  State<_AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends State<_AddScheduleSheet> {
  String _type = 'irrigation';
  String? _zone;
  final _days = <String>[];
  String _startTime = '06:00';
  int _duration = 15;

  final _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final _zones = ['A', 'B', 'C'];

  Future<void> _pickTime() async {
    final parts = _startTime.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 6,
        minute: int.tryParse(parts[1]) ?? 0,
      ),
    );
    if (picked != null) {
      setState(() {
        _startTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _save() {
    if (_days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final schedule = ScheduleModel(
      id: const Uuid().v4(),
      type: _type,
      zone: _type == 'irrigation' ? _zone : null,
      days: _days,
      startTime: _startTime,
      durationMinutes: _duration,
      isEnabled: true,
    );

    context.read<ScheduleBloc>().add(
      ScheduleAddRequested(schedule: schedule, farmId: widget.farmId),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add New Schedule', style: AppTextStyles.headlineLarge),

          const SizedBox(height: AppSpacing.lg),

          // Type selector
          Text('Type', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _TypeChip(
                  label: '🌱 Irrigation',
                  selected: _type == 'irrigation',
                  onTap: () => setState(() => _type = 'irrigation'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _TypeChip(
                  label: '🌿 Fertigation',
                  selected: _type == 'fertigation',
                  onTap: () => setState(() => _type = 'fertigation'),
                ),
              ),
            ],
          ),

          if (_type == 'irrigation') ...[
            const SizedBox(height: AppSpacing.md),
            Text('Zone', style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: _zones
                  .map(
                    (z) => Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: _TypeChip(
                        label: 'Zone $z',
                        selected: _zone == z,
                        onTap: () => setState(() => _zone = z),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // Days
          Text('Days', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            children: _allDays
                .map(
                  (d) => GestureDetector(
                    onTap: () => setState(() {
                      if (_days.contains(d)) {
                        _days.remove(d);
                      } else {
                        _days.add(d);
                      }
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: _days.contains(d)
                            ? AppColors.primary.withOpacity(0.15)
                            : AppColors.surfaceBg,
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                        border: Border.all(
                          color: _days.contains(d)
                              ? AppColors.primary
                              : AppColors.borderColor,
                        ),
                      ),
                      child: Text(
                        d,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: _days.contains(d)
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: AppSpacing.md),

          // Time + Duration row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Start Time', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                    GestureDetector(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceBg,
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.sm,
                          ),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _startTime,
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Duration', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBg,
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => setState(
                              () => _duration = (_duration - 5).clamp(5, 60),
                            ),
                            icon: const Icon(Icons.remove, size: 16),
                          ),
                          Expanded(
                            child: Text(
                              '$_duration min',
                              style: AppTextStyles.labelLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(
                              () => _duration = (_duration + 5).clamp(5, 60),
                            ),
                            icon: const Icon(Icons.add, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          PrimaryButton(
            label: 'Save Schedule',
            icon: Icons.save_rounded,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surfaceBg,
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
