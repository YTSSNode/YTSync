import 'package:ytsync/main.dart';
import 'package:ytsync/util.dart';

Account createAccount() {
  return Account(
    email: "felix@yay.com",
    name: "Felix",
    uuid: "cbJ31YQ4RtNjgBDFdcEBsU30AhX2",
  );
}

List<AnnouncementData> getAnnouncementsPlaceholder() {
  return [
    AnnouncementData(
      "Math Test",
      "Class 1",
      DateTime(2025, 2, 28),
      "Mr. Johnson",
      "Prepare for calculus test on derivatives and integrals.",
      "1",
      false,
    ),
    AnnouncementData(
      "English Essay",
      "Class 2",
      DateTime(2025, 3, 3),
      "Ms. Williams",
      "Write a 500-word essay on Shakespeare's Hamlet.",
      "2",
      false,
    ),
    AnnouncementData(
      "Physics Lab",
      "Class 3",
      DateTime(2025, 3, 25),
      "Dr. Smith",
      "Prepare for lab on momentum and collisions.",
      "3",
      false,
    ),
    AnnouncementData(
      "History Project",
      "Class 4",
      DateTime(2025, 3, 10),
      "Mrs. Davis",
      "Complete research project on World War II.",
      account.uuid,
      false,
    ),
    AnnouncementData(
      "Chemistry Quiz",
      "Class 5",
      DateTime(2025, 3, 1),
      "Dr. Wilson",
      "Study periodic table and chemical bonding for quiz.",
      account.uuid,
      false,
    ),
    AnnouncementData(
      "Art Exhibition",
      "Class 6",
      DateTime(2025, 3, 15),
      "Ms. Thompson",
      "Prepare your portfolio for the spring exhibition.",
      account.uuid,
      false,
    ),
    AnnouncementData(
      "Computer Science Project",
      "Class 7",
      DateTime(2025, 3, 7),
      "Mr. Anderson",
      "Complete your programming assignment on data structures.",
      "1",
      true,
    ),
    AnnouncementData(
      "Music Recital",
      "Class 8",
      DateTime(2025, 3, 20),
      "Mr. Lewis",
      "Practice your piece for the upcoming recital.",
      account.uuid,
      true,
    ),
    AnnouncementData(
      "Biology Exam",
      "Class 9",
      DateTime(2025, 3, 12),
      "Dr. Harris",
      "Study cell biology and genetics for midterm exam.",
      account.uuid,
      false,
    ),
    AnnouncementData(
      "Physical Education",
      "Class 10",
      DateTime(2025, 3, 2),
      "Coach Brown",
      "Bring appropriate gear for basketball tournament.",
      account.uuid,
      false,
    ),
  ];
}

List<(String, bool)> getClassesPlaceholder() {
  return [
    ("Class 1", true),
    ("Class 2", true),
    ("Class 3", true),
    ("Class 4", true),
    ("Class 5", true),
    ("Class 6", true),
    ("Class 7", true),
    ("Class 8", true),
    ("Class 9", true),
    ("Class 10", true),
  ];
}
