import 'package:flutter/material.dart';
import 'mainconductor.dart'; // Asegúrate de que esté en la ubicación correcta
import 'package:prueba/main.dart';

class ConductorTiempoReal extends StatelessWidget {
  const ConductorTiempoReal({super.key});

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
              '¿Está seguro de regresar al menú principal?',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[700],
        title: Center(
          child: Text(
            'Pantalla del Conductor',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MenuPrincipal()),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo[700]!, Colors.blue[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Text(
            'Pantalla donde el conductor tendrá los botones de advertencia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
