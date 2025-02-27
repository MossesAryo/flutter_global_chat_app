import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:globalchat/firebase_options.dart';
import 'package:globalchat/providers/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:globalchat/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(ChangeNotifierProvider(
      create: (context) => UserProvider(), child: MyApp()));
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
            brightness: Brightness.light,
            fontFamily: "Poppins",
            useMaterial3: true),
        home: SplashScreen());
  }
}
