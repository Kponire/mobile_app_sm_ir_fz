// ─── User Model
class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatarUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['\$id'] ?? '',
    fullName: map['fullName'] ?? '',
    email: map['email'] ?? '',
    phone: map['phone'],
    avatarUrl: map['avatarUrl'],
  );

  Map<String, dynamic> toMap() => {
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'avatarUrl': avatarUrl,
  };

  UserModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? avatarUrl,
  }) => UserModel(
    id: id,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    avatarUrl: avatarUrl ?? this.avatarUrl,
  );
}

// ─── Farm Model
class FarmModel {
  final String id;
  final String name;
  final String location;
  final String deviceId;
  final int zonesCount;
  final String waterSource;
  final String userId;

  const FarmModel({
    required this.id,
    required this.name,
    required this.location,
    required this.deviceId,
    required this.zonesCount,
    required this.waterSource,
    required this.userId,
  });

  factory FarmModel.fromMap(Map<String, dynamic> map) => FarmModel(
    id: map['\$id'] ?? '',
    name: map['name'] ?? '',
    location: map['location'] ?? '',
    deviceId: map['deviceId'] ?? '',
    zonesCount: map['zonesCount'] ?? 3,
    waterSource: map['waterSource'] ?? 'Tank',
    userId: map['userId'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'location': location,
    'deviceId': deviceId,
    'zonesCount': zonesCount,
    'waterSource': waterSource,
    'userId': userId,
  };
}

// ─── Sensor Data
class SensorData {
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final double tankLevel;
  final bool pumpStatus;
  final bool systemOnline;
  final String currentMode;
  final String activeOperation;
  final DateTime lastUpdated;

  const SensorData({
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.tankLevel,
    required this.pumpStatus,
    required this.systemOnline,
    required this.currentMode,
    required this.activeOperation,
    required this.lastUpdated,
  });

  factory SensorData.fromMap(Map<String, dynamic> map) => SensorData(
    soilMoisture: (map['soilMoisture'] ?? 0.0).toDouble(),
    temperature: (map['temperature'] ?? 0.0).toDouble(),
    humidity: (map['humidity'] ?? 0.0).toDouble(),
    tankLevel: (map['tankLevel'] ?? 0.0).toDouble(),
    pumpStatus: map['pumpStatus'] ?? false,
    systemOnline: map['systemOnline'] ?? false,
    currentMode: map['currentMode'] ?? 'Manual',
    activeOperation: map['activeOperation'] ?? 'Idle',
    lastUpdated: DateTime.tryParse(map['lastUpdated'] ?? '') ?? DateTime.now(),
  );

  factory SensorData.empty() => SensorData(
    soilMoisture: 0,
    temperature: 0,
    humidity: 0,
    tankLevel: 0,
    pumpStatus: false,
    systemOnline: false,
    currentMode: 'Manual',
    activeOperation: 'Idle',
    lastUpdated: DateTime.now(),
  );

  SensorData copyWith({
    double? soilMoisture,
    double? temperature,
    double? humidity,
    double? tankLevel,
    bool? pumpStatus,
    bool? systemOnline,
    String? currentMode,
    String? activeOperation,
    DateTime? lastUpdated,
  }) => SensorData(
    soilMoisture: soilMoisture ?? this.soilMoisture,
    temperature: temperature ?? this.temperature,
    humidity: humidity ?? this.humidity,
    tankLevel: tankLevel ?? this.tankLevel,
    pumpStatus: pumpStatus ?? this.pumpStatus,
    systemOnline: systemOnline ?? this.systemOnline,
    currentMode: currentMode ?? this.currentMode,
    activeOperation: activeOperation ?? this.activeOperation,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
}

// ─── Zone Model
class ZoneModel {
  final String id;
  final String name;
  final bool isActive;
  final String type; // 'irrigation' | 'fertigation'

  const ZoneModel({
    required this.id,
    required this.name,
    required this.isActive,
    required this.type,
  });

