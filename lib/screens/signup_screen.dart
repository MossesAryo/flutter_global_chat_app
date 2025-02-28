import 'package:flutter/material.dart';
import 'package:globalchat/controllers/signup_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  var userForm = GlobalKey<FormState>();

  bool isLoading = false;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController country = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: userForm,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      SizedBox(child: Image.asset("assets/images/logo.png")),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: email,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email is required ";
                          }
                        },
                        decoration: InputDecoration(label: Text("Email")),
                      ),
                      SizedBox(
                        height: 23,
                      ),
                      TextFormField(
                        controller: password,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password is required ";
                          }
                        },
                        obscureText: true,
                        enableSuggestions: true,
                        autocorrect: false,
                        decoration: InputDecoration(label: Text("Password")),
                      ),
                      SizedBox(
                        height: 23,
                      ),
                      TextFormField(
                        controller: name,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Name is required ";
                          }
                        },
                        decoration: InputDecoration(label: Text("Name")),
                      ),
                      SizedBox(
                        height: 23,
                      ),
                      TextFormField(
                        controller: country,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password is required ";
                          }
                        },
                        decoration: InputDecoration(label: Text("country")),
                      ),
                      SizedBox(
                        height: 23,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    minimumSize: Size(0, 50),
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.blue),
                                onPressed: () async {
                                  if (userForm.currentState!.validate()) {
                                    isLoading = true;
                                    setState(() {});
                                    await SignupController.createAccount(
                                        context: context,
                                        email: email.text,
                                        password: password.text,
                                        name: name.text,
                                        country: country.text);
                                    isLoading = false;
                                    setState(() {});
                                  }
                                },
                                child: isLoading
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text("Create Account")),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
