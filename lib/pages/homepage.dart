 import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:ytsync/network.dart';
import 'package:ytsync/pages/homepage_widget.dart';
import 'package:timer_button/timer_button.dart';
import './settings.dart';
import 'announcement.dart';
import '../util.dart';
import '../main.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

final FirebaseAuth _auth = FirebaseAuth.instance;
bool _hoverRefresh = false;
bool _hoverFilter = false;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}
class HomePageState extends State<HomePage> {
  late List<AnnouncementData> announcements;
  List<String> selectedClasses = [];
  List<String> availableClasses = [];
  HashMap<String, String> displayClasses = HashMap<String, String>();

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
      displayClasses[clazz] = clazz
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
      if (value == true) selectedClasses.add(className);
      else selectedClasses.remove(className);
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
    String description,
    String uuid,
    bool isPublic,
  ) async {
    var data = AnnouncementData(
      title,
      clazz,
      due,
      publish,
      description,
      uuid,
      isPublic,
    );

    if (!await sendAnnouncementToServer(data, isPublic)) return false;

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
    builder: (context) => SettingsPage(
      selectedClasses: selectedClasses,
      displayClasses: displayClasses,
      onClassToggle: _toggleClassSelection,
      onMultipleClassSelect: _setSelectedClasses,
    ),
  );
}

  void showFilterPopup(BuildContext context) {
    final theme = Theme.of(context);

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

showDialog(
  context: context,
  builder: (BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: color3,
        elevation: 8,
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: color3,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.shade500,
              width: 2,
            ),
          ),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Filter Announcements",
                  style: TextStyle(
                    fontFamily: "montserrat",
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    // Show Completed
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            "Show Completed",
                            style: TextStyle(
                              fontFamily: "montserrat",
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Checkbox(
                          value: showCompleted,
                          onChanged: (bool? value) {
                            setState(() {
                              showCompleted = value ?? false;
                            });
                          },
                          activeColor: color1,
                          checkColor: appState.selectedTheme == 'dark'
                              ? Colors.black
                              : Colors.white,
                          side: BorderSide(color: color1, width: 2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Show Incomplete
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            "Show Incomplete",
                            style: TextStyle(
                              fontFamily: "montserrat",
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Checkbox(
                          value: showUncompleted,
                          onChanged: (bool? value) {
                            setState(() {
                              showUncompleted = value ?? false;
                            });
                          },
                          activeColor: color1,
                          checkColor: appState.selectedTheme == 'dark'
                              ? Colors.black
                              : Colors.white,
                          side: BorderSide(color: color1, width: 2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Show Personal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            "Show Personal",
                            style: TextStyle(
                              fontFamily: "montserrat",
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Checkbox(
                          value: showPersonal,
                          onChanged: (bool? value) {
                            setState(() {
                              showPersonal = value ?? false;
                            });
                          },
                          activeColor: color1,
                          checkColor: appState.selectedTheme == 'dark'
                              ? Colors.black
                              : Colors.white,
                          side: BorderSide(color: color1, width: 2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Show Public
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            "Show Public",
                            style: TextStyle(
                              fontFamily: "montserrat",
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Checkbox(
                          value: showPublic,
                          onChanged: (bool? value) {
                            setState(() {
                              showPublic = value ?? false;
                            });
                          },
                          activeColor: color1,
                          checkColor: appState.selectedTheme == 'dark'
                              ? Colors.black
                              : Colors.white,
                          side: BorderSide(color: color1, width: 2),
                        ),
                      ],
                    ),
                  ],
                ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appState.selectedTheme == 'light'
                            ? const Color(0xFF0070D1)
                            : appState.selectedTheme == 'dark'
                            ? Colors.white
                            : color2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                      ),
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Apply Filter",
                        style: TextStyle(
                          fontFamily: "montserrat",
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: appState.selectedTheme == 'light'? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final size = MediaQuery.of(context).size;
    final bool isPhone = size.width < 600;

    Color color1 = const Color.fromARGB(255, 17, 6, 161);
    Color color2 = const Color(0xFFFFC700);
    Color color3 = Colors.white;
    String filterAsset = "assets/filterdark.png";
    String plusAsset = "assets/plus.png";
    String gearAsset = "assets/gear.png";

    if (appState.selectedTheme == 'light') {
      color1 = const Color(0xFF0070D1);
      color2 = Colors.grey.shade200;
      color3 = Colors.white;
    } else if (appState.selectedTheme == 'dark') {
      color1 = Colors.white;
      color2 = Colors.grey.shade900;
      color3 = Colors.grey.shade800;
      filterAsset = "assets/filter.png";
      plusAsset = "assets/plusdark.png";
      gearAsset = "assets/geardark.png";
    }

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
      backgroundColor: color2,
      appBar: AppBar(
        backgroundColor: color1,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // LEFT: Profile
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: appState.selectedTheme == 'dark'
                      ? Colors.black
                      : Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 20,
                    color: appState.selectedTheme == 'dark'
                        ? Colors.white
                        : color1,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: TextStyle(
                        fontFamily: "montserrat",
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: appState.selectedTheme == 'dark'
                            ? Colors.black
                            : Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      account.email,
                      style: TextStyle(
                        fontFamily: "montserrat",
                        fontSize: 12,
                        color: appState.selectedTheme == 'dark'
                            ? Colors.black.withOpacity(0.8)
                            : Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Top bar with filter and refresh
          Container(
            width: double.infinity,
            color: color2,
            padding: EdgeInsets.fromLTRB(
              16,
              isPhone ? 10 : 20, 
              16,
              isPhone ? 10 : 20, 
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // LEFT: Filter Button
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: MouseRegion(
                          onEnter: (_) => setState(() => _hoverFilter = true),
                          onExit: (_) => setState(() => _hoverFilter = false),
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => showFilterPopup(context),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.all(isPhone ? 4 : 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _hoverFilter ? color1 : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Image.asset(
                                filterAsset,
                                width: isPhone ? 26 : 28,  
                                height: isPhone ? 26 : 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // RIGHT: Refresh Button
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: MouseRegion(
                          onEnter: (_) => setState(() => _hoverRefresh = true),
                          onExit: (_) => setState(() => _hoverRefresh = false),
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: refreshFunc,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                horizontal: isPhone ? 6 : 8,
                                vertical: isPhone ? 2 : 4,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _hoverRefresh ? color1 : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh_outlined,
                                    size: isPhone ? 26 : 28,
                                    color: appState.selectedTheme == 'dark'
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Refresh",
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontFamily: "montserrat",
                                      fontSize: isPhone ? 13 : 16,
                                      color: appState.selectedTheme == 'dark'
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isPhone ? 6 : 10),
                Divider(
                  thickness: 1,
                  color: appState.selectedTheme == 'dark'
                      ? Colors.white54
                      : Colors.black54,
                ),
              ],
            ),
          ),

          // Main announcement list
          Expanded(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: isPhone ? 0 : 8,
              ),
              decoration: BoxDecoration(
                color: color3,
                border: Border.all(
                  color: color1,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: announcements.isEmpty
                  ? Center(
                      child: Text(
                        "No announcements to display",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: "montserrat",
                          fontWeight: FontWeight.bold,
                          color: color1,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: createAnnouncementList(
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
                      ),
                    ),
            ),
          ),

          // Bottom bar buttons
          Container(
            width: double.infinity,
            color: color2,
            padding: EdgeInsets.symmetric(
              vertical: isPhone ? 10 : 20, 
              horizontal: 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
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
                          builder: (BuildContext context) {
                            return Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.all(16),
                              child: Material(
                                borderRadius: BorderRadius.circular(20),
                                color: color3,
                                elevation: 8,
                                child: Container(
                                  width: 360,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: color3,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.grey.shade500,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "No Classes Selected",
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
                                        "Please select at least one class to continue.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: "montserrat",
                                          fontSize: 16,
                                          color: appState.selectedTheme == 'dark'
                                          ? Colors.white
                                          : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          OutlinedButton(
                                            onPressed: () => Navigator.pop(context),
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(color: Colors.grey.shade600, width: 2),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                            ),
                                            child: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                fontFamily: "montserrat",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: appState.selectedTheme == 'dark'
                                                ? Colors.white
                                                : Colors.black,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.push(context, getSettingsPageMaterial());
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: appState.selectedTheme == 'light'
                                                ? const Color(0xFF0070D1)
                                                : appState.selectedTheme == 'dark'
                                                ? Colors.white
                                                : color2,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                            ),
                                            child: Text(
                                              "Go to Settings",
                                              style: TextStyle(
                                                fontFamily: "montserrat",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: appState.selectedTheme == 'light'
                                                    ? Colors.white
                                                    : Colors.black,
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
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color1,
                        padding: EdgeInsets.symmetric(
                          vertical: isPhone ? 6 : 10, 
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: isPhone ? 2 : 6),
                          Image.asset(
                            plusAsset,
                            width: isPhone ? 22 : 28, 
                            height: isPhone ? 22 : 28,
                          ),
                          SizedBox(height: isPhone ? 2 : 6),
                          Text(
                            "Add Announcement",
                            style: TextStyle(
                              fontFamily: "montserrat",
                              fontWeight: FontWeight.bold,
                              fontSize: isPhone ? 10 : 12,
                              color: appState.selectedTheme == 'dark'
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                          SizedBox(height: isPhone ? 2 : 6),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, getSettingsPageMaterial());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color1,
                        padding: EdgeInsets.symmetric(
                          vertical: isPhone ? 6 : 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: isPhone ? 2 : 6),
                          Image.asset(
                            gearAsset,
                            width: isPhone ? 22 : 28,
                            height: isPhone ? 22 : 28,
                          ),
                          SizedBox(height: isPhone ? 2 : 6),
                          Text(
                            "Settings",
                            style: TextStyle(
                              fontFamily: "montserrat",
                              fontWeight: FontWeight.bold,
                              fontSize: isPhone ? 10 : 12,
                              color: appState.selectedTheme == 'dark'
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                          SizedBox(height: isPhone ? 2 : 6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}