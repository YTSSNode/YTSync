import 'package:firebase_core/firebase_core.dart';
import 'package:ytsync/firebase_options.dart';
import 'package:ytsync/main.dart';
import 'package:ytsync/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

class NetworkClass {
  String name;
  bool selected;

  NetworkClass(this.name, this.selected);

  @override
  bool operator ==(Object other) =>
      other is NetworkClass && other.hashCode == hashCode;

  @override
  int get hashCode => name.hashCode;
}

List<AnnouncementData> _announcementServer = [];
List<NetworkClass> _classUser = [];
List<String> _classServer = [];
List<String> _formClass = [];
String getMessageFromErrorCodeAuth(e) {
  switch (e.code) {
    case "account-exists-with-different-credential":
    case "email-already-in-use":
      return "Email already used. Please go to the login page.";
    case "wrong-password":
      return "Wrong email/password combination.";
    case "user-not-found":
      return "No user found with this email.";
    case "user-disabled":
      return "User disabled.";
    case "too-many=requests":
      return "Too many requests to log into this account.";
    case "operation-not-allowed":
      return "Server error, please try again later.";
    case "invalid-email":
      return "Email address is invalid.";
    case "weak-password":
      return "";
    case "expired-action-code":
      return "";
    case "invalid-action-code":
      return "";
    default:
      return "Something went wrong. Please try again.";
  }
}

String getMessageFromErrorCode(e) {
  switch (e.code) {
    case "aborted":
      return "Error: Connection Aborted.";
    case "already-exists":
      return "";
    case "cancelled":
      return "";
    case "data-loss":
      return "";
    case "deadline-exceeded":
      return "";
    case "failed-precondition":
      return "";
    case "internal":
      return "";
    case "invalid-argument":
      return "";
    case "not-found":
      return "";
    case "out-of-range":
      return "";
    case "permission-denied":
      return "";
    case "resource-exhausted":
      return "";
    case "unauthenticated":
      return "";
    case "unavailable":
      return "";
    case "unimplemented":
      return "";
    default:
      return "";
  }
}

Future<(bool, String)> firebaseInit([
  bool initApp = true,
  String email = "",
  String password = "",
  String? name,
  String clazz = "",
  String registerNumber = "",
]) async {
  try {
    var database = FirebaseFirestore.instance;
    _announcementServer.clear();
    _classServer.clear();
    _classUser.clear();
    _formClass.clear();

    if (initApp) {
      await database.collection("classRegNum").get().then((event) {
        for (var doc in event.docs) {
          _formClass.add(doc.id);
        }
      });

      dynamic accountUnsafe;

      if (name == null) {
        accountUnsafe = await signIn(email, password);
      } else {
        if (!_formClass.contains(clazz)) {
          return (false, "Class does not exist.");
        }

        accountUnsafe = await registerAccount(
          email,
          password,
          name,
          clazz,
          registerNumber,
        );
      }

      if (accountUnsafe is String) {
        return (false, accountUnsafe);
      } else if (accountUnsafe is Account) {
        account = accountUnsafe;
      } else {
        return (false, "Unknown error occurred.");
      }
    }

    await database.collection("announcements").get().then((event) {
      for (var doc in event.docs) {
        Map<String, dynamic> content = doc.data();
        AnnouncementData data = AnnouncementData(
          content["title"],
          content["class"],
          DateTime.parse(content["due"].toDate().toString()),
          content.containsKey("publish")
              ? DateTime.parse(content["publish"].toDate().toString())
              : null,
          content["desc"],
          content["authorUUID"],
          true,
        );
        data.setId(content["id"]);

        database
            .collection("users")
            .doc(account.uuid)
            .collection("completed")
            .doc(data.getChecksum())
            .get()
            .then((item) {
              final content2 = item.data();
              if (content2 != null && content2["isCompleted"]) {
                data.complete(true);
              }
            });

        _announcementServer.add(data);
      }
    });

    await database
        .collection("users")
        .doc(account.uuid)
        .collection("announcements")
        .get()
        .then((item) {
          for (var doc in item.docs) {
            Map<String, dynamic> content = doc.data();
            AnnouncementData data = AnnouncementData(
              content["title"],
              content["class"],
              DateTime.parse(content["due"].toDate().toString()),
              content.containsKey("publish")
                  ? DateTime.parse(content["publish"].toDate().toString())
                  : null,
              content["desc"],
              content["authorUUID"],
              false,
            );
            data.setId(content["id"]);

            database
                .collection("users")
                .doc(account.uuid)
                .collection("completed")
                .doc(data.getChecksum())
                .get()
                .then((item) {
                  final content2 = item.data();
                  if (content2 != null && content2["isCompleted"]) {
                    data.complete(true);
                  }
                });

            _announcementServer.add(data);
          }
        });

    for (String level in ["Sec 4", "Sec 3", "Sec 2", "Sec 1"]) {
      await database.collection("classes").doc(level).get().then((item) {
        Map<String, dynamic>? content = item.data();
        for (String name in (content?.keys.toList() ?? [])) {
          _classServer.add(name);
          _classUser.add(NetworkClass(name, false));
        }
      });
    }

    await database
        .collection("users")
        .doc(account.uuid)
        .collection("classes")
        .get()
        .then((item) {
          for (var minidoc in item.docs) {
            Map<String, dynamic> content = minidoc.data();
            if (!_classUser.contains(NetworkClass(minidoc.id, false))) {
              _classUser.add(
                NetworkClass(minidoc.id, content["isselected"]),
              );
            } else if (content["isselected"]) {
              _classUser[
                      _classUser.indexOf(NetworkClass(minidoc.id, false))]
                  .selected = true;
            }
          }
        });

    _classUser.removeWhere((c) {
      if (!_classServer.contains(c.name)) {
        database
            .collection("users")
            .doc(account.uuid)
            .collection("classes")
            .doc(c.name)
            .delete();
        return true;
      }
      return false;
    });
  } on FirebaseException catch (e) {
    return (false, getMessageFromErrorCode(e));
  }

  return (true, "");
}

