import 'package:flutter/material.dart';
import 'package:messager_app/model/profie_model.dart';
import 'package:messager_app/service/auth_service.dart';
import 'package:messager_app/service/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  String user_id = Supabase.instance.client.auth.currentUser!.id;

  late Future<Profile?> futureProfile = _profileService.fetchProfile(user_id);

  void logout() {
    setState(() {
      _authService.logout(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Expanded(
            child: Container(
                padding: EdgeInsets.all(24),
                child: FutureBuilder(
                    future: futureProfile,
                    builder: (context, data) {
                      if (data.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (!data.hasData || data.hasError) {
                        return SizedBox.shrink();
                      }
                      Profile? profile = data.data;
                      String user_image = profile!.user_image;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // GestureDetector(
                              //   onTap: () => Navigator.pop(context),
                              //   child: Icon(
                              //     Icons.arrow_back_ios_new,
                              //     color: Colors.white,
                              //   ),
                              // ),
                              SizedBox(
                                width: 20,
                              ),
                              Container(
                                  height: 80,
                                  width: 80,
                                  child: profile!.user_image.isEmpty
                                      ? Image.asset(
                                          "assets/images/avatar.png",
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          "$user_image?t=${DateTime.now().millisecondsSinceEpoch}",
                                          key: ValueKey(DateTime.now()
                                              .millisecondsSinceEpoch),
                                          fit: BoxFit.cover)),
                              SizedBox(
                                width: 12,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.user_name.isEmpty
                                        ? "New User"
                                        : profile.user_name,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  GestureDetector(
                                    // onTap: () {
                                    //   Navigator.push(
                                    //       context,
                                    //       MaterialPageRoute(
                                    //           builder: (_) => ChangeProfilePage(
                                    //               user_image:
                                    //                   profile.user_image,
                                    //               user_name:
                                    //                   profile.user_name)));
                                    // },
                                    child: Container(
                                      height: 40,
                                      width: 150,
                                      decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      child: Center(
                                        child: Text("Change Info",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Text("Setting",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          SizedBox(
                            height: 12,
                          ),
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(4)),
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                "Change Pasword",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          GestureDetector(
                            onTap: () => logout(),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(4)),
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  "Sign out",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    }))),
      ),
    );
  }
}