  ZoneModel copyWith({bool? isActive}) => ZoneModel(
    id: id,
    name: name,
    isActive: isActive ?? this.isActive,
    type: type,
  );
}

// Schedule Model
class ScheduleModel {
  final String id;
  final String type; // 'irrigation' | 'fertigation'
  final String? zone;
  final List<String> days;
  final String startTime;
  final int durationMinutes;
  final bool isEnabled;

  const ScheduleModel({
    required this.id,
    required this.type,
    this.zone,
    required this.days,
    required this.startTime,
    required this.durationMinutes,
    required this.isEnabled,
  });

  factory ScheduleModel.fromMap(Map<String, dynamic> map) => ScheduleModel(
    id: map['\$id'] ?? '',
    type: map['type'] ?? 'irrigation',
    zone: map['zone'],
    days: List<String>.from(map['days'] ?? []),
    startTime: map['startTime'] ?? '06:00',
    durationMinutes: map['durationMinutes'] ?? 15,
    isEnabled: map['isEnabled'] ?? true,
  );

  Map<String, dynamic> toMap() => {
    'type': type,
    'zone': zone,
    'days': days,
    'startTime': startTime,
    'durationMinutes': durationMinutes,
    'isEnabled': isEnabled,
  };

  ScheduleModel copyWith({bool? isEnabled}) => ScheduleModel(
    id: id,
    type: type,
    zone: zone,
    days: days,
    startTime: startTime,
    durationMinutes: durationMinutes,
    isEnabled: isEnabled ?? this.isEnabled,
  );
}

// Notification Model
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String category; // 'critical' | 'warning' | 'info' | 'success'
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) =>
      NotificationModel(
        id: map['\$id'] ?? '',
        title: map['title'] ?? '',
        body: map['body'] ?? '',
        category: map['category'] ?? 'info',
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        isRead: map['isRead'] ?? false,
      );

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id: id,
    title: title,
    body: body,
    category: category,
    createdAt: createdAt,
    isRead: isRead ?? this.isRead,
  );
}

// Device Model
class DeviceModel {
  final String id;
  final String deviceId;
  final String name;
  final bool isOnline;
  final String firmwareVersion;
  final DateTime? lastSeen;
  final String? wifiName;
  final int? signalStrength;

  const DeviceModel({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.isOnline,
    required this.firmwareVersion,
    this.lastSeen,
    this.wifiName,
    this.signalStrength,
  });

  factory DeviceModel.fromMap(Map<String, dynamic> map) => DeviceModel(
    id: map['\$id'] ?? '',
    deviceId: map['deviceId'] ?? '',
    name: map['name'] ?? 'ESP8266 Controller',
    isOnline: map['isOnline'] ?? false,
    firmwareVersion: map['firmwareVersion'] ?? '1.0.0',
    lastSeen: DateTime.tryParse(map['lastSeen'] ?? ''),
    wifiName: map['wifiName'],
    signalStrength: map['signalStrength'],
  );
}

// ─── Automation Settings
class AutomationSettings {
  final double moistureThreshold;
  final int maxIrrigationTime;
  final int minTimeBetweenIrrigation;
  final bool fertigationEnabled;
  final int fertigationIntervalDays;
  final int fertigationDuration;
  final bool stopOnRain;
  final bool reduceOnHighHumidity;
  final bool increaseOnHighTemp;
  final String irrigationWindowStart;
  final String irrigationWindowEnd;
  final String fertigationWindowStart;
  final String fertigationWindowEnd;
  final String farmId;

  const AutomationSettings({
    this.moistureThreshold = 40,
    this.maxIrrigationTime = 30,
    this.minTimeBetweenIrrigation = 120,
    this.fertigationEnabled = false,
    this.fertigationIntervalDays = 7,
    this.fertigationDuration = 15,
    this.stopOnRain = true,
    this.reduceOnHighHumidity = true,
    this.increaseOnHighTemp = true,
    this.irrigationWindowStart = '06:00',
    this.irrigationWindowEnd = '09:00',
    this.fertigationWindowStart = '07:00',
    this.fertigationWindowEnd = '08:00',
    this.farmId = "",
  });

