import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

String userName;
String userEmail;
String userImage;
String userId;

Future<String> signInWithGoogle() async {
  try {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    if (user.email == null ||
        user.displayName == null ||
        user.photoUrl == null) {
      return null;
    }

    userName = user.displayName;
    userEmail = user.email;
    userImage = user.photoUrl;

    // Only taking the first part of the name, i.e., First Name
    if (userName.contains(" ")) {
      userName = userName.substring(0, userName.indexOf(" "));
    }

    if (user.isAnonymous || await user.getIdToken() == null) {
      return null;
    }

    final FirebaseUser currentUser = await _auth.currentUser();

    if (user.uid != currentUser.uid) {
      return null;
    }

    userId = user.uid;
    return 'signInWithGoogle succeeded: $user';
  } catch (error) {
    return null;
  }
}

void signOutGoogle() async {
  await googleSignIn.signOut();
  userId = null;
}

