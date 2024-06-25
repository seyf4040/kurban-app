import 'package:url_launcher/url_launcher.dart';

void shareVideoViaWhatsApp(String phoneNumber, String videoPath) async {
  final Uri uri = Uri(
    scheme: 'https',
    host: 'api.whatsapp.com',
    path: '/send',
    queryParameters: {
      'phone': phoneNumber,
      'text': 'Check out this video: $videoPath',
    },
  );

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $uri';
  }
}
