import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Función para iniciar sesión con correo y contraseña
  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Intentamos iniciar sesión con las credenciales
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      // Verificamos si el usuario tiene un UID válido
      if (user?.uid != null) {
        return user?.uid; // Retornamos el UID si es exitoso
      } else {
        return null; // Si no se obtuvo un UID, retornamos null
      }
    } on FirebaseAuthException catch (e) {
      // Manejamos los errores comunes
      if (e.code == 'user-not-found') {
        return 'User not found'; // Retornamos un mensaje de error
      } else if (e.code == 'wrong-password') {
        return 'Wrong password'; // Retornamos un mensaje de error
      } else {
        return 'Error: ${e.message}'; // Cualquier otro error
      }
    }
  }
}
