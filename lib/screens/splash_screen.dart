import 'package:flutter/material.dart';
import 'package:globalchat/providers/userProvider.dart';
import 'package:globalchat/screens/dashboard_screen.dart';
import 'package:globalchat/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), () {
      if (user == null) {
        openLogin();
      } else {
        openDashboard();
      }
    });

    // TODO: implement initState
    super.initState();
  }

  void openDashboard() {
    Provider.of<UserProvider>(context,listen: false).getUserDetails();

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return DashboardScreen();
    }));
  }

  void openLogin() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return LoginScreen();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(child: Image.asset("assets/images/logo.png")),
      ),
    );
  }
}
