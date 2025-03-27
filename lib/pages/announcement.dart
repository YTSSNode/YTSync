import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:ytsync/main.dart';
import 'package:ytsync/pages/homepage.dart';
import '../util.dart';

class AddAnnouncementPage extends StatefulWidget {
  final HomePageState homePageState;
  final List<String> availableClasses;
  final List<String> selectedClasses;
  final HashMap<String, String> displayClasses;

  const AddAnnouncementPage({
    super.key,
    required this.homePageState,
    required this.availableClasses,
    required this.selectedClasses,
    required this.displayClasses,
  });

  @override
  AddAnnouncementPageState createState() => AddAnnouncementPageState();
}

class AddAnnouncementPageState extends State<AddAnnouncementPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime? _selectedDueDate;
  String? _selectedClass;

  bool isPublic = false;
  bool isPublishDate = true;

  @override
  Widget build(BuildContext context) {
    // Use available classes if we have selected classes, otherwise use all classes
    List<String> classOptions =
        widget.selectedClasses.isNotEmpty
            ? widget.selectedClasses
            : widget.availableClasses;

    return Scaffold(
      appBar: AppBar(title: Text("Add Announcement")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              //title bar
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Title",
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              SizedBox(height: 16),

              //class dropdown selection box
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: "Class",
                  prefixIcon: Icon(Icons.class_),
                ),

                value: _selectedClass,
                items:
                    classOptions.map((className) {
                      return DropdownMenuItem(
                        value: className,
                        child: Text(widget.displayClasses[className] ?? ""),
                      );
                    }).toList(),

                onChanged: (value) {
                  setState(() {
                    _selectedClass = value.toString();
                  });
                },
              ),
              SizedBox(height: 16),

              //description text area
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Description",
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 64),
                    child: Icon(Icons.description),
                  ),
                ),
              ),
              SizedBox(height: 16),

              //due date picker
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: "Due Date",
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  setState(() {
                    _dateController.text = dateFormatDateTime(
                      pickedDate ?? DateTime.now(),
                    );
                    _selectedDueDate = pickedDate;
                  });
                },
              ),
              SizedBox(height: 24),
              Divider(),

              Row(
                children: [
                  Text(
                    "Would you like to publish the date of the announcement?",
                  ),
                ],
              ),

              Row(
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    value: isPublishDate,
                    onChanged: (bool? value) {
                      setState(() {
                        isPublishDate = value ?? false;
                      });
                    },
                  ),
                  Text("Send Publish Date"),
                ],
              ),

              Divider(),

              Row(
                children: [
                  Text(
                    "Would you like to make this announcement public so that everyone in the class can view it?",
                  ),
                ],
              ),

              Row(
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    value: isPublic,
                    onChanged: (bool? value) {
                      setState(() {
                        isPublic = value ?? false;
                      });
                    },
                  ),
                  Text("Public"),
                ],
              ),

              Divider(),

              ElevatedButton(
                onPressed: () async {
                  var clazz = _selectedClass;
                  var pickedDate = _selectedDueDate;
                  if (_titleController.text.isNotEmpty &&
                      clazz != null &&
                      _dateController.text.isNotEmpty &&
                      pickedDate != null) {
                    if (pickedDate.difference(DateTime.now()).inDays < 0) {
                      showSnackBar(
                        context,
                        "The due date cannot be before today.",
                      );
                    } else {
                      if (await widget.homePageState.addAnnouncement(
                        _titleController.text,
                        clazz,
                        pickedDate,
                        isPublishDate ? DateTime.now() : null,
                        account.name,
                        _descriptionController.text,
                        account.uuid,
                        isPublic,
                      )) {
                        if (context.mounted) {
                          Navigator.pop(context);
                          showSnackBar(
                            context,
                            isPublic
                                ? "Announcement published successfully!"
                                : "Personal announcement added.",
                          );
                        }
                      } else {
                        if (context.mounted) {
                          showSnackBar(
                            context,
                            isPublic
                                ? "Failed to send announcement to the server. (Try checking your internet connection)"
                                : "Failed to sync personal announcement with account. (Try checking your internet connection)",
                          );
                        }
                      }
                    }
                  } else {
                    showSnackBar(context, "Please fill all required fields.");
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      isPublic ? "Publish" : "Add Privately",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
