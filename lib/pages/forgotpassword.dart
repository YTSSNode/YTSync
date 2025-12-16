import 'package:flutter/material.dart';
import 'package:ytsync/main.dart';
import 'package:ytsync/network.dart';
import 'package:ytsync/util.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ForgotPasswordState createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPasswordPage> {
  final TextEditingController _emailText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isPhone = size.width < 600;
    final isTablet = size.width > 600;

    final double cardWidth = isTablet ? 420 : 350;
    final double titleFont = isTablet ? 46 : 38;
    final double logoHeight = isTablet ? 220 : 180;
    final double inputFont = isTablet ? 18 : 16;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.light && appState.selectedTheme != 'ytss'
              ? Colors.grey[200]
              : theme.brightness == Brightness.dark
                  ? Colors.grey[900]
                  : null,
          gradient: appState.selectedTheme == 'ytss'
              ? const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 3, 0, 47),
                    Color.fromARGB(255, 32, 16, 255),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: cardWidth),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //=== LOGO ===
                    Column(
                      children: [
                        Image.asset('assets/logo.png', height: 140),
                        const SizedBox(height: 10),
                      ],
                    ),

                    //=== TITLE ===
                    Stack(
                      children: [
                        Text(
                          "YTSync",
                          style: TextStyle(
                            fontFamily: "ytlogonew",
                            fontSize: titleFont,
                            letterSpacing: 3.5,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 4
                              ..color = appState.selectedTheme == 'ytss'
                                  ? const Color.fromARGB(255, 0, 0, 0)
                                  : appState.selectedTheme == 'light'
                                      ? const Color.fromARGB(255, 255, 255, 255)
                                      : const Color.fromARGB(255, 89, 89, 89),
                          ),
                        ),
                        Text(
                          "YTSync",
                          style: TextStyle(
                            fontFamily: "ytlogonew",
                            fontSize: titleFont,
                            letterSpacing: 3.5,
                            fontWeight: FontWeight.w400,
                            color: appState.selectedTheme == 'ytss'
                                ? const Color(0xFFFFC700)
                                : appState.selectedTheme == 'light'
                                    ? const Color(0xFF0070D1)
                                    : Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    //=== PASSWORD RESET BOX ===
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        border: Border.all(
                          color: appState.selectedTheme == 'ytss'
                              ? Colors.grey[300]!
                              : appState.selectedTheme == 'light'
                                  ? const Color(0xFF0070D1)
                                  : Colors.white.withOpacity(0.8),
                            width: 3.0,
                          ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          //=== HEADER ===
                          Stack(
                            children: [
                              Text(
                                "Forgot your password?",
                                style: TextStyle(
                                  fontFamily: "montserrat",
                                  fontSize: isTablet ? 22 : 18,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 1.5
                                    ..color = appState.selectedTheme == 'dark'
                                        ? Colors.grey[700]!
                                        : Colors.grey[300]!,
                                ),
                              ),
                              Text(
                                "Forgot your password?",
                                style: TextStyle(
                                  fontFamily: "montserrat",
                                  fontSize: isTablet ? 22 : 18,
                                  color: appState.selectedTheme == 'ytss'
                                      ? Colors.black
                                      : theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: Text(
                              "Enter your email to receive a password reset link.",
                              style: TextStyle(
                                fontFamily: "montserrat",
                                fontSize: 14,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          //=== EMAIL INPUT ===
                          TextField(
                            inputFormatters: [
                              TextInputFormatter.withFunction(
                                (oldValue, newValue) {
                                  final text = newValue.text
                                      .toLowerCase()
                                      .replaceAll(RegExp(r'[^a-z0-9@_.]'), '');
                                  return TextEditingValue(
                                    text: text,
                                    selection:
                                        TextSelection.collapsed(offset: text.length),
                                  );
                                },
                              ),
                            ],
                            controller: _emailText,
                            style: TextStyle(
                              fontFamily: "montserrat",
                              fontSize: inputFont,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(
                                fontFamily: "montserrat",
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 75, 75, 75),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: appState.selectedTheme == 'ytss'
                                      ? const Color(0xFFFFC700)
                                      : theme.brightness == Brightness.dark
                                          ? Colors.white
                                          : const Color(0xFF0070D1),
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          //=== SEND BUTTON ===
                          ElevatedButton(
                            onPressed: () async {
                              if (_emailText.text.isEmpty) {
                                showSnackBar(context, "Please fill in your email.");
                                return;
                              }

                              int timeDiff = DateTime.now()
                                  .difference(appState.passwordTime)
                                  .inSeconds;
                              if (timeDiff < 60) {
                                showSnackBar(context,
                                    "You've tried to send a password reset too often. Please wait ${60 - timeDiff} seconds.");
                                return;
                              }

                              appState.passwordTime = DateTime.now();
                              prefs?.setInt("passwordForgetTime",
                                  appState.passwordTime.microsecondsSinceEpoch);

                              String? msg = await resetPassword(_emailText.text);
                              if (msg == null) {
                                showSnackBar(context, "Reset password email sent.");
                              } else {
                                showSnackBar(context, msg);
                                appState.passwordTime =
                                    DateTime.fromMillisecondsSinceEpoch(0);
                                prefs?.setInt("passwordForgetTime",
                                    appState.passwordTime.microsecondsSinceEpoch);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appState.selectedTheme == 'ytss'
                                  ? const Color(0xFFFFC700)
                                  : theme.colorScheme.secondary,
                              padding: EdgeInsets.symmetric(vertical: isPhone? 8 : 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Send Reset Link",
                              style: TextStyle(
                                fontFamily: "montserrat",
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: appState.selectedTheme == 'dark'
                                  ? Colors.black
                                  : appState.selectedTheme == 'ytss'
                                      ? Colors.black
                                      : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    //=== GO BACK BUTTON ===
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Go back.",
                        style: TextStyle(
                          fontFamily: "montserrat",
                          decoration: TextDecoration.underline,
                          color: appState.selectedTheme == 'ytss' ? Colors.white : theme.textTheme.bodyMedium?.color,
                        ),
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
