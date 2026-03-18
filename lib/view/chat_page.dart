import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final supabase = Supabase.instance.client;

  final myId = Supabase.instance.client.auth.currentUser?.id;
  final ChatService _chatService = ChatService();
  final ProfileService _profileService = ProfileService();

  late final Stream<List<Message>> _messagesStream;

  late Future<Profile?> futureProfile =
      _profileService.fetchProfile(widget.partnerId);

  final TextEditingController messagesController = TextEditingController();

  bool change = false;

  File? imageFile;
  XFile? image;

  Future<void> pickImage() async {
    final String myId = supabase.auth.currentUser!.id;

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

  Future<void> upload(XFile? image) async {
    try {
      _chatService.sendImage(imageFile, widget.partnerId);
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
              final isMe = msg.senderId == myId;

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: msg.image.isEmpty
                        ? Text(
                            msg.text,
                            style: TextStyle(
                                color: isMe ? Colors.white : Colors.black),
                          )
                        : Container(
                            width: 120,
                            child:
                                Image.network(msg.image, fit: BoxFit.cover))),
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
          Profile? profile = snapshot.data!;
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
                      child: profile.userImage.isEmpty
                          ? Image.asset("assets/images/avatar.png")
                          : Image.network(profile.userImage))),
              SizedBox(
                width: 12,
              ),
              Text(
                profile.userName.isEmpty ? "New User" : profile.userName,
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
            imageFile != null
                ? Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Container(
                            width: 120,
                            height: 120,
                            margin: EdgeInsets.only(top: 12),
                            child: Image.file(
                              imageFile!,
                              fit: BoxFit.cover,
                            )),
                        SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                            onTap: () {
                              imageFile = null;
                              setState(() {});
                            },
                            child: Icon(Icons.cancel))
                      ],
                    ),
                  )
                : SizedBox.shrink(),
            SizedBox(
              height: 12,
            ),
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      pickImage();
                    },
                    child: imageFile != null
                        ? Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                color: Colors.blue),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          )
                        : Icon(Icons.add)),
                SizedBox(
                  width: 12,
                ),
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.75,
                  child: TextField(
                    controller: messagesController,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                GestureDetector(
                    onTap: () {
                      if (image != null) {
                        upload(image);
                        imageFile = null;

                        setState(() {});
                      } else {
                        if (messagesController.text == "" ||
                            messagesController.text.isEmpty) {
                          return;
                        } else {
                          _chatService.sendMessage(
                              messagesController.text, widget.partnerId);
                          _chatService.increUnreadCount(
                              widget.conversationId, widget.partnerId);
                          setState(() {
                            messagesController.clear();
                          });
                        }
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
