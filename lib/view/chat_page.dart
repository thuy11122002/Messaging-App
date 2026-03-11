import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:messager_app/model/message_model.dart';
import 'package:messager_app/model/profie_model.dart';
import 'package:messager_app/service/chat_service.dart';
import 'package:messager_app/service/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatPage extends StatefulWidget {
  final String partnerId, conversationId;

  ChatPage({required this.partnerId, required this.conversationId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final myId = Supabase.instance.client.auth.currentUser?.id;
  final ChatService _chatService = ChatService();
  final ProfileService _profileService = ProfileService();

  late final Stream<List<Message>> _messagesStream;

  late Future<Profile?> futureProfile =
      _profileService.fetchProfile(widget.partnerId);

  final messages_controller = TextEditingController();

  @override
  void initState() {
    initializeData();
    super.initState();
  }

  void initializeData() async {
    try {
      _messagesStream = _chatService.getMessages(widget.partnerId);
      _chatService.resetUnreadCount(widget.conversationId);
    } catch (e) {
      print("Initialization Error: $e");
    }
  }

  String formatRealTime(String time) {
    DateTime dateTime = DateTime.parse(time).toLocal();

    timeago.setLocaleMessages('vi', timeago.ViMessages());
    return timeago.format(dateTime, locale: 'vi');
  }

  Widget _buildListMessage() {
    return StreamBuilder(
        stream: _messagesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return SizedBox.shrink();
          }
          final messages = snapshot.data!;
          return ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final isMe = msg.sender_id == myId;

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(color: isMe ? Colors.white : Colors.black),
                  ),
                ),
              );
            },
          );
        });
  }

  Widget _buidlProfilePartner() {
    return FutureBuilder(
        future: futureProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return SizedBox.shrink();
          }

          return Row(
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back_ios)),
              SizedBox(
                width: 12,
              ),
              Container(
                  width: 54,
                  height: 54,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(80),
                      child: snapshot.data!.user_image.isEmpty
                          ? Image.asset("assets/images/avatar.png")
                          : Image.network(snapshot.data!.user_image))),
              SizedBox(
                width: 12,
              ),
              Text(
                snapshot.data!.user_name.isEmpty
                    ? "New User"
                    : snapshot.data!.user_name,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              )
            ],
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
          children: [
            _buidlProfilePartner(),
            Expanded(child: _buildListMessage()),
            SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Icon(Icons.add),
                SizedBox(
                  width: 12,
                ),
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.75,
                  child: TextField(
                    controller: messages_controller,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                GestureDetector(
                    onTap: () {
                      if (messages_controller.text == "" ||
                          messages_controller.text.isEmpty) {
                        return;
                      } else {
                        _chatService.sendMessage(
                            messages_controller.text, widget.partnerId);
                        _chatService.increUnreadCount(
                            widget.conversationId, widget.partnerId);
                        setState(() {
                          messages_controller.clear();
                        });
                      }
                    },
                    child: Icon(Icons.send))
              ],
            )
          ],
        ),
      )),
    );
  }
}
