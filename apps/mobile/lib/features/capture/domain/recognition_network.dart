import 'dart:async';
import 'dart:io';

abstract class RecognitionNetwork {
  Future<bool> get isOnline;
}

class LookupRecognitionNetwork implements RecognitionNetwork {
  @override
  Future<bool> get isOnline async {
    try {
      final result = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }
}

class FixedRecognitionNetwork implements RecognitionNetwork {
  const FixedRecognitionNetwork(this.online);

  final bool online;

  @override
  Future<bool> get isOnline async => online;
}
