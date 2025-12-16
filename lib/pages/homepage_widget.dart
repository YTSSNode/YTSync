// announcements_ui.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:ytsync/main.dart';
import 'package:ytsync/network.dart';
import 'package:ytsync/util.dart';

/// Keep the same public function name/signature (for compatibility).
ListView createAnnouncementList(
  List<AnnouncementData> announcements,
  List<String> selectedClasses,
  HashMap<String, String> displayClasses,
  bool showUncompleted,
  bool showCompleted,
  bool showPersonal,
  bool showPublic,
  theme,
  context,
  setState,
  removeAnnouncement,
) {
  return AnnouncementList(
    announcements: announcements,
    selectedClasses: selectedClasses,
    displayClasses: displayClasses,
    showUncompleted: showUncompleted,
    showCompleted: showCompleted,
    showPersonal: showPersonal,
    showPublic: showPublic,
    theme: theme,
    parentContext: context,
    parentSetState: setState,
    removeAnnouncement: removeAnnouncement,
  ).buildListView();
}

/// Main widget for announcements — returns a ListView via buildListView()
class AnnouncementList {
  final List<AnnouncementData> announcements;
  final List<String> selectedClasses;
  final HashMap<String, String> displayClasses;
  final bool showUncompleted;
  final bool showCompleted;
  final bool showPersonal;
  final bool showPublic;
  final ThemeData theme;
  final BuildContext parentContext;
  final Function parentSetState;
  final Function removeAnnouncement;

  late final bool isPhone;
  late final bool isTablet;

