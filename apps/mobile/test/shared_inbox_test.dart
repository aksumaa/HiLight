import 'package:flutter_test/flutter_test.dart';
import 'package:hilight/data/models/library_item.dart';
import 'package:hilight/features/capture/domain/shared_inbox.dart';

void main() {
  test('shared text and links become notes, and a photo becomes a scan', () {
    final text = eventForShare(
      const SharedCapture(id: '1', kind: 'text', text: 'A sentence from Safari'),
      languageCode: 'en',
    );
    final link = eventForShare(
      const SharedCapture(id: '2', kind: 'url', text: 'https://example.com/page'),
      languageCode: 'en',
    );
    final photo = eventForShare(
      const SharedCapture(id: '3', kind: 'image', path: '/tmp/page.jpg'),
      languageCode: 'uz',
    );
    expect(text?.source, ItemSource.manual);
    expect(text?.text, 'A sentence from Safari');
    expect(link?.text, 'https://example.com/page');
    expect(photo?.source, ItemSource.scan);
    expect(photo?.imagePath, '/tmp/page.jpg');
    expect(eventForShare(const SharedCapture(id: '4', kind: 'text', text: '  '), languageCode: 'en'), isNull);
  });
}
