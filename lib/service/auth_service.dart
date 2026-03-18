import 'package:flutter/material.dart';
import 'package:messager_app/service/profile_service.dart';
import 'package:messager_app/view/login_page.dart';
import 'package:messager_app/view/widgets/snackBar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;
  final ProfileService _profileService = ProfileService();

  Future<String?> signUp(String email, String password, String userName) async {
    try {
      final response = await supabase.auth.signUp(
        password: password,
        email: email,
      );
      _profileService.createUserProfile(userName);
      return "Success";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        password: password,
        email: email,
      );

      if (response.user != null) {
        return null;
      }

      return "Email or pass is invalid, please try again";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await supabase.auth.signOut();
      if (!context.mounted) return;
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
    } catch (e) {
      print("Logout error $e");
    }
  }

  Future<String> changePassword(String oldPassword, String newPassword) async {
    try {
      final email = supabase.auth.currentUser!.email;

      final response = await supabase.auth.signInWithPassword(
        password: oldPassword,
        email: email,
      );

      if (response.user != null) {
        final UserResponse res = await supabase.auth.updateUser(
          UserAttributes(
            password: newPassword,
          ),
        );
        return "Successful";
      } else {
        print("Old Password is wrong");

        return "Old Password is wrong";
      }
    } catch (e) {
      print("Error while changing Password: $e");
      return "Error";
    }
  }
}
