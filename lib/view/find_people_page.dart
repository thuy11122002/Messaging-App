import 'package:flutter/material.dart';
import 'package:messager_app/model/profie_model.dart';
import 'package:messager_app/service/notification_service.dart';
import 'package:messager_app/service/profile_service.dart';
import 'package:messager_app/view/widgets/snackBar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FindPeoplePage extends StatefulWidget {
  const FindPeoplePage({super.key});

  @override
  State<FindPeoplePage> createState() => _FindPeoplePageState();
}

class _FindPeoplePageState extends State<FindPeoplePage> {
  final myId = Supabase.instance.client.auth.currentUser!.id;
  final ProfileService _profileService = ProfileService();
  final NotificationService _notificationService = NotificationService();

  late Future<List<Profile>> futureProfile =
      _profileService.findPeople(searchValue);

  List<Profile> profiles = [];

  String searchValue = "";

  @override
  void initState() {
    initializeData();
    super.initState();
  }

  void initializeData() async {
    try {
      final profiles = await futureProfile;
      if (profiles.isNotEmpty) {
        setState(() {
          this.profiles = profiles;
        });
      }
    } catch (e) {
      print("Initialization Error: $e");
    }
  }

  Widget _buildPeopleList() {
    return FutureBuilder(
        future: futureProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return SizedBox.shrink();
          }
          final profiles = snapshot.data ?? [];
          return ListView.builder(
              itemCount: profiles.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                print(profiles.length);
                Profile profile = snapshot.data![index];
                // Future<bool> check =
                //     _chatService.checkConversation(profile.user_id);
                Future<bool> checkNotification =
                    _notificationService.checkNotification(profile.userId);

                if (profile.userId == myId) {
                  return SizedBox.shrink();
                }

                return FutureBuilder(
                    future: checkNotification,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return SizedBox.shrink();
                      }
                      if (!snapshot.data!) {
                        return SizedBox.shrink();
                      }
                      return Container(
                        width: MediaQuery.sizeOf(context).width,
                        margin: EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                                width: 54,
                                height: 54,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(80),
                                    child: profile.userImage.isEmpty
                                        ? Image.asset(
                                            "assets/images/avatar.png")
                                        : Image.network(profile.userImage))),
                            SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.userName.isEmpty
                                          ? "New User"
                                          : profile.userName,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text("User Description.....")
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                                onTap: () {
                                  _notificationService
                                      .createNotification(profile.userId);
                                  showSnackBar(
                                      context, "Has already sent request");
                                  setState(() {});
                                },
                                child: Icon(Icons.add))
                          ],
                        ),
                      );
                    });
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Icon(Icons.more_horiz), Icon(Icons.edit_square)],
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                "Find People",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Container(
                    width: MediaQuery.sizeOf(context).width * 0.8,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchValue = value;
                          futureProfile =
                              _profileService.findPeople(searchValue);
                        });
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), hintText: "Search"),
                    ),
                  ),
                  Expanded(child: SizedBox()),
                  Icon(Icons.sort_sharp)
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Expanded(child: _buildPeopleList())
            ],
          ),
        ),
      ),
    );
  }
}
