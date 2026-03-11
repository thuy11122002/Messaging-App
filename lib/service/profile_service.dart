import 'dart:io';

import 'package:flutter/material.dart';
import 'package:messager_app/model/profie_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  Future<void> createUserProfile(String userName) async {
    final String userId = supabase.auth.currentUser!.id;

    try {
      await supabase
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
          await supabase.from("profile").select().eq("id", userId).single();

      return Profile.fromJson(reponse);
    } catch (e) {
      print("Error while fetching profile $e");
      return null;
    }
  }

  Future<List<Profile>> fetchAllProfile() async {
    // final String user_id = supabase.auth.currentUser!.id;
    try {
      final reponse = await supabase.from("profile").select();

      return (reponse as List).map((json) => Profile.fromJson(json)).toList();
    } catch (e) {
      print("Error while fetching profile $e");
      return [];
    }
  }

  // Future<Profile?> fetchProfile() async {
  //   final String user_id = supabase.auth.currentUser!.id;
  //   try {
  //     final reponse =
  //         await supabase.from("profile").select().eq("id", user_id).single();

  //     return Profile.fromJson(reponse);
  //   } catch (e) {
  //     print("Error while fetching profile $e");
  //     return null;
  //   }
  // }

  Future<void> updateProfile(
      File? file, String user_name, BuildContext context) async {
    final String user_id = supabase.auth.currentUser!.id;

    try {
      final file_name = 'avatar_${user_id}.jpg';
      final file_path = 'avatar/$file_name';

      print(file!.path);

      await supabase.storage.from("profile").upload(file_path, file,
          fileOptions: FileOptions(upsert: true, cacheControl: '3600'));
      final image_url =
          supabase.storage.from("profile").getPublicUrl(file_path);

      await supabase.from("profile").update(
          {'user_image': image_url, "user_name": user_name}).eq('id', user_id);

      // showSnackBar(context, "Saved");
    } on StorageException catch (e) {
      print("Error Storage: $e");
    } catch (e) {
      print("Error while Update $e");
    }
  }
}
