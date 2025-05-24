import 'dart:convert';
import 'package:book_eat_frontend/pantallas/restaurante_detalle.dart';
import 'session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RestaurantesScreen extends StatefulWidget {
  const RestaurantesScreen({super.key});

  @override
  _RestaurantesScreenState createState() => _RestaurantesScreenState();
}

class _RestaurantesScreenState extends State<RestaurantesScreen> {
  List<dynamic> restaurantes = [];
  Set<int> favoritos = {};

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await _cargarRestaurantes();
    await _cargarFavoritos();
  }

  Future<void> _cargarRestaurantes() async {
    final url = Uri.parse('http://localhost:8862/restaurantes');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        restaurantes = json.decode(utf8.decode(response.bodyBytes));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar los restaurantes')),
      );
    }
  }

  Future<void> _cargarFavoritos() async {
    final userId = Session.usuarioId;
    final url = Uri.parse('http://localhost:8862/restaurantes/favoritos/usuario/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List;
      setState(() {
        favoritos = data.map((f) => f['restauranteId'] as int).toSet();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron cargar los favoritos')),
      );
    }
  }

  Future<void> _toggleFavorito(int restauranteId) async {
    final userId = Session.usuarioId;
    final url = Uri.parse('http://localhost:8862/restaurantes/favoritos');
    final esFavorito = favoritos.contains(restauranteId);

    final response = esFavorito
        ? await http.delete(Uri.parse('$url?usuarioId=$userId&restauranteId=$restauranteId'))
        : await http.post(url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'usuarioId': userId, 'restauranteId': restauranteId}),
          );

    if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
      setState(() {
        if (esFavorito) {
          favoritos.remove(restauranteId);
        } else {
          favoritos.add(restauranteId);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar favoritos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurantes'),
        backgroundColor: Colors.green,
      ),
      body: restaurantes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: restaurantes.length,
              itemBuilder: (context, index) {
                final restaurante = restaurantes[index];
                final restauranteId = restaurante['id'] as int;
                final esFavorito = favoritos.contains(restauranteId);

                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: IconButton(
                      icon: Icon(
                        esFavorito ? Icons.star : Icons.star_border,
                        color: esFavorito ? Colors.yellow[700] : Colors.grey,
                      ),
                      onPressed: () => _toggleFavorito(restauranteId),
                    ),
                    title: Text(
                      restaurante['nombre'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ciudad: ${restaurante['ciudad']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Tipo de comida: ${restaurante['tipoComida']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RestauranteDetalleScreen(restaurante: restaurante),
                          ),
                        );
                      },
                      child: const Text('Detalles'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