Future<bool> sendAnnouncementToServer(
  AnnouncementData data,
  bool isPublic,
) async {
  try {
    var database = FirebaseFirestore.instance;
    data.setId(Random().nextInt(1 << 16));
    if (isPublic) {
      var document = database.collection("announcements").doc(data.getChecksum());
      await document.set({
        "authorUUID": data.getAuthorUUID(),
        "class": data.getClass(),
        "desc": data.getDesc(),
        "due": data.getDueAsDateTime(),
        "id": data.getId(),
        "title": data.getTitle(),
      });

      if (data.getPublishAsDateTime() != null) {
        await document.update({"publish": data.getPublishAsDateTime()});
      }

      await database
          .collection("users")
          .doc(account.uuid)
          .collection("completed")
          .doc(data.getChecksum())
          .set({"isCompleted": false});
    } else {
      var document = database
          .collection("users")
          .doc(account.uuid)
          .collection("announcements")
          .doc(data.getChecksum());
      await document.set({
            "authorUUID": data.getAuthorUUID(),
            "class": data.getClass(),
            "desc": data.getDesc(),
            "due": data.getDueAsDateTime(),
            "id": data.getId(),
            "title": data.getTitle(),
          });

      if (data.getPublishAsDateTime() != null) {
        await document.update({"publish": data.getPublishAsDateTime()});
      }

      await database
          .collection("users")
          .doc(account.uuid)
          .collection("completed")
          .doc(data.getChecksum())
          .set({"isCompleted": false});
    }
  } on FirebaseException catch (e) {
    // Caught an exception from Firebase.
    getMessageFromErrorCode(e);
    return false;
  }
  return true;
}

List<AnnouncementData>? receiveAnnouncementFromServer() {
  return _announcementServer;
}

Future<bool> deleteAnnouncementFromServer(AnnouncementData data) async {
  try {
    var database = FirebaseFirestore.instance;
    if (data.isPublic()) {
      database.collection("announcements").doc(data.getChecksum()).delete();
      //TODO: use Cloud Functions to delete all users' announcements
    } else {
      database
          .collection("users")
          .doc(account.uuid)
          .collection("announcements")
          .doc(data.getChecksum())
          .delete();
    }

    database
        .collection("users")
        .doc(account.uuid)
        .collection("completed")
        .doc(data.getChecksum())
        .delete();
  } on FirebaseException catch (e) {
    getMessageFromErrorCode(e);
    return false;
  }
  return true;
}

Future<bool> completeAnnouncementInServer(data, bool complete) async {
  try {
    var database = FirebaseFirestore.instance;
    await database
        .collection("users")
        .doc(account.uuid)
        .collection("completed")
        .doc(data.getChecksum())
        .set({"isCompleted": complete});
  } on FirebaseException catch (e) {
    getMessageFromErrorCode(e);
    return false;
  }
  return true;
}

Future<bool> changeSelectedClassesInServer(String clazz, bool selected) async {
  try {
    var database = FirebaseFirestore.instance;
    final file = database
        .collection("users")
        .doc(account.uuid)
        .collection("classes")
        .doc(clazz);
    file.set({"isselected": selected});
  } on FirebaseException catch (e) {
    getMessageFromErrorCode(e);
    return false;
  }
  return true;
}

