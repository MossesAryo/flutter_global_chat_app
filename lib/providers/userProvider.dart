import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String userName = "";
  String userEmail = "";
  String userId = "";

  var db = FirebaseFirestore.instance;
  var authUser = FirebaseAuth.instance.currentUser;

  void getUserDetails() {
    db.collection("users").doc(authUser!.uid).get().then((dataSnapshot) {
      userName = dataSnapshot.data()?["name"] ?? "";
      userId = dataSnapshot.data()?["id"] ?? "";
      userEmail = dataSnapshot.data()?["email"] ?? "";
      notifyListeners();
    });
  }
}
