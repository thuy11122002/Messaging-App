import 'package:flutter/material.dart';
import 'package:messager_app/service/auth_service.dart';
import 'package:messager_app/view/widgets/snackBar.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final AuthService _authService = AuthService();

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController checkNewPasswordController = TextEditingController();
  String oldPassword = "";

  String newPassword = "";
  String checkNewPassword = "";

  void changePassword() async {
    final reponse = await _authService.changePassword(oldPassword, newPassword);
    if (reponse.contains("Successful")) {
      showSnackBar(context, "Update password successfully");
      Navigator.pop(context);
    } else {
      showSnackBar(context, "Old Password is wrong, please try again");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Expanded(
              child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Icon(Icons.arrow_back_ios)),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: MediaQuery.sizeOf(context).width,
              child: TextField(
                controller: oldPasswordController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "Old Password"),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Container(
              width: MediaQuery.sizeOf(context).width,
              child: TextField(
                controller: newPasswordController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "New Password"),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Text("The new password must be equal or more than 8 characters"),
            SizedBox(
              height: 12,
            ),
            Container(
              width: MediaQuery.sizeOf(context).width,
              child: TextField(
                controller: checkNewPasswordController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Check New Password"),
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
                  oldPassword = oldPasswordController.text;
                  newPassword = newPasswordController.text;
                  checkNewPassword = checkNewPasswordController.text;
                  if (newPassword.isEmpty ||
                      oldPassword.isEmpty ||
                      checkNewPassword.isEmpty) {
                    showSnackBar(
                        context, "You must fill all fields, please try again");
                    return;
                  }
                  if (!newPassword.contains(checkNewPassword)) {
                    showSnackBar(context,
                        "check new Password is different to new Password, please try again");
                    return;
                  }
                  if (newPassword.length < 8) {
                    showSnackBar(context,
                        "New Password must be equal or more than 8 characters, please try again");

                    return;
                  }
                  changePassword();
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
