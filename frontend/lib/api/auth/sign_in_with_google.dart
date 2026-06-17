import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sona/api/auth/api_auth.dart';

class GoogleAuthService {
    
    final FirebaseAuth _auth = FirebaseAuth.instance;
    
    final GoogleSignIn _googleSignIn = GoogleSignIn(
      serverClientId: '388389040333-dtdo4ucu30bglqs46l7g7bft3srk6l16.apps.googleusercontent.com',
      clientId: '388389040333-dtdo4ucu30bglqs46l7g7bft3srk6l16.apps.googleusercontent.com',
    );
    
    Future<Map<String, dynamic>?> signInWithGoogle() async {
      
      try {
        await _googleSignIn.signOut();
        final googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          return null;
        }

        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential =
            await _auth.signInWithCredential(credential);

        final firebaseUser = userCredential.user;

        if (firebaseUser == null) return null;

        return await ApiAuth().googleLogin(
          email: firebaseUser.email ?? googleUser.email,
          nama: firebaseUser.displayName ?? googleUser.displayName ?? 'Google User',
          photoProfile: firebaseUser.photoURL ?? googleUser.photoUrl,
        );

      } catch (e) {
        throw Exception('Gagal login dengan google: $e');
      }
    }
    
    Future<void> signOut() async {
        
        await _googleSignIn.signOut();
        
        await _auth.signOut(); 
    }
}