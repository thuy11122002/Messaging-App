import 'dart:io';

import 'package:flutter/material.dart';
import 'package:messager_app/model/profie_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final _supabase = Supabase.instance.client;

  Future<void> createUserProfile(String userName) async {
    final String userId = _supabase.auth.currentUser!.id;

    try {
      await _supabase
          .from("profile")
          .insert({"id": userId, "user_name": userName});
    } catch (e) {
      print("Error while create profile $e");
    }
  }

  Future<Profile?> fetchProfile(String userId) async {
    // final String user_id = supabase.auth.currentUser!.id;
    try {
      final reponse =
          await _supabase.from("profile").select().eq("id", userId).single();

      return Profile.fromJson(reponse);
    } catch (e) {
      print("Error while fetching profile $e");
      return null;
    }
  }

  Future<List<Profile>> fetchAllProfile() async {
    // final String user_id = supabase.auth.currentUser!.id;
    try {
      final reponse = await _supabase.from("profile").select();

      return (reponse as List).map((json) => Profile.fromJson(json)).toList();
    } catch (e) {
      print("Error while fetching profile $e");
      return [];
    }
  }

  Future<void> updateProfile(
      File? file, String userName, BuildContext context) async {
    final String userId = _supabase.auth.currentUser!.id;

    try {
      if (file == null) {
        await _supabase
            .from("profile")
            .update({"user_name": userName}).eq('id', userId);
      } else {
        final fileName = 'avatar_${userId}.jpg';
        final filePath = 'avatar/$fileName';

        await _supabase.storage.from("profile").upload(filePath, file!,
            fileOptions: FileOptions(upsert: true, cacheControl: '3600'));
        final imageUrl =
            _supabase.storage.from("profile").getPublicUrl(filePath);

        await _supabase.from("profile").update(
            {'user_image': imageUrl, "user_name": userName}).eq('id', userId);
      }

      // showSnackBar(context, "Saved");
    } on StorageException catch (e) {
      print("Error Storage: $e");
    } catch (e) {
      print("Error while Update $e");
    }
  }

  Future<void> updateUsername(String userName) async {
    final String userId = _supabase.auth.currentUser!.id;

    try {
      await _supabase
          .from("profile")
          .update({"user_name": userName}).eq('id', userId);

      // showSnackBar(context, "Saved");
    } on StorageException catch (e) {
      print("Error Storage: $e");
    } catch (e) {
      print("Error while Update $e");
    }
  }

  Future<List<Profile>> findPeople(String query) async {
    // final myId = _supabase.auth.currentUser!.id;

    try {
      if (query.isEmpty) {
        final reponse = await _supabase.from('profile').select();
        return (reponse as List).map((json) => Profile.fromJson(json)).toList();
      } else {
        final reponse = await _supabase
            .from("profile")
            .select()
            .ilike("user_name", '%$query%');
        print(reponse);
        return (reponse as List).map((json) => Profile.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error while Searching People: $e");
      return [];
    }
  }
}
