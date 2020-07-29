import 'package:firebase_database/firebase_database.dart';

class UploadContact {
  String key;
  String name;
  String phoneNumber;

  UploadContact(this.name, this.phoneNumber);

  UploadContact.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value["name"],
        phoneNumber = snapshot.value["phone"];

  toJson() {
    return {"name": name, "phone": phoneNumber};
  }
}
