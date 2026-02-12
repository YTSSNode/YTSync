import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ytsync/firebase_options.dart';
import 'package:ytsync/network.dart';
import 'package:ytsync/pages/homepage.dart';
import 'package:ytsync/pages/login.dart';
import 'package:ytsync/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:html' as html;

late MyAppState appState;
SharedPreferences? prefs;
late Account account;

bool loggedIn = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  prefs = await SharedPreferences.getInstance();

  await FirebaseAuth.instance.authStateChanges().first;

  if ((prefs?.getString("credential-email") ?? "").isNotEmpty) {
    var result = await firebaseInit(
      true,
      prefs?.getString("credential-email") ?? "",
      prefs?.getString("credential-pass") ?? "",
    );

    if (result.$1) {
      loggedIn = true;
    }
  }
  html.document.title = "YTSync";
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late Map<String, (ThemeMode, ThemeData)> appThemeMap;
  (ThemeMode, ThemeData) themeData = (ThemeMode.light, ThemeData.light());
  String selectedTheme = 'light';

  late DateTime passwordTime;

    MyAppState() {
    appThemeMap = {
      "light": (
        ThemeMode.light,
        ThemeData(
          primaryColor: const Color(0xFF0070D1),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF0070D1),
            secondary: Color(0xFF0070D1),
          ),
          cardColor: Colors.white,
          scaffoldBackgroundColor: const Color(0xFFF7F7F7),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.black),
          ),
          cardTheme: getCardTheme(),
          inputDecorationTheme: getInputDecorationTheme(Colors.grey[100], "light"),
          elevatedButtonTheme: getElevatedButtonTheme(const Color(0xFF0070D1), Colors.white),
          appBarTheme: getAppBarTheme(Colors.white, Colors.black),
        ),
      ),



      "dark": (
        ThemeMode.dark,
        ThemeData.dark().copyWith(
          primaryColor: Colors.blueGrey,
          colorScheme: const ColorScheme.dark(
            primary: Colors.blueGrey,
            secondary: Colors.white,
          ),
          cardColor: Colors.grey[850],
          scaffoldBackgroundColor: const Color(0xFF121212),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
          ),
          cardTheme: getCardTheme(),
          inputDecorationTheme: getInputDecorationTheme(Colors.grey[800], "dark"),
          elevatedButtonTheme: getElevatedButtonTheme(Colors.blueGrey, Colors.white),
          appBarTheme: getAppBarTheme(Colors.black, Colors.white),
        ),
      ),

      "ytss": (
        ThemeMode.light,
        ThemeData(
          primaryColor: const Color(0xFF0A1958),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF0A1958),
            secondary: Color(0xFFFFC700),
          ),
          cardColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.black),
          ),
          cardTheme: getCardTheme(),
          inputDecorationTheme: getInputDecorationTheme(Colors.grey[100], "ytss"), 
          elevatedButtonTheme: getElevatedButtonTheme(
            const Color(0xFF0A1958),
            const Color(0xFFFFC700),
          ),
          appBarTheme: getAppBarTheme(Color(0xFF0A1958), Color(0xFFFFC700)),
        ),
      ),
    };

    selectedTheme = prefs?.getString('theme') ?? 'ytss';
    themeData = appThemeMap[selectedTheme] ?? (ThemeMode.light, ThemeData.light());

    passwordTime = DateTime.fromMicrosecondsSinceEpoch(
      prefs?.getInt("passwordForgetTime") ?? 0,
    );

    appState = this;
  }

  void updateTheme() {
    setState(() {
      themeData = appThemeMap[selectedTheme] ?? (ThemeMode.light, ThemeData.light());
    });
  }

  ElevatedButtonThemeData getElevatedButtonTheme(bgColor, fgColor) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  AppBarTheme getAppBarTheme(bgColor, fgColor) {
    return AppBarTheme(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      centerTitle: true,
      elevation: 0,
    );
  }

  InputDecorationTheme getInputDecorationTheme(Color? fillColor, String themeName) {
    Color borderColor;

    switch (themeName) {
      case 'ytss':
        borderColor = const Color(0xFFFFC700);
        break;
      case 'dark':
        borderColor = Colors.white;
        break;
      default:
        borderColor = Colors.blue;
    }

    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor, width: 2.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: fillColor,
    );
  }


  CardTheme getCardTheme() {
    return CardTheme(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData.$2,
      darkTheme: appThemeMap["dark"]?.$2 ?? ThemeData.dark(),
      themeMode: themeData.$1,
      home: loggedIn ? const HomePage() : const LogInPage(),
    );
  }
}

void appSaveToPref() async {
  await prefs?.setString('theme', appState.selectedTheme);
}

Future<void> changeAppTheme(String value, Widget widget, State state) async {
  appState.selectedTheme = value;

  state.setState(() {
    appState.updateTheme();
  });
}
