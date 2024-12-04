import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class EditDriverScreen extends StatefulWidget {
  const EditDriverScreen({super.key});

  @override
  EditDriverScreenState createState() => EditDriverScreenState();
}

class EditDriverScreenState extends State<EditDriverScreen> {
  final TextEditingController _curpController = TextEditingController();
  final TextEditingController _employeeNumberController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _workShiftController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNamePController = TextEditingController();
  final TextEditingController _lastNameMController = TextEditingController();
  String? selectedLine;

  String? uid;
  String? _curpError;
  String? _phoneError;
  String? _errorMessage;

  final List<String> metroLines = [
    'Línea 1',
    'Línea 2',
    'Línea 3',
    'Línea 4',
    'Línea 5',
    'Línea 6',
    'Línea 7',
    'Línea 8',
    'Línea 9',
    'Línea 12',
    'Línea A',
    'Línea B',
  ];

  // Validación de CURP
  void _validateCurp(String value) {
    RegExp curpRegex = RegExp(r'^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z\d]{2}$');
    setState(() {
      if (value.isEmpty || !curpRegex.hasMatch(value)) {
        _curpError = 'CURP no válida';
      } else {
        _curpError = null;
      }
    });
  }

  // Validación de teléfono
  void _validatePhone(String value) {
    RegExp phoneRegex = RegExp(r'^\d{10}$');
    setState(() {
      if (value.isEmpty || !phoneRegex.hasMatch(value)) {
        _phoneError = 'El número debe tener 10 dígitos';
      } else {
        _phoneError = null;
      }
    });
  }

  // Función para mostrar un mensaje de error en la parte inferior
  void _showErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  // Función para buscar al conductor en Firestore y cargar los datos correctos
  Future<void> _buscarConductor() async {
    String curp = _curpController.text;
    String numeroEmpleado = _employeeNumberController.text;

    if (curp.isEmpty || numeroEmpleado.isEmpty) {
      _showErrorMessage('Por favor, completa ambos campos');
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('conductores')
          .where('curp', isEqualTo: curp)
          .where('numeroEmpleado', isEqualTo: numeroEmpleado)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var conductorData = querySnapshot.docs.first.data() as Map<String, dynamic>;

        setState(() {
          uid = conductorData['uid'];
          _nameController.text = conductorData['nombre'] ?? '';
          _lastNamePController.text = conductorData['apellidoPaterno'] ?? '';
          _lastNameMController.text = conductorData['apellidoMaterno'] ?? '';
          _phoneController.text = conductorData['telefono'] ?? '';
          _emailController.text = conductorData['correo'] ?? '';
          _workShiftController.text = conductorData['turnoTrabajo'] ?? '';
          selectedLine = conductorData['lineaAsignada'] ?? '';
          _errorMessage = null;
        });
      } else {
        _showErrorMessage('Conductor no encontrado');
      }
    } catch (e) {
      _showErrorMessage('Error al buscar conductor: $e');
    }
  }

  // Función para guardar los cambios en Firestore
  Future<void> _guardarCambios() async {
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection('conductores').doc(uid).update({
        'nombre': _nameController.text,
        'apellidoPaterno': _lastNamePController.text,
        'apellidoMaterno': _lastNameMController.text,
        'telefono': _phoneController.text,
        'correo': _emailController.text,
        'turnoTrabajo': _workShiftController.text,
        'lineaAsignada': selectedLine,
      });

      _showErrorMessage('Datos del conductor actualizados correctamente');

      // Regresar a admin_screen.dart después de 3 segundos
      Timer(const Duration(seconds: 3), () {
        Navigator.pushNamed(context, '/admin_screen');
      });
    } catch (e) {
      _showErrorMessage('Error al actualizar los datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Modificar Datos Conductor',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.blue[200]!],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const Icon(
                        Icons.edit,
                        size: 90,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      _CustomTextField(
                        label: 'Número de empleado',
                        icon: Icons.badge,
                        controller: _employeeNumberController,
                        isEditable: true,
                      ),
                      const SizedBox(height: 15),
                      _CustomTextField(
                        label: 'CURP',
                        icon: Icons.badge,
                        controller: _curpController,
                        errorText: _curpError,
                        onChanged: (value) => _validateCurp(value),
                        isEditable: true,
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: _buscarConductor,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Identificar Conductor',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (uid != null) ...[
                        _CustomTextField(
                          label: 'Nombre(s)',
                          icon: Icons.person,
                          controller: _nameController,
                        ),
                        const SizedBox(height: 15),
                        _CustomTextField(
                          label: 'Apellido Paterno',
                          icon: Icons.person,
                          controller: _lastNamePController,
                        ),
                        const SizedBox(height: 15),
                        _CustomTextField(
                          label: 'Apellido Materno',
                          icon: Icons.person,
                          controller: _lastNameMController,
                        ),
                        const SizedBox(height: 15),
                        _CustomTextField(
                          label: 'Correo electrónico',
                          icon: Icons.email,
                          controller: _emailController,
                        ),
                        const SizedBox(height: 15),
                        _CustomTextField(
                          label: 'Teléfono de contacto',
                          icon: Icons.phone,
                          controller: _phoneController,
                          errorText: _phoneError,
                          onChanged: (value) => _validatePhone(value),
                        ),
                        const SizedBox(height: 15),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Estación base o asignada',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                          value: selectedLine,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedLine = newValue;
                            });
                          },
                          items: metroLines.map((String line) {
                            return DropdownMenuItem<String>(
                              value: line,
                              child: Row(
                                children: [
                                  const Icon(Icons.train, size: 20),
                                  const SizedBox(width: 8),
                                  Text(line),
                                ],
                              ),
                            );
                          }).toList(),
                          style: const TextStyle(color: Colors.black),
                          dropdownColor: Colors.white,
                          isExpanded: true,
                        ),
                        const SizedBox(height: 15),
                        _CustomTextField(
                          label: 'Turno de trabajo',
                          icon: Icons.access_time,
                          controller: _workShiftController,
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: ElevatedButton(
                            onPressed: _guardarCambios,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Guardar Cambios',
                              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ],
                  ),
                ),
              ),
              if (_errorMessage != null) // Mostrar mensaje de error en la parte inferior
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[700],
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget reutilizable para los campos de texto, con opción de hacerlo no editable
class _CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final String? errorText;
  final Function(String)? onChanged;
  final Function()? onTap;
  final bool readOnly;
  final bool isEditable;

  const _CustomTextField({
    required this.label,
    required this.icon,
    this.controller,
    this.errorText,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: isEditable,
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: label,
        errorText: errorText,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.deepPurple),
          borderRadius: BorderRadius.circular(12),
        ),
        fillColor: isEditable ? Colors.grey[200] : Colors.grey[300],
        filled: true,
      ),
    );
  }
}
