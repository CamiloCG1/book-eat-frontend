import 'dart:convert';
import 'package:book_eat_frontend/pantallas/editar_reservas.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UsuarioReservasScreen extends StatefulWidget {
  final int restauranteId;
  final int usuarioId;

  const UsuarioReservasScreen({super.key, required this.restauranteId, required this.usuarioId});

  @override
  State<UsuarioReservasScreen> createState() => _UsuarioReservasScreenState();
}

class _UsuarioReservasScreenState extends State<UsuarioReservasScreen> {
  List<dynamic> reservas = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarReservas();
  }

  Future<void> _cargarReservas() async {
    final url = Uri.parse('http://localhost:8862/reservas/usuario/${widget.usuarioId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final ahora = DateTime.now();
      setState(() {
        reservas = data
            .where((r) =>
                r['restauranteId'] == widget.restauranteId &&
                DateTime.parse(r['fechaHora']).isAfter(ahora))
            .toList()
          ..sort((a, b) =>
              DateTime.parse(a['fechaHora']).compareTo(DateTime.parse(b['fechaHora'])));
        cargando = false;
      });
    } else {
      setState(() {
        cargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar las reservas')),
      );
    }
  }

  Future<void> _eliminarReserva(int reservaId) async {
    final url = Uri.parse('http://localhost:8862/reservas/$reservaId');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      setState(() {
        reservas.removeWhere((r) => r['id'] == reservaId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva eliminada')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar la reserva')),
      );
    }
  }

  void _editarReserva(Map<String, dynamic> reserva) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarReservaScreen(reserva: reserva),
      ),
    );

    if (resultado == true) {
      _cargarReservas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Reservas')),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : reservas.isEmpty
              ? const Center(child: Text('No tienes reservas futuras en este restaurante'))
              : ListView.builder(
                  itemCount: reservas.length,
                  itemBuilder: (context, index) {
                    final reserva = reservas[index];
                    final fecha = DateTime.parse(reserva['fechaHora']);
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text('Reserva para ${reserva['numeroPersonas']} personas'),
                        subtitle: Text('${fecha.toLocal()}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _editarReserva(reserva),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _eliminarReserva(reserva['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
