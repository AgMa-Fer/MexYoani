import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'admin_screen.dart';
import 'package:prueba/main.dart';

class AdminNoticias extends StatefulWidget {
  static String id = 'admin_noticias';

  const AdminNoticias({super.key});

  @override
  State<AdminNoticias> createState() => _AdminNoticiasState();
}

class _AdminNoticiasState extends State<AdminNoticias> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  String _tipoNoticia = 'Verde';
  String _lineaSeleccionada = 'Línea 1';
  TimeOfDay _horaSeleccionada = TimeOfDay.now();

  final Map<String, Color> metroLineColors = {
    'Línea 1': Color.fromARGB(255, 255, 0, 128),
    'Línea 2': Color.fromARGB(255, 0, 100, 164),
    'Línea 3': Color.fromARGB(255, 132, 186, 144),
    'Línea 4': Color.fromARGB(255, 0, 204, 204),
    'Línea 5': Color.fromARGB(255, 251, 255, 0),
    'Línea 6': Color.fromARGB(255, 235, 3, 3),
    'Línea 7': Color.fromARGB(255, 255, 128, 0),
    'Línea 8': Color.fromARGB(255, 26, 142, 53),
    'Línea 9': Color.fromARGB(255, 102, 51, 0),
    'Línea 12': Color.fromARGB(255, 204, 153, 0),
    'Línea A': Color.fromARGB(255, 71, 0, 153),
    'Línea B': Color.fromARGB(255, 153, 153, 153),
  };

  Future<void> _seleccionarHora(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada,
    );
    if (picked != null && picked != _horaSeleccionada) {
      setState(() {
        _horaSeleccionada = picked;
      });
    }
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _fechaController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _agregarNoticia() async {
    final String titulo = _tituloController.text;
    final String descripcion = _descripcionController.text;
    final String tipoNoticia = _tipoNoticia;
    final String lineaSeleccionada = _lineaSeleccionada;
    final String horaSeleccionada = _horaSeleccionada.format(context);
    final String fechaSeleccionada = _fechaController.text;

    if (titulo.isEmpty || descripcion.isEmpty || fechaSeleccionada.isEmpty || horaSeleccionada.isEmpty) {
      _mostrarErrorToast('Por favor, complete todos los campos');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('Noticias').add({
        'Titulo': titulo,
        'Descripcion': descripcion,
        'Tipo de Noticia': tipoNoticia,
        'Linea del Metro': lineaSeleccionada,
        'Hora de la Noticia': horaSeleccionada,
        'Fecha': fechaSeleccionada,
        'Creado': DateTime.now(),
      });

      _mostrarExitoToast();

      _tituloController.clear();
      _descripcionController.clear();
      _fechaController.clear();
      setState(() {
        _tipoNoticia = 'Verde';
        _lineaSeleccionada = 'Línea 1';
        _horaSeleccionada = TimeOfDay.now();
      });

      Future.delayed(Duration(seconds: 5), () {
        Navigator.pushReplacementNamed(context, AdminScreen.id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar la noticia: $e')),
      );
    }
  }

  void _mostrarExitoToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¡Noticia Agregada Correctamente!',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Icon(Icons.check_circle, color: Colors.white, size: 24),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
          
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
              '¿Está seguro de regresar al menú principal?',
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
                    color: Colors.red[700],
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
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
                    MaterialPageRoute(builder: (context) => MyApp()),
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
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
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
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Center(
          child: Text(
            'Crear Noticia',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AdminScreen.id); // Regresa a admin_screen.dart
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepOrange, Colors.orangeAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(
                  Icons.announcement,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _buildLabel('Título'),
              _buildTextField(_tituloController, 'Ingrese el título de la noticia'),
              const SizedBox(height: 20),
              _buildLabel('Descripción'),
              _buildTextField(_descripcionController, 'Ingrese la descripción del problema', maxLines: 3),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Tipo de Noticia'),
                        _buildDropdown(
                          value: _tipoNoticia,
                          items: ['Verde', 'Amarillo', 'Rojo'],
                          onChanged: (newValue) => setState(() {
                            _tipoNoticia = newValue!;
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Línea del Metro'),
                        _buildMetroLineDropdown(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildLabel('Fecha de la Noticia'),
              _buildTextField(
                _fechaController,
                'Seleccione la fecha',
                readOnly: true,
                onTap: () => _seleccionarFecha(context),
              ),
              const SizedBox(height: 20),
              _buildLabel('Hora de la Noticia'),
              Text(
                'Hora seleccionada: ${_horaSeleccionada.format(context)}',
                style: TextStyle(color: Colors.black87, fontSize: 18),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _seleccionarHora(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Seleccionar Hora',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _agregarNoticia,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Agregar Noticia',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {int maxLines = 1, bool readOnly = false, VoidCallback? onTap}) {
    return Row(
      children: [
        const Icon(Icons.edit, color: Colors.black87),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.black38),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetroLineDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
      ),
      child: DropdownButton<String>(
        value: _lineaSeleccionada,
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down, color: Colors.orange.shade700),
        style: TextStyle(color: Colors.black87, fontSize: 18),
        underline: SizedBox(),
        onChanged: (String? newValue) {
          setState(() {
            _lineaSeleccionada = newValue!;
          });
        },
        items: metroLineColors.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Row(
              children: [
                Icon(Icons.train, color: entry.value),
                SizedBox(width: 8),
                Text(entry.key),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down, color: Colors.orange.shade700),
        style: TextStyle(color: Colors.black87, fontSize: 18),
        underline: SizedBox(),
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Row(
              children: [
                Icon(
                  value == 'Verde'
                      ? Icons.check_circle
                      : value == 'Amarillo'
                          ? Icons.warning
                          : Icons.report,
                  color: value == 'Verde'
                      ? Colors.green
                      : value == 'Amarillo'
                          ? Colors.yellow
                          : Colors.red,
                ),
                SizedBox(width: 8),
                Text(value),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
