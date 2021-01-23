import 'dart:io';

import 'package:brahminapp/common_widgets/custom_raised_button.dart';
import 'package:brahminapp/common_widgets/platform_exception_alert_dialog.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class EditGallery extends StatefulWidget {
  final imageUrl;
  final uid;
  final set;
  final num;

  const EditGallery(
      {Key key,
      @required this.imageUrl,
      @required this.uid,
      this.num,
      this.set})
      : super(key: key);

  @override
  _EditGalleryState createState() => _EditGalleryState();
}

class _EditGalleryState extends State<EditGallery> {
  bool inProcess = false;
  File imageFile;
  String imageUrlP;

  Future<void> _submit() async {
    Future.delayed(Duration(milliseconds: 10)).whenComplete(() async {
      StorageReference reference = FirebaseStorage.instance
          .ref()
          .child('Users/${widget.uid}/${widget.num}');
      StorageUploadTask uploadTask = reference.putFile(imageFile);
      var downloadUrlt =
          await (await uploadTask.onComplete).ref.getDownloadURL();
      var url = downloadUrlt.toString();

      imageUrlP = url;
      print('eir $imageUrlP');
    }).whenComplete(() {
      try {
        if (widget.set == null) {
          FirebaseFirestore.instance
              .doc('punditUsers/${widget.uid}/user_profile/galleryPic')
              .set({
            'link${widget.num}': imageUrlP,
            'link${widget.num + 1}': null,
            'link${widget.num + 2}': null,
            'link${widget.num + 3}': null,
            'link${widget.num + 4}': null,
            'link${widget.num + 5}': null,
            'set': 'done',
          }).whenComplete(() {
            FirebaseFirestore.instance
                .doc('Avaliable_pundit/${widget.uid}/gallery/pics')
                .set({
              'link${widget.num}': imageUrlP,
              'link${widget.num + 1}': null,
              'link${widget.num + 2}': null,
              'link${widget.num + 3}': null,
              'set': 'done',
            });
          }).whenComplete(() => print('set data is completed'));
        } else {
          FirebaseFirestore.instance
              .doc('punditUsers/${widget.uid}/user_profile/galleryPic')
              .update({
                'link${widget.num}': imageUrlP,
              })
              .whenComplete(() => {
                    FirebaseFirestore.instance
                        .doc('Avaliable_pundit/${widget.uid}/gallery/pics')
                        .update({
                      'link${widget.num}': imageUrlP,
                    })
                  })
              .whenComplete(() => print('update data is completed'));
        }
      } on PlatformException catch (e) {
        PlatformExceptionAlertDialog(
          title: 'Operation failed',
          exception: e,
        ).show(context);
      }
    });

    Navigator.of(context).pop();
  }

  getImagezFromDevice({ImageSource source, int num}) async {
    this.setState(() {
      inProcess = true;
    });
    // ignore: invalid_use_of_visible_for_testing_member
    PickedFile image = await ImagePicker.platform.pickImage(source: source);
    if (image != null) {
      File cropped = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 3, ratioY: 2),
        compressQuality: 100,
        maxWidth: 700,
        maxHeight: 700,
        compressFormat: ImageCompressFormat.jpg,
      );
      this.setState(() {
        imageFile = cropped;
        inProcess = false;
      });
    } else {
      this.setState(() {
        inProcess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    imageUrlP = widget.imageUrl;
    return WillPopScope(
      onWillPop: () async {
        imageFile = null;
        imageUrlP = null;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 100,),
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(

            child: Column(
              children: [
                Card(
                  elevation: 0.5,
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Please upload image',
                            style: TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: GestureDetector(
                              onTap: () {
                                getImagezFromDevice(
                                  source: ImageSource.gallery,
                                  num: widget.num,
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                      style: BorderStyle.solid),
                                ),
                                height: MediaQuery.of(context).size.height *
                                    0.35,
                                child: imageFile == null
                                    ? imageUrlP == null
                                        ? Center(
                                            child: Text(
                                              'Add image',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          )
                                        : Image.network(
                                            imageUrlP,
                                            fit: BoxFit.fitHeight,
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent
                                                        loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes
                                                      : null,
                                                ),
                                              );
                                            },
                                          )
                                    : Image.file(
                                        imageFile,
                                        fit: BoxFit.fitHeight,
                                      ),
                              ),
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(
                                    Icons.image,
                                    size: 30,
                                    color: Colors.deepOrange,
                                  ),
                                  onPressed: () {
                                    getImagezFromDevice(
                                      source: ImageSource.gallery,
                                      num: widget.num,
                                    );
                                  }),
                              IconButton(
                                  icon: Icon(
                                    Icons.camera_alt,
                                    size: 30,
                                    color: Colors.deepOrange,
                                  ),
                                  onPressed: () {
                                    getImagezFromDevice(
                                      num: widget.num,
                                      source: ImageSource.camera,
                                    );
                                  }),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          CustomRaisedButton(
                            child: Text('Submit'),
                            color: Colors.deepOrange,
                            onPressed: () => _submit(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  color: Colors.grey[100],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
