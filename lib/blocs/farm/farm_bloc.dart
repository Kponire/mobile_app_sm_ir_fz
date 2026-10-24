import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:appwrite/appwrite.dart';
import '../../models/models.dart';
import '../../services/appwrite_service.dart';

// ─── Farm BLoC
abstract class FarmEvent extends Equatable {
  const FarmEvent();
  @override
  List<Object?> get props => [];
}

class FarmSetupRequested extends FarmEvent {
  final FarmModel farm;
  const FarmSetupRequested(this.farm);
  @override
  List<Object?> get props => [farm];
}

class FarmLoadRequested extends FarmEvent {
  final String userId;
  const FarmLoadRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}

abstract class FarmState extends Equatable {
  const FarmState();
  @override
  List<Object?> get props => [];
}

class FarmInitial extends FarmState {}

class FarmLoading extends FarmState {}

class FarmLoaded extends FarmState {
  final FarmModel farm;
  const FarmLoaded(this.farm);
  @override
  List<Object?> get props => [farm];
}

class FarmError extends FarmState {
  final String message;
  const FarmError(this.message);
  @override
  List<Object?> get props => [message];
}

class FarmBloc extends Bloc<FarmEvent, FarmState> {
  final FarmService _farmService;

  FarmBloc({required FarmService farmService})
    : _farmService = farmService,
      super(FarmInitial()) {
    on<FarmSetupRequested>(_onSetup);
    on<FarmLoadRequested>(_onLoad);
  }

  Future<void> _onSetup(
    FarmSetupRequested event,
    Emitter<FarmState> emit,
  ) async {
    emit(FarmLoading());
    try {
      final farm = await _farmService.createFarm(event.farm);
      emit(FarmLoaded(farm));
    } catch (e) {
      emit(FarmError(e.toString()));
    }
  }

  Future<void> _onLoad(FarmLoadRequested event, Emitter<FarmState> emit) async {
    emit(FarmLoading());
    try {
      final farm = await _farmService.getFarmByUser(event.userId);
      if (farm == null) {
        emit(FarmInitial());
      } else {
        emit(FarmLoaded(farm));
      }
    } catch (e) {
      emit(FarmError(e.toString()));
    }
  }
}

// Sensor BLoC
/* abstract class SensorEvent extends Equatable {
  const SensorEvent();
  @override
  List<Object?> get props => [];
}

class SensorSubscribeRequested extends SensorEvent {
  final String deviceId;
  const SensorSubscribeRequested(this.deviceId);
  @override
  List<Object?> get props => [deviceId];
}

class SensorDataReceived extends SensorEvent {
  final SensorData data;
  const SensorDataReceived(this.data);
  @override
  List<Object?> get props => [data];
}

class SensorUnsubscribeRequested extends SensorEvent {}

abstract class SensorState extends Equatable {
  const SensorState();
  @override
  List<Object?> get props => [];
}

class SensorInitial extends SensorState {}

class SensorLoading extends SensorState {}

class SensorLoaded extends SensorState {
  final SensorData data;
  const SensorLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class SensorError extends SensorState {
  final String message;
  const SensorError(this.message);
  @override
  List<Object?> get props => [message];
}

class SensorBloc extends Bloc<SensorEvent, SensorState> {
  final SensorService _sensorService;
  RealtimeSubscription? _subscription;

  SensorBloc({required SensorService sensorService})
    : _sensorService = sensorService,
      super(SensorInitial()) {
    on<SensorSubscribeRequested>(_onSubscribe);
    on<SensorDataReceived>(_onDataReceived);
    on<SensorUnsubscribeRequested>(_onUnsubscribe);
  }

  Future<void> _onSubscribe(
    SensorSubscribeRequested event,
    Emitter<SensorState> emit,
  ) async {
    emit(SensorLoading());
    try {
      final initial = await _sensorService.getLatestSensorData(event.deviceId);
      if (initial != null) emit(SensorLoaded(initial));

      _subscription = _sensorService.subscribeToSensorData(
        event.deviceId,
        (data) => add(SensorDataReceived(data)),
      );
    } catch (e) {
      emit(SensorError(e.toString()));
    }
  }

  void _onDataReceived(SensorDataReceived event, Emitter<SensorState> emit) {
    emit(SensorLoaded(event.data));
  }

  Future<void> _onUnsubscribe(
    SensorUnsubscribeRequested event,
    Emitter<SensorState> emit,
  ) async {
    await _subscription?.close();
    _subscription = null;
  }

  @override
  Future<void> close() async {
    await _subscription?.close();
    return super.close();
  }
} */

// Control BLoC
abstract class ControlEvent extends Equatable {
  const ControlEvent();
  @override
  List<Object?> get props => [];
}

class ControlPumpToggle extends ControlEvent {
  final String deviceId;
  final bool turnOn;
  const ControlPumpToggle({required this.deviceId, required this.turnOn});
  @override
  List<Object?> get props => [deviceId, turnOn];
}

class ControlZoneToggle extends ControlEvent {
  final String deviceId;
  final String zone;
  final bool turnOn;
  const ControlZoneToggle({
    required this.deviceId,
    required this.zone,
    required this.turnOn,
  });
  @override
  List<Object?> get props => [deviceId, zone, turnOn];
}

class ControlStartIrrigation extends ControlEvent {
  final String deviceId;
  final int durationMinutes;
  const ControlStartIrrigation({
    required this.deviceId,
    required this.durationMinutes,
  });
  @override
  List<Object?> get props => [deviceId, durationMinutes];
}

