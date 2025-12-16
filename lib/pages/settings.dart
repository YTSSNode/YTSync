import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:ytsync/network.dart';
import 'package:ytsync/pages/login.dart';
import 'package:ytsync/util.dart';
import 'package:ytsync/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<List<String>> _fetchAvailableClasses() async {
  final snapshot = await FirebaseFirestore.instance.collection('classes').get();
  return snapshot.docs.map((doc) => doc.id).toList();
}

class SettingsPage extends StatefulWidget {
  final List<String> selectedClasses;
  final HashMap<String, String> displayClasses;
  final Function(String, bool?) onClassToggle;
  final Function(List<String>) onMultipleClassSelect;

  const SettingsPage({
    super.key,
    required this.selectedClasses,
    required this.displayClasses,
    required this.onClassToggle,
    required this.onMultipleClassSelect,
  });

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  List<String> _selectedClasses = [];
  List<String> _availableClasses = [];
  final HashSet<String> _classesChanged = HashSet<String>();
  bool _isClassDropdownOpen = false;
  final Map<String, bool> _isDropdownOpenLvl = {
    "Sec 4": false,
    "Sec 3": false,
    "Sec 2": false,
    "Sec 1": false,
  };

  String _newTheme = appState.selectedTheme;
  String _oldTheme = "";
  bool _isThemeDropdownOpen = false;
  bool _isChangesMade = false;

  final Map<String, bool> _isThemeHovered = {
    'light': false,
    'dark': false,
    'ytss': false,
  };

  final Map<String, bool> _isClassHovered = {};

  final Map<String, String> themeNames = {
    'light': 'Light',
    'dark': 'Dark',
    'ytss': 'YTSS (Navy & Yellow)',
  };

  @override
  void initState() {
    super.initState();
    _selectedClasses = List.from(widget.selectedClasses);
    _oldTheme = appState.selectedTheme;
    fetchSec4Classes();
  }

