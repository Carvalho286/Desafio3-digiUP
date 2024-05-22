import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CRUDservice {
  User? user = FirebaseAuth.instance.currentUser;

  //CREATE
  Future addNewContacts(String name, String phone, String email) async {

    Map<String, dynamic> data = {
      'name': name,
      'email': email,
      'phone': phone
    };

    try {
      await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('contacts')
        .add(data);

      print('Document Added');
    } catch(e) {
      print(e);
    }

  }

  //READ
  Stream<QuerySnapshot> getContacts({String? searchQuery}) async* {

    var contactsQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('contacts')
        .orderBy('name');

    if (searchQuery != null && searchQuery.isNotEmpty) {
      String searchEnd = searchQuery + '\uf8ff';
      contactsQuery = contactsQuery.where('name', isGreaterThanOrEqualTo: searchQuery, isLessThan: searchEnd);
    }

    var contacts = contactsQuery.snapshots();

    yield* contacts;

  }

  //UPDATE
  Future updateContact(String name, String phone, String email, String contactId) async {

    Map<String, dynamic> data = {
      'name': name,
      'email': email,
      'phone': phone
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('contacts')
          .doc(contactId)
          .update(data);

      print('Document Updated');
    } catch(e) {
      print(e);
    }

  }

  //DELETE
  Future deleteContact(String contactId) async {
    try{
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('contacts')
          .doc(contactId)
          .delete();

      print('Document Deleted');
    } catch(e) {
      print(e.toString());
    }
  }


  //READ ONE CONTACT
  Future<DocumentSnapshot> getOneContact(String contactId) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('contacts')
        .doc(contactId)
        .get();
  }

}