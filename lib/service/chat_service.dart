import 'dart:io';

import 'package:messager_app/model/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart' as uuid;

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

  Future<void> sendImage(File? file, String partnerId) async {
    final myId = _supabase.auth.currentUser!.id;

    try {
      String unique = uuid.Uuid().v4();
      final fileName = '${unique}.jpg';
      print(fileName);
      final filePath = fileName;

      await _supabase.storage.from("chat_images").upload(filePath, file!,
          fileOptions: FileOptions(upsert: true, cacheControl: '3600'));
      final imageUrl =
          _supabase.storage.from("chat_images").getPublicUrl(filePath);
      await _supabase.from('messages').insert({
        'sender_id': myId,
        'receiver_id': partnerId,
        'text': "",
        'image': imageUrl
      });

      await _supabase.from('conversations').update({
        'last_message': 'Sent an image',
        'last_sender_id': myId,
        'last_message_time': DateTime.now().toUtc().toIso8601String()
      }).contains('participant_ids', [myId, partnerId]);

      // showSnackBar(context, "Saved");
    } on StorageException catch (e) {
      print("Error Storage: $e");
    } catch (e) {
      print("Error while Update $e");
    }
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

  Future<List<Map<String, dynamic>>> findConversations(String query) async {
    final myId = _supabase.auth.currentUser!.id;
    List<Map<String, dynamic>> enrichedConversations = [];

    try {
      if (query.isEmpty) {
        return await _supabase
            .from('conversations')
            .select()
            .contains('participant_ids', [myId]);
      } else {
        final ids = await _supabase
            .from("profile")
            .select("id")
            .ilike("user_name", '%$query%');

        for (var id in (ids as List).map((e) => e['id']).toList()) {
          if (id != myId) {
            final conversation = await _supabase
                .from("conversations")
                .select()
                .contains('participant_ids', [myId, id]).single();
            enrichedConversations.add(conversation);
          }
        }
      }
      return enrichedConversations;
    } catch (e) {
      print("Error while Searching: $e");
      return [];
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
}
