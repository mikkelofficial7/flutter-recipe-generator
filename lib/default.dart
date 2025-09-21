// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  bool isMaxImageReached = false;
  late double defaultMarginTop;

  @override
  void initState() {
    super.initState();
    runAnimation();
  }

  void runAnimation() {
    setState(() {
      defaultMarginTop = listImage.isEmpty ? 40 : 350;
    });
  }

  void setImageToList(String imagePath) {
    setState(() {
      showToast("Item uploaded successfully..", Colors.green);
      listImage.add(imagePath);
      isMaxImageReached = listImage.length >= Variable.maxImageUpload;

      if (listImage.length >= Variable.maxImageUpload) {
        var listOfFirstItems = listImage.take(Variable.maxImageUpload).toList();
        listImage.clear();
        listImage.addAll(listOfFirstItems);
      }
      runAnimation();
    });
  }

  void removeImage(int index) {
    setState(() {
      showToast("Item removed successfully..", Colors.red);
      listImage.removeAt(index);
      isMaxImageReached = listImage.length >= Variable.maxImageUpload;
      runAnimation();
    });
  }

  void showToast(String message, Color bgColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: bgColor,
      textColor: const Color(0xFFFFFFFF),
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black87,
        child: Stack(
          children: [
            Container(
                margin: EdgeInsets.only(top: 40),
                height: 300,
                child: UpperSideFragment(
                  listImage: listImage,
                  onRemoveImage: removeImage,
                )),
            BelowSideFragment(
                onImageGet: setImageToList,
                isMaxImageReached: isMaxImageReached,
                defaultMarginTop: defaultMarginTop)
          ],
        ),
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
      width: double.infinity,
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: const Color.fromARGB(241, 134, 133, 133),
            borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 8, left: 8),
                child: Text(Wording.maxImage,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                    )),
              ),
            ),
            Expanded(
                flex: 1,
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
                                width: 120,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 1,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .black54, // semi-transparent background
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(8),
                              ),
                              onPressed: () {
                                widget.onRemoveImage(index);
                              },
                              child:
                                  const Icon(Icons.close, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )),
            Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: Opacity(
                    opacity: widget.listImage.isEmpty ? 0.5 : 1.0,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          backgroundColor: Colors.black54, // button background
                          foregroundColor: Colors.grey, // text (and icon) color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          )),
                      onPressed: () {
                        if (widget.listImage.isNotEmpty) {
                          // hit here
                        }
                      },
                      icon: Icon(
                        Icons.hourglass_bottom,
                        color: Colors.grey,
                      ),
                      label: Text(Wording.analystMaterial),
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

class BelowSideFragment extends StatefulWidget {
  final void Function(String) onImageGet;
  final bool isMaxImageReached;
  final double defaultMarginTop;

  const BelowSideFragment({
    Key? key,
    required this.onImageGet,
    required this.isMaxImageReached,
    required this.defaultMarginTop,
  }) : super(key: key);

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

  void onImageGet(String imagePath) {
    widget.onImageGet(imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(top: widget.defaultMarginTop),
      child: SizedBox(
        width: double.infinity,
        child: actionType == ActionState.gallery
            ? GalleryView(
                onClose: setAction,
                onSelectedImage: (imageLists) {
                  for (final image in imageLists) {
                    onImageGet(image);
                  }
                },
              )
            : actionType == ActionState.camera
                ? CameraView(
                    onClose: setAction,
                    onCapturedImage: onImageGet,
                  )
                : ButtonView(
                    onActionSelected: setAction,
                    isMaxImageReached: widget.isMaxImageReached),
      ),
    );
  }
}

class ButtonView extends StatelessWidget {
  final void Function(ActionState) onActionSelected; // callback
  final bool isMaxImageReached;

  const ButtonView(
      {super.key,
      required this.onActionSelected,
      required this.isMaxImageReached});

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
                child: Opacity(
                  opacity: isMaxImageReached ? 0.5 : 1.0,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                            255, 3, 70, 125), // button background
                        foregroundColor: Colors.yellow, // text (and icon) color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        )),
                    onPressed: () {
                      if (!isMaxImageReached) {
                        onActionSelected(ActionState.camera);
                      }
                    },
                    icon: Icon(
                      Icons.camera_alt,
                      color: Colors.yellow,
                    ),
                    label: Text(Wording.openCamera),
                  ),
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
                child: Opacity(
                  opacity: isMaxImageReached ? 0.5 : 1.0,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                            255, 123, 15, 7), // button background
                        foregroundColor: Colors.yellow, // text (and icon) color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        )),
                    onPressed: () {
                      if (!isMaxImageReached) {
                        onActionSelected(ActionState.gallery);
                      }
                    },
                    icon: Icon(
                      Icons.image,
                      color: Colors.yellow,
                    ),
                    label: Text(Wording.openGallery),
                  ),
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
  bool isTakePicture = false;
  late String activeImagePath;

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
      setState(() {
        activeImagePath = imagePath;
        isTakePicture = true;
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> addPictureToList() async {
    if (!mounted) return;
    setState(() {
      widget.onCapturedImage(activeImagePath);
      isTakePicture = false;
    });
  }

  Future<void> cancelPicture() async {
    if (!mounted) return;
    setState(() {
      isTakePicture = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return isTakePicture == false
        ? Scaffold(
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
                      padding: const EdgeInsets.only(
                          bottom: Variable.defaultMarginBottom),
                      child: ElevatedButton(
                          onPressed: () {
                            takePicture();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 22, 22, 22),
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
          )
        : Scaffold(
            body: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.file(File(activeImagePath), fit: BoxFit.cover),
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
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: Variable.defaultMarginBottom),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  backgroundColor:
                                      Colors.white, // button background
                                  foregroundColor: const Color.fromARGB(255,
                                      178, 20, 20), // text (and icon) color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  )),
                              onPressed: () {
                                cancelPicture();
                              },
                              child: Icon(Icons.close,
                                  color: const Color.fromARGB(255, 178, 20, 20),
                                  size: 30)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  backgroundColor:
                                      Colors.white, // button background
                                  foregroundColor: const Color.fromARGB(
                                      255, 16, 111, 7), // text (and icon) color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  )),
                              onPressed: () {
                                addPictureToList();
                              },
                              child: Icon(
                                Icons.check,
                                color: const Color.fromARGB(255, 16, 111, 7),
                                size: 30,
                              )),
                        )
                      ],
                    ),
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

class GalleryView extends StatefulWidget {
  final void Function(ActionState) onClose; // callback
  final void Function(List<String>) onSelectedImage; // callback

  const GalleryView(
      {super.key, required this.onClose, required this.onSelectedImage});

  @override
  GalleryViewState createState() => GalleryViewState();
}

class GalleryViewState extends State<GalleryView> {
  List<File> imageSelected = [];

  Future<void> pickImageGallery() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        imageSelected.addAll(
          result.paths.map((path) => File(path!)).toList(),
        );
      });
    }
  }

  Future<void> removeImage(int index) async {
    setState(() {
      imageSelected.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                  flex: 4,
                  child: Container(
                    margin: EdgeInsets.only(
                        top: 70, left: 10, right: 10, bottom: 10),
                    child: imageSelected.isEmpty
                        ? Center(child: Text(Wording.noImageChoose))
                        : GridView.builder(
                            padding: EdgeInsets.only(top: 10),
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                            ),
                            itemCount: imageSelected.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.file(
                                      imageSelected[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                      right: 0,
                                      top: 1,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors
                                              .black54, // semi-transparent background
                                          shape: const CircleBorder(),
                                          padding: const EdgeInsets.all(8),
                                        ),
                                        onPressed: () {
                                          removeImage(index);
                                        },
                                        child: const Icon(Icons.close,
                                            color: Colors.white),
                                      ))
                                ],
                              );
                            },
                          ),
                  )),
              Expanded(
                  child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:
                      EdgeInsets.only(bottom: Variable.defaultMarginBottom),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87, // button background
                        foregroundColor:
                            Colors.white70, // text (and icon) color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        )),
                    onPressed: () {
                      pickImageGallery();
                    },
                    icon: Icon(
                      Icons.image,
                      color: Colors.white70,
                    ),
                    label: Text(Wording.openGalleryShow),
                  ),
                ),
              ))
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
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
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: imageSelected.isEmpty
                ? Container()
                : Container(
                    margin: EdgeInsets.all(15),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          backgroundColor: Colors.white, // button background
                          foregroundColor:
                              Colors.blueAccent, // text (and icon) color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          )),
                      onPressed: () {
                        widget.onSelectedImage(
                            imageSelected.map((file) => file.path).toList());
                        widget.onClose(ActionState.normal);
                      },
                      icon: Icon(
                        Icons.file_upload,
                        color: Colors.blueAccent,
                      ),
                      label: Text(Wording.upload),
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
