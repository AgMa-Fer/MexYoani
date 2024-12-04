import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_screen.dart'; // Pantalla a la que redirigirá después del login exitoso
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart'; // Importa la pantalla de inicio de sesión
import 'package:prueba/main.dart'; // Importa la página principal

class AdminLoginPage extends StatefulWidget {
  static String id = 'admin_login_page';

  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  final String adminEmail = "administrador1@gmail.com";

  Future<void> _login() async {
    try {
      if (_emailController.text == adminEmail) {
        // Autenticación exitosa, redirigir a AdminScreen directamente
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        Navigator.pushReplacementNamed(context, AdminScreen.id);
      } else {
        setState(() {
          _errorMessage = 'Acceso denegado. Solo administradores pueden ingresar.';
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.code == 'user-not-found'
            ? 'Usuario no encontrado. Verifique su correo.'
            : e.code == 'wrong-password'
                ? 'Contraseña incorrecta. Intente de nuevo.'
                : 'Error al iniciar sesión. Intente de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Center(
            child: Text(
              'Login de Administrador',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.exit_to_app, color: Colors.white),
              onPressed: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepOrange, Colors.amber],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40.0),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(
                        'assets/Admin.png',
                        height: 300,
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    const Text(
                      '¡Bienvenido Administrador!',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30.0),
                    _emailTextField(),
                    const SizedBox(height: 20.0),
                    _passwordTextField(),
                    const SizedBox(height: 20.0),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    _loginButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emailTextField() {
    return Row(
      children: [
        const Icon(Icons.email, color: Colors.black87, size: 30),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Correo electrónico',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
              labelStyle: TextStyle(color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordTextField() {
    return Row(
      children: [
        const Icon(Icons.lock, color: Colors.black87, size: 30),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Contraseña',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
              labelStyle: TextStyle(color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  Widget _loginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrange,
        padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Iniciar Sesión',
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Center(
            child: Text(
              '¿Deseas salir al menú principal?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.deepOrange[700],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.close, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'No',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.check, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Sí',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
