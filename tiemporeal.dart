import 'dart:typed_data';
import 'dart:math'; // Importar para cálculos matemáticos
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'stations.dart'; // Importar el archivo con las listas de estaciones

class MapaPage extends StatefulWidget {
  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  BitmapDescriptor? _customIcon;
  BitmapDescriptor? _userIcon;

  LatLng? _previousPosition; // Para almacenar la ubicación previa
  double _carRotation = 0.0; // Variable para almacenar la rotación del carrito

  final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(19.432608, -99.133209), // Coordenadas de CDMX por defecto
    zoom: 12,
  );

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _getCurrentLocation();
    _setCustomMarkerIcon();
    _setUserMarkerIcon();
  }

  // Función para cargar el estilo del mapa desde el archivo JSON
  void _loadMapStyle() async {
    String style = await rootBundle.loadString('assets/map_styles.json');
    _mapController?.setMapStyle(style);
  }

  // Función para cargar el ícono personalizado desde los assets para las estaciones
  void _setCustomMarkerIcon() async {
    _customIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      'assets/estacionp.png',
    );
  }

  // Función para cargar el ícono personalizado del carrito 3D y redimensionarlo
  Future<void> _setUserMarkerIcon() async {
    ByteData byteData = await rootBundle.load('assets/carrouber.png');
    Uint8List resizedIcon = await _resizeImage(byteData, 72);

    _userIcon = BitmapDescriptor.fromBytes(resizedIcon);
  }

  // Función para redimensionar la imagen del ícono del carrito
  Future<Uint8List> _resizeImage(ByteData data, int width) async {
    Uint8List bytes = data.buffer.asUint8List();
    img.Image image = img.decodeImage(bytes)!;
    img.Image resizedImage = img.copyResize(image, width: width);
    return Uint8List.fromList(img.encodePng(resizedImage));
  }

  // Función para obtener la ubicación actual del usuario
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

    // Si hay una posición previa, calcular el bearing
    if (_previousPosition != null) {
      _carRotation = calculateBearing(_previousPosition!, currentLatLng);
    }

    setState(() {
      _previousPosition = currentLatLng; // Actualizar la posición previa
      _currentPosition = position;

      _markers
          .removeWhere((marker) => marker.markerId.value == 'currentLocation');

      _markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: currentLatLng,
          anchor: Offset(0.5, 0.5),
          rotation: _carRotation, // Aplicar la rotación calculada
          infoWindow: InfoWindow(title: 'Mi ubicación'),
          icon: _userIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15,
          ),
        ),
      );
    });
  }

  // Calcular el bearing entre dos ubicaciones
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
    return (bearing + 360) %
        360; // Asegurarse de que el ángulo esté entre 0 y 360 grados
  }

  double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  double radiansToDegrees(double radians) {
    return radians * 180 / pi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa del Metro CDMX'),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildLineButton('assets/linea1.png', line1Stations,
                    const Color.fromARGB(255, 239, 77, 152)),
                _buildLineButton('assets/linea2.png', line2Stations,
                    const Color.fromARGB(255, 0, 94, 184)),
                _buildLineButton('assets/linea3.png', line3Stations,
                    const Color.fromARGB(255, 175, 152, 0)),
                _buildLineButton('assets/linea4.png', line4Stations,
                    const Color.fromARGB(255, 107, 187, 174)),
                _buildLineButton('assets/linea5.png', line5Stations,
                    const Color.fromARGB(255, 254, 209, 0)),
                _buildLineButton('assets/linea6.png', line6Stations,
                    const Color.fromARGB(255, 218, 36, 22)),
                _buildLineButton('assets/linea7.png', line7Stations,
                    const Color.fromARGB(255, 232, 120, 28)),
                _buildLineButton('assets/linea8.png', line8Stations,
                    const Color.fromARGB(255, 0, 154, 66)),
                _buildLineButton('assets/linea9.png', line9Stations,
                    const Color.fromARGB(255, 80, 43, 42)),
                _buildLineButton('assets/lineaa.png', lineAStations,
                    const Color.fromARGB(255, 152, 23, 151)),
                _buildLineButton('assets/lineab.png', lineBStations,
                    const Color.fromARGB(255, 177, 179, 179)),
                _buildLineButton('assets/linea12.png', line12Stations,
                    const Color.fromARGB(255, 176, 163, 37)),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled:
                  false, // Deshabilitar el punto azul predeterminado
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _loadMapStyle();
              },
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

  Widget _buildLineButton(String imagePath,
      List<MapEntry<String, LatLng>> stations, Color lineColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      width: 50,
      height: 50,
      child: IconButton(
        icon: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
        onPressed: () {
          if (_customIcon != null) {
            _addMarkers(stations, lineColor);
            _drawPolyline(stations, lineColor);
          } else {
            print("Íconos de estaciones aún no están cargados");
          }
        },
      ),
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
            infoWindow: InfoWindow(
              title: station.key,
              snippet: "Estación de la línea",
            ),
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

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}