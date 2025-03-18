import 'package:animate_gradient/animate_gradient.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ytsync/main.dart';
import 'package:ytsync/network.dart';
import 'package:ytsync/pages/forgotpassword.dart';
import 'package:ytsync/pages/homepage.dart';
import 'package:ytsync/util.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  LogInPageState createState() => LogInPageState();
}

class LogInPageState extends State<LogInPage> {
  LogInPageState();

  bool loginPage = true;

  final TextEditingController _emailText = TextEditingController();
  final TextEditingController _passText = TextEditingController();
  final TextEditingController _nameText = TextEditingController();
  final TextEditingController _confirmPassText = TextEditingController();
  final TextEditingController _classText = TextEditingController();
  final TextEditingController _registerNumText = TextEditingController();

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
                    Text(
                      loginPage
                          ? "Please log in below."
                          : "Please sign up below",
                      style: TextStyle(fontFamily: "instruct", fontSize: 16),
                    ),
                    SizedBox(height: 10),

                    // Form Fields
                    SizedBox(
                      width: 350.0,
                      child: Column(
                        children: [
                          if (!loginPage)
                            TextField(
                              controller: _nameText,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Username',
                              ),
                            ),

                          SizedBox(height: 15),
                          TextField(
                            controller: _emailText,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Email',
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

                          if (!loginPage)
                            TextField(
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              controller: _confirmPassText,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Confirm Password',
                              ),
                            ),

                          if (!loginPage) SizedBox(height: 10),

                          if (!loginPage)
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    maxLength: 2,
                                    controller: _classText,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Class',
                                      counterText: "",
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: TextField(
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    controller: _registerNumText,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Register Number',
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          SizedBox(height: 5),

                          // Forgot Password Link
                          if (loginPage)
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

                              if (!loginPage && _nameText.text.isEmpty) {
                                showSnackBar(
                                  context,
                                  "Please fill in your username.",
                                );
                                return;
                              }
                              if (_emailText.text.isEmpty) {
                                showSnackBar(
                                  context,
                                  "Please fill in your email.",
                                );
                                return;
                              }
                              if (_passText.text.isEmpty) {
                                showSnackBar(
                                  context,
                                  "Please fill in your password.",
                                );
                                return;
                              } else if (!loginPage) {
                                if (_passText.text.length < 8) {
                                  showSnackBar(
                                    context,
                                    "Password must be at least 8 characters long.",
                                  );
                                  return;
                                } else if (!RegExp(
                                      r'[a-zA-Z]',
                                    ).hasMatch(_passText.text) ||
                                    !RegExp(r'\d').hasMatch(_passText.text)) {
                                  showSnackBar(
                                    context,
                                    "Password must have at least one alphabet and one number.",
                                  );
                                  return;
                                }
                              }

                              if (!loginPage) {
                                if (_confirmPassText.text.isEmpty) {
                                  showSnackBar(
                                    context,
                                    "Please confirm your password.",
                                  );
                                  return;
                                } else if (_confirmPassText.text !=
                                    _passText.text) {
                                  showSnackBar(
                                    context,
                                    "Passwords do not match. Retype 'Confirm Password'.",
                                  );
                                  return;
                                }
                              }

                              if (!loginPage) {
                                if (_classText.text.isEmpty) {
                                  showSnackBar(
                                    context,
                                    "Please fill in your form class.",
                                  );
                                  return;
                                } else if (int.tryParse(_classText.text[0]) == null ||
                                    !RegExp(
                                      r'[a-zA-Z]',
                                    ).hasMatch(_classText.text[1])) {
                                  showSnackBar(
                                    context,
                                    "Class format is invalid. (eg: 4F)",
                                  );
                                  return;
                                } else if ((int.tryParse(_classText.text[0]) ??
                                            5) >=
                                        5 ||
                                    (int.tryParse(_classText.text[0]) ?? 0) <=
                                        0) {
                                  showSnackBar(
                                    context,
                                    "Classes can only be 1 to 4. (eg: 1A, 2A, 3A, 4A)",
                                  );
                                  return;
                                }
                              }

                              if (!loginPage) {
                                if (_registerNumText.text.isEmpty) {
                                  showSnackBar(
                                    context,
                                    "Please fill in your register number.",
                                  );
                                  return;
                                }
                              }

                              showSnackBar(
                                context,
                                loginPage
                                    ? "Logging in. Please wait."
                                    : "Signing you up! Please wait.",
                              );
                              loginButtonDisabled = true;

                              var result = await firebaseInit(
                                true,
                                _emailText.text,
                                _passText.text,
                                loginPage ? null : _nameText.text,
                                _classText.text,
                                _registerNumText.text,
                              );

                              if (result.$1) {
                                if (context.mounted) {
                                  showSnackBar(
                                    context,
                                    loginPage
                                        ? "Login success!"
                                        : "Sign up success. Welcome to YTSync!",
                                  );

                                  prefs?.setString(
                                    "credential-email",
                                    _emailText.text,
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
                            child: Text(loginPage ? "Log In" : "Sign Up"),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Switch between Login/Signup
                    TextButton(
                      onPressed: () {
                        setState(() {
                          loginPage = !loginPage;
                        });
                      },
                      child: Text(
                        loginPage
                            ? "Don't have an account? Sign up instead."
                            : "Log in instead.",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
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
