import 'dart:async';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'stations.dart'; // Importar las estaciones
import 'lineas.dart'; // Importar las coordenadas de las líneas
import 'package:prueba/main.dart';

class MapaPage extends StatefulWidget {
  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  BitmapDescriptor? _stationIcon;
  BitmapDescriptor? _driverIcon;
  BitmapDescriptor? _userIcon;
  Timer? _locationTimer;
  Timer? _lineUpdateTimer;

  LatLng? _previousPosition;
  double _carRotation = 0.0;
  String _coordinatesText = "";

  final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(19.432608, -99.133209),
    zoom: 12,
  );

  final Set<Marker> _stationMarkers = {}; // Marcadores de estaciones
  final Set<Marker> _driverMarkers = {}; // Marcadores de conductores
  final Set<Polyline> _polylines = {};

  String? _selectedLineName;
  String? _selectedLineImagePath;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _getCurrentLocation();
    _setStationMarkerIcon();
    _setDriverMarkerIcon();
    _setUserMarkerIcon();

    // Iniciar el timer para actualizar la ubicación cada 2 segundos
    _locationTimer = Timer.periodic(
        Duration(seconds: 2), (Timer t) => _getCurrentLocation());
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _locationTimer?.cancel();
    _lineUpdateTimer?.cancel();
    super.dispose();
  }

  void _loadMapStyle() async {
    String style = await rootBundle.loadString('assets/map_styles.json');
    _mapController?.setMapStyle(style);
  }

  void _setStationMarkerIcon() async {
    _stationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(50, 50)),
      'assets/estacionp.png',
    );
  }

  Future<void> _setDriverMarkerIcon() async {
    ByteData byteData = await rootBundle.load('assets/carrouber.png');
    Uint8List resizedIcon = await _resizeImage(byteData, 200);

    _driverIcon = BitmapDescriptor.fromBytes(resizedIcon);
  }

  Future<void> _setUserMarkerIcon() async {
    ByteData byteData = await rootBundle.load('assets/1Usuario.png');
    Uint8List resizedIcon = await _resizeImage(byteData, 80);

    _userIcon = BitmapDescriptor.fromBytes(resizedIcon);
  }

  Future<Uint8List> _resizeImage(ByteData data, int width) async {
    Uint8List bytes = data.buffer.asUint8List();
    img.Image image = img.decodeImage(bytes)!;
    img.Image resizedImage = img.copyResize(image, width: width);
    return Uint8List.fromList(img.encodePng(resizedImage));
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Los servicios de ubicación están deshabilitados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Los permisos de ubicación fueron denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Los permisos de ubicación están denegados permanentemente.');
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

      // Limpiar solo los marcadores de conductores
      _driverMarkers.clear();

      _driverMarkers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: currentLatLng,
          anchor: Offset(0.5, 0.5),
          rotation: _carRotation,
          infoWindow: InfoWindow(title: 'Mi ubicación'),
          icon: _userIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
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

  double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  double radiansToDegrees(double radians) {
    return radians * 180 / pi;
  }

  Future<void> _fetchDriverCoordinates(String lineName) async {
    if (_selectedLineName == null) return;

    print("Iniciando la obtención de coordenadas para la línea: $lineName");
    final DocumentSnapshot document = await FirebaseFirestore.instance
        .collection('coordenadas')
        .doc(lineName)
        .get();

    if (document.exists) {
      print("Documento de la línea '$lineName' encontrado en Firestore.");
      String coordinatesText = "";

      final data = document.data() as Map<String, dynamic>?;
      if (data != null) {
        setState(() {
          _driverMarkers.clear();

          data.forEach((key, value) {
            final coordString = value as String;
            final coord = coordString.split(',');
            final lat = double.parse(coord[0]);
            final lng = double.parse(coord[1]);

            coordinatesText += "Lat: $lat, Lng: $lng\n";
            print("Coordenada obtenida: Lat: $lat, Lng: $lng");

            _driverMarkers.add(
              Marker(
                markerId: MarkerId(key),
                position: LatLng(lat, lng),
                icon: _driverIcon ?? BitmapDescriptor.defaultMarker,
                infoWindow: InfoWindow(title: key),
              ),
            );
          });

          _coordinatesText = coordinatesText;
          print("Texto de coordenadas actualizado:\n$_coordinatesText");
        });
      }
    } else {
      print("El documento de la línea '$lineName' no existe en Firestore.");
    }
  }

  void _addStationMarkers(List<MapEntry<String, LatLng>> stations) {
    setState(() {
      _stationMarkers.clear(); // Limpiar los marcadores de estaciones previos
      _stationMarkers.addAll(
        stations.map((station) {
          return Marker(
            markerId: MarkerId(station.key),
            position: station.value,
            anchor: Offset(0.5, 0.5),
            infoWindow: InfoWindow(
              title: station.key,
              snippet: "Estación de la línea",
            ),
            icon: _stationIcon ?? BitmapDescriptor.defaultMarker,
          );
        }).toSet(),
      );
    });
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
              '¿Quieres regresar al menú principal?',
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'No',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()),
                  );
                },
                child: Text(
                  'Sí',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
        backgroundColor: Colors.orange,
        title: Center(
          child: Text(
            'Metro CDMX',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange),
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
                  if (_selectedLineImagePath != null &&
                      _selectedLineName != null)
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            _selectedLineImagePath!,
                            width: 40,
                            height: 40,
                          ),
                          SizedBox(width: 10),
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
            _buildLineButton('assets/linea1.png', 'Línea 1', line1Stations,
                line1Route, const Color.fromARGB(255, 239, 77, 152)),
            _buildLineButton('assets/linea2.png', 'Línea 2', line2Stations,
                line2Route, const Color.fromARGB(255, 0, 94, 184)),
            _buildLineButton('assets/linea3.png', 'Línea 3', line3Stations,
                line3Route, const Color.fromARGB(255, 175, 152, 0)),
            _buildLineButton('assets/linea4.png', 'Línea 4', line4Stations,
                line4Route, const Color.fromARGB(255, 107, 187, 174)),
            _buildLineButton('assets/linea5.png', 'Línea 5', line5Stations,
                line5Route, const Color.fromARGB(255, 254, 209, 0)),
            _buildLineButton('assets/linea6.png', 'Línea 6', line6Stations,
                line6Route, const Color.fromARGB(255, 218, 36, 22)),
            _buildLineButton('assets/linea7.png', 'Línea 7', line7Stations,
                line7Route, const Color.fromARGB(255, 232, 120, 28)),
            _buildLineButton('assets/linea8.png', 'Línea 8', line8Stations,
                line8Route, const Color.fromARGB(255, 0, 154, 66)),
            _buildLineButton('assets/linea9.png', 'Línea 9', line9Stations,
                line9Route, const Color.fromARGB(255, 80, 43, 42)),
            _buildLineButton('assets/lineaa.png', 'Línea A', lineAStations,
                lineARoute, const Color.fromARGB(255, 152, 23, 151)),
            _buildLineButton('assets/lineab.png', 'Línea B', lineBStations,
                lineBRoute, const Color.fromARGB(255, 177, 179, 179)),
            _buildLineButton('assets/linea12.png', 'Línea 12', line12Stations,
                line12Route, const Color.fromARGB(255, 176, 163, 37)),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: {..._stationMarkers, ..._driverMarkers},
            polylines: _polylines,
            myLocationEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _loadMapStyle();
            },
          ),
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _coordinatesText.split('\n').map((coord) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons
                                .train, // Ícono de tren, puedes cambiar a otro ícono
                            color: Colors.blueAccent, // Color del ícono
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              coord,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontFamily: 'Courier', // Fuente monoespaciada
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildLineButton(
      String imagePath,
      String lineName,
      List<MapEntry<String, LatLng>> stations,
      List<LatLng> routeCoordinates,
      Color lineColor) {
    return ListTile(
      leading: Image.asset(imagePath, width: 40, height: 40),
      title: Text(
        lineName,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _selectedLineName = lineName;
          _selectedLineImagePath = imagePath;
          _addStationMarkers(stations);
          _drawPolyline(routeCoordinates, lineColor);
          _zoomToFitLine(routeCoordinates);

          _lineUpdateTimer?.cancel();
          _lineUpdateTimer = Timer.periodic(
            Duration(seconds: 2),
            (Timer t) => _fetchDriverCoordinates(lineName),
          );
        });
      },
    );
  }

  void _drawPolyline(List<LatLng> routeCoordinates, Color lineColor) {
    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: PolylineId("border_polyline_${routeCoordinates[0]}"),
          points: routeCoordinates,
          color: Colors.black,
          width: 7,
        ),
      );
      _polylines.add(
        Polyline(
          polylineId: PolylineId("polyline_${routeCoordinates[0]}"),
          points: routeCoordinates,
          color: lineColor,
          width: 5,
        ),
      );
    });
  }

  void _zoomToFitLine(List<LatLng> routeCoordinates) {
    LatLngBounds bounds = _calculateLatLngBounds(routeCoordinates);
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  LatLngBounds _calculateLatLngBounds(List<LatLng> positions) {
    double southWestLat = positions.map((p) => p.latitude).reduce(min);
    double southWestLng = positions.map((p) => p.longitude).reduce(min);
    double northEastLat = positions.map((p) => p.latitude).reduce(max);
    double northEastLng = positions.map((p) => p.longitude).reduce(max);

    return LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );
  }
}
