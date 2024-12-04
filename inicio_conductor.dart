import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prueba/src/login_page.dart';
import 'package:prueba/src/home_page.dart';
import 'package:prueba/src/loggin_admin.dart';
import 'package:prueba/src/admin_screen.dart';
import 'package:prueba/src/register_driver_screen.dart';  // Importamos la pantalla de registrar conductor
import 'package:prueba/src/remove_driver_screen.dart';  // Importamos la pantalla de eliminar conductor
import 'package:prueba/src/edit_driver_screen.dart';  // Importamos la pantalla de modificar conductor
import 'firebase_options.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Conductor());
}

class Conductor extends StatelessWidget {
  
  const Conductor({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metro Conductor App',
      debugShowCheckedModeBanner: false,
      initialRoute: LoginPage.id,
      routes: {
        // Rutas del proyecto
        LoginPage.id: (context) => const LoginPage(),
        HomePage.id: (context) => const HomePage(),
        AdminLoginPage.id: (context) => const AdminLoginPage(),
        AdminScreen.id: (context) => const AdminScreen(),
        '/registerDriver': (context) => const RegisterDriverScreen(),  // Ruta para registrar conductor
        '/removeDriver': (context) => const RemoveDriverScreen(),  // Ruta para eliminar conductor
        '/editDriver': (context) => const EditDriverScreen(),  // Ruta para modificar conductor
      },
    );
  }
}
