import 'package:url_launcher/url_launcher.dart';

class UrlLauncherHelper {
  static Future<void> urlLauncher(String webSite) async {
    final url = Uri.parse(webSite);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch url';
    }
  }
}