  factory AutomationSettings.fromMap(Map<String, dynamic> map) =>
      AutomationSettings(
        moistureThreshold: (map['moistureThreshold'] ?? 40).toDouble(),
        maxIrrigationTime: map['maxIrrigationTime'] ?? 30,
        minTimeBetweenIrrigation: map['minTimeBetweenIrrigation'] ?? 120,
        fertigationEnabled: map['fertigationEnabled'] ?? false,
        fertigationIntervalDays: map['fertigationIntervalDays'] ?? 7,
        fertigationDuration: map['fertigationDuration'] ?? 15,
        stopOnRain: map['stopOnRain'] ?? true,
        reduceOnHighHumidity: map['reduceOnHighHumidity'] ?? true,
        increaseOnHighTemp: map['increaseOnHighTemp'] ?? true,
        irrigationWindowStart: map['irrigationWindowStart'] ?? '06:00',
        irrigationWindowEnd: map['irrigationWindowEnd'] ?? '09:00',
        fertigationWindowStart: map['fertigationWindowStart'] ?? '07:00',
        fertigationWindowEnd: map['fertigationWindowEnd'] ?? '08:00',
        farmId: map['farmId'] ?? '',
      );

  Map<String, dynamic> toMap() => {
    'moistureThreshold': moistureThreshold,
    'maxIrrigationTime': maxIrrigationTime,
    'minTimeBetweenIrrigation': minTimeBetweenIrrigation,
    'fertigationEnabled': fertigationEnabled,
    'fertigationIntervalDays': fertigationIntervalDays,
    'fertigationDuration': fertigationDuration,
    'stopOnRain': stopOnRain,
    'reduceOnHighHumidity': reduceOnHighHumidity,
    'increaseOnHighTemp': increaseOnHighTemp,
    'irrigationWindowStart': irrigationWindowStart,
    'irrigationWindowEnd': irrigationWindowEnd,
    'fertigationWindowStart': fertigationWindowStart,
    'fertigationWindowEnd': fertigationWindowEnd,
    'farmId': farmId,
  };

  AutomationSettings copyWith({
    double? moistureThreshold,
    int? maxIrrigationTime,
    int? minTimeBetweenIrrigation,
    bool? fertigationEnabled,
    int? fertigationIntervalDays,
    int? fertigationDuration,
    bool? stopOnRain,
    bool? reduceOnHighHumidity,
    bool? increaseOnHighTemp,
    String? irrigationWindowStart,
    String? irrigationWindowEnd,
    String? fertigationWindowStart,
    String? fertigationWindowEnd,
    String? farmId,
  }) => AutomationSettings(
    moistureThreshold: moistureThreshold ?? this.moistureThreshold,
    maxIrrigationTime: maxIrrigationTime ?? this.maxIrrigationTime,
    minTimeBetweenIrrigation:
        minTimeBetweenIrrigation ?? this.minTimeBetweenIrrigation,
    fertigationEnabled: fertigationEnabled ?? this.fertigationEnabled,
    fertigationIntervalDays:
        fertigationIntervalDays ?? this.fertigationIntervalDays,
    fertigationDuration: fertigationDuration ?? this.fertigationDuration,
    stopOnRain: stopOnRain ?? this.stopOnRain,
    reduceOnHighHumidity: reduceOnHighHumidity ?? this.reduceOnHighHumidity,
    increaseOnHighTemp: increaseOnHighTemp ?? this.increaseOnHighTemp,
    irrigationWindowStart: irrigationWindowStart ?? this.irrigationWindowStart,
    irrigationWindowEnd: irrigationWindowEnd ?? this.irrigationWindowEnd,
    fertigationWindowStart:
        fertigationWindowStart ?? this.fertigationWindowStart,
    fertigationWindowEnd: fertigationWindowEnd ?? this.fertigationWindowEnd,
    farmId: farmId ?? this.farmId,
  );
}
