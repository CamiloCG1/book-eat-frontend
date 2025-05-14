import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'session.dart'; // Asegúrate de importar tu clase Session

class ResenasScreen extends StatefulWidget {
  final int restauranteId;

  const ResenasScreen({super.key, required this.restauranteId});

  @override
  State<ResenasScreen> createState() => _ResenasScreenState();
}

class _ResenasScreenState extends State<ResenasScreen> {
  List<dynamic> _resenas = [];
  bool _cargando = true;
  final TextEditingController _comentarioController = TextEditingController();
  int _puntuacion = 5; // Por defecto 5 estrellas

  @override
  void initState() {
    super.initState();
    _cargarResenas();
  }

  Future<void> _cargarResenas() async {
    final url = Uri.parse('http://localhost:8862/resenas/restaurante/${widget.restauranteId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _resenas = json.decode(utf8.decode(response.bodyBytes));
        _cargando = false;
      });
    } else {
      setState(() {
        _cargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron cargar las reseñas')),
      );
    }
  }

  Future<void> _enviarResena() async {
    final comentario = _comentarioController.text.trim();
    if (comentario.isEmpty || _puntuacion < 1 || _puntuacion > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor escribe un comentario y selecciona una puntuación')),
      );
      return;
    }

    final resena = {
      "usuarioId": Session.usuarioId,
      "restauranteId": widget.restauranteId,
      "calificacion": _puntuacion,
      "comentario": comentario,
    };

    final response = await http.post(
      Uri.parse('http://localhost:8862/resenas'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(resena),
    );

    if (response.statusCode == 200) {
      _comentarioController.clear();
      setState(() {
        _puntuacion = 5;
      });
      await _cargarResenas();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reseña enviada con éxito')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al enviar la reseña')),
      );
    }
  }

  Widget _buildEstrellas() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final estrellaIndex = index + 1;
        return IconButton(
          icon: Icon(
            estrellaIndex <= _puntuacion ? Icons.star : Icons.star_border,
            color: Colors.orange,
          ),
          onPressed: () {
            setState(() {
              _puntuacion = estrellaIndex;
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reseñas del Restaurante')),
      body: Column(
        children: [
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _resenas.isEmpty
                    ? const Center(child: Text('No hay reseñas disponibles.'))
                    : ListView.builder(
                        itemCount: _resenas.length,
                        itemBuilder: (context, index) {
                          final resena = _resenas[index];
                          return ListTile(
                            leading: const Icon(Icons.star, color: Colors.orange),
                            title: Text('Puntuación: ${resena['calificacion']}/5'),
                            subtitle: Text(resena['comentario'] ?? ''),
                          );
                        },
                      ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildEstrellas(),
                TextField(
                  controller: _comentarioController,
                  decoration: const InputDecoration(
                    labelText: 'Escribe tu reseña',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _enviarResena,
                  child: const Text('Enviar Reseña'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
