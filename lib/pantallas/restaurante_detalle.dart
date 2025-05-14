import 'dart:convert';
import 'package:book_eat_frontend/pantallas/resenas.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'reserva.dart';

class RestauranteDetalleScreen extends StatefulWidget {
  final Map<String, dynamic> restaurante;

  const RestauranteDetalleScreen({super.key, required this.restaurante});

  @override
  State<RestauranteDetalleScreen> createState() => _RestauranteDetalleScreenState();
}

class _RestauranteDetalleScreenState extends State<RestauranteDetalleScreen> {
  List<dynamic> _resenas = [];
  double? promedio;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarResenasYCalcularPromedio();
  }

  Future<void> _cargarResenasYCalcularPromedio() async {
    final url = Uri.parse('http://localhost:8862/resenas/restaurante/${widget.restaurante['id']}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      double suma = 0;
      for (var r in data) {
        suma += (r['calificacion'] as num).toDouble();
      }
      setState(() {
        _resenas = data;
        promedio = data.isNotEmpty ? suma / data.length : null;
        _cargando = false;
      });
    } else {
      setState(() {
        _resenas = [];
        promedio = null;
        _cargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron cargar las reseñas')),
      );
    }
  }

  Widget _buildEstrellas(double? promedio) {
    if (promedio == null) {
      return const Text('Sin reseñas disponibles');
    }

    int estrellasLlenas = promedio.floor();
    bool mediaEstrella = (promedio - estrellasLlenas) >= 0.5;
    int estrellasVacias = 5 - estrellasLlenas - (mediaEstrella ? 1 : 0);

    return Row(
      children: [
        const Text('Calificación: ', style: TextStyle(fontWeight: FontWeight.bold)),
        ...List.generate(estrellasLlenas, (_) => const Icon(Icons.star, color: Colors.orange)),
        if (mediaEstrella) const Icon(Icons.star_half, color: Colors.orange),
        ...List.generate(estrellasVacias, (_) => const Icon(Icons.star_border, color: Colors.orange)),
        const SizedBox(width: 8),
        Text('(${promedio.toStringAsFixed(1)})'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurante = widget.restaurante;

    return Scaffold(
      appBar: AppBar(
        title: Text(restaurante['nombre']),
        backgroundColor: Colors.teal,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (restaurante['imagenDestacada'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        restaurante['imagenDestacada'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    restaurante['descripcion'] ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text('Ciudad: ${restaurante['ciudad']}'),
                  Text('Dirección: ${restaurante['direccion']}'),
                  Text('Tipo de comida: ${restaurante['tipoComida']}'),
                  const SizedBox(height: 10),
                  _buildEstrellas(promedio),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservaScreen(
                            restauranteId: restaurante['id'],
                          ),
                        ),
                      );
                    },
                    child: const Text('Reservar Mesa'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResenasScreen(
                            restauranteId: restaurante['id'],
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text('Ver Reseñas'),
                  ),
                ],
              ),
            ),
    );
  }
}
