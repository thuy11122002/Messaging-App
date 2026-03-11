import 'package:flutter/material.dart';
import 'package:messager_app/model/notification_model.dart';
import 'package:messager_app/model/profie_model.dart';
import 'package:messager_app/service/chat_service.dart';
import 'package:messager_app/service/notification_service.dart';
import 'package:messager_app/service/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final myId = Supabase.instance.client.auth.currentUser!.id;

  final ChatService _chatService = ChatService();
  final ProfileService _profileService = ProfileService();
  final NotificationService _notificationService = NotificationService();

  late Future<List<NotificationModel>> futureNotification =
      _notificationService.getAllNotification();

  List<NotificationModel> notifications = [];

  @override
  void initState() {
    initializeData();
    super.initState();
  }

  void initializeData() async {
    try {
      // _conversationsStream = _chatService.getConversations();

      final notifications = await futureNotification;
      if (notifications.isNotEmpty) {
        setState(() {
          this.notifications = notifications;
        });
      }
    } catch (e) {
      print("Initialization Error: $e");
    }
  }

  Widget _buildNotificationList() {
    return FutureBuilder(
        future: futureNotification,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return SizedBox.shrink();
          }
          return ListView.builder(
              itemCount: notifications.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                Future<Profile?> p = _profileService
                    .fetchProfile(notifications[index].sender_id);
                bool check = notifications[index].accepted;

                if (check) {
                  return SizedBox.shrink();
                }

                return FutureBuilder(
                    future: p,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return SizedBox.shrink();
                      }
                      Profile profile = snapshot.data!;
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
                                    child: profile.user_image.isEmpty
                                        ? Image.asset(
                                            "assets/images/avatar.png")
                                        : Image.network(profile.user_image))),
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
                                      profile.user_name.isEmpty
                                          ? "New User"
                                          : profile.user_name,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text("Sent you a friend request")
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _notificationService
                                    .acceptNotify(profile.user_id);
                              },
                              child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      color: Colors.blue),
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  )),
                            ),
                            SizedBox(
                              width: 40,
                            ),
                            GestureDetector(
                                onTap: () {
                                  _notificationService
                                      .unacceptNotify(profile.user_id);
                                },
                                child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        color: Colors.grey),
                                    child: Icon(
                                      Icons.remove,
                                      color: Colors.white,
                                    ))),
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
                children: [
                  Icon(Icons.more_horiz),
                  GestureDetector(
                      onTap: () => {}, child: Icon(Icons.edit_square))
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                "Notifications",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 12,
              ),
              Expanded(child: _buildNotificationList())
            ],
          ),
        ),
      ),
    );
  }
}
