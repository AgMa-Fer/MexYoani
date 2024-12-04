import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';

class EstadoServicio extends StatefulWidget {
  @override
  _EstadoServicioState createState() => _EstadoServicioState();
}

class _EstadoServicioState extends State<EstadoServicio>
    with SingleTickerProviderStateMixin {
  String lineaSeleccionada = 'Todas';
  final List<Map<String, dynamic>> lineas = [
    {'nombre': 'Todas', 'color': Colors.black},
    {'nombre': 'Línea 1', 'color': Color.fromARGB(255, 255, 0, 128)},
    {'nombre': 'Línea 2', 'color': Color.fromARGB(255, 9, 100, 164)},
    {'nombre': 'Línea 3', 'color': Color.fromARGB(255, 132, 186, 14)},
    {'nombre': 'Línea 4', 'color': Color.fromARGB(255, 0, 204, 204)},
    {'nombre': 'Línea 5', 'color': Color.fromARGB(255, 255, 204, 0)},
    {'nombre': 'Línea 6', 'color': Color.fromARGB(255, 255, 0, 0)},
    {'nombre': 'Línea 7', 'color': Color.fromARGB(255, 255, 102, 0)},
    {'nombre': 'Línea 8', 'color': Color.fromARGB(255, 0, 153, 102)},
    {'nombre': 'Línea 9', 'color': Color.fromARGB(255, 102, 51, 0)},
    {'nombre': 'Línea 12', 'color': Color.fromARGB(255, 204, 153, 0)},
    {'nombre': 'Línea A', 'color': Color.fromARGB(255, 102, 0, 153)},
    {'nombre': 'Línea B', 'color': Color.fromARGB(255, 153, 153, 153)},
  ];

  OverlayEntry? _overlayEntry;
  late AnimationController _controller;
  late Animation<double> _animation;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _audioPlayer = AudioPlayer();

    // Escucha los cambios en Firestore para reproducir el sonido
    _listenForNewNoticias();
  }

  void _listenForNewNoticias() {
    FirebaseFirestore.instance.collection('Noticias').snapshots().listen(
      (snapshot) async {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            // Reproduce el sonido al agregar una noticia
            try {
              await _audioPlayer.setAsset('assets/sounds/metro_sound.mp3');
              await _audioPlayer.play();
            } catch (e) {
              print('Error al reproducir sonido: $e');
            }
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void toggleMenu() {
    if (_overlayEntry == null) {
      _controller.forward();
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _controller.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        right: 20,
        bottom: 80,
        child: Material(
          color: Colors.transparent,
          child: ScaleTransition(
            scale: _animation,
            child: Container(
              width: 150,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: lineas.map((linea) {
                    return ListTile(
                      leading: Icon(Icons.train, color: linea['color']),
                      title: Text(
                        linea['nombre'],
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        filtrarNoticiasPorLinea(linea['nombre']);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void filtrarNoticiasPorLinea(String linea) {
    setState(() {
      lineaSeleccionada = linea;
    });
    toggleMenu(); // Cierra el menú después de seleccionar una línea
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Noticias y Avisos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepOrange, Colors.orangeAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Noticias').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay noticias disponibles',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final noticiasDocs = snapshot.data!.docs.where((doc) {
                    final lineas = doc['Linea del Metro'] as String? ?? '';
                    return lineaSeleccionada == 'Todas' || lineas.contains(lineaSeleccionada);
                  }).toList();

                  return ListView.builder(
                    itemCount: noticiasDocs.length,
                    itemBuilder: (context, index) {
                      var noticia = noticiasDocs[index];
                      String tipoNoticia = noticia['Tipo de Noticia'];

                      Color colorFondo;
                      IconData iconoNoticia;
                      Color colorIcono;

                      switch (tipoNoticia) {
                        case 'Rojo':
                          colorFondo = Colors.red.shade100;
                          iconoNoticia = Icons.warning_rounded;
                          colorIcono = Colors.red;
                          break;
                        case 'Amarillo':
                          colorFondo = Colors.yellow.shade100;
                          iconoNoticia = Icons.info_rounded;
                          colorIcono = Colors.orangeAccent;
                          break;
                        case 'Verde':
                        default:
                          colorFondo = Colors.green.shade100;
                          iconoNoticia = Icons.check_circle_rounded;
                          colorIcono = Colors.green;
                          break;
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          color: colorFondo,
                          shadowColor: Colors.black54,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(iconoNoticia, color: colorIcono, size: 28),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        noticia['Titulo'],
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: colorIcono,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  noticia['Descripcion'],
                                  style: TextStyle(fontSize: 16, color: Colors.black54),
                                ),
                                Divider(
                                  color: colorIcono.withOpacity(0.5),
                                  thickness: 1.5,
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.access_time, color: colorIcono, size: 20),
                                        SizedBox(width: 5),
                                        Text(
                                          'Hora: ${noticia['Hora de la Noticia']}',
                                          style: TextStyle(color: Colors.black45, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.train, color: colorIcono, size: 20),
                                        SizedBox(width: 5),
                                        Text(
                                          '${noticia['Linea del Metro']}',
                                          style: TextStyle(color: Colors.black45, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: Icon(Icons.train, color: Colors.black),
        onPressed: toggleMenu,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

void main() => runApp(MaterialApp(
      home: EstadoServicio(),
      theme: ThemeData(
        fontFamily: 'Arial',
      ),
    ));
