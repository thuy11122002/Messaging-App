import 'package:flutter/material.dart';
import 'package:messager_app/model/profie_model.dart';
import 'package:messager_app/service/chat_service.dart';
import 'package:messager_app/service/profile_service.dart';
import 'package:messager_app/view/chat_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class SearchChat extends StatefulWidget {
  const SearchChat({super.key});

  @override
  State<SearchChat> createState() => _SearchChatState();
}

class _SearchChatState extends State<SearchChat> {
  final myId = Supabase.instance.client.auth.currentUser!.id;
  final ChatService _chatService = ChatService();
  final ProfileService _profileService = ProfileService();

  late Future<List<Profile>> futureProfile = _profileService.fetchAllProfile();

  List<Profile> profiles = [];
  List<Map<String, dynamic>> conversations = [];

  @override
  void initState() {
    initializeData();
    super.initState();
  }

  void initializeData() async {
    try {
      // _conversationsStream = _chatService.getConversations();

      final profiles = await futureProfile;
      final conversations = await futureConversations;
      if (profiles.isNotEmpty) {
        setState(() {
          this.profiles = profiles;
          this.conversations = conversations;
        });
      }
    } catch (e) {
      print("Initialization Error: $e");
    }
  }

  final TextEditingController searchController = TextEditingController();
  String searchValue = "";

  late Future<List<Map<String, dynamic>>> futureConversations =
      _chatService.findConversations(searchValue);

  String formatRealTime(String time) {
    DateTime dateTime = DateTime.parse(time).toLocal();

    timeago.setLocaleMessages('vi', timeago.ViMessages());
    return timeago.format(dateTime, locale: 'vi');
  }

  Widget _buildFindPeopleList() {
    return FutureBuilder(
        future: futureConversations,
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
                                      partnerId: profile.userId,
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
                                    child: profile.userImage.isEmpty
                                        ? Image.asset(
                                            "assets/images/avatar.png")
                                        : Image.network(profile.userImage))),
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
                                      profile.userName.isEmpty
                                          ? "New User"
                                          : profile.userName,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
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
                children: [Icon(Icons.more_horiz), Icon(Icons.edit_square)],
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.arrow_back_ios_new)),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    "Search",
                    style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Container(
                    width: MediaQuery.sizeOf(context).width * 0.8,
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), hintText: "Search"),
                      onChanged: (value) {
                        searchController.text;
                        // _onSearchChanged(value);
                        setState(() {
                          searchValue = value;
                          futureConversations =
                              _chatService.findConversations(searchValue);
                        });
                      },
                    ),
                  ),
                  Expanded(child: SizedBox()),
                  Icon(Icons.sort_sharp)
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Expanded(child: _buildFindPeopleList())
            ],
          ),
        ),
      ),
    );
  }
}
