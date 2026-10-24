import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/models.dart';
import '../../services/appwrite_service.dart';

// Schedule BLoC
abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();
  @override
  List<Object?> get props => [];
}

class ScheduleLoadRequested extends ScheduleEvent {
  final String farmId;
  const ScheduleLoadRequested(this.farmId);
  @override
  List<Object?> get props => [farmId];
}

class ScheduleAddRequested extends ScheduleEvent {
  final ScheduleModel schedule;
  final String farmId;
  const ScheduleAddRequested({required this.schedule, required this.farmId});
  @override
  List<Object?> get props => [schedule, farmId];
}

class ScheduleToggleRequested extends ScheduleEvent {
  final String scheduleId;
  final bool isEnabled;
  const ScheduleToggleRequested({
    required this.scheduleId,
    required this.isEnabled,
  });
  @override
  List<Object?> get props => [scheduleId, isEnabled];
}

class ScheduleDeleteRequested extends ScheduleEvent {
  final String scheduleId;
  const ScheduleDeleteRequested(this.scheduleId);
  @override
  List<Object?> get props => [scheduleId];
}

abstract class ScheduleState extends Equatable {
  const ScheduleState();
  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<ScheduleModel> schedules;
  const ScheduleLoaded(this.schedules);
  @override
  List<Object?> get props => [schedules];
}

class ScheduleError extends ScheduleState {
  final String message;
  const ScheduleError(this.message);
  @override
  List<Object?> get props => [message];
}

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleService _scheduleService;
  String? _currentFarmId;

  ScheduleBloc({required ScheduleService scheduleService})
    : _scheduleService = scheduleService,
      super(ScheduleInitial()) {
    on<ScheduleLoadRequested>(_onLoad);
    on<ScheduleAddRequested>(_onAdd);
    on<ScheduleToggleRequested>(_onToggle);
    on<ScheduleDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(
    ScheduleLoadRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    _currentFarmId = event.farmId;
    emit(ScheduleLoading());
    try {
      final schedules = await _scheduleService.getSchedules(event.farmId);
      emit(ScheduleLoaded(schedules));
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  Future<void> _onAdd(
    ScheduleAddRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      final created = await _scheduleService.createSchedule(
        event.schedule,
        event.farmId,
      );
      final current = state is ScheduleLoaded
          ? (state as ScheduleLoaded).schedules
          : <ScheduleModel>[];
      emit(ScheduleLoaded([...current, created]));
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  Future<void> _onToggle(
    ScheduleToggleRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    if (state is! ScheduleLoaded) return;
    try {
      await _scheduleService.updateSchedule(event.scheduleId, {
        'isEnabled': event.isEnabled,
      });
      final current = (state as ScheduleLoaded).schedules;
      final updated = current.map((s) {
        if (s.id == event.scheduleId)
          return s.copyWith(isEnabled: event.isEnabled);
        return s;
      }).toList();
      emit(ScheduleLoaded(updated));
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  Future<void> _onDelete(
    ScheduleDeleteRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    if (state is! ScheduleLoaded) return;
    try {
      await _scheduleService.deleteSchedule(event.scheduleId);
      final current = (state as ScheduleLoaded).schedules;
      emit(
        ScheduleLoaded(current.where((s) => s.id != event.scheduleId).toList()),
      );
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }
}

// ─── Notification BLoC
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class NotificationLoadRequested extends NotificationEvent {
  final String userId;
  const NotificationLoadRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}

class NotificationMarkReadRequested extends NotificationEvent {
  final String notificationId;
  const NotificationMarkReadRequested(this.notificationId);
  @override
  List<Object?> get props => [notificationId];
}

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  const NotificationLoaded(this.notifications);
  @override
  List<Object?> get props => [notifications];
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
  @override
  List<Object?> get props => [message];
}

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService _notificationService;

  NotificationBloc({required NotificationService notificationService})
    : _notificationService = notificationService,
      super(NotificationInitial()) {
    on<NotificationLoadRequested>(_onLoad);
    on<NotificationMarkReadRequested>(_onMarkRead);
  }

  Future<void> _onLoad(
    NotificationLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final notifications = await _notificationService.getNotifications(
        event.userId,
      );
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkRead(
    NotificationMarkReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is! NotificationLoaded) return;
    try {
      await _notificationService.markAsRead(event.notificationId);
      final current = (state as NotificationLoaded).notifications;
      final updated = current.map((n) {
        if (n.id == event.notificationId) return n.copyWith(isRead: true);
        return n;
      }).toList();
      emit(NotificationLoaded(updated));
    } catch (e) {
      // silently fail
    }
  }
}

// Automation BLoC
abstract class AutomationEvent extends Equatable {
  const AutomationEvent();
  @override
  List<Object?> get props => [];
}

class AutomationLoadRequested extends AutomationEvent {
  final String farmId;
  const AutomationLoadRequested(this.farmId);
  @override
  List<Object?> get props => [farmId];
}

class AutomationSaveRequested extends AutomationEvent {
  final String farmId;
  final AutomationSettings settings;
  const AutomationSaveRequested({required this.farmId, required this.settings});
  @override
  List<Object?> get props => [farmId, settings];
}

class AutomationSettingChanged extends AutomationEvent {
  final AutomationSettings settings;
  const AutomationSettingChanged(this.settings);
  @override
  List<Object?> get props => [settings];
}

abstract class AutomationState extends Equatable {
  const AutomationState();
  @override
  List<Object?> get props => [];
}

class AutomationInitial extends AutomationState {}

class AutomationLoading extends AutomationState {}

class AutomationLoaded extends AutomationState {
  final AutomationSettings settings;
  const AutomationLoaded(this.settings);
  @override
  List<Object?> get props => [settings];
}

class AutomationSaved extends AutomationState {
  final AutomationSettings settings;
  const AutomationSaved(this.settings);
  @override
  List<Object?> get props => [settings];
}

class AutomationError extends AutomationState {
  final String message;
  const AutomationError(this.message);
  @override
  List<Object?> get props => [message];
}

class AutomationBloc extends Bloc<AutomationEvent, AutomationState> {
  final AutomationServiceBackend _automationService;

  AutomationBloc({required AutomationServiceBackend automationService})
    : _automationService = automationService,
      super(AutomationInitial()) {
    on<AutomationLoadRequested>(_onLoad);
    on<AutomationSaveRequested>(_onSave);
    on<AutomationSettingChanged>(_onChanged);
  }

  Future<void> _onLoad(
    AutomationLoadRequested event,
    Emitter<AutomationState> emit,
  ) async {
    emit(AutomationLoading());
    try {
      final settings = await _automationService.getSettings(event.farmId);
      emit(AutomationLoaded(settings));
    } catch (e) {
      emit(const AutomationLoaded(AutomationSettings()));
    }
  }

  void _onChanged(
    AutomationSettingChanged event,
    Emitter<AutomationState> emit,
  ) {
    emit(AutomationLoaded(event.settings));
  }

  Future<void> _onSave(
    AutomationSaveRequested event,
    Emitter<AutomationState> emit,
  ) async {
    emit(AutomationLoading());
    try {
      await _automationService.saveSettings(event.farmId, event.settings);
      emit(AutomationSaved(event.settings));
    } catch (e) {
      print(e);
      emit(AutomationError('Failed to save settings'));
    }
  }
}
