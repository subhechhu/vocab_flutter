import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authentication {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String _email = '';
  String _userId = '';

  String getEmail() {
    return _email;
  }

  String getUserId() {
    return _userId;
  }

  GoogleSignIn getUser() {
    return _googleSignIn;
  }

  Future<bool> googleSignIn(Future<SharedPreferences> _prefs) async {
    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken);
    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(authCredential);

    final User user = userCredential.user;

    _email = user.email;
    _userId = user.uid;

    _prefs.then((SharedPreferences pref) {
      pref.setString("email", user.email);
      pref.setString("displayName", user.displayName);
      pref.setBool("isLoggedIn", true);
      pref.setString("userId", user.uid);
    });

    if (user.email == null) return false;

    return true;
  }
}
