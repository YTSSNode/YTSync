import 'dart:collection';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ytsync/network.dart';
import 'package:ytsync/pages/homepage_widget.dart';
import 'package:timer_button/timer_button.dart';
import './settings.dart';
import 'announcement.dart';
import '../util.dart';
import '../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  //announcements and classes
  late List<AnnouncementData> announcements;
  List<String> selectedClasses = [];
  List<String> availableClasses = [];
  HashMap<String, String> displayClasses =
      HashMap<String, String>(); //actual name, display name

  //filter category
  bool showCompleted = true;
  bool showUncompleted = true;
  bool showPersonal = true;
  bool showPublic = true;

  HomePageState() {
    homepageInit();
  }

  void homepageInit() {
    announcements = receiveAnnouncementFromServer() ?? [];
    announcements.sort(AnnouncementData.sortFunction);

    var classes = receiveClassesFromServer();
    for (var entry in classes) {
      var clazz = entry.name;
      var selected = entry.selected;

      availableClasses.add(clazz);
      displayClasses[clazz] =
          clazz
              .replaceAll("Sec 4", "")
              .replaceAll("Sec 3", "")
              .replaceAll("Sec 2", "")
              .replaceAll("Sec 1", "")
              .trimLeft();
      if (selected) {
        selectedClasses.add(clazz);
      }
    }
    availableClasses.sort();
    selectedClasses.sort();
  }

  void _toggleClassSelection(String className, bool? value) {
    setState(() {
      if (value == true) {
        selectedClasses.add(className);
      } else {
        selectedClasses.remove(className);
      }
    });
  }

  void _setSelectedClasses(List<String> classes) {
    setState(() {
      selectedClasses = List.from(classes);
    });
  }

  Future<bool> addAnnouncement(
    String title,
    String clazz,
    DateTime due,
    DateTime? publish,
    String author,
    String description,
    String uuid,
    bool isPublic,
  ) async {
    var data = AnnouncementData(
      title,
      clazz,
      due,
      publish,
      author,
      description,
      uuid,
      isPublic,
    );

    if (!await sendAnnouncementToServer(data, isPublic)) {
      return false;
    }

    setState(() {
      announcements.add(data);
      announcements.sort(AnnouncementData.sortFunction);
    });

    return true;
  }

  void removeAnnouncement(AnnouncementData data) {
    setState(() {
      announcements.remove(data);
    });
  }

  MaterialPageRoute getSettingsPageMaterial() {
    return MaterialPageRoute(
      builder:
          (context) => SettingsPage(
            availableClasses: availableClasses,
            selectedClasses: selectedClasses,
            displayClasses: displayClasses,
            onClassToggle: _toggleClassSelection,
            onMultipleClassSelect: _setSelectedClasses,
          ),
    );
  }

  void showFilterPopup(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          scrollable: true,
          title: const Text("Filter Announcements"),
          titleTextStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 30.0,
          ),
          content: StatefulBuilder(
            builder:
                (context, setState) => Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Form(
                    child: Table(
                      columnWidths: {
                        0: FlexColumnWidth(),
                        1: FlexColumnWidth(0.2),
                      },
                      children: [
                        TableRow(
                          children: [
                            Text(
                              "Show Completed",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                            Checkbox(
                              checkColor: Colors.white,
                              value: showCompleted,
                              onChanged: (bool? value) {
                                setState(() {
                                  showCompleted = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text(
                              "Show Incomplete",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                            Checkbox(
                              checkColor: Colors.white,
                              value: showUncompleted,
                              onChanged: (bool? value) {
                                setState(() {
                                  showUncompleted = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text(
                              "Show Personal",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                            Checkbox(
                              checkColor: Colors.white,
                              value: showPersonal,
                              onChanged: (bool? value) {
                                setState(() {
                                  showPersonal = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text(
                              "Show Public",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                            Checkbox(
                              checkColor: Colors.white,
                              value: showPublic,
                              onChanged: (bool? value) {
                                setState(() {
                                  showPublic = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          ),
          actions: [
            ElevatedButton(
              child: const Text("Filter"),
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Future.delayed(Duration.zero, () => {
      if (userPass.startsWith("YTSS@") && context.mounted) {
        showDialog(
          context: context,
          builder:
          (context) => AlertDialog(
            title: Text("Warning: Action Needed on Password."),
            content: Text(
              "Please change your password to prevent anyone else from signing in to your account.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, getSettingsPageMaterial());
                },
                child: Text("Go to Settings"),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        )
      }
    });

    refreshFunc() async {
      selectedClasses.clear();
      availableClasses.clear();
      displayClasses.clear();
      announcements.clear();

      await firebaseInit(false);

      setState(() {
        homepageInit();

        showSnackBar(context, "Refreshed Page.");
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Announcements",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Today is ${fullDateStr(DateTime.now())}", style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.filter_alt_outlined),
                  tooltip: "Pick a filter to categorise the announcements.",
                  onPressed: () => showFilterPopup(context),
                ),
                Row(
                  children: [
                    Icon(Icons.refresh_outlined),
                    TimerButton.builder(
                      onPressed: refreshFunc,
                      builder: (context, timeLeft) {
                        return MouseRegion(
                          cursor:
                              timeLeft >= 0
                                  ? DefaultMouseCursor()
                                  : SystemMouseCursors.click,
                          child:
                              timeLeft >= 0
                                  ? Text(
                                    "Refresh (${timeLeft}s)",
                                    style: theme.textTheme.labelLarge,
                                  )
                                  : Text(
                                    "Refresh",
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color:
                                          appState
                                              .themeData
                                              .$2
                                              .colorScheme
                                              .secondary,
                                    ),
                                  ),
                        );
                      },
                      timeOutInSeconds: 60,
                    ),
                  ],
                ),
              ],
            ),

            Divider(),

            Expanded(
              child:
                  announcements.isEmpty
                      ? Center(
                        child: Text(
                          "No announcements to display",
                          style: theme.textTheme.titleMedium,
                        ),
                      )
                      : (createAnnouncementList(
                        announcements,
                        selectedClasses,
                        displayClasses,
                        showUncompleted,
                        showCompleted,
                        showPersonal,
                        showPublic,
                        theme,
                        context,
                        setState,
                        removeAnnouncement,
                      )),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            // Add
            if (selectedClasses.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AddAnnouncementPage(
                        homePageState: this,
                        availableClasses: availableClasses,
                        selectedClasses: selectedClasses,
                        displayClasses: displayClasses,
                      ),
                ),
              );
            } else {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text("No classes selected."),
                      content: Text(
                        "Please select at least one class to continue.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(context, getSettingsPageMaterial());
                          },
                          child: Text("Go to Settings"),
                        ),
                      ],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
              );
            }
          } else if (index == 1) {
            // Settings
            Navigator.push(context, getSettingsPageMaterial());
          }
        },
      ),
    );
  }
}
