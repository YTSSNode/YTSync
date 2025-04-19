import 'package:animate_gradient/animate_gradient.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ytsync/main.dart';
import 'package:ytsync/network.dart';
import 'package:ytsync/pages/forgotpassword.dart';
import 'package:ytsync/pages/homepage.dart';
import 'package:ytsync/util.dart';

import '../util.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  LogInPageState createState() => LogInPageState();
}

class LogInPageState extends State<LogInPage> {
  LogInPageState();

  final TextEditingController _serialNumText = TextEditingController();
  final TextEditingController _passText = TextEditingController();

  final ForgotPasswordPage forgotPassPage = ForgotPasswordPage();

  bool loginButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var titleStyle =
        theme.textTheme.titleMedium?.copyWith(
          fontFamily: "ytlogo",
          fontSize: 80.0, // Reduced font size for a cleaner look
          fontWeight: FontWeight.bold,
          letterSpacing: 3.5,
        ) ??
        TextStyle(
          fontFamily: "ytlogo",
          fontSize: 40.0,
          fontWeight: FontWeight.bold,
        );

    return Scaffold(
      body: AnimateGradient(
        primaryBegin: Alignment.topLeft,
        primaryEnd: Alignment.bottomLeft,
        secondaryBegin: Alignment.bottomRight,
        secondaryEnd: Alignment.topLeft,
        primaryColors: const [
          Color.fromARGB(255, 206, 251, 251),
          Color.fromARGB(255, 253, 230, 187),
        ],
        secondaryColors: const [
          Color.fromARGB(255, 253, 230, 187),
          Color.fromARGB(255, 206, 251, 251),
        ],
        duration: Duration(seconds: 15),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // School Logo at the top
                    Image.asset(
                      'assets/logo.png',
                      height: 100, // Adjust height as needed
                    ),
                    SizedBox(height: 10),

                    // YTSync Title
                    Text("YTSync", style: titleStyle),
                    SizedBox(height: 20),

                    // Login Text
                    Text("Please log in below.", style: TextStyle(fontFamily: "instruct", fontSize: 16)),
                    SizedBox(height: 10),

                    // Form Fields
                    SizedBox(
                      width: 350.0,
                      child: Column(
                        children: [
                          SizedBox(height: 15),
                          TextField(
                            controller: _serialNumText,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Identification Number',
                            ),
                          ),
                          SizedBox(height: 15),
                          TextField(
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            controller: _passText,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Password',
                            ),
                          ),

                          SizedBox(height: 10),

                          SizedBox(height: 5),

                          // Forgot Password Link
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => forgotPassPage,
                                  ),
                                );
                              },
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 10.0),

                          // Login/Signup Button
                          ElevatedButton(
                            onPressed: () async {
                              if (loginButtonDisabled) return;

                              if (_serialNumText.text.isEmpty) {
                                showSnackBar(
                                  context,
                                  "Please fill in your ID number.",
                                );
                                return;
                              }
                              
                              if (_passText.text.isEmpty) {
                                showSnackBar(
                                  context,
                                  "Please fill in your password.",
                                );
                                return;
                              }

                              showSnackBar(
                                context,
                                "Logging in. Please wait."
                              );
                              loginButtonDisabled = true;

                              var result = await firebaseInit(
                                true,
                                _serialNumText.text,
                                _passText.text
                              );

                              if (result.$1) {
                                if (context.mounted) {
                                  showSnackBar(
                                    context, "Login success!"
                                  );

                                  prefs?.setString(
                                    "credential-id",
                                    _serialNumText.text,
                                  );
                                  prefs?.setString(
                                    "credential-pass",
                                    _passText.text,
                                  );

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomePage(),
                                    ),
                                  );
                                }
                              } else if (context.mounted) {
                                showSnackBar(context, result.$2);
                              }
                              loginButtonDisabled = false;
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                Colors.amberAccent,
                              ),
                              padding: WidgetStateProperty.all(
                                EdgeInsets.symmetric(
                                  horizontal: 50,
                                  vertical: 15,
                                ),
                              ),
                            ),
                            child: Text("Log In"),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
