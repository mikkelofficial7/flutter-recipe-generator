import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_generator/constant/wording.dart';

import 'util/device.dart';

class DefaultApp extends StatelessWidget {
  const DefaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              flex: 1,
              child: Container(
                color: Colors.red,
                height: 100,
                child: Center(child: Text("Left")),
              )),
          Expanded(flex: 3, child: BelowSideFragment())
        ],
      ),
    );
  }
}

class BelowSideFragment extends StatefulWidget {
  const BelowSideFragment({super.key});

  @override
  State<BelowSideFragment> createState() => BelowSideFragmentState();
}

class BelowSideFragmentState extends State<BelowSideFragment> {
  ActionState actionType = ActionState.normal;

  void setAction(ActionState action) {
    setState(() {
      actionType = action;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // match parent width
      child: actionType == ActionState.normal
          ? ButtonView(
              onActionSelected: setAction,
            )
          : actionType == ActionState.camera
              ? CameraView()
              : Text("data"),
    );
  }
}

class ButtonView extends StatelessWidget {
  final void Function(ActionState) onActionSelected; // callback
  const ButtonView({super.key, required this.onActionSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey,
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 3, 70, 125), // button background
                    foregroundColor: Colors.yellow, // text (and icon) color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    )),
                onPressed: () {
                  onActionSelected(ActionState.camera);
                },
                icon: Icon(
                  Icons.camera_alt,
                  color: Colors.yellow,
                ),
                label: Text(Wording.openCamera),
              ),
            ),
          ),
          Expanded(
              flex: 0,
              child: Text(
                Wording.or,
                style: TextStyle(color: Colors.white70),
              )),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.topCenter,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 123, 15, 7), // button background
                    foregroundColor: Colors.yellow, // text (and icon) color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    )),
                onPressed: () {
                  onActionSelected(ActionState.gallery);
                },
                icon: Icon(
                  Icons.image,
                  color: Colors.yellow,
                ),
                label: Text(Wording.openGallery),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  CameraViewState createState() => CameraViewState();
}

class CameraViewState extends State<CameraView> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    startCamera();
  }

  Future<void> startCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras![0], ResolutionPreset.medium);
    await _controller!.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: CameraPreview(_controller!),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
