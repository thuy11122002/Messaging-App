import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messager_app/service/profile_service.dart';
import 'package:messager_app/view/widgets/snackBar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangeProfilePage extends StatefulWidget {
  final String userName, userImage;

  ChangeProfilePage({required this.userName, required this.userImage});

  @override
  State<ChangeProfilePage> createState() => _ChangeProfilePageState();
}

class _ChangeProfilePageState extends State<ChangeProfilePage> {
  ProfileService _profileService = ProfileService();
  TextEditingController userNameController = TextEditingController();
  final supabase = Supabase.instance.client;

  bool change = false;

  File? imageFile;
  XFile? image;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();

    image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (image == null) return;
    setState(() {
      imageFile = File(image!.path);
      change = true;
    });

    if (!mounted) {
      return;
    }
  }

  Future<void> Update(String userName, XFile? image) async {
    try {
      _profileService.updateProfile(imageFile, userName, context);
    } catch (e) {
      print("Error while update Image $e");
    } finally {
      if (mounted) {
        setState(() {
          imageFile = File(image!.path);
          change = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    userNameController.text = widget.userName;
    String userImage = widget.userImage;
    return Scaffold(
      body: SafeArea(
          child: Expanded(
              child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: () async {
                  pickImage();
                },
                child: !change
                    ? Container(
                        height: 200,
                        width: 200,
                        child: widget.userImage.isEmpty
                            ? Image.asset(
                                "assets/images/avatar.png",
                                fit: BoxFit.cover,
                              )
                            : Image.network(userImage, fit: BoxFit.cover))
                    : Container(
                        height: 200,
                        width: 200,
                        child: Image.file(
                          imageFile!,
                          fit: BoxFit.cover,
                        )),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Container(
              width: MediaQuery.sizeOf(context).width,
              child: TextField(
                controller: userNameController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "User Name"),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            Expanded(child: SizedBox()),
            GestureDetector(
              onTap: () {},
              child: GestureDetector(
                onTap: () {
                  // _profileService.updateProfileName(
                  //     userNameController.text, context);
                  if (userNameController.text.isEmpty) {
                    showSnackBar(context, "Username must be filled");
                    return;
                  }
                  if (image != null) {
                    Update(userNameController.text, image);
                    setState(() {
                      Navigator.pop(context);
                    });
                  } else {
                    _profileService.updateUsername(userNameController.text);
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  height: 40,
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4)),
                  child: Center(
                    child: Text("Save",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ),
            )
          ],
        ),
      ))),
    );
  }
}
