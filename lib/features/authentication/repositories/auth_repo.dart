import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SIGNUP with Username & Password
  Future<User?> signUp(String username, String password) async {
    try {
      String fakeEmail = "$username@signumcode.com"; // Create a fake email
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: fakeEmail,
        password: password,
      );

      // Store the username in Firestore
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "username": username,
        "email": fakeEmail,
        "uid": userCredential.user!.uid,
      });

      return userCredential.user;
    } catch (e) {
      throw Exception("Signup failed: ${e.toString()}");
    }
  }

  // LOGIN with Username & Password
  Future<User?> login(String username, String password) async {
    try {
      String fakeEmail = "$username@signumcode.com"; // Convert username to fake email
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: fakeEmail,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential'||e.code == 'wrong-password') {
        throw FirebaseAuthException(code: e.code,message: 'Invalid Credential');
      }else {
        log(e.code);
        throw Exception("${e.code}");
      }
    } catch (e) {
      throw Exception("An unexpected error occurred: ${e.toString()}");
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // CHECK IF USERNAME EXISTS
  Future<bool> doesUsernameExist(String username) async {
    String fakeEmail = "$username@yourapp.com";
    var result = await _firestore.collection("users").where("email", isEqualTo: fakeEmail).get();
    return result.docs.isNotEmpty;
  }
}