  Future<Map<String, String>?> _getAuthorInfo(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return {
        'name': data['name'] ?? 'Unknown',
        'email': data['email'] ?? 'Unknown',
      };
    } catch (_) {
      return null;
    }
  }

  AnnouncementList({
  required this.announcements,
  required this.selectedClasses,
  required this.displayClasses,
  required this.showUncompleted,
  required this.showCompleted,
  required this.showPersonal,
  required this.showPublic,
  required theme,
  required parentContext,
  required parentSetState,
  required removeAnnouncement,
})  : parentContext = parentContext,
      parentSetState = parentSetState,
      removeAnnouncement = removeAnnouncement,
      theme = theme ?? Theme.of(parentContext),
      isPhone = MediaQuery.of(parentContext).size.width < 600,
      isTablet = MediaQuery.of(parentContext).size.width >= 600;

  ListView buildListView() {
    final filtered = <AnnouncementData>[];

    for (var a in announcements) {
      final aClass = a.getClass();
      if (!selectedClasses.contains(aClass)) continue;

      if (a.isCompleted() && !showCompleted) continue;
      if (!a.isCompleted() && !showUncompleted) continue;

      if (a.isPublic() && !showPublic) continue;
      if (!a.isPublic() && !showPersonal) continue;

      filtered.add(a);
    }

    final incomplete = filtered.where((a) => !a.isCompleted()).toList();
    final complete = filtered.where((a) => a.isCompleted()).toList();

    final children = <Widget>[];

    // Incomplete Section
    children.add(_sectionHeader("Incomplete"));

    if (incomplete.isEmpty) {
      children.add(_emptySectionHint("No incomplete announcements"));
    } else {
      for (var a in incomplete) {
        children.add(_announcementCard(
          announcement: a,
          displayClasses: displayClasses,
          context: parentContext,
        ));
      }
    }

    // Complete Section
    children.add(_sectionHeader("Complete"));

    if (complete.isEmpty) {
      children.add(_emptySectionHint("No completed announcements"));
    } else {
      for (var a in complete) {
        children.add(_announcementCard(
          announcement: a,
          displayClasses: displayClasses,
          context: parentContext,
        ));
      }
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: children,
    );
  }


  Widget _sectionHeader(String text) {
    final isYtss = appState.selectedTheme == 'ytss';
    final strokeColor = appState.selectedTheme == 'dark'
        ? Colors.grey[700]!
        : Colors.grey[300]!;
    final fillColor = isYtss ? Colors.black : (theme.textTheme.bodyMedium?.color ?? Colors.black);

    return Padding(
      padding: isPhone? const EdgeInsets.fromLTRB(10, 12, 12, 8)
                      : const EdgeInsets.fromLTRB(20, 18, 16, 8),
      child: Stack(
        children: [
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontFamily: "montserrat",
              fontSize: 16,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.4
                ..color = strokeColor,
            ),
          ),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontFamily: "montserrat",
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: fillColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptySectionHint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "montserrat",
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _announcementCard({
    required AnnouncementData announcement,
    required HashMap<String, String> displayClasses,
    required BuildContext context,
  }) {
    final bool completed = announcement.isCompleted();

    final cardBg = theme.cardColor;
    final borderColor = appState.selectedTheme == 'ytss'
        ? Colors.grey[300]!
        : appState.selectedTheme == 'light'
            ? const Color(0xFF0070D1)
            : Colors.white.withOpacity(0.8);

    final dueDays = announcement.getDaysToDue();

      // BADGE TEXT COLOR
      late Color badgeTextColor;
      if (completed) {
        badgeTextColor = const Color.fromRGBO(125, 125, 125, 0.9);
      } else {
        final d = dueDays;
        if (d == 0) {
          badgeTextColor = const Color.fromRGBO(255, 0, 0, 1);
        } else if (d == 1 || d == 2) {
          badgeTextColor = Colors.orange;
        } else if (d == 3) {
          badgeTextColor = Colors.orangeAccent;
        } else if (d == 4) {
          badgeTextColor = Colors.lightGreen;
        } else if (d < 0) {
          badgeTextColor = const Color.fromRGBO(255, 120, 120, 1);
        } else {
          badgeTextColor = Colors.green;
        }
      }

      // BADGE BG
      final badgeBg = completed
          ? badgeTextColor.withOpacity(0.15)
          : badgeTextColor.withOpacity(0.20);

    if (completed) {
      badgeTextColor = const Color.fromRGBO(125, 125, 125, 0.9);
    } else {
      final d = dueDays;
      if (d == 0) {
        badgeTextColor = const Color.fromRGBO(255, 0, 0, 1);
      } else if (d == 1 || d == 2) {
        badgeTextColor = Colors.orange;
      } else if (d == 3) {
        badgeTextColor = Colors.orangeAccent;
      } else if (d == 4) {
        badgeTextColor = Colors.lightGreen;
      } else {
        badgeTextColor = d < 0 ? const Color.fromRGBO(255, 120, 120, 1) : Colors.green;
      }
    }

    return Padding(
      padding: isPhone? const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0) : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
      child: Card(
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: 3),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => _announcementDialog(
                announcement,
                displayClasses,
                context,
                parentSetState,
                removeAnnouncement,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: isPhone? _strokedTitle(announcement.getTitle(), completed, fontSize: 15)
                                    : _strokedTitle(announcement.getTitle(), completed)
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        completed ? announcement.getDue() : deadlineStr(announcement.getDueAsDateTime()),
                        style: TextStyle(
                          fontFamily: "montserrat",
                          fontWeight: FontWeight.bold,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                // Class + Type row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        displayClasses[announcement.getClass()] ?? announcement.getClass(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: "montserrat",
                          fontSize: isPhone ? 13 : null,
                          color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.flag_rounded, color: Colors.grey, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          announcement.isPublic() ? "Public" : "Personal",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
                            fontFamily: "montserrat",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Description preview
                Text(
                  announcement.getDesc(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha((0.75 * 255).toInt()),
                    fontFamily: "montserrat",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _strokedTitle(
    String title,
    bool completed, {
    double fontSize = 20,
  }) {
    final fillColor = completed
        ? (appState.selectedTheme == 'dark'
            ? const Color.fromARGB(255, 225, 225, 225)
            : const Color.fromARGB(255, 100, 100, 100))
        : (appState.selectedTheme == 'ytss'
            ? const Color.fromARGB(255, 17, 6, 161)
            : theme.textTheme.titleMedium?.color);

    return Stack(
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: "montserrat",
            fontSize: fontSize,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..color = appState.selectedTheme == 'dark'
                  ? const Color.fromARGB(255, 10, 9, 9)
                  : const Color.fromARGB(255, 246, 246, 246),
          ),
        ),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: "montserrat",
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            color: fillColor,
          ),
        ),
      ],
    );
  }

  Widget _announcementDialog(
    AnnouncementData data,
    HashMap<String, String> displayClasses,
    BuildContext context,
    Function setStateFunc,
    Function removeAnnouncementFunc,
  ) {
    final cardBg = theme.cardColor;
    final ScrollController descController = ScrollController();
    final borderColor = appState.selectedTheme == 'ytss'
        ? Colors.grey[300]!
        : appState.selectedTheme == 'light'
            ? const Color(0xFF0070D1)
            : Colors.white.withOpacity(0.8);

    return AlertDialog(
  backgroundColor: cardBg,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(color: borderColor, width: 3),
  ),

  // ==== TITLE WITH STROKE ====
  title: Stack(
    children: [
      Text(
        data.getTitle(),
        style: TextStyle(
          fontFamily: "montserrat",
          fontSize: isPhone? 18 : 20,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..color = appState.selectedTheme == 'dark'
                ? const Color.fromARGB(255, 0, 0, 0)
                : const Color.fromARGB(255, 246, 246, 246),
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      Text(
        data.getTitle(),
        style: TextStyle(
          fontFamily: "montserrat",
          fontSize: isPhone? 18 : 20,
          fontWeight: FontWeight.bold,
          color: appState.selectedTheme == 'ytss'
              ? const Color.fromARGB(255, 17, 6, 161)
              : appState.selectedTheme == 'dark'
                  ? Colors.white
                  : Colors.black,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  ),

  // ==== CONTENT ====
  content: SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelValueRow(
          "Class:",
          displayClasses[data.getClass()] ?? data.getClass(),
          fontSize: isPhone? 13.5 : 18,
        ),
        const SizedBox(height: 20),

        Text(
          "Description:",
          style: TextStyle(
            fontFamily: "montserrat",
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),

        // DESCRIPTION BOX
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          width: double.infinity,
          padding: EdgeInsets.all(isPhone? 8 : 12),
          decoration: BoxDecoration(
            color: theme.dialogBackgroundColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: appState.selectedTheme == 'dark'
                  ? Colors.grey
                  : Colors.grey[400]!,
              width: 1.5,
            ),
          ),
          child: Scrollbar(
            controller: descController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: descController,
              child: Text(
                data.getDesc(),
                style: TextStyle(
                  fontFamily: "montserrat",
                  fontSize: isPhone? 12 : 13.5,
                  color: theme.colorScheme.onSurface.withOpacity(0.85),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        FutureBuilder<Map<String, String>?>(
          future: _getAuthorInfo(data.getAuthorUUID()),
          builder: (context, snapshot) {
            String value;

            if (snapshot.connectionState == ConnectionState.waiting) {
              value = "Loading...";
            } else if (!snapshot.hasData || snapshot.data == null) {
              value = "Unknown user";
            } else {
              final author = snapshot.data!;
              value = "${author['name']} (${author['email']})";
            }

            return _labelValueRow(
              "Posted by:",
              value,
              fontSize: 12,
            );
          },
        ),

        if (data.getPublish() != "") ...[
          const SizedBox(height: 2),
          _labelValueRow("Posted Date:", data.getPublish(), fontSize: 12),
        ],
        const SizedBox(height: 2),
        _labelValueRow("Due:", data.getDue(), fontSize: 12),
        const SizedBox(height: 2),
        _labelValueRow(
          "Type:",
          data.isPublic() ? "Public" : "Personal",
          fontSize: 12,
        ),
      ],
    ),
  ),

  // ==== ACTION BUTTONS ====
  actions: [
    // COMPLETE / UNDO
    TextButton(
      onPressed: () async {
        if (data.isCompleted()) {
          if (await data.uncomplete()) {
            if (context.mounted) {
              Navigator.pop(context);
              showSnackBar(context,
                  "Announcement is now not completed. (\"${data.getTitle()}\")");
            }
            parentSetState(
                () => announcements.sort(AnnouncementData.sortFunction));
          } else {
            if (context.mounted) {
              showSnackBar(context,
                  "Failed to sync announcement completion with the server.");
            }
          }
        } else {
          if (await data.complete()) {
            if (context.mounted) {
              Navigator.pop(context);
              showSnackBar(context,
                  "Announcement Completed. (\"${data.getTitle()}\")");
            }
            parentSetState(
                () => announcements.sort(AnnouncementData.sortFunction));
          } else {
            if (context.mounted) {
              showSnackBar(context,
                  "Failed to sync announcement completion with the server.");
            }
          }
        }
      },
      child: Text(
        data.isCompleted() ? "Undo" : "Complete",
        style: TextStyle(
          fontFamily: "montserrat",
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: data.isCompleted() ? Colors.red : Colors.green,
        ),
      ),
    ),

    // DELETE
    TextButton(
      onPressed: () async {
        if (data.getAuthorUUID() == account.uuid) {
          final themeLocal = Theme.of(context);
          showDialog(
            context: context,
            builder: (BuildContext ctx) {
              return AlertDialog(
                backgroundColor: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: borderColor, width: 3),
                ),

                // DELETE TITLE
                title: Text(
                  "Are you sure you want to delete this announcement?",
                  style: TextStyle(
                    fontFamily: "montserrat",
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: themeLocal.textTheme.bodyMedium?.color,
                  ),
                ),

                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontFamily: "montserrat",
                        fontSize: 15,
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      if (await deleteAnnouncementFromServer(data)) {
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                          showSnackBar(
                            context,
                            "Successfully deleted announcement. (\"${data.getTitle()}\")",
                          );
                        }
                        removeAnnouncement(data);
                      } else {
                        if (context.mounted) {
                          showSnackBar(
                            context,
                            "Failed to delete announcement. (Try checking your internet connection)",
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Confirm",
                      style: TextStyle(
                        fontFamily: "montserrat",
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }
      },
      style: data.getAuthorUUID() != account.uuid
          ? ButtonStyle(
              overlayColor:
                  MaterialStateProperty.all(Colors.transparent),
              mouseCursor:
                  MaterialStateProperty.all(SystemMouseCursors.basic),
            )
          : null,
      child: Text(
        "Delete",
        style: TextStyle(
          fontFamily: "montserrat",
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: data.getAuthorUUID() == account.uuid
              ? Colors.red
              : Colors.grey,
        ),
      ),
    ),

    // CLOSE
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text(
        "Close",
        style: TextStyle(
          fontFamily: "montserrat",
          fontSize: 15,
        ),
      ),
    ),
  ],
);
  }

    Widget _labelValueRow(String label, String value, {double fontSize = 14}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "montserrat",
            fontSize: fontSize,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: "montserrat",
              fontSize: fontSize,
            ),
          ),
        ),
      ],
    );
  }
}
