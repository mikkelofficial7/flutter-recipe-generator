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

    // Storage & Gallery
    var permissionStorage = Permission.storage;

    var isAndroidSDK35Above = false;

    // additional for SDK 25 above
    var permissionRecordAudio = Permission.microphone;

    if (isPlatformAndroid && sdkVersion >= 33) {
      permissionStorage = Permission.photos;
      isAndroidSDK35Above = true;
    }

    // Check camera + all storage permissions
    bool cameraGranted = await permissionCamera.isGranted;
    bool storageGranted = await permissionStorage.isGranted;

    // If denied, request them
    bool cameraRequest = await permissionCamera.request().isGranted;
    bool storageRequest = await permissionStorage.request().isGranted;

    // Check if permanently denied
    bool cameraPermanentlyDenied = await permissionCamera.isPermanentlyDenied;
    bool storagePermanentlyDenied = await permissionStorage.isPermanentlyDenied;

    if (isAndroidSDK35Above) {
      bool recordAudioGranted = await permissionRecordAudio.isGranted;

      if (cameraGranted && storageGranted && recordAudioGranted) {
        if (!mounted) return;
        navigateDefaultPage();
        return;
      }

      bool recordAudioRequest = await permissionRecordAudio.request().isGranted;

      if (cameraRequest && storageRequest && recordAudioRequest) {
        setState(() {
          statusMessage = Wording.permissionGranted;
          buttonStatusMessage = Wording.giveAccessSuccess;
        });
        navigateDefaultPage();
      } else {
        bool recordAudioPermanentlyDenied =
            await permissionRecordAudio.isPermanentlyDenied;

        if (cameraPermanentlyDenied ||
            storagePermanentlyDenied ||
            recordAudioPermanentlyDenied) {
          setState(() {
            statusMessage = Wording.permissionRevokedPermanent;
            buttonStatusMessage = Wording.goToSetting;
          });

          if (isUserClickGoToSetting) {
            openAppSettings();
          }
        } else {
          setState(() {
            statusMessage = Wording.permissionRevoked;
            buttonStatusMessage = Wording.giveAccess;
          });
        }
      }
    } else {
      if (cameraGranted && storageGranted) {
        if (!mounted) return;
        navigateDefaultPage();
        return;
      }

      if (cameraRequest && storageRequest) {
        setState(() {
          statusMessage = Wording.permissionGranted;
          buttonStatusMessage = Wording.giveAccessSuccess;
        });
        navigateDefaultPage();
      } else {
        if (cameraPermanentlyDenied || storagePermanentlyDenied) {
          setState(() {
            statusMessage = Wording.permissionRevokedPermanent;
            buttonStatusMessage = Wording.goToSetting;
          });

          if (isUserClickGoToSetting) {
            openAppSettings();
          }
        } else {
          setState(() {
            statusMessage = Wording.permissionRevoked;
            buttonStatusMessage = Wording.giveAccess;
          });
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
