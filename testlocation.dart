import 'package:flutter/material.dart';
import 'package:background_location/background_location.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocationUpdaterPage extends StatefulWidget {
  @override
  _LocationUpdaterPageState createState() => _LocationUpdaterPageState();
}

class _LocationUpdaterPageState extends State<LocationUpdaterPage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String _locationMessage = "Esperando ubicación...";

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _startBackgroundLocation();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'location_channel',
      'Ubicación',
      channelDescription: 'Notificaciones de actualización de ubicación',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Actualización de Ubicación',
      message,
      platformChannelSpecifics,
    );
  }

  void _startBackgroundLocation() async {
    await BackgroundLocation.setAndroidNotification(
      title: 'Actualización de Ubicación',
      message: 'Ubicación activa en segundo plano',
      icon: '@mipmap/ic_launcher',
    );

    // Configura la frecuencia de actualización (cada 3 segundos)
    BackgroundLocation.startLocationService(distanceFilter: 0);
    BackgroundLocation.getLocationUpdates((location) {
      String message = 'Lat: ${location.latitude}, Lng: ${location.longitude}';
      setState(() {
        _locationMessage = message;
      });
      print('Ubicación actualizada: $message');
      _showNotification(message);
    });
  }

  @override
  void dispose() {
    BackgroundLocation.stopLocationService();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actualización de Ubicación'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ubicación actual:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              _locationMessage,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
