import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../study/application/study_providers.dart';
import '../domain/widget_snapshot.dart';

const sharedContainerChannel = MethodChannel('com.muslima.hilight/shared');

class WidgetBridge {
  WidgetBridge({this.channel = sharedContainerChannel});

  final MethodChannel channel;

  Future<bool> publish({required String quote, required int due}) async {
    try {
      final wrote = await channel.invokeMethod<bool>('writeWidget', {'quote': quote, 'due': due});
      return wrote ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}

final widgetBridgeProvider = Provider<WidgetBridge>((ref) => WidgetBridge());

/// Pushes the quote and the due count into the App Group whenever they change.
class WidgetPublisher extends ConsumerStatefulWidget {
  const WidgetPublisher({super.key});

  @override
  ConsumerState<WidgetPublisher> createState() => _WidgetPublisherState();
}

class _WidgetPublisherState extends ConsumerState<WidgetPublisher> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _push());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(libraryItemsProvider, (_, _) => _push());
    ref.listen(reviewDueCountProvider, (_, _) => _push());
    return const SizedBox.shrink();
  }

  void _push() {
    final items = ref.read(libraryItemsProvider).value ?? const [];
    final due = ref.read(reviewDueCountProvider);
    ref.read(widgetBridgeProvider).publish(
      quote: quoteOfDay(items, DateTime.now()) ?? '',
      due: due,
    );
  }
}
