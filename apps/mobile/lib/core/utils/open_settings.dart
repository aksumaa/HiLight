import 'package:url_launcher/url_launcher.dart';

Future<void> openSystemSettings() async {
  final uri = Uri.parse('app-settings:');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
