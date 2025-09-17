import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_recipe_generator/constant/wording.dart';
import 'package:flutter_recipe_generator/default.dart';
import 'package:flutter_recipe_generator/util/device.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandler extends StatefulWidget {
  const PermissionHandler({super.key});

  @override
  State<PermissionHandler> createState() => _PermissionHandlerState();
}

class _PermissionHandlerState extends State<PermissionHandler> {
  String statusMessage = Wording.permissionTitle;
  String buttonStatusMessage = Wording.giveAccess;
  bool isUserClickGoToSetting = false;

  Future<void> _checkPermission() async {
    var sdkVersion = await detectAndroidSdk();
    var isPlatformAndroid = Platform.isAndroid;

    // Camera
    var permissionCamera = Permission.camera;

    // Gallery / storage
    var permissionStorage = sdkVersion < 33 && isPlatformAndroid
        ? Permission.storage
        : Permission.photos;

    if (await permissionCamera.status.isGranted &&
        await permissionStorage.status.isGranted) {
      // permission permanent granted
      if (!mounted) return;

      navigateDefaultPage();
      return;
    } else {
      if (await permissionCamera.status.isDenied ||
          await permissionStorage.status.isDenied) {
        // await permission camera and storage
        var awaitCamera = await permissionCamera.request().isGranted;
        var awaitStorage = await permissionStorage.request().isGranted;

        // Ask the user
        if (awaitCamera && awaitStorage) {
          setState(() {
            statusMessage = Wording.permissionGranted; // permission granted
            buttonStatusMessage = Wording.giveAccessSuccess;
          });

          navigateDefaultPage();
        } else {
          setState(() {
            statusMessage = Wording.permissionRevoked; // permission revoked
            buttonStatusMessage = Wording.giveAccess;
          });
        }
      } else {
        setState(() {
          statusMessage = Wording
              .permissionRevokedPermanent; // permission revoked permanent
          buttonStatusMessage = Wording.goToSetting;
        });
        if (isUserClickGoToSetting) {
          openAppSettings();
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(31, 230, 230, 230),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Center(
                child: Text(
                  statusMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // button background color
                foregroundColor: Colors.white12, // text (and icon) color
              ),
              onPressed: () {
                _checkPermission();
                isUserClickGoToSetting = true;
              },
              child: Text(buttonStatusMessage,
                  style: TextStyle(color: Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }

  void navigateDefaultPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DefaultApp()),
    );
  }
}
