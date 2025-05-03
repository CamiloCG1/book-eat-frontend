import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  Future<void> _registroUsuario() async {
    final url = Uri.parse('http://localhost:8862/usuarios');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'usuario': _usuarioController.text,
        'correo': _correoController.text,
        'contrasena': _contrasenaController.text,
      }),
    );

    if (response.statusCode == 200) {
      // Registro exitoso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso')),
      );
      Navigator.pop(context);
    } else {
      // Error en el registro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar usuario')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usuarioController,
              decoration: const InputDecoration(labelText: 'Nombre de usuario'),
            ),
            TextField(
              controller: _correoController,
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _contrasenaController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registroUsuario,
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
