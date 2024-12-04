import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class MapaRed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
        title: Text(
          'Red del Metro',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Regresa a la pantalla anterior
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepOrange,
              Colors.orangeAccent,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              '¡Bienvenido Viajero!',
              style: TextStyle(
                fontSize: 38, // Ajuste del tamaño de la fuente
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25), // Borde redondeado
                child: PhotoView(
                  imageProvider: AssetImage('assets/Red_Metro.jpg'),
                  minScale: PhotoViewComputedScale.contained, // Ajusta la imagen a la pantalla
                  maxScale: PhotoViewComputedScale.covered * 4.0, // Permite zoom hasta 4x
                  backgroundDecoration: BoxDecoration(
                    color: Colors.transparent, // Fondo transparente para ver el degradado
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'MexYoani',
              style: TextStyle(
                fontSize: 30, // Ajuste del tamaño de la fuente
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'Viajando en el Corazón de México',
              style: TextStyle(
                fontSize: 26, // Ajuste del tamaño de la fuente
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
