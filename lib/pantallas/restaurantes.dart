import 'dart:convert';
import 'package:book_eat_frontend/pantallas/restaurante_detalle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RestaurantesScreen extends StatefulWidget {
  const RestaurantesScreen({super.key});

  @override
  _RestaurantesScreenState createState() => _RestaurantesScreenState();
}

class _RestaurantesScreenState extends State<RestaurantesScreen> {
  late List<dynamic> restaurantes = [];

  @override
  void initState() {
    super.initState();
    _cargarRestaurantes();
  }

  Future<void> _cargarRestaurantes() async {
    final url = Uri.parse('http://localhost:8862/restaurantes');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Aquí aseguramos que se usa UTF-8
      setState(() {
        restaurantes = json.decode(utf8.decode(response.bodyBytes)); // Decodificación en UTF-8
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar los restaurantes')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurantes'),
        backgroundColor: Colors.green, // Para darle un color más agradable
      ),
      body: restaurantes.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Indicador de carga mientras se obtienen los datos
          : ListView.builder(
              itemCount: restaurantes.length,
              itemBuilder: (context, index) {
                final restaurante = restaurantes[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 5, // Para darle un poco de sombra a las tarjetas
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
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