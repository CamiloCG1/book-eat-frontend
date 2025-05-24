import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'restaurantes.dart';
import 'session.dart';

class MemoriaCorreos {
  static List<String> correos = [];
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // No hay carga porque está en memoria y se mantiene viva mientras la app esté abierta
  }

  Future<void> _guardarCorreoEnMemoria(String correo) async {
    if (!MemoriaCorreos.correos.contains(correo)) {
      MemoriaCorreos.correos.add(correo);
    }
  }

  Future<void> _iniciarSesion() async {
    final url = Uri.parse('http://localhost:8862/usuarios/autenticacion');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'correo': _correoController.text,
        'contrasena': _contrasenaController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Session.usuarioId = data['id'];

      await _guardarCorreoEnMemoria(_correoController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicio de sesión exitoso')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RestaurantesScreen()),
      );
    } else if (response.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o contraseña incorrectos')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error desconocido, intente de nuevo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),

              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return MemoriaCorreos.correos.where((String option) {
                    return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  _correoController.text = selection;
                },
                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                  controller.text = _correoController.text;
                  controller.selection = _correoController.selection;
                  controller.addListener(() {
                    _correoController.text = controller.text;
                    _correoController.selection = controller.selection;
                  });
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  );
                },
              ),

              const SizedBox(height: 20),
              TextField(
                controller: _contrasenaController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _iniciarSesion,
                child: const Text('Iniciar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
