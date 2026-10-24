import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart' as models;
import '../models/models.dart';

class AppwriteConfig {
  static const String endpoint = 'https://fra.cloud.appwrite.io/v1';
  static const String projectId = '69988bb3003af3bb740d';
  static const String databaseId = '69adb7cb0011389aaa1c';
  /*static const String appwriteProjectId = '69988bb3003af3bb740d';
  static const String appwriteProjectName = 'smart_irrigation_farming';
  static const String appwritePublicEndpoint = 'https://fra.cloud.appwrite.io/v1';*/

  // Collection IDs
  static const String farmsCollection = 'farms';
  static const String sensorDataCollection = 'sensor_data';
  static const String schedulesCollection = 'irrigation_schedules';
  static const String notificationsCollection = 'notifications';
  static const String devicesCollection = 'devices';
  static const String automationCollection = 'automation_settings';
  static const String usersCollection = 'users';
}

class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;
  AppwriteService._internal();

  late final Client client;
  late final Account account;
  late final Databases databases;
  late final Storage storage;
  late final Realtime realtime;

  void init() {
    client = Client()
      ..setEndpoint(AppwriteConfig.endpoint)
      ..setProject(AppwriteConfig.projectId)
      ..setSelfSigned(status: true);

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
    realtime = Realtime(client);
  }
}

// Auth Service
class AuthService {
  final AppwriteService _service = AppwriteService();

  Account get _account => _service.account;
  Databases get _db => _service.databases;

  Future<models.User> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final user = await _account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: fullName,
    );

    await _db.createDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.usersCollection,
      documentId: user.$id,
      data: {'fullName': fullName, 'email': email, 'userId': user.$id},
    );

    await _account.createEmailPasswordSession(email: email, password: password);

    return user;
  }

  Future<models.Session> login({
    required String email,
    required String password,
  }) async {
    return await _account.createEmailPasswordSession(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _account.deleteSession(sessionId: 'current');
  }

  Future<models.User?> getCurrentUser() async {
    try {
      return await _account.get();
    } catch (_) {
      return null;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    await _account.createRecovery(
      email: email,
      url: 'https://yourdomain.com/reset-password',
    );
  }

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _db.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollection,
        documentId: userId,
      );
      return UserModel.fromMap(doc.data);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    await _db.updateDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.usersCollection,
      documentId: userId,
      data: data,
    );
  }

  Future<models.Session> createGoogleSession() async {
    return await _account.createOAuth2Session(provider: OAuthProvider.google)
        as models.Session;
  }
}

// Farm Service
class FarmService {
  final AppwriteService _service = AppwriteService();
  Databases get _db => _service.databases;

  Future<FarmModel> createFarm(FarmModel farm) async {
    final doc = await _db.createDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.farmsCollection,
      documentId: ID.unique(),
      data: farm.toMap(),
    );
    return FarmModel.fromMap({...doc.data, '\$id': doc.$id});
  }

  Future<FarmModel?> getFarmByUser(String userId) async {
    try {
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.farmsCollection,
        queries: [Query.equal('userId', userId)],
      );
      print("The farm result is ${result.documents}");
      if (result.documents.isEmpty) return null;
      final doc = result.documents.first;
      return FarmModel.fromMap({...doc.data, '\$id': doc.$id});
    } catch (_) {
      print("The farm result is null");
      return null;
    }
  }

  Future<void> updateFarm(String farmId, Map<String, dynamic> data) async {
    await _db.updateDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.farmsCollection,
      documentId: farmId,
      data: data,
    );
  }
}

// Sensor Service
class SensorService {
  final AppwriteService _service = AppwriteService();
  Databases get _db => _service.databases;
  Realtime get _realtime => _service.realtime;

  Future<SensorData?> getLatestSensorData(String deviceId) async {
    try {
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.sensorDataCollection,
        queries: [
          Query.equal('deviceId', deviceId),
          Query.orderDesc('\$createdAt'),
          Query.limit(1),
        ],
      );
      if (result.documents.isEmpty) return null;
      return SensorData.fromMap(result.documents.first.data);
    } catch (_) {
      return null;
    }
  }

  RealtimeSubscription subscribeToSensorData(
    String deviceId,
    Function(SensorData) onData,
  ) {
    return _realtime.subscribe([
        'databases.${AppwriteConfig.databaseId}.collections.${AppwriteConfig.sensorDataCollection}.documents',
      ])
      ..stream.listen((event) {
        if (event.payload['deviceId'] == deviceId) {
          onData(SensorData.fromMap(event.payload));
        }
      });
  }

  Future<void> sendCommand(
    String deviceId,
    Map<String, dynamic> command,
  ) async {
    await _db.createDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: 'commands',
      documentId: ID.unique(),
      data: {
        'deviceId': deviceId,
        ...command,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}

// Schedule Service
class ScheduleService {
  final AppwriteService _service = AppwriteService();
  Databases get _db => _service.databases;

  Future<List<ScheduleModel>> getSchedules(String farmId) async {
    final result = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.schedulesCollection,
      queries: [Query.equal('farmId', farmId)],
    );
    return result.documents
        .map((d) => ScheduleModel.fromMap({...d.data, '\$id': d.$id}))
        .toList();
  }

  Future<ScheduleModel> createSchedule(
    ScheduleModel schedule,
    String farmId,
  ) async {
    final data = schedule.toMap();
    data.remove('id');
    data['farmId'] = farmId;

    final doc = await _db.createDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.schedulesCollection,
      documentId: ID.unique(),
      data: {...schedule.toMap(), 'farmId': farmId},
    );
    return ScheduleModel.fromMap({...doc.data, '\$id': doc.$id});
  }

  Future<void> updateSchedule(
    String scheduleId,
    Map<String, dynamic> data,
  ) async {
    await _db.updateDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.schedulesCollection,
      documentId: scheduleId,
      data: data,
    );
  }

  Future<void> deleteSchedule(String scheduleId) async {
    await _db.deleteDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.schedulesCollection,
      documentId: scheduleId,
    );
  }
}

// Notification Service
class NotificationService {
  final AppwriteService _service = AppwriteService();
  Databases get _db => _service.databases;

  Future<List<NotificationModel>> getNotifications(String userId) async {
    final result = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.notificationsCollection,
      queries: [
        Query.equal('userId', userId),
        Query.orderDesc('\$createdAt'),
        Query.limit(50),
      ],
    );
    return result.documents
        .map((d) => NotificationModel.fromMap({...d.data, '\$id': d.$id}))
        .toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await _db.updateDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.notificationsCollection,
      documentId: notificationId,
      data: {'isRead': true},
    );
  }
}

// Automation Service
class AutomationServiceBackend {
  final AppwriteService _service = AppwriteService();
  Databases get _db => _service.databases;

  Future<AutomationSettings> getSettings(String farmId) async {
    try {
      final doc = await _db.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.automationCollection,
        documentId: farmId,
      );
      return AutomationSettings.fromMap(doc.data);
    } catch (_) {
      return const AutomationSettings();
    }
  }

  Future<void> saveSettings(String farmId, AutomationSettings settings) async {
    try {
      await _db.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.automationCollection,
        documentId: farmId,
        data: settings.toMap(),
      );
    } catch (_) {
      await _db.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.automationCollection,
        documentId: farmId,
        data: settings.toMap(),
      );
    }
  }
}
