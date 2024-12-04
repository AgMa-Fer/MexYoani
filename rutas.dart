import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dijkstra_algorithm.dart';
import 'buscadorlista.dart';
import 'package:prueba/main.dart';
import 'stations.dart';

//Buscador
class BuscadorLista extends StatefulWidget {
  final List<MapEntry<String, LatLng>> estaciones;
  final Function(LatLng, String) onEstacionSeleccionada;

  BuscadorLista({
    required this.estaciones,
    required this.onEstacionSeleccionada,
  });

  @override
  _BuscadorListaState createState() => _BuscadorListaState();
}

class _BuscadorListaState extends State<BuscadorLista> {
  String filtro = ''; // Filtro para las estaciones

  @override
  Widget build(BuildContext context) {
    // Filtrar las estaciones en base al texto ingresado
    List<MapEntry<String, LatLng>> estacionesFiltradas = widget.estaciones
        .where((estacion) =>
            estacion.key.toLowerCase().contains(filtro.toLowerCase()))
        .toList();

    return Column(
      children: [
        // Cuadro de búsqueda
        TextField(
          decoration: InputDecoration(
            prefixIcon:
                Icon(Icons.search, color: Colors.black), // Icono de búsqueda
            hintText: 'Buscar estación...',
            hintStyle:
                TextStyle(color: Colors.black54), // Color del texto de ayuda
            filled: true,
            fillColor:
                Colors.white.withOpacity(0.5), // Fondo ligeramente visible
            contentPadding: EdgeInsets.symmetric(
                vertical: 15), // Ajuste del alto del TextField
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0), // Bordes redondeados
              borderSide: BorderSide(
                color: Colors.transparent, // Borde invisible
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  30.0), // Bordes redondeados al hacer clic
              borderSide: BorderSide(
                color: Colors.transparent, // Borde invisible al hacer clic
              ),
            ),
          ),
          style: TextStyle(color: Colors.black), // Color del texto negro
          onChanged: (value) {
            setState(() {
              filtro =
                  value; // Actualiza el filtro cada vez que cambia el texto
            });
          },
        ),
        // Lista de estaciones filtradas
        Expanded(
          child: ListView.builder(
            shrinkWrap:
                true, // Permite que el ListView se ajuste dentro de un Expanded
            itemCount: estacionesFiltradas.length,
            itemBuilder: (context, index) {
              final estacion = estacionesFiltradas[index];
              return ListTile(
                title: Text(estacion.key),
                onTap: () {
                  // Llama a la función cuando una estación es seleccionada
                  widget.onEstacionSeleccionada(estacion.value, estacion.key);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

//Fin Buscador

class RutasPage extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<RutasPage> {
  late GoogleMapController mapController;
  static const LatLng _center = LatLng(19.41591757608901, -99.13539091858357);
  String _mapStyle = '';
  BitmapDescriptor? customIcon;
  double currentZoom = 12.0;
  final double _maxZoom = 16.0; // Límite máximo de zoom
  final double _minZoom = 11.0; // Límite mínimo de zoom
  String? _informacionMarcador; // Variable para almacenar la info del marcador

  // Variables para seleccionar dos estaciones
  bool seleccionandoEstaciones = false;
  String? estacionSeleccionada1;
  String? estacionSeleccionada2;
  List<String> ruta = [];

  // Definir los límites del área del mapa
  final LatLngBounds _limitesMapa = LatLngBounds(
    southwest: LatLng(19.22798944837666, -99.2391381423812),
    northeast: LatLng(19.553779921289138, -98.98919918226348),
  );

  // Mapa de imágenes de estaciones
  final Map<String, String> imagenesEstaciones = {
    //linea 1
    "Pantitlán": 'assets/pantitlán.png',
    "Zaragoza": 'assets/zaragoza.png',
    "Gómez Farías": 'assets/gómez_farías.png',
    "Boulevard Puerto Aéreo": 'assets/boulevard_puerto_aéreo.png',
    "Balbuena": 'assets/balbuena.png',
    "Moctezuma": 'assets/moctezuma.png',
    "San Lázaro": 'assets/san_lázaro.png',
    "Candelaria": 'assets/candelaria.png',
    "Merced": 'assets/merced.png',
    "Pino Suárez": 'assets/pino_suárez.png',
    "Isabel la Católica": 'assets/isabel_la_católica.png',
    "Salto del Agua": 'assets/salto_del_agua.png',
    "Balderas": 'assets/balderas.png',
    "Cuauhtémoc": 'assets/cuauhtémoc.png',
    "Insurgentes": 'assets/insurgentes.png',
    "Sevilla": 'assets/sevilla.png',
    "Chapultepec": 'assets/chapultepec.png',
    "Juanacatlán": 'assets/juanacatlán.png',
    "Tacubaya": 'assets/tacubaya.png',
    "Observatorio": 'assets/observatorio.png',
    //linea 2
    "Cuatro Caminos": 'assets/cuatro_caminos.png',
    "Panteones": 'assets/panteones.png',
    "Tacuba": 'assets/tacuba.png',
    "Cuitláhuac": 'assets/cuitláhuac.png',
    "Popotla": 'assets/popotla.png',
    "Colegio Militar": 'assets/colegio_militar.png',
    "Normal": 'assets/normal.png',
    "San Cosme": 'assets/san_cosme.png',
    "Revolución": 'assets/revolución.png',
    "Hidalgo": 'assets/hidalgo.png',
    "Bellas Artes": 'assets/bellas_artes.png',
    "Allende": 'assets/allende.png',
    "Zócalo Tenochtitlan": 'assets/zócalo_tenochtitlan.png',
    "San Antonio Abad": 'assets/san_antonio_abad.png',
    "Chabacano": 'assets/chabacano.png',
    "Viaducto": 'assets/viaducto.png',
    "Xola": 'assets/xola.png',
    "Villa de Cortés": 'assets/villa_de_cortés.png',
    "Nativitas": 'assets/nativitas.png',
    "Portales": 'assets/portales.png',
    "Ermita": 'assets/ermita.png',
    "General Anaya": 'assets/general_anaya.png',
    "Tasqueña": 'assets/tasqueña.png',
    //linea 3
    "Indios Verdes": 'assets/indios_verdes.png',
    "Deportivo 18 de Marzo": 'assets/deportivo_18_de_marzo.png',
    "Potrero": 'assets/potrero.png',
    "La Raza": 'assets/la_raza.png',
    "Tlatelolco": 'assets/tlatelolco.png',
    "Guerrero": 'assets/guerrero.png',
    "Juárez": 'assets/juárez.png',
    "Niños Héroes": 'assets/niños_héroes.png',
    "Hospital General": 'assets/hospital_general.png',
    "Centro Médico": 'assets/centro_médico.png',
    "Etiopía": 'assets/etiopía.png',
    "Eugenia": 'assets/eugenia.png',
    "División del Norte": 'assets/división_del_norte.png',
    "Zapata": 'assets/zapata.png',
    "Coyoacán": 'assets/coyoacán.png',
    "Viveros": 'assets/viveros.png',
    "Miguel Ángel de Quevedo": 'assets/miguel_ángel_de_quevedo.png',
    "Copilco": 'assets/copilco.png',
    "Universidad": 'assets/universidad.png',
    //linea 4
    "Martín Carrera": 'assets/martín_carrera.png',
    "Talismán": 'assets/talismán.png',
    "Bondojito": 'assets/bondojito.png',
    "Consulado": 'assets/consulado.png',
    "Canal del Norte": 'assets/canal_del_norte.png',
    "Morelos": 'assets/morelos.png',
    "Fray Servando": 'assets/fray_servando.png',
    "Jamaica": 'assets/jamaica.png',
    "Santa Anita": 'assets/santa_anita.png',
    //linea 5
    "Politécnico": 'assets/politécnico.png',
    "Instituto del Petróleo": 'assets/instituto_del_petróleo.png',
    "Autobuses del Norte": 'assets/autobuses_del_norte.png',
    "Misterios": 'assets/misterios.png',
    "Valle Gómez": 'assets/valle_gómez.png',
    "Eduardo Molina": 'assets/eduardo_molina.png',
    "Aragón": 'assets/aragón.png',
    "Oceanía": 'assets/oceanía.png',
    "Terminal Aérea": 'assets/terminal_aérea.png',
    "Hangares": 'assets/hangares.png',
    //linea 6
    "Rosario": 'assets/rosario.png',
    "Tezozómoc": 'assets/tezozómoc.png',
    "UAM Azcapotzalco": 'assets/uam_azcapotzalco.png',
    "Ferrería": 'assets/ferrería.png',
    "Norte 45": 'assets/norte_45.png',
    "Vallejo": 'assets/vallejo.png',
    "Lindavista": 'assets/lindavista.png',
    "La Villa Basílica": 'assets/la_villa_basílica.png',
    //linea 7
    "Aquiles Serdán": 'assets/aquiles_serdán.png',
    "Camarones": 'assets/camarones.png',
    "Refinería": 'assets/refinería.png',
    "San Joaquín": 'assets/san_joaquín.png',
    "Polanco": 'assets/polanco.png',
    "Auditorio": 'assets/auditorio.png',
    "Constituyentes": 'assets/constituyentes.png',
    "San Pedro de los Pinos": 'assets/san_pedro_de_los_pinos.png',
    "San Antonio": 'assets/san_antonio.png',
    "Mixcoac": 'assets/mixcoac.png',
    "Barranca del Muerto": 'assets/barranca_del_muerto.png',
    //linea 8
    "Constitución de 1917": 'assets/constitución_de_1917.png',
    "UAM-I": 'assets/uam-i.png',
    "Cerro de la Estrella": 'assets/cerro_de_la_estrella.png',
    "Iztapalapa": 'assets/iztapalapa.png',
    "Atlalilco": 'assets/atlalilco.png',
    "Escuadrón 201": 'assets/escuadrón_201.png',
    "Aculco": 'assets/aculco.png',
    "Apatlaco": 'assets/apatlaco.png',
    "Iztacalco": 'assets/iztacalco.png',
    "Coyuya": 'assets/coyuya.png',
    "La Viga": 'assets/la_viga.png',
    "Obrera": 'assets/obrera.png',
    "Doctores": 'assets/doctores.png',
    "San Juan de Letrán": 'assets/san_juan_de_letrán.png',
    "Garibaldi": 'assets/garibaldi.png',
    //linea 9
    "Puebla": 'assets/puebla.png',
    "Ciudad Deportiva": 'assets/ciudad_deportiva.png',
    "Velódromo": 'assets/velódromo.png',
    "Mixiuhca": 'assets/mixiuhca.png',
    "Lázaro Cárdenas": 'assets/lázaro_cárdenas.png',
    "Chilpancingo": 'assets/chilpancingo.png',
    "Patriotismo": 'assets/patriotismo.png',
    //linea A
    "La Paz": 'assets/la_paz.png',
    "Los Reyes": 'assets/los_reyes.png',
    "Santa Marta": 'assets/santa_marta.png',
    "Acatitla": 'assets/acatitla.png',
    "Peñón Viejo": 'assets/peñón_viejo.png',
    "Guelatao": 'assets/guelatao.png',
    "Tepalcates": 'assets/tepalcates.png',
    "Canal de San Juan": 'assets/canal_de_san_juan.png',
    "Agrícola Oriental": 'assets/agrícola_oriental.png',
    //linea B
    "Buenavista": 'assets/buenavista.png',
    "Garibaldi/Lagunilla": 'assets/garibaldi_lagunilla.png',
    "Lagunilla": 'assets/lagunilla.png',
    "Tepito": 'assets/tepito.png',
    "Ricardo Flores Magón": 'assets/ricardo_flores_magón.png',
    "Romero Rubio": 'assets/romero_rubio.png',
    "Deportivo Oceanía": 'assets/deportivo_oceanía.png',
    "Bosque de Aragón": 'assets/bosque_de_aragón.png',
    "Villa de Aragón": 'assets/villa_de_aragón.png',
    "Nezahualcóyotl": 'assets/nezahualcóyotl.png',
    "Río de los Remedios": 'assets/río_de_los_remedios.png',
    "Impulsora": 'assets/impulsora.png',
    "Múzquiz": 'assets/múzquiz.png',
    "Ecatepec": 'assets/ecatepec.png',
    "Olímpica": 'assets/olímpica.png',
    "Plaza Aragón": 'assets/plaza_aragón.png',
    "Ciudad Azteca": 'assets/ciudad_azteca.png',
    //linea 12
    "Tláhuac": 'assets/tláhuac.png',
    "Tlaltenco": 'assets/tlaltenco.png',
    "Zapotitlán": 'assets/zapotitlán.png',
    "Nopalera": 'assets/nopalera.png',
    "Olivos": 'assets/olivos.png',
    "Tezonco": 'assets/tezonco.png',
    "Periférico Oriente": 'assets/periférico_oriente.png',
    "Calle 11": 'assets/calle_11.png',
    "Lomas Estrella": 'assets/lomas_estrella.png',
    "San Andrés Tomatlán": 'assets/san_andrés_tomatlán.png',
    "Culhuacán": 'assets/culhuacán.png',
    "Mexicaltzingo": 'assets/mexicaltzingo.png',
    "Eje Central": 'assets/eje_central.png',
    "Parque de los Venados": 'assets/parque_de_los_venados.png',
    "Hospital 20 de Noviembre": 'assets/hospital_20_de_noviembre.png',
    "Insurgentes Sur": 'assets/insurgentes_sur.png',
  };

  // Definimos las estaciones para dijsktra
// Línea 1
  final pantitlan1 = Estacion('Pantitlán', 'Línea 1');
  final zaragoza = Estacion('Zaragoza', 'Línea 1');
  final gomezFarias = Estacion('Gómez Farías', 'Línea 1');
  final boulevardPuertoAereo = Estacion('Boulevard Puerto Aéreo', 'Línea 1');
  final balbuena = Estacion('Balbuena', 'Línea 1');
  final moctezuma = Estacion('Moctezuma', 'Línea 1');
  final sanLazaro1 = Estacion('San Lázaro', 'Línea 1');
  final candelaria1 = Estacion('Candelaria', 'Línea 1');
  final merced = Estacion('Merced', 'Línea 1');
  final pinoSuarez1 = Estacion('Pino Suárez', 'Línea 1');
  final isabelLaCatolica = Estacion('Isabel la Católica', 'Línea 1');
  final saltoDelAgua1 = Estacion('Salto del Agua', 'Línea 1');
  final balderas = Estacion('Balderas', 'Línea 1');
  final cuauhtemoc = Estacion('Cuauhtémoc', 'Línea 1');
  final insurgentes = Estacion('Insurgentes', 'Línea 1');
  final sevilla = Estacion('Sevilla', 'Línea 1');
  final chapultepec = Estacion('Chapultepec', 'Línea 1');
  final juanacatlan = Estacion('Juanacatlán', 'Línea 1');
  final tacubaya1 = Estacion('Tacubaya', 'Línea 1');
  final observatorio = Estacion('Observatorio', 'Línea 1');

// Línea 2
  final cuatroCaminos = Estacion('Cuatro Caminos', 'Línea 2');
  final panteones = Estacion('Panteones', 'Línea 2');
  final tacuba2 = Estacion('Tacuba', 'Línea 2');
  final cuitlahuac = Estacion('Cuitláhuac', 'Línea 2');
  final popotla = Estacion('Popotla', 'Línea 2');
  final colegioMilitar = Estacion('Colegio Militar', 'Línea 2');
  final normal = Estacion('Normal', 'Línea 2');
  final sanCosme = Estacion('San Cosme', 'Línea 2');
  final revolucion = Estacion('Revolución', 'Línea 2');
  final hidalgo2 = Estacion('Hidalgo', 'Línea 2');
  final bellasArtes2 = Estacion('Bellas Artes', 'Línea 2');
  final allende = Estacion('Allende', 'Línea 2');
  final zocaloTenochtitlan = Estacion('Zócalo Tenochtitlan', 'Línea 2');
  final pinoSuarez2 = Estacion('Pino Suárez', 'Línea 2');
  final sanAntonioAbad = Estacion('San Antonio Abad', 'Línea 2');
  final chabacano2 = Estacion('Chabacano', 'Línea 2');
  final viaducto = Estacion('Viaducto', 'Línea 2');
  final xola = Estacion('Xola', 'Línea 2');
  final villaDeCortes = Estacion('Villa de Cortés', 'Línea 2');
  final nativitas = Estacion('Nativitas', 'Línea 2');
  final portales = Estacion('Portales', 'Línea 2');
  final ermita2 = Estacion('Ermita', 'Línea 2');
  final generalAnaya = Estacion('General Anaya', 'Línea 2');
  final tasquena = Estacion('Tasqueña', 'Línea 2');

// Línea 3
  final indiosVerdes = Estacion('Indios Verdes', 'Línea 3');
  final deportivo18DeMarzo = Estacion('Deportivo 18 de Marzo', 'Línea 3');
  final potrero = Estacion('Potrero', 'Línea 3');
  final laRaza = Estacion('La Raza', 'Línea 3');
  final tlatelolco = Estacion('Tlatelolco', 'Línea 3');
  final guerrero = Estacion('Guerrero', 'Línea 3');
  final hidalgo3 = Estacion('Hidalgo', 'Línea 3');
  final juarez = Estacion('Juárez', 'Línea 3');
  final balderas3 = Estacion('Balderas', 'Línea 3');
  final ninosHeroes = Estacion('Niños Héroes', 'Línea 3');
  final hospitalGeneral = Estacion('Hospital General', 'Línea 3');
  final centroMedico = Estacion('Centro Médico', 'Línea 3');
  final etiopia = Estacion('Etiopía', 'Línea 3');
  final eugenia = Estacion('Eugenia', 'Línea 3');
  final divisionDelNorte = Estacion('División del Norte', 'Línea 3');
  final zapata = Estacion('Zapata', 'Línea 3');
  final coyoacan = Estacion('Coyoacán', 'Línea 3');
  final viveros = Estacion('Viveros', 'Línea 3');
  final miguelAngelDeQuevedo = Estacion('Miguel Ángel de Quevedo', 'Línea 3');
  final copilco = Estacion('Copilco', 'Línea 3');
  final universidad = Estacion('Universidad', 'Línea 3');

// Línea 4
  final martinCarrera4 = Estacion('Martín Carrera', 'Línea 4');
  final talisman = Estacion('Talismán', 'Línea 4');
  final bondojito = Estacion('Bondojito', 'Línea 4');
  final consulado4 = Estacion('Consulado', 'Línea 4');
  final canalDelNorte = Estacion('Canal del Norte', 'Línea 4');
  final morelos = Estacion('Morelos', 'Línea 4');
  final candelaria4 = Estacion('Candelaria', 'Línea 4');
  final frayServando = Estacion('Fray Servando', 'Línea 4');
  final jamaica4 = Estacion('Jamaica', 'Línea 4');
  final santaAnita = Estacion('Santa Anita', 'Línea 4');

// Línea 5
  final politecnico = Estacion('Politécnico', 'Línea 5');
  final institutoDelPetroleo5 = Estacion('Instituto del Petróleo', 'Línea 5');
  final autobusesDelNorte = Estacion('Autobuses del Norte', 'Línea 5');
  final laRaza5 = Estacion('La Raza', 'Línea 5');
  final misterios = Estacion('Misterios', 'Línea 5');
  final valleGomez = Estacion('Valle Gómez', 'Línea 5');
  final consulado5 = Estacion('Consulado', 'Línea 5');
  final eduardoMolina = Estacion('Eduardo Molina', 'Línea 5');
  final aragon = Estacion('Aragón', 'Línea 5');
  final oceania5 = Estacion('Oceanía', 'Línea 5');
  final terminalAerea = Estacion('Terminal Aérea', 'Línea 5');
  final hangares = Estacion('Hangares', 'Línea 5');
  final pantitlan5 = Estacion('Pantitlán', 'Línea 5');

// Línea 6
  final rosario6 = Estacion('Rosario', 'Línea 6');
  final tezozomoc = Estacion('Tezozómoc', 'Línea 6');
  final uamAzcapotzalco = Estacion('UAM Azcapotzalco', 'Línea 6');
  final ferreria = Estacion('Ferrería', 'Línea 6');
  final norte45 = Estacion('Norte 45', 'Línea 6');
  final vallejo = Estacion('Vallejo', 'Línea 6');
  final institutoDelPetroleo6 = Estacion('Instituto del Petróleo', 'Línea 6');
  final lindavista = Estacion('Lindavista', 'Línea 6');
  final deportivo18DeMarzo6 = Estacion('Deportivo 18 de Marzo', 'Línea 6');
  final laVillaBasilica = Estacion('La Villa Basílica', 'Línea 6');
  final martinCarrera6 = Estacion('Martín Carrera', 'Línea 6');

// Línea 7
  final rosario7 = Estacion('Rosario', 'Línea 7');
  final aquilesSerdan = Estacion('Aquiles Serdán', 'Línea 7');
  final camarones = Estacion('Camarones', 'Línea 7');
  final refineria = Estacion('Refinería', 'Línea 7');
  final tacuba7 = Estacion('Tacuba', 'Línea 7');
  final sanJoaquin = Estacion('San Joaquín', 'Línea 7');
  final polanco = Estacion('Polanco', 'Línea 7');
  final auditorio = Estacion('Auditorio', 'Línea 7');
  final constituyentes = Estacion('Constituyentes', 'Línea 7');
  final tacubaya7 = Estacion('Tacubaya', 'Línea 7');
  final sanPedroDeLosPinos = Estacion('San Pedro de los Pinos', 'Línea 7');
  final sanAntonio = Estacion('San Antonio', 'Línea 7');
  final mixcoac7 = Estacion('Mixcoac', 'Línea 7');
  final barrancaDelMuerto = Estacion('Barranca del Muerto', 'Línea 7');

// Línea 8
  final constitucionDe1917 = Estacion('Constitución de 1917', 'Línea 8');
  final uamI = Estacion('UAM-I', 'Línea 8');
  final cerroDeLaEstrella = Estacion('Cerro de la Estrella', 'Línea 8');
  final iztapalapa = Estacion('Iztapalapa', 'Línea 8');
  final atlalilco8 = Estacion('Atlalilco', 'Línea 8');
  final escuadron201 = Estacion('Escuadrón 201', 'Línea 8');
  final aculco = Estacion('Aculco', 'Línea 8');
  final apatlaco = Estacion('Apatlaco', 'Línea 8');
  final iztacalco = Estacion('Iztacalco', 'Línea 8');
  final coyuya = Estacion('Coyuya', 'Línea 8');
  final santaAnita8 = Estacion('Santa Anita', 'Línea 8');
  final laViga = Estacion('La Viga', 'Línea 8');
  final chabacano8 = Estacion('Chabacano', 'Línea 8');
  final obrera = Estacion('Obrera', 'Línea 8');
  final doctores = Estacion('Doctores', 'Línea 8');
  final saltoDelAgua8 = Estacion('Salto del Agua', 'Línea 8');
  final sanJuanDeLetran = Estacion('San Juan de Letrán', 'Línea 8');
  final bellasArtes8 = Estacion('Bellas Artes', 'Línea 8');
  final garibaldi8 = Estacion('Garibaldi', 'Línea 8');

// Línea 9
  final pantitlan9 = Estacion('Pantitlán', 'Línea 9');
  final puebla = Estacion('Puebla', 'Línea 9');
  final ciudadDeportiva = Estacion('Ciudad Deportiva', 'Línea 9');
  final velodromo = Estacion('Velódromo', 'Línea 9');
  final mixiuhca = Estacion('Mixiuhca', 'Línea 9');
  final jamaica9 = Estacion('Jamaica', 'Línea 9');
  final chabacano9 = Estacion('Chabacano', 'Línea 9');
  final lazaroCardenas = Estacion('Lázaro Cárdenas', 'Línea 9');
  final centroMedico9 = Estacion('Centro Médico', 'Línea 9');
  final chilpancingo = Estacion('Chilpancingo', 'Línea 9');
  final patriotismo = Estacion('Patriotismo', 'Línea 9');
  final tacubaya9 = Estacion('Tacubaya', 'Línea 9');

// Línea A
  final laPaz = Estacion('La Paz', 'Línea A');
  final losReyes = Estacion('Los Reyes', 'Línea A');
  final santaMarta = Estacion('Santa Marta', 'Línea A');
  final acatitla = Estacion('Acatitla', 'Línea A');
  final penonViejo = Estacion('Peñón Viejo', 'Línea A');
  final guelatao = Estacion('Guelatao', 'Línea A');
  final tepalcates = Estacion('Tepalcates', 'Línea A');
  final canalDeSanJuan = Estacion('Canal de San Juan', 'Línea A');
  final agricolaOriental = Estacion('Agrícola Oriental', 'Línea A');
  final pantitlanA = Estacion('Pantitlán', 'Línea A');

// Línea B
  final buenavista = Estacion('Buenavista', 'Línea B');
  final guerreroB = Estacion('Guerrero', 'Línea B');
  final garibaldiB = Estacion('Garibaldi', 'Línea B');
  final lagunilla = Estacion('Lagunilla', 'Línea B');
  final tepito = Estacion('Tepito', 'Línea B');
  final morelosB = Estacion('Morelos', 'Línea B');
  final sanLazaroB = Estacion('San Lázaro', 'Línea B');
  final ricardoFloresMagon = Estacion('Ricardo Flores Magón', 'Línea B');
  final romeroRubio = Estacion('Romero Rubio', 'Línea B');
  final oceaniaB = Estacion('Oceanía', 'Línea B');
  final deportivoOceania = Estacion('Deportivo Oceanía', 'Línea B');
  final bosqueDeAragon = Estacion('Bosque de Aragón', 'Línea B');
  final villaDeAragon = Estacion('Villa de Aragón', 'Línea B');
  final nezahualcoyotl = Estacion('Nezahualcóyotl', 'Línea B');
  final rioDeLosRemedios = Estacion('Río de los Remedios', 'Línea B');
  final impulsora = Estacion('Impulsora', 'Línea B');
  final muzquiz = Estacion('Múzquiz', 'Línea B');
  final ecatepec = Estacion('Ecatepec', 'Línea B');
  final olimpica = Estacion('Olímpica', 'Línea B');
  final plazaAragon = Estacion('Plaza Aragón', 'Línea B');
  final ciudadAzteca = Estacion('Ciudad Azteca', 'Línea B');

// Línea 12
  final tlahuac = Estacion('Tláhuac', 'Línea 12');
  final tlaltenco = Estacion('Tlaltenco', 'Línea 12');
  final zapotitlan = Estacion('Zapotitlán', 'Línea 12');
  final nopalera = Estacion('Nopalera', 'Línea 12');
  final olivos = Estacion('Olivos', 'Línea 12');
  final tezonco = Estacion('Tezonco', 'Línea 12');
  final perifericoOriente = Estacion('Periférico Oriente', 'Línea 12');
  final calle11 = Estacion('Calle 11', 'Línea 12');
  final lomasEstrella = Estacion('Lomas Estrella', 'Línea 12');
  final sanAndresTomatlan = Estacion('San Andrés Tomatlán', 'Línea 12');
  final culhuacan = Estacion('Culhuacán', 'Línea 12');
  final atlalilco12 = Estacion('Atlalilco', 'Línea 12');
  final mexicaltzingo = Estacion('Mexicaltzingo', 'Línea 12');
  final ermita12 = Estacion('Ermita', 'Línea 12');
  final ejeCentral = Estacion('Eje Central', 'Línea 12');
  final parqueDeLosVenados = Estacion('Parque de los Venados', 'Línea 12');
  final zapata12 = Estacion('Zapata', 'Línea 12');
  final hospital20DeNoviembre =
      Estacion('Hospital 20 de Noviembre', 'Línea 12');
  final insurgentesSur = Estacion('Insurgentes Sur', 'Línea 12');
  final mixcoac12 = Estacion('Mixcoac', 'Línea 12');

  // Mapa de estaciones
  late final Map<String, Estacion> estaciones;

  // Lista de estaciones de la Línea 1
  
  // Mapa de estaciones con sus líneas de transbordo
  final Map<String, List<String>> estacionesConTransbordo = {
    //linea 1
    "Pantitlán": ["linea1", "linea5", "linea9", "lineaa"],
    "San Lázaro": ["linea1", "lineab"],
    "Candelaria": ["linea1", "linea4"],
    "Pino Suárez": ["linea1", "linea2"],
    "Salto del Agua": ["linea1", "linea8"],
    "Balderas": ["linea1", "linea3"],
    "Tacubaya": ["linea1", "linea7", "linea9"],
    //linea 2
    "Tacuba": ["linea2", "linea7"],
    "Hidalgo": ["linea2", "linea3"],
    "Bellas Artes": ["linea2", "linea8"],
    "Chabacano": ["linea2", "linea8", "linea9"],
    "Ermita": ["linea2", "linea12"],
    //linea 3
    "Deportivo 18 de Marzo": ["linea3", "linea6"],
    "La Raza": ["linea3", "linea5"],
    "Guerrero": ["linea3", "lineab"],
    "Centro Médico": ["linea3", "linea9"],
    "Zapata": ["linea3", "linea12"],
    //linea 4
    "Martín Carrera": ["linea4", "linea6"],
    "Consulado": ["linea4", "linea5"],
    "Morelos": ["linea4", "lineab"],
    "Jamaica": ["linea4", "linea9"],
    "Santa Anita": ["linea4", "linea8"],
    //linea 5
    "Instituto del Petróleo": ["linea5", "linea6"],
    "Oceanía": ["linea5", "lineab"],
    //linea 6 completa
    //linea 7
    "Rosario": ["linea7", "linea6"],
    "Mixcoac": ["linea7", "linea12"],
    //linea 8
    "Garibaldi": ["linea8", "lineab"],
    "Atlalilco": ["linea8", "linea12"],
    //linea 9 completa
    //linea A completa
    //linea B completa
    //linea 12 completa
  };

  @override
  void initState() {
    super.initState();
    loadMapStyle();
    loadCustomIcon();

    // Inicializar estaciones y conexiones
    estaciones = {
      // Línea 1
      'Pantitlán': pantitlan1,
      'Zaragoza': zaragoza,
      'Gómez Farías': gomezFarias,
      'Boulevard Puerto Aéreo': boulevardPuertoAereo,
      'Balbuena': balbuena,
      'Moctezuma': moctezuma,
      'San Lázaro': sanLazaro1,
      'Candelaria': candelaria1,
      'Merced': merced,
      'Pino Suárez': pinoSuarez1,
      'Isabel la Católica': isabelLaCatolica,
      'Salto del Agua': saltoDelAgua1,
      'Balderas': balderas,
      'Cuauhtémoc': cuauhtemoc,
      'Insurgentes': insurgentes,
      'Sevilla': sevilla,
      'Chapultepec': chapultepec,
      'Juanacatlán': juanacatlan,
      'Tacubaya': tacubaya1,
      'Observatorio': observatorio,

      // Línea 2
      'Cuatro Caminos': cuatroCaminos,
      'Panteones': panteones,
      'Tacuba': tacuba2,
      'Cuitláhuac': cuitlahuac,
      'Popotla': popotla,
      'Colegio Militar': colegioMilitar,
      'Normal': normal,
      'San Cosme': sanCosme,
      'Revolución': revolucion,
      'Hidalgo': hidalgo2,
      'Bellas Artes': bellasArtes2,
      'Allende': allende,
      'Zócalo Tenochtitlan': zocaloTenochtitlan,
      'Pino Suárez': pinoSuarez2,
      'San Antonio Abad': sanAntonioAbad,
      'Chabacano': chabacano2,
      'Viaducto': viaducto,
      'Xola': xola,
      'Villa de Cortés': villaDeCortes,
      'Nativitas': nativitas,
      'Portales': portales,
      'Ermita': ermita2,
      'General Anaya': generalAnaya,
      'Tasqueña': tasquena,
// Línea 3
      'Indios Verdes': indiosVerdes,
      'Deportivo 18 de Marzo': deportivo18DeMarzo,
      'Potrero': potrero,
      'La Raza': laRaza,
      'Tlatelolco': tlatelolco,
      'Guerrero': guerrero,
      'Hidalgo': hidalgo3,
      'Juárez': juarez,
      'Balderas': balderas3,
      'Niños Héroes': ninosHeroes,
      'Hospital General': hospitalGeneral,
      'Centro Médico': centroMedico,
      'Etiopía': etiopia,
      'Eugenia': eugenia,
      'División del Norte': divisionDelNorte,
      'Zapata': zapata,
      'Coyoacán': coyoacan,
      'Viveros': viveros,
      'Miguel Ángel de Quevedo': miguelAngelDeQuevedo,
      'Copilco': copilco,
      'Universidad': universidad,

// Línea 4
      'Martín Carrera': martinCarrera4,
      'Talismán': talisman,
      'Bondojito': bondojito,
      'Consulado': consulado4,
      'Canal del Norte': canalDelNorte,
      'Morelos': morelos,
      'Candelaria': candelaria4,
      'Fray Servando': frayServando,
      'Jamaica': jamaica4,
      'Santa Anita': santaAnita,

// Línea 5
      'Politécnico': politecnico,
      'Instituto del Petróleo': institutoDelPetroleo5,
      'Autobuses del Norte': autobusesDelNorte,
      'La Raza': laRaza5,
      'Misterios': misterios,
      'Valle Gómez': valleGomez,
      'Consulado': consulado5,
      'Eduardo Molina': eduardoMolina,
      'Aragón': aragon,
      'Oceanía': oceania5,
      'Terminal Aérea': terminalAerea,
      'Hangares': hangares,
      'Pantitlán': pantitlan5,

// Línea 6
      'Rosario': rosario6,
      'Tezozómoc': tezozomoc,
      'UAM Azcapotzalco': uamAzcapotzalco,
      'Ferrería': ferreria,
      'Norte 45': norte45,
      'Vallejo': vallejo,
      'Instituto del Petróleo': institutoDelPetroleo6,
      'Lindavista': lindavista,
      'Deportivo 18 de Marzo': deportivo18DeMarzo6,
      'La Villa Basilica': laVillaBasilica,
      'Martín Carrera': martinCarrera6,

// Línea 7
      'Rosario': rosario7,
      'Aquiles Serdán': aquilesSerdan,
      'Camarones': camarones,
      'Refinería': refineria,
      'Tacuba': tacuba7,
      'San Joaquín': sanJoaquin,
      'Polanco': polanco,
      'Auditorio': auditorio,
      'Constituyentes': constituyentes,
      'Tacubaya': tacubaya7,
      'San Pedro de los Pinos': sanPedroDeLosPinos,
      'San Antonio': sanAntonio,
      'Mixcoac': mixcoac7,
      'Barranca del Muerto': barrancaDelMuerto,

// Línea 8
      'Constitución de 1917': constitucionDe1917,
      'UAM-I': uamI,
      'Cerro de la Estrella': cerroDeLaEstrella,
      'Iztapalapa': iztapalapa,
      'Atlalilco': atlalilco8,
      'Escuadrón 201': escuadron201,
      'Aculco': aculco,
      'Apatlaco': apatlaco,
      'Iztacalco': iztacalco,
      'Coyuya': coyuya,
      'Santa Anita': santaAnita8,
      'La Viga': laViga,
      'Chabacano': chabacano8,
      'Obrera': obrera,
      'Doctores': doctores,
      'Salto del Agua': saltoDelAgua8,
      'San Juan de Letrán': sanJuanDeLetran,
      'Bellas Artes': bellasArtes8,
      'Garibaldi': garibaldi8,

// Línea 9
      'Pantitlán': pantitlan9,
      'Puebla': puebla,
      'Ciudad Deportiva': ciudadDeportiva,
      'Velódromo': velodromo,
      'Mixiuhca': mixiuhca,
      'Jamaica': jamaica9,
      'Chabacano': chabacano9,
      'Lázaro Cárdenas': lazaroCardenas,
      'Centro Médico': centroMedico9,
      'Chilpancingo': chilpancingo,
      'Patriotismo': patriotismo,
      'Tacubaya': tacubaya9,

// Línea A
      'La Paz': laPaz,
      'Los Reyes': losReyes,
      'Santa Marta': santaMarta,
      'Acatitla': acatitla,
      'Peñón Viejo': penonViejo,
      'Guelatao': guelatao,
      'Tepalcates': tepalcates,
      'Canal de San Juan': canalDeSanJuan,
      'Agrícola Oriental': agricolaOriental,
      'Pantitlán': pantitlanA,

// Línea B
      'Buenavista': buenavista,
      'Guerrero': guerreroB,
      'Garibaldi': garibaldiB,
      'Lagunilla': lagunilla,
      'Tepito': tepito,
      'Morelos': morelosB,
      'San Lázaro': sanLazaroB,
      'Ricardo Flores Magón': ricardoFloresMagon,
      'Romero Rubio': romeroRubio,
      'Oceanía': oceaniaB,
      'Deportivo Oceanía': deportivoOceania,
      'Bosque de Aragón': bosqueDeAragon,
      'Villa de Aragón': villaDeAragon,
      'Nezahualcóyotl': nezahualcoyotl,
      'Río de los Remedios': rioDeLosRemedios,
      'Impulsora': impulsora,
      'Múzquiz': muzquiz,
      'Ecatepec': ecatepec,
      'Olímpica': olimpica,
      'Plaza Aragón': plazaAragon,
      'Ciudad Azteca': ciudadAzteca,

// Línea 12
      'Tláhuac': tlahuac,
      'Tlaltenco': tlaltenco,
      'Zapotitlán': zapotitlan,
      'Nopalera': nopalera,
      'Olivos': olivos,
      'Tezonco': tezonco,
      'Periférico Oriente': perifericoOriente,
      'Calle 11': calle11,
      'Lomas Estrella': lomasEstrella,
      'San Andrés Tomatlán': sanAndresTomatlan,
      'Culhuacán': culhuacan,
      'Atlalilco': atlalilco12,
      'Mexicaltzingo': mexicaltzingo,
      'Ermita': ermita12,
      'Eje Central': ejeCentral,
      'Parque de los Venados': parqueDeLosVenados,
      'Zapata': zapata12,
      'Hospital 20 de Noviembre': hospital20DeNoviembre,
      'Insurgentes Sur': insurgentesSur,
      'Mixcoac': mixcoac12,
    };

// Conectar las estaciones (distancias en kilómetros)
//linea 1
    conectarEstaciones(pantitlan1, zaragoza, 1.32);
    conectarEstaciones(zaragoza, gomezFarias, 0.762);
    conectarEstaciones(gomezFarias, boulevardPuertoAereo, 0.611);
    conectarEstaciones(boulevardPuertoAereo, balbuena, 0.595);
    conectarEstaciones(balbuena, moctezuma, 0.703);
    conectarEstaciones(moctezuma, sanLazaro1, 0.478);
    conectarEstaciones(sanLazaro1, candelaria1, 0.866);
    conectarEstaciones(candelaria1, merced, 0.698);
    conectarEstaciones(merced, pinoSuarez1, 0.745);
    conectarEstaciones(pinoSuarez1, isabelLaCatolica, 0.382);
    conectarEstaciones(isabelLaCatolica, saltoDelAgua1, 0.445);
    conectarEstaciones(saltoDelAgua1, balderas, 0.458);
    conectarEstaciones(balderas, cuauhtemoc, 0.409);
    conectarEstaciones(cuauhtemoc, insurgentes, 0.793);
    conectarEstaciones(insurgentes, sevilla, 0.645);
    conectarEstaciones(sevilla, chapultepec, 0.501);
    conectarEstaciones(chapultepec, juanacatlan, 0.973);
    conectarEstaciones(juanacatlan, tacubaya1, 1.158);
    conectarEstaciones(tacubaya1, observatorio, 1.262);
    // linea 2
    conectarEstaciones(cuatroCaminos, panteones, 1.639);
    conectarEstaciones(panteones, tacuba2, 1.416);
    conectarEstaciones(tacuba2, cuitlahuac, 0.637);
    conectarEstaciones(cuitlahuac, popotla, 0.620);
    conectarEstaciones(popotla, colegioMilitar, 0.462);
    conectarEstaciones(colegioMilitar, normal, 0.516);
    conectarEstaciones(normal, sanCosme, 0.657);
    conectarEstaciones(sanCosme, revolucion, 0.537);
    conectarEstaciones(revolucion, hidalgo2, 0.587);
    conectarEstaciones(hidalgo2, bellasArtes2, 0.447);
    conectarEstaciones(bellasArtes2, allende, 0.387);
    conectarEstaciones(allende, zocaloTenochtitlan, 0.602);
    conectarEstaciones(zocaloTenochtitlan, pinoSuarez2, 0.745);
    conectarEstaciones(pinoSuarez2, sanAntonioAbad, 0.817);
    conectarEstaciones(sanAntonioAbad, chabacano2, 0.642);
    conectarEstaciones(chabacano2, viaducto, 0.774);
    conectarEstaciones(viaducto, xola, 0.490);
    conectarEstaciones(xola, villaDeCortes, 0.698);
    conectarEstaciones(villaDeCortes, nativitas, 0.750);
    conectarEstaciones(nativitas, portales, 0.924);
    conectarEstaciones(portales, ermita2, 0.748);
    conectarEstaciones(ermita2, generalAnaya, 0.838);
    conectarEstaciones(generalAnaya, tasquena, 1.330);
    // línea 3
    conectarEstaciones(indiosVerdes, deportivo18DeMarzo, 1.166);
    conectarEstaciones(deportivo18DeMarzo, potrero, 0.966);
    conectarEstaciones(potrero, laRaza, 1.106);
    conectarEstaciones(laRaza, tlatelolco, 1.445);
    conectarEstaciones(tlatelolco, guerrero, 1.042);
    conectarEstaciones(guerrero, hidalgo3, 0.702);
    conectarEstaciones(hidalgo3, juarez, 0.251);
    conectarEstaciones(juarez, balderas3, 0.659);
    conectarEstaciones(balderas3, ninosHeroes, 0.665);
    conectarEstaciones(ninosHeroes, hospitalGeneral, 0.559);
    conectarEstaciones(hospitalGeneral, centroMedico, 0.653);
    conectarEstaciones(centroMedico, etiopia, 1.119);
    conectarEstaciones(etiopia, eugenia, 0.950);
    conectarEstaciones(eugenia, divisionDelNorte, 0.715);
    conectarEstaciones(divisionDelNorte, zapata, 0.794);
    conectarEstaciones(zapata, coyoacan, 1.153);
    conectarEstaciones(coyoacan, viveros, 0.908);
    conectarEstaciones(viveros, miguelAngelDeQuevedo, 0.824);
    conectarEstaciones(miguelAngelDeQuevedo, copilco, 1.295);
    conectarEstaciones(copilco, universidad, 1.306);
// línea 4
    conectarEstaciones(santaAnita, jamaica4, 0.758);
    conectarEstaciones(jamaica4, frayServando, 1.033);
    conectarEstaciones(frayServando, candelaria4, 0.633);
    conectarEstaciones(candelaria4, morelos, 1.062);
    conectarEstaciones(morelos, canalDelNorte, 0.910);
    conectarEstaciones(canalDelNorte, consulado4, 0.884);
    conectarEstaciones(consulado4, bondojito, 0.645);
    conectarEstaciones(bondojito, talisman, 0.959);
    conectarEstaciones(talisman, martinCarrera4, 1.129);
// línea 5
    conectarEstaciones(politecnico, institutoDelPetroleo5, 1.188);
    conectarEstaciones(institutoDelPetroleo5, autobusesDelNorte, 1.067);
    conectarEstaciones(autobusesDelNorte, laRaza5, 0.975);
    conectarEstaciones(laRaza5, misterios, 0.892);
    conectarEstaciones(misterios, valleGomez, 0.969);
    conectarEstaciones(valleGomez, consulado5, 0.679);
    conectarEstaciones(consulado5, eduardoMolina, 0.815);
    conectarEstaciones(eduardoMolina, aragon, 0.860);
    conectarEstaciones(aragon, oceania5, 1.219);
    conectarEstaciones(oceania5, terminalAerea, 1.174);
    conectarEstaciones(terminalAerea, hangares, 1.153);
    conectarEstaciones(hangares, pantitlan5, 1.644);
// línea 6
    conectarEstaciones(rosario6, tezozomoc, 1.257);
    conectarEstaciones(tezozomoc, uamAzcapotzalco, 0.973);
    conectarEstaciones(uamAzcapotzalco, ferreria, 1.173);
    conectarEstaciones(ferreria, norte45, 1.072);
    conectarEstaciones(norte45, vallejo, 0.660);
    conectarEstaciones(vallejo, institutoDelPetroleo6, 0.755);
    conectarEstaciones(institutoDelPetroleo6, lindavista, 1.258);
    conectarEstaciones(lindavista, deportivo18DeMarzo6, 1.075);
    conectarEstaciones(deportivo18DeMarzo6, laVillaBasilica, 0.570);
    conectarEstaciones(laVillaBasilica, martinCarrera6, 1.141);
// linea 7
    conectarEstaciones(rosario7, aquilesSerdan, 1.615);
    conectarEstaciones(aquilesSerdan, camarones, 1.402);
    conectarEstaciones(camarones, refineria, 0.952);
    conectarEstaciones(refineria, tacuba7, 1.295);
    conectarEstaciones(tacuba7, sanJoaquin, 1.433);
    conectarEstaciones(sanJoaquin, polanco, 1.163);
    conectarEstaciones(polanco, auditorio, 0.812);
    conectarEstaciones(auditorio, constituyentes, 1.430);
    conectarEstaciones(constituyentes, tacubaya7, 1.005);
    conectarEstaciones(tacubaya7, sanPedroDeLosPinos, 1.084);
    conectarEstaciones(sanPedroDeLosPinos, sanAntonio, 0.606);
    conectarEstaciones(sanAntonio, mixcoac7, 0.788);
    conectarEstaciones(mixcoac7, barrancaDelMuerto, 1.476);
    // línea 8
    conectarEstaciones(garibaldi8, bellasArtes8, 0.634);
    conectarEstaciones(bellasArtes8, sanJuanDeLetran, 0.456);
    conectarEstaciones(sanJuanDeLetran, saltoDelAgua8, 0.292);
    conectarEstaciones(saltoDelAgua8, doctores, 0.564);
    conectarEstaciones(doctores, obrera, 0.761);
    conectarEstaciones(obrera, chabacano8, 1.143);
    conectarEstaciones(chabacano8, laViga, 0.843);
    conectarEstaciones(laViga, santaAnita8, 0.633);
    conectarEstaciones(santaAnita8, coyuya, 0.968);
    conectarEstaciones(coyuya, iztacalco, 0.993);
    conectarEstaciones(iztacalco, apatlaco, 0.910);
    conectarEstaciones(apatlaco, aculco, 0.534);
    conectarEstaciones(aculco, escuadron201, 0.789);
    conectarEstaciones(escuadron201, atlalilco8, 1.738);
    conectarEstaciones(atlalilco8, iztapalapa, 0.732);
    conectarEstaciones(iztapalapa, cerroDeLaEstrella, 0.717);
    conectarEstaciones(cerroDeLaEstrella, uamI, 1.135);
    conectarEstaciones(uamI, constitucionDe1917, 1.137);
    // línea 9
    conectarEstaciones(pantitlan9, puebla, 1.380);
    conectarEstaciones(puebla, ciudadDeportiva, 0.800);
    conectarEstaciones(ciudadDeportiva, velodromo, 1.110);
    conectarEstaciones(velodromo, mixiuhca, 0.821);
    conectarEstaciones(mixiuhca, jamaica9, 0.942);
    conectarEstaciones(jamaica9, chabacano9, 1.031);
    conectarEstaciones(chabacano9, lazaroCardenas, 1.000);
    conectarEstaciones(lazaroCardenas, centroMedico9, 1.059);
    conectarEstaciones(centroMedico9, chilpancingo, 1.152);
    conectarEstaciones(chilpancingo, patriotismo, 0.955);
    conectarEstaciones(patriotismo, tacubaya9, 1.133);
// línea A
    conectarEstaciones(pantitlanA, agricolaOriental, 1.409);
    conectarEstaciones(agricolaOriental, canalDeSanJuan, 1.093);
    conectarEstaciones(canalDeSanJuan, tepalcates, 1.456);
    conectarEstaciones(tepalcates, guelatao, 1.161);
    conectarEstaciones(guelatao, penonViejo, 2.206);
    conectarEstaciones(penonViejo, acatitla, 1.379);
    conectarEstaciones(acatitla, santaMarta, 1.100);
    conectarEstaciones(santaMarta, losReyes, 1.783);
    conectarEstaciones(losReyes, laPaz, 1.956);
// línea B
    conectarEstaciones(ciudadAzteca, plazaAragon, 0.574);
    conectarEstaciones(plazaAragon, olimpica, 0.709);
    conectarEstaciones(olimpica, ecatepec, 0.596);
    conectarEstaciones(ecatepec, muzquiz, 1.485);
    conectarEstaciones(muzquiz, rioDeLosRemedios, 1.155);
    conectarEstaciones(rioDeLosRemedios, impulsora, 0.436);
    conectarEstaciones(impulsora, nezahualcoyotl, 1.393);
    conectarEstaciones(nezahualcoyotl, villaDeAragon, 1.335);
    conectarEstaciones(villaDeAragon, bosqueDeAragon, 0.784);
    conectarEstaciones(bosqueDeAragon, deportivoOceania, 1.165);
    conectarEstaciones(deportivoOceania, oceaniaB, 0.863);
    conectarEstaciones(oceaniaB, romeroRubio, 0.809);
    conectarEstaciones(romeroRubio, ricardoFloresMagon, 0.908);
    conectarEstaciones(ricardoFloresMagon, sanLazaroB, 0.907);
    conectarEstaciones(sanLazaroB, morelosB, 1.296);
    conectarEstaciones(morelosB, tepito, 0.498);
    conectarEstaciones(tepito, lagunilla, 0.611);
    conectarEstaciones(lagunilla, garibaldiB, 0.474);
    conectarEstaciones(garibaldiB, guerreroB, 0.757);
    conectarEstaciones(guerreroB, buenavista, 0.521);
// línea 12
    conectarEstaciones(tlahuac, tlaltenco, 1.298);
    conectarEstaciones(tlaltenco, zapotitlan, 1.115);
    conectarEstaciones(zapotitlan, nopalera, 1.276);
    conectarEstaciones(nopalera, olivos, 1.360);
    conectarEstaciones(olivos, tezonco, 0.490);
    conectarEstaciones(tezonco, perifericoOriente, 1.545);
    conectarEstaciones(perifericoOriente, calle11, 1.111);
    conectarEstaciones(calle11, lomasEstrella, 0.906);
    conectarEstaciones(lomasEstrella, sanAndresTomatlan, 1.060);
    conectarEstaciones(sanAndresTomatlan, culhuacan, 0.990);
    conectarEstaciones(culhuacan, atlalilco12, 1.671);
    conectarEstaciones(atlalilco12, mexicaltzingo, 1.922);
    conectarEstaciones(mexicaltzingo, ermita12, 1.805);
    conectarEstaciones(ermita12, ejeCentral, 0.895);
    conectarEstaciones(ejeCentral, parqueDeLosVenados, 1.280);
    conectarEstaciones(parqueDeLosVenados, zapata12, 0.563);
    conectarEstaciones(zapata12, hospital20DeNoviembre, 0.450);
    conectarEstaciones(hospital20DeNoviembre, insurgentesSur, 0.725);
    conectarEstaciones(insurgentesSur, mixcoac12, 0.651);
    //transbordos linea 1
    conectarEstaciones(pantitlan1, pantitlan5, 0.030);
    conectarEstaciones(pantitlan1, pantitlan9, 0.030);
    conectarEstaciones(pantitlan1, pantitlanA, 0.030);
    conectarEstaciones(pantitlan5, pantitlan9, 0.030);
    conectarEstaciones(pantitlan5, pantitlanA, 0.030);
    conectarEstaciones(pantitlan9, pantitlanA, 0.030);
    conectarEstaciones(sanLazaro1, sanLazaroB, 0.030);
    conectarEstaciones(candelaria1, candelaria4, 0.030);
    conectarEstaciones(pinoSuarez1, pinoSuarez2, 0.030);
    conectarEstaciones(saltoDelAgua1, saltoDelAgua8, 0.030);
    conectarEstaciones(balderas, balderas3, 0.030);
    conectarEstaciones(tacubaya1, tacubaya7, 0.030);
    //transbordos linea 2
    conectarEstaciones(tacuba2, tacuba7, 0.030);
    conectarEstaciones(hidalgo3, hidalgo2, 0.030);
    conectarEstaciones(bellasArtes2, bellasArtes8, 0.030);
    conectarEstaciones(chabacano2, chabacano9, 0.030);
    conectarEstaciones(chabacano2, chabacano8, 0.030);
    conectarEstaciones(chabacano8, chabacano9, 0.030);
    conectarEstaciones(ermita2, ermita12, 0.030);
    //transbordos linea 3
    conectarEstaciones(deportivo18DeMarzo, deportivo18DeMarzo6, 0.030);
    conectarEstaciones(laRaza, laRaza5, 0.030);
    conectarEstaciones(guerrero, guerreroB, 0.030);
    conectarEstaciones(centroMedico, centroMedico9, 0.030);
    conectarEstaciones(zapata, zapata12, 0.030);
    //transbordos linea 4
    conectarEstaciones(martinCarrera4, martinCarrera6, 0.030);
    conectarEstaciones(consulado4, consulado5, 0.030);
    conectarEstaciones(morelos, morelosB, 0.030);
    conectarEstaciones(jamaica4, jamaica9, 0.030);
    conectarEstaciones(santaAnita, santaAnita8, 0.030);
    //transbordos linea 5
    conectarEstaciones(institutoDelPetroleo5, institutoDelPetroleo6, 0.030);
    conectarEstaciones(oceania5, oceaniaB, 0.030);
    //transbordos linea 6
    conectarEstaciones(rosario6, rosario7, 0.030);
    //transbordos linea 7
    conectarEstaciones(mixcoac7, mixcoac12, 0.030);
    //transbordos linea 8
    conectarEstaciones(garibaldi8, garibaldiB, 0.030);
    conectarEstaciones(atlalilco8, atlalilco12, 0.030);
    //transbordos linea 9
    //transbordos linea A
    //transbordos linea B
    //transbordos linea 12
  }

  Future<void> loadMapStyle() async {
    try {
      _mapStyle = await rootBundle.loadString('assets/map_styles.json');
    } catch (e) {
      print('Error al cargar el estilo del mapa: $e');
    }
  }

  Future<void> loadCustomIcon() async {
    String iconPath;
    double iconSize;

    if (currentZoom < 12.0) {
      iconPath = 'assets/estacionup.png';
      iconSize = 16.0;
    } else if (currentZoom < 14.0) {
      iconPath = 'assets/estacionp.png';
      iconSize = 16.0;
    } else if (currentZoom < 16.0) {
      iconPath = 'assets/estacion.png';
      iconSize = 24.0;
    } else {
      iconPath = 'assets/estaciongrande.png';
      iconSize = 32.0;
    }

    customIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(iconSize, iconSize)),
      iconPath,
    );

    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_mapStyle.isNotEmpty) {
      mapController.setMapStyle(_mapStyle);
    }
  }

  // Función para mostrar imágenes de las estaciones seleccionadas
  void _mostrarRutaConImagenes(BuildContext context, List<String> ruta) {
    setState(() {
      this.ruta = ruta;
    });
  }

// Función para crear marcadores desde una lista de estaciones
  Set<Marker> _createMarkersFromStations(
      List<MapEntry<String, LatLng>> stations) {
    final Set<Marker> markers = {};

    if (customIcon != null) {
      for (var station in stations) {
        markers.add(
          Marker(
            markerId: MarkerId(
                station.key), // Usamos station.key para acceder al nombre
            position: station
                .value, // Usamos station.value para acceder a la posición
            icon: customIcon!,
            anchor: Offset(0.5, 0.5),
            infoWindow: InfoWindow(
              title: station.key, // station.key es el nombre de la estación
            ),
            onTap: () {
              if (seleccionandoEstaciones) {
                _seleccionarEstacion(station.key); // station.key es el nombre
              } else {
                /*
              // Aquí no puedes acceder directamente a "transbordo" ya que la lista
              // de estaciones que estás usando solo tiene nombre y posición.
              // Si quieres mostrar las líneas de transbordo, deberías ajustar el modelo de datos.
              // Por ejemplo, si tuvieras un Map<String, dynamic> en lugar de MapEntry:
              // String lineasTransbordo = station['transbordo'].join(', ');
               _mostrarInfo(
                    station.key, '\n\t\t Transbordo con\n\t\t ${station.key}');
              */
                String lineasTransbordo = ''; // Placeholder
                _mostrarInfo(station.key,
                    '\n\t\t     Transbordo con Lineas\n\t\t $lineasTransbordo');
              }
            },
          ),
        );
      }
    }
    return markers;
  }

  // Función para crear polilíneas desde una lista de estaciones
  Set<Polyline> _createPolylinesFromStations(
      List<MapEntry<String, LatLng>> stations, String lineId, Color color) {
    final Set<Polyline> polylines = {};

    polylines.add(
      Polyline(
        polylineId: PolylineId('${lineId}_contour'),
        points: stations.map((station) => station.value).toList(),
        color: Colors.black,
        width: 5,
      ),
    );

    polylines.add(
      Polyline(
        polylineId: PolylineId('${lineId}_main'),
        points: stations.map((station) => station.value).toList(),
        color: color,
        width: 4,
      ),
    );

    return polylines;
  }

  Set<Marker> _createAllMarkers() {
    final Set<Marker> allMarkers = {};
    allMarkers.addAll(_createMarkersFromStations(line1Stations));
    allMarkers.addAll(_createMarkersFromStations(line2Stations));
    allMarkers.addAll(_createMarkersFromStations(line3Stations));
    allMarkers.addAll(_createMarkersFromStations(line4Stations));
    allMarkers.addAll(_createMarkersFromStations(line5Stations));
    allMarkers.addAll(_createMarkersFromStations(line6Stations));
    allMarkers.addAll(_createMarkersFromStations(line7Stations));
    allMarkers.addAll(_createMarkersFromStations(line8Stations));
    allMarkers.addAll(_createMarkersFromStations(line9Stations));
    allMarkers.addAll(_createMarkersFromStations(lineAStations));
    allMarkers.addAll(_createMarkersFromStations(lineBStations));
    allMarkers.addAll(_createMarkersFromStations(line12Stations));

    return allMarkers;
  }

  Set<Polyline> _createAllPolylines() {
    final Set<Polyline> allPolylines = {};
    allPolylines.addAll(_createPolylinesFromStations(
        line1Stations, 'linea1', const Color.fromARGB(255, 255, 0, 128)));
    allPolylines.addAll(_createPolylinesFromStations(
        line2Stations, 'linea2', const Color.fromARGB(255, 9, 100, 164)));
    allPolylines.addAll(_createPolylinesFromStations(
        line3Stations, 'linea3', const Color.fromARGB(255, 132, 186, 14)));
    allPolylines.addAll(_createPolylinesFromStations(
        line4Stations, 'linea4', const Color.fromARGB(255, 0, 204, 204)));
    allPolylines.addAll(_createPolylinesFromStations(
        line5Stations, 'linea5', const Color.fromARGB(255, 255, 204, 0)));
    allPolylines.addAll(_createPolylinesFromStations(
        line6Stations, 'linea6', const Color.fromARGB(255, 255, 0, 0)));
    allPolylines.addAll(_createPolylinesFromStations(
        line7Stations, 'linea7', const Color.fromARGB(255, 255, 102, 0)));
    allPolylines.addAll(_createPolylinesFromStations(
        line8Stations, 'linea8', const Color.fromARGB(255, 0, 153, 102)));
    allPolylines.addAll(_createPolylinesFromStations(
        line9Stations, 'linea9', const Color.fromARGB(255, 102, 51, 0)));
    allPolylines.addAll(_createPolylinesFromStations(
        lineAStations, 'lineaA', const Color.fromARGB(255, 102, 0, 153)));
    allPolylines.addAll(_createPolylinesFromStations(
        lineBStations, 'lineaB', const Color.fromARGB(255, 153, 153, 153)));
    allPolylines.addAll(_createPolylinesFromStations(
        line12Stations, 'linea12', const Color.fromARGB(255, 204, 153, 0)));

    return allPolylines;
  }

  void _mostrarInfo(String nombreEstacion, String info) {
    setState(() {
      _informacionMarcador = '$nombreEstacion: $info';
    });
  }

  // Función para manejar la selección de estaciones
  void _seleccionarEstacion(String nombreEstacion) {
    if (estacionSeleccionada1 == null) {
      estacionSeleccionada1 = nombreEstacion;
    } else if (estacionSeleccionada2 == null &&
        estacionSeleccionada1 != nombreEstacion) {
      estacionSeleccionada2 = nombreEstacion;
    }

    if (estacionSeleccionada1 != null && estacionSeleccionada2 != null) {
      // Ambas estaciones seleccionadas, calcular la ruta más corta usando Dijkstra
      final ruta = obtenerRuta(
          estacionSeleccionada1!, estacionSeleccionada2!, estaciones);

      // Mostramos la ruta con las imágenes
      if (ruta.isNotEmpty) {
        _mostrarRutaConImagenes(context, ruta);
      } else {
        setState(() {
          _informacionMarcador =
              'No se encontró una ruta entre ${estacionSeleccionada1} y ${estacionSeleccionada2}';
        });
      }
    }
  }

  List<Widget> _crearImagenesDeEstaciones(List<String> ruta) {
    List<Widget> estacionesConFlechas = [];

    for (int i = 0; i < ruta.length; i++) {
      estacionesConFlechas.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(
            children: [
              Image.asset(
                'assets/${ruta[i].toLowerCase().replaceAll(' ', '_')}.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/estacion.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  );
                },
              ),
              SizedBox(height: 5),
              Text(
                ruta[i],
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );

      if (i < ruta.length - 1) {
        estacionesConFlechas.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              " → ",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    }

    return estacionesConFlechas;
  }

  void _activarModoSeleccion() {
    setState(() {
      seleccionandoEstaciones = !seleccionandoEstaciones;
      estacionSeleccionada1 = null;
      estacionSeleccionada2 = null;
      _informacionMarcador =
          seleccionandoEstaciones ? 'Selecciona dos estaciones...' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Este código lo puedes dejar para futuros toques si se desea.
      },
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              'Metro de la CDMX',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          backgroundColor: Colors.orange,
          actions: [
            IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
              );
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.orange, // Color del encabezado
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Centra horizontalmente
                  mainAxisAlignment: MainAxisAlignment
                      .start, // Ajusta para que los widgets no se solapen
                  children: [
                    Text(
                      'Selecciona la estación del Metro deseada',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Colors.white,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                        height:
                            10), // Espacio entre el texto y el cuadro de búsqueda

                    // Aquí reemplazamos el TextField por el BuscadorLista
                    Expanded(
                      child: Container(
                        alignment: Alignment
                            .center, // Centra el BuscadorLista dentro del Container
                        margin: EdgeInsets.symmetric(
                            horizontal: 20), // Márgenes laterales
                        child: BuscadorLista(
                          estaciones:
                              lineStations, // Lista de estaciones del metro
                          onEstacionSeleccionada:
                              (LatLng ubicacion, String nombre) {
                            // Acción cuando se selecciona una estación: centrar mapa
                            _centrarMapaEnEstacion(ubicacion, nombre);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Línea 1 - Rosa
              ListTile(
                leading: Icon(Icons.train,
                    color: const Color.fromARGB(255, 233, 0,
                        128)), // Icono representando la Línea 1 (rosa)
                title: Text(
                  'Línea 1 \n Pantitlan - Observatorio',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  _mostrarSelectorDeEstaciones(context, 'Línea 1',
                      line1Stations, const Color.fromARGB(255, 233, 0, 128));
                },
              ),

              // Línea 2 - Azul
              ListTile(
                leading: Icon(Icons.train,
                    color: const Color.fromARGB(255, 9, 100,
                        164)), // Icono representando la Línea 2 (azul)
                title: Text(
                  'Línea 2 \n Cuatro Caminos - Tasqueña',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  _mostrarSelectorDeEstaciones(context, 'Línea 2',
                      line2Stations, const Color.fromARGB(255, 9, 100, 164));
                },
              ),

              // Línea 3 - Verde Olivo
              ListTile(
                leading: Icon(Icons.train,
                    color: const Color.fromARGB(255, 132, 186,
                        14)), // Icono representando la Línea 3 (verde olivo)
                title: Text(
                  'Línea 3 \n Indios Verdes - Universidad',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  _mostrarSelectorDeEstaciones(context, 'Línea 3',
                      line3Stations, const Color.fromARGB(255, 132, 186, 14));
                },
              ),

              // Línea 4 - Cian
              ListTile(
                leading: Icon(Icons.train,
                    color: const Color.fromARGB(255, 0, 204,
                        204)), // Icono representando la Línea 4 (cian)
                title: Text(
                  'Línea 4 \n Martin Carrera - Santa Anita',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  _mostrarSelectorDeEstaciones(context, 'Línea 4',
                      line4Stations, const Color.fromARGB(255, 0, 204, 204));
                },
              ),

              // Línea 5 - Amarilla
              ListTile(
                leading: Icon(Icons.train,
                    color: const Color.fromARGB(255, 255, 204,
                        0)), // Icono representando la Línea 5 (amarilla)
                title: Text(
                  'Línea 5 \n Pantitlan - Politécnico',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  _mostrarSelectorDeEstaciones(context, 'Línea 5',
                      line5Stations, const Color.fromARGB(255, 255, 204, 0));
                },
              ),

              // Línea 6 - Roja
              ListTile(
                leading: Icon(Icons.train,
                    color: const Color.fromARGB(255, 255, 0,
                        0)), // Icono representando la Línea 6 (rojo)
                title: Text(
                  'Línea 6 \n Rosario - Martin Carrera',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  _mostrarSelectorDeEstaciones(context, 'Línea 6',
                      line6Stations, const Color.fromARGB(255, 255, 0, 0));
                },
              ),

              // Línea 7 - Naranja Oscuro
              ListTile(
                leading: Icon(Icons.train,
                    color: const Color.fromARGB(255, 255, 102,
                        0)), // Icono representando la Línea 7 (naranja oscuro)
                title: Text(
                  'Línea 7 \n Rosario - Barranca del Muerto',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  _mostrarSelectorDeEstaciones(context, 'Línea 7',
                      line7Stations, const Color.fromARGB(255, 255, 102, 0));
                },
              ),

              // Línea 8 - Verde Claro
              ListTile(
                leading: Icon(Icons.train,
                    color: const Color.fromARGB(255, 0, 153,
                        102)), // Icono representando la Línea 8 (verde claro)
                title: Text(
                  'Línea 8 \n Garibaldi - Const. 1917',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  _mostrarSelectorDeEstaciones(context, 'Línea 8',
                      line8Stations, const Color.fromARGB(255, 0, 153, 102));
                },
              ),

              // Línea 9 - Café
              ListTile(
                leading: Icon(Icons.train,
                    color: const Color.fromARGB(255, 102, 51,
                        0)), // Icono representando la Línea 9 (café)
                title: Text(
                  'Línea 9 \n Pantitlan - Tacubaya',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  _mostrarSelectorDeEstaciones(context, 'Línea 9',
                      line9Stations, const Color.fromARGB(255, 102, 51, 0));
                },
              ),

              // Línea 12 - Dorada
              ListTile(
                leading: Icon(Icons.train,
                    color: const Color.fromARGB(255, 204, 153,
                        0)), // Icono representando la Línea 12 (dorada)
                title: Text(
                  'Línea 12 \n Mixcoac - Tláhuac',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  _mostrarSelectorDeEstaciones(context, 'Línea 12',
                      line12Stations, const Color.fromARGB(255, 204, 153, 0));
                },
              ),

              // Línea A - Morada
              ListTile(
                leading: Icon(Icons.train,
                    color: const Color.fromARGB(255, 102, 0,
                        153)), // Icono representando la Línea A (morada)
                title: Text(
                  'Línea A \n Pantitlan - La Paz',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  _mostrarSelectorDeEstaciones(context, 'Línea A',
                      lineAStations, const Color.fromARGB(255, 102, 0, 153));
                },
              ),

              // Línea B - Verde Gris
              ListTile(
                leading: Icon(Icons.train,
                    color: const Color.fromARGB(255, 153, 153,
                        153)), // Icono representando la Línea B (gris)
                title: Text(
                  'Línea B \n Cd. Azteca - Buenavista',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  _mostrarSelectorDeEstaciones(context, 'Línea B',
                      lineBStations, const Color.fromARGB(255, 153, 153, 153));
                },
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: currentZoom,
              ),
              markers: _createAllMarkers(),
              polylines: _createAllPolylines(),
              minMaxZoomPreference: MinMaxZoomPreference(_minZoom, _maxZoom),
              cameraTargetBounds: CameraTargetBounds(_limitesMapa),
              onCameraIdle: () async {
                double newZoom = await mapController.getZoomLevel();
                if (newZoom != currentZoom) {
                  currentZoom = newZoom;
                  await loadCustomIcon();
                  setState(() {});
                }
              },
              // Deshabilitar botones predeterminados de Google Maps
              myLocationButtonEnabled:
                  false, // Deshabilita el botón de mi ubicación
              zoomControlsEnabled: false, // Deshabilita los controles de zoom
              mapToolbarEnabled:
                  false, // Deshabilita la barra de herramientas de Google Maps
            ),
            if (ruta.isNotEmpty)
              Positioned(
                bottom: 100,
                left: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    // Evitamos que el cuadro desaparezca al tocar dentro de él
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          Color.fromARGB(255, 255, 255, 255).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Centra verticalmente
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Centra horizontalmente
                      children: [
                        Text(
                          'Ruta más corta\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Color de letra
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _crearImagenesDeEstaciones(ruta),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_informacionMarcador != null && ruta.isEmpty)
              Positioned(
                bottom: 100,
                left: 10,
                right: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Centra verticalmente
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Centra horizontalmente
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/${_informacionMarcador!.split(':').first.toLowerCase().replaceAll(' ', '')}.png',
                            width: 65,
                            height: 65,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/estacion.png',
                                width: 65,
                                height: 65,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _informacionMarcador!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0,
                                    0), // Aplicar el color sin opacidad
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      _crearImagenesDeTransbordo(
                          _informacionMarcador!.split(':').first),
                    ],
                  ),
                ),
              ),
            // Botones alineados en un Row
            Positioned(
              bottom: 40,
              left: 20,
              child: Row(
                children: [
                  // Botón para seleccionar 2 estaciones
                  FloatingActionButton(
                    onPressed: _activarModoSeleccion,
                    mini: true,
                    backgroundColor:
                        Colors.orange, // Color naranja para el botón
                    child: Image.asset(
                      'assets/direcciones.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 10), // Espacio entre los botones
                  // Botón para borrar la ruta más corta
                  FloatingActionButton(
                    onPressed: _borrarRutaMasCorta,
                    mini: true,
                    backgroundColor:
                        Colors.orange, // Color naranja para el botón
                    child: Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Nueva función para borrar la ruta más corta
  void _borrarRutaMasCorta() {
    setState(() {
      ruta = [];
      _informacionMarcador = null;
    });
  }

  // Función para crear imágenes de transbordo debajo del texto
  Widget _crearImagenesDeTransbordo(String nombreEstacion) {
    if (!estacionesConTransbordo.containsKey(nombreEstacion)) {
      return Container(); // No hay transbordo para esta estación
    }

    final List<String> lineasDeTransbordo =
        estacionesConTransbordo[nombreEstacion]!;

    return Row(
      children: lineasDeTransbordo.map((linea) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Image.asset(
            'assets/$linea.png',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        );
      }).toList(),
    );
  }

  // Función para centrar el mapa en una estación específica y mostrar su información
  void _centrarMapaEnEstacion(LatLng estacion, String nombreEstacion) {
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(estacion, 16.0),
      //Cierre menu y que directamente valla a la estacion
    );
    _mostrarInfo(nombreEstacion, ' $nombreEstacion');
  }

  // Función para mostrar el selector de estaciones de una línea
  void _mostrarSelectorDeEstaciones(BuildContext context, String linea,
      List<MapEntry<String, LatLng>> estaciones, Color colorIcon) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecciona una estación de la $linea',
              textAlign: TextAlign.center),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: estaciones.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: Icon(Icons.train,
                      color:
                          colorIcon), // Ícono del tren con el color de la línea
                  title: Text(estaciones[index].key),
                  onTap: () {
                    if (seleccionandoEstaciones) {
                      _seleccionarEstacion(estaciones[index].key);
                    } else {
                      _centrarMapaEnEstacion(
                          estaciones[index].value, estaciones[index].key);
                    }
                    Navigator.pop(context);
                    Navigator.of(context).pop(); // Cerrar el diálogo
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}