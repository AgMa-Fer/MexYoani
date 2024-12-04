// stations.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

//Línea 1
final List<MapEntry<String, LatLng>> lineStations = [
  MapEntry("Pantitlán", LatLng(19.415351498671384, -99.07437711948525)),
  MapEntry("Zaragoza", LatLng(19.412239357993922, -99.08259672398522)),
  MapEntry("Gómez Farías", LatLng(19.416598558132716, -99.09027332639185)),
  MapEntry(
      "Boulevard Puerto Aéreo", LatLng(19.419877193568414, -99.09612790305032)),
  MapEntry("Balbuena", LatLng(19.423233127670795, -99.10269075244707)),
  MapEntry("Moctezuma", LatLng(19.426987181115713, -99.10984876077056)),
  MapEntry("San Lázaro", LatLng(19.43135210465258, -99.11420329944875)),
  MapEntry("Candelaria", LatLng(19.429723142033787, -99.12097319459068)),
  MapEntry("Merced", LatLng(19.425665902541382, -99.12506203525676)),
  MapEntry("Pino Suárez", LatLng(19.42607982447942, -99.13267178277351)),
  MapEntry(
      "Isabel la Católica", LatLng(19.426726432496093, -99.13776863249403)),
  MapEntry("Salto del Agua", LatLng(19.427346746256433, -99.14209228982031)),
  MapEntry("Balderas", LatLng(19.42746288023911, -99.1489288227407)),
  MapEntry("Cuauhtémoc", LatLng(19.42589458704645, -99.1544327153046)),
  MapEntry("Insurgentes", LatLng(19.42396858217946, -99.16301374783575)),
  MapEntry("Sevilla", LatLng(19.421799062006926, -99.17108563139494)),
  MapEntry("Chapultepec", LatLng(19.42078850124916, -99.1769386319353)),
  MapEntry("Juanacatlán", LatLng(19.413135553653905, -99.18180667954424)),
  MapEntry("Tacubaya", LatLng(19.402050919301157, -99.18735662205182)),
  MapEntry("Observatorio", LatLng(19.39903285585087, -99.20035708831745)),

//Linea 2

  MapEntry("Cuatro Caminos", LatLng(19.459525637846248, -99.21583798989766)),
  MapEntry("Panteones", LatLng(19.458746706008235, -99.20296338661313)),
  MapEntry("Tacuba", LatLng(19.459232274342614, -99.18753532090959)),
  MapEntry("Cuitláhuac", LatLng(19.45741524606002, -99.18148225223777)),
  MapEntry("Popotla", LatLng(19.45293604859668, -99.17543531917897)),
  MapEntry("Colegio Militar", LatLng(19.449375684299504, -99.17181134375284)),
  MapEntry("Normal", LatLng(19.444790212551286, -99.16740362641656)),
  MapEntry("San Cosme", LatLng(19.44200076091255, -99.16075235991168)),
  MapEntry("Revolución", LatLng(19.439360970234247, -99.15425078709455)),
  MapEntry("Hidalgo", LatLng(19.437626299762638, -99.14716961225092)),
  MapEntry("Bellas Artes", LatLng(19.436542284567956, -99.14161937670347)),
  MapEntry("Allende", LatLng(19.435707776057946, -99.13684332050549)),
  MapEntry(
      "Zócalo Tenochtitlan", LatLng(19.432502697172275, -99.13233697958958)),
  MapEntry("Pino Suárez", LatLng(19.42458692516335, -99.13292102956223)),
  MapEntry("San Antonio Abad", LatLng(19.416026743885926, -99.13459472797464)),
  MapEntry("Chabacano", LatLng(19.409086021036774, -99.13565726341629)),
  MapEntry("Viaducto", LatLng(19.40086824865009, -99.13691215649861)),
  MapEntry("Xola", LatLng(19.395370588105376, -99.13779388151433)),
  MapEntry("Villa de Cortés", LatLng(19.387808012409966, -99.13897023884594)),
  MapEntry("Nativitas", LatLng(19.379774906725416, -99.14020320724379)),
  MapEntry("Portales", LatLng(19.370038272860576, -99.1416086846933)),
  MapEntry("Ermita", LatLng(19.361413958721666, -99.14300906826098)),
  MapEntry("General Anaya", LatLng(19.3535894236359, -99.14511841975529)),
  MapEntry("Tasqueña", LatLng(19.343262687528487, -99.13965626915771)),

//Linea 3

  MapEntry("Indios Verdes", LatLng(19.495203276559163, -99.11963079688945)),
  MapEntry(
      "Deportivo 18 de Marzo", LatLng(19.48506898611646, -99.12547801253845)),
  MapEntry("Potrero", LatLng(19.47717957833783, -99.13203333140738)),
  MapEntry("La Raza", LatLng(19.470665251345654, -99.13745837913474)),
  MapEntry("Tlatelolco", LatLng(19.45499028080833, -99.14327642027048)),
  MapEntry("Guerrero", LatLng(19.444715576739732, -99.14515242302312)),
  MapEntry("Hidalgo", LatLng(19.437551768487427, -99.14715716644474)),
  MapEntry("Juárez", LatLng(19.433257364195157, -99.14767576801704)),
  MapEntry("Balderas", LatLng(19.42721480988917, -99.14893869117569)),
  MapEntry("Niños Héroes", LatLng(19.4194393896254, -99.15038079436934)),
  MapEntry("Hospital General", LatLng(19.41377658406791, -99.15331478591511)),
  MapEntry("Centro Médico", LatLng(19.406553196707687, -99.15523989510709)),
  MapEntry("Etiopía", LatLng(19.395931563629727, -99.15602046213509)),
  MapEntry("Eugenia", LatLng(19.386170243957615, -99.15719818211949)),
  MapEntry("División del Norte", LatLng(19.37919325369598, -99.15949878526094)),
  MapEntry("Zapata", LatLng(19.37069806741976, -99.1650228982572)),
  MapEntry("Coyoacán", LatLng(19.361311336434795, -99.17088590732868)),
  MapEntry("Viveros", LatLng(19.35401676774263, -99.17540038859259)),
  MapEntry("Miguel Ángel de Quevedo",
      LatLng(19.346349819432508, -99.18074020747102)),
  MapEntry("Copilco", LatLng(19.336215952858716, -99.17706310381831)),
  MapEntry("Universidad", LatLng(19.324415499468298, -99.17390658484527)),

//Linea 4

  MapEntry("Martín Carrera", LatLng(19.48503441246483, -99.10440643962394)),
  MapEntry("Talismán", LatLng(19.474329733069055, -99.10803293923703)),
  MapEntry("Bondojito", LatLng(19.464599702959646, -99.11196822078703)),
  MapEntry("Consulado", LatLng(19.45795648195311, -99.11384089616321)),
  MapEntry("Canal del Norte", LatLng(19.448818185799286, -99.11590883048792)),
  MapEntry("Morelos", LatLng(19.439664410156784, -99.11813143114863)),
  MapEntry("Candelaria", LatLng(19.42818229289537, -99.11965829159158)),
  MapEntry("Fray Servando", LatLng(19.42161591372167, -99.12055157162942)),
  MapEntry("Jamaica", LatLng(19.410971223404374, -99.12172789220085)),
  MapEntry("Santa Anita", LatLng(19.404151346024953, -99.12072482940322)),

//Linea 5 

  MapEntry("Politécnico", LatLng(19.500728097403062, -99.14920864519907)),
  MapEntry(
      "Instituto del Petróleo", LatLng(19.489297300065555, -99.14471910208975)),
  MapEntry(
      "Autobuses del Norte", LatLng(19.479004210628062, -99.14062060829903)),
  MapEntry("La Raza", LatLng(19.46967150917847, -99.1365033442921)),
  MapEntry("Misterios", LatLng(19.46313445746586, -99.13039363761116)),
  MapEntry("Valle Gómez", LatLng(19.458911970809286, -99.1194976158625)),
  MapEntry("Consulado", LatLng(19.45535104195718, -99.11343785249115)),
  MapEntry("Eduardo Molina", LatLng(19.451429117656822, -99.1053870449156)),
  MapEntry("Aragón", LatLng(19.451236628102606, -99.09620070277366)),
  MapEntry("Oceanía", LatLng(19.444968563214008, -99.08695056700199)),
  MapEntry("Terminal Aérea", LatLng(19.434092114267138, -99.08806058304113)),
  MapEntry("Hangares", LatLng(19.42435803720359, -99.0882902418957)),
  MapEntry("Pantitlán", LatLng(19.415351498671384, -99.07437711948525)),

//Linea 6 

  MapEntry("Rosario", LatLng(19.504816979038754, -99.20005458847595)),
  MapEntry("Tezozómoc", LatLng(19.495068188179804, -99.19612276022885)),
  MapEntry("UAM Azcapotzalco", LatLng(19.4909027643271, -99.18628852298879)),
  MapEntry("Ferrería", LatLng(19.490862148242698, -99.1740856308064)),
  MapEntry("Norte 45", LatLng(19.488960622207415, -99.16315224799003)),
  MapEntry("Vallejo", LatLng(19.489991578868395, -99.15596781731098)),
  MapEntry(
      "Instituto del Petróleo", LatLng(19.491252714057513, -99.14836487315624)),
  MapEntry("Lindavista", LatLng(19.488190895300423, -99.13508073265054)),
  MapEntry(
      "Deportivo 18 de Marzo", LatLng(19.485186379130738, -99.12548981792223)),
  MapEntry("La Villa-Basílica", LatLng(19.481739366701802, -99.1183706708437)),
  MapEntry("Martín Carrera", LatLng(19.48540010074814, -99.10438363758549)),

//Linea 7
  
  MapEntry("Rosario", LatLng(19.50479675274806, -99.20014041915495)),
  MapEntry("Aquiles Serdán", LatLng(19.490690523741076, -99.19532089364772)),
  MapEntry("Camarones", LatLng(19.479161576686103, -99.18979797062053)),
  MapEntry("Refinería", LatLng(19.469677472852293, -99.19005590924493)),
  MapEntry("Tacuba", LatLng(19.459262915540393, -99.18768894237115)),
  MapEntry("San Joaquín", LatLng(19.44514211126248, -99.19169457852146)),
  MapEntry("Polanco", LatLng(19.43383885963916, -99.19123939251085)),
  MapEntry("Auditorio", LatLng(19.42508187577483, -99.1920587272876)),
  MapEntry("Constituyentes", LatLng(19.411716549352242, -99.19123939249751)),
  MapEntry("Tacubaya", LatLng(19.401856412661154, -99.18720341003205)),
  MapEntry(
      "San Pedro de los Pinos", LatLng(19.39141192771089, -99.18583437587628)),
  MapEntry("San Antonio", LatLng(19.384854348300404, -99.18673778879732)),
  MapEntry("Mixcoac", LatLng(19.37623669025047, -99.18777125223724)),
  MapEntry(
      "Barranca del Muerto", LatLng(19.361563958514225, -99.18926403270977)),

//Linea 8 

  MapEntry(
      "Constitución de 1917", LatLng(19.346172642532053, -99.06397077056742)),
  MapEntry("UAM-I", LatLng(19.351096940856724, -99.07515220489113)),
  MapEntry(
      "Cerro de la Estrella", LatLng(19.35629295777897, -99.0856095404725)),
  MapEntry("Iztapalapa", LatLng(19.357942900115994, -99.09326791776228)),
  MapEntry("Atlalilco", LatLng(19.352620575530104, -99.10604226466799)),
  MapEntry("Escuadrón 201", LatLng(19.36484489354835, -99.10932563257651)),
  MapEntry("Aculco", LatLng(19.3733280616867, -99.10765528691941)),
  MapEntry("Apatlaco", LatLng(19.379171132497195, -99.10937994731536)),
  MapEntry("Iztacalco", LatLng(19.388842070594325, -99.11212183548402)),
  MapEntry("Coyuya", LatLng(19.39830371376962, -99.11344148231552)),
  MapEntry("Santa Anita", LatLng(19.404364088194814, -99.12064857793919)),
  MapEntry("La Viga", LatLng(19.406912262114606, -99.12630200398716)),
  MapEntry("Chabacano", LatLng(19.409330745183134, -99.13557574166056)),
  MapEntry("Obrera", LatLng(19.41341438351027, -99.14404280496584)),
  MapEntry("Doctores", LatLng(19.42179257260864, -99.14317913366364)),
  MapEntry("Salto del Agua", LatLng(19.42746063297194, -99.14206333471343)),
  MapEntry("San Juan de Letrán", LatLng(19.43180244972228, -99.14127141249993)),
  MapEntry("Bellas Artes", LatLng(19.43655200883551, -99.14161004138933)),
  MapEntry("Garibaldi", LatLng(19.44407918416027, -99.13863815376487)),

//Linea 9

  MapEntry("Pantitlán", LatLng(19.415351498671384, -99.07437711948525)),
  MapEntry("Puebla", LatLng(19.407256356104245, -99.08237436518422)),
  MapEntry("Ciudad Deportiva", LatLng(19.408566771327326, -99.09128794312933)),
  MapEntry("Velódromo", LatLng(19.408481679748732, -99.1032509024901)),
  MapEntry("Mixiuhca", LatLng(19.408672556374064, -99.11282075844245)),
  MapEntry("Jamaica", LatLng(19.40934921132076, -99.12176925212793)),
  MapEntry("Chabacano", LatLng(19.408105337918133, -99.13578586479684)),
  MapEntry("Lázaro Cárdenas", LatLng(19.407194422770818, -99.14461962648876)),
  MapEntry("Centro Médico", LatLng(19.40659874537824, -99.15517116086079)),
  MapEntry("Chilpancingo", LatLng(19.405895028260975, -99.1685328330824)),
  MapEntry("Patriotismo", LatLng(19.406059268400586, -99.17889783053543)),
  MapEntry("Tacubaya", LatLng(19.40192629925452, -99.187377080922)),

//Linea A

  MapEntry("La Paz", LatLng(19.350622881055255, -98.96076573117712)),
  MapEntry("Los Reyes", LatLng(19.35908602803274, -98.97686581221511)),
  MapEntry("Santa Marta", LatLng(19.360296268884174, -98.99509093404055)),
  MapEntry("Acatitla", LatLng(19.364726296189207, -99.00554974337348)),
  MapEntry("Peñón Viejo", LatLng(19.37329964079993, -99.01706905691495)),
  MapEntry("Guelatao", LatLng(19.385200495677672, -99.03562309635804)),
  MapEntry("Tepalcates", LatLng(19.39130635476298, -99.046326428292)),
  MapEntry("Canal de San Juan", LatLng(19.398765185279363, -99.05941260869987)),
  MapEntry("Agrícola Oriental", LatLng(19.404668196549512, -99.06951383876383)),
  MapEntry("Pantitlán", LatLng(19.415351498671384, -99.07437711948525)),

//Linea B

  MapEntry("Buenavista", LatLng(19.446235172235074, -99.15206628831669)),
  MapEntry("Guerrero", LatLng(19.4449199826273, -99.14521056227166)),
  MapEntry("Garibaldi", LatLng(19.443968992722098, -99.13836556475475)),
  MapEntry("Lagunilla", LatLng(19.443584548415217, -99.13181024590793)),
  MapEntry("Tepito", LatLng(19.443038231248156, -99.12416058579802)),
  MapEntry("Morelos", LatLng(19.43989181328533, -99.11819535295348)),
  MapEntry("San Lázaro", LatLng(19.431381806768943, -99.1141420653729)),
  MapEntry(
      "Ricardo Flores Magón", LatLng(19.4367845835044, -99.10365999274693)),
  MapEntry("Romero Rubio", LatLng(19.44109333190791, -99.09418001787034)),
  MapEntry("Oceanía", LatLng(19.445256723131976, -99.08694153480938)),
  MapEntry("Deportivo Oceanía", LatLng(19.451276145072548, -99.07932406122531)),
  MapEntry("Bosque de Aragón", LatLng(19.45836407645456, -99.06930363738823)),
  MapEntry("Villa de Aragón", LatLng(19.461809068530155, -99.06125296885823)),
  MapEntry("Nezahualcóyotl", LatLng(19.472794488667777, -99.05476202319745)),
  MapEntry(
      "Río de los Remedios", LatLng(19.491300866402646, -99.04654962473701)),
  MapEntry("Impulsora", LatLng(19.48581988865982, -99.04899684179401)),
  MapEntry("Múzquiz", LatLng(19.501724308932104, -99.04199312439115)),
  MapEntry("Ecatepec", LatLng(19.515577414503777, -99.03594535858001)),
  MapEntry("Olímpica", LatLng(19.521523438648668, -99.03333825136586)),
  MapEntry("Plaza Aragón", LatLng(19.528632088551124, -99.03016251588116)),
  MapEntry("Ciudad Azteca", LatLng(19.535022528132902, -99.02767342589961)),

//Linea 12

  MapEntry("Tláhuac", LatLng(19.28588612907294, -99.01402689705961)),
  MapEntry("Tlaltenco", LatLng(19.294367167044523, -99.02400657505814)),
  MapEntry("Zapotitlán", LatLng(19.29672833209648, -99.03430370050137)),
  MapEntry("Nopalera", LatLng(19.299995749537253, -99.04601363989487)),
  MapEntry("Olivos", LatLng(19.304372407129645, -99.0595018806687)),
  MapEntry("Tezonco", LatLng(19.30634926080463, -99.06517792747282)),
  MapEntry(
      "Periférico Oriente", LatLng(19.317602126802385, -99.07451598491755)),
  MapEntry("Calle 11", LatLng(19.320499157075886, -99.08590100861214)),
  MapEntry("Lomas Estrella", LatLng(19.32216591941258, -99.09582302100618)),
  MapEntry(
      "San Andrés Tomatlán", LatLng(19.328152522124615, -99.10450485330635)),
  MapEntry("Culhuacán", LatLng(19.336918178100344, -99.10894112054478)),
  MapEntry("Atlalilco", LatLng(19.352620575530104, -99.10604226466799)),
  MapEntry("Mexicaltzingo", LatLng(19.357808027216453, -99.12304462054112)),
  MapEntry("Ermita", LatLng(19.359883622787756, -99.14315346245125)),
  MapEntry("Eje Central", LatLng(19.36135697543238, -99.15143727941877)),
  MapEntry(
      "Parque de los Venados", LatLng(19.37065373258711, -99.1587312617491)),
  MapEntry("Zapata", LatLng(19.370820545851746, -99.16527536767708)),
  MapEntry("Hospital 20 de Noviembre",
      LatLng(19.371940811710267, -99.17109772135039)),
  MapEntry("Insurgentes Sur", LatLng(19.37356083830467, -99.17870187296606)),
  MapEntry("Mixcoac", LatLng(19.376144566970716, -99.18779897139657)),
];