import 'dart:async';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:background_location/background_location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'stations.dart';
import 'lineas.dart';
import 'login_page.dart';
import 'mainconductor.dart';

class MapaPage2 extends StatefulWidget {
  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage2> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GoogleMapController? _mapController;
  Position? _currentPosition;
  BitmapDescriptor? _customIcon;
  BitmapDescriptor? _userIcon;
  LatLng? _previousPosition;
  double _carRotation = 0.0;
  final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(19.432608, -99.133209), // Coordenadas de CDMX
    zoom: 12,
  );
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  String? _userUID;
  String? _selectedLineName;
  String? _selectedLineLogo;
  Color? _selectedLineColor;
  List<String> _previousLines =
      []; // Almacena las dos últimas líneas seleccionadas
  Timer? _locationUpdateTimer; // Temporizador para actualizar la ubicación

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Agrega el observer
    _loadMapStyle();
    _initializeBackgroundLocation();
    _setCustomMarkerIcon();
    _setUserMarkerIcon();
    _loadUserUID();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (_userUID != null && _selectedLineName != null) {
        FirebaseFirestore.instance
            .collection('coordenadas')
            .doc(_selectedLineName)
            .update({
          _userUID!: FieldValue.delete(),
        }).then((_) {
          print('Campo "$_userUID" eliminado al cerrar la app');
        }).catchError((error) {
          print('Error al eliminar el campo "$_userUID": $error');
        });
      }
    }
  }

  Future<void> _initializeBackgroundLocation() async {
    await BackgroundLocation.setAndroidNotification(
      title: 'Ubicación en segundo plano',
      message: 'La aplicación sigue actualizando tu ubicación',
      icon: '@mipmap/ic_launcher',
    );

    BackgroundLocation.startLocationService(distanceFilter: 0);

    _locationUpdateTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      String? userUID = await obtenerUID();
      if (userUID != null && _selectedLineName != null) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        await FirebaseFirestore.instance
            .collection('coordenadas')
            .doc(_selectedLineName)
            .update({
          userUID: '${position.latitude},${position.longitude}',
        });
        print('Ubicación actualizada en Firestore cada 3 segundos');

        LatLng newLatLng = LatLng(position.latitude, position.longitude);
        if (_previousPosition != null) {
          _carRotation = calculateBearing(_previousPosition!, newLatLng);
        }
        setState(() {
          _previousPosition = newLatLng;
          _updateUserMarker(newLatLng);
        });
      }
    });
  }

  void _updateUserMarker(LatLng position) {
    _markers
        .removeWhere((marker) => marker.markerId.value == 'currentLocation');
    _markers.add(Marker(
      markerId: MarkerId('currentLocation'),
      position: position,
      anchor: Offset(0.5, 0.5),
      rotation: _carRotation,
      infoWindow: InfoWindow(title: 'Mi ubicación'),
      icon: _userIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ));
  }

  Future<void> _loadUserUID() async {
    _userUID = await obtenerUID();
    print('UID del usuario: $_userUID');
  }

  void _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled)
      return Future.error('Servicios de ubicación deshabilitados.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied)
        return Future.error('Permisos de ubicación denegados.');
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Permisos de ubicación denegados permanentemente.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    if (_previousPosition != null) {
      _carRotation = calculateBearing(_previousPosition!, currentLatLng);
    }

    setState(() {
      _previousPosition = currentLatLng;
      _currentPosition = position;
      _updateUserMarker(currentLatLng);
    });

    if (_userUID != null && _selectedLineName != null) {
      await FirebaseFirestore.instance
          .collection('coordenadas')
          .doc(_selectedLineName)
          .update({
        _userUID!: '${position.latitude},${position.longitude}',
      });
      print('Coordenadas actualizadas en Firestore');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remueve el observer
    _mapController?.dispose();
    _locationUpdateTimer?.cancel(); // Cancela el temporizador al salir
    BackgroundLocation.stopLocationService();
    if (_userUID != null && _selectedLineName != null) {
      FirebaseFirestore.instance
          .collection('coordenadas')
          .doc(_selectedLineName)
          .update({
        _userUID!: FieldValue.delete(),
      }).then((_) {
        print(
            'Campo "$_userUID" eliminado en Firestore al salir de la actividad');
      }).catchError((error) {
        print('Error al eliminar el campo "$_userUID": $error');
      });
    }
    super.dispose();
  }

  void _loadMapStyle() async {
    String style = await rootBundle.loadString('assets/map_styles.json');
    _mapController?.setMapStyle(style);
  }

  void _setCustomMarkerIcon() async {
    _customIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      'assets/estacionp.png',
    );
  }

  Future<void> _setUserMarkerIcon() async {
    ByteData byteData = await rootBundle.load('assets/carrouber.png');
    Uint8List resizedIcon = await _resizeImage(byteData, 200);
    _userIcon = BitmapDescriptor.fromBytes(resizedIcon);
  }

  Future<Uint8List> _resizeImage(ByteData data, int width) async {
    Uint8List bytes = data.buffer.asUint8List();
    img.Image image = img.decodeImage(bytes)!;
    img.Image resizedImage = img.copyResize(image, width: width);
    return Uint8List.fromList(img.encodePng(resizedImage));
  }

  double calculateBearing(LatLng start, LatLng end) {
    double startLat = degreesToRadians(start.latitude);
    double startLng = degreesToRadians(start.longitude);
    double endLat = degreesToRadians(end.latitude);
    double endLng = degreesToRadians(end.longitude);

    double dLng = endLng - startLng;
    double y = sin(dLng) * cos(endLat);
    double x =
        cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(dLng);

    double bearing = radiansToDegrees(atan2(y, x));
    return (bearing + 360) % 360;
  }

  double degreesToRadians(double degrees) => degrees * pi / 180;
  double radiansToDegrees(double radians) => radians * 180 / pi;

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
              '¿Quieres regresar al menú principal del conductor?',
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
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
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
                    MaterialPageRoute(builder: (context) => MenuPrincipal()),
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
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
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
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.indigo[700],
        title: Center(
          child: Text(
            'Conductor del Metro de CDMX',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo[700]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      'Selecciona la Línea del Metro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (_selectedLineName != null)
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(_selectedLineLogo!,
                              width: 24, height: 24),
                          SizedBox(width: 8),
                          Text(
                            _selectedLineName!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            _buildLineButton('assets/linea1.png', line1Stations,
                const Color.fromARGB(255, 239, 77, 152), "Línea 1"),
            _buildLineButton('assets/linea2.png', line2Stations,
                const Color.fromARGB(255, 0, 94, 184), "Línea 2"),
            _buildLineButton('assets/linea3.png', line3Stations,
                const Color.fromARGB(255, 175, 152, 0), "Línea 3"),
            _buildLineButton('assets/linea4.png', line4Stations,
                const Color.fromARGB(255, 107, 187, 174), "Línea 4"),
            _buildLineButton('assets/linea5.png', line5Stations,
                const Color.fromARGB(255, 254, 209, 0), "Línea 5"),
            _buildLineButton('assets/linea6.png', line6Stations,
                const Color.fromARGB(255, 218, 36, 22), "Línea 6"),
            _buildLineButton('assets/linea7.png', line7Stations,
                const Color.fromARGB(255, 232, 120, 28), "Línea 7"),
            _buildLineButton('assets/linea8.png', line8Stations,
                const Color.fromARGB(255, 0, 154, 66), "Línea 8"),
            _buildLineButton('assets/linea9.png', line9Stations,
                const Color.fromARGB(255, 80, 43, 42), "Línea 9"),
            _buildLineButton('assets/lineaa.png', lineAStations,
                const Color.fromARGB(255, 152, 23, 151), "Línea A"),
            _buildLineButton('assets/lineab.png', lineBStations,
                const Color.fromARGB(255, 177, 179, 179), "Línea B"),
            _buildLineButton('assets/linea12.png', line12Stations,
                const Color.fromARGB(255, 176, 163, 37), "Línea 12"),
          ],
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          _loadMapStyle();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildLineButton(
      String imagePath,
      List<MapEntry<String, LatLng>> stations,
      Color lineColor,
      String lineName) {
    return ListTile(
      leading: Image.asset(imagePath, width: 30, height: 30),
      title: Text(lineName,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      onTap: () async {
        if (_customIcon != null) {
          for (String line in _previousLines) {
            await FirebaseFirestore.instance
                .collection('coordenadas')
                .doc(line)
                .update({
              _userUID!: FieldValue.delete(),
            });
            print('UID eliminado de la línea: $line');
          }

          _previousLines.add(lineName);
          if (_previousLines.length > 2) {
            _previousLines.removeAt(0);
          }

          setState(() {
            _selectedLineName = lineName;
            _selectedLineLogo = imagePath;
            _selectedLineColor = lineColor;
          });

          _addMarkers(stations, lineColor);
          _drawPolyline(stations, lineColor);

          if (_userUID != null) {
            Position position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high);
            await FirebaseFirestore.instance
                .collection('coordenadas')
                .doc(lineName)
                .update({
              _userUID!: '${position.latitude},${position.longitude}',
            });

            print(
                'Ubicación actualizada en Firestore en la nueva línea: $lineName');
          } else {
            print("UID del usuario no disponible.");
          }
        } else {
          print("Íconos de estaciones aún no están cargados");
        }
        Navigator.of(context).pop();
      },
    );
  }

  void _addMarkers(List<MapEntry<String, LatLng>> stations, Color lineColor) {
    setState(() {
      _markers.clear();
      _markers.addAll(
        stations.map((station) {
          return Marker(
            markerId: MarkerId(station.key),
            position: station.value,
            anchor: Offset(0.5, 0.5),
            infoWindow:
                InfoWindow(title: station.key, snippet: "Estación de la línea"),
            icon: _customIcon ?? BitmapDescriptor.defaultMarker,
          );
        }).toSet(),
      );
    });
  }

  void _drawPolyline(List<MapEntry<String, LatLng>> stations, Color lineColor) {
    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: PolylineId("border_polyline_${stations[0].key}"),
          points: stations.map((station) => station.value).toList(),
          color: Colors.black,
          width: 7,
        ),
      );
      _polylines.add(
        Polyline(
          polylineId: PolylineId("polyline_${stations[0].key}"),
          points: stations.map((station) => station.value).toList(),
          color: lineColor,
          width: 5,
        ),
      );
    });
  }
}
