import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:globalchat/screens/dashboard_screen.dart';

class SignupController {
  static Future<void> createAccount(
      {required BuildContext context,
      required String email,
      required String password}) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) {
        return DashboardScreen();
      }), (route) {
        return false;
      });

      print("Account Created Successfully");
    } catch (e) {
      SnackBar messageSnackbar =
          SnackBar(backgroundColor: Colors.red, content: Text(e.toString()));

      ScaffoldMessenger.of(context).showSnackBar(messageSnackbar);
    }
  }
}
