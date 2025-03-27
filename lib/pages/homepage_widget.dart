import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:ytsync/main.dart';
import 'package:ytsync/network.dart';
import 'package:ytsync/util.dart';

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
) => ListView.builder(
  itemCount: announcements.length + 2,
  itemBuilder: (context, index) {
    if (index == 0) {
      return Text("Incomplete", style: TextStyle(fontWeight: FontWeight.bold));
    }
    index--;

    if (announcements.isEmpty ||
        (index == 0 &&
            announcements.isNotEmpty &&
            announcements[index].isCompleted()) ||
        (index - 1 < announcements.length &&
            index - 1 >= 0 &&
            !announcements[index - 1].isCompleted() &&
            ((index < 0 || index >= announcements.length) ||
                announcements[index].isCompleted()))) {
      return Text("Complete", style: TextStyle(fontWeight: FontWeight.bold));
    }

    if (index >= announcements.length || announcements[index].isCompleted()) {
      index--;
    }

    if (!selectedClasses.contains(announcements[index].getClass())) {
      return SizedBox();
    }

    if (!(((showCompleted && announcements[index].isCompleted()) ||
            (showUncompleted && !announcements[index].isCompleted())) &&
        ((showPersonal && !announcements[index].isPublic()) ||
            (showPublic && announcements[index].isPublic())))) {
      return SizedBox();
    }

    return _createAnnouncementCard(
      announcements,
      displayClasses,
      index,
      theme,
      context,
      setState,
      removeAnnouncement,
    );
  },
);

Card _createAnnouncementCard(
  List<AnnouncementData> announcements,
  HashMap<String, String> displayClasses,
  int index,
  theme,
  context,
  setState,
  removeAnnouncement,
) => Card(
  child: InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () {
      showDialog(
        context: context,
        builder: (context) {
          return _getAnnouncementAlertDialog(
            announcements,
            displayClasses,
            index,
            context,
            setState,
            removeAnnouncement,
          );
        },
      );
    },

    child: Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    announcements[index].isCompleted()
                        ? Icon(Icons.check_box, color: Colors.lightGreen)
                        : SizedBox(),
                    Text(
                      announcements[index].getTitle(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            announcements[index].isCompleted()
                                ? Colors.grey
                                : null,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      announcements[index].isCompleted()
                          ? Color.fromRGBO(50, 50, 50, 0.5)
                          : (announcements[index].getDaysToDue() < 0
                              ? Color.fromRGBO(175, 6, 6, 1)
                              : theme.primaryColor.withAlpha(
                                (0.2 * 255).toInt(),
                              )),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  announcements[index].isCompleted() ? announcements[index].getDue() :
                          deadlineStr(announcements[index].getDueAsDateTime()),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        announcements[index].isCompleted()
                            ? Color.fromRGBO(125, 125, 125, 0.5)
                            : switch (announcements[index].getDaysToDue()) {
                              0 => Color.fromRGBO(255, 0, 0, 1),
                              1 || 2 => Colors.orange,
                              3 => Colors.orangeAccent,
                              4 => Colors.lightGreen,
                              var x =>
                                x < 0
                                    ? Color.fromRGBO(255, 120, 120, 1)
                                    : Colors.green,
                            },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayClasses[announcements[index].getClass()] ?? "",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(
                    (0.6 * 255).toInt(),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.flag_rounded, color: Colors.grey),
                  Text(
                    announcements[index].isPublic() ? "Public" : "Personal",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(
                        (0.6 * 255).toInt(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);

dynamic _getAnnouncementAlertDialog(
  List<AnnouncementData> announcements,
  HashMap<String, String> displayClasses,
  int index,
  context,
  setState,
  removeAnnouncement,
) {
  var data = announcements[index];
  return AlertDialog(
    title: Text(data.getTitle()),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Class: ${displayClasses[data.getClass()] ?? ""}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Text("Posted by: ", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(data.getAuthor()),
          ],
        ),
        if (data.getPublish() != "")
          Row(
            children: [
              Text("Posted Date: ", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(data.getPublish()),
            ],
          ),
        Row(
          children: [
            Text("Due: ", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(data.getDue()),
          ],
        ),
        Row(
          children: [
            Text("Type: ", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(data.isPublic() ? "Public" : "Personal"),
          ],
        ),
        SizedBox(height: 12),
        Text("Description: ", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(data.getDesc()),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () async {
          if (data.isCompleted()) {
            if (await data.uncomplete()) {
              if (context.mounted) {
                Navigator.pop(context);
                showSnackBar(
                  context,
                  "Announcement is now not completed. (\"${data.getTitle()}\")",
                );
              }

              setState(() => announcements.sort(AnnouncementData.sortFunction));
            } else {
              if (context.mounted) {
                showSnackBar(
                  context,
                  "Failed to sync announcement completion with the server. (Try checking your internet connection)",
                );
              }
            }
          } else {
            if (await data.complete()) {
              if (context.mounted) {
                Navigator.pop(context);
                showSnackBar(
                  context,
                  "Announcement Completed. (\"${data.getTitle()}\")",
                );
              }

              setState(() => announcements.sort(AnnouncementData.sortFunction));
            } else {
              if (context.mounted) {
                showSnackBar(
                  context,
                  "Failed to sync announcement completion with the server. (Try checking your internet connection)",
                );
              }
            }
          }
        },
        child: Text(
          data.isCompleted() ? "Undo" : "Complete",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: data.isCompleted() ? Colors.red : Colors.green,
          ),
        ),
      ),
      TextButton(
        onPressed: () async {
          if (data.getAuthorUUID() == account.uuid) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                final theme = Theme.of(context);
                return AlertDialog(
                  title: Text(
                    "Are you sure you want to delete this announcement?",
                  ),
                  titleTextStyle: theme.textTheme.titleSmall,
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (await deleteAnnouncementFromServer(data)) {
                          if (context.mounted) {
                            Navigator.pop(context);
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
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll<Color>(
                          Colors.red,
                        ),
                      ),
                      child: Text("Confirm"),
                    ),
                  ],
                );
              },
            );
          }
        },
        style:
            data.getAuthorUUID() != account.uuid
                ? ButtonStyle(
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  mouseCursor: DefaultMouseCursor(),
                )
                : null,
        child: Text(
          "Delete",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color:
                data.getAuthorUUID() == account.uuid ? Colors.red : Colors.grey,
          ),
        ),
      ),
      TextButton(onPressed: () => Navigator.pop(context), child: Text("Close")),
    ],
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );
}
