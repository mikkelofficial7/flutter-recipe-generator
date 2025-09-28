import 'package:flutter/services.dart';

class ModeNavigation {
  static Future<bool> isGestureNavigationActive(MethodChannel channel) async {
    try {
      final result = await channel.invokeMethod<bool>("isGestureNavigation");
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
