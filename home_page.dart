// PANTALLA DESPUÉS DE INICIAR SESIÓN DEL CONDUCTOR
//No habilitada no sirve de nada 
import 'package:flutter/material.dart';
import 'login_page.dart';  // Importamos la página de login del conductor

class HomePage extends StatelessWidget {
  static String id = 'home_page';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,  // Cambiamos el color del AppBar
        title: const Text('Inicio de Sesión'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),  // Icono de salir en la esquina superior izquierda
          onPressed: () {
            Navigator.pushReplacementNamed(context, LoginPage.id);  // Regresa al login del conductor
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Text(
              '¡Bienvenido Conductor!',
              style: TextStyle(
                fontSize: 28,  // Aumentamos el tamaño de la fuente
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,  // Cambiamos el color del texto
              ),
            ),
          ),
          const SizedBox(height: 30.0),  // Aumentamos el espacio entre el texto y otros elementos
        ],
      ),
      backgroundColor: Colors.grey[100],  // Color de fondo más claro para un diseño limpio
    );
  }
}
