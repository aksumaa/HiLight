import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../domain/tutor_service.dart';

final tutorProvider = Provider<TutorService>((ref) {
  final api = ref.watch(apiClientProvider);
  return TutorService(dio: api.dio, bearer: api.bearer);
});
