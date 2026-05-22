import 'package:url_launcher/url_launcher.dart';

class MapLauncherService {
  Future<bool> openCoordinates({
    required double latitude,
    required double longitude,
  }) {
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '$latitude,$longitude',
    });

    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
