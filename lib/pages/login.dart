import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ytsync/pages/forgotpassword.dart';
import 'package:ytsync/pages/homepage.dart';
import 'package:ytsync/util.dart';
import 'package:ytsync/network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ytsync/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  LogInPageState createState() => LogInPageState();
}

class LogInPageState extends State<LogInPage> {
  bool loginPage = true;

  final TextEditingController _emailText = TextEditingController();
  final TextEditingController _passText = TextEditingController();
  final TextEditingController _nameText = TextEditingController();
  final TextEditingController _confirmPassText = TextEditingController();
  final TextEditingController _classText = TextEditingController();
  final TextEditingController _registerNumText = TextEditingController();

  final ForgotPasswordPage forgotPassPage = ForgotPasswordPage();
  bool loginButtonDisabled = false;

  Color getFocusedBorderColor(ThemeData theme) {
    if (appState.selectedTheme == 'ytss') return const Color(0xFFFFC700);
    if (theme.brightness == Brightness.dark) return Colors.white;
    return const Color(0xFF0070D1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isPhone = size.width < 600;
    final isLaptop = size.width > 600;

    final double cardWidth = isLaptop ? 420 : 350;
    final double titleFont = isLaptop ? 36 : 32;
    final double inputFont = isLaptop ? 18 : 16;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.light &&
                  (appState.selectedTheme != 'ytss')
              ? Colors.grey[200]
              : theme.brightness == Brightness.dark
                  ? Colors.grey[900]
                  : null,
          gradient: (appState.selectedTheme == 'ytss')
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
                    if (loginPage)
                      Column(
                        children: [
                          Image.asset(
                            'assets/logo.png',
                            height: 140
                          ),
                          const SizedBox(height: 10),
                        ],
                      )
                    else
                      SizedBox(height: 0),

                    // === LOGO TEXT ===
                    Stack(
                      children: [
                        Text(
                          'YTSync',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'ytlogonew',
                            fontSize: titleFont,
                            letterSpacing: 3.5,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 4
                              ..color = appState.selectedTheme == 'ytss'
                                  ? const Color.fromARGB(255, 0, 0, 0)
                                  : appState.selectedTheme == 'light'
                                      ? Colors.white
                                      : const Color.fromARGB(255, 89, 89, 89),
                          ),
                        ),
                        Text(
                          'YTSync',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'ytlogonew',
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
                          Stack(
                            children: [
                              Text(
                                loginPage ? "Please log in below" : "Sign up below",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'montserrat',
                                  fontSize: isLaptop ? 22 : 18,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 1.5
                                    ..color = appState.selectedTheme == 'dark'
                                        ? Colors.grey[700]!
                                        : const Color.fromARGB(255, 224, 224, 224),
                                ),
                              ),
                              Text(
                                loginPage ? "Please log in below" : "Sign up below",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'montserrat',
                                  fontSize: isLaptop ? 22 : 18,
                                  color: appState.selectedTheme == 'ytss'
                                      ? Colors.black
                                      : Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isPhone? 8 : 20),

                          if (!loginPage)
                            TextField(
                              controller: _nameText,
                              style: TextStyle(
                                  fontFamily: "montserrat",
                                  fontSize: inputFont,
                                  color: theme.textTheme.bodyMedium?.color),
                              decoration: _inputDecoration('Username', theme),
                            ),
                          if (!loginPage) SizedBox(height: isPhone? 8 : 15),

                          TextField(
                            inputFormatters: [
                              TextInputFormatter.withFunction((o, n) =>
                                  TextEditingValue(
                                    text: n.text
                                        .toLowerCase()
                                        .replaceAll(RegExp(r'[^a-z0-9@_.]'), ''),
                                    selection: n.selection,
                                  ))
                            ],
                            controller: _emailText,
                            style: TextStyle(
                                fontFamily: "montserrat",
                                fontSize: inputFont,
                                color: theme.textTheme.bodyMedium?.color),
                            decoration: _inputDecoration('Email', theme),
                          ),
                          SizedBox(height: isPhone? 8 : 15),

                          PasswordField(
                            controller: _passText,
                            theme: theme,
                            inputFont: inputFont,
                            focusedBorderColor: getFocusedBorderColor(theme),
                          ),
                          SizedBox(height: isPhone? 8 : 15),

                          if (!loginPage)
                            ConfirmPasswordField(
                              controller: _confirmPassText,
                              theme: theme,
                              inputFont: inputFont,
                              focusedBorderColor: getFocusedBorderColor(theme),
                            ),
                          if (!loginPage) SizedBox(height: isPhone? 8 : 15),

                          if (!loginPage)
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    inputFormatters: [
                                      TextInputFormatter.withFunction((o, n) {
                                        var t = n.text;
                                        if (t.length > 2) t = t.substring(0, 2);
                                        if (t.isNotEmpty) {
                                          if (!RegExp(r'^[0-9]').hasMatch(t[0]))
                                            t = '';
                                          else if (t.length == 2) {
                                            t = t[0] + t[1].toUpperCase();
                                            if (!RegExp(r'^[A-Z]$').hasMatch(t[1])) t = t[0];
                                          }
                                        }
                                        return TextEditingValue(
                                          text: t,
                                          selection: TextSelection.collapsed(offset: t.length),
                                        );
                                      })
                                    ],
                                    maxLength: 2,
                                    controller: _classText,
                                    style: TextStyle(
                                        fontFamily: "montserrat",
                                        fontSize: inputFont,
                                        color: theme.textTheme.bodyMedium?.color),
                                    decoration: _inputDecoration('Class', theme)
                                        .copyWith(counterText: ""),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    inputFormatters: [
                                      TextInputFormatter.withFunction(
                                        (o, n) =>
                                            n.text.length <= 2 &&
                                                    RegExp(r'^[0-9]{0,2}$')
                                                        .hasMatch(n.text)
                                                ? n
                                                : o,
                                      ),
                                    ],
                                    controller: _registerNumText,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        fontFamily: "montserrat",
                                        fontSize: inputFont,
                                        color: theme.textTheme.bodyMedium?.color),
                                    decoration:
                                        _inputDecoration('Register Number', theme),
                                  ),
                                ),
                              ],
                            ),
                          if (!loginPage) SizedBox(height: isPhone? 8 : 15),

