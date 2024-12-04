import 'package:flutter/material.dart';
import 'package:prueba/src/login_page.dart';
import 'package:prueba/src/tiemporealconductor.dart'; // Importa la pantalla correcta para Tiempo real
import 'package:prueba/src/conductor_tiempo_real.dart'; // Importa el archivo conductor_tiempo_real.dart

class MenuPrincipal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Evitar que el botón físico de retroceso funcione
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          // Flecha de retorno que muestra el diálogo de cierre de sesión
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              _showLogoutDialog(context, isBackPressed: false);
            },
          ),
          title: Center(
            child: Text(
              'Menú Principal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          backgroundColor: Colors.indigo[900],
          actions: [
            IconButton(
              icon: Icon(Icons.exit_to_app, color: Colors.white),
              onPressed: () {
                _showLogoutDialog(context, isBackPressed: true);
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.purple],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 20.0,
              children: <Widget>[
                MenuButton(
                  imagePath: 'assets/conductortiemporeal.png',
                  label: 'Conductores Tiempo Real',
                  imageSizeMultiplier: 1.20, // Tamaño ajustado a 1.20
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapaPage2()), // Navega a MapaPage2
                    );
                  },
                ),
                MenuButton(
                  imagePath: 'assets/cerrarsesion.png',
                  label: 'Cerrar Sesión',
                  imageSizeMultiplier: 1.05, // Tamaño ajustado a 1.05
                  onTap: () {
                    _showLogoutDialog(context, isBackPressed: false);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, {required bool isBackPressed}) {
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
              isBackPressed
                  ? '¿Quieres cerrar sesión y regresar al menú principal?'
                  : '¿Estás seguro que quieres salir del modo conductor?',
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
                    MaterialPageRoute(builder: (context) => LoginPage()),
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

class MenuButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;
  final double imageSizeMultiplier;

  MenuButton({
    required this.imagePath,
    required this.label,
    required this.onTap,
    this.imageSizeMultiplier = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 90.0 * imageSizeMultiplier,
            height: 90.0 * imageSizeMultiplier,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
