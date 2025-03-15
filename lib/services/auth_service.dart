import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/widgets/alert.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String allowDomain = "ku.th";

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if(user!=null){
        String emailDomain = user.email!.split('@')[1];
        print(emailDomain);
        if(emailDomain != allowDomain){
          signOut();
          throw Exception("e-mail ต้องเป็น @${allowDomain} เท่านั้น");
        }
        final querySnapshot = await _firestore
            .collection("users")
            .where("email", isEqualTo: user.email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          signOut();
          throw Exception("บัญชีของคุณไม่ได้รับอนุญาตให้เข้าใช้งาน");
        }
        return user;
      }
    } catch (e) {
      String errorMessage = e.toString().replaceFirst("Exception: ", "");
      AlertBox.showErrorDialog(context, errorMessage);
      return null;
    }
    return null;
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
    await GoogleSignIn().disconnect();
  }
}
