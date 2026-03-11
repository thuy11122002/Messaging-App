import 'package:flutter/material.dart';
import 'package:messager_app/model/item_chat_model.dart';
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
          final chatData = data.where((m) {
            final sId = m['sender_id'];
            final rId = m['receiver_id'];
            return (sId == myId && rId == partnerId) ||
                (sId == partnerId && rId == myId);
          }).toList();

          return chatData.map((json) => Message.fromJson(json)).toList();
        });
  }

  Stream<List<Map<String, dynamic>>> getConversations() {
    final myId = _supabase.auth.currentUser!.id;

    return _supabase
        .from('conversations')
        .stream(primaryKey: ['id'])
        .order('last_message_time', ascending: false)
        .map((data) {
          return data.where((conv) {
            final List participants = conv['participant_ids'] ?? [];
            return participants.contains(myId);
          }).toList();
        });
  }

  Future<List<Map<String, dynamic>>> getChats() async {
    final myId = _supabase.auth.currentUser!.id;
    try {
      return await _supabase
          .from('conversations')
          .select()
          .not('participant_ids', 'cs', [myId]).order('last_message_time',
              ascending: false);
    } catch (e) {
      print("Error while fetching $e");
      return [];
    }
  }

  Future<void> sendMessage(String text, String partnerId) async {
    final myId = _supabase.auth.currentUser!.id;
    await _supabase.from('messages').insert({
      'sender_id': myId,
      'receiver_id': partnerId,
      'text': text,
    });
    await _supabase.from('conversations').update({
      'last_message': text,
      'last_sender_id': myId,
      'last_message_time': DateTime.now().toUtc().toIso8601String()
    }).contains('participant_ids', [myId, partnerId]);
  }

  Future<void> addChat(String partnerId) async {
    final myId = _supabase.auth.currentUser!.id;
    try {
      final existing = await _supabase
          .from('conversations')
          .select()
          .contains('participant_ids', [myId, partnerId]).maybeSingle();

      if (existing != null) {
        print("Already add");
        return;
      }

      await _supabase
          .from('conversations')
          .insert({
            'participant_ids': [myId, partnerId],
            'last_message': "",
            'unread_counts': {
              myId: 0,
              partnerId: 0,
            }
          })
          .select()
          .single();
    } catch (e) {
      print("Error while adding $e");
      rethrow;
    }
  }

  Future<void> resetUnreadCount(String conversationId) async {
    final myId = _supabase.auth.currentUser!.id;

    final data = await _supabase
        .from('conversations')
        .select('unread_counts')
        .eq('id', conversationId)
        .single();

    Map<String, dynamic> unreadCounts = data['unread_counts'];

    unreadCounts[myId] = 0;

    await _supabase
        .from('conversations')
        .update({'unread_counts': unreadCounts}).eq('id', conversationId);
  }

  Future<void> increUnreadCount(String conversationId, String partnerId) async {
    await _supabase.rpc('increment_unread_count', params: {
      'conv_id': conversationId,
      'user_id': partnerId,
    });
  }

  Future<bool> checkConversation(String partnerId) async {
    final myId = _supabase.auth.currentUser!.id;

    try {
      final reponse = await _supabase
          .from('conversations')
          .select()
          .contains('participant_ids', [myId, partnerId]);
      if (reponse.isEmpty) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print("Error : $e");
      return false;
    }
  }

  // Future<List<ItemChatModel>> getChats() async{
  //   final myId = _supabase.auth.currentUser!.id;
  //   final reponse = await _supabase.from('chatrooms').select()
  // }
}
