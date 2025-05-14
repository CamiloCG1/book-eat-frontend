import 'package:flutter/material.dart';
import 'reserva.dart';

class RestauranteDetalleScreen extends StatelessWidget {
  final Map<String, dynamic> restaurante;

  const RestauranteDetalleScreen({super.key, required this.restaurante});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurante['nombre']),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
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
                // Aquí podrías ir a una pantalla de reseñas
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reseñas próximamente...')),
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