class ControlStopIrrigation extends ControlEvent {
  final String deviceId;
  const ControlStopIrrigation(this.deviceId);
  @override
  List<Object?> get props => [deviceId];
}

class ControlStartFertigation extends ControlEvent {
  final String deviceId;
  final int durationMinutes;
  const ControlStartFertigation({
    required this.deviceId,
    required this.durationMinutes,
  });
  @override
  List<Object?> get props => [deviceId, durationMinutes];
}

class ControlStopFertigation extends ControlEvent {
  final String deviceId;
  const ControlStopFertigation(this.deviceId);
  @override
  List<Object?> get props => [deviceId];
}

class ControlModeChanged extends ControlEvent {
  final String deviceId;
  final String mode;
  const ControlModeChanged({required this.deviceId, required this.mode});
  @override
  List<Object?> get props => [deviceId, mode];
}

abstract class ControlState extends Equatable {
  const ControlState();
  @override
  List<Object?> get props => [];
}

class ControlIdle extends ControlState {}

class ControlProcessing extends ControlState {}

class ControlSuccess extends ControlState {
  final String message;
  const ControlSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ControlError extends ControlState {
  final String message;
  const ControlError(this.message);
  @override
  List<Object?> get props => [message];
}

class ControlBloc extends Bloc<ControlEvent, ControlState> {
  final SensorService _sensorService;

  ControlBloc({required SensorService sensorService})
    : _sensorService = sensorService,
      super(ControlIdle()) {
    on<ControlPumpToggle>(_onPumpToggle);
    on<ControlZoneToggle>(_onZoneToggle);
    on<ControlStartIrrigation>(_onStartIrrigation);
    on<ControlStopIrrigation>(_onStopIrrigation);
    on<ControlStartFertigation>(_onStartFertigation);
    on<ControlStopFertigation>(_onStopFertigation);
    on<ControlModeChanged>(_onModeChanged);
  }

  Future<void> _onPumpToggle(
    ControlPumpToggle event,
    Emitter<ControlState> emit,
  ) async {
    emit(ControlProcessing());
    try {
      await _sensorService.sendCommand(event.deviceId, {
        'command': 'PUMP',
        'state': event.turnOn ? 'ON' : 'OFF',
      });
      emit(
        ControlSuccess(
          'Pump ${event.turnOn ? 'started' : 'stopped'} successfully',
        ),
      );
    } catch (e) {
      emit(ControlError('Failed to control pump'));
    }
  }

  Future<void> _onZoneToggle(
    ControlZoneToggle event,
    Emitter<ControlState> emit,
  ) async {
    emit(ControlProcessing());
    try {
      await _sensorService.sendCommand(event.deviceId, {
        'command': 'ZONE',
        'zone': event.zone,
        'state': event.turnOn ? 'ON' : 'OFF',
      });
      emit(
        ControlSuccess(
          'Zone ${event.zone} ${event.turnOn ? 'activated' : 'deactivated'}',
        ),
      );
    } catch (e) {
      emit(ControlError('Failed to control zone'));
    }
  }

  Future<void> _onStartIrrigation(
    ControlStartIrrigation event,
    Emitter<ControlState> emit,
  ) async {
    emit(ControlProcessing());
    try {
      await _sensorService.sendCommand(event.deviceId, {
        'command': 'START_IRRIGATION',
        'duration': event.durationMinutes,
      });
      emit(
        ControlSuccess('Irrigation started for ${event.durationMinutes} mins'),
      );
    } catch (e) {
      emit(ControlError('Failed to start irrigation'));
    }
  }

  Future<void> _onStopIrrigation(
    ControlStopIrrigation event,
    Emitter<ControlState> emit,
  ) async {
    emit(ControlProcessing());
    try {
      await _sensorService.sendCommand(event.deviceId, {
        'command': 'STOP_IRRIGATION',
      });
      emit(ControlSuccess('Irrigation stopped'));
    } catch (e) {
      emit(ControlError('Failed to stop irrigation'));
    }
  }

  Future<void> _onStartFertigation(
    ControlStartFertigation event,
    Emitter<ControlState> emit,
  ) async {
    emit(ControlProcessing());
    try {
      await _sensorService.sendCommand(event.deviceId, {
        'command': 'START_FERTIGATION',
        'duration': event.durationMinutes,
      });
      emit(
        ControlSuccess('Fertigation started for ${event.durationMinutes} mins'),
      );
    } catch (e) {
      emit(ControlError('Failed to start fertigation'));
    }
  }

  Future<void> _onStopFertigation(
    ControlStopFertigation event,
    Emitter<ControlState> emit,
  ) async {
    emit(ControlProcessing());
    try {
      await _sensorService.sendCommand(event.deviceId, {
        'command': 'STOP_FERTIGATION',
      });
      emit(ControlSuccess('Fertigation stopped'));
    } catch (e) {
      emit(ControlError('Failed to stop fertigation'));
    }
  }

  Future<void> _onModeChanged(
    ControlModeChanged event,
    Emitter<ControlState> emit,
  ) async {
    emit(ControlProcessing());
    try {
      await _sensorService.sendCommand(event.deviceId, {
        'command': 'SET_MODE',
        'mode': event.mode,
      });
      emit(ControlSuccess('Mode changed to ${event.mode}'));
    } catch (e) {
      emit(ControlError('Failed to change mode'));
    }
  }
}
