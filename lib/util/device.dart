import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

Future<int> detectAndroidSdk() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt;
  } else {
    return -1;
  }
}
