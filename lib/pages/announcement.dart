import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:ytsync/main.dart';
import '../util.dart';
import 'homepage.dart';
import 'package:flutter/services.dart';

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
  String? visibilityType;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Color getAccent() {
    if (appState.selectedTheme == 'ytss') {
      return const Color(0xFFFFC700);
    } else if (appState.selectedTheme == 'light') {
      return const Color(0xFF0070D1);
    } else {
      return Colors.white;
    }
  }

  Color getInputColor(BuildContext context) {
    final theme = Theme.of(context);
    if (appState.selectedTheme == 'ytss') {
      return Colors.black;
    } else if (appState.selectedTheme == 'light') {
      return theme.textTheme.bodyMedium?.color ?? Colors.black87;
    } else {
      return Colors.white.withOpacity(0.95);
    }
  }

  Color getCardColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.cardColor;
  }

  BoxDecoration themedBackground(BuildContext context) {
    final theme = Theme.of(context);

    if (appState.selectedTheme == 'ytss') {
      return const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 3, 0, 47),
            Color.fromARGB(255, 32, 16, 255),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    } else {
      return BoxDecoration(
        color: theme.brightness == Brightness.light && appState.selectedTheme != 'ytss'
            ? Colors.grey[200]
            : theme.brightness == Brightness.dark
                ? Colors.grey[900]
                : null,
      );
    }
  }

  OutlineInputBorder buildBorder(BuildContext context) {
    final theme = Theme.of(context);
    Color borderColor;
    if (appState.selectedTheme == 'ytss') {
      borderColor = const Color.fromARGB(255, 181, 181, 181)!;
    } else if (appState.selectedTheme == 'light') {
      borderColor = const Color(0xFF0070D1);
    } else {
      borderColor = Colors.white.withOpacity(0.8);
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor, width: 1.5),
    );
  }

  InputDecoration themedInput(BuildContext context, String label, IconData icon, {String? hint}) {
    final theme = Theme.of(context);
    final fill = getCardColor(context);
    final labelColor = appState.selectedTheme == 'ytss'
        ? Colors.black
        : appState.selectedTheme == 'light'
            ? const Color(0xFF0070D1)
            : Colors.grey[300]!;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: appState.selectedTheme == 'ytss'? const Color.fromARGB(255, 17, 6, 161) : getAccent()),
      labelStyle: TextStyle(
        color: labelColor,
        fontFamily: "montserrat",
      ),
      filled: true,
      fillColor: fill,
      enabledBorder: buildBorder(context),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: appState.selectedTheme == 'ytss'
              ? const Color(0xFFFFC700)
              : theme.brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF0070D1),
          width: 2.0,
        ),
      ),
      border: buildBorder(context),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> classOptions = widget.selectedClasses.isNotEmpty
        ? widget.selectedClasses
        : widget.availableClasses;

    final theme = Theme.of(context);
    final isPhone = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: themedBackground(context),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    children: [
                      Text(
                        "Add Announcement",
                        style: TextStyle(
                          fontFamily: "montserrat",
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
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
                        "Add Announcement",
                        style: TextStyle(
                          fontFamily: "montserrat",
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: appState.selectedTheme == 'ytss'
                              ? const Color(0xFFFFC700)
                              : appState.selectedTheme == 'light'
                                  ? const Color(0xFF0070D1)
                                  : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: getCardColor(context),
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
                      const SizedBox(height: 4),

                      // Title field
                      TextField(
                        controller: _titleController,
                        style: TextStyle(
                          fontFamily: "montserrat",
                          color: getInputColor(context),
                        ),
                        decoration: themedInput(context, "Title", Icons.title),
                      ),
                      const SizedBox(height: 16),

                      // Class Picker
                      DropdownButtonFormField<String>(
                        decoration: themedInput(context, "Class", Icons.class_),
                        value: _selectedClass,
                        dropdownColor: getCardColor(context),
                        style: TextStyle(
                          fontFamily: "montserrat",
                          color: getInputColor(context),
                        ),
                        items: classOptions.map((className) {
                          return DropdownMenuItem(
                            value: className,
                            child: Text(
                              widget.displayClasses[className] ?? className,
                              style: TextStyle(
                                fontFamily: "montserrat",
                                color: getInputColor(context),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedClass = value);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextField(
                        controller: _descriptionController,
                        style: TextStyle(
                          fontFamily: "montserrat",
                          color: getInputColor(context),
                        ),
                        maxLines: 4,
                        decoration: themedInput(context, "Description", Icons.description),
                      ),
                      const SizedBox(height: 16),

                      // Due date
                      TextField(
                        controller: _dateController,
                        readOnly: true,
                        style: TextStyle(
                          fontFamily: "montserrat",
                          color: getInputColor(context),
                        ),
                        decoration: themedInput(context, "Due Date", Icons.calendar_today),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            _dateController.text = dateFormatDateTime(picked);
                            _selectedDueDate = picked;
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Visibility dropdown (Public / Personal)
                      DropdownButtonFormField<String>(
                        decoration: themedInput(context, "Visibility", Icons.visibility_outlined),
                        value: visibilityType,
                        dropdownColor: getCardColor(context),
                        style: TextStyle(
                          fontFamily: "montserrat",
                          color: getInputColor(context),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: "public",
                            child: Text(
                              "Public",
                              style: TextStyle(
                                fontFamily: "montserrat",
                                fontSize: 16,
                                color: getInputColor(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: "private",
                            child: Text(
                              "Personal",
                              style: TextStyle(
                                fontFamily: "montserrat",
                                fontSize: 16,
                                color: getInputColor(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (v) {
                          setState(() {
                            visibilityType = v;
                            isPublic = v == "public";
                          });
                        },
                      ),

                      const SizedBox(height: 28),

                      // Submit button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appState.selectedTheme == 'ytss'
                              ? const Color(0xFFFFC700)
                              : appState.selectedTheme == 'light'
                                  ? const Color(0xFF0070D1)
                                  : Colors.white,
                          padding: EdgeInsets.symmetric(vertical: isPhone ? 12 : 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async => await handleSubmit(),
                        child: Text(
                          isPublic ? "Publish" : "Add Privately",
                          style: TextStyle(
                            fontFamily: "montserrat",
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: appState.selectedTheme == 'dark'
                                ? Colors.black
                                : appState.selectedTheme == 'ytss'
                                    ? Colors.black
                                    : Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      if (visibilityType == "public") 
                        Text(
                          "Author and publish date will be recorded publicly.",
                          style: TextStyle(
                            fontFamily: "montserrat",
                            fontSize: 12,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.85),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Go back button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Go back.",
                    style: TextStyle(
                      fontFamily: "montserrat",
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
    );
  }

  Future<void> handleSubmit() async {
    var clazz = _selectedClass;
    var pickedDate = _selectedDueDate;

    if (_titleController.text.isEmpty ||
        clazz == null ||
        pickedDate == null ||
        visibilityType == null) {
      showSnackBar(context, "Please fill all fields.");
      return;
    }

    if (pickedDate.isBefore(DateTime.now())) {
      showSnackBar(context, "The due date cannot be before today.");
      return;
    }

    bool ok = await widget.homePageState.addAnnouncement(
      _titleController.text,
      clazz,
      pickedDate,
      DateTime.now(),
      _descriptionController.text,
      account.uuid,
      isPublic,
    );

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context);
      showSnackBar(
        context,
        isPublic
            ? "Announcement published successfully!"
            : "Personal announcement added.",
      );
    } else {
      showSnackBar(
        context,
        "Failed to send data. Check your internet.",
      );
    }
  }
}
