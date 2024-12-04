import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'loggin_admin.dart';
import 'mainconductor.dart';
import 'package:prueba/main.dart';

Future<String?> obtenerUID() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userUID');
}

class LoginPage extends StatefulWidget {
  static String id = 'login_page';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      var user = userCredential.user;
      if (user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userUID', user.uid);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuPrincipal()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.code == 'user-not-found'
            ? 'Usuario no encontrado. Verifique su correo.'
            : 'Contraseña incorrecta. Intente de nuevo.';
      });
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showLogoutDialog(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo[900],
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          title: Center(
            child: Text(
              'Inicio de Sesión Conductor',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo, Colors.purple],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(
                        'assets/logo.png',
                        height: 300.0,
                        width: 300.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      '¡Bienvenido Conductor!',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    _userTextField(),
                    const SizedBox(height: 15),
                    _passwordTextField(),
                    const SizedBox(height: 20.0),
                    if (_errorMessage != null)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10.0),
                    _isLoading ? CircularProgressIndicator() : _buttonLogin(),
                    const SizedBox(height: 10.0),
                    _buttonAdminLogin(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          icon: Icon(Icons.email, color: Colors.black87, size: 30),
          hintText: 'ejemplo@correo.com',
          labelText: 'Correo electrónico',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.black87),
        ),
      ),
    );
  }

  Widget _passwordTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(
          icon: Icon(Icons.lock, color: Colors.black87, size: 30),
          hintText: 'Contraseña',
          labelText: 'Contraseña',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buttonLogin() {
    return SizedBox(
      width: 250,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 10.0,
        ),
        onPressed: _login,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: const Text(
            'Iniciar Sesión',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buttonAdminLogin() {
    return SizedBox(
      width: 250,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange[700],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5.0,
        ),
        onPressed: () {
          Navigator.pushNamed(context, AdminLoginPage.id);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: const Text(
            'Administrador',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
          ),
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
              '¿Estás seguro que quieres salir del modo conductor?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
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
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
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