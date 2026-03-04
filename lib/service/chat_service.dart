import 'package:flutter/material.dart';
import 'package:messager_app/model/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final _supabase = Supabase.instance.client;

  Stream<List<Message>> getMessages(String partnerId) {
    final myId = _supabase.auth.currentUser!.id;

    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .handleError((error) {
          print("Error while Fetching Message $error");
        })
        .map((data) {
          // Lọc dữ liệu ngay tại Client
          final chatData = data.where((m) {
            final sId = m['sender_id'];
            final rId = m['receiver_id'];
            return (sId == myId && rId == partnerId) ||
                (sId == partnerId && rId == myId);
          }).toList();

          return chatData.map((json) => Message.fromJson(json)).toList();
        });
  }

  Future<void> sendMessage(String text, String partnerId) async {
    final myId = _supabase.auth.currentUser!.id;
    await _supabase.from('messages').insert({
      'sender_id': myId,
      'receiver_id': partnerId,
      'text': text,
    });
  }
}
