import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class RemoveDriverScreen extends StatefulWidget {
  const RemoveDriverScreen({super.key});

  @override
  RemoveDriverScreenState createState() => RemoveDriverScreenState();
}

class RemoveDriverScreenState extends State<RemoveDriverScreen> {
  final TextEditingController _curpController = TextEditingController();
  final TextEditingController _employeeNumberController = TextEditingController();

  Map<String, dynamic>? conductorData;
  String? _curpError;
  String? _errorMessage;

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

  // Función para identificar al conductor
  Future<void> _identificarConductor() async {
    String curp = _curpController.text;
    String numeroEmpleado = _employeeNumberController.text;

    if (curp.isEmpty || numeroEmpleado.isEmpty) {
      _showErrorMessage('Por favor, llena ambos campos');
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('conductores')
          .where('curp', isEqualTo: curp)
          .where('numeroEmpleado', isEqualTo: numeroEmpleado)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          conductorData = querySnapshot.docs.first.data() as Map<String, dynamic>;
          _errorMessage = null;
        });
      } else {
        setState(() {
          conductorData = null;
        });
        _showErrorMessage('Conductor no encontrado');
      }
    } catch (e) {
      _showErrorMessage('Error al buscar conductor: $e');
    }
  }

  // Función para mostrar mensaje de error en contenedor rojo
  void _showErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  // Función para dar de baja al conductor
  Future<void> _darDeBajaConductor() async {
    if (conductorData == null) return;

    String curp = _curpController.text;
    String numeroEmpleado = _employeeNumberController.text;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('conductores')
          .where('curp', isEqualTo: curp)
          .where('numeroEmpleado', isEqualTo: numeroEmpleado)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();

        _showErrorMessage('Conductor inhabilitado correctamente');

        setState(() {
          conductorData = null;
        });
        _curpController.clear();
        _employeeNumberController.clear();

        // Regresar a admin_screen.dart después de 3 segundos
        Future.delayed(Duration(seconds: 3), () {
          Navigator.pushReplacementNamed(context, '/admin_screen');
        });
      }
    } catch (e) {
      _showErrorMessage('Error al dar de baja conductor: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        title: const Text(
          'Deshabilitar Conductor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              // Implementar aquí el diálogo de confirmación
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red[700]!, Colors.red[200]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - kToolbarHeight - 24,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Icon(Icons.person_remove, size: 120, color: Colors.white),
                      const SizedBox(height: 20),
                      _CustomTextField(
                        label: 'Número de empleado',
                        icon: Icons.badge,
                        controller: _employeeNumberController,
                      ),
                      const SizedBox(height: 20),
                      _CustomTextField(
                        label: 'CURP',
                        icon: Icons.badge,
                        controller: _curpController,
                        errorText: _curpError,
                        onChanged: (value) => _validateCurp(value),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _identificarConductor,
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
                      const SizedBox(height: 20),
                      if (conductorData != null) ...[
                        const Divider(color: Colors.white70),
                        const Text(
                          'Datos del Conductor:',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        _buildInfoRow('Nombre: ', conductorData!['nombre'] ?? 'N/A'),
                        _buildInfoRow('Apellido Paterno: ', conductorData!['apellidoPaterno'] ?? 'N/A'),
                        _buildInfoRow('Apellido Materno: ', conductorData!['apellidoMaterno'] ?? 'N/A'),
                        _buildInfoRow('Número de empleado: ', conductorData!['numeroEmpleado'] ?? 'N/A'),
                        _buildInfoRow('CURP: ', conductorData!['curp'] ?? 'N/A'),
                        _buildInfoRow('Correo: ', conductorData!['correo'] ?? 'N/A'),
                        _buildInfoRow('Teléfono: ', conductorData!['telefono'] ?? 'N/A'),
                        _buildInfoRow('Línea Asignada: ', conductorData!['lineaAsignada'] ?? 'N/A'),
                        _buildInfoRow('Turno de Trabajo: ', conductorData!['turnoTrabajo'] ?? 'N/A'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _darDeBajaConductor,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Dar de Baja',
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (_errorMessage != null)
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[700],
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ],
    );
  }
}

// Widget reutilizable para los campos de texto
class _CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final String? errorText;
  final Function(String)? onChanged;
  final Function()? onTap;
  final bool readOnly;

  const _CustomTextField({
    required this.label,
    required this.icon,
    this.controller,
    this.errorText,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.black87, size: 30),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            onTap: onTap,
            readOnly: readOnly,
            decoration: InputDecoration(
              labelText: label,
              errorText: errorText,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.white,
              labelStyle: const TextStyle(color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}
