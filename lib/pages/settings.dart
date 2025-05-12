import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:ytsync/network.dart';
import 'package:ytsync/pages/login.dart';
import 'package:ytsync/util.dart';
import 'package:ytsync/main.dart';

class SettingsPage extends StatefulWidget {
  final List<String> availableClasses;
  final List<String> selectedClasses;
  final HashMap<String, String> displayClasses;
  final Function(String, bool?) onClassToggle;
  final Function(List<String>) onMultipleClassSelect;

  const SettingsPage({
    super.key,
    required this.availableClasses,
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
  final HashSet<String> _classesChanged = HashSet<String>();
  bool _isDropdownOpen = false;
  final Map<String, bool> _isDropdownOpenLvl = {
    "Sec4": false,
    "Sec3": false,
    "Sec2": false,
    "Sec1": false,
  };

  String _newTheme = appState.selectedTheme;
  String _oldTheme = "";
  bool _isChangesMade = false;
  final TextEditingController _passText = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedClasses = List.from(widget.selectedClasses);
    _oldTheme = appState.selectedTheme;
  }

  void updateTheme(String? value) {
    if (value == _newTheme) {
      return;
    }

    if (value != _oldTheme) {
      _isChangesMade = true;
    }

    _newTheme = value ?? appState.selectedTheme;
    changeAppTheme(_newTheme, widget, this);
  }

  void revertChanges() async {
    _classesChanged.clear();
  }

  void saveChanges() async {
    widget.onMultipleClassSelect(_selectedClasses);
    
    for (String className in _classesChanged) {
      if (_selectedClasses.contains(className)) {
        if (!await changeSelectedClassesInServer(className, true)) {
          if (context.mounted) {
            showSnackBar(context, "Error: settings could not be synced. Try again.");
          }
        }
      } else {
        if (await changeSelectedClassesInServer(className, false)) {
          if (context.mounted) {
            showSnackBar(context, "Error: settings could not be synced. Try again.");
          }
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

  Iterable<dynamic> getClasses(theme, lvl) {
    return widget.availableClasses.map((className) {
      if (className.startsWith(lvl)) {
        return CheckboxListTile(
          title: Text(widget.displayClasses[className] ?? ""),
          value: _selectedClasses.contains(className),
          onChanged: (bool? value) async {
            _isChangesMade = true;
            _classesChanged.add(className);

            setState(() {
              if (value == true) {
                _selectedClasses.add(className);
              } else {
                _selectedClasses.remove(className);
              }
            });
          },
          activeColor: theme.primaryColor,
          dense: true,
        );
      } else {
        return SizedBox();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        actions: [
          TextButton(
            onPressed: () => saveChanges(),
            child: Text(
              "Save",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: appState.themeData.$2.colorScheme.secondary,
              ),
            ),
          ),
        ],
        leading: BackButton(
          onPressed: () {
            if (_isChangesMade) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  final theme = Theme.of(context);
                  return AlertDialog(
                    title: Text("Warning! There are unsaved changes."),
                    titleTextStyle: theme.textTheme.titleSmall,
                    actions: [
                      TextButton(
                        onPressed: () {
                          revertChanges();
                          changeAppTheme(_oldTheme, widget, this);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Revert changes",
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Cancel",
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),

      body: ListView(
        children: [
          // Top bar section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Account Settings",
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () async {
                    String? msg = await signOut();
                    if (msg == null && context.mounted) {
                      while (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LogInPage()),
                      );

                      widget.availableClasses.clear();
                      widget.selectedClasses.clear();

                      prefs?.setString("credential-id", "");
                      prefs?.setString("credential-pass", "");

                      showSnackBar(context, "Signed out from current account!");
                    } else {
                      showSnackBar(context, msg);
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.red),
                  ),
                  child: Text(
                    "Sign Out",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Change Password",
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(children: [
                  SizedBox(
                    width: 100.0,
                    height: 30.0,
                    child: TextField(
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      controller: _passText,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'New Password',
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  TextButton(onPressed: () async {
                    if (_passText.text.isEmpty) {
                      showSnackBar(context, "New password is empty.");
                    } else {
                      dynamic msg = await changePassword(_passText.text);
                      if (context.mounted) {
                        if (msg is String) {
                          showSnackBar(context, "Password change failed. $msg");
                        } else {
                          userPass = _passText.text;
                          showSnackBar(context, "Password successfully changed!");
                        }
                      }
                    }
                  }, child: Text("Confirm\nChange"))
                ])
              ),
            ],
          ),

          // Theme section
          Divider(),

          Padding(
            padding: EdgeInsets.all(16),
            child: Text("Theme", style: theme.textTheme.titleLarge),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Choose Theme",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.color_lens),
              ),
              value: appState.selectedTheme,
              items: [
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'dark', child: Text('Dark')),
                DropdownMenuItem(value: 'pink', child: Text('Pink')),
                DropdownMenuItem(
                  value: 'ytss',
                  child: Text('YTSS (Navy & Yellow)'),
                ),
              ],
              onChanged: (value) {
                updateTheme(value);
              },
            ),
          ),

          // Class section
          Divider(),

          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Class Subscriptions",
              style: theme.textTheme.titleLarge,
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Select which classes you want to see announcements for:",
              style: theme.textTheme.bodyMedium,
            ),
          ),

          SizedBox(height: 8),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () {
                setState(() {
                  _isDropdownOpen = !_isDropdownOpen;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.class_),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedClasses.isEmpty
                            ? "No classes selected"
                            : _selectedClasses.length == 1
                            ? (widget.displayClasses[_selectedClasses.first] ??
                                "")
                            : "${_selectedClasses.length} classes selected",
                      ),
                    ),
                    Icon(
                      _isDropdownOpen
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_isDropdownOpen)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
                color: theme.cardColor,
              ),
              child: Column(
                children: [
                  ...["Sec 4", "Sec 3", "Sec 2", "Sec 1"].map(
                    (lvl) => Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isDropdownOpenLvl[lvl] =
                                  !(_isDropdownOpenLvl[lvl] ?? false);
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.class_sharp),
                                SizedBox(width: 12),
                                Expanded(child: Text(lvl)),
                                Icon(
                                  _isDropdownOpenLvl[lvl] == true
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                ),
                              ],
                            ),
                          ),
                        ),

                        ...(_isDropdownOpenLvl[lvl] == true
                            ? getClasses(theme, lvl)
                            : [SizedBox()]),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedClasses.clear();
                              _classesChanged.addAll(List.from(
                                widget.availableClasses,
                              ));
                            });
                          },
                          child: Text("Clear All"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedClasses = List.from(
                                widget.availableClasses,
                              );
                              _classesChanged.addAll(List.from(
                                widget.availableClasses,
                              ));
                            });
                          },
                          child: Text("Select All"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
