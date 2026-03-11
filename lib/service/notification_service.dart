import 'package:flutter/material.dart';
import 'package:messager_app/model/notification_model.dart';
import 'package:messager_app/service/chat_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final _supabase = Supabase.instance.client;
  final ChatService _chatService = ChatService();

  Future<void> createNotification(String partnerId) async {
    final myId = _supabase.auth.currentUser!.id;
    try {
      await _supabase
          .from("notifications")
          .insert({'sender_id': myId, 'receiver_id': partnerId});
    } catch (e) {
      print("Error while send notify: $e");
    }
  }

  Future<bool> checkNotification(String partnerId) async {
    final myId = _supabase.auth.currentUser!.id;
    try {
      final reponse = await _supabase
          .from("notifications")
          .select()
          .or("sender_id.eq.$myId,sender_id.eq.$partnerId")
          .or("receiver_id.eq.$partnerId,receiver_id.eq.$myId");
      if (reponse.isEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error while checking : $e");
      return false;
    }
  }

  Future<void> acceptNotify(String partnerId) async {
    final myId = _supabase.auth.currentUser!.id;

    try {
      _chatService.addChat(partnerId);
      await _supabase
          .from("notifications")
          .update({'accepted': true})
          .eq('sender_id', partnerId)
          .eq('receiver_id', myId);
    } catch (e) {
      print('Error while acepting : $e');
    }
  }

  Future<void> unacceptNotify(String partnerId) async {
    final myId = _supabase.auth.currentUser!.id;

    try {
      await _supabase
          .from("notifications")
          .delete()
          .eq('sender_id', partnerId)
          .eq('receiver_id', myId);
    } catch (e) {
      print('Error while unacepting : $e');
    }
  }

  Future<List<NotificationModel>> getAllNotification() async {
    final myId = _supabase.auth.currentUser!.id;

    try {
      final reponse = await _supabase
          .from("notifications")
          .select()
          .eq('receiver_id', myId);
      return (reponse as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print("Error while fetching notifications $e");
      return [];
    }
  }
}
