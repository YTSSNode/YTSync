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
      return "ID already used.";
    case "wrong-password":
      return "Wrong ID/password combination.";
    case "user-not-found":
      return "No user found with this ID.";
    case "user-disabled":
      return "User disabled.";
    case "too-many=requests":
      return "Too many requests to log into this account.";
    case "operation-not-allowed":
      return "Server error, please try again later.";
    case "invalid-email":
      return "ID is invalid.";
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
  String idNum = "",
  String password = "",
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

      var accountUnsafe = await signIn(idNum, password);
      if (accountUnsafe is String) {
        return (false, accountUnsafe);
      } else if (accountUnsafe is Account) {
        account = accountUnsafe;
      } else {
        return (false, "Unknown error occurred.");
      }
    }

    //get all public announcements
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
          content["author"],
          content["desc"],
          content["authorUUID"],
          true,
        );
        data.setId(content["id"]);

        //check if user has completed it
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

        //read if annc is complete, if it is call this function
        _announcementServer.add(data);
      }
    });

    //get all private announcements
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
              content["author"],
              content["desc"],
              content["authorUUID"],
              false,
            );
            data.setId(content["id"]);

            //check if private announcement is completed
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

            //read if annc is complete, if it is call this function
            _announcementServer.add(data);
          }
        });

    //class name format: ${Sec 4/3/2/1} ${class name}
    for (String level in ["Sec 4", "Sec 3", "Sec 2", "Sec 1"]) {
      await database.collection("classes").doc(level).get().then((item) {
        Map<String, dynamic>? content = item.data();
        for (String name in (content?.keys.toList() ?? [])) {
          _classServer.add("$level $name");
          _classUser.add(NetworkClass("$level $name", false));
        }
      });
    }

    //get selected classes
    await database
        .collection("users")
        .doc(account.uuid)
        .collection("classes")
        .get()
        .then((item) {
          for (var minidoc in item.docs) {
            Map<String, dynamic> content = minidoc.data();
            if (!_classUser.contains(NetworkClass(minidoc.id, false))) {
              _classUser.add(NetworkClass(minidoc.id, content["isselected"]));
            } else if (content["isselected"]) {
              _classUser[_classUser.indexOf(NetworkClass(minidoc.id, false))]
                  .selected = content["isselected"];
            }
          }
        });
    //removing classes from the user that no longer exists.
    for (var currentclass in _classUser) {
      if (!_classServer.contains(currentclass.name)) {
        _classUser.remove(currentclass);
        database
            .collection("users")
            .doc(account.uuid)
            .collection("classes")
            .doc(currentclass.name)
            .delete();
      }
    }
  } on FirebaseException catch (e) {
    // Caught an exception from Firebase.
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
      var document = database
          .collection("announcements")
          .doc(data.getChecksum());
      await document.set({
        "author": account.name,
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
        "author": account.name,
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
      print(data.getChecksum());
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
      "class": clazz,
      "registernum": registerNumber,
    });

    // Update the class's register number document in Firestore
    await database.collection("classRegNum").doc(clazz).set({
      registerNumber:
          "", // Assuming you're storing the registerNumber under the class document
    }, SetOptions(merge: true));

    // Update current session with the new user details
    currentSession = Account(
      name: name,
      id: emailAddress,
      uuid: uuid,
      permission: "student",
    );
  } on FirebaseAuthException catch (e) {
    // Return error message if FirebaseAuthException occurs
    return getMessageFromErrorCodeAuth(e);
  }

  // Return the updated current session after successful registration
  return currentSession;
}

Future<dynamic> signIn(String id, String password) async {
  var currentSession = Account(
    name: "guest",
    id: "guest",
    uuid: "0",
    permission: "student",
  );

  try {
    // Sign in with Firebase Authentication
    var permission = "";
    var emailAddress = "";
    var database = FirebaseFirestore.instance;
    var info = await database.collection("idsearch").doc(id).get();
    if (info.exists) {
      Map<String, dynamic>? content = info.data();
      emailAddress = content?["email"] ?? "";
    }
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailAddress,
      password: password,
    );

    String name = "", uuid = "0";
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uuid = user.uid;

      // Await the result from Firestore to ensure the name is fetched before continuing
      var docSnapshot = await database.collection("users").doc(uuid).get();
      if (docSnapshot.exists) {
        Map<String, dynamic>? content = docSnapshot.data();
        name =
            content?["name"] ??
            "guest"; // Ensure name is safely fetched, default to "guest"
        permission = content?["permission"] ?? "student";
      }
    }

    // Update currentSession with fetched data
    currentSession = Account(
      name: name,
      id: emailAddress,
      uuid: uuid,
      permission: permission,
    );
  } on FirebaseAuthException catch (e) {
    return getMessageFromErrorCodeAuth(e);
  } on FirebaseException catch (e) {
    return getMessageFromErrorCode(e);
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
  try {
    var database = FirebaseFirestore.instance;
    // Iterate through the _formClass list to check if the clazz matches
    for (String currClass in _formClass) {
      if (currClass == clazz) {
        // Fetch the document from the Firestore collection
        var docSnapshot =
            await database.collection("classRegNum").doc(currClass).get();

        // Check if the document exists and contains the regNum key
        if (docSnapshot.exists) {
          Map<String, dynamic>? content = docSnapshot.data();
          return content?.containsKey(regNum) ??
              false; // Return true if regNum exists, false otherwise
        } else {
          return "Class does not exist. ($clazz)"; // If the document doesn't exist, return false
        }
      }
    }
    return "Class does not exist. ($clazz)"; // If the clazz isn't found in _formClass, return false
  } on FirebaseException catch (e) {
    // Handle Firebase-specific errors
    return getMessageFromErrorCode(e);
  }
}

Future<String?> passwordReset(String useruuid, String password) async {
  // if its password resetting, run passwordReset(user(from admin panel),"YTSS@2025")
  //else, run the function with the new password given (user = take from current session)
  try {
    var database = FirebaseFirestore.instance;
  } on FirebaseAuthException catch (e) {
    return getMessageFromErrorCodeAuth(e);
  } on FirebaseException catch (e) {
    return getMessageFromErrorCode(e);
  }
}
