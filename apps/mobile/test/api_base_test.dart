import 'package:flutter_test/flutter_test.dart';
import 'package:hilight/features/capture/domain/recognition.dart';

void main() {
  test('release refuses a plain http API address', () {
    expect(
      resolveApiBase(release: true, defined: 'http://192.168.1.20:8000'),
      'https://api.hilight.invalid',
    );
    expect(
      resolveApiBase(release: true, defined: ''),
      'https://api.hilight.invalid',
    );
    expect(
      resolveApiBase(release: true, defined: 'https://api.example.com'),
      'https://api.example.com',
    );
  });

  test('debug keeps a local http default', () {
    expect(resolveApiBase(release: false, defined: ''), 'http://127.0.0.1:8000');
    expect(
      resolveApiBase(release: false, defined: 'http://192.168.1.20:8000'),
      'http://192.168.1.20:8000',
    );
  });
}
