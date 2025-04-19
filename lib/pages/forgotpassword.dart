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
                    "Please contact the General Office for your password to be reset.",
                    style: TextStyle(fontFamily: "instruct"),
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
