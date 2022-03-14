import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_journal/models/journal.dart';

class FirestoreService {
  FirebaseFirestore? _firestore;
  CollectionReference? _journals;
  FirebaseAuth? _auth;
  String? _uid;

  CollectionReference? get journals => _journals;

  FirestoreService() {
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
    _uid = _auth?.currentUser?.uid;
    _journals = _firestore!.collection(_uid!);
  }

  Future<void> create(Journal journal) async {
    final journalDoc = _journals!.doc();
    final journalWithId = journal..id = journalDoc.id;

    await journalDoc
        .set(Journal.encrypt(journalWithId).toJson())
        .timeout(const Duration(seconds: 3), onTimeout: () {});

    // setting the timeout so the offline storage of firestore works
    // https://stackoverflow.com/questions/53549773/using-offline-persistence-in-firestore-in-a-flutter-app
  }

  Future<void> update(Journal journal) async {
    final journalDoc = _journals!.doc(journal.id);
    await journalDoc
        .update(Journal.encrypt(journal).toJson())
        .timeout(const Duration(seconds: 3), onTimeout: () {});

    // setting the timeout so the offline storage of firestore works
    // https://stackoverflow.com/questions/53549773/using-offline-persistence-in-firestore-in-a-flutter-app
  }

  Future<void> delete(Journal journal) async {
    final journalDoc = _journals!.doc(journal.id);
    await journalDoc.delete();
  }
}
