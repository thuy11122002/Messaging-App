import 'package:flutter/material.dart';
import 'package:messager_app/model/item_chat_model.dart';
import 'package:messager_app/model/profie_model.dart';
import 'package:messager_app/service/auth_service.dart';
import 'package:messager_app/service/chat_service.dart';
import 'package:messager_app/service/profile_service.dart';
import 'package:messager_app/view/chat_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final myId = Supabase.instance.client.auth.currentUser!.id;
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  final ChatService _chatService = ChatService();

  late Future<List<Map<String, dynamic>>> futureConversation =
      _chatService.getChats();

  late final Stream<List<Map<String, dynamic>>> _conversationsStream;

  void logout() {
    setState(() {
      _authService.logout(context);
    });
  }

  @override
  void initState() {
    initializeData();
    super.initState();
  }

  void initializeData() async {
    try {
      // final profiles = await futureProfile;
      _conversationsStream = _chatService.getConversations();
    } catch (e) {
      print("Initialization Error: $e");
    }
  }

  String formatRealTime(String time) {
    DateTime dateTime = DateTime.parse(time).toLocal();

    timeago.setLocaleMessages('vi', timeago.ViMessages());
    return timeago.format(dateTime, locale: 'vi');
  }

  Widget _buildListConversations() {
    return StreamBuilder(
        stream: _conversationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return SizedBox.shrink();
          }
          final conversations = snapshot.data ?? [];
          return ListView.builder(
            itemCount: conversations.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              final conv = conversations[index];
              final List<dynamic> participants = conv['participant_ids'];
              final partnerId = participants.firstWhere((id) => id != myId);
              Future<Profile?> p = _profileService.fetchProfile(partnerId);
              Map<String, dynamic> unreadCounts = conv['unread_counts'];

              return FutureBuilder(
                  future: p,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return SizedBox.shrink();
                    }
                    final profile = snapshot.data!;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ChatPage(
                                      partnerId: profile.user_id,
                                      conversationId: conv['id'],
                                    )));
                      },
                      child: Container(
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
                            // SizedBox()),
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
                                    Text(conv['last_message'])
                                  ],
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Column(
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(formatRealTime(
                                      conv['last_message_time'])),
                                  unreadCounts[myId] == 0
                                      ? SizedBox.shrink()
                                      : Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(54),
                                              color: Colors.blue),
                                          padding: EdgeInsets.all(4),
                                          child: Text(
                                            unreadCounts[myId].toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            },
          );
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
                      onTap: () => logout(), child: Icon(Icons.edit_square))
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                "Chats",
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
              Expanded(child: _buildListConversations())
            ],
          ),
        ),
      ),
    );
  }
}
