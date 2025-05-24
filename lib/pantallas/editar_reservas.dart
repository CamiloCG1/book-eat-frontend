import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditarReservaScreen extends StatefulWidget {
  final Map<String, dynamic> reserva;

  const EditarReservaScreen({super.key, required this.reserva});

  @override
  State<EditarReservaScreen> createState() => _EditarReservaScreenState();
}

class _EditarReservaScreenState extends State<EditarReservaScreen> {
  late DateTime fechaHora;
  late int numeroPersonas;
  int? mesaSeleccionada;
  List<dynamic> mesas = [];
  bool cargandoMesas = true;

  @override
  void initState() {
    super.initState();
    final reserva = widget.reserva;
    fechaHora = DateTime.parse(reserva['fechaHora']);
    numeroPersonas = reserva['numeroPersonas'];
    mesaSeleccionada = reserva['mesaId'];
    _cargarMesas();
  }

  Future<void> _cargarMesas() async {
    final restauranteId = widget.reserva['restauranteId'];
    final url = Uri.parse('http://localhost:8862/mesas/restaurante/$restauranteId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        mesas = data;
        cargandoMesas = false;
      });
    } else {
      setState(() {
        cargandoMesas = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar las mesas')),
      );
    }
  }

  Future<void> _guardarCambios() async {
    final mesa = mesas.firstWhere((m) => m['id'] == mesaSeleccionada, orElse: () => null);
    if (mesa == null || numeroPersonas > mesa['capacidad']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La mesa seleccionada no tiene suficiente capacidad')),
      );
      return;
    }

    final reservaActualizada = {
      "fechaHora": fechaHora.toIso8601String(),
      "numeroPersonas": numeroPersonas,
      "restauranteId": widget.reserva['restauranteId'],
      "mesaId": mesaSeleccionada
    };

    final url = Uri.parse('http://localhost:8862/reservas/${widget.reserva['id']}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reservaActualizada),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva actualizada')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar la reserva')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Reserva')),
      body: cargandoMesas
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Fecha y Hora'),
                    subtitle: Text('${fechaHora.toLocal()}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final now = DateTime.now();
                      final initialDate = fechaHora.isBefore(now) ? now : fechaHora;

                      final fecha = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: now,
                        lastDate: DateTime(2100),
                      );
                      if (fecha != null) {
                        final hora = await _seleccionarHora(context);
                        if (hora != null) {
                          setState(() {
                            fechaHora = DateTime(
                              fecha.year,
                              fecha.month,
                              fecha.day,
                              hora.hour,
                              hora.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  TextFormField(
                    initialValue: numeroPersonas.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Número de Personas'),
                    onChanged: (value) {
                      numeroPersonas = int.tryParse(value) ?? 1;
                    },
                  ),
                  DropdownButtonFormField<int>(
                    value: mesaSeleccionada,
                    decoration: const InputDecoration(labelText: 'Mesa'),
                    items: mesas.map<DropdownMenuItem<int>>((mesa) {
                      return DropdownMenuItem<int>(
                        value: mesa['id'],
                        child: Text('Mesa ${mesa['id']} - Capacidad: ${mesa['capacidad']}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        mesaSeleccionada = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _guardarCambios,
                    child: const Text('Guardar Cambios'),
                  )
                ],
              ),
            ),
    );
  }
}

Future<TimeOfDay?> _seleccionarHora(BuildContext context) async {
  return await showDialog<TimeOfDay>(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: const Text('Selecciona una hora'),
        children: List.generate(12, (index) {
          final hour = 12 + index; // De 12:00 a 23:00
          return SimpleDialogOption(
            child: Text('${hour.toString().padLeft(2, '0')}:00'),
            onPressed: () {
              Navigator.pop(context, TimeOfDay(hour: hour, minute: 0));
            },
          );
        }),
      );
    },
  );
}
