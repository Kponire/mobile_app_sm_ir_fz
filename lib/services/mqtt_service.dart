// services/mqtt_service.dart
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient client;

  Future<void> connect({
    required String host,
    required int port,
    required String username,
    required String password,
    required String topic,
    required Function(Map<String, dynamic>) onData,
  }) async {
    client = MqttServerClient(host, '');
    client.port = port;
    client.secure = true;
    client.logging(on: false);

    client.onConnected = () => print('MQTT Connected');
    client.onDisconnected = () => print('MQTT Disconnected');

    final connMess = MqttConnectMessage()
        .withClientIdentifier(
          'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
        )
        .startClean()
        .authenticateAs(username, password);

    client.connectionMessage = connMess;

    try {
      await client.connect();
    } catch (e) {
      print('Connection error: $e');
      client.disconnect();
      return;
    }

    client.subscribe(topic, MqttQos.atLeastOnce);

    client.updates!.listen((events) {
      final recMess = events[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );

      try {
        final data = jsonDecode(payload);
        onData(data);
      } catch (e) {
        print('Invalid JSON: $payload');
      }
    });
  }

  void publish(String topic, Map<String, dynamic> data) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode(data));
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void disconnect() {
    client.disconnect();
  }
}
