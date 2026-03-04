import 'package:flutter/material.dart';
import 'package:messager_app/model/item_chat_model.dart';
import 'package:messager_app/model/profie_model.dart';
import 'package:messager_app/service/auth_service.dart';
import 'package:messager_app/service/profile_service.dart';
import 'package:messager_app/view/chat_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final myId = Supabase.instance.client.auth.currentUser!.id;
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  late Future<List<Profile>> futureProfile = _profileService.fetchAllProfile();

  List<Profile> profiles = [];

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

  List<ItemChatModel> list = [
    ItemChatModel(
        avatar: 'assets/images/avatar.png',
        name: 'Thuy',
        last_text: "Hello",
        last_time: '16h05',
        unread_count: 4),
    ItemChatModel(
        avatar: 'assets/images/avatar.png',
        name: 'Thu',
        last_text: "Nivce",
        last_time: '16h05',
        unread_count: 10),
    ItemChatModel(
        avatar: 'assets/images/avatar.png',
        name: 'Huy',
        last_text: "Yossssssssssssssssssssssssssssss",
        last_time: '5h05',
        unread_count: 0),
    ItemChatModel(
        avatar: 'assets/images/avatar.png',
        name: 'Hoang',
        last_text: "Gssssssssssssssssssssssssssssssssssssso",
        last_time: '16h05',
        unread_count: 1)
  ];

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
              Expanded(
                  child: FutureBuilder(
                      future: futureProfile,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return SizedBox.shrink();
                        }
                        return ListView.builder(
                          itemCount: profiles.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            if (profiles[index].user_id == myId) {
                              return SizedBox.shrink();
                            }
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ChatPage(
                                              partner_id:
                                                  profiles[index].user_id,
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
                                            borderRadius:
                                                BorderRadius.circular(80),
                                            child: profiles[index]
                                                    .user_image
                                                    .isEmpty
                                                ? Image.asset(
                                                    list[index].avatar)
                                                : Image.network(profiles[index]
                                                    .user_image))),
                                    // SizedBox()),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              profiles[index].user_name.isEmpty
                                                  ? "New User"
                                                  : profiles[index].user_name,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(list[index].last_text)
                                          ],
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Column(
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(list[index].last_time),
                                          Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(54),
                                                  color: Colors.blue),
                                              padding: EdgeInsets.all(4),
                                              child: Text(
                                                list[index]
                                                    .unread_count
                                                    .toString(),
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
                          },
                        );
                      }))
              // Expanded(
              //   child: ListView.builder(
              //     itemCount: list.length,
              //     scrollDirection: Axis.vertical,
              //     itemBuilder: (context, index) {
              //       return GestureDetector(
              //         onTap: () {
              //           Navigator.push(
              //               context,
              //               MaterialPageRoute(
              //                   builder: (_) => ChatPage(
              //                         partner_id: "sss",
              //                       )));
              //         },
              //         child: Container(
              //           width: MediaQuery.sizeOf(context).width,
              //           margin: EdgeInsets.only(bottom: 12),
              //           child: Row(
              //             children: [
              //               Container(
              //                   width: 54,
              //                   height: 54,
              //                   child: ClipRRect(
              //                       borderRadius: BorderRadius.circular(80),
              //                       child: Image.asset(list[index].avatar))),
              //               // SizedBox()),
              //               SizedBox(
              //                 width: 12,
              //               ),
              //               Expanded(
              //                 child: Align(
              //                   alignment: Alignment.topLeft,
              //                   child: Column(
              //                     crossAxisAlignment: CrossAxisAlignment.start,
              //                     children: [
              //                       Text(
              //                         list[index].name,
              //                         style: TextStyle(
              //                             color: Colors.black,
              //                             fontSize: 16,
              //                             fontWeight: FontWeight.bold),
              //                       ),
              //                       Text(list[index].last_text)
              //                     ],
              //                   ),
              //                 ),
              //               ),
              //               Align(
              //                 alignment: Alignment.topRight,
              //                 child: Column(
              //                   // crossAxisAlignment: CrossAxisAlignment.start,
              //                   children: [
              //                     Text(list[index].last_time),
              //                     Container(
              //                         decoration: BoxDecoration(
              //                             borderRadius:
              //                                 BorderRadius.circular(54),
              //                             color: Colors.blue),
              //                         padding: EdgeInsets.all(4),
              //                         child: Text(
              //                           list[index].unread_count.toString(),
              //                           style: TextStyle(
              //                               fontWeight: FontWeight.bold,
              //                               color: Colors.white),
              //                         ))
              //                   ],
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
