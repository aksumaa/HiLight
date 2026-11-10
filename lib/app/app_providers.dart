import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/db/app_database.dart';
import '../data/models/library_item.dart';
import '../data/remote/api_client.dart';
import '../data/remote/token_store.dart';
import '../data/repositories/drift_item_repository.dart';
import '../data/repositories/item_repository.dart';
import '../data/sync/sync_service.dart';
import '../features/capture/domain/capture_file_store.dart';
import '../features/capture/domain/capture_pipeline.dart';
import '../features/capture/domain/capture_source.dart';
import '../features/capture/domain/mlkit_ocr_service.dart';
import '../features/capture/domain/preview_recognition.dart';
import '../features/capture/domain/recognition.dart';
import '../features/capture/domain/recognition_network.dart';
import '../features/capture/domain/server_recognition.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError('SharedPreferences is provided in main.');
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw StateError('AppDatabase is provided in main.');
});

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return DriftItemRepository(ref.watch(appDatabaseProvider));
});

final captureFileStoreProvider = Provider<CaptureFileStore>((ref) {
  return DocumentsCaptureFileStore();
});

final recognitionConfigProvider = Provider<RecognitionConfig>((ref) {
  return RecognitionConfig.fromEnvironment();
});

final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(recognitionConfigProvider);
  final dio = Dio(BaseOptions(baseUrl: config.apiBase));
  ref.onDispose(dio.close);
  return ApiClient(dio: dio, tokens: ref.watch(tokenStoreProvider));
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    api: ref.watch(apiClientProvider),
    items: ref.watch(itemRepositoryProvider),
    preferences: ref.watch(sharedPreferencesProvider),
  );
});

final recognitionNetworkProvider = Provider<RecognitionNetwork>((ref) {
  return LookupRecognitionNetwork();
});

final ocrRouterProvider = Provider<OcrRouter>((ref) {
  final config = ref.watch(recognitionConfigProvider);
  final client = http.Client();
  ref.onDispose(client.close);
  return OcrRouter(
    onDevice: MlKitOcrService(),
    server: ServerOcrService(
      apiBase: config.apiBase,
      useFake: config.useFakeOcr,
      fake: PreviewOcrService(),
      client: client,
      bearer: () => ref.read(apiClientProvider).bearer(),
    ),
  );
});

final sttServiceProvider = Provider<SttService>((ref) {
  final config = ref.watch(recognitionConfigProvider);
  final client = http.Client();
  ref.onDispose(client.close);
  return ServerSttService(
    apiBase: config.apiBase,
    useFake: config.useFakeStt,
    fake: PreviewSttService(),
    client: client,
    bearer: () => ref.read(apiClientProvider).bearer(),
  );
});

final capturePipelineProvider = Provider<CapturePipeline>((ref) {
  return CapturePipeline(
    ocr: ref.watch(ocrRouterProvider),
    stt: ref.watch(sttServiceProvider),
    network: ref.watch(recognitionNetworkProvider),
    repository: ref.watch(itemRepositoryProvider),
    files: ref.watch(captureFileStoreProvider),
  );
});

final phoneCameraSourceProvider = Provider<PhoneCameraSource>((ref) {
  return PhoneCameraSource(ref.watch(captureFileStoreProvider));
});

final phoneMicSourceProvider = Provider<PhoneMicSource>((ref) {
  return PhoneMicSource();
});

final manualInputSourceProvider = Provider<ManualInputSource>((ref) {
  return ManualInputSource();
});

final mockDeviceSourceProvider = Provider<MockDeviceSource>((ref) {
  return MockDeviceSource();
});

final libraryItemsProvider = StreamProvider<List<LibraryItem>>((ref) {
  return ref.watch(itemRepositoryProvider).watchAll();
});

class CaptureLanguageController extends Notifier<String> {
  static const storageKey = 'capture_language';

  @override
  String build() {
    final stored = ref.watch(sharedPreferencesProvider).getString(storageKey);
    if (stored != null &&
        (stored == 'en' || stored == 'ru' || stored == 'uz')) {
      return stored;
    }
    final code = PlatformDispatcher.instance.locale.languageCode;
    if (code == 'ru' || code == 'uz') return code;
    return 'en';
  }

  Future<void> select(String code) async {
    state = code;
    await ref.read(sharedPreferencesProvider).setString(storageKey, code);
  }
}

final captureLanguageProvider =
    NotifierProvider<CaptureLanguageController, String>(
      CaptureLanguageController.new,
    );
