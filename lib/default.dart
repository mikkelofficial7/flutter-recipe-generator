// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_recipe_generator/constant/wording.dart';

import 'util/device.dart';

class DefaultApp extends StatefulWidget {
  @override
  State<DefaultApp> createState() => DefaultAppState();
}

class DefaultAppState extends State<DefaultApp> {
  final List<String> listImage = [];

  void setImageToList(String imagePath) {
    setState(() {
      listImage.add(imagePath);
    });
  }

  void removeImage(int index) {
    setState(() {
      listImage.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              flex: 1,
              child: UpperSideFragment(
                listImage: listImage,
                onRemoveImage: removeImage,
              )),
          Expanded(
              flex: 4,
              child: BelowSideFragment(
                onCaptureImage: setImageToList,
              ))
        ],
      ),
    );
  }
}

class UpperSideFragment extends StatefulWidget {
  final void Function(int) onRemoveImage;
  final List<String> listImage;

  UpperSideFragment(
      {super.key, required this.listImage, required this.onRemoveImage});

  @override
  State<UpperSideFragment> createState() => UpperSideFragmentState();
}

class UpperSideFragmentState extends State<UpperSideFragment> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.black87),
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: const Color.fromARGB(241, 134, 133, 133),
            borderRadius: BorderRadius.circular(8)),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.listImage.length,
          itemBuilder: (context, index) {
            return Center(
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(widget.listImage[index]),
                        fit: BoxFit.cover,
                        height: 150,
                        width: 150,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    right: 5,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.black54, // semi-transparent background
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                      ),
                      onPressed: () {
                        widget.onRemoveImage(index);
                      },
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/*********************/
/*********************/
/*********************/
/*********************/

class BelowSideFragment extends StatefulWidget {
  final void Function(String) onCaptureImage;

  const BelowSideFragment({super.key, required this.onCaptureImage});

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

  void capturedImage(String imagePath) {
    widget.onCaptureImage(imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: actionType == ActionState.normal
          ? ButtonView(
              onActionSelected: setAction,
            )
          : actionType == ActionState.camera
              ? CameraView(
                  onClose: setAction,
                  onCapturedImage: capturedImage,
                )
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
      decoration: BoxDecoration(color: Colors.black87),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.horizontal(
                left: Radius.circular(8), right: Radius.circular(8))),
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
      ),
    );
  }
}

class CameraView extends StatefulWidget {
  final void Function(ActionState) onClose; // callback
  final void Function(String) onCapturedImage; // callback

  const CameraView(
      {super.key, required this.onClose, required this.onCapturedImage});

  @override
  CameraViewState createState() => CameraViewState();
}

class CameraViewState extends State<CameraView> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool? isSuccessCapture;

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

  Future<void> takePicture() async {
    try {
      final image = await _controller!.takePicture();

      // Save to app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = join(directory.path, '${DateTime.now()}.png');
      await image.saveTo(imagePath);

      if (!mounted) return;
      widget.onCapturedImage(imagePath);
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: CameraPreview(_controller!),
          ),
          Container(
            color: Colors.transparent,
            height: double.infinity,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: ElevatedButton(
                    onPressed: () {
                      takePicture();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
                      padding: const EdgeInsets.all(15),
                      shape: const CircleBorder(), // makes it circular
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white70,
                      size: 45,
                    )),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(15),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  backgroundColor: Colors.white, // button background
                  foregroundColor: Colors.red, // text (and icon) color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  )),
              onPressed: () {
                widget.onClose(ActionState.normal);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.red,
              ),
              label: Text(Wording.close),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
