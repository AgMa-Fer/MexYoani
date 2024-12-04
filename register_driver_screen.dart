import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';

class RegisterDriverScreen extends StatefulWidget {
  const RegisterDriverScreen({super.key});

  @override
  RegisterDriverScreenState createState() => RegisterDriverScreenState();
}

class RegisterDriverScreenState extends State<RegisterDriverScreen> {
  final TextEditingController _curpController = TextEditingController();
  final TextEditingController _employeeNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _workShiftController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNamePController = TextEditingController();
  final TextEditingController _lastNameMController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  String? _curpError;
  String? _phoneError;
  String? _emailError;
  String? _passwordError;
  String? _errorMessage;

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

  void _validateEmail(String value) {
    RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    setState(() {
      if (value.isEmpty || !emailRegex.hasMatch(value)) {
        _emailError = 'Correo electrónico no válido';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty || value.length < 6) {
        _passwordError = 'La contraseña debe tener al menos 6 caracteres';
      } else {
        _passwordError = null;
      }
    });
  }

  void _showErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  Future<void> _registerDriver(BuildContext context) async {
    if (_curpController.text.isEmpty ||
        _employeeNumberController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        selectedLine == null ||
        _workShiftController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _lastNamePController.text.isEmpty ||
        _lastNameMController.text.isEmpty) {
      _showErrorMessage('Por favor, completa todos los campos');
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final random = Random();
      final latitude = (random.nextDouble() * 180 - 90).toStringAsFixed(5);
      final longitude = (random.nextDouble() * 360 - 180).toStringAsFixed(5);
      final randomCoordinate = '$latitude,$longitude';

      await FirebaseFirestore.instance.collection('conductores').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'nombre': _nameController.text,
        'apellidoPaterno': _lastNamePController.text,
        'apellidoMaterno': _lastNameMController.text,
        'curp': _curpController.text,
        'numeroEmpleado': _employeeNumberController.text,
        'correo': _emailController.text,
        'telefono': _phoneController.text,
        'lineaAsignada': selectedLine,
        'turnoTrabajo': _workShiftController.text,
      });

      await FirebaseFirestore.instance.collection('coordenadas').doc(userCredential.user!.uid).set({
        'coordenada': randomCoordinate,
        'linea': selectedLine,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conductor registrado correctamente')),
      );

      // Limpiar los campos
      _nameController.clear();
      _lastNamePController.clear();
      _lastNameMController.clear();
      _curpController.clear();
      _employeeNumberController.clear();
      _emailController.clear();
      _passwordController.clear();
      _phoneController.clear();
      _workShiftController.clear();
      setState(() {
        selectedLine = null;
      });

      // Redirigir a admin_screen.dart después de 3 segundos
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacementNamed(context, '/admin_screen');
      });
    } catch (e) {
      _showErrorMessage('Error al registrar conductor: $e');
    }
  }

  Future<void> _selectWorkShift(BuildContext context, bool isEntrada) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isEntrada) {
          _workShiftController.text = 'Entrada: ${picked.format(context)}';
        } else {
          _workShiftController.text += ' - Salida: ${picked.format(context)}';
        }
      });
    }
  }

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

  final Map<String, Color> metroLineColors = {
    'Línea 1': Color.fromARGB(255, 255, 0, 128),
    'Línea 2': Color.fromARGB(255, 0, 100, 164),
    'Línea 3': Color.fromARGB(255, 132, 186, 144),
    'Línea 4': Color.fromARGB(255, 0, 204, 204),
    'Línea 5': Color.fromARGB(255, 242, 255, 0),
    'Línea 6': Color.fromARGB(255, 245, 4, 4),
    'Línea 7': Color.fromARGB(255, 255, 128, 0),
    'Línea 8': Color.fromARGB(255, 0, 153, 64),
    'Línea 9': Color.fromARGB(255, 102, 51, 0),
    'Línea 12': Color.fromARGB(255, 204, 153, 0),
    'Línea A': Color.fromARGB(255, 79, 6, 128),
    'Línea B': Color.fromARGB(255, 153, 153, 153),
  };

  String? selectedLine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Registrar Conductor',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[700]!, Colors.green[200]!],
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
                        Icons.person_add,
                        size: 90,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      _CustomTextField(
                          label: 'Nombre(s)',
                          icon: Icons.person,
                          controller: _nameController),
                      const SizedBox(height: 15),
                      _CustomTextField(
                          label: 'Apellido paterno',
                          icon: Icons.person,
                          controller: _lastNamePController),
                      const SizedBox(height: 15),
                      _CustomTextField(
                          label: 'Apellido materno',
                          icon: Icons.person,
                          controller: _lastNameMController),
                      const SizedBox(height: 20),
                      _CustomTextField(
                        label: 'CURP',
                        icon: Icons.badge,
                        controller: _curpController,
                        errorText: _curpError,
                        onChanged: (value) => _validateCurp(value),
                      ),
                      const SizedBox(height: 15),
                      _CustomTextField(
                        label: 'Número de empleado',
                        icon: Icons.badge,
                        controller: _employeeNumberController,
                      ),
                      const SizedBox(height: 15),
                      _CustomTextField(
                        label: 'Correo electrónico',
                        icon: Icons.email,
                        controller: _emailController,
                        errorText: _emailError,
                        onChanged: (value) => _validateEmail(value),
                      ),
                      const SizedBox(height: 15),
                      _CustomTextField(
                        label: 'Contraseña',
                        icon: Icons.lock,
                        controller: _passwordController,
                        errorText: _passwordError,
                        onChanged: (value) => _validatePassword(value),
                        obscureText: true,
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
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: DropdownButtonFormField<String>(
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
                                  Icon(
                                    Icons.train,
                                    size: 20,
                                    color: metroLineColors[line],
                                  ),
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
                      ),
                      const SizedBox(height: 15),
                      _CustomTextField(
                        label: 'Hora de entrada',
                        icon: Icons.access_time,
                        controller: _workShiftController,
                        onTap: () => _selectWorkShift(context, true),
                        readOnly: true,
                      ),
                      const SizedBox(height: 15),
                      _CustomTextField(
                        label: 'Hora de salida',
                        icon: Icons.access_time,
                        controller: _workShiftController,
                        onTap: () => _selectWorkShift(context, false),
                        readOnly: true,
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: GestureDetector(
                          onTap: () async {
                            await _registerDriver(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.green[700],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'Registrar Conductor',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
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

class _CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final String? errorText;
  final Function(String)? onChanged;
  final Function()? onTap;
  final bool readOnly;
  final bool obscureText;

  const _CustomTextField({
    required this.label,
    required this.icon,
    this.controller,
    this.errorText,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.black87),
        SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            onTap: onTap,
            readOnly: readOnly,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: label,
              errorText: errorText,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.deepPurple),
                borderRadius: BorderRadius.circular(12),
              ),
              fillColor: Colors.grey[200],
              filled: true,
            ),
          ),
        ),
      ],
    );
  }
}
