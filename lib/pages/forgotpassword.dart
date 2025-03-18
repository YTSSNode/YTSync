import 'package:animate_gradient/animate_gradient.dart';
import 'package:flutter/material.dart';
import 'package:timer_button/timer_button.dart';
import 'package:ytsync/main.dart';
import 'package:ytsync/network.dart';
import 'package:ytsync/util.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ForgotPasswordState createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPasswordPage> {
  ForgotPasswordState();

  bool loginPage = true;

  final TextEditingController _emailText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var actionText = ("Send Reset Link").padRight(23);
    actionText = actionText.padLeft(30);
    var theme = Theme.of(context);

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
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Enter your email to receive a reset link.",
                    style: TextStyle(fontFamily: "Pacifico"),
                  ),

                  SizedBox(height: 50.0),

                  SizedBox(
                    width: 350.0,
                    child: Column(
                      spacing: 15.0,
                      children: [
                        TextField(
                          controller: _emailText,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Email',
                          ),
                        ),

                        TextButton(
                          onPressed: () async {
                            if (_emailText.text.isEmpty) {
                              showSnackBar(context, "Please fill in your email.");
                              return;
                            }
                            
                            int timeDiff = DateTime.now().difference(appState.passwordTime).inSeconds;
                            if (timeDiff < 60) {
                              showSnackBar(context, "You've tried to send a password reset too often. Please wait ${60 - timeDiff} seconds.");
                              return;
                            }
                            appState.passwordTime = DateTime.now();
                            prefs?.setInt("passwordForgetTime", appState.passwordTime.microsecondsSinceEpoch);

                            String? msg = await resetPassword(_emailText.text);
                            if (msg == null) {
                              showSnackBar(context, "Reset password email sent.");
                            } else {
                              showSnackBar(context, msg);
                              appState.passwordTime = DateTime.fromMillisecondsSinceEpoch(0);
                              prefs?.setInt("passwordForgetTime", appState.passwordTime.microsecondsSinceEpoch);
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Colors.amberAccent,
                            ),
                          ),
                          child: Text(actionText),
                        )],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "GO BACK",
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
