import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'session.dart';

class ReservaScreen extends StatefulWidget {
  final int restauranteId;

  const ReservaScreen({super.key, required this.restauranteId});

  @override
  _ReservaScreenState createState() => _ReservaScreenState();
}

class _ReservaScreenState extends State<ReservaScreen> {
  DateTime _fechaHora = DateTime.now()
      .add(const Duration(hours: 1))
      .copyWith(minute: 0, second: 0, millisecond: 0, microsecond: 0);
  List<dynamic> mesasDisponibles = [];
  Map<String, dynamic>? mesaSeleccionada;
  TextEditingController _numeroPersonasController = TextEditingController();
  String? _errorMensaje;

  Future<void> _cargarMesasDisponibles() async {
    final url = Uri.parse(
      'http://localhost:8862/mesas/disponibles?restauranteId=${widget.restauranteId}&fechaHora=${_fechaHora.toIso8601String()}',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        mesasDisponibles = json.decode(utf8.decode(response.bodyBytes));
        mesaSeleccionada = null;
        _numeroPersonasController.clear();
        _errorMensaje = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron cargar las mesas disponibles')),
      );
    }
  }

  Future<void> _confirmarReserva() async {
    if (mesaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar una mesa')),
      );
      return;
    }

    int numeroPersonas = int.tryParse(_numeroPersonasController.text) ?? 0;
    if (numeroPersonas <= 0) {
      setState(() {
        _errorMensaje = 'Por favor ingrese un número válido de personas';
      });
      return;
    }

    if (numeroPersonas > mesaSeleccionada!['capacidad']) {
      setState(() {
        _errorMensaje = 'El número de personas excede la capacidad de la mesa';
      });
      return;
    }

    final reserva = {
      "fechaHora": _fechaHora.toIso8601String(),
      "numeroPersonas": numeroPersonas,
      "usuarioId": Session.usuarioId,
      "restauranteId": widget.restauranteId,
      "mesaId": mesaSeleccionada!['id']
    };

    final response = await http.post(
      Uri.parse('http://localhost:8862/reservas'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reserva),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva confirmada')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al realizar la reserva')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarMesasDisponibles();
  }

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserva de Mesa'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Fecha y hora: ${formatoFecha.format(_fechaHora)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final fecha = await showDatePicker(
                  context: context,
                  initialDate: _fechaHora,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (fecha != null) {
                  final hora = await _seleccionarHora(context, widget.restauranteId, fecha);
                  if (hora != null) {
                    setState(() {
                      _fechaHora = DateTime(
                        fecha.year,
                        fecha.month,
                        fecha.day,
                        hora.hour,
                        hora.minute,
                      );
                    });
                    _cargarMesasDisponibles();
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('Mesas disponibles:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: mesasDisponibles.length,
                itemBuilder: (context, index) {
                  final mesa = mesasDisponibles[index];
                  return Card(
                    color: mesaSeleccionada?['id'] == mesa['id'] ? Colors.teal[100] : null,
                    child: ListTile(
                      title: Text('Mesa #${mesa['numero']}'),
                      subtitle: Text('Capacidad: ${mesa['capacidad']} personas'),
                      onTap: () {
                        setState(() {
                          mesaSeleccionada = mesa;
                          _numeroPersonasController.clear();
                          _errorMensaje = null;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            if (mesaSeleccionada != null) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _numeroPersonasController,
                decoration: InputDecoration(
                  labelText: 'Número de personas',
                  errorText: _errorMensaje,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _confirmarReserva,
              child: const Text('Confirmar Reserva'),
            )
          ],
        ),
      ),
    );
  }

  Future<TimeOfDay?> _seleccionarHora(BuildContext context, int restauranteId, DateTime fecha) async {
    final String fechaFormato = '${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
    final url = Uri.parse('http://localhost:8862/reservas/disponibilidad?restauranteId=$restauranteId&fecha=$fechaFormato');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        if (data.isEmpty) {
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Sin disponibilidad'),
              content: const Text('No hay horarios disponibles para la fecha seleccionada.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
              ],
            ),
          );
          return null;
        }

        return await showDialog<TimeOfDay>(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: const Text('Selecciona una hora'),
              children: data.map<Widget>((horaStr) {
                final partes = horaStr.split(':');
                final hour = int.parse(partes[0]);
                final minute = int.parse(partes[1]);
                return SimpleDialogOption(
                  child: Text(horaStr),
                  onPressed: () => Navigator.pop(context, TimeOfDay(hour: hour, minute: minute)),
                );
              }).toList(),
            );
          },
        );
      } else {
        throw Exception('Error al obtener disponibilidad');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar horarios disponibles')),
      );
      return null;
    }
  }
}