  Future<void> fetchSec4Classes() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('classes')
          .doc('Sec 4')
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _availableClasses = data.keys.toList();
        for (var c in _availableClasses) _isClassHovered[c] = false;
        setState(() {});
      }
    } catch (e) {
      showSnackBar(context, "Failed to load classes: $e");
    }
  }

  void updateTheme(String value) {
    if (value == _newTheme) return;
    _isChangesMade = true;
    _newTheme = value;
    changeAppTheme(_newTheme, widget, this);
  }

  void revertChanges() {
    _classesChanged.clear();
  }

  void saveChanges() async {
    widget.onMultipleClassSelect(_selectedClasses);

    for (String className in _classesChanged) {
      if (_selectedClasses.contains(className)) {
        if (!await changeSelectedClassesInServer(className, true)) {
          if (context.mounted) showSnackBar(context, "Error: settings could not be synced. Try again.");
        }
      } else {
        if (!await changeSelectedClassesInServer(className, false)) {
          if (context.mounted) showSnackBar(context, "Error: settings could not be synced. Try again.");
        }
      }
    }

    changeAppTheme(_newTheme, widget, this);
    appSaveToPref();

    if (context.mounted) {
      Navigator.pop(context);
      showSnackBar(context, "Settings Saved!");
    }

    _classesChanged.clear();
  }

  Widget buildSelectableOption({
    required String text,
    required bool isSelected,
    required bool isHovered,
    required VoidCallback onTap,
    required Color color1,
    required Color color3,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.yellow : color3,
            border: Border.all(
              color: isSelected || isHovered ? Colors.yellow : Colors.grey.shade400,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: "montserrat",
              color: (appState.selectedTheme == 'dark' && text == 'Dark' && isSelected)
                  ? Colors.black
                  : (appState.selectedTheme == 'dark' ? Colors.white : Colors.black),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final bool isPhone = size.width < 600;

    Color color1 = const Color.fromARGB(255, 17, 6, 161);
    Color color2 = const Color(0xFFFFC700);
    Color color3 = Colors.white;

    if (appState.selectedTheme == 'light') {
      color1 = const Color(0xFF0070D1);
      color2 = Colors.grey.shade200;
      color3 = Colors.white;
    } else if (appState.selectedTheme == 'dark') {
      color1 = Colors.white;
      color2 = Colors.grey.shade900;
      color3 = Colors.grey.shade800;
    }

    void _showChangeUsernameDialog() {
      final ctrl = TextEditingController();

      final borderColor = appState.selectedTheme == 'ytss'
          ? Colors.grey[300]!
          : appState.selectedTheme == 'light'
              ? const Color(0xFF0070D1)
              : Colors.white.withOpacity(0.8);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: borderColor, width: 3),
            ),

            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),

            title: Text(
              "Change Username",
              style: TextStyle(
                fontFamily: "montserrat",
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: appState.selectedTheme == 'dark'? Colors.white : Colors.black,
              ),
            ),

            content: SizedBox(
              width: 420,
              child: TextField(
                controller: ctrl,
                style: TextStyle(
                  fontFamily: "montserrat",
                  fontSize: 14,
                  color: appState.selectedTheme == 'dark'
                    ? Colors.white
                    : Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: "New username",
                  labelStyle: TextStyle(
                    fontFamily: "montserrat",
                    color: appState.selectedTheme == 'dark'
                        ? Colors.grey[400]
                        : Colors.grey[700],
                  ),

                  fillColor: appState.selectedTheme == 'ytss'
                      ? Colors.grey[300]
                      : appState.selectedTheme == 'light'
                          ? Colors.grey[300]
                          : Colors.grey[800],

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontFamily: "montserrat",
                    fontSize: 15,
                    color: appState.selectedTheme == 'dark'? Colors.grey[300]: null,
                  ),
                ),
              ),

              ElevatedButton(
                onPressed: () async {
                  final username = ctrl.text.trim();

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

                  if (RegExp(r'[ _\.]{2,}').hasMatch(username)) {
                    showSnackBar(
                      context,
                      "No consecutive spaces, underscores, or dots.",
                    );
                    return;
                  }

                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .update({
                    'name': username,
                  });

                  Navigator.pop(context);
                  showSnackBar(context, "Username updated!");

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor : appState.selectedTheme == 'ytss'
                                  ? const Color(0xFFFFC700)
                                  : appState.selectedTheme == 'dark'
                                  ? Colors.white
                                  : borderColor,
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Save",
                  style: TextStyle(
                    fontFamily: "montserrat",
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: appState.selectedTheme == 'light'? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    Widget _passwordField(TextEditingController ctrl, String label) {
      return TextField(
        controller: ctrl,
        obscureText: true,
        style: TextStyle(
          fontFamily: "montserrat",
          fontSize: 14,
          color: appState.selectedTheme == 'dark'
            ? Colors.white
            : Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: "montserrat",
            color: appState.selectedTheme == 'dark'
                ? Colors.grey[400]
                : Colors.grey[700],
          ),

          fillColor: appState.selectedTheme == 'ytss'
              ? Colors.grey[300]
              : appState.selectedTheme == 'light'
                  ? Colors.grey[300]
                  : Colors.grey[800],

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }


    void _showChangePasswordDialog() {
      final currentCtrl = TextEditingController();
      final newCtrl = TextEditingController();
      final confirmCtrl = TextEditingController();

      final borderColor = appState.selectedTheme == 'ytss'
          ? Colors.grey[300]!
          : appState.selectedTheme == 'light'
              ? const Color(0xFF0070D1)
              : const Color.fromARGB(255, 255, 255, 255);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: borderColor, width: 3),
            ),

            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),

            title: Text(
              "Change Password",
              style: TextStyle(
                fontFamily: "montserrat",
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: appState.selectedTheme == 'dark'? Colors.white : Colors.black,
              ),
            ),

            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _passwordField(currentCtrl, "Current password"),
                  const SizedBox(height: 12),
                  _passwordField(newCtrl, "New password"),
                  const SizedBox(height: 12),
                  _passwordField(confirmCtrl, "Confirm password"),
                ],
              ),
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontFamily: "montserrat",
                    fontSize: 15,
                    color: appState.selectedTheme == 'dark'? Colors.grey[300]: null,
                  ),
                ),
              ),

              ElevatedButton(
                onPressed: () async {
                  if (newCtrl.text != confirmCtrl.text) {
                    showSnackBar(context, "Passwords do not match.");
                    return;
                  }
                  
                  if (newCtrl.text.contains(' ')) {
                    showSnackBar(context, "Password cannot contain spaces.");
                    return;
                  }

                  if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[^\s]{8,}$')
                      .hasMatch(newCtrl.text)) {
                    showSnackBar(
                      context,
                      "Password must be at least 8 characters and include letters and numbers.",
                    );
                    return;
                  }

                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;

                  try {
                    await user.updatePassword(newCtrl.text);
                    Navigator.pop(context);
                    showSnackBar(context, "Password changed!");
                  } catch (e) {
                    showSnackBar(
                      context,
                      "Please re-login before changing password.",
                    );
                  }

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor : appState.selectedTheme == 'ytss'
                                  ? const Color(0xFFFFC700)
                                  : appState.selectedTheme == 'dark'
                                  ? Colors.white
                                  : borderColor,
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Update",
                  style: TextStyle(
                    fontFamily: "montserrat",
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: appState.selectedTheme == 'light'? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: color2,
      appBar: AppBar(
        backgroundColor: color1,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: appState.selectedTheme == 'dark' ? Colors.black : Colors.white,
          ),
          onPressed: () {
            if (_isChangesMade) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.all(16),
                    child: Material(
                      borderRadius: BorderRadius.circular(20),
                      color: appState.selectedTheme == 'dark' ? Colors.grey[850] : Colors.white,
                      elevation: 8,
                      child: Container(
                        width: 350,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: appState.selectedTheme == 'dark' ? Colors.grey[850] : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.shade500,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Unsaved Changes",
                              style: TextStyle(
                                fontFamily: "montserrat",
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: color1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "You have unsaved changes. Do you want to revert them or cancel?",
                              style: TextStyle(
                                fontFamily: "montserrat",
                                fontSize: 16,
                                color: appState.selectedTheme == 'dark' ? Colors.white : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: color3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(color: Colors.grey.shade500, width: 2),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                                  ),
                                  onPressed: () {
                                    revertChanges();
                                    changeAppTheme(_oldTheme, widget, this);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Revert",
                                    style: TextStyle(
                                      fontFamily: "montserrat",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: appState.selectedTheme == 'dark' ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: color1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontFamily: "montserrat",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: appState.selectedTheme == 'dark' ? Colors.black : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            fontFamily: "montserrat",
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: appState.selectedTheme == 'dark' ? Colors.black : Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Account Settings Header
            Container(
              width: double.infinity,
              color: color2,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Text(
                    "Account Settings",
                    style: TextStyle(
                      fontFamily: "montserrat",
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: appState.selectedTheme == 'dark' ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: 1,
                    color: color1,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Username + Password row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showChangeUsernameDialog(),
                        icon: Icon(
                          Icons.person,
                          size: isPhone ? 18 : 22,
                          color: appState.selectedTheme == 'dark'
                              ? Colors.black
                              : Colors.white,
                        ),
                        label: Text(
                          "Change Username",
                          style: TextStyle(
                            fontFamily: "montserrat",
                            fontWeight: FontWeight.bold,
                            fontSize: isPhone ? 12 : 14,
                            color: appState.selectedTheme == 'dark'? Colors.black : Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appState.selectedTheme == 'light'
                              ? const Color(0xFF0070D1)
                              : appState.selectedTheme == 'dark'
                                  ? Colors.white
                                  : const Color.fromARGB(255, 17, 6, 161),
                          padding: EdgeInsets.symmetric(
                            horizontal: isPhone ? 16 : 24,
                            vertical: isPhone ? 8 : 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      ElevatedButton.icon(
                        onPressed: () => _showChangePasswordDialog(),
                        icon: Icon(
                          Icons.lock,
                          size: isPhone ? 18 : 22,
                          color: appState.selectedTheme == 'dark'
                              ? Colors.black
                              : Colors.white,
                        ),
                        label: Text(
                          "Change Password",
                          style: TextStyle(
                            fontFamily: "montserrat",
                            fontWeight: FontWeight.bold,
                            fontSize: isPhone ? 12 : 14,
                            color: appState.selectedTheme == 'dark'? Colors.black : Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appState.selectedTheme == 'light'
                              ? const Color(0xFF0070D1)
                              : appState.selectedTheme == 'dark'
                                  ? Colors.white
                                  : const Color.fromARGB(255, 17, 6, 161),
                          padding: EdgeInsets.symmetric(
                            horizontal: isPhone ? 16 : 24,
                            vertical: isPhone ? 8 : 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Sign Out
                  ElevatedButton.icon(
                    onPressed: () async {
                      String? msg = await signOut();
                      if (msg == null && context.mounted) {
                        while (Navigator.canPop(context)) Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LogInPage()),
                        );
                        showSnackBar(context, "Signed out from current account!");
                      } else {
                        showSnackBar(context, msg);
                      }
                    },
                    icon: Icon(
                      Icons.logout,
                      size: isPhone ? 18 : 22,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Sign Out",
                      style: TextStyle(
                        fontFamily: "montserrat",
                        fontWeight: FontWeight.bold,
                        fontSize: isPhone ? 12 : 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(
                        horizontal: isPhone ? 16 : 24,
                        vertical: isPhone ? 8 : 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Theme Selection
            _buildSelectableSection(
              title: "Theme",
              color1: appState.selectedTheme == 'dark'
                  ? Color.fromARGB(255, 57, 57, 57)
                  : color1,
              color2: color2,
              color3: color3,
              child: Column(
                children: [
                  InkWell(
                    onTap: () => setState(() => _isThemeDropdownOpen = !_isThemeDropdownOpen),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: color3,
                        border: Border.all(color: Colors.grey.shade400, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.color_lens,
                              color: appState.selectedTheme == 'dark' ? Colors.white : Colors.black),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              themeNames[_newTheme] ?? "",
                              style: TextStyle(
                                fontFamily: "montserrat",
                                color: appState.selectedTheme == 'dark' ? Colors.white : Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            _isThemeDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                            color: appState.selectedTheme == 'dark' ? Colors.white : Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_isThemeDropdownOpen)
                    Column(
                      children: ['light', 'dark', 'ytss'].map((theme) {
                        bool isSelected = _newTheme == theme;
                        bool isHovered = _isThemeHovered[theme] ?? false;
                        return buildSelectableOption(
                          text: themeNames[theme] ?? "",
                          isSelected: isSelected,
                          isHovered: isHovered,
                          onTap: () => updateTheme(theme),
                          color1: color1,
                          color3: color3,
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // CLASS SUBSCRIPTIONS
              _buildSelectableSection(
                title: "Class Subscriptions",
                color1: appState.selectedTheme == 'dark' ? const Color.fromARGB(255, 57, 57, 57) : color1,
                color2: color2,
                color3: color3,
                child: StatefulBuilder(
                  builder: (context, setStateSB) {
                    final ScrollController classListController = ScrollController();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main button showing number of selected classes
                        InkWell(
                          onTap: () => setStateSB(() => _isClassDropdownOpen = !_isClassDropdownOpen),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: color3,
                              border: Border.all(color: Colors.grey.shade400, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.class_sharp),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "${_selectedClasses.length} classes selected",
                                    style: TextStyle(
                                      fontFamily: "montserrat",
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: appState.selectedTheme == 'dark' ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _isClassDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                  color: appState.selectedTheme == 'dark' ? Colors.white : Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Levels Dropdown
                        if (_isClassDropdownOpen)
                          Column(
                            children: ["Sec 4", "Sec 3", "Sec 2", "Sec 1"].map((level) {
                              final isOpen = _isDropdownOpenLvl[level] ?? false;
                              return Column(
                                children: [
                                  // Level Button
                                  InkWell(
                                    onTap: () async {
                                      setStateSB(() => _isDropdownOpenLvl[level] = !isOpen);

                                      // Only fetch Sec 4 data
                                      if (level == "Sec 4" && _availableClasses.isEmpty && !isOpen) {
                                        try {
                                          final doc = await FirebaseFirestore.instance
                                              .collection('classes')
                                              .doc(level)
                                              .get();
                                          if (doc.exists) {
                                            final data = doc.data() as Map<String, dynamic>;
                                            _availableClasses = data.keys.toList();   // class names are keys
                                            setStateSB(() {});
                                          }
                                        } catch (e) {
                                          showSnackBar(context, "Failed to load $level classes: $e");
                                        }
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: color3,
                                        border: Border.all(color: Colors.grey.shade400, width: 2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.school),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              "$level classes",
                                              style: TextStyle(
                                                fontFamily: "montserrat",
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: appState.selectedTheme == 'dark' ? Colors.white : Colors.black,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                            color: appState.selectedTheme == 'dark' ? Colors.white : Colors.black,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Classes List (Sec 4 only)
                                  if (isOpen && level == "Sec 4")
                                    SizedBox(
                                      height: isPhone? 400 : 250,
                                      child: NotificationListener<ScrollNotification>(
                                        onNotification: (scrollNotification) {
                                          if (scrollNotification is ScrollUpdateNotification) {
                                            // Only allow inner list to scroll
                                            if (classListController.hasClients &&
                                                classListController.position.pixels !=
                                                    classListController.position.minScrollExtent &&
                                                classListController.position.pixels !=
                                                    classListController.position.maxScrollExtent) {
                                              return true; // Stop parent scroll
                                            }
                                          }
                                          return false;
                                        },
                                        child: ListView.builder(
                                          controller: classListController,
                                          physics: const ClampingScrollPhysics(),
                                          itemCount: _availableClasses.length,
                                          itemBuilder: (context, index) {
                                            final classData = _availableClasses[index];
                                            final subject = classData.split(" - ")[0];
                                            final isChecked = _selectedClasses.contains(classData);

                                            return Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: isPhone? 0 : 4),
                                              decoration: BoxDecoration(
                                                color: appState.selectedTheme == 'dark'
                                                    ? Colors.grey[800]
                                                    : Colors.white,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: CheckboxListTile(
                                                controlAffinity: ListTileControlAffinity.leading,
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                                                title: Text(
                                                  subject,
                                                  style: TextStyle(
                                                    fontFamily: "montserrat",
                                                    fontSize: 12,
                                                    color: appState.selectedTheme == 'dark' ? Colors.white : Colors.black,
                                                  ),
                                                ),
                                                value: isChecked,
                                                activeColor: appState.selectedTheme == 'light'
                                                    ? const Color(0xFF0070D1)
                                                    : appState.selectedTheme == 'dark'
                                                        ? Colors.white
                                                        : const Color.fromARGB(255, 17, 6, 161),
                                                onChanged: (bool? checked) {
                                                  setState(() {
                                                    _isChangesMade = true;
                                                    if (checked == true) {
                                                      _selectedClasses.add(classData);
                                                    } else {
                                                      _selectedClasses.remove(classData);
                                                    }
                                                    _classesChanged.add(classData);
                                                  });
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  // Empty placeholders for Sec 1-3
                                  if (isOpen && level != "Sec 4")
                                    Container(
                                      height: 50,
                                      alignment: Alignment.center,
                                      child: Text(
                                        "No classes available",
                                        style: TextStyle(
                                          fontFamily: "montserrat",
                                          fontSize: 12,
                                          color: appState.selectedTheme == 'dark' ? Colors.white : 
                                                appState.selectedTheme == 'ytss' ? Colors.white :Colors.black,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }).toList(),
                          ),
                      ],
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 240,
                child: ElevatedButton(
                  onPressed: saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color1,
                    padding: EdgeInsets.symmetric(
                      vertical: isPhone ? 8 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Save Changes",
                    style: TextStyle(
                      fontFamily: "montserrat",
                      fontWeight: FontWeight.bold,
                      fontSize: isPhone ? 14 : 16,
                      color: appState.selectedTheme == 'dark' ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableSection({
    required String title,
    required Widget child,
    required Color color1,
    required Color color2,
    required Color color3,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color1,
        border: Border.all(color: color2, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: "montserrat",
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: appState.selectedTheme == 'dark' ? Colors.white : color3,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
