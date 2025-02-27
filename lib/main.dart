import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:globalchat/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: "Poppins",
          useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Global Chat'),
        ),
        body: Center(
          child: Text("Firebase looking fine"),
        ),
      ),
    );
  }
}
