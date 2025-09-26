import 'package:flutter/services.dart';

class ModeNavigation {
  static const _channel = MethodChannel("navigation_mode");

  static Future<bool> isGestureNavigationActive() async {
    try {
      final result = await _channel.invokeMethod<bool>("isGestureNavigation");
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
