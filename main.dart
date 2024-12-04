import 'package:flutter/material.dart';
import 'package:prueba/src/estadoservicio.dart';
import 'package:prueba/src/rutas.dart';
import 'package:prueba/src/tiemporealusuario.dart'; // Importa la pantalla correcta para Tiempo real
import 'package:prueba/utils/inicio_conductor.dart';
import 'package:prueba/utils/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prueba/src/mapa_red.dart'; // Importación del archivo Mapa_red.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Aplicación',
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(),
        primarySwatch: Colors.orange,
        appBarTheme: AppBarTheme(
          color: Colors.orange,
          titleTextStyle: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('es', 'MX'),
        const Locale('en', ''),
      ],
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menú Principal'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepOrange, Colors.orangeAccent],
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
                imagePath: 'assets/tiemporeal.png',
                label: 'Tiempo Real',
                imageSizeMultiplier: 1.30,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapaPage()),
                  );
                },
              ),
              MenuButton(
                imagePath: 'assets/rutas.png',
                label: 'Rutas',
                imageSizeMultiplier: 1.15,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RutasPage()),
                  );
                },
              ),
              MenuButton(
                imagePath: 'assets/estadodelservicio.png',
                label: 'Estado del Servicio',
                imageSizeMultiplier: 1.10,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EstadoServicio()),
                  );
                },
              ),
              MenuButton(
                imagePath: 'assets/conductores.png',
                label: 'Conductores',
                imageSizeMultiplier: 1.10,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Conductor()),
                  );
                },
              ),
              // Nuevo botón "Red del Metro"
              MenuButton(
                imagePath: 'assets/Red.png',
                label: 'Red del Metro',
                imageSizeMultiplier: 0.95,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapaRed()), // Redirige a MapaRed
                  );
                },
              ),
              MenuButton(
                imagePath: 'assets/cerrarsesion.png',
                label: 'Salir',
                imageSizeMultiplier: 0.85,
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: Material(
                            type: MaterialType.transparency,
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Confirmar Salida',
                                    style: GoogleFonts.roboto(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '¿Estás seguro de que deseas salir de la aplicación?',
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[300],
                                          shadowColor: Colors.grey,
                                          elevation: 5,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                          'Cancelar',
                                          style: GoogleFonts.roboto(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          shadowColor: Colors.orange,
                                          elevation: 5,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                          'Salir',
                                          style: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onPressed: () {
                                          SystemNavigator.pop();
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
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
          Center(
            child: Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