List<NetworkClass> receiveClassesFromServer() {
  return _classUser;
}

Future<dynamic> registerAccount(
  String emailAddress,
  String password,
  String name,
  String clazz,
  String registerNumber,
) async {
  var database = FirebaseFirestore.instance;
  // Initial default session
  Account? currentSession;

  try {
    // Check if an account with the same class and register number exists
    var checkResult = await checkClassRegisterNumber(clazz, registerNumber);

    // If the checkClassRegisterNumber returns an error message (String), return that message
    if (checkResult is String) {
      return checkResult; // Return the error message if there's an issue
    }

    // Proceed with account registration if the class and register number don't already exist
    if (checkResult == true) {
      return "Account with the same class and register number exists. Please log in or press 'forgot password' if you have forgotten your password.";
    }

    // Create user in FirebaseAuth
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailAddress,
      password: password,
    );

    // Get the current authenticated user
    User? user = FirebaseAuth.instance.currentUser;
    String uuid = (user != null) ? user.uid : "0";

    // Store user information in Firestore
    await database.collection("users").doc(uuid).set({
      "name": name,
      "email": emailAddress,
      "class": clazz,
      "registernum": registerNumber,
    });

    // Update the class's register number document in Firestore
    await database.collection("classRegNum").doc(clazz).set({
      registerNumber:
          "", // Assuming you're storing the registerNumber under the class document
    }, SetOptions(merge: true));

    // Update current session with the new user details
    currentSession = Account(name: name, email: emailAddress, uuid: uuid);
  } on FirebaseAuthException catch (e) {
    // Return error message if FirebaseAuthException occurs
    return getMessageFromErrorCodeAuth(e);
  }

  // Return the updated current session after successful registration
  return currentSession;
}

Future<dynamic> signIn(String emailAddress, String password) async {
  var currentSession = Account(name: "guest", email: "guest", uuid: "0");

  try {
    // Sign in with Firebase Authentication
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailAddress,
      password: password,
    );

    String name = "", uuid = "0";
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uuid = user.uid;
      var database = FirebaseFirestore.instance;

      // Await the result from Firestore to ensure the name is fetched before continuing
      var docSnapshot = await database.collection("users").doc(uuid).get();
      if (docSnapshot.exists) {
        Map<String, dynamic>? content = docSnapshot.data();
        name =
            content?["name"] ??
            "guest"; // Ensure name is safely fetched, default to "guest"
      }
    }

    // Update currentSession with fetched data
    currentSession = Account(name: name, email: emailAddress, uuid: uuid);
  } on FirebaseAuthException catch (e) {
    return getMessageFromErrorCodeAuth(e);
  }

  return currentSession;
}

Future<String?> signOut() async {
  try {
    await FirebaseAuth.instance.signOut();
  } on FirebaseAuthException catch (e) {
    return getMessageFromErrorCodeAuth(e);
  }
  return null;
}

Future<String?> resetPassword(String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  } on FirebaseAuthException catch (e) {
    return getMessageFromErrorCodeAuth(e);
  } on FirebaseException catch (e) {
    return getMessageFromErrorCode(e);
  }
  return null;
}

Future<dynamic> checkClassRegisterNumber(String clazz, String regNum) async {
  print("DEBUG: Checking class '$clazz' against _formClass: $_formClass");

  try {
    var database = FirebaseFirestore.instance;

    // Convert input to uppercase and trim spaces
    String inputClass = clazz.trim().toUpperCase();

    for (String currClass in _formClass) {
      String docClass = currClass.trim().toUpperCase();
      print("DEBUG: Comparing input '$inputClass' with document ID '$docClass'");

      if (docClass == inputClass) {
        // Fetch the document from Firestore
        var docSnapshot = await database.collection("classRegNum").doc(currClass).get();

        if (docSnapshot.exists) {
          Map<String, dynamic>? content = docSnapshot.data();
          print("DEBUG: Found class document '$currClass' with content: $content");

          // Return true if register number exists, false otherwise
          return content?.containsKey(regNum) ?? false;
        } else {
          print("DEBUG: Document '$currClass' does not exist in Firestore!");
          return "Class does not exist. ($clazz)";
        }
      }
    }

    // No match found
    print("DEBUG: No matching class found for '$inputClass'");
    return "Class does not exist. ($clazz)";

  } on FirebaseException catch (e) {
    print("DEBUG: Firebase exception: $e");
    return getMessageFromErrorCode(e);
  }
}
