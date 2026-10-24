// blocs/sensor/sensor_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/mqtt_service.dart';
import '../../models/sensor_data.dart';

abstract class SensorEvent {}

class ConnectMqtt extends SensorEvent {}

class SensorUpdated extends SensorEvent {
  final SensorData data;
  SensorUpdated(this.data);
}

class SensorState {
  final SensorData? data;
  final bool isConnected;

  SensorState({this.data, this.isConnected = false});

  SensorState copyWith({SensorData? data, bool? isConnected}) {
    return SensorState(
      data: data ?? this.data,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class SensorBloc extends Bloc<SensorEvent, SensorState> {
  final MqttService mqtt;
  static const String host =
      "78fe25d6cc1b42fc9b1e0c849b0236bf.s1.eu.hivemq.cloud";
  static const int port = 8883;
  static const String username = "oluwaponire";
  static const String password = "Oluwaponire1234#";

  SensorBloc(this.mqtt) : super(SensorState()) {
    on<ConnectMqtt>((event, emit) async {
      await mqtt.connect(
        host: SensorBloc.host,
        port: SensorBloc.port,
        username: SensorBloc.username,
        password: SensorBloc.password,
        topic: 'farm/sensors/reading',
        onData: (data) {
          add(SensorUpdated(SensorData.fromJson(data)));
        },
      );

      emit(state.copyWith(isConnected: true));
    });

    on<SensorUpdated>((event, emit) {
      emit(state.copyWith(data: event.data));
    });
  }
}