                          if (loginPage)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => forgotPassPage),
                                  );
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    fontFamily: "montserrat",
                                    fontSize: 16,
                                    color: theme.textTheme.bodyMedium?.color,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: isPhone? 8 : 15),

                          ElevatedButton(
                            onPressed: loginButtonDisabled
                                ? null
                                : () async {
                                    await _handleLoginSignup();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              padding: EdgeInsets.symmetric(vertical: isPhone? 8 : 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              loginPage ? "Log In" : "Sign Up",
                              style: TextStyle(
                                fontFamily: "montserrat",
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: appState.selectedTheme == 'ytss'
                                    ? Colors.black
                                    : appState.selectedTheme == 'light'
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isPhone? 8 : 20),

                    TextButton(
                      onPressed: () {
                        setState(() {
                          loginPage = !loginPage;
                        });
                      },
                      child: Text(
                        loginPage
                            ? "Don't have an account? Sign up instead."
                            : "Already have an account? Log in instead.",
                        style: TextStyle(
                          fontFamily: 'montserrat',
                          decoration: TextDecoration.underline,
                          color: appState.selectedTheme == 'ytss'
                              ? Colors.white
                              : theme.textTheme.bodyMedium?.color,
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

  InputDecoration _inputDecoration(String hint, ThemeData theme) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: "montserrat",
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color.fromARGB(255, 75, 75, 75), width: 1.5),
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
    );
  }

  Future<void> _handleLoginSignup() async {
    if (!loginPage) {
      final username = _nameText.text.trim();

      if (username.isEmpty) {
        showSnackBar(context, "Please fill in your username.");
        return;
      }

      if (username.length < 3 || username.length > 24) {
        showSnackBar(context, "Username must be 3–24 characters long.");
        return;
      }

      if (!RegExp(r'^[a-zA-Z0-9 _\.]+$').hasMatch(username)) {
        showSnackBar(
          context,
          "Only letters, numbers, spaces, _ and . are allowed.",
        );
        return;
      }

      if (RegExp(r'^[ _\.]|[ _\.]$').hasMatch(username)) {
        showSnackBar(
          context,
          "Username cannot start or end with space, _ or .",
        );
        return;
      }

      if (RegExp(r'[ _\.]{2,}').hasMatch(username)) {
        showSnackBar(
          context,
          "No consecutive spaces, underscores, or dots.",
        );
        return;
      }
    }
    if (_emailText.text.isEmpty) {
      showSnackBar(context, "Please fill in your email.");
      return;
    } else if (!loginPage &&
        (!_emailText.text.trimRight().endsWith("@ytss.edu.sg") &&
            !_emailText.text.trimRight().endsWith("@students.edu.sg"))) {
      showSnackBar(context,
          "Email must end in @ytss.edu.sg or @students.edu.sg");
      return;
    }
    if (_passText.text.isEmpty) {
      showSnackBar(context, "Please fill in your password.");
      return;
    } else if (!loginPage) {
      final password = _passText.text;

      if (password.contains(' ')) {
        showSnackBar(context, "Password cannot contain spaces.");
        return;
      }

      if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$').hasMatch(password)) {
        showSnackBar(
          context,
          "Password must be at least 8 characters and include letters and numbers.",
        );
        return;
      }
    }
    if (!loginPage) {
      if (_confirmPassText.text.isEmpty) {
        showSnackBar(context, "Please confirm your password.");
        return;
      } else if (_confirmPassText.text != _passText.text) {
        showSnackBar(context, "Passwords do not match.");
        return;
      }
    }

    if (!loginPage) {
      if (_classText.text.isEmpty ||
          !RegExp(r'^[1-4][A-Z]$').hasMatch(_classText.text)) {
        showSnackBar(context, "Class format invalid (e.g., 4F).");
        return;
      }
    }
    if (!loginPage &&
        (_registerNumText.text.isEmpty || _registerNumText.text.length > 2)) {
      showSnackBar(context, "Register number must be 1 or 2 digits.");  
      return;
    }

    showSnackBar(context, loginPage ? "Logging in. Please wait." : "Signing up. Please wait.");

    setState(() {
      loginButtonDisabled = true;
    });

    late final (bool, String) result;

    if (loginPage) {
      result = await firebaseInit(
        true,
        _emailText.text.trim(),
        _passText.text.trim(),
        null,
        '',
        '',
      );
    } else {
      result = await firebaseInit(
        true,
        _emailText.text.trim(),
        _passText.text.trim(),
        _nameText.text.trim(),
        _classText.text.trim(),
        _registerNumText.text.trim(),
      );
    }

    if (result.$1) {
      if (mounted) {
        showSnackBar(
          context,
          loginPage
              ? "Login success!"
              : "Sign up success. Welcome to YTSync!",
        );

        prefs?.setString("credential-email", _emailText.text);
        prefs?.setString("credential-pass", _passText.text);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      if (mounted) {
        showSnackBar(context, result.$2);
      }
    }

    if (mounted) {
      setState(() {
        loginButtonDisabled = false;
      });
    }
  }
}

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final ThemeData theme;
  final double inputFont;
  final Color focusedBorderColor;

  const PasswordField({
    super.key,
    required this.controller,
    required this.theme,
    required this.inputFont,
    required this.focusedBorderColor,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      enableSuggestions: false,
      autocorrect: false,
      style: TextStyle(
        fontFamily: "montserrat",
        fontSize: widget.inputFont,
        color: widget.theme.textTheme.bodyMedium?.color,
      ),
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: TextStyle(
          fontFamily: "montserrat",
          color: widget.theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: widget.theme.textTheme.bodyMedium?.color,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color.fromARGB(255, 75, 75, 75), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: widget.focusedBorderColor,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}

class ConfirmPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final ThemeData theme;
  final double inputFont;
  final Color focusedBorderColor;

  const ConfirmPasswordField({
    super.key,
    required this.controller,
    required this.theme,
    required this.inputFont,
    required this.focusedBorderColor,
  });

  @override
  State<ConfirmPasswordField> createState() => _ConfirmPasswordFieldState();
}

class _ConfirmPasswordFieldState extends State<ConfirmPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      enableSuggestions: false,
      autocorrect: false,
      obscureText: _obscureText,
      style: TextStyle(
        fontFamily: "montserrat",
        fontSize: widget.inputFont,
        color: widget.theme.textTheme.bodyMedium?.color,
      ),
      decoration: InputDecoration(
        hintText: 'Confirm Password',
        hintStyle: TextStyle(
          fontFamily: "montserrat",
          color: widget.theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: widget.theme.textTheme.bodyMedium?.color,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color.fromARGB(255, 75, 75, 75), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: widget.focusedBorderColor,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
