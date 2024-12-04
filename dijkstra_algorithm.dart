import 'dart:collection';
import 'package:collection/collection.dart';

// Definimos la clase para las conexiones entre estaciones (nodos) con la línea
class Estacion {
  final String nombre;
  final String linea; // Línea en la que se encuentra la estación
  final Map<Estacion, double> conexiones; // Vecinos con su respectiva distancia

  Estacion(this.nombre, this.linea) : conexiones = {};

  @override
  String toString() => '$nombre (Línea $linea)';
}

// Función para agregar conexiones entre estaciones con penalización por cambio de línea
void conectarEstaciones(Estacion a, Estacion b, double distancia) {
  double penalizacion =
      a.linea != b.linea ? 5.0 : 0.0; // Penalización por cambio de línea
  a.conexiones[b] = distancia + penalizacion;
  b.conexiones[a] = distancia + penalizacion;
}

// Implementación de la búsqueda de la ruta más corta
List<String> encontrarRutaMasCorta(Estacion inicio, Estacion destino) {
  // Cola de prioridad para explorar las estaciones en orden de distancia
  PriorityQueue<List<dynamic>> cola =
      PriorityQueue((a, b) => a[1].compareTo(b[1]));
  Map<Estacion, double> distancias = {};
  Map<Estacion, Estacion?> anteriores = {};
  List<String> ruta = [];

  // Inicializar las distancias con infinito y la estación inicial con distancia 0
  distancias[inicio] = 0;
  cola.add([inicio, 0.0]);

  // Mientras haya estaciones por explorar
  while (cola.isNotEmpty) {
    final List<dynamic> actual = cola.removeFirst();
    final Estacion estacionActual = actual[0];
    final double distanciaActual = actual[1];

    // Si llegamos al destino, reconstruir la ruta
    if (estacionActual == destino) {
      Estacion? temp = destino;
      while (temp != null) {
        ruta.insert(0, temp.nombre); // Insertar al principio de la lista
        temp = anteriores[temp];
      }
      break;
    }

    // Explorar las conexiones de la estación actual
    for (final vecino in estacionActual.conexiones.entries) {
      final Estacion estacionVecina = vecino.key;
      final double distanciaVecina = vecino.value;
      final double nuevaDistancia = distanciaActual + distanciaVecina;

      // Si encontramos una ruta más corta
      if (nuevaDistancia < (distancias[estacionVecina] ?? double.infinity)) {
        distancias[estacionVecina] = nuevaDistancia;
        anteriores[estacionVecina] = estacionActual;
        cola.add([estacionVecina, nuevaDistancia]);
      }
    }
  }

  return ruta;
}

// Función para obtener la ruta más corta entre dos estaciones seleccionadas
List<String> obtenerRuta(
    String estacion1, String estacion2, Map<String, Estacion> estaciones) {
  final Estacion? inicio = estaciones[estacion1];
  final Estacion? destino = estaciones[estacion2];

  if (inicio != null && destino != null) {
    return encontrarRutaMasCorta(inicio, destino);
  } else {
    return [];
  }
}