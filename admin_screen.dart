import 'package:flutter/material.dart';
import 'package:prueba/src/login_page.dart'; // Importa la pantalla de LoginPage
import 'package:google_fonts/google_fonts.dart'; // Importa Google Fonts
import 'admin_noticias.dart'; // Importa la nueva actividad de Noticias
import 'loggin_admin.dart'; // Importa la pantalla de login para administrador
import 'package:prueba/main.dart'; // Importa la pantalla principal

class AdminScreen extends StatelessWidget {
  static String id = 'admin_screen';
  const AdminScreen({super.key});

  void _showExitAdminDialog(BuildContext context) {
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
              '¿Quiere salir del modo administrador?',
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
                    MaterialPageRoute(builder: (context) => LoginPage()),
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
              '¿Desea cerrar sesión como administrador y regresar al menú principal?',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 224, 175, 12),
        title: Center(
          child: Text(
            'Panel de Administrador',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            _showExitAdminDialog(context);
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 224, 175, 12),
              Colors.amber.shade100,
              Colors.grey.shade200,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView( // Envolver en SingleChildScrollView para desplazamiento vertical
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Imagen del administrador con borde redondeado
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(25), // Borde redondeado de 25
                  ),
                  clipBehavior: Clip.antiAlias, // Habilita el recorte del borde
                  child: Image.asset(
                    'assets/Admin.png', // Asegúrate de que la imagen esté en la carpeta correcta
                    height: 300, // Tamaño más grande con sombra
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 20),

                // Texto de bienvenida
                Text(
                  '¡Bienvenido, Administrador!',
                  style: GoogleFonts.roboto(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                // Botones del panel de administrador
                _AdminButton(
                  icon: Icons.person_add,
                  label: 'Registrar Conductor',
                  color: Colors.green[700],
                  onPressed: () {
                    Navigator.pushNamed(context, '/registerDriver');
                  },
                ),

                const SizedBox(height: 20),

                _AdminButton(
                  icon: Icons.person_remove,
                  label: 'Dar de baja Conductor',
                  color: Colors.red[700],
                  onPressed: () {
                    Navigator.pushNamed(context, '/removeDriver');
                  },
                ),

                const SizedBox(height: 20),

                _AdminButton(
                  icon: Icons.edit,
                  label: 'Modificar Conductor',
                  color: Colors.blue[700],
                  onPressed: () {
                    Navigator.pushNamed(context, '/editDriver');
                  },
                ),

                const SizedBox(height: 20),

                _AdminButton(
                  icon: Icons.announcement,
                  label: 'Noticias',
                  color: Colors.orange[700],
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminNoticias()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget reutilizable para los botones del panel de administrador
class _AdminButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onPressed;

  const _AdminButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        backgroundColor: color,
        shadowColor: Colors.black45,
        elevation: 10, // Agrega sombra a los botones
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: Colors.white),
          const SizedBox(width: 20),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
